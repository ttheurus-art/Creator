--[[
    Singularity UI Library
    Original UI library
    Theme: Singularity
]]

local Singularity = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(9, 8, 14),
    Secondary = Color3.fromRGB(15, 13, 23),
    Tertiary = Color3.fromRGB(22, 19, 33),

    Accent = Color3.fromRGB(145, 75, 255),
    AccentDark = Color3.fromRGB(91, 43, 170),

    Text = Color3.fromRGB(245, 242, 255),
    SubText = Color3.fromRGB(164, 158, 181),
    Muted = Color3.fromRGB(105, 99, 120),

    Stroke = Color3.fromRGB(48, 42, 65),

    Success = Color3.fromRGB(91, 220, 145),
    Danger = Color3.fromRGB(235, 85, 105)
}

local WindowClass = {}
WindowClass.__index = WindowClass

local TabClass = {}
TabClass.__index = TabClass

local CurrentWindow = nil
local Gui = nil

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
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            time or 0.2,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()

    return tween
end

local function MakeDraggable(handle, object)
    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
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
end

local function GetParent()
    local success, result = pcall(function()
        return CoreGui
    end)

    if success and result then
        return result
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

local function Notify(title, content, duration)
    if not Gui then
        return
    end

    local holder = Gui:FindFirstChild("Notifications")

    if not holder then
        holder = Create("Frame", {
            Name = "Notifications",
            Parent = Gui,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 1, -20),
            Position = UDim2.new(1, -315, 0, 10)
        })

        local layout = Create("UIListLayout", {
            Parent = holder,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        })
    end

    local notification = Create("Frame", {
        Parent = holder,
        BackgroundColor3 = Theme.Secondary,
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

    local titleLabel = CreateText(
        notification,
        title or "Singularity",
        14,
        Theme.Text
    )

    titleLabel.Position = UDim2.new(0, 15, 0, 7)
    titleLabel.Size = UDim2.new(1, -25, 0, 24)
    titleLabel.Font = Enum.Font.GothamBold

    local contentLabel = CreateText(
        notification,
        content or "",
        12,
        Theme.SubText
    )

    contentLabel.Position = UDim2.new(0, 15, 0, 31)
    contentLabel.Size = UDim2.new(1, -25, 0, 28)

    notification.Position = UDim2.new(1, 40, 0, 0)

    Tween(notification, 0.35, {
        Position = UDim2.new(0, 0, 0, 0)
    })

    task.delay(duration or 3, function()
        if notification and notification.Parent then
            Tween(notification, 0.3, {
                Position = UDim2.new(1, 40, 0, 0)
            })

            task.wait(0.35)

            if notification then
                notification:Destroy()
            end
        end
    end)
end

Singularity.Notify = Notify

function TabClass:CreateSection(text)
    local section = Create("TextLabel", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 28),
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
        Size = UDim2.new(1, -10, 0, 70)
    })

    Corner(holder, 8)
    Stroke(holder)

    local title = CreateText(
        holder,
        data.Title or "Information",
        13,
        Theme.Text
    )

    title.Position = UDim2.new(0, 12, 0, 7)
    title.Size = UDim2.new(1, -24, 0, 22)
    title.Font = Enum.Font.GothamBold

    local content = CreateText(
        holder,
        data.Content or "",
        11,
        Theme.SubText
    )

    content.Position = UDim2.new(0, 12, 0, 29)
    content.Size = UDim2.new(1, -24, 0, 32)
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
        Size = UDim2.new(1, -10, 0, 42),
        Text = data.Name or "Button",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false
    })

    Corner(button, 8)
    Stroke(button)

    button.MouseEnter:Connect(function()
        Tween(button, 0.15, {
            BackgroundColor3 = Theme.Tertiary
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, 0.15, {
            BackgroundColor3 = Theme.Secondary
        })
    end)

    button.MouseButton1Click:Connect(function()
        if typeof(data.Callback) == "function" then
            task.spawn(data.Callback)
        end
    end)

    return button
end

function TabClass:CreateToggle(data)
    data = data or {}

    local value = data.CurrentValue == true

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, -10, 0, 46)
    })

    Corner(holder, 8)
    Stroke(holder)

    local label = CreateText(
        holder,
        data.Name or "Toggle",
        13,
        Theme.Text
    )

    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -65, 1, 0)

    local switch = Create("TextButton", {
        Parent = holder,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(1, -52, 0.5, -10),
        Size = UDim2.new(0, 40, 0, 20),
        Text = "",
        AutoButtonColor = false
    })

    Corner(switch, 10)

    local knob = Create("Frame", {
        Parent = switch,
        BackgroundColor3 = Theme.Muted,
        Position = UDim2.new(0, 3, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14)
    })

    Corner(knob, 7)

    local function SetValue(newValue, callback)
        value = newValue == true

        if value then
            Tween(switch, 0.2, {
                BackgroundColor3 = Theme.AccentDark
            })

            Tween(knob, 0.2, {
                BackgroundColor3 = Theme.Accent,
                Position = UDim2.new(1, -17, 0.5, -7)
            })
        else
            Tween(switch, 0.2, {
                BackgroundColor3 = Theme.Tertiary
            })

            Tween(knob, 0.2, {
                BackgroundColor3 = Theme.Muted,
                Position = UDim2.new(0, 3, 0.5, -7)
            })
        end

        if callback ~= false and typeof(data.Callback) == "function" then
            task.spawn(data.Callback, value)
        end
    end

    switch.MouseButton1Click:Connect(function()
        SetValue(not value)
    end)

    SetValue(value, false)

    return {
        Holder = holder,
        Set = function(_, newValue)
            SetValue(newValue)
        end,
        Get = function()
            return value
        end
    }
