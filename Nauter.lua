-- NAUTER LIBRARY | FULL COMPACT EDITION
-- Roblox LocalScript | Mobile / Tablet / PC

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Previous = PlayerGui:FindFirstChild("Nauter")
if Previous then Previous:Destroy() end

local C = {
    Background = Color3.fromRGB(12, 10, 18), Panel = Color3.fromRGB(25, 20, 36),
    Purple = Color3.fromRGB(145, 65, 255), Neon = Color3.fromRGB(190, 110, 255),
    White = Color3.fromRGB(245, 240, 255), Muted = Color3.fromRGB(165, 155, 185),
    Off = Color3.fromRGB(65, 58, 78), Red = Color3.fromRGB(135, 45, 75)
}

local function Make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function Round(obj, radius)
    Make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end
local function Outline(obj, color)
    Make("UIStroke", {Color = color or C.Purple, Thickness = 1, Transparency = 0.25}, obj)
end
local function Text(parent, text, size, color, font)
    return Make("TextLabel", {BackgroundTransparency = 1, Text = text or "", TextColor3 = color or C.White,
        Font = font or Enum.Font.Gotham, TextSize = size or 12, TextWrapped = true}, parent)
end

local Gui = Make("ScreenGui", {Name = "Nauter", ResetOnSpawn = false, DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PlayerGui)
local Main = Make("Frame", {Name = "Window", AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
    Size = UDim2.fromOffset(480,360), BackgroundColor3 = C.Background, BackgroundTransparency = .1,
    BorderSizePixel = 0, ClipsDescendants = true}, Gui)
Round(Main, 16); Outline(Main)
Make("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0,C.Background),
    ColorSequenceKeypoint.new(.55,Color3.fromRGB(27,15,43)), ColorSequenceKeypoint.new(1,Color3.fromRGB(53,23,83))}), Rotation = 35}, Main)

local Header = Make("Frame", {Name = "Header", Size = UDim2.new(1,0,0,44), BackgroundColor3 = C.Panel,
    BackgroundTransparency = .1, BorderSizePixel = 0}, Main)
Round(Header, 14)
local Logo = Make("TextLabel", {Position=UDim2.new(0,10,0,6),Size=UDim2.fromOffset(32,32),BackgroundColor3=C.Purple,
    Text="N",TextColor3=C.White,Font=Enum.Font.GothamBold,TextSize=20},Header); Round(Logo,10)
local Title = Make("TextLabel", {Position=UDim2.new(0,50,0,0),Size=UDim2.new(.55,0,1,0),BackgroundTransparency=1,
    Text="NAUTER",TextColor3=C.White,Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left},Header)
local Min = Make("TextButton", {Position=UDim2.new(1,-72,0,7),Size=UDim2.fromOffset(28,28),BackgroundColor3=C.Off,
    Text="−",TextColor3=C.White,Font=Enum.Font.GothamBold,TextSize=18},Header); Round(Min,9)
local Exit = Make("TextButton", {Position=UDim2.new(1,-37,0,7),Size=UDim2.fromOffset(28,28),BackgroundColor3=C.Red,
    Text="×",TextColor3=C.White,Font=Enum.Font.GothamBold,TextSize=19},Header); Round(Exit,9)

local Body = Make("Frame", {Position=UDim2.new(0,0,0,44),Size=UDim2.new(1,0,1,-44),BackgroundTransparency=1},Main)
local Sidebar = Make("ScrollingFrame", {Name="Tabs",Size=UDim2.new(0,100,1,0),BackgroundColor3=C.Panel,
    BackgroundTransparency=.1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=C.Purple,
    AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},Body); Round(Sidebar,8)
Make("UIPadding",{PaddingTop=UDim.new(0,9),PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,7),PaddingBottom=UDim.new(0,8)},Sidebar)
Make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},Sidebar)
local Content = Make("ScrollingFrame", {Name="Content",Position=UDim2.new(0,108,0,0),Size=UDim2.new(1,-116,1,0),
    BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.Purple,
    AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},Body)
Make("UIPadding",{PaddingTop=UDim.new(0,9),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,10)},Content)
local ContentLayout = Make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},Content)
local Show = Make("TextButton",{Name="FloatingButton",Size=UDim2.fromOffset(46,46),Position=UDim2.new(0,12,.5,-23),
    BackgroundColor3=C.Purple,Text="N",TextColor3=C.White,Font=Enum.Font.GothamBold,TextSize=21,Visible=false},Gui)
