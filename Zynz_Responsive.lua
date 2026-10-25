-- Zynz.lua - advanced responsive Roblox UI library
-- Features: window controls, tabs, keybinds, multi-select dropdowns, notifications, color tools, and static source scanning
-- Client-side use: local Zynz = loadstring(...)() or require(ModuleScript)
-- API: local Window = Zynz:CreateWindow({Name="Zynz"}); local MainTab = Window:CreateTab({Name="Main"})

local Zynz = {}
Zynz.__index = Zynz

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local COLORS = {
    Window = Color3.fromRGB(8, 8, 8),
    Tab = Color3.fromRGB(34, 34, 34),
    TabSelected = Color3.fromRGB(57, 57, 57),
    Component = Color3.fromRGB(24, 24, 24),
    ComponentHover = Color3.fromRGB(39, 39, 39),
    Line = Color3.fromRGB(80, 80, 80),
    Text = Color3.fromRGB(245, 245, 245),
    Muted = Color3.fromRGB(170, 170, 170),
    Accent = Color3.fromRGB(170, 170, 170),
}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, obj)
end

local function addTextConstraint(obj, minSize, maxSize)
    make("UITextSizeConstraint", {MinTextSize = minSize, MaxTextSize = maxSize}, obj)
end

-- Responsive sizing: phone + tablet use the same touch-friendly component sizes;
-- desktop uses the same layout with proportionally larger controls.
local function getDeviceClass()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(900, 700)
    if viewport.X <= 600 then return "phone" end
    if viewport.X <= 1100 then return "tablet" end
    return "pc"
end

local function getScale()
    return getDeviceClass() == "pc" and 15 or 12
end

local function rowHeight()
    return getDeviceClass() == "pc" and 52 or 42
end

local function controlHeight()
    return getDeviceClass() == "pc" and 34 or 30
end

local function tabWidth()
    return getDeviceClass() == "pc" and 146 or 116
end

local function applyWindowSize(root)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(900, 700)
    local device = getDeviceClass()
    local width, height
    if device == "pc" then
        width = math.min(900, viewport.X - 48)
        height = math.min(700, viewport.Y - 48)
    elseif device == "tablet" then
        -- Tall, portrait-like panel; component sizes match phone.
        width = math.min(440, viewport.X - 24)
        height = math.min(760, viewport.Y - 48)
    else
        width = math.max(280, viewport.X - 20)
        height = math.max(300, viewport.Y - 64)
    end
    root.Size = UDim2.new(0, math.max(260, width), 0, math.max(300, height))
end

local function label(parent, text, props)
    props = props or {}
    local obj = make("TextLabel", {
        Name = props.Name or "Label",
        BackgroundTransparency = 1,
        Text = tostring(text or ""),
        TextColor3 = props.TextColor3 or COLORS.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = getScale(),
        TextScaled = true,
        TextWrapped = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
        Size = props.Size or UDim2.new(1, 0, 1, 0),
        Position = props.Position or UDim2.new(),
    }, parent)
    addTextConstraint(obj, props.MinTextSize or 4, props.MaxTextSize or getScale())
    return obj
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function connectHover(button)
    button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.ComponentHover}):Play() end)
    button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.Component}):Play() end)
end

-- Top-right notification manager. Each toast has an independent duration timer and exit tween.
local notificationManagers = setmetatable({}, {__mode = "k"})
local function getNotificationManager(gui)
    if notificationManagers[gui] then return notificationManagers[gui] end
    local manager = {Items = {}, Gui = gui}
    notificationManagers[gui] = manager
    local function relayout()
        local y = 12
        for _, item in ipairs(manager.Items) do
            if item.Frame and item.Frame.Parent then
                item.TargetY = y
                if not item.Exiting and not item.Entering then
                    TweenService:Create(item.Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -12, 0, y)}):Play()
                end
                y = y + item.Frame.AbsoluteSize.Y + 8
            end
        end
    end
    manager.Show = function(opts)
        opts = opts or {}
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local width = math.clamp(math.floor(viewport.X * 0.42), 180, 270)
        if viewport.X < 430 then width = math.max(155, viewport.X - 24) end
        local height = 66
        local duration = math.max(0.1, tonumber(opts.Duration) or 3)
        local frame = make("Frame", {Name="ZynzNotification", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1, width + 24, 0, 12), Size=UDim2.new(0,width,0,height), BackgroundColor3=COLORS.Component, BorderSizePixel=0, ClipsDescendants=true, ZIndex=100}, gui)
        round(frame, 9)
        make("UIStroke", {Color=Color3.fromRGB(58,58,58), Thickness=1, Transparency=0.15}, frame)
        label(frame, opts.Name or "Notification", {Position=UDim2.new(0,10,0,6), Size=UDim2.new(1,-20,0,20), MaxTextSize=math.max(7,getScale()+1), MinTextSize=4})
        label(frame, opts.Paragraph or opts.Content or opts.Text or "", {Position=UDim2.new(0,10,0,27), Size=UDim2.new(1,-20,0,25), TextColor3=COLORS.Muted, MaxTextSize=getScale(), MinTextSize=4, TextYAlignment=Enum.TextYAlignment.Top})
        local track = make("Frame", {Name="TimerLine", Position=UDim2.new(0,0,1,-3), Size=UDim2.new(1,0,0,3), BackgroundColor3=Color3.fromRGB(65,65,65), BorderSizePixel=0, ZIndex=102}, frame)
        local fill = make("Frame", {Name="TimerFill", Size=UDim2.fromScale(1,1), BackgroundColor3=COLORS.Accent, BorderSizePixel=0, ZIndex=103}, track)
        local item = {Frame=frame, Exiting=false, Entering=true, Duration=duration}
        table.insert(manager.Items, item)
        relayout()
        local enterTween = TweenService:Create(frame, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position=UDim2.new(1,-12,0,item.TargetY or 12)})
        enterTween:Play()
        enterTween.Completed:Connect(function() item.Entering = false end)
        local timer = TweenService:Create(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)})
        timer:Play()
        task.delay(duration, function()
            if not frame.Parent or item.Exiting then return end
            item.Exiting = true
            local exit = TweenService:Create(frame, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position=UDim2.new(1,width+30,0,item.TargetY or 12)})
            exit:Play()
            exit.Completed:Wait()
            if frame.Parent then frame:Destroy() end
            for i, existing in ipairs(manager.Items) do if existing == item then table.remove(manager.Items, i); break end end
            relayout()
        end)
        return frame
    end
    return manager