end

function TabClass:CreateSlider(data)
    data = data or {}

    local min = data.Range and data.Range[1] or 0
    local max = data.Range and data.Range[2] or 100
    local value = data.CurrentValue or min

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, -10, 0, 65)
    })

    Corner(holder, 8)
    Stroke(holder)

    local label = CreateText(
        holder,
        data.Name or "Slider",
        13,
        Theme.Text
    )

    label.Position = UDim2.new(0, 12, 0, 7)
    label.Size = UDim2.new(1, -70, 0, 22)

    local valueLabel = CreateText(
        holder,
        tostring(value),
        12,
        Theme.Accent
    )

    valueLabel.Position = UDim2.new(1, -55, 0, 7)
    valueLabel.Size = UDim2.new(0, 43, 0, 22)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Create("Frame", {
        Parent = holder,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(1, -24, 0, 7)
    })

    Corner(bar, 4)

    local fill = Create("Frame", {
        Parent = bar,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0)
    })

    Corner(fill, 4)

    local dragging = false

    local function SetValue(newValue)
        newValue = math.clamp(newValue, min, max)
        value = math.floor(newValue)

        local percent = 0

        if max ~= min then
            percent = (value - min) / (max - min)
        end

        Tween(fill, 0.08, {
            Size = UDim2.new(percent, 0, 1, 0)
        })

        valueLabel.Text = tostring(value)

        if typeof(data.Callback) == "function" then
            task.spawn(data.Callback, value)
        end
    end

    local function Update(input)
        local x = input.Position.X
        local start = bar.AbsolutePosition.X
        local width = bar.AbsoluteSize.X

        local percent = math.clamp(
            (x - start) / width,
            0,
            1
        )

        SetValue(min + ((max - min) * percent))
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            Update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    SetValue(value)

    return {
        Holder = holder,
        Set = function(_, newValue)
            SetValue(newValue)
        end,
        Get = function()
            return value
        end
    }
end

