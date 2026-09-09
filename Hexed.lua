--[[
	Hexed - Black Hole Theme GUI Library for Roblox exploits
	Author: ttheurus-art
	Description: Red & black space theme, performance optimized
]]

local Hexed = {}
Hexed.__index = Hexed

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- ========== CONFIGURATION ==========

local DEFAULT_CONFIG = {
	Name = "Hexed Window",
	Icon = 0,
	Theme = "BlackHole",
	Position = "TopCenter",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil,
		FileName = "HexedConfig"
	}
}

-- ========== THEMES ==========

local THEMES = {
	BlackHole = {
		Background = Color3.fromRGB(10, 10, 20),
		Secondary = Color3.fromRGB(20, 15, 35),
		Accent = Color3.fromRGB(220, 50, 50),
		AccentLight = Color3.fromRGB(255, 80, 80),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 200),
		Button = Color3.fromRGB(0, 0, 0),
		ButtonHover = Color3.fromRGB(30, 10, 10),
		Glow = Color3.fromRGB(220, 50, 50)
	}
}

-- ========== WINDOW CLASS ==========

local Window = {}
Window.__index = Window

function Hexed:CreateWindow(config)
	config = setmetatable(config or {}, {__index = DEFAULT_CONFIG})
	
	local self = setmetatable({}, Window)
	self.Name = config.Name
	self.Icon = config.Icon
	self.Theme = THEMES[config.Theme] or THEMES.BlackHole
	self.ThemeName = config.Theme
	self.Config = config
	self.Tabs = {}
	self.TabOrder = {}
	self.IsOpen = true
	self.IsDragging = false
	self.DragOffset = Vector2.new(0, 0)
	self.Position = config.Position or "TopCenter"
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HexedGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	
	self.ScreenGui = screenGui
	self.PlayerGui = playerGui
	
	self:CreateMainWindow()
	self:CreateToggleButton()
	self:SetupResponsiveDesign()
	self:SetupDragging()
	
	return self
end

function Window:CreateMainWindow()
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "HexedMainFrame"
	mainFrame.BackgroundColor3 = self.Theme.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = self.ScreenGui
	
	local screenSize = self.ScreenGui.AbsoluteSize
	local width = math.min(screenSize.X * 0.6, 600)
	local height = math.min(screenSize.Y * 0.7, 700)
	
	mainFrame.Size = UDim2.new(0, width, 0, height)
	mainFrame.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
	
	-- Red glow border effect (optimized with minimal corners)
	local borderFrame = Instance.new("Frame")
	borderFrame.Name = "GlowBorder"
	borderFrame.BackgroundColor3 = self.Theme.Accent
	borderFrame.BorderSizePixel = 0
	borderFrame.Size = UDim2.new(1, 0, 1, 0)
	borderFrame.Position = UDim2.new(0, 0, 0, 0)
	borderFrame.Parent = mainFrame
	borderFrame.ZIndex = 0
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = borderFrame
	
	-- Inner content frame
	local innerFrame = Instance.new("Frame")
	innerFrame.Name = "InnerFrame"
	innerFrame.BackgroundColor3 = self.Theme.Background
	innerFrame.BorderSizePixel = 0
	innerFrame.Size = UDim2.new(1, -2, 1, -2)
	innerFrame.Position = UDim2.new(0, 1, 0, 1)
	innerFrame.Parent = mainFrame
	innerFrame.ZIndex = 1
	
	local innerCorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(0, 6)
	innerCorner.Parent = innerFrame
	
	-- Top bar (draggable)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.BackgroundColor3 = self.Theme.Secondary
	topBar.BorderSizePixel = 0
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.Parent = innerFrame
	
	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 6)
	topCorner.Parent = topBar
	
	-- Title with red glow
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = self.Name
	titleLabel.TextColor3 = self.Theme.AccentLight
	titleLabel.TextSize = 16
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -50, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = topBar
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Text = "×"
	closeButton.TextColor3 = self.Theme.AccentLight
	closeButton.TextSize = 24
	closeButton.BackgroundColor3 = self.Theme.Button
	closeButton.BorderSizePixel = 0
	closeButton.Size = UDim2.new(0, 40, 1, 0)
	closeButton.Position = UDim2.new(1, -40, 0, 0)
	closeButton.Parent = topBar
	
	closeButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	
	-- Tab buttons container
	local tabButtonsFrame = Instance.new("Frame")
	tabButtonsFrame.Name = "TabButtons"
	tabButtonsFrame.BackgroundColor3 = self.Theme.Background
	tabButtonsFrame.BorderSizePixel = 0
	tabButtonsFrame.Size = UDim2.new(1, 0, 0, 35)
	tabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
	tabButtonsFrame.Parent = innerFrame
	
	-- Tab content container
	local tabContentFrame = Instance.new("Frame")
	tabContentFrame.Name = "TabContent"
	tabContentFrame.BackgroundColor3 = self.Theme.Background
	tabContentFrame.BorderSizePixel = 0
	tabContentFrame.Size = UDim2.new(1, 0, 1, -75)
	tabContentFrame.Position = UDim2.new(0, 0, 0, 75)
	tabContentFrame.Parent = innerFrame
	
	self.MainFrame = mainFrame
	self.InnerFrame = innerFrame
	self.TopBar = topBar
	self.TabButtonsFrame = tabButtonsFrame
	self.TabContentFrame = tabContentFrame