end

function Zynz:CreateWindow(options)
    options = options or {}
    local gui = make("ScreenGui", {
        Name = "ZynzUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
    local old = gui.Parent:FindFirstChild("ZynzUI")
    if old and old ~= gui then old:Destroy() end

    local root = make("Frame", {
        Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.88, 0, 0.72, 0), BackgroundColor3 = COLORS.Window, BorderSizePixel = 0,
    }, gui)
    applyWindowSize(root)
    make("UISizeConstraint", {MinSize = Vector2.new(260, 300), MaxSize = Vector2.new(920, 780)}, root)
    round(root, 12)
    make("UIStroke", {Color = Color3.fromRGB(45,45,45), Thickness = 1, Transparency = 0.2}, root)

    local header = make("Frame", {Name="Header", Size=UDim2.new(1,0,0,44), BackgroundTransparency=1}, root)
    local title = label(header, options.Name or "Zynz", {Size=UDim2.new(1,-74,1,0), Position=UDim2.new(0,12,0,0), MaxTextSize=12, MinTextSize=7})
    local minimize = make("TextButton", {Name="Minimize", Text="−", Font=Enum.Font.GothamBold, TextSize=18, TextColor3=COLORS.Text, BackgroundColor3=COLORS.Component, BorderSizePixel=0, Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-72,0,6), AutoButtonColor=false}, header)
    round(minimize, 6)
    local close = make("TextButton", {Name="Close", Text="×", Font=Enum.Font.GothamBold, TextSize=18, TextColor3=COLORS.Text, BackgroundColor3=COLORS.Component, BorderSizePixel=0, Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-36,0,6), AutoButtonColor=false}, header)
    round(close, 6)

    local content = make("Frame", {Name="Content", Position=UDim2.new(0,10,0,50), Size=UDim2.new(1,-20,1,-60), BackgroundTransparency=1}, root)
    local page = make("Frame", {Name="Page", Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,-(tabWidth()+8),1,0), BackgroundTransparency=1}, content)
    local pages = make("Folder", {Name="Pages"}, page)
    local tabList = make("ScrollingFrame", {Name="Tabs", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,tabWidth(),1,0), BackgroundColor3=COLORS.Tab, BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=COLORS.Line, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y}, content)
    round(tabList, 8)
    make("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder}, tabList)
    make("UIPadding", {PaddingTop=UDim.new(0,6), PaddingLeft=UDim.new(0,5), PaddingRight=UDim.new(0,5), PaddingBottom=UDim.new(0,6)}, tabList)

    local restore = make("TextButton", {Name="RestoreZynz", Text="Zynz", Font=Enum.Font.GothamMedium, TextColor3=COLORS.Text, TextSize=12, TextScaled=true, BackgroundColor3=COLORS.Component, BorderSizePixel=0, Visible=false, Size=UDim2.new(0,84,0,38), Position=UDim2.new(0,15,0.5,-19), AutoButtonColor=false}, gui)
    round(restore, 9)
    addTextConstraint(restore, 9, 15)
    makeDraggable(root, header)
    makeDraggable(restore)

    -- Resize only from the two bottom corners; hold for 0.5s before dragging.
    local resizing, resizeCorner, resizeStart, sizeStart, posStart, holdToken = false, nil, nil, nil, nil, 0
    local function addResizeHandle(name, rightSide)
        local handle = make("TextButton", {Name=name, Text="", AutoButtonColor=false, BackgroundTransparency=1,
            AnchorPoint=Vector2.new(rightSide and 1 or 0,1), Position=UDim2.new(rightSide and 1 or 0,0,1,0),
            Size=UDim2.new(0,22,0,22), ZIndex=20}, root)
        local mark = make("Frame", {Name="Grip", AnchorPoint=Vector2.new(rightSide and 1 or 0,1),
            Position=UDim2.new(rightSide and 1 or 0,-4,1,-4), Size=UDim2.new(0,10,0,2),
            BackgroundColor3=COLORS.Line, BorderSizePixel=0, Rotation=rightSide and -45 or 45, ZIndex=21}, handle)
        handle.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            holdToken += 1; local token=holdToken
            local origin=input.Position
            task.delay(0.5,function()
                if token ~= holdToken or not handle.Parent then return end
                resizing=true; resizeCorner=rightSide and "Right" or "Left"; resizeStart=origin
                sizeStart=root.AbsoluteSize; posStart=root.Position
            end)
        end)
        handle.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                holdToken += 1; resizing=false; resizeCorner=nil
            end
        end)
    end
    addResizeHandle("ResizeBottomRight", true)
    addResizeHandle("ResizeBottomLeft", false)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if resizing then resizing=false; resizeCorner=nil end
            holdToken += 1
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not resizing or not resizeStart or not sizeStart then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta=input.Position-resizeStart
        local camera=workspace.CurrentCamera
        local viewport=camera and camera.ViewportSize or Vector2.new(800,600)
        local minW,minH=300,230
        local maxW,maxH=math.min(760,viewport.X-16),math.min(540,viewport.Y-16)
        local w=math.clamp(sizeStart.X+(resizeCorner=="Right" and delta.X or -delta.X),minW,math.max(minW,maxW))
        local h=math.clamp(sizeStart.Y+delta.Y,minH,math.max(minH,maxH))
        root.Size=UDim2.new(0,w,0,h)
        local shiftX=(w-sizeStart.X)/2*(resizeCorner=="Right" and 1 or -1)
        local shiftY=(h-sizeStart.Y)/2
        root.Position=UDim2.new(posStart.X.Scale,posStart.X.Offset+shiftX,posStart.Y.Scale,posStart.Y.Offset+shiftY)
    end)

    local window = {Gui=gui, Root=root, _tabs={}, _active=nil, _restore=restore}
    function window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tostring(tabOptions.Name or "Tab")
        local tabButton = make("TextButton", {Name=tabName.."TabButton", Text=tabName, Font=Enum.Font.GothamMedium, TextColor3=COLORS.Text, TextSize=getScale(), TextScaled=true, TextTruncate=Enum.TextTruncate.AtEnd, TextXAlignment=Enum.TextXAlignment.Left, BackgroundColor3=COLORS.Tab, BorderSizePixel=0, Size=UDim2.new(1,0,0,rowHeight()), AutoButtonColor=false}, tabList)
        round(tabButton, 6); addTextConstraint(tabButton, 4, getScale())
        make("UIPadding", {PaddingLeft=UDim.new(0,7), PaddingRight=UDim.new(0,4)}, tabButton)
        local tabPage = make("ScrollingFrame", {Name=tabName, Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=COLORS.Line, Visible=false, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y}, pages)
        make("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, tabPage)
        make("UIPadding", {PaddingTop=UDim.new(0,2), PaddingRight=UDim.new(0,5), PaddingBottom=UDim.new(0,4)}, tabPage)
        local tab = {Page=tabPage, Button=tabButton, _order=0}
        local function activate()
            for _, item in ipairs(window._tabs) do
                item.Page.Visible = false
                item.Button.BackgroundColor3 = COLORS.Tab
            end
            tabPage.Visible = true
            tabButton.BackgroundColor3 = COLORS.TabSelected
            window._active = tab
        end
        tabButton.MouseButton1Click:Connect(activate)
        table.insert(window._tabs, tab)
        if #window._tabs == 1 then activate() end

        local function nextOrder(obj)
            tab._order += 1
            obj.LayoutOrder = tab._order
            return obj
        end
        local function component(name, height)
            local frame = make("Frame", {Name=name, Size=UDim2.new(1,0,0,height or rowHeight()), BackgroundColor3=COLORS.Component, BorderSizePixel=0, ClipsDescendants=true}, tabPage)
            round(frame, 7)
            return nextOrder(frame)
        end
        local function componentName(parent, name, rightWidth)
            return label(parent, name or "", {Size=UDim2.new(1,-(rightWidth or 12),1,0), Position=UDim2.new(0,9,0,0), MaxTextSize=getScale(), MinTextSize=4})
        end

        function tab:CreateButton(opts)
            opts=opts or {}; local frame=component("Button",rowHeight()); local txt=componentName(frame,opts.Name or "Button")
            local hit=make("TextButton",{Name="Hitbox",Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},frame)
            connectHover(frame)
            hit.MouseButton1Click:Connect(function() if type(opts.Callback)=="function" then task.spawn(opts.Callback) end end)
            return {Frame=frame,Label=txt}
        end

        function tab:CreateToggle(opts)
            opts=opts or {}; local frame=component("Toggle",rowHeight()); componentName(frame,opts.Name or "Toggle",38)
            local state=opts.Value == true or opts.ValueRn == true
            local track=make("Frame",{Name="Track",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-7,0.5,0),Size=UDim2.new(0,34,0,18),BackgroundColor3=state and COLORS.Accent or Color3.fromRGB(65,65,65),BorderSizePixel=0},frame); round(track,8)
            local knob=make("Frame",{Name="Knob",Position=state and UDim2.new(1,-16,0,2) or UDim2.new(0,2,0,2),Size=UDim2.new(0,18,0,18),BackgroundColor3=Color3.fromRGB(250,250,250),BorderSizePixel=0},track); round(knob,8)
            local hit=make("TextButton",{Name="Hitbox",Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},frame)
            local function set(v,call) state=v==true; TweenService:Create(track,TweenInfo.new(.12),{BackgroundColor3=state and COLORS.Accent or Color3.fromRGB(65,65,65)}):Play(); knob:TweenPosition(state and UDim2.new(1,-16,0,2) or UDim2.new(0,2,0,2),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.12,true); if call and type(opts.Callback)=="function" then task.spawn(opts.Callback,state) end end
            hit.MouseButton1Click:Connect(function() set(not state,true) end)
            return {Frame=frame,GetValue=function() return state end,SetValue=function(_,v) set(v,true) end}
        end

        function tab:CreateSlider(opts)
            opts=opts or {}; local frame=component("Slider",43); componentName(frame,opts.Name or "Slider",48)
            local min,max=1,100
            if type(opts.Range)=="table" then min=tonumber(opts.Range[1]) or 1; max=tonumber(opts.Range[2]) or 100
            elseif type(opts.Range)=="number" then max=opts.Range
            elseif type(opts.Range)=="string" then local a,b=opts.Range:match("([%-]?%d+)%s*[%-%:]%s*([%-]?%d+)"); min=tonumber(a) or 1; max=tonumber(b) or 100 end
            min=tonumber(opts.Min) or min; max=tonumber(opts.Max) or max; if max<=min then max=min+1 end
            local value=math.clamp(tonumber(opts.Value) or min,min,max)
            local valueText=label(frame,tostring(value),{Size=UDim2.new(0,38,0,14),Position=UDim2.new(1,-43,0,2),TextXAlignment=Enum.TextXAlignment.Right,MaxTextSize=getScale(),MinTextSize=4,TextColor3=COLORS.Muted})
            local rail=make("Frame",{Name="Rail",Position=UDim2.new(0,9,1,-12),Size=UDim2.new(1,-18,0,4),BackgroundColor3=Color3.fromRGB(65,65,65),BorderSizePixel=0},frame); round(rail,4)
            local fill=make("Frame",{Name="Fill",Size=UDim2.new((value-min)/(max-min),0,1,0),BackgroundColor3=COLORS.Accent,BorderSizePixel=0},rail); round(fill,4)
            local thumb=make("Frame",{Name="Thumb",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new((value-min)/(max-min),0,.5,0),Size=UDim2.new(0,18,0,18),BackgroundColor3=Color3.fromRGB(250,250,250),BorderSizePixel=0,ZIndex=3},rail); round(thumb,20); make("UIStroke",{Color=COLORS.Accent,Thickness=1},thumb)
            local dragging=false
            local function update(input,call)
                local pct=math.clamp((input.Position.X-rail.AbsolutePosition.X)/math.max(rail.AbsoluteSize.X,1),0,1)
                local raw=min+(max-min)*pct
                local step=tonumber(opts.Increment or opts.Step) or 1
                value=math.clamp(math.floor((raw-min)/step+0.5)*step+min,min,max)
                local normalized=(value-min)/(max-min)
                fill.Size=UDim2.new(normalized,0,1,0); thumb.Position=UDim2.new(normalized,0,.5,0); valueText.Text=tostring(value)
                if call and type(opts.Callback)=="function" then task.spawn(opts.Callback,value) end
            end
            local function begin(input) dragging=true; update(input,true) end
            thumb.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then begin(input) end end)
            rail.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then begin(input) end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input,true) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
            return {Frame=frame,GetValue=function() return value end,SetValue=function(_,v) value=math.clamp(tonumber(v) or min,min,max); local p=(value-min)/(max-min); fill.Size=UDim2.new(p,0,1,0); thumb.Position=UDim2.new(p,0,.5,0); valueText.Text=tostring(value); if type(opts.Callback)=="function" then task.spawn(opts.Callback,value) end end}
        end

        function tab:CreateParagraph(opts)
            opts=opts or {}; local name=tostring(opts.Name or "Paragraph"); local body=tostring(opts.Content or opts.Text or "")
            local combined=name..(body~="" and "\n"..body or "")
            local lineCount=1
            for _ in combined:gmatch("\n") do lineCount+=1 end
            local approx=math.max(1,math.ceil(#combined/74))
            local height=math.clamp(14+math.max(lineCount,approx)*11,34,180)
            local frame=make("Frame",{Name="Paragraph",Size=UDim2.new(1,0,0,height),BackgroundColor3=COLORS.Component,BorderSizePixel=0},tabPage); round(frame,7); nextOrder(frame)
            local txt=make("TextLabel",{Name="Text",Position=UDim2.new(0,9,0,5),Size=UDim2.new(1,-18,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=combined,TextColor3=COLORS.Text,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=false,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,RichText=opts.RichText==true},frame)
            make("UITextSizeConstraint",{MinTextSize=getScale(),MaxTextSize=getScale()},txt)
            local function resizeParagraph()
                task.defer(function()
                    if not frame.Parent or not txt.Parent then return end
                    local needed = math.clamp(math.ceil(txt.TextBounds.Y) + 10, 28, 220)
                    frame.Size = UDim2.new(1,0,0,needed)
                end)
            end
            txt:GetPropertyChangedSignal("TextBounds"):Connect(resizeParagraph)
            resizeParagraph()
            return {Frame=frame,Label=txt,SetText=function(_,newText) txt.Text=tostring(newText); resizeParagraph() end}
        end

        function tab:CreateSection(opts)
            opts=opts or {}; local frame=make("Frame",{Name="Section",Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,BorderSizePixel=0},tabPage); nextOrder(frame)
            local txt=label(frame,opts.Name or "Section",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,3,0,0),TextColor3=COLORS.Muted,MaxTextSize=getScale(),MinTextSize=4})
            return {Frame=frame,Label=txt}
        end

        function tab:CreateInput(opts)
            opts=opts or {}; local frame=component("Input",rowHeight()); componentName(frame,opts.Name or "Input",95)
            local input=make("TextBox",{Name="InputBox",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),Size=UDim2.new(0,110,0,controlHeight()),BackgroundColor3=Color3.fromRGB(39,39,39),BorderSizePixel=0,Text=tostring(opts.Default or ""),PlaceholderText=opts.Placeholder or "Enter...",TextColor3=COLORS.Text,PlaceholderColor3=COLORS.Muted,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,ClearTextOnFocus=false},frame); round(input,5); addTextConstraint(input,4,getScale())
            input.FocusLost:Connect(function(enter) if type(opts.Callback)=="function" then task.spawn(opts.Callback,input.Text,enter) end end)
            return {Frame=frame,Input=input,GetValue=function() return input.Text end,SetValue=function(_,v) input.Text=tostring(v) end}
        end

        function tab:CreateDropdown(opts)
            opts=opts or {}; local frame=component("Dropdown",rowHeight()); componentName(frame,opts.Name or "Dropdown",100)
            local optionsList=opts.Options or {}
            local chosen=tostring(opts.CurrentOption or optionsList[1] or "Select")
            local drop=make("TextButton",{Name="Select",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-5,.5,0),Size=UDim2.new(0,116,0,controlHeight()),BackgroundColor3=Color3.fromRGB(39,39,39),BorderSizePixel=0,Text=chosen.." ▾",TextColor3=COLORS.Text,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,TextTruncate=Enum.TextTruncate.AtEnd,AutoButtonColor=false,ZIndex=4},frame)
            round(drop,5); addTextConstraint(drop,4,getScale())
            local popup
            local function closePopup() if popup then popup:Destroy(); popup=nil end; drop.Text=chosen.." ▾" end
            local function choose(value)
                chosen=tostring(value); closePopup()
                if type(opts.Callback)=="function" then task.spawn(opts.Callback,value) end
            end
            local function openPopup()
                if popup then closePopup(); return end
                if #optionsList==0 then return end
                local rowH=24; local maxRows=math.min(#optionsList,6)
                popup=make("Frame",{Name="DropdownOptions",Position=UDim2.new(0,frame.AbsolutePosition.X-tabPage.AbsolutePosition.X,0,frame.AbsolutePosition.Y-tabPage.AbsolutePosition.Y+frame.AbsoluteSize.Y+2),Size=UDim2.new(0,math.max(88,drop.AbsoluteSize.X),0,rowH*maxRows),BackgroundColor3=Color3.fromRGB(31,31,31),BorderSizePixel=0,ZIndex=50},tabPage)
                round(popup,6); make("UIStroke",{Color=COLORS.Line,Thickness=1},popup)
                local list=make("ScrollingFrame",{Name="Options",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(0,0,0,#optionsList*rowH),ZIndex=51},popup)
                for i,value in ipairs(optionsList) do
                    local item=make("TextButton",{Name="Option",Text=tostring(value),TextColor3=COLORS.Text,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,0,0,(i-1)*rowH),Size=UDim2.new(1,-2,0,rowH),BackgroundColor3=tostring(value)==chosen and COLORS.TabSelected or COLORS.Tab,BorderSizePixel=0,AutoButtonColor=false,ZIndex=52},list)
                    make("UIPadding",{PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,4)},item); addTextConstraint(item,4,getScale())
                    item.MouseButton1Click:Connect(function() choose(value) end)
                end
                drop.Text=chosen.." ▴"
            end
            drop.MouseButton1Click:Connect(openPopup)
            return {Frame=frame,GetValue=function() return chosen end,SetValue=function(_,v) chosen=tostring(v); drop.Text=chosen..(popup and " ▴" or " ▾") end,Open=openPopup,Close=closePopup}
        end

        function tab:CreateLabel(opts)
            opts = type(opts) == "table" and opts or {Name = tostring(opts or "Label")}
            local frame = make("Frame", {Name="Label", Size=UDim2.new(1,0,0,opts.Height or 24), BackgroundTransparency=1, BorderSizePixel=0}, tabPage)
            nextOrder(frame)
            local txt = label(frame, opts.Name or opts.Text or "Label", {Position=UDim2.new(0,4,0,0), Size=UDim2.new(1,-8,1,0), TextColor3=opts.Color or COLORS.Text, MaxTextSize=getScale(), MinTextSize=4})
            return {Frame=frame, Label=txt, SetText=function(_, value) txt.Text=tostring(value) end, SetColor=function(_, color) if typeof(color)=="Color3" then txt.TextColor3=color end end}
        end

        function tab:CreateDivider(opts)
            opts = opts or {}
            local frame = make("Frame", {Name="Divider", Size=UDim2.new(1,0,0,opts.Height or 7), BackgroundTransparency=1, BorderSizePixel=0}, tabPage)
            nextOrder(frame)
            make("Frame", {Name="Line", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(1,-8,0,1), BackgroundColor3=opts.Color or COLORS.Line, BorderSizePixel=0}, frame)
            return {Frame=frame}
        end

        function tab:CreateKeybind(opts)
            opts = opts or {}
            local frame = component("Keybind", rowHeight())
            componentName(frame, opts.Name or "Keybind", 92)
            local current = opts.KeyCode or opts.Default or Enum.KeyCode.RightControl
            if typeof(current) == "string" then current = Enum.KeyCode[current] or Enum.KeyCode.RightControl end
            if typeof(current) ~= "EnumItem" then current = Enum.KeyCode.RightControl end
            local listening = false
            local button = make("TextButton", {Name="KeyButton", AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-6,.5,0), Size=UDim2.new(0,100,0,controlHeight()), BackgroundColor3=Color3.fromRGB(39,39,39), BorderSizePixel=0, Text=current.Name, TextColor3=COLORS.Text, Font=Enum.Font.Gotham, TextSize=getScale(), TextScaled=true, AutoButtonColor=false}, frame)
            round(button,5); addTextConstraint(button,4,getScale())
            button.MouseButton1Click:Connect(function() listening=true; button.Text="Press key..." end)
            local connection
            connection=UserInputService.InputBegan:Connect(function(input, processed)
                if not button.Parent then if connection then connection:Disconnect() end; return end
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                        current=input.KeyCode; listening=false; button.Text=current.Name
                        if type(opts.Callback)=="function" then task.spawn(opts.Callback,current) end
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                        current=input.UserInputType; listening=false; button.Text=current.Name:gsub("MouseButton", "Mouse ")
                        if type(opts.Callback)=="function" then task.spawn(opts.Callback,current) end
                    end
                elseif not processed and input.KeyCode == current and type(opts.Callback)=="function" then
                    task.spawn(opts.Callback,current)
                end
            end)
            return {Frame=frame, Button=button, GetValue=function() return current end,
                SetValue=function(_, key) if typeof(key)=="string" then key=Enum.KeyCode[key] end; if typeof(key)=="EnumItem" then current=key; button.Text=current.Name end end,
                BeginCapture=function() listening=true; button.Text="Press key..." end,
                Destroy=function() if connection then connection:Disconnect() end; if frame then frame:Destroy() end end}
        end

        function tab:CreateMultiDropdown(opts)
            opts=opts or {}
            local frame=component("MultiDropdown",rowHeight())
            componentName(frame,opts.Name or "Multi Select",105)
            local available=opts.Options or {}
            local selected={}
            local initial=opts.CurrentOptions or opts.Default or {}
            for _,value in ipairs(initial) do selected[tostring(value)]=true end
            local function selectedText()
                local values={}
                for _,value in ipairs(available) do if selected[tostring(value)] then table.insert(values,tostring(value)) end end
                if #values==0 then return "Select..." end
                local joined=table.concat(values,", ")
                return #joined>22 and (joined:sub(1,19).."...") or joined
            end
            local button=make("TextButton",{Name="MultiSelectButton",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-5,.5,0),Size=UDim2.new(0,94,0,21),BackgroundColor3=Color3.fromRGB(39,39,39),BorderSizePixel=0,Text=selectedText().." ▾",TextColor3=COLORS.Text,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,TextTruncate=Enum.TextTruncate.AtEnd,AutoButtonColor=false,ZIndex=4},frame)
            round(button,5); addTextConstraint(button,4,getScale())
            local popup
            local function closePopup() if popup then popup:Destroy(); popup=nil end; if button.Parent then button.Text=selectedText().." ▾" end end
            local function toggle(value)
                local key=tostring(value); selected[key]=not selected[key] or nil
                if type(opts.Callback)=="function" then
                    local result={}; for _,v in ipairs(available) do if selected[tostring(v)] then table.insert(result,v) end end
                    task.spawn(opts.Callback,result)
                end
                if popup and popup.Parent then
                    for _,child in ipairs(popup:GetDescendants()) do
                        if child:IsA("TextButton") and child:GetAttribute("OptionValue")==key then child.Text=(selected[key] and "✓  " or "   ")..key; child.BackgroundColor3=selected[key] and COLORS.TabSelected or COLORS.Tab end
                    end
                    button.Text=selectedText().." ▴"
                end
            end
            local function openPopup()
                if popup then closePopup(); return end
                if #available==0 then return end
                local rowH=24; local maxRows=math.min(#available,7)
                popup=make("Frame",{Name="MultiDropdownOptions",Position=UDim2.new(0,frame.AbsolutePosition.X-tabPage.AbsolutePosition.X,0,frame.AbsolutePosition.Y-tabPage.AbsolutePosition.Y+frame.AbsoluteSize.Y+2),Size=UDim2.new(0,math.max(94,button.AbsoluteSize.X),0,rowH*maxRows),BackgroundColor3=Color3.fromRGB(31,31,31),BorderSizePixel=0,ZIndex=60},tabPage)
                round(popup,6); make("UIStroke",{Color=COLORS.Line,Thickness=1},popup)
                local list=make("ScrollingFrame",{Name="Options",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(0,0,0,#available*rowH),ZIndex=61},popup)
                for i,value in ipairs(available) do
                    local key=tostring(value); local on=selected[key]==true
                    local item=make("TextButton",{Name="Option",Text=(on and "✓  " or "   ")..key,TextColor3=COLORS.Text,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,0,0,(i-1)*rowH),Size=UDim2.new(1,-2,0,rowH),BackgroundColor3=on and COLORS.TabSelected or COLORS.Tab,BorderSizePixel=0,AutoButtonColor=false,ZIndex=62},list)
                    item:SetAttribute("OptionValue",key); make("UIPadding",{PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,4)},item); addTextConstraint(item,4,getScale())
                    item.MouseButton1Click:Connect(function() toggle(value) end)
                end
                button.Text=selectedText().." ▴"
            end
            button.MouseButton1Click:Connect(openPopup)
            return {Frame=frame,GetValue=function() local result={}; for _,v in ipairs(available) do if selected[tostring(v)] then table.insert(result,v) end end; return result end,
                SetValue=function(_,values,call) selected={}; for _,v in ipairs(values or {}) do selected[tostring(v)]=true end; if popup then closePopup() end; button.Text=selectedText().." ▾"; if call~=false and type(opts.Callback)=="function" then task.spawn(opts.Callback,values or {}) end end,
                Refresh=function(_,newOptions) available=newOptions or {}; if popup then closePopup() end; button.Text=selectedText().." ▾" end, Open=openPopup, Close=closePopup}
        end

        function tab:CreateColorPicker(opts)
            opts=opts or {}; local frame=component("ColorPicker",146); componentName(frame,opts.Name or "Color",0)
            local current=opts.CurrentColor or opts.Color or Color3.fromRGB(233,2,200)
            if typeof(current)~="Color3" then current=Color3.fromRGB(233,2,200) end
            local h,s,v=current:ToHSV()
            local picker=make("Frame",{Name="Picker",Position=UDim2.new(0,8,0,25),Size=UDim2.new(1,-16,0,67),BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,ClipsDescendants=true},frame); round(picker,5)
            local sat=make("Frame",{Name="SaturationValue",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0},picker); round(sat,5)
            make("UIGradient",{Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromHSV(h,1,1))},sat)
            local black=make("Frame",{Name="BlackOverlay",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0},sat); round(black,5)
            make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})},black)
            local cursor=make("Frame",{Name="ColorCursor",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(s,0,1-v,0),Size=UDim2.new(0,13,0,13),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=4},picker); round(cursor,10); make("UIStroke",{Color=Color3.new(0,0,0),Thickness=1},cursor)
            local hue=make("Frame",{Name="Hue",Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,7),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},frame); round(hue,4)
            make("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(.17,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(.33,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(.67,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(.83,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})},hue)
            local hueKnob=make("Frame",{Name="HueThumb",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(h,0,.5,0),Size=UDim2.new(0,10,0,16),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=3},hue); round(hueKnob,3); make("UIStroke",{Color=Color3.fromRGB(20,20,20),Thickness=1},hueKnob)
            local rgb=make("Frame",{Name="RGBInputs",Position=UDim2.new(0,0,1,-11),Size=UDim2.new(1,0,0,11),BackgroundTransparency=1},frame)
            local boxes={}
            for i,channel in ipairs({"R","G","B"}) do
                local box=make("TextBox",{Name=channel,Position=UDim2.new((i-1)/3,0,0,0),Size=UDim2.new(1/3,-3,1,0),BackgroundColor3=Color3.fromRGB(39,39,39),BorderSizePixel=0,Text="0",TextColor3=COLORS.Text,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,ClearTextOnFocus=false},rgb); round(box,3); addTextConstraint(box,4,getScale()); boxes[i]=box
            end
            local function refresh(call)
                current=Color3.fromHSV(h,s,v); picker.BackgroundColor3=Color3.fromHSV(h,1,1); sat:FindFirstChildOfClass("UIGradient").Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromHSV(h,1,1)); cursor.Position=UDim2.new(s,0,1-v,0); hueKnob.Position=UDim2.new(h,0,.5,0)
                local r,g,b=math.floor(current.R*255+.5),math.floor(current.G*255+.5),math.floor(current.B*255+.5)
                boxes[1].Text=tostring(r); boxes[2].Text=tostring(g); boxes[3].Text=tostring(b)
                if call and type(opts.Callback)=="function" then task.spawn(opts.Callback,current,{r,g,b}) end
            end
            local dragSat,dragHue=false,false
            local function setSat(input) s=math.clamp((input.Position.X-picker.AbsolutePosition.X)/picker.AbsoluteSize.X,0,1); v=1-math.clamp((input.Position.Y-picker.AbsolutePosition.Y)/picker.AbsoluteSize.Y,0,1); refresh(true) end
            local function setHue(input) h=math.clamp((input.Position.X-hue.AbsolutePosition.X)/hue.AbsoluteSize.X,0,1); refresh(true) end
            picker.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragSat=true; setSat(input) end end)
            hue.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragHue=true; setHue(input) end end)
            UserInputService.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then if dragSat then setSat(input) elseif dragHue then setHue(input) end end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragSat=false; dragHue=false end end)
            for i,box in ipairs(boxes) do box.FocusLost:Connect(function() local vals={tonumber(boxes[1].Text),tonumber(boxes[2].Text),tonumber(boxes[3].Text)}; for n=1,3 do vals[n]=math.clamp(math.floor(vals[n] or 0),0,255) end; current=Color3.fromRGB(vals[1],vals[2],vals[3]); h,s,v=current:ToHSV(); refresh(true) end) end
            refresh(false)
            return {Frame=frame,GetValue=function() return current end,SetValue=function(_,color) if typeof(color)=="Color3" then current=color; h,s,v=current:ToHSV(); refresh(true) end end}
        end

        -- Friendly alias: both CreateColor and CreateColorPicker work.
        tab.CreateColor = tab.CreateColorPicker

        function tab:CreateNotification(opts)
            return getNotificationManager(gui).Show(opts or {})
        end

        return tab
    end

    local function collapse()
        root.Visible=false; restore.Visible=true
    end
    minimize.MouseButton1Click:Connect(collapse)
    close.MouseButton1Click:Connect(function() gui:Destroy() end)
    restore.MouseButton1Click:Connect(function() restore.Visible=false; root.Visible=true end)
    function window:Minimize() root.Visible=false; restore.Visible=true end
    function window:Restore() restore.Visible=false; root.Visible=true end
    function window:SetVisible(value) root.Visible=value==true; restore.Visible=not root.Visible end
    function window:SetTitle(value) title.Text=tostring(value or "Zynz") end
    function window:GetActiveTab() return self._active end
    function window:SelectTab(name)
        for _, item in ipairs(self._tabs) do
            if item.Button.Text == tostring(name) then
                for _, other in ipairs(self._tabs) do other.Page.Visible=false; other.Button.BackgroundColor3=COLORS.Tab end
                item.Page.Visible=true; item.Button.BackgroundColor3=COLORS.TabSelected; self._active=item; return true
            end
        end
        return false
    end
    function window:Destroy() if gui and gui.Parent then gui:Destroy() end end
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            applyWindowSize(root)
            page.Size = UDim2.new(1, -(tabWidth()+8), 1, 0)
            tabList.Size = UDim2.new(0, tabWidth(), 1, 0)
            for _, item in ipairs(window._tabs) do
                item.Button.Size = UDim2.new(1, 0, 0, rowHeight())
            end
        end)
        applyWindowSize(root)
    end
    return window