function TabClass:CreateDropdown(data)
    data = data or {}

    local options = data.Options or {}
    local current = data.CurrentOption or options[1]

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, -10, 0, 45),
        ClipsDescendants = true
    })

    Corner(holder, 8)
    Stroke(holder)

    local button = Create("TextButton", {
        Parent = holder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 45),
        Text = "",
        AutoButtonColor = false
    })

    local label = CreateText(
        button,
        data.Name or "Dropdown",
        13,
        Theme.Text
    )

    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(0.5, 0, 1, 0)

    local selected = CreateText(
        button,
        tostring(current or "None"),
        12,
        Theme.Accent
    )

    selected.Position = UDim2.new(0.5, 0, 0, 0)
    selected.Size = UDim2.new(0.45, -12, 1, 0)
    selected.TextXAlignment = Enum.TextXAlignment.Right

    local list = Create("Frame", {
        Parent = holder,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(0, 8, 0, 48),
        Size = UDim2.new(1, -16, 0, 0),
        Visible = false
    })

    Corner(list, 7)

    local layout = Create("UIListLayout", {
        Parent = list,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local open = false

    local function Rebuild()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for index, option in ipairs(options) do
            local optionButton = Create("TextButton", {
                Parent = list,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Text = tostring(option),
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false,
                LayoutOrder = index
            })

            optionButton.MouseButton1Click:Connect(function()
                current = option
                selected.Text = tostring(option)

                if typeof(data.Callback) == "function" then
                    task.spawn(data.Callback, option)
                end

                open = false
                list.Visible = false

                Tween(holder, 0.2, {
                    Size = UDim2.new(1, -10, 0, 45)
                })

                Tween(list, 0.2, {
                    Size = UDim2.new(1, -16, 0, 0)
                })
            end)
        }
    end

    button.MouseButton1Click:Connect(function()
        open = not open

        if open then
            list.Visible = true

            local height = math.min(#options * 34 + 4, 170)

            Tween(holder, 0.2, {
                Size = UDim2.new(1, -10, 0, 53 + height)
            })

            Tween(list, 0.2, {
                Size = UDim2.new(1, -16, 0, height)
            })
        else
            Tween(holder, 0.2, {
                Size = UDim2.new(1, -10, 0, 45)
            })

            Tween(list, 0.2, {
                Size = UDim2.new(1, -16, 0, 0)
            })

            task.delay(0.2, function()
                if not open then
                    list.Visible = false
                end
            end)
        end
    end)

    Rebuild()

    return {
        Holder = holder,

        Set = function(_, option)
            current = option
            selected.Text = tostring(option)

            if typeof(data.Callback) == "function" then
                task.spawn(data.Callback, option)
            end
        end,

        Get = function()
            return current
        end,

        Refresh = function(_, newOptions)
            options = newOptions or {}
            Rebuild()
        end
    }
end

function TabClass:CreateKeybind(data)
    data = data or {}

    local currentKey = data.CurrentKeybind or Enum.KeyCode.RightShift

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, -10, 0, 45)
    })

    Corner(holder, 8)
    Stroke(holder)

    local label = CreateText(
        holder,
        data.Name or "Keybind",
        13,
        Theme.Text
    )

    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(0.55, 0, 1, 0)

    local keyButton = Create("TextButton", {
        Parent = holder,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(1, -90, 0.5, -14),
        Size = UDim2.new(0, 78, 0, 28),
        Text = currentKey.Name,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    })

    Corner(keyButton, 6)
    Stroke(keyButton)

    local listening = false

    keyButton.MouseButton1Click:Connect(function()
        listening = true
        keyButton.Text = "Press..."
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            listening = false
            keyButton.Text = currentKey.Name

            if typeof(data.ChangedCallback) == "function" then
                task.spawn(data.ChangedCallback, currentKey)
            end

            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == currentKey then

            if typeof(data.Callback) == "function" then
                task.spawn(data.Callback)
            end
        end
    end)

    return {
        Holder = holder,

        Set = function(_, key)
            if typeof(key) == "EnumItem" then
                currentKey = key
                keyButton.Text = key.Name
            end
        end,

        Get = function()
            return currentKey
        end
    }