Round(Show,23); Outline(Show,C.Neon)

local function Resize()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local v = camera.ViewportSize
    Main.Size = UDim2.fromOffset(math.max(280,math.min(480,v.X*.92)), math.max(230,math.min(360,v.Y*.78)))
end
Resize()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Resize) end

-- Drag works with mouse and touch; controls on the right remain clickable.
local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos, dragInput = true, input.Position, Main.Position, input
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false; dragInput=nil end
end)
Min.Activated:Connect(function() Main.Visible=false; Show.Visible=true end)
Show.Activated:Connect(function() Main.Visible=true; Show.Visible=false end)
Exit.Activated:Connect(function() Gui:Destroy() end)

local Nauter = {}
local Tabs, SelectedTab = {}, nil
local function ClearContent()
    for _, child in ipairs(Content:GetChildren()) do
        if child ~= ContentLayout and not child:IsA("UIPadding") then child:Destroy() end
    end
end
local function SelectTab(tab)
    SelectedTab = tab
    ClearContent()
    for _, t in ipairs(Tabs) do t.Button.BackgroundColor3 = (t == tab) and C.Purple or C.Panel end
    tab.Render()
    Content.CanvasPosition = Vector2.zero
end
function Nauter:CreateWindow(options)
    options = options or {}
    if options.Name then Title.Text = tostring(options.Name) end
    return self
