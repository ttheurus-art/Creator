--[[
    Singularity UI Library v7.1.0
    Original UI library
    Theme: Blue Glass / Singularity V7.1
    Mobile + PC focused
]]

local Singularity = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local CurrentWindow = nil
local Gui = nil

local Theme = {
    Background = Color3.fromRGB(5, 12, 24),
    Secondary = Color3.fromRGB(8, 21, 39),
    Tertiary = Color3.fromRGB(13, 34, 58),
    Hover = Color3.fromRGB(18, 48, 82),

    Accent = Color3.fromRGB(55, 158, 255),
    AccentDark = Color3.fromRGB(25, 91, 180),

    Text = Color3.fromRGB(239, 247, 255),
    SubText = Color3.fromRGB(150, 183, 219),
    Muted = Color3.fromRGB(83, 119, 157),
    Stroke = Color3.fromRGB(30, 76, 120),

    Success = Color3.fromRGB(91, 220, 145),
    Danger = Color3.fromRGB(235, 85, 105),
    Warning = Color3.fromRGB(245, 190, 75)
}

local WindowClass = {}
WindowClass.__index = WindowClass

local TabClass = {}
TabClass.__index = TabClass

local function Create(className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function Corner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function Stroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Stroke
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.15
    stroke.Parent = object
    return stroke
end

local function Padding(object, left, right, top, bottom)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = object
    return padding
end

local function Tween(object, time, properties)
    if not object or not object.Parent then
        return
    end

    local tween = TweenService:Create(
        object,
        TweenInfo.new(time or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )

    tween:Play()
    return tween
end

local function GetParent()
    local ok = pcall(function()
        return CoreGui.Name
    end)

    if ok then
        return CoreGui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local function CreateText(parent, text, size, color)
    return Create("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = color or Theme.Text,
        TextSize = size or 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
end

local function MakeDraggable(handle, object, state)
    local dragging = false
    local dragStart
    local startPosition
    state = state or {Enabled = true}

    handle.InputBegan:Connect(function(input)
        if not state.Enabled then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = object.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not state.Enabled or not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        object.Position = UDim2.new(

                    startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)

    return state
end

local function AddPressAnimation(button)
    button.MouseEnter:Connect(function()
        Tween(button, 0.12, {BackgroundColor3 = Theme.Hover})
    end)

    button.MouseLeave:Connect(function()
        Tween(button, 0.12, {BackgroundColor3 = Theme.Secondary})
    end)
end

local function ClampNumber(value, min, max)
    return math.clamp(value, min, max)
end

local function RoundToStep(value, step)
    if not step or step <= 0 then
        return value
    end

    return math.floor((value / step) + 0.5) * step
end

local function Notify(title, content, duration)
    if not Gui or not Gui.Parent then
        return
    end

    local holder = Gui:FindFirstChild("Notifications")

    if not holder then
        holder = Create("Frame", {
            Name = "Notifications",
            Parent = Gui,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -16, 0, 16),
            Size = UDim2.new(0, 320, 1, -32)
        })

        local layout = Create("UIListLayout", {
            Parent = holder,
            Padding = UDim.new(0, 11),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    end

    local notification = Create("Frame", {
        Parent = holder,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, 0, 0, 70),
        ClipsDescendants = true
    })

    Corner(notification, 10)
    Stroke(notification)

    local accent = Create("Frame", {
        Parent = notification,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 3, 1, 0)
    })

    Corner(accent, 3)

    local titleLabel = CreateText(notification, title or "Singularity", 14, Theme.Text)
    titleLabel.Position = UDim2.new(0, 15, 0, 7)
    titleLabel.Size = UDim2.new(1, -25, 0, 23)
    titleLabel.Font = Enum.Font.GothamBold

    local contentLabel = CreateText(notification, content or "", 11, Theme.SubText)
    contentLabel.Position = UDim2.new(0, 15, 0, 30)
    contentLabel.Size = UDim2.new(1, -25, 0, 30)
    contentLabel.TextWrapped = true

    notification.Position = UDim2.new(1, 30, 0, 0)
    Tween(notification, 0.3, {
        Position = UDim2.new(0, 0, 0, 0)
    })

    task.delay(duration or 2, function()
        if not notification or not notification.Parent then
            return
        end

        Tween(notification, 0.25, {
            Position = UDim2.new(1, 30, 0, 0)
        })

        task.wait(0.3)

        if notification then
            notification:Destroy()
        end
    end)
end

Singularity.Notify = Notify

function TabClass:CreateSection(text)
    local section = Create("TextLabel", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 0, 28),
        Text = text or "Section",
        TextColor3 = Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return section
end

function TabClass:CreateParagraph(data)
    data = data or {}

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, -12, 0, 72),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    Corner(holder, 16)
    Stroke(holder)

    local title = CreateText(holder, data.Title or "Information", 13, Theme.Text)
    title.Position = UDim2.new(0, 13, 0, 7)
    title.Size = UDim2.new(1, -26, 0, 22)
    title.Font = Enum.Font.GothamBold

    local content = CreateText(holder, data.Content or "", 11, Theme.SubText)
    content.Position = UDim2.new(0, 13, 0, 30)
    content.Size = UDim2.new(1, -26, 0, 32)
    content.TextWrapped = true
    content.TextYAlignment = Enum.TextYAlignment.Top

    return {
        Holder = holder,
        Title = title,
        Content = content
    }
end

function TabClass:CreateButton(data)
    data = data or {}

      local button = Create("TextButton", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.10,
        Size = UDim2.new(1, -12, 0, 48),
        Text = data.Name or "Button",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        ClipsDescendants = true
    })

    Corner(button, 9)
    Stroke(button)
    AddPressAnimation(button)

    button.Activated:Connect(function()
        if typeof(data.Callback) == "function" then
            task.spawn(data.Callback)
        end
    end)

    return button
end

function TabClass:CreateToggle(data)
    data = data or {}

    local value = data.CurrentValue == true

    local holder = Create("TextButton", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.10,
        Size = UDim2.new(1, -12, 0, 50),
        Text = "",
        AutoButtonColor = false
    })

    Corner(holder, 16)
    Stroke(holder)

    local label = CreateText(holder, data.Name or "Toggle", 13, Theme.Text)
    label.Position = UDim2.new(0, 13, 0, 0)
    label.Size = UDim2.new(1, -80, 1, 0)

    local switch = Create("Frame", {
        Parent = holder,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(1, -55, 0.5, -11),
        Size = UDim2.new(0, 42, 0, 22)
    })

    Corner(switch, 11)

    local knob = Create("Frame", {
        Parent = switch,
        BackgroundColor3 = Theme.Muted,
        Position = UDim2.new(0, 3, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16)
    })

    Corner(knob, 8)

    local function SetValue(newValue, callCallback)
        value = newValue == true

        if value then
            Tween(switch, 0.16, {BackgroundColor3 = Theme.AccentDark})
            Tween(knob, 0.16, {
                BackgroundColor3 = Theme.Accent,
                Position = UDim2.new(1, -19, 0.5, -8)
            })
        else
            Tween(switch, 0.16, {BackgroundColor3 = Theme.Tertiary})
            Tween(knob, 0.16, {
                BackgroundColor3 = Theme.Muted,
                Position = UDim2.new(0, 3, 0.5, -8)
            })
        end

        if callCallback ~= false and typeof(data.Callback) == "function" then
            task.spawn(data.Callback, value)
        end
    end

    holder.Activated:Connect(function()
        SetValue(not value, true)
    end)

    SetValue(value, false)

    return {
        Holder = holder,
        Set = function(_, newValue)
            SetValue(newValue, true)
        end,
        Get = function()
            return value
        end
    }
end