end

function TabClass:CreateColorPicker(data)
    data = data or {}

    local colors = {
        Color3.fromRGB(145, 75, 255),
        Color3.fromRGB(75, 145, 255),
        Color3.fromRGB(75, 255, 170),
        Color3.fromRGB(255, 145, 75),
        Color3.fromRGB(255, 75, 120)
    }

    local index = 1

    local holder = Create("Frame", {
        Parent = self.Container,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, -10, 0, 45)
    })

    Corner(holder, 8)
    Stroke(holder)

    local label = CreateText(
        holder,
        data.Name or "Color",
        13,
        Theme.Text
    )

    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -70, 1, 0)

    local colorButton = Create("TextButton", {
        Parent = holder,
        BackgroundColor3 = colors[index],
        Position = UDim2.new(1, -50, 0.5, -13),
        Size = UDim2.new(0, 38, 0, 26),
        Text = "",
        AutoButtonColor = false
    })

    Corner(colorButton, 7)

    colorButton.MouseButton1Click:Connect(function()
        index = index + 1

        if index > #colors then
            index = 1
        end

        colorButton.BackgroundColor3 = colors[index]

        if typeof(data.Callback) == "function" then
            task.spawn(data.Callback, colors[index])
        end
    end)

    return {
        Holder = holder,
        Get = function()
            return colors[index]
        end
    }
end