end

function Window:CreateToggleButton()
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "HexedToggle"
	toggleButton.Text = "Show Hexed"
	toggleButton.TextColor3 = self.Theme.Text
	toggleButton.TextSize = 12
	toggleButton.BackgroundColor3 = self.Theme.Button
	toggleButton.BorderSizePixel = 0
	toggleButton.Parent = self.ScreenGui
	
	-- Add glow effect
	local glow = Instance.new("UIStroke")
	glow.Color = self.Theme.Accent
	glow.Thickness = 2
	glow.Parent = toggleButton
	
	if self.Position == "TopCenter" then
		toggleButton.Size = UDim2.new(0, 100, 0, 30)
		toggleButton.Position = UDim2.new(0.5, -50, 0, 5)
	elseif self.Position == "Cube" then
		toggleButton.Size = UDim2.new(0, 50, 0, 50)
		toggleButton.Text = "H"
		toggleButton.Position = UDim2.new(0, 10, 0, 5)
	end
	
	toggleButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	
	self.ToggleButton = toggleButton
end

function Window:CreateTab(name, icon)
	local tab = {
		Name = name,
		Icon = icon or 0,
		Sections = {},
		SectionOrder = {},
		Parent = self,
		IsActive = false
	}
	
	self.Tabs[name] = tab
	table.insert(self.TabOrder, name)
	
	self:CreateTabButton(name, tab)
	self:CreateTabContent(name, tab)
	
	return setmetatable(tab, {__index = Window})
end

function Window:CreateTabButton(name, tab)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = name .. "Button"
	tabButton.Text = name
	tabButton.TextColor3 = self.Theme.TextSecondary
	tabButton.TextSize = 12
	tabButton.BackgroundColor3 = self.Theme.Secondary
	tabButton.BorderSizePixel = 0
	tabButton.Size = UDim2.new(0, 100, 1, 0)
	tabButton.Parent = self.TabButtonsFrame
	
	local index = table.find(self.TabOrder, name) or 1
	tabButton.Position = UDim2.new(0, (index - 1) * 100, 0, 0)
	
	tabButton.MouseButton1Click:Connect(function()
		self:SelectTab(name)
	end)
	
	tab.Button = tabButton
end

function Window:CreateTabContent(name, tab)
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = name .. "Content"
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.Parent = self.TabContentFrame
	contentFrame.Visible = false
	
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.Size = UDim2.new(1, -5, 1, 0)
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.Parent = contentFrame
	
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 3)
	uiListLayout.Parent = scrollFrame
	
	tab.ContentFrame = contentFrame
	tab.ScrollFrame = scrollFrame
	tab.ListLayout = uiListLayout
end

