-- Zynz Enhanced v9 - Bloody X-chain + tab alignment/startup fix (library only)
-- Zynz.lua - advanced responsive Roblox UI library
-- Features: window controls, tabs, keybinds, multi-select dropdowns, notifications, color tools, and static source scanning
-- Client-side use: local Zynz = loadstring(...)() or require(ModuleScript)
-- API: local Window = Zynz:CreateWindow({Name="Zynz"}); local MainTab = Window:CreateTab({Name="Main"})

local Zynz = {}
Zynz.__index = Zynz

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- MainTabTheme presets:
--   "Modern"   = icy cyan/white accent with a resize-aware soft outer aura
--   "Classic"  = old Windows/Roblox-era squared, beveled controls
--   "Normal"   = dark purple style
--   "Halloween"= midnight purple, pumpkin orange, and ghostly violet
--   "Christmas"= evergreen, festive red, snow white, and warm gold
--   "Bloody"   = dark crimson horror styling with chains and randomized blood marks
local PALETTES = {
    Normal = {
        Window = Color3.fromRGB(13, 11, 20), Tab = Color3.fromRGB(25, 22, 36),
        TabSelected = Color3.fromRGB(91, 51, 157), Component = Color3.fromRGB(42, 38, 56),
        ComponentHover = Color3.fromRGB(57, 49, 75), Control = Color3.fromRGB(48, 44, 63), Popup = Color3.fromRGB(28, 25, 40), Line = Color3.fromRGB(91, 82, 110),
        Text = Color3.fromRGB(248, 246, 255), Muted = Color3.fromRGB(177, 168, 198),
        Accent = Color3.fromRGB(169, 102, 255), Aura = Color3.fromRGB(169, 102, 255),
    },
    Modern = {
        Window = Color3.fromRGB(13, 20, 29), Tab = Color3.fromRGB(19, 32, 44),
        TabSelected = Color3.fromRGB(44, 103, 129), Component = Color3.fromRGB(32, 49, 62),
        ComponentHover = Color3.fromRGB(45, 66, 81), Control = Color3.fromRGB(24, 42, 55), Popup = Color3.fromRGB(17, 30, 41), Line = Color3.fromRGB(117, 211, 239),
        Text = Color3.fromRGB(242, 251, 255), Muted = Color3.fromRGB(177, 211, 224),
        Accent = Color3.fromRGB(177, 235, 255), Aura = Color3.fromRGB(145, 225, 255),
    },
    Classic = {
        Window = Color3.fromRGB(192, 192, 192), Tab = Color3.fromRGB(212, 208, 200),
        TabSelected = Color3.fromRGB(0, 0, 128), Component = Color3.fromRGB(211, 211, 211),
        ComponentHover = Color3.fromRGB(232, 232, 232), Control = Color3.fromRGB(235, 235, 235), Popup = Color3.fromRGB(212, 208, 200), Line = Color3.fromRGB(64, 64, 64),
        Text = Color3.fromRGB(0, 0, 0), Muted = Color3.fromRGB(55, 55, 55),
        Accent = Color3.fromRGB(0, 0, 128), Aura = Color3.fromRGB(0, 0, 128),
    },
    Halloween = {
        Window = Color3.fromRGB(18, 12, 28), Tab = Color3.fromRGB(35, 22, 48),
        TabSelected = Color3.fromRGB(104, 47, 142), Component = Color3.fromRGB(48, 31, 60),
        ComponentHover = Color3.fromRGB(66, 39, 76), Control = Color3.fromRGB(31, 20, 42),
        Popup = Color3.fromRGB(26, 16, 37), Line = Color3.fromRGB(255, 126, 36),
        Text = Color3.fromRGB(255, 245, 232), Muted = Color3.fromRGB(199, 169, 207),
        Accent = Color3.fromRGB(255, 137, 43), Aura = Color3.fromRGB(159, 67, 220),
    },
    Christmas = {
        Window = Color3.fromRGB(12, 28, 24), Tab = Color3.fromRGB(20, 47, 38),
        TabSelected = Color3.fromRGB(157, 39, 49), Component = Color3.fromRGB(30, 57, 47),
        ComponentHover = Color3.fromRGB(42, 76, 61), Control = Color3.fromRGB(20, 43, 35),
        Popup = Color3.fromRGB(17, 38, 31), Line = Color3.fromRGB(224, 63, 72),
        Text = Color3.fromRGB(246, 250, 245), Muted = Color3.fromRGB(190, 216, 202),
        Accent = Color3.fromRGB(240, 198, 92), Aura = Color3.fromRGB(53, 166, 112),
    },
    Bloody = {
        Window = Color3.fromRGB(17, 7, 10), Tab = Color3.fromRGB(30, 10, 15),
        TabSelected = Color3.fromRGB(116, 14, 30), Component = Color3.fromRGB(38, 13, 19),
        ComponentHover = Color3.fromRGB(57, 16, 25), Control = Color3.fromRGB(24, 8, 13),
        Popup = Color3.fromRGB(21, 7, 12), Line = Color3.fromRGB(112, 27, 42),
        Text = Color3.fromRGB(250, 235, 238), Muted = Color3.fromRGB(188, 139, 148),
        Accent = Color3.fromRGB(210, 25, 49), Aura = Color3.fromRGB(124, 7, 25),
    },
}
local COLORS = table.clone(PALETTES.Normal)
local ACTIVE_THEME = "Normal"
local function applyTheme(themeName)
    local name = string.lower(tostring(themeName or "Normal"))
    if name == "classic" then ACTIVE_THEME = "Classic"
    elseif name == "modern" then ACTIVE_THEME = "Modern"
    elseif name == "halloween" then ACTIVE_THEME = "Halloween"
    elseif name == "christmas" then ACTIVE_THEME = "Christmas"
    elseif name == "bloody" then ACTIVE_THEME = "Bloody"
    else ACTIVE_THEME = "Normal" end
    for key, value in pairs(PALETTES[ACTIVE_THEME]) do COLORS[key] = value end
end
local function controlColor() return COLORS.Control or COLORS.Component end
local function popupColor() return COLORS.Popup or COLORS.Component end
local function classicFont() return ACTIVE_THEME == "Classic" and Enum.Font.Arial or Enum.Font.Gotham end
local function cornerRadius(modern, classic)
    if ACTIVE_THEME == "Classic" then return 0 end
    if ACTIVE_THEME == "Normal" then return 7 end
    if ACTIVE_THEME == "Halloween" or ACTIVE_THEME == "Christmas" or ACTIVE_THEME == "Bloody" then return modern or 9 end
    return modern or 10
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    -- Remember which palette role each color property represents so SetTheme()
    -- can recolor existing UI objects, not only newly-created controls.
    local roleOrder = {
        BackgroundColor3 = {"Window", "Tab", "TabSelected", "Component", "ComponentHover", "Control", "Popup"},
        TextColor3 = {"Text", "Muted", "Accent"},
        PlaceholderColor3 = {"Muted", "Text"},
        Color = {"Line", "Accent", "Aura"},
    }
    for property, roles in pairs(roleOrder) do
        local value = props and props[property]
        if value ~= nil then
            for _, role in ipairs(roles) do
                if COLORS[role] ~= nil and value == COLORS[role] then
                    obj:SetAttribute("ZynzThemeRole_" .. property, role)
                    break
                end
            end
        end
    end
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
    -- Dragging starts ONLY when the input begins on this explicit handle.
    -- Track the initiating input so unrelated touches/controls cannot move the window.
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if dragging then return end

        dragging = true
        dragInput = input
        dragStart = input.Position
        startPos = frame.Position

        local endedConnection
        endedConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragInput = nil
                dragStart = nil
                startPos = nil
                if endedConnection then endedConnection:Disconnect() end
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragInput then return end

        local isMouseDrag = dragInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouchDrag = dragInput.UserInputType == Enum.UserInputType.Touch
            and input == dragInput
        if not isMouseDrag and not isTouchDrag then return end

        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)
end

local function connectHover(button)
    button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.ComponentHover}):Play() end)
    button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.Component}):Play() end)
end

-- Procedural blood flecks used only by the Bloody theme. They are decorative UI shapes,
-- randomized per parent, and never recolor or cover the actual ColorPicker widget.
local bloodRandom = Random.new()
local BLOOD_DARK = Color3.fromRGB(82, 3, 17)
local BLOOD_MID = Color3.fromRGB(145, 8, 29)
local BLOOD_BRIGHT = Color3.fromRGB(202, 18, 42)
local function addBloodSplatter(parent, prefix, count, zIndex)
    if ACTIVE_THEME ~= "Bloody" or not parent or not parent.Parent then return end
    count = count or 5
    zIndex = zIndex or 3
    for i = 1, count do
        local x = bloodRandom:NextNumber(0.06, 0.94)
        local y = bloodRandom:NextNumber(0.08, 0.92)
        local size = bloodRandom:NextInteger(2, 7)
        local colorPick = bloodRandom:NextInteger(1, 3)
        local color = colorPick == 1 and BLOOD_DARK or (colorPick == 2 and BLOOD_MID or BLOOD_BRIGHT)
        local dot = make("Frame", {
            Name = prefix .. "BloodDot" .. i, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(x, y), Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = color, BackgroundTransparency = bloodRandom:NextNumber(0.04, 0.22),
            BorderSizePixel = 0, ZIndex = zIndex,
        }, parent)
        round(dot, 1)
        if i % 2 == 0 then
            local drip = make("Frame", {
                Name = prefix .. "BloodDrip" .. i, AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(x, y), Size = UDim2.fromOffset(math.max(2, math.floor(size * 0.45)), bloodRandom:NextInteger(4, 10)),
                BackgroundColor3 = color, BackgroundTransparency = bloodRandom:NextNumber(0.08, 0.24),
                BorderSizePixel = 0, Rotation = bloodRandom:NextInteger(-10, 10), ZIndex = zIndex,
            }, parent)
            round(drip, 2)
        end
    end
end