end

Zynz.Version = "2.1.0-responsive"
Zynz.Components = {"Button", "Toggle", "Slider", "Paragraph", "Section", "Label", "Divider", "Input", "Dropdown", "MultiDropdown", "Keybind", "ColorPicker", "Notification"}

function Zynz:SetTheme(theme)
    if type(theme) ~= "table" then return false end
    for key, value in pairs(theme) do
        if COLORS[key] and typeof(value) == "Color3" then COLORS[key] = value end
    end
    return true
end

function Zynz:GetTheme()
    local copy = {}
    for key, value in pairs(COLORS) do copy[key] = value end
    return copy
end

function Zynz:Notify(options)
    options=options or {}
    local gui=(LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")) or ((gethui and gethui()) or nil)
    if not gui then return end
    return getNotificationManager(gui).Show(options)
end

-- Static source scanner: parses UI declarations without executing the inspected source.
-- Optional opts.ResolveSource(url) may return source text for a URL; it must only fetch/read text.
local function scanBalanced(source, openAt)
    local depth, quote, longEq, i = 0, nil, nil, openAt
    while i <= #source do
        local c, n = source:sub(i,i), source:sub(i,i+1)
        if quote then
            if c == "\\" then i = i + 2
            elseif c == quote then quote = nil; i = i + 1
            else i = i + 1 end
        elseif longEq then
            local close = "]" .. string.rep("=", longEq) .. "]"
            local at = source:find(close, i, true)
            if not at then return nil end
            i = at + #close; longEq = nil
        elseif n == "--" then
            local eq = source:match("^%-%-%[(=*)%[", i)
            if eq then
                local close = "]"..eq.."]"; local at = source:find(close, i + 4 + #eq, true)
                if not at then return nil end
                i = at + #close
            else local nl = source:find("\n", i, true); i = nl and nl + 1 or #source + 1 end
        elseif c == '"' or c == "'" then quote = c; i = i + 1
        elseif c == "[" then
            local eq = source:match("^%[(=*)%[", i)
            if eq then longEq = #eq; i = i + #eq + 2 else i = i + 1 end
        elseif c == "(" or c == "{" then depth = depth + 1; i = i + 1
        elseif c == ")" or c == "}" then
            depth = depth - 1
            if depth == 0 then return source:sub(openAt, i), i end
            i = i + 1
        else i = i + 1 end
    end
    return nil
end

local function extractName(block)
    if type(block) ~= "string" then return nil end
    return block:match("Name%s*=%s*\"([^\"]*)\"")
        or block:match("Name%s*=%s*'([^']*)'")
end

local SCAN_COMPONENTS = {
    CreateButton="Button", CreateToggle="Toggle", CreateSlider="Slider",
    CreateParagraph="Paragraph", CreateSection="Section", CreateInput="Input",
    CreateDropdown="Dropdown", CreateMultiDropdown="MultiDropdown", CreateKeybind="Keybind",
    CreateLabel="Label", CreateDivider="Divider", CreateColor="Color", CreateColorPicker="ColorPicker",
    CreateNotification="Notification"
}

local function showScanLoading()
    local parent = (gethui and gethui()) or (LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    if not parent then return nil end
    local gui = make("ScreenGui", {
        Name = "ZynzScanLoading",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 10000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, parent)
    local textLabel = make("TextLabel", {
        Name = "LoadingText",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 240, 0, 28),
        BackgroundTransparency = 1,
        Text = "Zynz Library",
        TextColor3 = Color3.fromRGB(145, 145, 145),
        TextTransparency = 0,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextScaled = true,
        TextWrapped = false,
        ZIndex = 10001,
    }, gui)
    addTextConstraint(textLabel, 12, 16)
    return gui, textLabel
end

local function hideScanLoading(gui, textLabel)
    if not gui or not gui.Parent then return end
    if textLabel and textLabel.Parent then
        local tween = TweenService:Create(textLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
        tween:Play()
        tween.Completed:Wait()
    end
    if gui.Parent then gui:Destroy() end
end

function Zynz:ScanScript(source, opts)
    opts = opts or {}
    local loadingGui, loadingText = showScanLoading()
    -- Give Roblox one frame to render the text before scanning begins.
    if loadingGui then
        local RunService = game:GetService("RunService")
        RunService.RenderStepped:Wait()
    end
    local report = {Tabs = {}, Findings = {}, Warnings = {}, SourceCount = 0}
    local seenSources, sequence = {}, 0
    local maxDepth = math.clamp(tonumber(opts.MaxLoadstringDepth) or 5, 0, 12)

    local function addWarning(message)
        table.insert(report.Warnings, message)
    end
    local function addFinding(kind, name, src, pos, extra)
        sequence += 1
        local item = {Kind=kind, Name=name or kind, Source=src, Position=pos, Order=sequence}
        if extra then for k,v in pairs(extra) do item[k]=v end end
        table.insert(report.Findings, item)
        return item
    end
    local function literalStringAt(src, pos)
        local i = pos
        while src:sub(i,i):match("%s") do i += 1 end
        local q = src:sub(i,i)
        if q == "'" or q == '"' then
            local j = i + 1
            while j <= #src do
                local c = src:sub(j,j)
                if c == "\\" then j += 2
                elseif c == q then
                    local raw = src:sub(i+1,j-1)
                    raw = raw:gsub("\\n", "\n"):gsub("\\r", "\r"):gsub("\\t", "\t"):gsub("\\\\", "\\")
                    return raw, j + 1
                else j += 1 end
            end
        end
        return nil
    end

    local scanSource
    scanSource = function(src, sourceLabel, depth)
        if type(src) ~= "string" then addWarning("Source tidak berupa teks: "..tostring(sourceLabel)); return end
        if depth > maxDepth then addWarning("Batas kedalaman loadstring tercapai di "..tostring(sourceLabel)); return end
        local fingerprint = tostring(#src)..":"..src:sub(1,180)..":"..src:sub(-180)
        if seenSources[fingerprint] then addWarning("Source berulang dilewati untuk mencegah loop: "..tostring(sourceLabel)); return end
        seenSources[fingerprint] = true
        report.SourceCount += 1

        local events, pos = {}, 1
        local activeTab = nil
        local pendingSources = {}
        while true do
            local a,b,method = src:find("[:%.]([%a_][%w_]*)%s*%(%s*{", pos)
            if not a then break end
            local open = src:find("{", b, true)
            local block, finish = scanBalanced(src, open)
            if block then
                if method == "CreateTab" then
                    table.insert(events, {pos=a, kind="Tab", block=block, finish=finish})
                elseif SCAN_COMPONENTS[method] then
                    table.insert(events, {pos=a, kind=SCAN_COMPONENTS[method], block=block, finish=finish})
                end
                pos = finish + 1
            else pos = b + 1 end
        end

        -- Find loadstring calls and inspect literal payloads / URL sources statically.
        pos = 1
        while true do
            local a,b = src:find("loadstring%s*%(", pos)
            if not a then break end
            local open = src:find("(", a, true)
            local args, finish = scanBalanced(src, open)
            if args then
                local payload = args:sub(2, -2)
                local literal = literalStringAt(payload, 1)
                local url = payload:match("HttpGet%s*%(%s*[\"']([^\"']+)[\"']")
                local ev = {pos=a, kind="Loadstring", block=payload, finish=finish, literal=literal, url=url}
                table.insert(events, ev)
                pos = finish + 1
            else pos = b + 1 end
        end
        table.sort(events, function(x,y) return x.pos < y.pos end)

        local previousTab = activeTab
        for _, ev in ipairs(events) do
            if ev.kind == "Tab" then
                local name = extractName(ev.block) or ("Tab "..tostring(#report.Tabs+1))
                local tab = {Name=name, Order=#report.Tabs+1, Components={}, Source=sourceLabel, Position=ev.pos}
                table.insert(report.Tabs, tab)
                activeTab = tab
                addFinding("Tab", name, sourceLabel, ev.pos, {Tab=tab})
            elseif ev.kind == "Loadstring" then
                addFinding("Loadstring", ev.url and ("External source: "..ev.url) or "Dynamic source", sourceLabel, ev.pos, {URL=ev.url, HasLiteral=ev.literal ~= nil})
                if ev.literal then
                    table.insert(pendingSources, {Source=ev.literal, Label=tostring(sourceLabel).." -> loadstring literal"})
                elseif ev.url and type(opts.ResolveSource) == "function" then
                    local ok, resolved = pcall(opts.ResolveSource, ev.url)
                    if ok and type(resolved) == "string" then table.insert(pendingSources, {Source=resolved, Label=ev.url})
                    else addWarning("Source URL belum bisa dibaca: "..ev.url) end
                elseif ev.url then
                    addWarning("Source eksternal belum dipindai (tidak ada ResolveSource): "..ev.url)
                else
                    addWarning("Isi loadstring dinamis tidak dapat dipastikan secara statis di "..tostring(sourceLabel))
                end
            else
                local name = extractName(ev.block) or ev.kind
                local finding = addFinding(ev.kind, name, sourceLabel, ev.pos, {Tab=activeTab})
                if activeTab then table.insert(activeTab.Components, finding)
                else addWarning(ev.kind.." ditemukan sebelum tab pertama: "..name) end
            end
        end
        -- Scan nested sources after this source so parent tabs retain source order.
        for _, pending in ipairs(pendingSources) do
            scanSource(pending.Source, pending.Label, depth+1)
        end
    end

    scanSource(source, opts.SourceName or "input", 0)
    table.sort(report.Tabs, function(a,b) return a.Order < b.Order end)
    report.Success = true
    hideScanLoading(loadingGui, loadingText)
    return report
end

return setmetatable({}, Zynz)