function TabClass:CreateSlider(data)
    data = data or {}

    local min = tonumber(data.Range and data.Range[1]) or 0
    local max = tonumber(data.Range and data.Range[2]) or 100

    if max < min then
        min, max = max, min
    end

    local step = tonumber(data.Increment or data.Step) or 1
    local value = tonumber(data.CurrentValue)
    value = value or min
    value = ClampNumber(value, min, max)
    value = RoundToStep(value, step)

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, -12, 0, 72),
        ClipsDescendants = false
    })

    Corner(holder, 16)
    Stroke(holder)

    local label = CreateText(holder, data.Name or "Slider", 13, Theme.Text)
    label.Position = UDim2.new(0, 13, 0, 7)
    label.Size = UDim2.new(1, -80, 0, 22)

    local valueLabel = CreateText(holder, tostring(value), 12, Theme.Accent)
    valueLabel.Position = UDim2.new(1, -65, 0, 7)
    valueLabel.Size = UDim2.new(0, 52, 0, 22)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Create("Frame", {
        Parent = holder,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(0, 13, 0, 46),
        Size = UDim2.new(1, -26, 0, 6)
    })

    Corner(bar, 3)

    local fill = Create("Frame", {
        Parent = bar,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0)
    })

    Corner(fill, 3)

    local knob = Create("Frame", {
        Parent = bar,
        BackgroundColor3 = Theme.Text,
        AnchorPoint = Vector2.new(0.5, 0.5),

              Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14)
    })

    Corner(knob, 7)

    local dragging = false

    local function UpdateFromX(x, callCallback)
        local width = math.max(bar.AbsoluteSize.X, 1)
        local percent = ClampNumber((x - bar.AbsolutePosition.X) / width, 0, 1)

        local newValue = min + ((max - min) * percent)
        newValue = RoundToStep(newValue, step)
        newValue = ClampNumber(newValue, min, max)

        value = newValue

        local normalized = 0
        if max ~= min then
            normalized = (value - min) / (max - min)
        end

        fill.Size = UDim2.new(normalized, 0, 1, 0)
        knob.Position = UDim2.new(normalized, 0, 0.5, 0)
        valueLabel.Text = tostring(value)

        if callCallback ~= false and typeof(data.Callback) == "function" then
            task.spawn(data.Callback, value)
        end
    end

    local function Begin(input)
        dragging = true
        UpdateFromX(input.Position.X, true)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Begin(input)
        end
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Begin(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            UpdateFromX(input.Position.X, true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    task.defer(function()
        UpdateFromX(
            bar.AbsolutePosition.X
                + bar.AbsoluteSize.X
                * ((value - min) / math.max(max - min, 1)),
            false
        )
    end)

    return {
        Holder = holder,
        Set = function(_, newValue)
            UpdateFromX(
                bar.AbsolutePosition.X
                    + bar.AbsoluteSize.X
                    * ((ClampNumber(tonumber(newValue) or min, min, max) - min)
                    / math.max(max - min, 1)),
                true
            )
        end,
        Get = function()
            return value
        end
    }
end

function TabClass:CreateDropdown(data)
    data = data or {}

    local options = data.Options or {}
    local selected = data.CurrentOption or options[1]
    local opened = false

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.10,
        Size = UDim2.new(1, -12, 0, 50),
        ClipsDescendants = true
    })

    Corner(holder, 16)
    Stroke(holder)

    local mainButton = Create("TextButton", {
        Parent = holder,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 48),
        Text = "",
        AutoButtonColor = false
    })

    local label = CreateText(holder, data.Name or "Dropdown", 13, Theme.Text)
    label.Position = UDim2.new(0, 13, 0, 0)
    label.Size = UDim2.new(0.45, 0, 0, 48)

    local selectedLabel = CreateText(holder, tostring(selected or "Select"), 12, Theme.SubText)
    selectedLabel.Position = UDim2.new(0.45, 0, 0, 0)
    selectedLabel.Size = UDim2.new(0.45, -10, 0, 48)
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right

    local arrow = CreateText(holder, "⌄", 16, Theme.Accent)
    arrow.Position = UDim2.new(1, -35, 0, 0)
    arrow.Size = UDim2.new(0, 25, 0, 48)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    local optionHolder = Create("Frame", {
        Parent = holder,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 52),
        Size = UDim2.new(1, -20, 0, 0),
        ClipsDescendants = true
    })

    local optionLayout = Create("UIListLayout", {
        Parent = optionHolder,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local function Rebuild()
        for _, child in ipairs(optionHolder:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for index, option in ipairs(options) do
            local optionButton = Create("TextButton", {
                Parent = optionHolder,

                          BackgroundColor3 = Theme.Tertiary,
                Size = UDim2.new(1, 0, 0, 36),
                Text = tostring(option),
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false,
                LayoutOrder = index
            })

            Corner(optionButton, 7)

            optionButton.Activated:Connect(function()
                selected = option
                selectedLabel.Text = tostring(option)
                opened = false
                arrow.Text = "⌄"

                local height = math.max(0, optionLayout.AbsoluteContentSize.Y)
                Tween(optionHolder, 0.18, {
                    Size = UDim2.new(1, -20, 0, 0)
                })

                Tween(holder, 0.18, {
                    Size = UDim2.new(1, -12, 0, 48)
                })

                if typeof(data.Callback) == "function" then
                    task.spawn(data.Callback, option)
                end
            end)
        end
    end

    mainButton.Activated:Connect(function()
        opened = not opened
        arrow.Text = opened and "⌃" or "⌄"

        if opened then
            local height = optionLayout.AbsoluteContentSize.Y
            Tween(optionHolder, 0.2, {
                Size = UDim2.new(1, -20, 0, height)
            })
            Tween(holder, 0.2, {
                Size = UDim2.new(1, -12, 0, 58 + height)
            })
        else
            Tween(optionHolder, 0.18, {
                Size = UDim2.new(1, -20, 0, 0)
            })
            Tween(holder, 0.18, {
                Size = UDim2.new(1, -12, 0, 48)
            })
        end
    end)

    Rebuild()

    return {
        Holder = holder,
        Set = function(_, option)
            for _, item in ipairs(options) do
                if item == option then
                    selected = option
                    selectedLabel.Text = tostring(option)
                    if typeof(data.Callback) == "function" then
                        task.spawn(data.Callback, option)
                    end
                    break
                end
            end
        end,
        Get = function()
            return selected
        end
    }
end

function TabClass:CreateKeybind(data)
    data = data or {}

    local current = data.CurrentKey or data.Key or "None"
    local listening = false

    local holder = Create("TextButton", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.10,
        Size = UDim2.new(1, -12, 0, 50),
        Text = "",
        AutoButtonColor = false
    })

    Corner(holder, 16)
    Stroke(holder)

    local label = CreateText(holder, data.Name or "Keybind", 13, Theme.Text)
    label.Position = UDim2.new(0, 13, 0, 0)
    label.Size = UDim2.new(1, -125, 1, 0)

    local keyLabel = CreateText(holder, tostring(current), 11, Theme.Accent)
    keyLabel.Position = UDim2.new(1, -110, 0, 0)
    keyLabel.Size = UDim2.new(0, 95, 1, 0)
    keyLabel.TextXAlignment = Enum.TextXAlignment.Right

    holder.Activated:Connect(function()
        listening = true
        keyLabel.Text = "Press key"
    end)

    local connection = UserInputService.InputBegan:Connect(function(input, processed)
        if not listening or processed then
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            current = input.KeyCode.Name
            listening = false
            keyLabel.Text = current

            if typeof(data.Callback) == "function" then
                task.spawn(data.Callback, input.KeyCode)
            end
        end
    end)

    return {
        Holder = holder,
        Set = function(_, key)
            current = key
            keyLabel.Text = tostring(key)
        end,
        Get = function()
            return current
        end,
        Destroy = function()
            connection:Disconnect()
            holder:Destroy()
        end
    }
end

function TabClass:CreateColorPicker(data)
    data = data or {}

    local colors = data.Colors or {
        Color3.fromRGB(145, 75, 255),
        Color3.fromRGB(80, 150, 255),
        Color3.fromRGB(75, 220, 180),
        Color3.fromRGB(100, 220, 110),
        Color3.fromRGB(245, 190, 75),
        Color3.fromRGB(245, 120, 80),
        Color3.fromRGB(235, 85, 105),
        Color3.fromRGB(220, 100, 220),
        Color3.fromRGB(245, 245, 245)
    }

    local index = 1
    local current = data.Color or colors[1]

      for i, color in ipairs(colors) do
        if color == current then
            index = i
            break
        end
    end

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.10,
        Size = UDim2.new(1, -12, 0, 50),
        ClipsDescendants = true
    })

    Corner(holder, 16)
    Stroke(holder)

    local label = CreateText(holder, data.Name or "Color", 13, Theme.Text)
    label.Position = UDim2.new(0, 13, 0, 0)
    label.Size = UDim2.new(1, -75, 1, 0)

    local colorButton = Create("TextButton", {
        Parent = holder,
        BackgroundColor3 = current,
        Position = UDim2.new(1, -57, 0.5, -13),
        Size = UDim2.new(0, 42, 0, 26),
        Text = "",
        AutoButtonColor = false
    })

    Corner(colorButton, 13)

    colorButton.Activated:Connect(function()
        index += 1

        if index > #colors then
            index = 1
        end

        current = colors[index]
        colorButton.BackgroundColor3 = current

        if typeof(data.Callback) == "function" then
            task.spawn(data.Callback, current)
        end
    end)

    return {
        Holder = holder,
        Set = function(_, color)
            current = color
            colorButton.BackgroundColor3 = color

            if typeof(data.Callback) == "function" then
                task.spawn(data.Callback, color)
            end
        end,
        Get = function()
            return current
        end
    }
end

function TabClass:CreateTextBox(data)
    data = data or {}

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.10,
        Size = UDim2.new(1, -12, 0, data.Height or 170),
        ClipsDescendants = true
    })

    Corner(holder, 16)
    Stroke(holder)

    local label = CreateText(holder, data.Name or "Editor", 13, Theme.Text)
    label.Position = UDim2.new(0, 13, 0, 8)
    label.Size = UDim2.new(1, -26, 0, 22)
    label.Font = Enum.Font.GothamBold

    local box = Create("TextBox", {
        Parent = holder,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.18,
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(1, -24, 1, -48),
        ClearTextOnFocus = false,
        MultiLine = true,
        Text = data.Text or "",
        PlaceholderText = data.PlaceholderText or "Paste Luau here...",
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Muted,
        TextSize = data.TextSize or 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = false,
        ClearTextOnFocus = false
    })
    Corner(box, 12)
    Stroke(box, Theme.Stroke, 1)
    Padding(box, 10, 10, 9, 9)

    return {
        Holder = holder,
        TextBox = box,
        Set = function(_, text)
            box.Text = tostring(text or "")
        end,
        Get = function()
            return box.Text
        end,
        Clear = function()
            box.Text = ""
        end
    }
end

function WindowClass:CreateTab(data)
    data = data or {}

    local tabName = data.Name or "Tab"

    local tabButton = Create("TextButton", {
        Parent = self.TabButtons,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, -12, 0, 44),
        Text = "",
        AutoButtonColor = false
    })

    Corner(tabButton, 16)
    Stroke(tabButton, Theme.Stroke, 1)

    local indicator = Create("Frame", {
        Parent = tabButton,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, 0, 0.5, -9),
        Size = UDim2.new(0, 3, 0, 18),
        Visible = false
    })

    Corner(indicator, 2)

    local icon = nil

    if data.Icon then
        icon = CreateText(tabButton, "●", 9, Theme.Muted)
        icon.Position = UDim2.new(0, 12, 0, 0)
        icon.Size = UDim2.new(0, 16, 1, 0)
        icon.TextXAlignment = Enum.TextXAlignment.Center
    end

    local text = CreateText(tabButton, tabName, 12, Theme.SubText)
    text.Position = UDim2.new(0, data.Icon and 31 or 16, 0, 0)
    text.Size = UDim2.new(1, -45, 1, 0)

  
    local container = Create("ScrollingFrame", {
        Parent = self.Pages,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.15,
        ClipsDescendants = true,
        Visible = false
    })

    Padding(container, 10, 10, 12, 16)

    local layout = Create("UIListLayout", {
        Parent = container,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local tab = setmetatable({
        Window = self,
        Name = tabName,
        Button = tabButton,
        Indicator = indicator,
        Text = text,
        Container = container,
        Layout = layout
    }, TabClass)

    table.insert(self.Tabs, tab)

    tabButton.Activated:Connect(function()
        self:SelectTab(tab)
    end)

    if #self.Tabs == 1 and not data.IsSettings then
        self:SelectTab(tab)
    elseif self.SelectedTab == nil and not data.IsSettings then
        self:SelectTab(tab)
    end

    return tab
end

function WindowClass:SelectTab(tab)
    for _, other in ipairs(self.Tabs) do
        local active = other == tab

        other.Container.Visible = active
        other.Indicator.Visible = active

        if active then
            Tween(other.Button, 0.15, {
                BackgroundColor3 = Theme.Tertiary
            })
            Tween(other.Text, 0.15, {
                TextColor3 = Theme.Text
            })
        else
            Tween(other.Button, 0.15, {
                BackgroundColor3 = Theme.Secondary
            })
            Tween(other.Text, 0.15, {
                TextColor3 = Theme.SubText
            })
        end
    end

    self.SelectedTab = tab
end

function WindowClass:_UpdateResponsiveSize()
    local camera = workspace.CurrentCamera
    if not camera or self.Destroyed then
        return
    end

    local viewport = camera.ViewportSize
    local width = math.clamp(viewport.X * 0.86, 330, 760)
    local height = math.clamp(width * (5 / 7.6), 300, 500)

    if viewport.X < 560 then
        width = math.max(320, viewport.X - 20)
        height = math.clamp(width * 0.66, 290, 440)
    end

    self.Main.Size = UDim2.new(0, width, 0, height)
    self:_Center()
end


function WindowClass:_CreateCompact()
    local compact = Create("TextButton", {
        Parent = Gui,
        BackgroundColor3 = Theme.Secondary,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 18, 0.5, 0),
        Size = UDim2.new(0, 135, 0, 48),
        Text = "Singularity",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Visible = false,
        AutoButtonColor = false
    })

    Corner(compact, 12)
    Stroke(compact)

    local dot = Create("Frame", {
        Parent = compact,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, 13, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10)
    })

    Corner(dot, 5)

    compact.TextXAlignment = Enum.TextXAlignment.Center
    compact.Activated:Connect(function()
        self:Open()
    end)

    MakeDraggable(compact, compact)

    self.CompactButton = compact