function Window:SelectTab(name)
	for tabName, tab in pairs(self.Tabs) do
		if tab.ContentFrame then
			tab.ContentFrame.Visible = false
			if tab.Button then
				tab.Button.TextColor3 = self.Theme.TextSecondary
				tab.Button.BackgroundColor3 = self.Theme.Secondary
			end
		end
	end
	
	local tab = self.Tabs[name]
	if tab and tab.ContentFrame then
		tab.ContentFrame.Visible = true
		if tab.Button then
			tab.Button.TextColor3 = self.Theme.Accent
			tab.Button.BackgroundColor3 = self.Theme.Button
		end
	end
end

function Window:CreateSection(name)
	if not self.ScrollFrame then
		error("Section must be created inside a Tab")
	end
	
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Name = name
	sectionFrame.BackgroundColor3 = self.Theme.Secondary
	sectionFrame.BorderSizePixel = 0
	sectionFrame.Size = UDim2.new(1, -10, 0, 20)
	sectionFrame.Parent = self.ScrollFrame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = name
	titleLabel.TextColor3 = self.Theme.Accent
	titleLabel.TextSize = 12
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, 0, 1, 0)
	titleLabel.Position = UDim2.new(0, 5, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = sectionFrame
	
	local section = {
		Name = name,
		Frame = sectionFrame,
		Elements = {},
		Parent = self
	}
	
	table.insert(self.Sections, section)
	
	return section
end

function Window:CreateButton(config)
	if not self.ScrollFrame then
		error("Button must be created inside a Tab")
	end
	
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = config.Name
	buttonFrame.BackgroundColor3 = self.Theme.Button
	buttonFrame.BorderSizePixel = 0
	buttonFrame.Size = UDim2.new(1, -10, 0, 40)
	buttonFrame.Parent = self.ScrollFrame
	
	-- Red border/glow effect (minimal)
	local stroke = Instance.new("UIStroke")
	stroke.Color = self.Theme.Accent
	stroke.Thickness = 1
	stroke.Parent = buttonFrame
	
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Text = config.Name
	button.TextColor3 = self.Theme.AccentLight
	button.TextSize = 13
	button.BackgroundTransparency = 1
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Parent = buttonFrame
	
	if config.Description then
		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "Description"
		descLabel.Text = config.Description
		descLabel.TextColor3 = self.Theme.TextSecondary
		descLabel.TextSize = 10
		descLabel.BackgroundTransparency = 1
		descLabel.Size = UDim2.new(1, 0, 0.4, 0)
		descLabel.Position = UDim2.new(0, 5, 0.6, 0)
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = buttonFrame
	end
	
	button.MouseButton1Click:Connect(function()
		if config.Callback then
			config.Callback()
		end
	end)
	
	button.MouseEnter:Connect(function()
		buttonFrame.BackgroundColor3 = self.Theme.ButtonHover
	end)
	
	button.MouseLeave:Connect(function()
		buttonFrame.BackgroundColor3 = self.Theme.Button
	end)
	
	return {
		Name = config.Name,
		Frame = buttonFrame,
		Button = button,
		Callback = config.Callback
	}
end

function Window:CreateToggle(config)
	if not self.ScrollFrame then
		error("Toggle must be created inside a Tab")
	end
	
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = config.Name
	toggleFrame.BackgroundColor3 = self.Theme.Button
	toggleFrame.BorderSizePixel = 0
	toggleFrame.Size = UDim2.new(1, -10, 0, 40)
	toggleFrame.Parent = self.ScrollFrame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = self.Theme.Accent
	stroke.Thickness = 1
	stroke.Parent = toggleFrame
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Text = config.Name
	label.TextColor3 = self.Theme.AccentLight
	label.TextSize = 13
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -50, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = toggleFrame
	
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "Toggle"
	toggleButton.Text = config.Default and "ON" or "OFF"
	toggleButton.TextColor3 = self.Theme.Text
	toggleButton.TextSize = 11
	toggleButton.BackgroundColor3 = config.Default and self.Theme.Accent or self.Theme.Secondary
	toggleButton.BorderSizePixel = 0
	toggleButton.Size = UDim2.new(0, 40, 0, 25)
	toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
	toggleButton.Parent = toggleFrame
	
	local state = config.Default or false
	
	toggleButton.MouseButton1Click:Connect(function()
		state = not state
		toggleButton.Text = state and "ON" or "OFF"
		toggleButton.BackgroundColor3 = state and self.Theme.Accent or self.Theme.Secondary
		if config.Callback then
			config.Callback(state)
		end
	end)
	
	return {
		Name = config.Name,
		Frame = toggleFrame,
		Button = toggleButton,
		Value = state,
		Flag = config.Flag or config.Name
	}
end

function Window:CreateSlider(config)
	if not self.ScrollFrame then
		error("Slider must be created inside a Tab")
	end
	
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = config.Name
	sliderFrame.BackgroundColor3 = self.Theme.Button
	sliderFrame.BorderSizePixel = 0
	sliderFrame.Size = UDim2.new(1, -10, 0, 50)
	sliderFrame.Parent = self.ScrollFrame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = self.Theme.Accent
	stroke.Thickness = 1
	stroke.Parent = sliderFrame
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Text = config.Name .. ": " .. (config.Default or config.Min)
	label.TextColor3 = self.Theme.AccentLight
	label.TextSize = 11
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 15)
	label.Position = UDim2.new(0, 10, 0, 5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = sliderFrame
	
	local sliderBar = Instance.new("Frame")
	sliderBar.Name = "Bar"
	sliderBar.BackgroundColor3 = self.Theme.Secondary
	sliderBar.BorderSizePixel = 0
	sliderBar.Size = UDim2.new(1, -20, 0, 4)
	sliderBar.Position = UDim2.new(0, 10, 0, 28)
	sliderBar.Parent = sliderFrame
	
	local sliderFill = Instance.new("Frame")
	sliderFill.Name = "Fill"
	sliderFill.BackgroundColor3 = self.Theme.Accent
	sliderFill.BorderSizePixel = 0
	sliderFill.Size = UDim2.new(0, 0, 1, 0)
	sliderFill.Parent = sliderBar
	
	local value = config.Default or config.Min
	local min = config.Min or 0
	local max = config.Max or 100
	
	local function updateSlider(input)
		local barSize = sliderBar.AbsoluteSize.X
		local mousePos = input.Position.X - sliderBar.AbsolutePosition.X
		local percent = math.clamp(mousePos / barSize, 0, 1)
		value = math.floor(min + (max - min) * percent)
		sliderFill.Size = UDim2.new(percent, 0, 1, 0)
		label.Text = config.Name .. ": " .. value .. (config.Suffix or "")
		if config.Callback then
			config.Callback(value)
		end
	end
	
	sliderBar.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateSlider(input)
			local connection
			connection = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					updateSlider(input)
				end
			end)
			UserInputService.InputEnded:Connect(function()
				connection:Disconnect()
			end)
		end
	end)
	
	return {
		Name = config.Name,
		Frame = sliderFrame,
		Value = value,
		Flag = config.Flag or config.Name
	}
end

function Window:Toggle()
	self.IsOpen = not self.IsOpen
	self.InnerFrame.Visible = self.IsOpen
	self.ToggleButton.Visible = not self.IsOpen
end

function Window:SetupResponsiveDesign()
	local function adjustSize()
		local screenSize = self.ScreenGui.AbsoluteSize
		local width = math.min(screenSize.X * 0.6, 600)
		local height = math.min(screenSize.Y * 0.7, 700)
		
		self.MainFrame.Size = UDim2.new(0, width, 0, height)
		self.MainFrame.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
	end
	
	adjustSize()
	RunService.RenderStepped:Connect(adjustSize)
end

function Window:SetupDragging()
	local isDragging = false
	local dragStart = Vector2.new(0, 0)
	local windowStart = Vector2.new(0, 0)
	
	self.TopBar.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragStart = input.Position
			windowStart = self.MainFrame.AbsolutePosition
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local newPos = windowStart + delta
			self.MainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)
end

function Hexed.Notify(title, content, duration)
	duration = duration or 5
	print("[" .. title .. "] " .. content)
end

return Hexed
