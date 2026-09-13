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

-- Simple Tab API
-- Usage:
-- local Window = Singularity:TabWindow("test")
-- Window:TabButton("Button")
-- Window:TabToggle("Toggle")
-- Window:TabDropdown("Dropdown")
-- Window:TabColorpicker("Color")
-- Window:TabSlider("Slider")
-- Window:TabText("Text")

function WindowClass:TabButton(name, callback)
    local tab = self._SimpleTab or self:CreateTab({Name = "Main"})
    self._SimpleTab = tab
    return tab:CreateButton({
        Name = tostring(name or "Button"),
        Callback = callback
    })
end

function WindowClass:TabToggle(name, callback)
    local tab = self._SimpleTab or self:CreateTab({Name = "Main"})

      self._SimpleTab = tab
    return tab:CreateToggle({
        Name = tostring(name or "Toggle"),
        CurrentValue = false,
        Callback = callback
    })
end

function WindowClass:TabDropdown(name, options, callback)
    local tab = self._SimpleTab or self:CreateTab({Name = "Main"})
    self._SimpleTab = tab
    return tab:CreateDropdown({
        Name = tostring(name or "Dropdown"),
        Options = options or {},
        CurrentOption = (options and options[1]) or nil,
        Callback = callback
    })
end

function WindowClass:TabColorpicker(name, callback, defaultColor)
    local tab = self._SimpleTab or self:CreateTab({Name = "Main"})
    self._SimpleTab = tab
    return tab:CreateColorPicker({
        Name = tostring(name or "Color"),
        Color = defaultColor or Color3.fromRGB(100, 170, 255),
        Callback = callback
    })
end

function WindowClass:TabSlider(name, min, max, callback)
    local tab = self._SimpleTab or self:CreateTab({Name = "Main"})
    self._SimpleTab = tab
    return tab:CreateSlider({
        Name = tostring(name or "Slider"),
        Range = {min or 0, max or 100},
        Increment = 1,
        Suffix = "",
        CurrentValue = min or 0,
        Callback = callback
    })
end

function WindowClass:TabText(name, text)
    local tab = self._SimpleTab or self:CreateTab({Name = "Main"})
    self._SimpleTab = tab
    return tab:CreateParagraph({
        Title = tostring(name or "Text"),
        Content = tostring(text or "")
    })
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

function Singularity:TabWindow(name)
    return self:CreateWindow({Name = tostring(name or "Singularity")})
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

    local themeTab = window:CreateTab({Name = "Theme", Icon = true})
    themeTab:CreateSection("Appearance")
    themeTab:CreateDropdown({
        Name = "Theme",
        Options = {"Light Purple", "Blue", "Black", "White", "Red"},
        CurrentOption = "Blue",
        Callback = function(option)
            Singularity:SetTheme(option)
        end
    })
    themeTab:CreateParagraph({
        Title = "Aerial",
        Content = "Futuristic glass styling with rounded panels and soft transparent layers."
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




-- ============================================================================
local Themes = {
    ["Light Purple"]={Background=Color3.fromRGB(20,16,30),Secondary=Color3.fromRGB(30,23,45),Tertiary=Color3.fromRGB(46,34,67),Hover=Color3.fromRGB(65,45,92),Accent=Color3.fromRGB(190,125,255),AccentDark=Color3.fromRGB(125,70,190),Text=Color3.fromRGB(250,246,255),SubText=Color3.fromRGB(195,178,220),Muted=Color3.fromRGB(130,110,155),Stroke=Color3.fromRGB(105,75,140)},
    Blue={Background=Color3.fromRGB(5,12,24),Secondary=Color3.fromRGB(8,21,39),Tertiary=Color3.fromRGB(13,34,58),Hover=Color3.fromRGB(18,48,82),Accent=Color3.fromRGB(55,158,255),AccentDark=Color3.fromRGB(25,91,180),Text=Color3.fromRGB(239,247,255),SubText=Color3.fromRGB(150,183,219),Muted=Color3.fromRGB(83,119,157),Stroke=Color3.fromRGB(30,76,120)},
    Black={Background=Color3.fromRGB(7,7,9),Secondary=Color3.fromRGB(14,14,18),Tertiary=Color3.fromRGB(24,24,29),Hover=Color3.fromRGB(38,38,45),Accent=Color3.fromRGB(235,235,240),AccentDark=Color3.fromRGB(150,150,160),Text=Color3.fromRGB(255,255,255),SubText=Color3.fromRGB(180,180,188),Muted=Color3.fromRGB(105,105,112),Stroke=Color3.fromRGB(65,65,72)},
    White={Background=Color3.fromRGB(235,238,244),Secondary=Color3.fromRGB(248,249,252),Tertiary=Color3.fromRGB(225,228,235),Hover=Color3.fromRGB(210,214,224),Accent=Color3.fromRGB(55,105,220),AccentDark=Color3.fromRGB(35,75,165),Text=Color3.fromRGB(25,27,34),SubText=Color3.fromRGB(75,80,94),Muted=Color3.fromRGB(125,130,145),Stroke=Color3.fromRGB(180,184,195)},
    Red={Background=Color3.fromRGB(24,7,10),Secondary=Color3.fromRGB(39,10,15),Tertiary=Color3.fromRGB(60,15,23),Hover=Color3.fromRGB(85,20,31),Accent=Color3.fromRGB(255,78,98),AccentDark=Color3.fromRGB(185,38,55),Text=Color3.fromRGB(255,244,246),SubText=Color3.fromRGB(220,165,175),Muted=Color3.fromRGB(150,95,105),Stroke=Color3.fromRGB(125,40,52)}
}
function Singularity:SetTheme(themeName)
    local palette=Themes[themeName]
    if not palette then return false end
    for key,value in pairs(palette) do Theme[key]=value end
    return true
end
Singularity.Themes={"Light Purple","Blue","Black","White","Red"}

return Singularity