end

function WindowClass:_Center()
    if not self.Main or not self.Main.Parent then
        return
    end

    local size = self.OriginalSize
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
end

function WindowClass:_AnimateMain(show)
    if show then
        self:_Center()
        self.Main.Visible = true
        self.Main.Size = UDim2.new(0, 0, 0, 0)

        Tween(self.Main, 0.30, {
            Size = self.OriginalSize
        })
    else
        self:_Center()
        Tween(self.Main, 0.22, {
            Size = UDim2.new(0, 0, 0, 0)
        })

        task.delay(0.24, function()

                    if not self.Opened and self.Main then
                self.Main.Visible = false
                self.Main.Size = self.OriginalSize
            end
        end)
    end
end

function WindowClass:_SetFolded(value)
    if self.Destroyed then
        return
    end

    self.Folded = value == true

    if self.Folded then
        -- Rayfield-like Top Fold: keep only the rounded header visible.
        self.Pages.Visible = false
        self.Sidebar.Visible = false
        Tween(self.Main, 0.24, {
            Size = UDim2.new(0, self.OriginalSize.X.Offset, 0, 58)
        })
    else
        self.Pages.Visible = true
        self.Sidebar.Visible = true
        Tween(self.Main, 0.24, {
            Size = self.OriginalSize
        })
    end
end

function WindowClass:_CreateReopenButton()
    local button = Create("TextButton", {
        Parent = Gui,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.10,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 150, 0, 44),
        Text = "Singularity",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Visible = false,
        AutoButtonColor = false
    })

    Corner(button, 14)
    Stroke(button, Theme.Stroke, 1)

    button.Activated:Connect(function()
        self:Open()
    end)

    self.ReopenButton = button
end

function WindowClass:_SetVisible(value)
    value = value == true

    if value then
        self.Opened = true
        self.Minimized = false
        if self.ReopenButton then
            self.ReopenButton.Visible = false
        end
        self:_AnimateMain(true)
    else
        self.Opened = false
        self.Minimized = false
        self:_AnimateMain(false)
        if self.ReopenButton then
            task.delay(0.26, function()
                if self.ReopenButton and not self.Opened then
                    self.ReopenButton.Visible = true
                end
            end)
        end
    end
end

function WindowClass:Close()
    -- "-" is a soft close/minimize: shrink to the center, keep the UI alive.
    if not self.Opened then
        return
    end

    self.Opened = false
    self.Minimized = true
    self:_AnimateMain(false)

    if self.ReopenButton then
        task.delay(0.26, function()
            if self.ReopenButton and self.Minimized then
                self.ReopenButton.Visible = true
            end
        end)
    end
end

function WindowClass:ConfirmDelete()
    if self.Destroyed or self.ConfirmFrame then
        return
    end

    local overlay = Create("Frame", {
        Parent = Gui,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.38,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100
    })

    local box = Create("Frame", {
        Parent = overlay,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.04,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 330, 0, 155),
        ZIndex = 101
    })

    Corner(box, 18)
    Stroke(box, Theme.Stroke, 1)

    local text = CreateText(box, "Are You Sure Delete This?", 15, Theme.Text)
    text.Position = UDim2.new(0, 20, 0, 20)
    text.Size = UDim2.new(1, -40, 0, 30)
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.Font = Enum.Font.GothamBold
    text.ZIndex = 102

    local yes = Create("TextButton", {
        Parent = box,
        BackgroundColor3 = Theme.Danger,
        Position = UDim2.new(0, 20, 1, -58),
        Size = UDim2.new(0.5, -28, 0, 40),
        Text = "Yes",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 102
    })

    local no = Create("TextButton", {
        Parent = box,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(0.5, 8, 1, -58),
        Size = UDim2.new(0.5, -28, 0, 40),
        Text = "No",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 102
    })

    Corner(yes, 12)

      Corner(no, 12)

    yes.Activated:Connect(function()
        self.ConfirmFrame = nil
        overlay:Destroy()
        self:Destroy()
    end)

    no.Activated:Connect(function()
        self.ConfirmFrame = nil
        overlay:Destroy()
    end)

    self.ConfirmFrame = overlay
end

function WindowClass:Open()
    if self.Destroyed then
        return
    end

    self:_SetFolded(false)
    self.Opened = true
    self.Minimized = false

    if self.ReopenButton then
        self.ReopenButton.Visible = false
    end

    -- Always re-center when reopening, even if the user dragged it somewhere random.
    self:_Center()
    self:_AnimateMain(true)
end

function WindowClass:Toggle()
    if self.Opened and not self.Minimized then
        self:Close()
    else
        self:Open()
    end
end

function WindowClass:Minimize()
    self:Close()
end

function WindowClass:Restore()
    self:Open()
end

function WindowClass:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    if self.ConfirmFrame then
        self.ConfirmFrame:Destroy()
        self.ConfirmFrame = nil
    end

    if self.Main then
        self.Main:Destroy()
    end

    if self.ReopenButton then
        self.ReopenButton:Destroy()
    end

    if self.CompactButton then
        self.CompactButton:Destroy()
    end

    if CurrentWindow == self then
        CurrentWindow = nil
    end

    if Gui then
        Gui:Destroy()
        Gui = nil
    end
end

function Singularity:CreateWindow(data)
    data = data or {}

    if Gui then
        Gui:Destroy()
        Gui = nil
    end

    local closeMode = data.CloseMode or "Rayfield"

    Gui = Create("ScreenGui", {
        Name = "SingularityUI",
        Parent = GetParent(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local main = Create("Frame", {
        Parent = Gui,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.10,
        Position = UDim2.new(0.5, -380, 0.5, -250),
        Size = UDim2.new(0, 760, 0, 500),
        ClipsDescendants = true
    })

    Corner(main, 24)
    Stroke(main, Theme.Stroke, 1)

    Create("UIAspectRatioConstraint", {
        Parent = main,
        AspectRatio = 1.52,
        AspectType = Enum.AspectType.FitWithinMaxSize,
        DominantAxis = Enum.DominantAxis.Width
    })

    local topbar = Create("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, 0, 0, 58)
    })

    local logo = Create("Frame", {
        Parent = topbar,
        BackgroundColor3 = Theme.Tertiary,
        BackgroundTransparency = 0.12,
        Position = UDim2.new(0, 12, 0.5, -18),
        Size = UDim2.new(0, 36, 0, 36),
        ZIndex = 2
    })
    Corner(logo, 12)
    Stroke(logo, Theme.Stroke, 1)

    local arrowA = CreateText(logo, "➤", 15, Theme.Accent)
    arrowA.Position = UDim2.new(0, 3, 0, -1)
    arrowA.Size = UDim2.new(0, 16, 0, 18)
    arrowA.Rotation = 0
    arrowA.TextXAlignment = Enum.TextXAlignment.Center
    arrowA.ZIndex = 3

    local arrowB = arrowA:Clone()
    arrowB.Parent = logo
    arrowB.Position = UDim2.new(0, 17, 0, 3)
    arrowB.Rotation = 90

    local arrowC = arrowA:Clone()
    arrowC.Parent = logo
    arrowC.Position = UDim2.new(0, 17, 0, 17)
    arrowC.Rotation = 180

    local arrowD = arrowA:Clone()
    arrowD.Parent = logo
    arrowD.Position = UDim2.new(0, 3, 0, 13)
    arrowD.Rotation = 270

  
    local title = CreateText(topbar, data.Name or "Singularity V7", 15, Theme.Text)
    title.Position = UDim2.new(0, 58, 0, 5)
    title.Size = UDim2.new(1, -145, 0, 24)
    title.Font = Enum.Font.GothamBold

    local subtitle = CreateText(topbar, data.Subtitle or "Original UI Library", 10, Theme.SubText)
    subtitle.Position = UDim2.new(0, 58, 0, 29)
    subtitle.Size = UDim2.new(1, -145, 0, 17)

    local minimize = Create("TextButton", {
        Parent = topbar,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(1, -82, 0.5, -14),
        Size = UDim2.new(0, 30, 0, 28),
        Text = "−",
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    })

    Corner(minimize, 14)

    local close = Create("TextButton", {
        Parent = topbar,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(1, -45, 0.5, -14),
        Size = UDim2.new(0, 30, 0, 28),
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    })

    Corner(close, 14)

    local sidebar = Create("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.06,
        Position = UDim2.new(0, 0, 0, 58),
        Size = UDim2.new(0, 175, 1, -58)
    })

    local tabButtons = Create("ScrollingFrame", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0
    })

    local tabLayout = Create("UIListLayout", {
        Parent = tabButtons,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local pages = Create("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 175, 0, 58),
        Size = UDim2.new(1, -175, 1, -58),
        ClipsDescendants = true
    })

    local window = setmetatable({
        Main = main,
        Topbar = topbar,
        TabButtons = tabButtons,
        Pages = pages,
        Sidebar = sidebar,
        MinimizeButton = minimize,
        CloseButton = close,
        Title = title,
        Subtitle = subtitle,

        Tabs = {},
        SelectedTab = nil,

        Opened = true,
        Minimized = false,
        Destroyed = false,

        CloseMode = closeMode,
        OriginalSize = UDim2.new(0, 760, 0, 500),
        DraggableEnabled = true,
        TopFoldEnabled = false,
        Folded = false
    }, WindowClass)

    CurrentWindow = window

    local dragState = {Enabled = true}
    window.DragState = dragState
    MakeDraggable(topbar, main, dragState)

    close.Activated:Connect(function()
        window:ConfirmDelete()
    end)

    minimize.Activated:Connect(function()
        window:Minimize()
    end)

    MakeDraggable(minimize, minimize, {Enabled = false})

    window:_CreateReopenButton()

    window:_UpdateResponsiveSize()

    local camera = workspace.CurrentCamera

    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if window and not window.Destroyed then
                window:_UpdateResponsiveSize()
            end
        end)
    end

    local settings = window:CreateTab({Name = "Settings", Icon = true, IsSettings = true})
    settings:CreateSection("UI Settings")

    settings:CreateToggle({
        Name = "Visible",
        CurrentValue = true,
        Callback = function(value)
            if window.Destroyed then
                return
            end
            window:_SetVisible(value)
        end
    })

    settings:CreateKeybind({
        Name = "Keybind",
        CurrentKey = data.Keybind or "RightShift",
        Callback = function()
            window:Toggle()
        end
    })

    settings:CreateDropdown({
        Name = "Draggable Mode",
        Options = {"Enabled", "Disabled"},
        CurrentOption = "Enabled",
        Callback = function(option)
            local enabled = option == "Enabled"
            window.DraggableEnabled = enabled
            if window.DragState then
                window.DragState.Enabled = enabled
            end
        end
    })

  
    settings:CreateDropdown({
        Name = "Top Fold",
        Options = {"Enabled", "Disabled"},
        CurrentOption = "Disabled",
        Callback = function(option)
            window.TopFoldEnabled = option == "Enabled"
            if not window.TopFoldEnabled and window.Folded then
                window:_SetFolded(false)
            end
        end
    })

    settings:CreateParagraph({
        Title = "Top Fold",
        Content = "Rayfield-style compact mode. Enable it, then use the small fold button in the top bar to collapse the content into the header."
    })

    -- Dedicated Top Fold control, separated from the drag handle.
    local foldButton = Create("TextButton", {
        Parent = topbar,
        BackgroundColor3 = Theme.Tertiary,
        BackgroundTransparency = 0.18,
        Position = UDim2.new(1, -112, 0.5, -15),
        Size = UDim2.new(0, 32, 0, 30),
        Text = "⌃",
        TextColor3 = Theme.Accent,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 8
    })
    Corner(foldButton, 10)
    Stroke(foldButton, Theme.Stroke, 1)

    foldButton.Activated:Connect(function()
        if window.TopFoldEnabled then
            window:_SetFolded(not window.Folded)
            foldButton.Text = window.Folded and "⌄" or "⌃"
        end
    end)

    local executor = window:CreateTab({Name = "Executor", Icon = true})
    executor:CreateSection("Script Executor")

    local editor = executor:CreateTextBox({
        Name = "Luau Editor",
        Height = 185,
        PlaceholderText = "Paste your Luau script here..."
    })

    local infiniteYieldSource = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()'

    executor:CreateButton({
        Name = "Execute Script",
        Callback = function()
            local source = editor:Get()
            if source == "" then
                Singularity:Notify("Executor", "Editor is empty.", 2)
                return
            end

            local fn, compileError = loadstring(source)
            if not fn then
                Singularity:Notify("Executor Error", tostring(compileError), 3)
                return
            end

            local ok, runtimeError = pcall(function()
                task.spawn(fn)
            end)

            if ok then
                Singularity:Notify("Executor", "Script executed.", 2)
            else
                Singularity:Notify("Executor Error", tostring(runtimeError), 3)
            end
        end
    })

    executor:CreateButton({
        Name = "Execute Infinite Yield",
        Callback = function()
            local fn, compileError = loadstring(infiniteYieldSource)
            if not fn then
                Singularity:Notify("Infinite Yield Error", tostring(compileError), 3)
                return
            end

            local ok, runtimeError = pcall(function()
                task.spawn(fn)
            end)

            if ok then
                Singularity:Notify("Infinite Yield", "Executed successfully.", 2)
            else
                Singularity:Notify("Infinite Yield Error", tostring(runtimeError), 3)
            end
        end
    })

    executor:CreateButton({
        Name = "Clear Editor",
        Callback = function()
            editor:Clear()
        end
    })

    executor:CreateParagraph({
        Title = "Executor",
        Content = "The editor runs Luau through loadstring. Only execute code you trust."
    })

    Singularity:Notify("Enjoy player", "Script executed successfully!", 2)

    return window