end
function Nauter:CreateTab(name)
    local tab = {Name=name, Items={}}
    tab.Button = Make("TextButton",{Name=tostring(name),Size=UDim2.new(1,0,0,34),BackgroundColor3=C.Panel,
        BackgroundTransparency=.05,Text=tostring(name),TextColor3=C.White,Font=Enum.Font.GothamBold,
        TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,AutoButtonColor=false},Sidebar)
    Round(tab.Button,9)
    function tab:Render() for _, draw in ipairs(self.Items) do draw() end end
    tab.Button.Activated:Connect(function() SelectTab(tab) end)
    table.insert(Tabs,tab)
    local function Add(draw)
        table.insert(tab.Items,draw)
        if SelectedTab == tab then ClearContent(); tab:Render() end
    end
    function tab:CreateSection(label)
        Add(function()
            local l=Text(Content,string.upper(tostring(label)),11,C.Neon,Enum.Font.GothamBold)
            l.Size=UDim2.new(1,-3,0,24); l.TextXAlignment=Enum.TextXAlignment.Left
        end)
    end
    function tab:CreateDivider()
        Add(function() local f=Make("Frame",{Size=UDim2.new(1,-3,0,1),BackgroundColor3=C.Purple,BackgroundTransparency=.35,BorderSizePixel=0},Content) end)
    end
    function tab:CreateLabel(label)
        local control={Text=tostring(label or "Label")}
        Add(function()
            local l=Text(Content,control.Text,12,C.White)
            l.Name="Label"; l.Size=UDim2.new(1,-3,0,28); l.TextXAlignment=Enum.TextXAlignment.Left
            control.Set=function(_,newText) control.Text=tostring(newText); if l.Parent then l.Text=control.Text end end
        end)
        return control
    end
    function tab:CreateParagraph(options)
        options=options or {}; local state={Title=options.Title or "Paragraph",Content=options.Content or ""}; local control={}
        Add(function()
            local box=Make("Frame",{Size=UDim2.new(1,-3,0,68),BackgroundColor3=C.Panel,BackgroundTransparency=.05,BorderSizePixel=0},Content); Round(box,10)
            local t=Text(box,state.Title,12,C.Neon,Enum.Font.GothamBold); t.Position=UDim2.new(0,10,0,6); t.Size=UDim2.new(1,-20,0,19); t.TextXAlignment=Enum.TextXAlignment.Left
            local d=Text(box,state.Content,11,C.Muted); d.Position=UDim2.new(0,10,0,27); d.Size=UDim2.new(1,-20,1,-32); d.TextXAlignment=Enum.TextXAlignment.Left; d.TextYAlignment=Enum.TextYAlignment.Top
            control.Set=function(_,newText) state.Content=tostring(newText); if d.Parent then d.Text=state.Content end end
        end)
        return control
    end
    function tab:CreateButton(options)
        options=options or {}
        Add(function()
            local b=Make("TextButton",{Size=UDim2.new(1,-3,0,38),BackgroundColor3=C.Panel,BackgroundTransparency=.05,
                Text=options.Name or "Button",TextColor3=C.White,Font=Enum.Font.GothamMedium,TextSize=12,AutoButtonColor=false},Content)
            Round(b,10); Outline(b)
            b.Activated:Connect(function()
                TweenService:Create(b,TweenInfo.new(.1),{BackgroundColor3=C.Purple}):Play()
                task.delay(.15,function() if b.Parent then b.BackgroundColor3=C.Panel end end)
                if options.Callback then options.Callback() end
            end)
        end)
    end
    function tab:CreateToggle(options)
        options=options or {}; local value=options.Default==true; local control={}
        function control:Get() return value end
        function control:Set(v, fire) value=(v==true); if control.Refresh then control.Refresh() end; if fire~=false and options.Callback then options.Callback(value) end end
        Add(function()
            local b=Make("TextButton",{Size=UDim2.new(1,-3,0,40),BackgroundColor3=C.Panel,BackgroundTransparency=.05,Text="",AutoButtonColor=false},Content); Round(b,10)
            local label=Text(b,options.Name or "Toggle",11,C.White,Enum.Font.GothamMedium); label.Position=UDim2.new(0,10,0,0); label.Size=UDim2.new(1,-65,1,0); label.TextXAlignment=Enum.TextXAlignment.Left
            local sw=Make("Frame",{Position=UDim2.new(1,-43,.5,-9),Size=UDim2.fromOffset(33,18),BackgroundColor3=value and C.Purple or C.Off},b); Round(sw,20)
            local dot=Make("Frame",{Position=value and UDim2.new(1,-16,0,2) or UDim2.new(0,2,0,2),Size=UDim2.fromOffset(14,14),BackgroundColor3=C.White},sw); Round(dot,20)
            function control.Refresh() if not b.Parent then return end; sw.BackgroundColor3=value and C.Purple or C.Off; dot.Position=value and UDim2.new(1,-16,0,2) or UDim2.new(0,2,0,2) end
            b.Activated:Connect(function() control:Set(not value) end)
        end)
        return control
    end
    function tab:CreateSlider(options)
        options=options or {}; local min,max=options.Min or 0,options.Max or 100; assert(max>min,"Slider Max must exceed Min")
        local value=math.clamp(options.Default or min,min,max); local control={}
        function control:Get() return value end
        function control:Set(v,fire) value=math.clamp(tonumber(v) or min,min,max); if options.Decimal~=true then value=math.floor(value+.5) end; if control.Refresh then control.Refresh() end; if fire~=false and options.Callback then options.Callback(value) end end
        Add(function()
            local box=Make("Frame",{Size=UDim2.new(1,-3,0,62),BackgroundColor3=C.Panel,BackgroundTransparency=.05},Content); Round(box,10)
            local label=Text(box,(options.Name or "Slider")..": "..tostring(value),11,C.White,Enum.Font.GothamMedium); label.Position=UDim2.new(0,10,0,5); label.Size=UDim2.new(1,-20,0,19); label.TextXAlignment=Enum.TextXAlignment.Left
            local bar=Make("Frame",{Position=UDim2.new(0,10,0,38),Size=UDim2.new(1,-20,0,6),BackgroundColor3=C.Off},box); Round(bar,5)
            local fill=Make("Frame",{Size=UDim2.new((value-min)/(max-min),0,1,0),BackgroundColor3=C.Purple},bar); Round(fill,5)
            local hit=Make("TextButton",{Position=UDim2.new(0,0,0,26),Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text=""},box)
            local function fromX(x) local w=bar.AbsoluteSize.X; if w>0 then control:Set(min+math.clamp((x-bar.AbsolutePosition.X)/w,0,1)*(max-min)) end end
            local active=false
            hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then active=true; fromX(i.Position.X) end end)
            local moveConn=UIS.InputChanged:Connect(function(i) if active and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then fromX(i.Position.X) end end)
            local endConn=UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then active=false end end)
            box.Destroying:Connect(function() moveConn:Disconnect(); endConn:Disconnect() end)
            function control.Refresh() if not box.Parent then return end; fill.Size=UDim2.new((value-min)/(max-min),0,1,0); label.Text=(options.Name or "Slider")..": "..tostring(value) end
        end)
        return control
    end
    function tab:CreateInput(options)
        options=options or {}; local value=tostring(options.Default or ""); local control={}
        function control:Get() return value end
        function control:Set(v,fire) value=tostring(v or ""); if control.Box and control.Box.Parent then control.Box.Text=value end; if fire~=false and options.Callback then options.Callback(value) end end
        Add(function()
            local box=Make("Frame",{Size=UDim2.new(1,-3,0,62),BackgroundColor3=C.Panel,BackgroundTransparency=.05},Content); Round(box,10)
            local label=Text(box,options.Name or "Input",11,C.White,Enum.Font.GothamMedium); label.Position=UDim2.new(0,10,0,4); label.Size=UDim2.new(1,-20,0,18); label.TextXAlignment=Enum.TextXAlignment.Left
            local input=Make("TextBox",{Position=UDim2.new(0,8,0,26),Size=UDim2.new(1,-16,0,28),BackgroundColor3=C.Background,Text=value,PlaceholderText=options.Placeholder or "Type here...",PlaceholderColor3=C.Muted,
                TextColor3=C.White,Font=Enum.Font.Gotham,TextSize=11,ClearTextOnFocus=options.ClearTextOnFocus==true},box); Round(input,7); control.Box=input
            input.FocusLost:Connect(function(enter) value=input.Text; if options.Callback then options.Callback(value,enter) end end)
        end)
        return control
    end
    function tab:CreateDropdown(options)
        options=options or {}; local choices=options.Options or {}; local index=1; local value=options.CurrentOption or options.Default
        for i,v in ipairs(choices) do if v==value then index=i; break end end
        value=choices[index] or value or "Select..."; local control={}
        function control:Get() return value end
        function control:Set(v,fire) for i,x in ipairs(choices) do if x==v then index=i; value=x; break end end; if control.Refresh then control.Refresh() end; if fire~=false and options.Callback then options.Callback(value) end end
        Add(function()
            local b=Make("TextButton",{Size=UDim2.new(1,-3,0,40),BackgroundColor3=C.Panel,BackgroundTransparency=.05,Text="",AutoButtonColor=false},Content); Round(b,10); Outline(b,C.Off)
            local label=Text(b,(options.Name or "Dropdown")..": "..tostring(value),11,C.White,Enum.Font.GothamMedium); label.Position=UDim2.new(0,10,0,0); label.Size=UDim2.new(1,-30,1,0); label.TextXAlignment=Enum.TextXAlignment.Left
            local arrow=Text(b,"▾",15,C.Neon,Enum.Font.GothamBold); arrow.Position=UDim2.new(1,-26,0,0); arrow.Size=UDim2.new(0,20,1,0)
            function control.Refresh() if label.Parent then label.Text=(options.Name or "Dropdown")..": "..tostring(value) end end
            b.Activated:Connect(function() if #choices==0 then return end; index=index%#choices+1; value=choices[index]; control.Refresh(); if options.Callback then options.Callback(value) end end)
        end)
        return control
    end
    function tab:CreateKeybind(options)
        options=options or {}; local key=options.Default or Enum.KeyCode.RightControl; local listening=false; local control={}
        function control:Get() return key end
        function control:Set(v) if typeof(v)=="EnumItem" and v.EnumType==Enum.KeyCode then key=v; if control.Refresh then control.Refresh() end end end
        Add(function()
            local b=Make("TextButton",{Size=UDim2.new(1,-3,0,40),BackgroundColor3=C.Panel,Text="",AutoButtonColor=false},Content); Round(b,10)
            local label=Text(b,options.Name or "Keybind",11,C.White); label.Position=UDim2.new(0,10,0,0); label.Size=UDim2.new(1,-90,1,0); label.TextXAlignment=Enum.TextXAlignment.Left
            local keyText=Text(b,key.Name,10,C.Neon,Enum.Font.GothamBold); keyText.Position=UDim2.new(1,-78,0,0); keyText.Size=UDim2.new(0,68,1,0)
            function control.Refresh() if keyText.Parent then keyText.Text=listening and "Press key..." or key.Name end end
            b.Activated:Connect(function() listening=true; control.Refresh() end)
            local conn=UIS.InputBegan:Connect(function(input,processed)
                if listening and input.UserInputType==Enum.UserInputType.Keyboard then key=input.KeyCode; listening=false; control.Refresh()
                elseif not listening and not processed and input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==key then
                    if options.Callback then options.Callback(key) end
                end
            end)
            b.Destroying:Connect(function() conn:Disconnect() end)
        end)
        return control
    end
    function tab:CreateColorPicker(options)
        options=options or {}; local colors=options.Colors or {C.Purple,Color3.fromRGB(255,70,150),Color3.fromRGB(60,170,255),Color3.fromRGB(70,220,150),Color3.fromRGB(255,190,60),C.White}
        local index=1; local value=options.Default or colors[1]; for i,c in ipairs(colors) do if c==value then index=i end end; local control={}
        function control:Get() return value end
        function control:Set(v,fire) if typeof(v)=="Color3" then value=v; if control.Refresh then control.Refresh() end; if fire~=false and options.Callback then options.Callback(value) end end end
        Add(function()
            local b=Make("TextButton",{Size=UDim2.new(1,-3,0,40),BackgroundColor3=C.Panel,Text="",AutoButtonColor=false},Content); Round(b,10)
            local label=Text(b,options.Name or "Color Picker",11,C.White,Enum.Font.GothamMedium); label.Position=UDim2.new(0,10,0,0); label.Size=UDim2.new(1,-55,1,0); label.TextXAlignment=Enum.TextXAlignment.Left
            local swatch=Make("Frame",{Position=UDim2.new(1,-35,.5,-10),Size=UDim2.fromOffset(24,20),BackgroundColor3=value},b); Round(swatch,6); Outline(swatch,C.White)
            function control.Refresh() if swatch.Parent then swatch.BackgroundColor3=value end end
            b.Activated:Connect(function() index=index%#colors+1; value=colors[index]; control.Refresh(); if options.Callback then options.Callback(value) end end)
        end)
        return control
    end
    if not SelectedTab then SelectTab(tab) end
    return tab
end
function Nauter:Destroy() if Gui then Gui:Destroy() end end
function Nauter:SetVisible(state) if not Gui.Parent then return end; Main.Visible=state==true; Show.Visible=not Main.Visible end
function Nauter:GetGui() return Gui end
function Nauter:Notify(options)
    options=options or {}; local toast=Make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),Size=UDim2.fromOffset(220,72),BackgroundColor3=C.Panel,BackgroundTransparency=.05},Gui); Round(toast,12); Outline(toast)
    local title=Text(toast,options.Title or "Nauter",12,C.Neon,Enum.Font.GothamBold); title.Position=UDim2.new(0,10,0,7); title.Size=UDim2.new(1,-20,0,18); title.TextXAlignment=Enum.TextXAlignment.Left
    local msg=Text(toast,options.Content or "",11,C.White); msg.Position=UDim2.new(0,10,0,27); msg.Size=UDim2.new(1,-20,1,-32); msg.TextXAlignment=Enum.TextXAlignment.Left; msg.TextYAlignment=Enum.TextYAlignment.Top
    task.delay(tonumber(options.Duration) or 3,function() if toast.Parent then toast:Destroy() end end)