-- Top-right notification manager. Each toast has an independent duration timer and exit tween.
local notificationManagers = setmetatable({}, {__mode = "k"})
local function getNotificationManager(gui)
    if not gui then return nil end
    if notificationManagers[gui] then return notificationManagers[gui] end
    local host = gui
    if not host:IsA("ScreenGui") then
        local parent = host
        local existing = parent:FindFirstChild("ZynzNotifications")
        if existing and existing:IsA("ScreenGui") then
            host = existing
        else
            host = make("ScreenGui", {
                Name = "ZynzNotifications",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                DisplayOrder = 1001,
                ZIndexBehavior = Enum.ZIndexBehavior.Global,
            }, parent)
        end
    end
    local manager = {Items = {}, Gui = host}
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
        local frame = make("Frame", {Name="ZynzNotification", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1, width + 24, 0, 12), Size=UDim2.new(0,width,0,height), BackgroundColor3=COLORS.Component, BorderSizePixel=0, ClipsDescendants=true, ZIndex=250}, host)
        round(frame, ACTIVE_THEME == "Bloody" and 5 or 9)
        make("UIStroke", {Color=ACTIVE_THEME == "Bloody" and BLOOD_BRIGHT or Color3.fromRGB(58,58,58), Thickness=ACTIVE_THEME == "Bloody" and 1.5 or 1, Transparency=0.15}, frame)
        if ACTIVE_THEME == "Bloody" then
            make("Frame", {Name="BloodTopBar", Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,0,0,3), BackgroundColor3=BLOOD_BRIGHT, BorderSizePixel=0, ZIndex=254}, frame)
            addBloodSplatter(frame, "Toast", 7, 254)
        end
        local titleLabel=label(frame, opts.Name or "Notification", {Position=UDim2.new(0,10,0,6), Size=UDim2.new(1,-20,0,20), MaxTextSize=math.max(7,getScale()+1), MinTextSize=4}); titleLabel.ZIndex=251
        local bodyLabel=label(frame, opts.Paragraph or opts.Content or opts.Text or "", {Position=UDim2.new(0,10,0,27), Size=UDim2.new(1,-20,0,25), TextColor3=COLORS.Muted, MaxTextSize=getScale(), MinTextSize=4, TextYAlignment=Enum.TextYAlignment.Top}); bodyLabel.ZIndex=251
        local track = make("Frame", {Name="TimerLine", Position=UDim2.new(0,0,1,-3), Size=UDim2.new(1,0,0,3), BackgroundColor3=ACTIVE_THEME == "Bloody" and BLOOD_DARK or Color3.fromRGB(65,65,65), BorderSizePixel=0, ZIndex=252}, frame)
        local fill = make("Frame", {Name="TimerFill", Size=UDim2.fromScale(1,1), BackgroundColor3=COLORS.Accent, BorderSizePixel=0, ZIndex=253}, track)
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
    applyTheme(options.MainTabTheme or options.Theme or "Normal")
    local gui = make("ScreenGui", {
        Name = "ZynzUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 999,
    }, (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
    local old = gui.Parent:FindFirstChild("ZynzUI")
    if old and old ~= gui then old:Destroy() end

    -- Modern aura is attached directly to the window below. This keeps it aligned
    -- through dragging/resizing and guarantees it is destroyed with the window.
    local auraOuter, auraInner
    local modernDecorationConnection

    local root = make("Frame", {
        Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.88, 0, 0.72, 0), BackgroundColor3 = COLORS.Window, BorderSizePixel = ACTIVE_THEME == "Classic" and 1 or 0,
        ZIndex = 1,
    }, gui)
    applyWindowSize(root)
    make("UISizeConstraint", {MinSize = Vector2.new(260, 300), MaxSize = Vector2.new(920, 780)}, root)
    round(root, cornerRadius(15, 4))
    make("UIStroke", {Color = COLORS.Line, Thickness = ACTIVE_THEME == "Classic" and 1 or (ACTIVE_THEME == "Modern" and 1.5 or 1.1), Transparency = ACTIVE_THEME == "Classic" and 0 or (ACTIVE_THEME == "Modern" and 0.12 or 0.25)}, root)
    if ACTIVE_THEME == "Modern" then
        auraOuter = make("UIStroke", {Name="ZynzModernAuraOuter", Color=COLORS.Aura, Thickness=8, Transparency=0.84, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, root)
        auraInner = make("UIStroke", {Name="ZynzModernAuraInner", Color=Color3.fromRGB(218,247,255), Thickness=2, Transparency=0.68, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, root)
    end
    -- Modern theme: a small animated car follows the outside perimeter of the window.
    -- No chain decoration is drawn. Position is derived from AbsolutePosition/AbsoluteSize
    -- every frame, so the car remains aligned while the user drags or resizes the UI.
    if ACTIVE_THEME == "Modern" then
        local carRng = Random.new()
        local rainbowCar = carRng:NextNumber() < 0.08 -- 8% rainbow, otherwise a random solid color
        local solidCarColor = Color3.fromHSV(carRng:NextNumber(), carRng:NextNumber(0.72, 1), carRng:NextNumber(0.78, 1))
        local flyingCar = make("Frame", {
            Name = "ZynzModernFlyingCar", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(-100, -100), Size = UDim2.fromOffset(34, 20),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100,
        }, gui)
        local chassis = make("Frame", {
            Name = "CarBody", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.62, 0), Size = UDim2.new(1, -2, 0, 8),
            BackgroundColor3 = solidCarColor, BorderSizePixel = 0, ZIndex = 101,
        }, flyingCar)
        round(chassis, 4)
        local cabin = make("Frame", {
            Name = "CarCabin", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.28, 0), Size = UDim2.new(0, 13, 0, 7),
            BackgroundColor3 = Color3.fromHSV((select(1, solidCarColor:ToHSV()) + 0.08) % 1, 0.45, 1),
            BorderSizePixel = 0, ZIndex = 102,
        }, flyingCar)
        round(cabin, 3)
        for _, wheelX in ipairs({7, 25}) do
            local wheel = make("Frame", {
                Name = "CarWheel", AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, wheelX, 0, 15), Size = UDim2.fromOffset(6, 6),
                BackgroundColor3 = Color3.fromRGB(225, 244, 255), BorderSizePixel = 0, ZIndex = 103,
            }, flyingCar)
            round(wheel, 3)
        end
        local elapsed = 0
        local rainbowHue = carRng:NextNumber()
        local function updateCarColor()
            if rainbowCar and chassis.Parent and cabin.Parent then
                chassis.BackgroundColor3 = Color3.fromHSV(rainbowHue % 1, 0.92, 1)
                cabin.BackgroundColor3 = Color3.fromHSV((rainbowHue + 0.08) % 1, 0.45, 1)
            end
        end
        modernDecorationConnection = RunService.RenderStepped:Connect(function(dt)
            if not gui.Parent or not root.Parent or not flyingCar.Parent then
                if modernDecorationConnection then modernDecorationConnection:Disconnect(); modernDecorationConnection = nil end
                return
            end
            elapsed += dt
            if rainbowCar then
                rainbowHue = (rainbowHue + dt / 4.5) % 1
                updateCarColor()
            end
            local p, s = root.AbsolutePosition, root.AbsoluteSize
            local margin, carW, carH = 8, 34, 20
            local left, top = p.X + margin, p.Y + margin
            local right, bottom = p.X + s.X - margin, p.Y + s.Y - margin
            local w, h = math.max(1, right-left), math.max(1, bottom-top)
            local perimeter = 2 * (w + h)
            local distance = (elapsed * 72) % perimeter
            local x, y
            if distance < w then
                x, y = left + distance, top
            elseif distance < w + h then
                x, y = right, top + (distance-w)
            elseif distance < 2*w + h then
                x, y = right - (distance-w-h), bottom
            else
                x, y = left, bottom - (distance-2*w-h)
            end
            flyingCar.Position = UDim2.fromOffset(x, y)
            -- Keep the car upright at every corner. Rotating through 180/270 degrees
            -- made the cabin and wheels appear upside-down while it returned left.
            flyingCar.Rotation = 0
            flyingCar.Visible = root.Visible
        end)
    end

    -- Script-built Halloween scene: pumpkin, ghost, bats, cobwebs and moon (no lantern).
    -- All decorations are assembled from native Roblox UI objects; no image assets are required.
    if ACTIVE_THEME == "Halloween" then
        local scene = make("Frame", {
            Name = "HalloweenSceneBackground", BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0.025, 0, 0.19, 0), Size = UDim2.new(0.36, 0, 0.73, 0),
            ZIndex = 1, ClipsDescendants = false,
        }, root)

        local function sceneLine(parent, name, x1, y1, x2, y2, color, thickness, transparency)
            local dx, dy = x2-x1, y2-y1
            local length = math.sqrt(dx*dx + dy*dy)
            local line = make("Frame", {Name=name, AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.fromScale((x1+x2)/2,(y1+y2)/2), Size=UDim2.new(length,0,0,thickness),
                Rotation=math.deg(math.atan2(dy,dx)), BackgroundColor3=color,
                BackgroundTransparency=transparency or 0, BorderSizePixel=0, ZIndex=1}, parent)
            round(line, thickness)
            return line
        end

        local function sceneBall(parent, name, x, y, size, color, transparency)
            local ball = make("Frame", {Name=name, AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.fromScale(x,y), Size=UDim2.new(0,size,0,size), BackgroundColor3=color,
                BackgroundTransparency=transparency or 0, BorderSizePixel=0, ZIndex=1}, parent)
            round(ball, 1)
            return ball
        end

        local orange = Color3.fromRGB(245, 112, 31)
        local orangeLight = Color3.fromRGB(255, 155, 54)
        local purple = Color3.fromRGB(125, 70, 170)
        local dark = Color3.fromRGB(42, 25, 53)
        local gold = Color3.fromRGB(255, 197, 76)
        local leaf = Color3.fromRGB(76, 133, 58)

        -- Crescent moon and distant stars.
        sceneBall(scene, "MoonBase", 0.78, 0.12, 36, gold, 0.08)
        sceneBall(scene, "MoonCutout", 0.82, 0.095, 31, COLORS.Window, 0)
        for i, star in ipairs({{0.15,0.10},{0.40,0.17},{0.60,0.06},{0.91,0.28},{0.14,0.35}}) do
            sceneLine(scene, "StarH"..i, star[1]-0.025,star[2],star[1]+0.025,star[2],gold,2,0.12)
            sceneLine(scene, "StarV"..i, star[1],star[2]-0.025,star[1],star[2]+0.025,gold,2,0.12)
        end

        -- Friendly ghost built from a rounded head, body and eyes.
        local ghost = make("Frame", {Name="GhostBody", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.23,0.30),
            Size=UDim2.new(0,37,0,42), BackgroundColor3=Color3.fromRGB(245,239,255), BackgroundTransparency=0.04,
            BorderSizePixel=0, ZIndex=1}, scene)
        round(ghost, 18)
        make("UIStroke", {Color=Color3.fromRGB(190,170,220), Thickness=1, Transparency=0.25}, ghost)
        -- Small scallops suggest the ghost's floating sheet.
        for i=1,3 do sceneBall(scene,"GhostHem"..i,0.23+(i-2)*0.095,0.365,12,Color3.fromRGB(245,239,255),0.04) end
        sceneBall(scene,"GhostEyeL",0.218,0.29,4,dark,0)
        sceneBall(scene,"GhostEyeR",0.252,0.29,4,dark,0)
        sceneBall(scene,"GhostMouth",0.235,0.32,4,dark,0)

        -- Pumpkin body: overlapping orange lobes, green stem, triangular eyes and grin.
        local pumpkin = make("Frame", {Name="PumpkinBody", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.49,0.69),
            Size=UDim2.new(0,100,0,76), BackgroundColor3=orange, BorderSizePixel=0, ZIndex=1}, scene)
        round(pumpkin, 28)
        make("UIStroke", {Color=Color3.fromRGB(255,180,82), Thickness=2, Transparency=0.12}, pumpkin)
        for i, x in ipairs({0.18,0.34,0.50,0.66,0.82}) do
            local rib = make("Frame", {Name="PumpkinRib"..i, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(x,0,0.52,0),
                Size=UDim2.new(0, i==3 and 22 or 16, 0, 66), BackgroundColor3=i%2==0 and orangeLight or Color3.fromRGB(218,83,25),
                BackgroundTransparency=0.30, BorderSizePixel=0, ZIndex=1}, pumpkin)
            round(rib, 12)
        end
        local stem = make("Frame", {Name="PumpkinStem", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.53,0,0,2),
            Size=UDim2.new(0,14,0,18), Rotation=12, BackgroundColor3=leaf, BorderSizePixel=0, ZIndex=1}, pumpkin)
        round(stem, 4)
        -- Face pieces sit above the pumpkin lobes.
        sceneLine(pumpkin,"JackEyeLeftA",0.22,0.35,0.34,0.53,Color3.fromRGB(58,29,54),4,0)
        sceneLine(pumpkin,"JackEyeLeftB",0.22,0.53,0.34,0.35,Color3.fromRGB(58,29,54),4,0)
        sceneLine(pumpkin,"JackEyeRightA",0.66,0.35,0.78,0.53,Color3.fromRGB(58,29,54),4,0)
        sceneLine(pumpkin,"JackEyeRightB",0.66,0.53,0.78,0.35,Color3.fromRGB(58,29,54),4,0)
        sceneLine(pumpkin,"JackGrinTop",0.29,0.68,0.70,0.68,Color3.fromRGB(58,29,54),4,0)
        sceneLine(pumpkin,"JackGrinLeft",0.29,0.68,0.37,0.79,Color3.fromRGB(58,29,54),3,0)
        sceneLine(pumpkin,"JackGrinRight",0.70,0.68,0.62,0.79,Color3.fromRGB(58,29,54),3,0)

        -- Tiny bat silhouettes, assembled from triangles-like angled wings and a body.
        for i, bat in ipairs({{0.45,0.27,0.65},{0.87,0.61,0.48}}) do
            local x,y,scale=bat[1],bat[2],bat[3]
            sceneLine(scene,"BatWingL"..i,x,y,x-0.045*scale,y-0.025*scale,dark,3,0.02)
            sceneLine(scene,"BatWingL2_"..i,x-0.045*scale,y-0.025*scale,x-0.07*scale,y+0.015*scale,dark,3,0.02)
            sceneLine(scene,"BatWingR"..i,x,y,x+0.045*scale,y-0.025*scale,dark,3,0.02)
            sceneLine(scene,"BatWingR2_"..i,x+0.045*scale,y-0.025*scale,x+0.07*scale,y+0.015*scale,dark,3,0.02)
            sceneLine(scene,"BatBody"..i,x,y-0.012*scale,x,y+0.022*scale,dark,4,0.02)
        end

        -- Ground mist and small decorative stones.
        sceneLine(scene,"MistLine1",0.08,0.88,0.45,0.88,purple,3,0.28)
        sceneLine(scene,"MistLine2",0.53,0.91,0.91,0.91,purple,3,0.28)
        sceneBall(scene,"GroundDot1",0.12,0.82,5,gold,0.12)
        sceneBall(scene,"GroundDot2",0.87,0.84,6,orangeLight,0.12)
    end

    -- Script-built Christmas tree background: no external image or asset ID required.
    -- Made from UI Frames, rotated line segments, and small ornament circles.
    if ACTIVE_THEME == "Christmas" then
        local tree = make("Frame", {
            Name = "ChristmasTreeBackground",
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0.035, 0, 0.205, 0),
            Size = UDim2.new(0.34, 0, 0.69, 0),
            ZIndex = 1,
        }, root)

        local function treeLine(name, x1, y1, x2, y2, color, thickness, transparency)
            local dx, dy = x2 - x1, y2 - y1
            local length = math.sqrt(dx * dx + dy * dy)
            local line = make("Frame", {
                Name = name, AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale((x1 + x2) / 2, (y1 + y2) / 2),
                Size = UDim2.new(length, 0, 0, thickness),
                Rotation = math.deg(math.atan2(dy, dx)),
                BackgroundColor3 = color, BackgroundTransparency = transparency or 0,
                BorderSizePixel = 0, ZIndex = 1,
            }, tree)
            round(line, thickness)
            return line
        end

        local function treeBall(name, x, y, color, size)
            local ball = make("Frame", {
                Name = name, AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(x, y), Size = UDim2.new(0, size, 0, size),
                BackgroundColor3 = color, BackgroundTransparency = 0.06,
                BorderSizePixel = 0, ZIndex = 1,
            }, tree)
            round(ball, 1)
            make("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.52}, ball)
            local shine = make("Frame", {Name = "Highlight", Position = UDim2.new(0.22, 0, 0.17, 0), Size = UDim2.new(0.22, 0, 0.22, 0), BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0.18, BorderSizePixel = 0, ZIndex = 1}, ball)
            round(shine, 1)
        end

        local leaf = Color3.fromRGB(42, 137, 78)
        local leafLight = Color3.fromRGB(69, 170, 99)
        local wire = Color3.fromRGB(232, 190, 81)
        -- Visible evergreen body: layered green tiers ensure the tree never looks hollow.
        local function treeTier(name, x, y, w, h, color)
            local tier = make("Frame", {
                Name = name, AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(w, h),
                BackgroundColor3 = color, BackgroundTransparency = 0.03,
                BorderSizePixel = 0, ZIndex = 1,
            }, tree)
            round(tier, 5)
            return tier
        end
        treeTier("EvergreenTopFill", 0.50, 0.27, 0.30, 0.25, Color3.fromRGB(32, 119, 64))
        treeTier("EvergreenMiddleFill", 0.50, 0.48, 0.51, 0.27, Color3.fromRGB(27, 105, 56))
        treeTier("EvergreenBottomFill", 0.50, 0.68, 0.72, 0.28, Color3.fromRGB(22, 91, 48))
        -- Bright branch edges give the filled tiers a recognizable fir-tree silhouette.
        treeLine("TreeLeftTop", 0.50, 0.12, 0.29, 0.39, leafLight, 8, 0.02)
        treeLine("TreeRightTop", 0.50, 0.12, 0.71, 0.39, leafLight, 8, 0.02)
        treeLine("TreeLeftMiddle", 0.50, 0.27, 0.20, 0.59, leaf, 10, 0.02)
        treeLine("TreeRightMiddle", 0.50, 0.27, 0.80, 0.59, leaf, 10, 0.02)
        treeLine("TreeLeftBottom", 0.50, 0.43, 0.10, 0.79, leafLight, 11, 0.02)
        treeLine("TreeRightBottom", 0.50, 0.43, 0.90, 0.79, leafLight, 11, 0.02)
        treeLine("TreeTrunk", 0.50, 0.77, 0.50, 0.94, Color3.fromRGB(150, 94, 53), 10, 0.10)

        -- Gold garlands are made from short angled line segments, not an image.
        local garlands = {
            {0.34,0.31,0.48,0.36},{0.48,0.36,0.64,0.31},
            {0.26,0.48,0.46,0.54},{0.46,0.54,0.70,0.47},
            {0.17,0.66,0.43,0.72},{0.43,0.72,0.79,0.64},
        }
        for i, g in ipairs(garlands) do
            treeLine("GoldGarland" .. i, g[1], g[2], g[3], g[4], wire, 2, 0.12)
        end

        treeBall("RedOrnament1", 0.40, 0.28, Color3.fromRGB(236, 68, 76), 9)
        treeBall("GoldOrnament1", 0.62, 0.35, Color3.fromRGB(255, 210, 89), 8)
        treeBall("BlueOrnament1", 0.28, 0.48, Color3.fromRGB(101, 201, 239), 8)
        treeBall("RedOrnament2", 0.68, 0.51, Color3.fromRGB(236, 68, 76), 10)
        treeBall("GoldOrnament2", 0.42, 0.61, Color3.fromRGB(255, 210, 89), 8)
        treeBall("PurpleOrnament", 0.60, 0.70, Color3.fromRGB(194, 133, 255), 8)
        treeBall("RedOrnament3", 0.22, 0.72, Color3.fromRGB(236, 68, 76), 9)
        treeBall("BlueOrnament2", 0.76, 0.66, Color3.fromRGB(101, 201, 239), 7)
        treeBall("GoldOrnament3", 0.51, 0.43, Color3.fromRGB(255, 210, 89), 7)
        treeBall("RedOrnament4", 0.34, 0.57, Color3.fromRGB(236, 68, 76), 7)

        -- Tiny snow glints around the tree add depth without cluttering the panel.
        for i, flake in ipairs({
            {0.08,0.22,4},{0.88,0.30,3},{0.12,0.43,3},{0.91,0.53,4},
            {0.08,0.68,3},{0.86,0.82,4},{0.28,0.12,3},{0.73,0.15,3},
        }) do
            local snow = make("TextLabel", {
                Name="TreeSnowGlint"..i, BackgroundTransparency=1,
                Position=UDim2.fromScale(flake[1],flake[2]), Size=UDim2.fromOffset(10,10),
                Text="✦", TextColor3=Color3.fromRGB(220,245,255), TextTransparency=0.16,
                TextSize=flake[3]+5, Font=Enum.Font.GothamBold, ZIndex=1,
            }, tree)
        end

        -- Add layered branchlets so the silhouette reads as a fir tree, not three flat triangles.
        local branchlets = {
            {0.43,0.24,0.34,0.32},{0.57,0.24,0.66,0.32},
            {0.39,0.34,0.28,0.43},{0.61,0.34,0.72,0.43},
            {0.34,0.45,0.22,0.55},{0.66,0.45,0.78,0.55},
            {0.29,0.57,0.15,0.69},{0.71,0.57,0.85,0.69},
            {0.25,0.68,0.12,0.77},{0.75,0.68,0.88,0.77},
        }
        for i, b in ipairs(branchlets) do
            treeLine("FirBranchlet"..i,b[1],b[2],b[3],b[4],i%2==0 and leafLight or leaf,4,0.04)
        end

        -- Fine snow dusting on a few branch tips.
        for i, tip in ipairs({
            {0.35,0.31,0.43,0.29},{0.57,0.30,0.65,0.32},
            {0.26,0.46,0.35,0.43},{0.66,0.44,0.74,0.47},
            {0.17,0.63,0.27,0.60},{0.72,0.60,0.82,0.63},
        }) do
            treeLine("SnowOnBranch"..i,tip[1],tip[2],tip[3],tip[4],Color3.fromRGB(218,242,239),2,0.14)
        end

        -- Small multicolour bulbs along the garlands, each with a tiny white glint.
        local bulbs = {
            {0.36,0.32},{0.44,0.35},{0.53,0.35},{0.62,0.32},
            {0.28,0.49},{0.38,0.52},{0.49,0.53},{0.60,0.51},{0.70,0.48},
            {0.19,0.66},{0.31,0.69},{0.43,0.70},{0.56,0.69},{0.68,0.67},{0.79,0.64},
        }
        local bulbColors = {
            Color3.fromRGB(255,75,82), Color3.fromRGB(255,214,94),
            Color3.fromRGB(103,207,255), Color3.fromRGB(255,255,226),
            Color3.fromRGB(208,132,255),
        }
        for i, bulb in ipairs(bulbs) do
            treeBall("GarlandBulb"..i,bulb[1],bulb[2],bulbColors[(i-1)%#bulbColors+1],5)
        end

        -- Layered presents at the foot of the tree.
        local function gift(name,x,y,w,h,base,ribbon)
            local box = make("Frame", {
                Name=name, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(x,y),
                Size=UDim2.new(0,w,0,h), BackgroundColor3=base, BorderSizePixel=0, ZIndex=1,
            },tree)
            round(box,2)
            make("UIStroke",{Color=Color3.fromRGB(255,235,190),Thickness=1,Transparency=0.35},box)
            make("Frame",{Name="RibbonVertical",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(0,3,1,0),BackgroundColor3=ribbon,BorderSizePixel=0,ZIndex=1},box)
            make("Frame",{Name="RibbonHorizontal",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,0,0,3),BackgroundColor3=ribbon,BorderSizePixel=0,ZIndex=1},box)
            local lid=make("Frame",{Name="Lid",AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,0,1),Size=UDim2.new(1,4,0,4),BackgroundColor3=base:Lerp(Color3.new(1,1,1),0.18),BorderSizePixel=0,ZIndex=1},box)
            round(lid,2)
        end
        gift("PresentRuby",0.30,0.86,19,15,Color3.fromRGB(186,42,55),Color3.fromRGB(255,215,112))
        gift("PresentGold",0.51,0.88,22,17,Color3.fromRGB(229,169,54),Color3.fromRGB(248,247,220))
        gift("PresentBlue",0.72,0.86,18,14,Color3.fromRGB(47,124,177),Color3.fromRGB(255,99,115))

        -- Trunk bark texture, plus a subtle snow base.
        treeLine("TrunkBark1",0.47,0.82,0.47,0.91,Color3.fromRGB(104,62,39),2,0.08)
        treeLine("TrunkBark2",0.53,0.84,0.53,0.92,Color3.fromRGB(194,132,78),2,0.10)
        treeLine("SnowBase",0.18,0.95,0.83,0.95,Color3.fromRGB(207,235,246),3,0.18)

        -- A crisp five-point-style star made from gold strokes with a soft halo.
        local starGlow=make("Frame",{Name="StarGlow",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.075),Size=UDim2.fromOffset(20,20),BackgroundColor3=Color3.fromRGB(255,211,83),BackgroundTransparency=0.76,BorderSizePixel=0,ZIndex=1},tree)
        round(starGlow,1)
        treeLine("StarSlashA", 0.43, 0.075, 0.57, 0.075, Color3.fromRGB(255, 224, 126), 3, 0)
        treeLine("StarSlashB", 0.50, 0.025, 0.50, 0.125, Color3.fromRGB(255, 224, 126), 3, 0)
        treeLine("StarSlashC", 0.455, 0.035, 0.545, 0.115, Color3.fromRGB(255, 224, 126), 2, 0)
        treeLine("StarSlashD", 0.545, 0.035, 0.455, 0.115, Color3.fromRGB(255, 224, 126), 2, 0)
    end

    -- Bloody theme backdrop: interlinked metal chains, worn links, and subtle dark-red drips.
    -- Kept behind the functional controls so the UI remains readable.
    if ACTIVE_THEME == "Bloody" then
        local chainLayer = make("Frame", {Name="BloodyChainBackground", BackgroundTransparency=1,
            Position=UDim2.new(0,0,0,42), Size=UDim2.new(1,0,1,-48), BorderSizePixel=0,
            ClipsDescendants=false, ZIndex=1}, root)
        local metal = Color3.fromRGB(92, 96, 106)
        local metalLight = Color3.fromRGB(151, 151, 160)
        local metalShade = Color3.fromRGB(39, 40, 48)
        local function chainLink(name, x, y, rotation, scale)
            local holder = make("Frame", {Name=name, AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.fromScale(x,y), Size=UDim2.fromOffset(25*scale,15*scale),
                Rotation=rotation, BackgroundTransparency=1, BorderSizePixel=0, ZIndex=1}, chainLayer)
            local outer = make("Frame", {Name="ForgedSteel", Size=UDim2.fromScale(1,1),
                BackgroundColor3=metal, BorderSizePixel=0, ZIndex=1}, holder)
            round(outer, 8)
            make("UIStroke", {Color=metalShade, Thickness=3, Transparency=0.03}, outer)
            local inner = make("Frame", {Name="HollowCore", AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(1,-8*scale,1,-7*scale),
                BackgroundColor3=COLORS.Window, BorderSizePixel=0, ZIndex=2}, outer)
            round(inner, 7)
            make("UIStroke", {Color=metalLight, Thickness=1, Transparency=0.18}, outer)
            make("Frame", {Name="MetalGlint", Position=UDim2.new(0.16,0,0.13,0),
                Size=UDim2.new(0.34,0,0,math.max(1,scale)), BackgroundColor3=metalLight,
                BackgroundTransparency=0.15, BorderSizePixel=0, ZIndex=3}, outer)
            return holder
        end
        -- Two continuous diagonal chain runs cross to form a clear X.
        -- Links overlap slightly so each strand reads as one connected chain, not scattered pieces.
        local function chainRun(prefix, reverse)
            local count = 19
            for i=1,count do
                local t = (i-1)/(count-1)
                local x = reverse and (0.055 + t*0.89) or (0.055 + t*0.89)
                local y = reverse and (0.045 + t*0.91) or (0.955 - t*0.91)
                -- Small alternating offsets make the interlocked links look hand-forged.
                x = x + math.sin(i*1.7)*0.006
                y = y + math.cos(i*1.3)*0.008
                local angle = reverse and 40 or -40
                angle = angle + (i%2==0 and 12 or -12)
                local scale = i%4==0 and 0.92 or 0.82
                chainLink(prefix.."Link"..i, x, y, angle, scale)
                if i%4==2 then
                    local drip = make("Frame", {Name=prefix.."BloodDrip"..i,
                        AnchorPoint=Vector2.new(0.5,0), Position=UDim2.fromScale(x+0.008,y+0.012),
                        Size=UDim2.fromOffset(2,bloodRandom:NextInteger(8,17)), BackgroundColor3=BLOOD_MID,
                        BackgroundTransparency=0.08, BorderSizePixel=0, Rotation=bloodRandom:NextInteger(-8,8), ZIndex=2}, chainLayer)
                    round(drip, 2)
                end
            end
        end
        chainRun("BloodyXUpperLeftToLowerRight", true)
        chainRun("BloodyXUpperRightToLowerLeft", false)
        -- Layered blood splashes: dark stains, brighter fresh drops, and short tapered-looking trails.
        -- Keep most marks near the diagonal chains and outer margins so controls stay legible.
        for i=1,20 do
            local side = i%2==0 and bloodRandom:NextNumber(0.08,0.34) or bloodRandom:NextNumber(0.66,0.92)
            local y = bloodRandom:NextNumber(0.06,0.94)
            local w = bloodRandom:NextInteger(4,11)
            local h = bloodRandom:NextInteger(3,9)
            local color = i%5==0 and BLOOD_BRIGHT or (i%2==0 and BLOOD_MID or BLOOD_DARK)
            local stain = make("Frame", {Name="BackdropBloodStain"..i, AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.fromScale(side,y), Size=UDim2.fromOffset(w,h), Rotation=bloodRandom:NextInteger(-65,65),
                BackgroundColor3=color, BackgroundTransparency=bloodRandom:NextNumber(0.04,0.22), BorderSizePixel=0, ZIndex=2}, chainLayer)
            round(stain, bloodRandom:NextInteger(2,5))
            if i%2==0 then
                local trail = make("Frame", {Name="BackdropBloodTrail"..i, AnchorPoint=Vector2.new(0.5,0),
                    Position=UDim2.fromScale(side+bloodRandom:NextNumber(-0.012,0.012),y+0.012),
                    Size=UDim2.fromOffset(bloodRandom:NextInteger(2,4),bloodRandom:NextInteger(7,16)),
                    Rotation=bloodRandom:NextInteger(-10,10), BackgroundColor3=color,
                    BackgroundTransparency=bloodRandom:NextNumber(0.06,0.20), BorderSizePixel=0, ZIndex=2}, chainLayer)
                round(trail, 2)
            end
            for dot=1,3 do
                local splat = make("Frame", {Name="BackdropBloodSplat"..i.."_"..dot,
                    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(side+bloodRandom:NextNumber(-0.025,0.025),y+bloodRandom:NextNumber(-0.025,0.025)),
                    Size=UDim2.fromOffset(bloodRandom:NextInteger(2,4),bloodRandom:NextInteger(2,4)),
                    BackgroundColor3=color, BackgroundTransparency=bloodRandom:NextNumber(0.02,0.18),
                    BorderSizePixel=0, ZIndex=2}, chainLayer)
                round(splat, 2)
            end
        end
    end

    local tabList
    local header = make("Frame", {Name="Header", Size=UDim2.new(1,0,0,44), BackgroundColor3=ACTIVE_THEME == "Classic" and Color3.fromRGB(0,0,128) or COLORS.Window, BackgroundTransparency=ACTIVE_THEME == "Classic" and 0 or 1, BorderSizePixel=0}, root)
    if ACTIVE_THEME == "Classic" then
        local titleGradient = make("UIGradient", {Color=ColorSequence.new(Color3.fromRGB(0,0,160), Color3.fromRGB(0,0,96))}, header)
    end
    local seasonalHeader = ACTIVE_THEME == "Halloween" or ACTIVE_THEME == "Christmas"
    -- Reserve a dedicated brand lane on the left and a control lane on the right.
    -- This prevents the theme logo, opacity orb, minimize, and close controls from overlapping.
    local titleLeft = ACTIVE_THEME == "Halloween" and 56 or (ACTIVE_THEME == "Christmas" and 42 or 12)
    local title = label(header, options.Name or "Zynz", {Size=UDim2.new(1, -(titleLeft + 116), 1, 0), Position=UDim2.new(0,titleLeft,0,0), MaxTextSize=15, MinTextSize=6})
    title.Font = ACTIVE_THEME == "Classic" and Enum.Font.ArialBold or Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    if ACTIVE_THEME == "Classic" then title.TextColor3 = Color3.fromRGB(255,255,255) end
    -- Make the title an explicit active drag target. Its bounds stop before the window controls.
    title.Active = true
    title.Selectable = false
    if ACTIVE_THEME == "Halloween" then
        -- Tiny script-drawn pumpkin badge in the header; no external image/asset ID.
        local badge = make("Frame", {Name="HalloweenPumpkinBadge", BackgroundColor3=Color3.fromRGB(245,112,31), BorderSizePixel=0,
            Size=UDim2.new(0,23,0,20), Position=UDim2.new(0,10,0,12), ZIndex=2}, header)
        round(badge, 8)
        make("UIStroke", {Color=Color3.fromRGB(255,177,79), Thickness=1, Transparency=0.12}, badge)
        local badgeStem = make("Frame", {Name="PumpkinBadgeStem", BackgroundColor3=Color3.fromRGB(76,133,58), BorderSizePixel=0,
            Size=UDim2.new(0,5,0,7), Position=UDim2.new(0.43,0,0,-4), Rotation=8, ZIndex=2}, badge)
        round(badgeStem, 2)
        for i, x in ipairs({0.28,0.50,0.72}) do
            local rib = make("Frame", {Name="BadgeRib"..i, BackgroundColor3=Color3.fromRGB(255,177,79), BackgroundTransparency=0.38,
                BorderSizePixel=0, Size=UDim2.new(0,3,0.76,0), Position=UDim2.new(x,-1.5,0.12,0), ZIndex=2}, badge)
            round(rib, 2)
        end
        local seasonalMark = label(header, "☾", {Name="HalloweenMark", Size=UDim2.new(0,16,1,0), Position=UDim2.new(0,34,0,0), TextXAlignment=Enum.TextXAlignment.Center, TextColor3=COLORS.Accent, MaxTextSize=14, MinTextSize=8})
        seasonalMark.Font = Enum.Font.GothamBold
    elseif ACTIVE_THEME == "Christmas" then
        -- Script-drawn Christmas tree is placed behind the window content; header uses a text-only snowflake.
        local seasonalMark = label(header, "❄", {Name="ChristmasMark", Size=UDim2.new(0,26,1,0), Position=UDim2.new(0,10,0,0), TextXAlignment=Enum.TextXAlignment.Center, TextColor3=COLORS.Accent, MaxTextSize=18, MinTextSize=8})
        seasonalMark.Font = Enum.Font.GothamBold
    end
    local minimize = make("TextButton", {Name="Minimize", Text="−", Font=Enum.Font.GothamBold, TextSize=18, TextColor3=COLORS.Text, BackgroundColor3=COLORS.Component, BorderSizePixel=0, Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-72,0,6), AutoButtonColor=false}, header)
    round(minimize, cornerRadius(9, 3))
    if ACTIVE_THEME == "Classic" then minimize.Font = Enum.Font.ArialBold; minimize.TextColor3 = Color3.fromRGB(0,0,0); make("UIStroke", {Color=Color3.fromRGB(255,255,255), Thickness=1}, minimize) end
    local close = make("TextButton", {Name="Close", Text="×", Font=Enum.Font.GothamBold, TextSize=18, TextColor3=COLORS.Text, BackgroundColor3=COLORS.Component, BorderSizePixel=0, Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-36,0,6), AutoButtonColor=false}, header)
    round(close, cornerRadius(9, 3))

    -- Theme-specific opacity orb beside the minimize/delete controls.
    -- The orb starts at 0.4 transparency; clicking it makes selected shell panels translucent.
    local opacityOrb = make("TextButton", {
        Name="OpacityOrb", Text="", AutoButtonColor=false,
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(1,-96,0,22),
        Size=UDim2.fromOffset(17,17), BackgroundColor3=COLORS.Accent,
        BackgroundTransparency=0.4, BorderSizePixel=0, ZIndex=12,
    }, header)
    local orbCorner = round(opacityOrb, 9)
    local orbStroke = make("UIStroke", {Color=COLORS.Line, Thickness=1.25, Transparency=0.12}, opacityOrb)
    local orbGradient = make("UIGradient", {Rotation=45, Color=ColorSequence.new(COLORS.Accent, COLORS.Component)}, opacityOrb)
    if ACTIVE_THEME == "Classic" then
        opacityOrb.Size = UDim2.fromOffset(15,15)
        opacityOrb.BackgroundColor3 = Color3.fromRGB(0,0,128)
        orbGradient.Enabled = false
        orbStroke.Color = Color3.fromRGB(255,255,255)
    elseif ACTIVE_THEME == "Halloween" then
        opacityOrb.Text = "•"
        opacityOrb.TextColor3 = Color3.fromRGB(255,180,65)
        opacityOrb.TextSize = 15
        opacityOrb.BackgroundColor3 = Color3.fromRGB(67,28,91)
        orbStroke.Color = Color3.fromRGB(255,126,36)
    elseif ACTIVE_THEME == "Christmas" then
        opacityOrb.BackgroundColor3 = Color3.fromRGB(190,42,55)
        orbStroke.Color = Color3.fromRGB(240,198,92)
        make("Frame", {Name="OrbShine", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.31,0.28), Size=UDim2.fromScale(0.23,0.23), BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.1, BorderSizePixel=0, ZIndex=13}, opacityOrb)
    elseif ACTIVE_THEME == "Modern" then
        orbStroke.Color = Color3.fromRGB(177,235,255)
        orbGradient.Color = ColorSequence.new(Color3.fromRGB(225,250,255), Color3.fromRGB(44,103,129))
    end
    local shellTranslucent = false
    local function setShellTranslucency(enabled)
        shellTranslucent = enabled
        local target = enabled and 0.4 or 0
        local targets = {
            {root, "BackgroundTransparency", target},
            {header, "BackgroundTransparency", enabled and 0.4 or (ACTIVE_THEME == "Classic" and 0 or 1)},
            {tabList, "BackgroundTransparency", target},
        }
        for _, item in ipairs(targets) do
            local object, property, value = item[1], item[2], item[3]
            if object and object.Parent then
                TweenService:Create(object, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[property]=value}):Play()
            end
        end
        -- Give the tab rail and header controls a matching softened look, while keeping text readable.
        for _, object in ipairs({minimize, close}) do
            if object and object.Parent then
                TweenService:Create(object, TweenInfo.new(0.18), {BackgroundTransparency=enabled and 0.4 or 0}):Play()
            end
        end
        TweenService:Create(opacityOrb, TweenInfo.new(0.16), {
            BackgroundTransparency = enabled and 0 or 0.4,
            Size = enabled and UDim2.fromOffset(19,19) or UDim2.fromOffset(ACTIVE_THEME == "Classic" and 15 or 17, ACTIVE_THEME == "Classic" and 15 or 17),
        }):Play()
        TweenService:Create(orbStroke, TweenInfo.new(0.16), {Transparency=enabled and 0 or 0.12, Thickness=enabled and 1.7 or 1.25}):Play()
    end
    opacityOrb.Activated:Connect(function() setShellTranslucency(not shellTranslucent) end)
    if ACTIVE_THEME == "Classic" then close.Font = Enum.Font.ArialBold; close.TextColor3 = Color3.fromRGB(0,0,0); make("UIStroke", {Color=Color3.fromRGB(255,255,255), Thickness=1}, close) end
    local minimizeStroke = make("UIStroke", {Color=COLORS.Line, Thickness=1, Transparency=0.55}, minimize)
    local closeStroke = make("UIStroke", {Color=COLORS.Line, Thickness=1, Transparency=0.55}, close)
    local function styleHeaderControl(button, stroke, isClose)
        button.MouseEnter:Connect(function()
            local hoverColor = isClose and Color3.fromRGB(190, 55, 68) or COLORS.ComponentHover
            TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3=hoverColor}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.12), {Color=isClose and Color3.fromRGB(255, 120, 130) or COLORS.Accent, Transparency=0.05}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3=COLORS.Component}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.14), {Color=COLORS.Line, Transparency=0.55}):Play()
        end)
    end
    styleHeaderControl(minimize, minimizeStroke, false)
    styleHeaderControl(close, closeStroke, true)

    -- Subtle accent separator under the title bar.
    local headerLine = make("Frame", {Name="HeaderAccent", Position=UDim2.new(0,ACTIVE_THEME == "Classic" and 0 or 12,0,43), Size=UDim2.new(1,ACTIVE_THEME == "Classic" and 0 or -24,0,1), BackgroundColor3=ACTIVE_THEME == "Classic" and Color3.fromRGB(128,128,128) or COLORS.Accent, BackgroundTransparency=ACTIVE_THEME == "Classic" and 0 or (ACTIVE_THEME == "Modern" and 0.12 or 0.25), BorderSizePixel=0}, root)

    local content = make("Frame", {Name="Content", Position=UDim2.new(0,10,0,50), Size=UDim2.new(1,-20,1,-60), BackgroundTransparency=1}, root)
    local page = make("Frame", {Name="Page", Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,-(tabWidth()+8),1,0), BackgroundTransparency=1}, content)
    local pages = make("Folder", {Name="Pages"}, page)
    tabList = make("ScrollingFrame", {Name="Tabs", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,tabWidth(),1,0), BackgroundColor3=COLORS.Tab, BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=COLORS.Line, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y}, content)
    round(tabList, cornerRadius(11, 3))
    make("UIStroke", {Color=COLORS.Line, Thickness=1, Transparency=0.72}, tabList)
    make("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder}, tabList)
    make("UIPadding", {PaddingTop=UDim.new(0,6), PaddingLeft=UDim.new(0,5), PaddingRight=UDim.new(0,5), PaddingBottom=UDim.new(0,6)}, tabList)

    -- The minimized chip lives in PlayerGui at a low DisplayOrder so Roblox HUD elements
    -- can render above it. The full window stays in the executor UI container.
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local oldRestoreGui = playerGui:FindFirstChild("ZynzMinimizedUI")
    if oldRestoreGui then oldRestoreGui:Destroy() end
    local restoreGui = make("ScreenGui", {
        Name = "ZynzMinimizedUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = -100,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    }, playerGui)
    local restore = make("TextButton", {Name="RestoreZynz", Text="  ZYNZ  ›", Font=Enum.Font.GothamBold, TextColor3=COLORS.Text, TextSize=13, TextScaled=true, BackgroundColor3=COLORS.Window, BorderSizePixel=0, Visible=false, Size=UDim2.new(0,104,0,44), Position=UDim2.new(0,14,0.5,-22), AutoButtonColor=false, Active=true, ZIndex=2}, restoreGui)
    round(restore, cornerRadius(14, 4))
    local restoreStroke = make("UIStroke", {Color=COLORS.Accent, Thickness=1.35, Transparency=0.08}, restore)
    local restoreGradient = make("UIGradient", {Rotation=0, Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Component),
        ColorSequenceKeypoint.new(1, COLORS.Window),
    })}, restore)
    make("Frame", {Name="RestoreAccent", BorderSizePixel=0, BackgroundColor3=COLORS.Accent,
        Size=UDim2.new(0,3,0.58,0), Position=UDim2.new(0,7,0.21,0), ZIndex=3}, restore)
    addTextConstraint(restore, 10, 15)
    restore.MouseEnter:Connect(function()
        TweenService:Create(restore, TweenInfo.new(0.13), {BackgroundColor3=COLORS.ComponentHover}):Play()
        TweenService:Create(restoreStroke, TweenInfo.new(0.13), {Transparency=0, Thickness=1.8}):Play()
    end)
    restore.MouseLeave:Connect(function()
        TweenService:Create(restore, TweenInfo.new(0.15), {BackgroundColor3=COLORS.Window}):Play()
        TweenService:Create(restoreStroke, TweenInfo.new(0.15), {Transparency=0.08, Thickness=1.35}):Play()
    end)
    makeDraggable(root, title) -- only the title text area is draggable in the header
    makeDraggable(restore)

    -- Allow dragging from the side and bottom edges too, not just the header.
    local dragEdges = {
        {Name="DragLeftEdge", Position=UDim2.new(0,0,0,48), Size=UDim2.new(0,12,1,-112)},
        {Name="DragRightEdge", Position=UDim2.new(1,-12,0,48), Size=UDim2.new(0,12,1,-112)},
        {Name="DragBottomEdge", Position=UDim2.new(0,64,1,-12), Size=UDim2.new(1,-128,0,12)},
    }
    for _, edgeInfo in ipairs(dragEdges) do
        local edge = make("TextButton", {Name=edgeInfo.Name, Text="", AutoButtonColor=false,
            BackgroundTransparency=1, BorderSizePixel=0, Position=edgeInfo.Position,
            Size=edgeInfo.Size, ZIndex=25}, root)
        makeDraggable(root, edge)
    end

    -- Touch-friendly invisible resize controls on both bottom corners.
    -- The large circular hit area makes resizing easier on phones/tablets.
    local resizing, resizeCorner, resizeStart, sizeStart, posStart, holdToken = false, nil, nil, nil, nil, 0
    local activeHandle, activeArrow = nil, nil

    local function hideResizeArrow()
        if activeArrow then activeArrow:Destroy(); activeArrow=nil end
    end

    local function showResizeArrow(rightSide)
        hideResizeArrow()
        local arrow = make("TextLabel", {
            Name = "ResizeDirectionHint", BackgroundTransparency = 1,
            Text = rightSide and "<" or ">", Font = Enum.Font.GothamBlack,
            TextSize = 42, TextColor3 = COLORS.Text, TextStrokeTransparency = 0.25,
            TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(54, 54),
            Position = UDim2.new(0, 0, 0, 0), ZIndex = 100,
        }, gui)
        local function updateArrow()
            if not arrow.Parent or not root.Parent then return end
            local p = root.AbsolutePosition
            local sz = root.AbsoluteSize
            -- Keep the hint outside the window, near the chosen bottom corner,
            -- pointing inward toward the bottom-center resize direction.
            local x = rightSide and (p.X + sz.X + 20) or (p.X - 20)
            local y = p.Y + sz.Y + 2
            arrow.Position = UDim2.fromOffset(x, y)
        end
        updateArrow()
        activeArrow = arrow
        return updateArrow
    end

    local arrowUpdater
    local function addResizeHandle(name, rightSide)
        local handle = make("TextButton", {
            Name=name, Text="", AutoButtonColor=false, BackgroundTransparency=1,
            AnchorPoint=Vector2.new(rightSide and 1 or 0,1),
            Position=UDim2.new(rightSide and 1 or 0,0,1,0),
            Size=UDim2.fromOffset(64,64), ZIndex=30,
        }, root)
        -- Invisible quarter-corner hit target: easy to touch, but no visible circle or grip.
        -- The button is a square hitbox anchored to the selected corner; only its inward quarter is useful.
        local touchArc = make("Frame", {
            Name="TouchQuarterCircle", AnchorPoint=Vector2.new(rightSide and 1 or 0,1),
            Position=UDim2.new(rightSide and 1 or 0,0,1,0), Size=UDim2.fromOffset(64,64),
            BackgroundTransparency=1, BorderSizePixel=0, ZIndex=30,
        }, handle)

        handle.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            holdToken += 1
            local token = holdToken
            local origin = input.Position
            activeHandle = handle
            task.delay(0.5, function()
                if token ~= holdToken or not handle.Parent or activeHandle ~= handle then return end
                resizing = true
                resizeCorner = rightSide and "Right" or "Left"
                resizeStart = origin
                sizeStart = root.AbsoluteSize
                posStart = root.Position
                arrowUpdater = showResizeArrow(rightSide)
            end)
        end)
        local function release(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            holdToken += 1
            resizing = false
            resizeCorner = nil
            activeHandle = nil
            arrowUpdater = nil
            hideResizeArrow()
        end
        handle.InputEnded:Connect(release)
    end

    addResizeHandle("ResizeBottomRight", true)
    addResizeHandle("ResizeBottomLeft", false)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
            resizeCorner = nil
            activeHandle = nil
            arrowUpdater = nil
            hideResizeArrow()
            holdToken += 1
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not resizing or not resizeStart or not sizeStart then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - resizeStart
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800,600)
        local minW, minH = 280, 260
        local maxW, maxH = math.min(920, viewport.X - 16), math.min(780, viewport.Y - 16)
        local w = math.clamp(sizeStart.X + (resizeCorner == "Right" and delta.X or -delta.X), minW, math.max(minW,maxW))
        local h = math.clamp(sizeStart.Y + delta.Y, minH, math.max(minH,maxH))
        -- Update root size continuously; Roblox's layout/constraints recalculate its contents as it changes.
        root.Size = UDim2.new(0,w,0,h)
        local shiftX = (w-sizeStart.X)/2 * (resizeCorner == "Right" and 1 or -1)
        local shiftY = (h-sizeStart.Y)/2
        root.Position = UDim2.new(posStart.X.Scale,posStart.X.Offset+shiftX,posStart.Y.Scale,posStart.Y.Offset+shiftY)
        if arrowUpdater then arrowUpdater() end
    end)

    local window = {Gui=gui, Root=root, _tabs={}, _active=nil, _restore=restore, _initialTabNeutral=true}

    -- Change between built-in themes at runtime. Existing tabs, labels, buttons,
    -- controls, popups and strokes are recolored using their recorded palette roles.
    function window:SetTheme(themeName)
        if type(themeName) ~= "string" or not PALETTES[themeName] then
            local wanted = string.lower(tostring(themeName or ""))
            for name in pairs(PALETTES) do
                if string.lower(name) == wanted then themeName = name; break end
            end
        end
        if type(themeName) ~= "string" or not PALETTES[themeName] then return false end
        applyTheme(themeName)
        -- Keep the opacity orb distinctive for every theme when themes change at runtime.
        if opacityOrb and opacityOrb.Parent then
            opacityOrb.BackgroundColor3 = COLORS.Accent
            opacityOrb.BackgroundTransparency = shellTranslucent and 0 or 0.4
            orbStroke.Color = COLORS.Line
            orbGradient.Color = ColorSequence.new(COLORS.Accent, COLORS.Component)
            orbGradient.Enabled = ACTIVE_THEME ~= "Classic"
            opacityOrb.Text = ACTIVE_THEME == "Halloween" and "•" or ""
            opacityOrb.TextColor3 = ACTIVE_THEME == "Halloween" and Color3.fromRGB(255,180,65) or COLORS.Text
            if ACTIVE_THEME == "Classic" then
                opacityOrb.BackgroundColor3 = Color3.fromRGB(0,0,128)
                orbStroke.Color = Color3.fromRGB(255,255,255)
                opacityOrb.Size = UDim2.fromOffset(15,15)
            elseif ACTIVE_THEME == "Halloween" then
                opacityOrb.BackgroundColor3 = Color3.fromRGB(67,28,91)
                orbStroke.Color = Color3.fromRGB(255,126,36)
                opacityOrb.Size = UDim2.fromOffset(17,17)
            elseif ACTIVE_THEME == "Christmas" then
                opacityOrb.BackgroundColor3 = Color3.fromRGB(190,42,55)
                orbStroke.Color = Color3.fromRGB(240,198,92)
                opacityOrb.Size = UDim2.fromOffset(17,17)
            elseif ACTIVE_THEME == "Modern" then
                orbStroke.Color = Color3.fromRGB(177,235,255)
                orbGradient.Color = ColorSequence.new(Color3.fromRGB(225,250,255), Color3.fromRGB(44,103,129))
                opacityOrb.Size = UDim2.fromOffset(17,17)
            else
                opacityOrb.Size = UDim2.fromOffset(17,17)
            end
        end
        for _, obj in ipairs(gui:GetDescendants()) do
            for property, roles in pairs({
                BackgroundColor3 = true, TextColor3 = true,
                PlaceholderColor3 = true, Color = true,
            }) do
                local role = obj:GetAttribute("ZynzThemeRole_" .. property)
                if role and COLORS[role] then
                    pcall(function() obj[property] = COLORS[role] end)
                end
            end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if ACTIVE_THEME == "Classic" then obj.Font = Enum.Font.Arial else obj.Font = Enum.Font.Gotham end
            end
        end
        -- Explicitly refresh the window shell and tab states.
        root.BackgroundColor3 = COLORS.Window
        root.BackgroundTransparency = shellTranslucent and 0.4 or 0
        header.BackgroundTransparency = shellTranslucent and 0.4 or (ACTIVE_THEME == "Classic" and 0 or 1)
        tabList.BackgroundTransparency = shellTranslucent and 0.4 or 0
        for _, item in ipairs(window._tabs) do
            local visuallyActive = item == window._active and not window._initialTabNeutral
            item.Button.BackgroundColor3 = visuallyActive and ((ACTIVE_THEME == "Classic" or ACTIVE_THEME == "Bloody") and COLORS.TabSelected or COLORS.Accent) or COLORS.Component
            item.Button.TextColor3 = visuallyActive and ((ACTIVE_THEME == "Classic" or ACTIVE_THEME == "Bloody") and Color3.fromRGB(255,255,255) or Color3.fromRGB(18,18,24)) or COLORS.Text
            local tabStroke = item.Button:FindFirstChildOfClass("UIStroke")
            if tabStroke then
                tabStroke.Color = visuallyActive and COLORS.Accent or COLORS.Line
                tabStroke.Transparency = visuallyActive and 0.08 or 0.42
                tabStroke.Thickness = visuallyActive and 1.5 or 1
            end
            local activeMark = item.Button:FindFirstChild("ActiveMark")
            if activeMark then
                activeMark.BackgroundColor3 = COLORS.Accent
                activeMark.Visible = visuallyActive
            end
            item.Page.ScrollBarImageColor3 = COLORS.Line
        end
        local stroke = root:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = COLORS.Line end
        return true
    end
    function window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tostring(tabOptions.Name or "Tab")
        local tabButton = make("TextButton", {Name=tabName.."TabButton", Text=tabName, Font=Enum.Font.GothamMedium, TextColor3=COLORS.Text, TextSize=getScale(), TextScaled=true, TextTruncate=Enum.TextTruncate.AtEnd, TextXAlignment=Enum.TextXAlignment.Left, BackgroundColor3=COLORS.Component, BorderSizePixel=0, Size=UDim2.new(1,0,0,rowHeight()), AutoButtonColor=false}, tabList)
        round(tabButton, cornerRadius(10, 2)); addTextConstraint(tabButton, 4, getScale())
        if ACTIVE_THEME == "Bloody" then addBloodSplatter(tabButton, "Tab", 5, 3) end
        local tabStroke = make("UIStroke", {Color=COLORS.Line, Thickness=1, Transparency=0.42}, tabButton)
        make("UIPadding", {PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,6)}, tabButton)
        local activeMark = make("Frame", {Name="ActiveMark", AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,-2,0.5,0), Size=UDim2.new(0,3,0,math.max(12,rowHeight()-14)), BackgroundColor3=COLORS.Accent, BorderSizePixel=0, Visible=false}, tabButton)
        round(activeMark, 3)
        tabButton.MouseEnter:Connect(function()
            if window._active ~= nil and window._active.Button ~= tabButton then
                TweenService:Create(tabButton, TweenInfo.new(0.12), {BackgroundColor3=COLORS.ComponentHover}):Play()
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if window._active == nil or window._active.Button ~= tabButton then
                TweenService:Create(tabButton, TweenInfo.new(0.12), {BackgroundColor3=COLORS.Component}):Play()
            end
        end)
        local tabPage = make("ScrollingFrame", {Name=tabName, Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=COLORS.Line, Visible=false, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y}, pages)
        make("UIListLayout", {Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder}, tabPage)
        make("UIPadding", {PaddingTop=UDim.new(0,2), PaddingRight=UDim.new(0,5), PaddingBottom=UDim.new(0,4)}, tabPage)
        local tab = {Page=tabPage, Button=tabButton, _order=0}
        local function activate()
            window._initialTabNeutral = false
            for _, item in ipairs(window._tabs) do
                item.Page.Visible = false
                item.Button.BackgroundColor3 = COLORS.Component
                item.Button.TextColor3 = COLORS.Text
                local stroke = item.Button:FindFirstChildOfClass("UIStroke")
                if stroke then stroke.Color = COLORS.Line; stroke.Transparency = 0.42; stroke.Thickness = 1 end
                local mark = item.Button:FindFirstChild("ActiveMark")
                if mark then mark.Visible = false end
            end
            tabPage.Visible = true
            tabButton.BackgroundColor3 = (ACTIVE_THEME == "Classic" or ACTIVE_THEME == "Bloody") and COLORS.TabSelected or COLORS.Accent
            tabButton.TextColor3 = (ACTIVE_THEME == "Classic" or ACTIVE_THEME == "Bloody") and Color3.fromRGB(255,255,255) or Color3.fromRGB(18,18,24)
            tabStroke.Color = COLORS.Accent
            tabStroke.Transparency = 0.08
            tabStroke.Thickness = 1.5
            activeMark.Visible = true
            window._active = tab
        end
        tabButton.MouseButton1Click:Connect(activate)
        tabButton.LayoutOrder = #window._tabs + 1
        table.insert(window._tabs, tab)
        if #window._tabs == 1 then
            tabPage.Visible = true
            window._active = tab
            tabButton.BackgroundColor3 = COLORS.Component
            tabButton.TextColor3 = COLORS.Text
            tabStroke.Color = COLORS.Line
            tabStroke.Transparency = 0.42
            tabStroke.Thickness = 1
            activeMark.Visible = false
        end

        local function nextOrder(obj)
            tab._order += 1
            obj.LayoutOrder = tab._order
            return obj
        end
        local function component(name, height)
            local frame = make("Frame", {
                Name=name, Size=UDim2.new(1,0,0,height or rowHeight()),
                BackgroundColor3=COLORS.Component, BorderSizePixel=0, ClipsDescendants=true,
            }, tabPage)
            round(frame, cornerRadius(10, 3))
            if ACTIVE_THEME == "Bloody" and name ~= "ColorPicker" and name ~= "Divider" and name ~= "Section" then
                addBloodSplatter(frame, name, 4, 3)
            end
            local stroke
            if ACTIVE_THEME == "Classic" then
                stroke = make("UIStroke", {Color=Color3.fromRGB(128,128,128), Thickness=1, Transparency=0}, frame)
            else
                stroke = make("UIStroke", {
                    Color=COLORS.Line, Thickness=1,
                    Transparency=ACTIVE_THEME == "Modern" and 0.42 or 0.34,
                }, frame)
                frame.MouseEnter:Connect(function()
                    if not frame.Parent then return end
                    TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3=COLORS.ComponentHover,
                    }):Play()
                    if stroke.Parent then
                        TweenService:Create(stroke, TweenInfo.new(0.12), {Color=COLORS.Accent, Transparency=0.12}):Play()
                    end
                end)
                frame.MouseLeave:Connect(function()
                    if not frame.Parent then return end
                    TweenService:Create(frame, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3=COLORS.Component,
                    }):Play()
                    if stroke.Parent then
                        TweenService:Create(stroke, TweenInfo.new(0.14), {
                            Color=COLORS.Line, Transparency=ACTIVE_THEME == "Modern" and 0.42 or 0.34,
                        }):Play()
                    end
                end)
            end
            return nextOrder(frame)
        end
        local function componentName(parent, name, rightWidth)
            return label(parent, name or "", {Size=UDim2.new(1,-(rightWidth or 12),1,0), Position=UDim2.new(0,9,0,0), MaxTextSize=getScale(), MinTextSize=4})
        end

        function tab:CreateButton(opts)
            opts=opts or {}
            local frame=component("Button",rowHeight())
            local txt=componentName(frame,opts.Name or "Button",62)
            local clickText=label(frame,"Click",{Name="ClickHint",Size=UDim2.new(0,48,1,0),Position=UDim2.new(1,-54,0,0),TextXAlignment=Enum.TextXAlignment.Right,TextColor3=ACTIVE_THEME=="Classic" and Color3.fromRGB(0,0,128) or COLORS.Accent,MaxTextSize=getScale(),MinTextSize=5})
            clickText.ZIndex=2
            if ACTIVE_THEME=="Classic" then clickText.Font=Enum.Font.ArialBold end
            local hit=make("TextButton",{Name="Hitbox",Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=1,AutoButtonColor=false},frame)
            hit.MouseButton1Click:Connect(function() if type(opts.Callback)=="function" then task.spawn(opts.Callback) end end)
            return {Frame=frame,Label=txt,ClickLabel=clickText}
        end

        function tab:CreateToggle(opts)
            opts=opts or {}; local frame=component("Toggle",rowHeight()); componentName(frame,opts.Name or "Toggle",38)
            local state=opts.Value == true or opts.ValueRn == true
            local track=make("Frame",{Name="Track",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-7,0.5,0),Size=UDim2.new(0,34,0,18),BackgroundColor3=state and COLORS.Accent or Color3.fromRGB(65,65,65),BorderSizePixel=0},frame); round(track,8)
            local knob=make("Frame",{Name="Knob",Position=state and UDim2.new(1,-16,0,0) or UDim2.new(0,2,0,0),Size=UDim2.new(0,18,0,18),BackgroundColor3=Color3.fromRGB(250,250,250),BorderSizePixel=0},track); round(knob,8)
            local hit=make("TextButton",{Name="Hitbox",Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},frame)
            local function set(v,call) state=v==true; TweenService:Create(track,TweenInfo.new(.12),{BackgroundColor3=state and COLORS.Accent or Color3.fromRGB(65,65,65)}):Play(); knob:TweenPosition(state and UDim2.new(1,-16,0,0) or UDim2.new(0,2,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.12,true); if call and type(opts.Callback)=="function" then task.spawn(opts.Callback,state) end end
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
            local frame=make("Frame",{Name="Paragraph",Size=UDim2.new(1,0,0,height),BackgroundColor3=COLORS.Component,BorderSizePixel=ACTIVE_THEME=="Classic" and 1 or 0},tabPage); round(frame,cornerRadius(9,0)); make("UIStroke",{Color=ACTIVE_THEME=="Classic" and Color3.fromRGB(128,128,128) or COLORS.Line,Thickness=1,Transparency=ACTIVE_THEME=="Classic" and 0 or 0.42},frame); nextOrder(frame)
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
            local input=make("TextBox",{Name="InputBox",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),Size=UDim2.new(0,110,0,controlHeight()),BackgroundColor3=controlColor(),BorderSizePixel=0,Text=tostring(opts.Default or ""),PlaceholderText=opts.Placeholder or "Enter...",TextColor3=COLORS.Text,PlaceholderColor3=COLORS.Muted,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,ClearTextOnFocus=false},frame); round(input,cornerRadius(5,0)); if ACTIVE_THEME == "Classic" then input.Font = Enum.Font.Arial; make("UIStroke", {Color=Color3.fromRGB(128,128,128), Thickness=1}, input) end; addTextConstraint(input,4,getScale())
            input.FocusLost:Connect(function(enter) if type(opts.Callback)=="function" then task.spawn(opts.Callback,input.Text,enter) end end)
            return {Frame=frame,Input=input,GetValue=function() return input.Text end,SetValue=function(_,v) input.Text=tostring(v) end}
        end

        function tab:CreateDropdown(opts)
            opts=opts or {}; local frame=component("Dropdown",rowHeight()); componentName(frame,opts.Name or "Dropdown",100)
            local optionsList=opts.Options or {}
            local chosen=tostring(opts.CurrentOption or optionsList[1] or "Select")
            local function closedText() return chosen end
            local function openedText() return chosen end
            local drop=make("TextButton",{Name="Select",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-5,.5,0),Size=UDim2.new(0,116,0,controlHeight()),BackgroundColor3=controlColor(),BorderSizePixel=0,Text=closedText(),TextColor3=COLORS.Text,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=4},frame)
            round(drop,cornerRadius(5,0)); if ACTIVE_THEME == "Classic" then drop.Font = Enum.Font.Arial; make("UIStroke", {Color=Color3.fromRGB(128,128,128), Thickness=1}, drop) end; addTextConstraint(drop,4,getScale())
            make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,17)},drop)
            local arrow=make("TextLabel",{Name="DropdownArrow",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-2,.5,0),Size=UDim2.new(0,12,0,20),BackgroundTransparency=1,Text="v",Rotation=0,TextColor3=COLORS.Text,Font=ACTIVE_THEME=="Classic" and Enum.Font.ArialBold or Enum.Font.GothamBold,TextSize=14,TextScaled=false,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=5},drop)
            local popup
            local popupTween
            local function closePopup()
                if popup then
                    local oldPopup = popup
                    popup = nil
                    if popupTween then pcall(function() popupTween:Cancel() end); popupTween=nil end
                    local closeTween = TweenService:Create(oldPopup, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        Size = UDim2.new(oldPopup.Size.X.Scale, oldPopup.Size.X.Offset, 0, 0),
                        Position = oldPopup.Position - UDim2.fromOffset(0, 4),
                    })
                    closeTween:Play()
                    closeTween.Completed:Connect(function() if oldPopup.Parent then oldPopup:Destroy() end end)
                end
                drop.Text=closedText()
                arrow.Text="v"
                arrow.Rotation=0
            end
            local function choose(value)
                chosen=tostring(value); closePopup()
                if type(opts.Callback)=="function" then task.spawn(opts.Callback,value) end
            end
            local function openPopup()
                if popup then closePopup(); return end
                if #optionsList==0 then return end
                local rowH=math.max(30,controlHeight())
                local totalRows=math.ceil(#optionsList/2)
                local visibleRows=math.min(totalRows,3)
                local camera=workspace.CurrentCamera
                local viewport=camera and camera.ViewportSize or Vector2.new(800,600)
                local popupWidth=math.min(math.max(200,drop.AbsoluteSize.X),math.max(180,viewport.X-8))
                local screenX=math.clamp(drop.AbsolutePosition.X,4,math.max(4,viewport.X-popupWidth-4))
                local screenY=drop.AbsolutePosition.Y+drop.AbsoluteSize.Y+2
                local targetPosition=UDim2.fromOffset(screenX,screenY)
                local popupHeight=visibleRows*rowH+12
                -- Parent the menu to the ScreenGui, not the scrolling tab. This anchors it directly below the dropdown control and prevents it appearing at the top of the tab.
                popup=make("Frame",{Name="DropdownOptions",Position=targetPosition-UDim2.fromOffset(0,7),Size=UDim2.new(0,popupWidth,0,0),BackgroundColor3=popupColor(),BorderSizePixel=ACTIVE_THEME=="Classic" and 1 or 0,ZIndex=200,ClipsDescendants=true},gui)
                round(popup,cornerRadius(6,0)); make("UIStroke",{Color=COLORS.Line,Thickness=1,Transparency=ACTIVE_THEME=="Classic" and 0 or 0.15},popup)
                local list=make("ScrollingFrame",{Name="Options",Position=UDim2.new(0,5,0,5),Size=UDim2.new(1,-10,1,-10),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollingDirection=Enum.ScrollingDirection.Y,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),ZIndex=201},popup)
                local grid=make("UIGridLayout",{Name="TwoLaneLayout",CellSize=UDim2.new(0.5,-3,0,rowH),CellPadding=UDim2.new(0,4,0,4),SortOrder=Enum.SortOrder.LayoutOrder},list)
                for i,value in ipairs(optionsList) do
                    local item=make("TextButton",{Name="Option",LayoutOrder=i,Text=tostring(value),TextColor3=(ACTIVE_THEME=="Classic" and tostring(value)==chosen) and Color3.fromRGB(255,255,255) or COLORS.Text,Font=classicFont(),TextSize=getScale(),TextScaled=true,TextTruncate=Enum.TextTruncate.AtEnd,BackgroundColor3=tostring(value)==chosen and COLORS.TabSelected or COLORS.Tab,BorderSizePixel=0,AutoButtonColor=false,ZIndex=202},list)
                    round(item,cornerRadius(4,0)); if ACTIVE_THEME=="Classic" then make("UIStroke",{Color=Color3.fromRGB(128,128,128),Thickness=1},item) end; make("UIPadding",{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,3)},item); addTextConstraint(item,4,getScale())
                    item.MouseButton1Click:Connect(function() choose(value) end)
                end
                local function updateCanvas()
                    list.CanvasSize=UDim2.new(0,0,0,grid.AbsoluteContentSize.Y+2)
                end
                grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
                updateCanvas()
                drop.Text=openedText()
                arrow.Text="^"
                arrow.Rotation=0
                popupTween = TweenService:Create(popup, TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = targetPosition,
                    Size = UDim2.new(0,popupWidth,0,popupHeight),
                })
                popupTween:Play()
            end
            drop.MouseButton1Click:Connect(openPopup)
            tabPage:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                if popup then closePopup() end
            end)
            return {Frame=frame,GetValue=function() return chosen end,SetValue=function(_,v) chosen=tostring(v); drop.Text=popup and openedText() or closedText() end,Open=openPopup,Close=closePopup}
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
            local button = make("TextButton", {Name="KeyButton", AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-6,.5,0), Size=UDim2.new(0,100,0,controlHeight()), BackgroundColor3=controlColor(), BorderSizePixel=0, Text=current.Name, TextColor3=COLORS.Text, Font=Enum.Font.Gotham, TextSize=getScale(), TextScaled=true, AutoButtonColor=false}, frame)
            round(button,cornerRadius(5,0)); if ACTIVE_THEME=="Classic" then button.Font=Enum.Font.Arial; make("UIStroke",{Color=Color3.fromRGB(128,128,128),Thickness=1},button) end; addTextConstraint(button,4,getScale())
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
            local button=make("TextButton",{Name="MultiSelectButton",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-5,.5,0),Size=UDim2.new(0,94,0,21),BackgroundColor3=controlColor(),BorderSizePixel=0,Text=selectedText().." ▾",TextColor3=COLORS.Text,Font=classicFont(),TextSize=getScale(),TextScaled=true,TextTruncate=Enum.TextTruncate.AtEnd,AutoButtonColor=false,ZIndex=4},frame)
            round(button,cornerRadius(5,0)); if ACTIVE_THEME=="Classic" then button.Font=Enum.Font.Arial; make("UIStroke",{Color=Color3.fromRGB(128,128,128),Thickness=1},button) end; addTextConstraint(button,4,getScale())
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
                        if child:IsA("TextButton") and child:GetAttribute("OptionValue")==key then child.Text=(selected[key] and "✓  " or "   ")..key; child.BackgroundColor3=selected[key] and COLORS.TabSelected or COLORS.Tab; child.TextColor3=(ACTIVE_THEME=="Classic" and selected[key]) and Color3.fromRGB(255,255,255) or COLORS.Text end
                    end
                    button.Text=selectedText().." ▴"
                end
            end
            local function openPopup()
                if popup then closePopup(); return end
                if #available==0 then return end
                local rowH=24; local maxRows=math.min(#available,7)
                popup=make("Frame",{Name="MultiDropdownOptions",Position=UDim2.new(0,frame.AbsolutePosition.X-tabPage.AbsolutePosition.X,0,frame.AbsolutePosition.Y-tabPage.AbsolutePosition.Y+frame.AbsoluteSize.Y+2),Size=UDim2.new(0,math.max(94,button.AbsoluteSize.X),0,rowH*maxRows),BackgroundColor3=popupColor(),BorderSizePixel=ACTIVE_THEME=="Classic" and 1 or 0,ZIndex=60},tabPage)
                round(popup,cornerRadius(6,0)); make("UIStroke",{Color=COLORS.Line,Thickness=1,Transparency=ACTIVE_THEME=="Classic" and 0 or 0.15},popup)
                local list=make("ScrollingFrame",{Name="Options",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(0,0,0,#available*rowH),ZIndex=61},popup)
                for i,value in ipairs(available) do
                    local key=tostring(value); local on=selected[key]==true
                    local item=make("TextButton",{Name="Option",Text=(on and "✓  " or "   ")..key,TextColor3=(ACTIVE_THEME=="Classic" and on) and Color3.fromRGB(255,255,255) or COLORS.Text,Font=classicFont(),TextSize=getScale(),TextScaled=true,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,0,0,(i-1)*rowH),Size=UDim2.new(1,-2,0,rowH),BackgroundColor3=on and COLORS.TabSelected or COLORS.Tab,BorderSizePixel=0,AutoButtonColor=false,ZIndex=62},list)
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
                local box=make("TextBox",{Name=channel,Position=UDim2.new((i-1)/3,0,0,0),Size=UDim2.new(1/3,-3,1,0),BackgroundColor3=controlColor(),BorderSizePixel=0,Text="0",TextColor3=COLORS.Text,Font=Enum.Font.Gotham,TextSize=getScale(),TextScaled=true,ClearTextOnFocus=false},rgb); round(box,3); addTextConstraint(box,4,getScale()); boxes[i]=box
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
            local manager=getNotificationManager(gui)
            if not manager then return nil end
            return manager.Show(opts or {})
        end

        return tab
    end

    local function collapse()
        if not root.Visible then return end
        root.Visible=false
        restore.Visible=true
        restore.Position=UDim2.new(0,14,0.5,-22)
    end
    minimize.MouseButton1Click:Connect(collapse)
    local function destroyWindowUI()
        if modernDecorationConnection then modernDecorationConnection:Disconnect(); modernDecorationConnection = nil end
        -- Explicit cleanup protects against any orphaned aura/resize hint instances.
        for _, name in ipairs({"ZynzAuraOuter", "ZynzAuraInner", "ZynzModernAuraOuter", "ZynzModernAuraInner", "ResizeDirectionHint"}) do
            local orphan = gui and gui:FindFirstChild(name, true)
            if orphan then orphan:Destroy() end
        end
        if activeArrow then activeArrow:Destroy(); activeArrow = nil end
        if restoreGui and restoreGui.Parent then restoreGui:Destroy() end
        if gui and gui.Parent then gui:Destroy() end
    end
    local confirmDialog
    local function showCloseConfirmation()
        if confirmDialog and confirmDialog.Parent then return end
        confirmDialog = make("Frame", {
            Name = "CloseConfirmation", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 260, 0, 138),
            BackgroundColor3 = COLORS.Window, BorderSizePixel = 0, ZIndex = 500,
        }, gui)
        round(confirmDialog, cornerRadius(12, 0))
        make("UIStroke", {Color = ACTIVE_THEME == "Bloody" and BLOOD_BRIGHT or COLORS.Accent, Thickness = ACTIVE_THEME == "Classic" and 2 or 1.5, Transparency = 0.05}, confirmDialog)
        if ACTIVE_THEME == "Bloody" then addBloodSplatter(confirmDialog, "Confirm", 8, 501) end
        local titleText = "Are You Sure Want To Delete Zynz?"
        local prompt = label(confirmDialog, titleText, {
            Name = "ConfirmTitle", Position = UDim2.new(0, 12, 0, 15),
            Size = UDim2.new(1, -24, 0, 42), TextXAlignment = Enum.TextXAlignment.Center,
            TextColor3 = COLORS.Text, MaxTextSize = 18, MinTextSize = 10,
        })
        prompt.ZIndex = 501
        local detail = label(confirmDialog, "This action cannot be undone.", {
            Name = "ConfirmDescription", Position = UDim2.new(0, 12, 0, 55),
            Size = UDim2.new(1, -24, 0, 20), TextXAlignment = Enum.TextXAlignment.Center,
            TextColor3 = COLORS.Muted, MaxTextSize = 12, MinTextSize = 8,
        })
        detail.ZIndex = 501
        local buttonY = 96
        local yes = make("TextButton", {
            Name = "Yes", Text = "Yes", Font = ACTIVE_THEME == "Classic" and Enum.Font.ArialBold or Enum.Font.GothamBold,
            TextSize = 14, TextColor3 = COLORS.Text, BackgroundColor3 = ACTIVE_THEME == "Halloween" and Color3.fromRGB(145, 54, 31) or ((ACTIVE_THEME == "Christmas" or ACTIVE_THEME == "Bloody") and Color3.fromRGB(157, 20, 38) or COLORS.Accent),
            BorderSizePixel = 0, Position = UDim2.new(0, 18, 0, buttonY), Size = UDim2.new(0.5, -24, 0, 34), ZIndex = 501,
        }, confirmDialog)
        round(yes, cornerRadius(7, 0))
        if ACTIVE_THEME == "Classic" then yes.TextColor3 = Color3.new(1,1,1) end
        local no = make("TextButton", {
            Name = "No", Text = "No", Font = ACTIVE_THEME == "Classic" and Enum.Font.ArialBold or Enum.Font.GothamBold,
            TextSize = 14, TextColor3 = COLORS.Text, BackgroundColor3 = COLORS.Component,
            BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, buttonY), Size = UDim2.new(0.5, -24, 0, 34), ZIndex = 501,
        }, confirmDialog)
        round(no, cornerRadius(7, 0))
        make("UIStroke", {Color = COLORS.Line, Thickness = 1, Transparency = 0.3}, yes)
        make("UIStroke", {Color = COLORS.Line, Thickness = 1, Transparency = 0.3}, no)
        no.Activated:Connect(function()
            if confirmDialog then confirmDialog:Destroy(); confirmDialog = nil end
        end)
        yes.Activated:Connect(function()
            destroyWindowUI()
        end)
    end
    close.MouseButton1Click:Connect(showCloseConfirmation)
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
                self._initialTabNeutral=false
                for _, other in ipairs(self._tabs) do
                    other.Page.Visible=false
                    other.Button.BackgroundColor3=COLORS.Component
                    other.Button.TextColor3=COLORS.Text
                    local st=other.Button:FindFirstChildOfClass("UIStroke")
                    if st then st.Color=COLORS.Line; st.Transparency=0.42; st.Thickness=1 end
                    local mark=other.Button:FindFirstChild("ActiveMark")
                    if mark then mark.Visible=false end
                end
                item.Page.Visible=true
                item.Button.BackgroundColor3=(ACTIVE_THEME=="Classic" or ACTIVE_THEME=="Bloody") and COLORS.TabSelected or COLORS.Accent
                item.Button.TextColor3=(ACTIVE_THEME=="Classic" or ACTIVE_THEME=="Bloody") and Color3.fromRGB(255,255,255) or Color3.fromRGB(18,18,24)
                local st=item.Button:FindFirstChildOfClass("UIStroke")
                if st then st.Color=COLORS.Accent; st.Transparency=0.08; st.Thickness=1.5 end
                local mark=item.Button:FindFirstChild("ActiveMark")
                if mark then mark.Visible=true end
                self._active=item; return true
            end
        end
        return false
    end
    function window:Destroy()
        destroyWindowUI()
    end
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

Zynz.Version = "2.7.0-multi-theme-runtime-switch"
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
    local gui=(gethui and gethui()) or (LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    if not gui then return nil end
    local manager=getNotificationManager(gui)
    if not manager then return nil end
    return manager.Show(options)
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

Zynz = setmetatable({}, Zynz)

-- Return the library object for loadstring(... )().
return Zynz