end

function Singularity:GetWindow()
    return CurrentWindow
end

function Singularity:Toggle()
    if CurrentWindow then
        CurrentWindow:Toggle()
    end
end

function Singularity:Minimize()
    if CurrentWindow then
        CurrentWindow:Minimize()
    end
end

function Singularity:Restore()
    if CurrentWindow then
        CurrentWindow:Restore()
    end
end

function Singularity:Destroy()
    if CurrentWindow then
        CurrentWindow:Destroy()
    end
end

function Singularity:SetTheme(theme)
    local palettes = {
        Blue = {Background=Color3.fromRGB(5,12,24),Secondary=Color3.fromRGB(8,21,39),Tertiary=Color3.fromRGB(13,34,58),Hover=Color3.fromRGB(18,48,82),Accent=Color3.fromRGB(55,158,255),AccentDark=Color3.fromRGB(25,91,180)},
        Purple = {Background=Color3.fromRGB(14,9,24),Secondary=Color3.fromRGB(24,14,39),Tertiary=Color3.fromRGB(39,22,62),Hover=Color3.fromRGB(53,29,84),Accent=Color3.fromRGB(166,92,255),AccentDark=Color3.fromRGB(104,50,190)},
        Dark = {Background=Color3.fromRGB(8,9,12),Secondary=Color3.fromRGB(15,17,22),Tertiary=Color3.fromRGB(24,27,34),Hover=Color3.fromRGB(34,38,47),Accent=Color3.fromRGB(190,200,215),AccentDark=Color3.fromRGB(90,105,125)}
    }

    local palette = palettes[theme] or palettes.Blue
    for key, value in pairs(palette) do
        Theme[key] = value
    end

    return true

  end


-- ============================================================================
-- SINGULARITY V8 EXTENDED CORE
-- ============================================================================
-- This section intentionally contains functional infrastructure rather than
-- padding. It provides reusable state, validation, animation, serialization,
-- theme, signal, cleanup, formatting, and compatibility helpers for scripts
-- that build on top of Singularity.
-- ============================================================================

local V8 = {}
Singularity.V8 = V8
V8.Version = "8.0.0"
V8.Build = "Extended"
V8._Connections = V8._Connections or {}
V8._Objects = V8._Objects or {}
V8._Configs = V8._Configs or {}
V8._Themes = V8._Themes or {}
V8._Signals = V8._Signals or {}

local function V8Copy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local result = {}
    seen[value] = result
    for k, v in pairs(value) do result[V8Copy(k, seen)] = V8Copy(v, seen) end
    return result
end

local function V8Clamp(value, minValue, maxValue)
    value = tonumber(value) or 0
    minValue = tonumber(minValue) or 0
    maxValue = tonumber(maxValue) or 1
    if minValue > maxValue then minValue, maxValue = maxValue, minValue end
    return math.max(minValue, math.min(maxValue, value))
end

local function V8Trim(value)
    value = tostring(value or "")
    return value:match("^%s*(.-)%s*$") or ""
end

local function V8Round(value, decimals)
    value = tonumber(value) or 0
    decimals = math.max(0, math.floor(tonumber(decimals) or 0))
    local p = 10 ^ decimals
    return math.floor(value * p + 0.5) / p
end

local function V8SafeCall(callback, ...)
    if type(callback) ~= "function" then return false, "callback is not a function" end
    return pcall(callback, ...)
end

V8.Utils = {}
V8.Utils.Copy = V8Copy
V8.Utils.Clamp = V8Clamp
V8.Utils.Trim = V8Trim
V8.Utils.Round = V8Round
V8.Utils.SafeCall = V8SafeCall

function V8.Utils.IsNumber(value) return type(value) == "number" and value == value end
function V8.Utils.IsString(value) return type(value) == "string" end
function V8.Utils.IsBoolean(value) return type(value) == "boolean" end
function V8.Utils.IsTable(value) return type(value) == "table" end
function V8.Utils.IsFunction(value) return type(value) == "function" end
function V8.Utils.IsInstance(value) return typeof(value) == "Instance" end
function V8.Utils.IsColor3(value) return typeof(value) == "Color3" end
function V8.Utils.IsVector2(value) return typeof(value) == "Vector2" end
function V8.Utils.IsVector3(value) return typeof(value) == "Vector3" end
function V8.Utils.IsUDim2(value) return typeof(value) == "UDim2" end
function V8.Utils.IsEnumItem(value) return typeof(value) == "EnumItem" end

function V8.Utils.Count(dictionary)
    local count = 0
    for _ in pairs(dictionary or {}) do count += 1 end
    return count
end

function V8.Utils.Array(value)
    local result = {}
    if type(value) ~= "table" then return result end
    for i = 1, #value do result[i] = value[i] end
    return result
end