end

print("Nauter Library loaded. Create tabs with Nauter:CreateTab(name).")

-- BUILT-IN DEMO: remove this section if you want a blank library window.
local Demo = Nauter:CreateTab("Test")
Demo:CreateSection("Basic Components")
Demo:CreateButton({Name="Test Button", Callback=function() print("Nauter button clicked") end})
Demo:CreateToggle({Name="Test Toggle", Default=false, Callback=function(v) print("Toggle:",v) end})
Demo:CreateSlider({Name="Test Slider", Min=1, Max=100, Default=16, Callback=function(v) print("Slider:",v) end})
Demo:CreateInput({Name="Text Input", Placeholder="Type something...", Callback=function(v) print("Input:",v) end})
Demo:CreateDropdown({Name="Difficulty", Options={"Easy","Normal","Hard"}, Callback=function(v) print("Selected:",v) end})
Demo:CreateKeybind({Name="Example Keybind", Default=Enum.KeyCode.RightControl, Callback=function(k) print("Pressed:",k.Name) end})
Demo:CreateColorPicker({Name="Accent Color", Callback=function(color) print("Color:",color) end})
Demo:CreateDivider()
Demo:CreateLabel("Nauter Library is ready")
Demo:CreateParagraph({Title="About", Content="Compact UI library demo. Add your own tabs and callbacks to build your interface."})

return Nauter