function WindowClass:CreateTab(data)
    data = data or {}

    local tabName = data.Name or "Tab"

    local tabButton = Create("TextButton", {
        Parent = self.TabButtons,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 38),
        Text = tabName,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false
    })

    Corner(tabButton, 7)

    local container = Create("ScrollingFrame", {
        Parent = self.Pages,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false
    })

    Padding(container, 5, 5, 5, 10)

    local layout = Create("UIListLayout", {
        Parent = container,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local tab = setmetatable({
        Window = self,
        Name = tabName,
        Button = tabButton,
        Container = container
    }, TabClass)

    table.insert(self.Tabs, tab)

    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function WindowClass:SelectTab(tab)
    for _, other in ipairs(self.Tabs) do
        local active = other == tab

        other.Container.Visible = active

        if active then
            Tween(other.Button, 0.18, {
                BackgroundColor3 = Theme.Tertiary,
                TextColor3 = Theme.Text
            })
        else
            Tween(other.Button, 0.18, {
                BackgroundColor3 = Theme.Secondary,
                TextColor3 = Theme.SubText
            })
        end
    end

    self.SelectedTab = tab
end

function WindowClass:_CreateCompact()
    local compact = Create("TextButton", {
        Parent = Gui,
        BackgroundColor3 = Theme.Secondary,
        Position = UDim2.new(0, 20, 0.5, -25),
        Size = UDim2.new(0, 120, 0, 50),
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
        Position = UDim2.new(0, 12, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10)
    })

    Corner(dot, 5)

    compact.MouseButton1Click:Connect(function()
        self:Open()
    end)

    MakeDraggable(compact, compact)

    self.CompactButton = compact
end

function WindowClass:_CreateNormalMinimize()
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
end

function WindowClass:_AnimateMain(show)
    if show then
        self.Main.Visible = true

        self.Main.Size = UDim2.new(
            0,
            0,
            0,
            0
        )

        Tween(self.Main, 0.35, {
            Size = self.OriginalSize
        })
    else
        Tween(self.Main, 0.25, {
            Size = UDim2.new(0, 0, 0, 0)
        })

        task.delay(0.25, function()
            if not self.Opened then
                self.Main.Visible = false
            end
        end)
    end
end

function WindowClass:Close()
    if not self.Opened then
        return
    end

    self.Opened = false

    self:_AnimateMain(false)

    if self.CloseMode == "Compact" and self.CompactButton then
        self.CompactButton.Visible = true

        self.CompactButton.Size = UDim2.new(0, 0, 0, 50)

        Tween(self.CompactButton, 0.3, {
            Size = UDim2.new(0, 120, 0, 50)
        })
    end
end

function WindowClass:Open()
    if self.Opened then
        return
    end

    self.Opened = true

    if self.CompactButton then
        Tween(self.CompactButton, 0.2, {
            Size = UDim2.new(0, 0, 0, 50)
        })

        task.delay(0.2, function()
            self.CompactButton.Visible = false
        end)
    end

    self:_AnimateMain(true)
end

function WindowClass:Toggle()
    if self.Opened then
        self:Close()
    else
        self:Open()
    end
end

function WindowClass:Minimize()
    if not self.Opened then
        return
    end

    self.Opened = false
    self.Minimized = true

    Tween(self.Main, 0.3, {
        Size = UDim2.new(
            0,
            self.OriginalSize.X.Offset,
            0,
            0
        )
    })

    task.delay(0.3, function()
        if self.Minimized then
            self.Main.Visible = false
        end
    end)
end

function WindowClass:Restore()
    if not self.Minimized then
        return
    end

    self.Minimized = false
    self.Opened = true

    self.Main.Visible = true

    self.Main.Size = UDim2.new(
        0,
        self.OriginalSize.X.Offset,
        0,
        0
    )

    Tween(self.Main, 0.3, {
        Size = self.OriginalSize
    })
end

function WindowClass:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    if self.Main then
        self.Main:Destroy()
    end

    if self.CompactButton then
        self.CompactButton:Destroy()
    end

    if CurrentWindow == self then
        CurrentWindow = nil
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
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local main = Create("Frame", {
        Parent = Gui,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -190),
        Size = UDim2.new(0, 600, 0, 380),
        ClipsDescendants = true
    })

    Corner(main, 12)
    Stroke(main, Theme.Stroke, 1)

    local topbar = Create("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 52)
    })

    local title = CreateText(
        topbar,
        data.Name or "Singularity",
        15,
        Theme.Text
    )

    title.Position = UDim2.new(0, 18, 0, 0)
    title.Size = UDim2.new(1, -130, 1, 0)
    title.Font = Enum.Font.GothamBold

    local subtitle = CreateText(
        topbar,
        data.Subtitle or "Original UI Library",
        10,
        Theme.SubText
    )

    subtitle.Position = UDim2.new(0, 18, 0, 27)
    subtitle.Size = UDim2.new(1, -130, 0, 18)

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

    Corner(minimize, 7)

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

    Corner(close, 7)

    local sidebar = Create("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.Secondary,
        Position = UDim2.new(0, 0, 0, 52),
        Size = UDim2.new(0, 145, 1, -52)
    })

    local tabButtons = Create("ScrollingFrame", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 8),
        Size = UDim2.new(1, -12, 1, -16),
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
        Position = UDim2.new(0, 145, 0, 52),
        Size = UDim2.new(1, -145, 1, -52)
    })

    local window = setmetatable({
        Main = main,
        Topbar = topbar,
        TabButtons = tabButtons,
        Pages = pages,
        MinimizeButton = minimize,
        CloseButton = close,

        Tabs = {},
        SelectedTab = nil,

        Opened = true,
        Minimized = false,
        Destroyed = false,

        CloseMode = closeMode,

        OriginalSize = UDim2.new(0, 600, 0, 380)
    }, WindowClass)

    CurrentWindow = window

    MakeDraggable(topbar, main)

    close.MouseButton1Click:Connect(function()
        window:Close()
    end)

    window:_CreateNormalMinimize()

    if closeMode == "Compact" then
        window:_CreateCompact()
    end

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
    if theme ~= "Singularity" then
        return false
    end

    return true
end

return Singularity