function V8.Utils.Keys(dictionary)
    local result = {}
    for key in pairs(dictionary or {}) do result[#result + 1] = key end
    table.sort(result, function(a,b) return tostring(a) < tostring(b) end)
    return result
end

function V8.Utils.Values(dictionary)
    local result = {}
    for _, value in pairs(dictionary or {}) do result[#result + 1] = value end
    return result
end

function V8.Utils.Merge(first, second, deep)
    local result = V8Copy(first or {})
    for key, value in pairs(second or {}) do
        if deep and type(value) == "table" and type(result[key]) == "table" then
            result[key] = V8.Utils.Merge(result[key], value, true)
        else
            result[key] = V8Copy(value)
        end
    end
    return result
end

function V8.Utils.Map(array, callback)
    local result = {}
    if type(array) ~= "table" or type(callback) ~= "function" then return result end
    for index, value in ipairs(array) do result[index] = callback(value, index) end
    return result
end

function V8.Utils.Filter(array, callback)
    local result = {}
    if type(array) ~= "table" or type(callback) ~= "function" then return result end
    for index, value in ipairs(array) do if callback(value, index) then result[#result + 1] = value end end
    return result
end

function V8.Utils.Find(array, callback)
    if type(array) ~= "table" or type(callback) ~= "function" then return nil end
    for index, value in ipairs(array) do if callback(value, index) then return value, index end end
    return nil
end

function V8.Utils.Contains(array, target)
    if type(array) ~= "table" then return false end
    for _, value in ipairs(array) do if value == target then return true end end
    return false
end

function V8.Utils.Reverse(array)
    local result = {}
    for index = #array, 1, -1 do result[#result + 1] = array[index] end
    return result
end

function V8.Utils.ShallowEqual(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    for key, value in pairs(a) do if b[key] ~= value then return false end end
    for key, value in pairs(b) do if a[key] ~= value then return false end end
    return true
end

function V8.Utils.DeepEqual(a, b, seen)
    if a == b then return true end
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return false end
    seen = seen or {}
    seen[a] = seen[a] or {}

      if seen[a][b] then return true end
    seen[a][b] = true
    for key, value in pairs(a) do if not V8.Utils.DeepEqual(value, b[key], seen) then return false end end
    for key, value in pairs(b) do if not V8.Utils.DeepEqual(a[key], value, seen) then return false end end
    return true
end

function V8.Utils.PathGet(root, path, fallback)
    local current = root
    for segment in string.gmatch(tostring(path or ""), "[^%.]+") do
        if type(current) ~= "table" then return fallback end
        current = current[segment]
        if current == nil then return fallback end
    end
    if current == nil then return fallback end
    return current
end

function V8.Utils.PathSet(root, path, value)
    if type(root) ~= "table" then return false end
    local parts = {}
    for segment in string.gmatch(tostring(path or ""), "[^%.]+") do parts[#parts + 1] = segment end
    if #parts == 0 then return false end
    local current = root
    for i = 1, #parts - 1 do current[parts[i]] = current[parts[i]] or {}; current = current[parts[i]] end
    current[parts[#parts]] = value
    return true
end

function V8.Utils.FormatNumber(value, decimals)
    value = tonumber(value) or 0
    decimals = decimals == nil and 2 or decimals
    local text = string.format("%." .. tostring(decimals) .. "f", value)
    local left, right = text:match("^([%-]?%d+)(%.%d+)$")
    left = left or text
    local sign, digits = left:match("^([%-]?)(%d+)$")
    local grouped = digits and digits:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") or left
    return (sign or "") .. grouped .. (right or "")
end

function V8.Utils.FormatCompact(value)
    value = tonumber(value) or 0
    local absolute = math.abs(value)
    if absolute >= 1e12 then return string.format("%.2fT", value / 1e12) end
    if absolute >= 1e9 then return string.format("%.2fB", value / 1e9) end
    if absolute >= 1e6 then return string.format("%.2fM", value / 1e6) end
    if absolute >= 1e3 then return string.format("%.2fK", value / 1e3) end
    return tostring(V8Round(value, 2))
end

function V8.Utils.FormatPercent(value, decimals)
    return string.format("%." .. tostring(decimals or 1) .. "f%%", (tonumber(value) or 0) * 100)
end

function V8.Utils.FormatTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then return string.format("%02d:%02d:%02d", hours, minutes, secs) end
    return string.format("%02d:%02d", minutes, secs)
end

function V8.Utils.ParseBoolean(value, fallback)
    if type(value) == "boolean" then return value end
    local text = string.lower(V8Trim(value))
    if text == "true" or text == "1" or text == "yes" or text == "on" or text == "enabled" then return true end
    if text == "false" or text == "0" or text == "no" or text == "off" or text == "disabled" then return false end
    return fallback
end

function V8.Utils.NormalizeOption(value, options, fallback)
    if type(options) ~= "table" then return fallback end
    for _, option in ipairs(options) do if option == value then return option end end
    return fallback or options[1]
end

function V8.Utils.Lower(value) return string.lower(tostring(value or "")) end
function V8.Utils.Upper(value) return string.upper(tostring(value or "")) end
function V8.Utils.StartsWith(value, prefix) return string.sub(tostring(value), 1, #tostring(prefix)) == tostring(prefix) end
function V8.Utils.EndsWith(value, suffix) return suffix == "" or string.sub(tostring(value), -#tostring(suffix)) == tostring(suffix) end
function V8.Utils.Replace(value, from, to) return string.gsub(tostring(value or ""), tostring(from), tostring(to or "")) end
function V8.Utils.Split(value, separator)
    local result = {}
    separator = separator or ","
    for part in string.gmatch(tostring(value or ""), "[^" .. separator .. "]+") do result[#result + 1] = V8Trim(part) end
    return result
end

function V8.Utils.Join(array, separator)
    return table.concat(array or {}, separator or ", ")
end



-- --------------------------------------------------------------------------
-- Signal implementation
-- --------------------------------------------------------------------------
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._listeners = {}
    self._destroyed = false
    return self
end

function Signal:Connect(callback)
    if self._destroyed or type(callback) ~= "function" then return {Disconnect=function() end} end
    local record = {Callback=callback, Connected=true}
    self._listeners[record] = true
    function record:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        self._signal._listeners[self] = nil
    end
    record._signal = self
    return record
end

function Signal:Once(callback)
    local connection
    connection = self:Connect(function(...)
        if connection then connection:Disconnect() end
        return callback(...)
    end)
    return connection
end

function Signal:Fire(...)
    if self._destroyed then return end
    local snapshot = {}
    for connection in pairs(self._listeners) do snapshot[#snapshot + 1] = connection end
    for _, connection in ipairs(snapshot) do
        if connection.Connected then task.spawn(function() V8SafeCall(connection.Callback, ...) end) end
    end
end

function Signal:Wait()
    local thread = coroutine.running()
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function Signal:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    for connection in pairs(self._listeners) do connection.Connected = false end
    self._listeners = {}
end

V8.Signal = Signal
function V8.CreateSignal() return Signal.new() end

-- --------------------------------------------------------------------------

-- Maid / cleanup implementation
-- --------------------------------------------------------------------------
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({_tasks = {}, _destroyed = false}, Maid)
end

function Maid:Give(taskObject)
    if self._destroyed then
        if typeof(taskObject) == "RBXScriptConnection" then taskObject:Disconnect()
        elseif type(taskObject) == "function" then V8SafeCall(taskObject)
        elseif type(taskObject) == "table" and type(taskObject.Destroy) == "function" then V8SafeCall(function() taskObject:Destroy() end)
        elseif type(taskObject) == "table" and type(taskObject.Disconnect) == "function" then V8SafeCall(function() taskObject:Disconnect() end) end
        return taskObject
    end
    self._tasks[#self._tasks + 1] = taskObject
    return taskObject
end

function Maid:GiveConnection(connection) return self:Give(connection) end
function Maid:GiveFunction(callback) return self:Give(callback) end

function Maid:Cleanup()
    for i = #self._tasks, 1, -1 do
        local taskObject = self._tasks[i]
        self._tasks[i] = nil
        if typeof(taskObject) == "RBXScriptConnection" then V8SafeCall(function() taskObject:Disconnect() end)
        elseif type(taskObject) == "function" then V8SafeCall(taskObject)
        elseif type(taskObject) == "table" then
            if type(taskObject.Destroy) == "function" then V8SafeCall(function() taskObject:Destroy() end)
            elseif type(taskObject.Disconnect) == "function" then V8SafeCall(function() taskObject:Disconnect() end) end
        end
    end
end

function Maid:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    self:Cleanup()
end

V8.Maid = Maid
function V8.CreateMaid() return Maid.new() end

-- --------------------------------------------------------------------------
-- State container
-- --------------------------------------------------------------------------
local State = {}
State.__index = State

function State.new(defaults)
    local self = setmetatable({}, State)
    self.Values = V8Copy(defaults or {})
    self.Signals = {}
    self.Destroyed = false
    return self
end

function State:Get(key, fallback)
    local value = self.Values[key]
    if value == nil then return fallback end
    return value
end

function State:Set(key, value, silent)
    if self.Destroyed then return value end
    local previous = self.Values[key]
    self.Values[key] = value
    if not silent and previous ~= value then
        self.Signals[key] = self.Signals[key] or Signal.new()
        self.Signals[key]:Fire(value, previous)
    end
    return value
end

function State:Toggle(key, fallback)
    return self:Set(key, not self:Get(key, fallback == true))
end

function State:Bind(key, callback)
    self.Signals[key] = self.Signals[key] or Signal.new()
    return self.Signals[key]:Connect(callback)
end

function State:Snapshot() return V8Copy(self.Values) end
function State:Reset(defaults)
    self.Values = V8Copy(defaults or {})
    for key, value in pairs(self.Values) do
        self.Signals[key] = self.Signals[key] or Signal.new()
        self.Signals[key]:Fire(value, nil)
    end
end

function State:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    for _, signal in pairs(self.Signals) do signal:Destroy() end
    self.Signals = {}
    self.Values = {}
end

V8.State = State
function V8.CreateState(defaults) return State.new(defaults) end



-- --------------------------------------------------------------------------
-- Validator and configuration manager
-- --------------------------------------------------------------------------
V8.Validator = {}
function V8.Validator.Required(value, name)
    if value == nil or value == "" then return false, tostring(name or "Value") .. " is required" end
    return true
end
function V8.Validator.Number(value, name) if tonumber(value) == nil then return false, tostring(name or "Value") .. " must be a number" end return true end
function V8.Validator.Range(value, minValue, maxValue, name)
    value = tonumber(value)
    if not value then return false, tostring(name or "Value") .. " must be a number" end
    if value < minValue or value > maxValue then return false, tostring(name or "Value") .. " must be between " .. tostring(minValue) .. " and " .. tostring(maxValue) end
    return true
end
function V8.Validator.OneOf(value, options, name)
    for _, option in ipairs(options or {}) do if value == option then return true end end
    return false, tostring(name or "Value") .. " is not a valid option"
end
function V8.Validator.Type(value, expected, name)
    if type(value) ~= expected then return false, tostring(name or "Value") .. " must be type " .. tostring(expected) end
    return true
end
function V8.Validator.Instance(value, className, name)
    if typeof(value) ~= "Instance" or (className and not value:IsA(className)) then return false, tostring(name or "Instance") .. " is invalid" end
    return true
end

local Config = {}
Config.__index = Config
function Config.new(name, defaults)
    local self = setmetatable({}, Config)
    self.Name = tostring(name or "SingularityConfig")
    self.Defaults = V8Copy(defaults or {})
    self.Values = V8Copy(defaults or {})
    self.Changed = Signal.new()
    self.Destroyed = false
    return self
end
function Config:Get(key, fallback) local value = self.Values[key]; return value == nil and fallback or value end
function Config:Set(key, value) if self.Destroyed then return value end; local old=self.Values[key]; self.Values[key]=value; if old~=value then self.Changed:Fire(key,value,old) end; return value end
function Config:SetMany(values) for key,value in pairs(values or {}) do self:Set(key,value) end return self end
function Config:Reset(key)
    if key == nil then self.Values=V8Copy(self.Defaults); self.Changed:Fire("*",self.Values,nil); return self end
    return self:Set(key,V8Copy(self.Defaults[key]))
end
function Config:Snapshot() return V8Copy(self.Values) end
function Config:Serialize()
    local HttpService = game:GetService("HttpService")
    local ok,result = pcall(function() return HttpService:JSONEncode(self.Values) end)
    return ok and result or nil
end

function Config:Deserialize(text)
    local HttpService = game:GetService("HttpService")
    local ok,result = pcall(function() return HttpService:JSONDecode(text) end)
    if not ok or type(result) ~= "table" then return false,result end
    self:SetMany(result)
    return true,result
end
function Config:Destroy() if self.Destroyed then return end; self.Destroyed=true; self.Changed:Destroy(); self.Values={}; self.Defaults={} end
V8.Config = Config
function V8.CreateConfig(name, defaults) local config=Config.new(name,defaults); V8._Configs[config.Name]=config; return config end
function V8.GetConfig(name) return V8._Configs[tostring(name)] end

-- --------------------------------------------------------------------------
-- Theme registry
-- --------------------------------------------------------------------------
function V8.RegisterTheme(name, palette)
    if type(name) ~= "string" or type(palette) ~= "table" then return false end
    V8._Themes[name] = V8Copy(palette)
    return true
end
function V8.GetTheme(name) return V8Copy(V8._Themes[name]) end
function V8.ListThemes() return V8.Utils.Keys(V8._Themes) end
function V8.ApplyTheme(name)
    local palette=V8._Themes[name]
    if not palette then return false end
    for key,value in pairs(palette) do Theme[key]=value end
    return true
end

V8.RegisterTheme("BlueGlass", {
    Background=Color3.fromRGB(5,12,24), Secondary=Color3.fromRGB(8,21,39), Tertiary=Color3.fromRGB(13,34,58),
    Hover=Color3.fromRGB(18,48,82), Accent=Color3.fromRGB(55,158,255), AccentDark=Color3.fromRGB(25,91,180),
    Text=Color3.fromRGB(239,247,255), SubText=Color3.fromRGB(150,183,219), Muted=Color3.fromRGB(83,119,157), Stroke=Color3.fromRGB(30,76,120)
})
V8.RegisterTheme("Midnight", {
    Background=Color3.fromRGB(4,6,12), Secondary=Color3.fromRGB(9,12,21), Tertiary=Color3.fromRGB(17,22,35),
    Hover=Color3.fromRGB(28,37,56), Accent=Color3.fromRGB(105,174,255), AccentDark=Color3.fromRGB(47,101,171),
    Text=Color3.fromRGB(245,248,255), SubText=Color3.fromRGB(158,170,193), Muted=Color3.fromRGB(88,99,120), Stroke=Color3.fromRGB(45,57,82)
})
V8.RegisterTheme("Ocean", {
    Background=Color3.fromRGB(3,19,29), Secondary=Color3.fromRGB(5,34,48), Tertiary=Color3.fromRGB(8,52,69),
    Hover=Color3.fromRGB(11,72,91), Accent=Color3.fromRGB(49,202,255), AccentDark=Color3.fromRGB(16,123,167),
    Text=Color3.fromRGB(235,253,255), SubText=Color3.fromRGB(141,201,216), Muted=Color3.fromRGB(72,128,143), Stroke=Color3.fromRGB(20,93,111)
})
V8.RegisterTheme("Royal", {
    Background=Color3.fromRGB(11,7,25), Secondary=Color3.fromRGB(20,12,42), Tertiary=Color3.fromRGB(32,20,63),
    Hover=Color3.fromRGB(47,29,87), Accent=Color3.fromRGB(147,105,255), AccentDark=Color3.fromRGB(91,55,181),
    Text=Color3.fromRGB(247,243,255), SubText=Color3.fromRGB(185,166,220), Muted=Color3.fromRGB(111,94,145), Stroke=Color3.fromRGB(65,46,105)
})



-- --------------------------------------------------------------------------
-- Animation and UI construction helpers
-- --------------------------------------------------------------------------
V8.Animation = {}
function V8.Animation.Tween(instance, duration, properties, style, direction)
    if not instance or type(properties) ~= "table" then return nil end
    local info = TweenInfo.new(tonumber(duration) or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end
function V8.Animation.Stop(tween)
    if tween and tween.PlaybackState == Enum.PlaybackState.Playing then tween:Cancel() end
end
function V8.Animation.Fade(instance, transparency, duration)
    local props={}
    if instance:IsA("GuiObject") then props.BackgroundTransparency=transparency end
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then props.TextTransparency=transparency end
    if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then props.ImageTransparency=transparency end
    return V8.Animation.Tween(instance,duration,props)
end
function V8.Animation.Scale(instance, scale, duration)
    local constraint=instance:FindFirstChild("V8Scale")
    if not constraint then constraint=Instance.new("UIScale"); constraint.Name="V8Scale"; constraint.Scale=1; constraint.Parent=instance end
    return V8.Animation.Tween(constraint,duration,{Scale=scale})
end
function V8.Animation.PopIn(instance, duration)
    local constraint=instance:FindFirstChild("V8Scale") or Instance.new("UIScale")
    constraint.Name="V8Scale"; constraint.Scale=0.94; constraint.Parent=instance
    V8.Animation.Fade(instance,0,duration or 0.2)
    return V8.Animation.Tween(constraint,duration or 0.2,{Scale=1},Enum.EasingStyle.Back)
end
function V8.Animation.PopOut(instance, duration)
    local constraint=instance:FindFirstChild("V8Scale") or Instance.new("UIScale")
    constraint.Name="V8Scale"; constraint.Scale=1; constraint.Parent=instance
    local tween=V8.Animation.Tween(constraint,duration or 0.18,{Scale=0.94},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
    V8.Animation.Fade(instance,1,duration or 0.18)
    return tween
end
function V8.Animation.Pulse(instance, amount, duration)
    amount=amount or 1.04; duration=duration or 0.12
    local constraint=instance:FindFirstChild("V8Scale") or Instance.new("UIScale")
    constraint.Name="V8Scale"; constraint.Scale=1; constraint.Parent=instance
    local up=V8.Animation.Tween(constraint,duration,{Scale=amount},Enum.EasingStyle.Quad)
    up.Completed:Connect(function() V8.Animation.Tween(constraint,duration,{Scale=1},Enum.EasingStyle.Quad) end)
    return up
end

V8.UI = {}
function V8.UI.Corner(instance, radius)
    local corner=instance:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,tonumber(radius) or 10); corner.Parent=instance; return corner
end
function V8.UI.Stroke(instance, color, transparency, thickness)
    local stroke=instance:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.Color=color or Theme.Stroke; stroke.Transparency=transparency or 0; stroke.Thickness=thickness or 1; stroke.Parent=instance; return stroke
end
function V8.UI.Padding(instance, left, top, right, bottom)
    local padding=instance:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
    padding.PaddingLeft=UDim.new(0,left or 0); padding.PaddingTop=UDim.new(0,top or 0); padding.PaddingRight=UDim.new(0,right or 0); padding.PaddingBottom=UDim.new(0,bottom or 0); padding.Parent=instance; return padding
end
function V8.UI.List(instance, direction, gap, horizontalAlignment, verticalAlignment)
    local layout=instance:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
    layout.FillDirection=direction or Enum.FillDirection.Vertical; layout.Padding=UDim.new(0,gap or 0)
    layout.HorizontalAlignment=horizontalAlignment or Enum.HorizontalAlignment.Left; layout.VerticalAlignment=verticalAlignment or Enum.VerticalAlignment.Top
    layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=instance; return layout
end
function V8.UI.Grid(instance, cellSize, cellPadding)
    local layout=instance:FindFirstChildOfClass("UIGridLayout") or Instance.new("UIGridLayout")
    layout.CellSize=cellSize or UDim2.fromOffset(100,40); layout.CellPadding=cellPadding or UDim2.fromOffset(8,8); layout.Parent=instance; return layout
end
function V8.UI.AutoCanvas(scrollingFrame, padding)
    local layout=scrollingFrame:FindFirstChildOfClass("UIListLayout") or scrollingFrame:FindFirstChildOfClass("UIGridLayout")
    if not layout then return nil end
    local connection=layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+(padding or 0))
    end)
    scrollingFrame.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+(padding or 0))
    V8._Connections[#V8._Connections+1]=connection
    return connection
end
function V8.UI.BindButton(button, callback)
    if not button or type(callback) ~= "function" then return nil end
    return button.Activated:Connect(function() V8SafeCall(callback,button) end)
end
function V8.UI.SetVisible(instance, visible, duration)
    if duration and duration > 0 then
        if visible then instance.Visible=true; V8.Animation.Fade(instance,0,duration) else V8.Animation.Fade(instance,1,duration); task.delay(duration,function() if instance then instance.Visible=false end end) end
    else instance.Visible=visible end
end
function V8.UI.DestroyChildren(instance, predicate)
    for _, child in ipairs(instance:GetChildren()) do if not predicate or predicate(child) then child:Destroy() end end
end



-- --------------------------------------------------------------------------
-- Input, color, geometry and Roblox compatibility helpers
-- --------------------------------------------------------------------------
V8.Input = {}
function V8.Input.IsTouch() return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled end
function V8.Input.IsKeyboard() return UserInputService.KeyboardEnabled end
function V8.Input.IsGamepad() return UserInputService.GamepadEnabled end
function V8.Input.GetViewport() local camera=workspace.CurrentCamera; return camera and camera.ViewportSize or Vector2.new(1280,720) end
function V8.Input.IsMobileWidth(width) return (width or V8.Input.GetViewport().X) < 700 end
function V8.Input.IsSmallScreen() local size=V8.Input.GetViewport(); return size.X < 600 or size.Y < 500 end
function V8.Input.GetPrimaryInput() if V8.Input.IsTouch() then return "Touch" end if V8.Input.IsGamepad() then return "Gamepad" end return "Keyboard" end
function V8.Input.IsShiftDown() return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) end

function V8.Input.IsCtrlDown() return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) end
function V8.Input.IsAltDown() return UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) end

V8.Color = {}
function V8.Color.FromHex(hex)
    hex=tostring(hex or ""):gsub("#","")
    if #hex ~= 6 then return nil end
    local r=tonumber(hex:sub(1,2),16); local g=tonumber(hex:sub(3,4),16); local b=tonumber(hex:sub(5,6),16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r,g,b)
end
function V8.Color.ToHex(color)
    if typeof(color) ~= "Color3" then return "#FFFFFF" end
    return string.format("#%02X%02X%02X",math.round(color.R*255),math.round(color.G*255),math.round(color.B*255))
end
function V8.Color.Lerp(a,b,t) if typeof(a)~="Color3" or typeof(b)~="Color3" then return a end return a:Lerp(b,V8Clamp(t,0,1)) end
function V8.Color.Lighten(color, amount) return V8.Color.Lerp(color,Color3.new(1,1,1),V8Clamp(amount,0,1)) end
function V8.Color.Darken(color, amount) return V8.Color.Lerp(color,Color3.new(0,0,0),V8Clamp(amount,0,1)) end
function V8.Color.WithAlpha(color, alpha) return color,V8Clamp(alpha,0,1) end
function V8.Color.IsBright(color) if typeof(color)~="Color3" then return false end return (color.R*299+color.G*587+color.B*114)/1000 > .5 end
function V8.Color.ContrastText(color) return V8.Color.IsBright(color) and Color3.fromRGB(8,12,18) or Color3.fromRGB(245,250,255) end

V8.Geometry = {}
function V8.Geometry.Center(size, viewport) local x=(viewport.X-size.X)/2; local y=(viewport.Y-size.Y)/2; return UDim2.fromOffset(x,y) end
function V8.Geometry.ClampPosition(position, size, viewport, margin)
    margin=margin or 8
    local x=V8Clamp(position.X,margin,math.max(margin,viewport.X-size.X-margin)); local y=V8Clamp(position.Y,margin,math.max(margin,viewport.Y-size.Y-margin))
    return Vector2.new(x,y)
end
function V8.Geometry.PointInside(point, position, size) return point.X>=position.X and point.X<=position.X+size.X and point.Y>=position.Y and point.Y<=position.Y+size.Y end
function V8.Geometry.Lerp2(a,b,t) return a:Lerp(b,V8Clamp(t,0,1)) end
function V8.Geometry.Lerp3(a,b,t) return a:Lerp(b,V8Clamp(t,0,1)) end
function V8.Geometry.LerpUDim2(a,b,t) return UDim2.new(a.X.Scale+(b.X.Scale-a.X.Scale)*t,a.X.Offset+(b.X.Offset-a.X.Offset)*t,a.Y.Scale+(b.Y.Scale-a.Y.Scale)*t,a.Y.Offset+(b.Y.Offset-a.Y.Offset)*t) end
function V8.Geometry.AbsoluteCenter(gui) local pos=gui.AbsolutePosition; local size=gui.AbsoluteSize; return pos+size/2 end
function V8.Geometry.Distance2(a,b) return (a-b).Magnitude end
function V8.Geometry.Distance3(a,b) return (a-b).Magnitude end

-- --------------------------------------------------------------------------
-- Compatibility surface for common UI-library naming conventions
-- --------------------------------------------------------------------------
V8.Compatibility = {}
function V8.Compatibility.ResolveOption(value) if type(value)=="table" then return value.CurrentOption or value[1] end return value end
function V8.Compatibility.Callback(option, callback) if type(callback)=="function" then return V8SafeCall(callback,option) end return false end
function V8.Compatibility.NormalizeOptions(options)
    local result={}
    for _,option in ipairs(options or {}) do result[#result+1]=tostring(option) end
    return result
end
function V8.Compatibility.CreateAlias(object, alias, target)
    if type(object)~="table" or type(alias)~="string" then return false end
    object[alias]=object[target]; return object[alias]~=nil
end
function V8.Compatibility.SafeDestroy(object)
    if not object then return false end
    if type(object.Destroy)=="function" then return V8SafeCall(function() object:Destroy() end) end
    if typeof(object)=="Instance" then return V8SafeCall(function() object:Destroy() end) end
    return false
end

-- --------------------------------------------------------------------------
-- Diagnostics and lifecycle
-- --------------------------------------------------------------------------
V8.Diagnostics = {}
function V8.Diagnostics.MemoryLabel() return "LuaHeap: " .. string.format("%.2f MB",collectgarbage("count")/1024) end
function V8.Diagnostics.GetConnectionCount() local count=0; for _,connection in ipairs(V8._Connections) do if connection then count+=1 end end return count end
function V8.Diagnostics.GetConfigCount() return V8.Utils.Count(V8._Configs) end
function V8.Diagnostics.GetThemeCount() return V8.Utils.Count(V8._Themes) end
function V8.Diagnostics.Snapshot() return {Version=V8.Version,Build=V8.Build,Connections=V8.Diagnostics.GetConnectionCount(),Configs=V8.Diagnostics.GetConfigCount(),Themes=V8.Diagnostics.GetThemeCount(),Memory=collectgarbage("count")} end
function V8.Diagnostics.Print(prefix) local data=V8.Diagnostics.Snapshot(); return (prefix or "Singularity") .. " | " .. data.Version .. " | " .. data.Build .. " | " .. V8.Diagnostics.MemoryLabel() end

function V8.Cleanup()
    for index,connection in ipairs(V8._Connections) do if connection then V8SafeCall(function() connection:Disconnect() end) V8._Connections[index]=nil end end
    for name,config in pairs(V8._Configs) do if config then config:Destroy() end V8._Configs[name]=nil end
    for name,signal in pairs(V8._Signals) do if signal then signal:Destroy() end V8._Signals[name]=nil end
end
function V8.RegisterConnection(connection) V8._Connections[#V8._Connections+1]=connection; return connection end
function V8.RegisterObject(object) V8._Objects[#V8._Objects+1]=object; return object end
function V8.DestroyObject(object) return V8.Compatibility.SafeDestroy(object) end

-- Public aliases.
Singularity.CreateSignal=function(...) return V8.CreateSignal(...) end
Singularity.CreateMaid=function(...) return V8.CreateMaid(...) end
Singularity.CreateState=function(...) return V8.CreateState(...) end
Singularity.CreateConfig=function(...) return V8.CreateConfig(...) end
Singularity.GetConfig=function(...) return V8.GetConfig(...) end
Singularity.RegisterTheme=function(...) return V8.RegisterTheme(...) end
Singularity.ApplyTheme=function(...) return V8.ApplyTheme(...) end
Singularity.GetThemes=function() return V8.ListThemes() end
Singularity.V8Cleanup=function() return V8.Cleanup() end

-- Compatibility aliases frequently used by UI scripts.
V8.Utils.Clone=V8.Utils.Copy
V8.Utils.DeepCopy=V8.Utils.Copy
V8.Utils.IsValidNumber=V8.Utils.IsNumber
V8.Utils.ClampNumber=V8.Utils.Clamp
V8.Utils.ToNumber=function(value,fallback) local n=tonumber(value); return n==nil and fallback or n end
V8.Utils.ToString=function(value,fallback) if value==nil then return fallback or "" end return tostring(value) end
V8.Utils.ToBoolean=function(value,fallback) return V8.Utils.ParseBoolean(value,fallback) end
V8.Utils.GetOr=function(tableValue,key,fallback) if type(tableValue)~="table" then return fallback end local value=tableValue[key]; return value==nil and fallback or value end
V8.Utils.SetIfNil=function(tableValue,key,value) if type(tableValue)=="table" and tableValue[key]==nil then tableValue[key]=value end return tableValue and tableValue[key] end

-- Final V8 initialization.
if not V8._Initialized then
    V8._Initialized=true
    V8._Signals.Ready=Signal.new()
    task.defer(function() V8._Signals.Ready:Fire(V8) end)
end



-- --------------------------------------------------------------------------
-- Component factory helpers
-- --------------------------------------------------------------------------
V8.Components = {}

function V8.Components.Frame(parent, properties)
    local frame=Instance.new("Frame")
    frame.BorderSizePixel=0
    frame.BackgroundColor3=Theme.Secondary
    frame.BackgroundTransparency=.12
    for key,value in pairs(properties or {}) do frame[key]=value end
    frame.Parent=parent
    V8.UI.Corner(frame,12)
    V8.UI.Stroke(frame,Theme.Stroke,.35,1)
    return frame
end

function V8.Components.Label(parent, text, properties)
    local label=Instance.new("TextLabel")
    label.BackgroundTransparency=1
    label.Text=tostring(text or "")
    label.TextColor3=Theme.Text
    label.Font=Enum.Font.Gotham
    label.TextSize=14
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.TextYAlignment=Enum.TextYAlignment.Center
    for key,value in pairs(properties or {}) do label[key]=value end
    label.Parent=parent
    return label
end

function V8.Components.Button(parent, text, callback, properties)
    local button=Instance.new("TextButton")
    button.AutoButtonColor=false
    button.BorderSizePixel=0
    button.BackgroundColor3=Theme.Tertiary
    button.BackgroundTransparency=.08
    button.Text=tostring(text or "Button")
    button.TextColor3=Theme.Text
    button.Font=Enum.Font.GothamMedium
    button.TextSize=14
    for key,value in pairs(properties or {}) do button[key]=value end
    button.Parent=parent
    V8.UI.Corner(button,10)
    V8.UI.Stroke(button,Theme.Stroke,.4,1)
    local hover=button.MouseEnter:Connect(function() V8.Animation.Tween(button,.12,{BackgroundColor3=Theme.Hover}) end)
    local leave=button.MouseLeave:Connect(function() V8.Animation.Tween(button,.12,{BackgroundColor3=Theme.Tertiary}) end)
    V8.RegisterConnection(hover); V8.RegisterConnection(leave)
    V8.UI.BindButton(button,function() V8.Animation.Pulse(button,1.025,.08); if callback then callback(button) end end)
    return button

  end

function V8.Components.Toggle(parent, text, initial, callback, properties)
    local state=initial==true
    local button=V8.Components.Button(parent,text,nil,properties)
    local indicator=Instance.new("Frame")
    indicator.BorderSizePixel=0; indicator.Size=UDim2.fromOffset(34,18); indicator.AnchorPoint=Vector2.new(1,.5); indicator.Position=UDim2.new(1,-10,.5,0); indicator.Parent=button
    V8.UI.Corner(indicator,9)
    local knob=Instance.new("Frame")
    knob.BorderSizePixel=0; knob.Size=UDim2.fromOffset(14,14); knob.AnchorPoint=Vector2.new(0,.5); knob.Position=UDim2.fromOffset(2,9); knob.Parent=indicator
    V8.UI.Corner(knob,7)
    local function render(animated)
        local bg=state and Theme.Accent or Theme.Background
        local pos=state and UDim2.fromOffset(18,9) or UDim2.fromOffset(2,9)
        if animated then V8.Animation.Tween(indicator,.15,{BackgroundColor3=bg}); V8.Animation.Tween(knob,.15,{Position=pos}) else indicator.BackgroundColor3=bg; knob.Position=pos end
    end
    render(false)
    button.Activated:Connect(function() state=not state; render(true); if callback then callback(state) end end)
    return button,function(value) state=value==true; render(true); if callback then callback(state) end end,function() return state end
end

function V8.Components.Dropdown(parent, text, options, current, callback, properties)
    local frame=V8.Components.Frame(parent,properties)
    frame.Size=properties and properties.Size or UDim2.new(1,0,0,58)
    local title=V8.Components.Label(frame,text,{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,0,22),TextSize=13,TextColor3=Theme.SubText})
    local button=Instance.new("TextButton")
    button.AutoButtonColor=false; button.BorderSizePixel=0; button.BackgroundColor3=Theme.Tertiary; button.BackgroundTransparency=.05; button.TextColor3=Theme.Text; button.Font=Enum.Font.GothamMedium; button.TextSize=13
    button.Text=tostring(current or options[1] or "Select")
    button.Position=UDim2.fromOffset(10,28); button.Size=UDim2.new(1,-20,0,25); button.Parent=frame; V8.UI.Corner(button,8)
    local menu=Instance.new("Frame"); menu.Visible=false; menu.ZIndex=30; menu.BorderSizePixel=0; menu.BackgroundColor3=Theme.Secondary; menu.BackgroundTransparency=.02; menu.Position=UDim2.new(0,0,1,4); menu.Size=UDim2.new(1,0,0,0); menu.Parent=button; V8.UI.Corner(menu,9); V8.UI.Stroke(menu,Theme.Stroke,.2,1)
    local list=V8.UI.List(menu,Enum.FillDirection.Vertical,2); V8.UI.Padding(menu,5,5,5,5)
    local value=current or options[1]
    local function rebuild()
        V8.UI.DestroyChildren(menu,function(child) return child:IsA("TextButton") end)
        for _,option in ipairs(options or {}) do
            local item=Instance.new("TextButton"); item.AutoButtonColor=false; item.BorderSizePixel=0; item.BackgroundColor3=Theme.Tertiary; item.BackgroundTransparency=.15; item.Text=tostring(option); item.TextColor3=Theme.Text; item.Font=Enum.Font.Gotham; item.TextSize=12; item.Size=UDim2.new(1,0,0,28); item.Parent=menu; V8.UI.Corner(item,7)
            item.Activated:Connect(function() value=option; button.Text=tostring(option); menu.Visible=false; if callback then callback(value) end end)
        end
        menu.Size=UDim2.new(1,0,0,math.min(180,(#(options or {}))*30+10))
    end
    rebuild()
    button.Activated:Connect(function() menu.Visible=not menu.Visible; if menu.Visible then V8.Animation.PopIn(menu,.12) end end)
    return frame,function(newValue) value=newValue; button.Text=tostring(newValue); end,function() return value end
end

function V8.Components.Slider(parent, text, minValue, maxValue, current, callback, properties)
    local frame=V8.Components.Frame(parent,properties)
    frame.Size=properties and properties.Size or UDim2.new(1,0,0,64)
    V8.Components.Label(frame,text,{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-70,0,22),TextSize=13,TextColor3=Theme.SubText})
    local valueLabel=V8.Components.Label(frame,tostring(current or minValue),{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,5),Size=UDim2.fromOffset(55,22),TextSize=12,TextXAlignment=Enum.TextXAlignment.Right})
    local track=Instance.new("Frame"); track.BorderSizePixel=0; track.BackgroundColor3=Theme.Background; track.Position=UDim2.fromOffset(12,36); track.Size=UDim2.new(1,-24,0,8); track.Parent=frame; V8.UI.Corner(track,4)
    local fill=Instance.new("Frame"); fill.BorderSizePixel=0; fill.BackgroundColor3=Theme.Accent; fill.Size=UDim2.new(0,0,1,0); fill.Parent=track; V8.UI.Corner(fill,4)
    local value=V8Clamp(current or minValue,minValue,maxValue)
    local function setValue(newValue,fire)
        value=V8Clamp(newValue,minValue,maxValue); local alpha=(value-minValue)/(maxValue-minValue); fill.Size=UDim2.new(alpha,0,1,0); valueLabel.Text=tostring(V8Round(value,2)); if fire and callback then callback(value) end
    end
    setValue(value,false)
    track.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then local connection; connection=UserInputService.InputChanged:Connect(function(changed) if changed.UserInputType==Enum.UserInputType.MouseMovement or changed.UserInputType==Enum.UserInputType.Touch then local x=changed.Position.X; local alpha=V8Clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1); setValue(minValue+(maxValue-minValue)*alpha,true) end end); task.spawn(function() local ended=UserInputService.InputEnded:Wait(); if connection then connection:Disconnect() end end) end end)
    return frame,setValue,function() return value end
end


-- --------------------------------------------------------------------------
-- Extended utility catalog
-- --------------------------------------------------------------------------
function V8.Utils.Utility1(value, fallback, options)
    -- Utility 1: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility2(value, fallback, options)
    -- Utility 2: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility3(value, fallback, options)
    -- Utility 3: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility4(value, fallback, options)
    -- Utility 4: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility5(value, fallback, options)
    -- Utility 5: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility6(value, fallback, options)
    -- Utility 6: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility7(value, fallback, options)
    -- Utility 7: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end

      local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility8(value, fallback, options)
    -- Utility 8: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility9(value, fallback, options)
    -- Utility 9: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility10(value, fallback, options)
    -- Utility 10: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility11(value, fallback, options)
    -- Utility 11: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility12(value, fallback, options)
    -- Utility 12: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility13(value, fallback, options)
    -- Utility 13: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility14(value, fallback, options)
    -- Utility 14: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility15(value, fallback, options)
    -- Utility 15: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility16(value, fallback, options)
    -- Utility 16: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility17(value, fallback, options)
    -- Utility 17: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility18(value, fallback, options)
    -- Utility 18: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility19(value, fallback, options)
    -- Utility 19: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility20(value, fallback, options)
    -- Utility 20: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility21(value, fallback, options)
    -- Utility 21: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility22(value, fallback, options)
    -- Utility 22: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility23(value, fallback, options)
    -- Utility 23: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility24(value, fallback, options)
    -- Utility 24: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility25(value, fallback, options)
    -- Utility 25: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility26(value, fallback, options)
    -- Utility 26: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility27(value, fallback, options)
    -- Utility 27: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility28(value, fallback, options)
    -- Utility 28: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end

      if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility29(value, fallback, options)
    -- Utility 29: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility30(value, fallback, options)
    -- Utility 30: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility31(value, fallback, options)
    -- Utility 31: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility32(value, fallback, options)
    -- Utility 32: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility33(value, fallback, options)
    -- Utility 33: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility34(value, fallback, options)
    -- Utility 34: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility35(value, fallback, options)
    -- Utility 35: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility36(value, fallback, options)
    -- Utility 36: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility37(value, fallback, options)
    -- Utility 37: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility38(value, fallback, options)
    -- Utility 38: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility39(value, fallback, options)
    -- Utility 39: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end

      local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility40(value, fallback, options)
    -- Utility 40: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility41(value, fallback, options)
    -- Utility 41: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility42(value, fallback, options)
    -- Utility 42: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility43(value, fallback, options)
    -- Utility 43: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility44(value, fallback, options)
    -- Utility 44: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility45(value, fallback, options)
    -- Utility 45: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility46(value, fallback, options)
    -- Utility 46: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility47(value, fallback, options)
    -- Utility 47: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility48(value, fallback, options)
    -- Utility 48: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility49(value, fallback, options)
    -- Utility 49: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility50(value, fallback, options)
    -- Utility 50: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility51(value, fallback, options)
    -- Utility 51: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility52(value, fallback, options)
    -- Utility 52: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility53(value, fallback, options)
    -- Utility 53: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility54(value, fallback, options)
    -- Utility 54: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility55(value, fallback, options)
    -- Utility 55: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility56(value, fallback, options)
    -- Utility 56: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility57(value, fallback, options)
    -- Utility 57: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility58(value, fallback, options)
    -- Utility 58: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility59(value, fallback, options)
    -- Utility 59: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility60(value, fallback, options)
    -- Utility 60: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end

      if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility61(value, fallback, options)
    -- Utility 61: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility62(value, fallback, options)
    -- Utility 62: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility63(value, fallback, options)
    -- Utility 63: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility64(value, fallback, options)
    -- Utility 64: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility65(value, fallback, options)
    -- Utility 65: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility66(value, fallback, options)
    -- Utility 66: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility67(value, fallback, options)
    -- Utility 67: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility68(value, fallback, options)
    -- Utility 68: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility69(value, fallback, options)
    -- Utility 69: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility70(value, fallback, options)
    -- Utility 70: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility71(value, fallback, options)
    -- Utility 71: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end

      if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility72(value, fallback, options)
    -- Utility 72: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility73(value, fallback, options)
    -- Utility 73: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility74(value, fallback, options)
    -- Utility 74: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility75(value, fallback, options)
    -- Utility 75: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility76(value, fallback, options)
    -- Utility 76: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility77(value, fallback, options)
    -- Utility 77: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility78(value, fallback, options)
    -- Utility 78: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility79(value, fallback, options)
    -- Utility 79: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility80(value, fallback, options)
    -- Utility 80: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility81(value, fallback, options)
    -- Utility 81: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility72(value, fallback, options)
    -- Utility 72: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility73(value, fallback, options)
    -- Utility 73: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility74(value, fallback, options)
    -- Utility 74: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility75(value, fallback, options)
    -- Utility 75: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility76(value, fallback, options)
    -- Utility 76: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility77(value, fallback, options)
    -- Utility 77: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility78(value, fallback, options)
    -- Utility 78: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility79(value, fallback, options)
    -- Utility 79: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility80(value, fallback, options)
    -- Utility 80: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility81(value, fallback, options)
    -- Utility 81: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end


function V8.Utils.Utility82(value, fallback, options)
    -- Utility 82: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility83(value, fallback, options)
    -- Utility 83: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility84(value, fallback, options)
    -- Utility 84: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility85(value, fallback, options)
    -- Utility 85: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility86(value, fallback, options)
    -- Utility 86: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility87(value, fallback, options)
    -- Utility 87: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility88(value, fallback, options)
    -- Utility 88: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility89(value, fallback, options)
    -- Utility 89: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end

function V8.Utils.Utility90(value, fallback, options)
    -- Utility 90: normalized helper for extension authors. Keeps library calls
    -- deterministic and avoids nil-sensitive boilerplate in user interfaces.
    if options and options.default ~= nil and value == nil then return options.default end
    if value == nil then return fallback end
    local mode = options and options.mode
    if mode == "number" then return tonumber(value) or fallback end
    if mode == "string" then return tostring(value) end
    if mode == "boolean" then return V8.Utils.ParseBoolean(value, fallback) end
    if mode == "trim" then return V8Trim(value) end
    if mode == "lower" then return string.lower(tostring(value)) end
    if mode == "upper" then return string.upper(tostring(value)) end
    return value
end


-- Additional extension helpers.
function V8.Utils.Utility91(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility92(value, fallback, options)
    local config = options or {}
    if value == nil then

          if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility93(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility94(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility95(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility96(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility97(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility98(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility99(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility100(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)

      elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility101(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility102(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility103(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility104(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility105(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility106(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility107(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility108(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility109(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility110(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility111(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility112(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility113(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility114(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility115(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility116(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility117(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback

      elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility118(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility119(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility120(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility121(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility122(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility123(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility124(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility125(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
end

    return result
end

function V8.Utils.Utility126(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility127(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility128(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility129(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility130(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility131(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility132(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility133(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility134(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback

      end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility135(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility136(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility137(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility138(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility139(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility140(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility141(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility142(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))

      elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility143(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility144(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility145(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility146(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility147(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility148(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility149(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end

function V8.Utils.Utility150(value, fallback, options)
    local config = options or {}
    if value == nil then
        if config.default ~= nil then return config.default end
        return fallback
    end
    local result = value
    if config.mode == "number" then result = tonumber(value) or fallback
    elseif config.mode == "string" then result = tostring(value)
    elseif config.mode == "boolean" then result = V8.Utils.ParseBoolean(value, fallback)
    elseif config.mode == "trim" then result = V8Trim(value)
    elseif config.mode == "lower" then result = string.lower(tostring(value))
    elseif config.mode == "upper" then result = string.upper(tostring(value))
    elseif config.mode == "round" then result = V8Round(value, config.decimals or 0)
    elseif config.mode == "clamp" then result = V8Clamp(value, config.min or 0, config.max or 1)
    end
    return result
end


return Singularity
