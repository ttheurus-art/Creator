--[[
	Hexed - Black Hole Theme GUI Library for Roblox exploits
	Works exactly like Rayfield with Black Hole aesthetic animations
	Author: ttheurus-art
	Description: Professional GUI with smooth black hole animations
]]

local Hexed = {}
Hexed.__index = Hexed

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ========== CONFIGURATION ==========

local DEFAULT_CONFIG = {
	Name = "Hexed",
	LoadingTitle = "Hexed",
	LoadingSubtitle = "Loading...",
	Icon = 0,
	Theme = "BlackHole",
	Position = "TopCenter",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil,
		FileName = "HexedConfig"
	},
	Discord = {
		Enabled = false,
		Invite = ""
	},
	KeySystem = false
}

-- ========== COLOR THEMES ==========

local THEMES = {
	BlackHole = {
		Background = Color3.fromRGB(10, 10, 20),
		Secondary = Color3.fromRGB(20, 15, 35),
		Tertiary = Color3.fromRGB(25, 20, 40),
		Accent = Color3.fromRGB(220, 50, 50),
		AccentLight = Color3.fromRGB(255, 80, 80),
		AccentDark = Color3.fromRGB(180, 30, 30),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 200),
		TextDisabled = Color3.fromRGB(100, 100, 120),
		Button = Color3.fromRGB(0, 0, 0),
		ButtonHover = Color3.fromRGB(30, 10, 10),
		ButtonActive = Color3.fromRGB(50, 15, 15),
		Glow = Color3.fromRGB(220, 50, 50),
		GlowLight = Color3.fromRGB(255, 100, 100)
	}
}

-- ========== UTILITY FUNCTIONS ==========

local function CreateBlackHoleParticles(parent)
	local particlesFolder = Instance.new("Folder")
	particlesFolder.Name = "Particles"
	particlesFolder.Parent = parent
	
	for i = 1, 5 do
		local particle = Instance.new("Frame")
		particle.Name = "Particle" .. i
		particle.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
		particle.BorderSizePixel = 0
		particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
		particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
		particle.Parent = particlesFolder
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = particle
	end
	
	return particlesFolder
end

local function TweenSize(object, newSize, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local goal = {Size = newSize}
	local tween = TweenService:Create(object, tweenInfo, goal)
	tween:Play()
	return tween
end

local function TweenPosition(object, newPos, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local goal = {Position = newPos}
	local tween = TweenService:Create(object, tweenInfo, goal)
	tween:Play()
	return tween
end

local function TweenTransparency(object, newTransparency, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local goal = {BackgroundTransparency = newTransparency}
	local tween = TweenService:Create(object, tweenInfo, goal)
	tween:Play()
	return tween
end

-- ========== MAIN WINDOW CLASS ==========

function Hexed:CreateWindow(options)
	options = setmetatable(options or {}, {__index = DEFAULT_CONFIG})
	
	local Window = {}
	Window.Tabs = {}
	Window.TabObjects = {}
	Window.Theme = THEMES.BlackHole
	Window.IsOpen = true
	Window.Config = options
	Window.Connections = {}
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- ========== LOADING SCREEN ==========
	
	local loadingGui = Instance.new("ScreenGui")
	loadingGui.Name = "LoadingGui"
	loadingGui.ResetOnSpawn = false
	loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	loadingGui.Parent = playerGui
	
	-- Loading Background
	local loadingBg = Instance.new("Frame")
	loadingBg.Name = "LoadingBg"
	loadingBg.BackgroundColor3 = Window.Theme.Background
	loadingBg.BorderSizePixel = 0
	loadingBg.Size = UDim2.new(1, 0, 1, 0)
	loadingBg.Parent = loadingGui
	
	-- Black Hole Center
	local centerBlackHole = Instance.new("Frame")
	centerBlackHole.Name = "BlackHole"
	centerBlackHole.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	centerBlackHole.BorderSizePixel = 0
	centerBlackHole.Size = UDim2.new(0, 100, 0, 100)
	centerBlackHole.Position = UDim2.new(0.5, -50, 0.5, -50)
	centerBlackHole.Parent = loadingBg
	
	local holeCorner = Instance.new("UICorner")
	holeCorner.CornerRadius = UDim.new(1, 0)
	holeCorner.Parent = centerBlackHole
	
	-- Glow Ring
	local glowRing = Instance.new("Frame")
	glowRing.Name = "GlowRing"
	glowRing.BackgroundColor3 = Window.Theme.Accent
	glowRing.BorderSizePixel = 0
	glowRing.Size = UDim2.new(0, 120, 0, 120)
	glowRing.Position = UDim2.new(0.5, -60, 0.5, -60)
	glowRing.Parent = loadingBg
	
	local ringCorner = Instance.new("UICorner")
	ringCorner.CornerRadius = UDim.new(1, 0)
	ringCorner.Parent = glowRing
	
	local ringStroke = Instance.new("UIStroke")
	ringStroke.Color = Window.Theme.Accent
	ringStroke.Thickness = 2
	ringStroke.Parent = glowRing
	
	glowRing.BackgroundTransparency = 1
	
	-- Loading Text
	local loadingTitle = Instance.new("TextLabel")
	loadingTitle.Name = "Title"
	loadingTitle.Text = options.LoadingTitle or "Hexed"
	loadingTitle.TextColor3 = Window.Theme.AccentLight
	loadingTitle.TextSize = 24
	loadingTitle.BackgroundTransparency = 1
	loadingTitle.Size = UDim2.new(1, 0, 0, 50)
	loadingTitle.Position = UDim2.new(0, 0, 0.5, -80)
	loadingTitle.Parent = loadingBg
	
	local loadingSubtitle = Instance.new("TextLabel")
	loadingSubtitle.Name = "Subtitle"
	loadingSubtitle.Text = options.LoadingSubtitle or "Loading..."
	loadingSubtitle.TextColor3 = Window.Theme.TextSecondary
	loadingSubtitle.TextSize = 16
	loadingSubtitle.BackgroundTransparency = 1
	loadingSubtitle.Size = UDim2.new(1, 0, 0, 40)
	loadingSubtitle.Position = UDim2.new(0, 0, 0.5, 20)
	loadingSubtitle.Parent = loadingBg
	
	-- Loading Rotation Animation
	local rotationAngle = 0
	local rotationConnection
	rotationConnection = RunService.RenderStepped:Connect(function()
		rotationAngle = (rotationAngle + 3) % 360
		glowRing.Rotation = rotationAngle
	end)
	
	-- Wait before closing loading screen
	wait(2)
	
	rotationConnection:Disconnect()
	TweenTransparency(loadingBg, 1, 0.5)
	wait(0.5)
	loadingGui:Destroy()
	
	-- ========== MAIN SCREEN GUI ==========
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HexedGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	
	-- ========== MAIN WINDOW FRAME ==========
	
	local mainWindow = Instance.new("Frame")
	mainWindow.Name = "MainWindow"
	mainWindow.BackgroundColor3 = Window.Theme.Background
	mainWindow.BorderSizePixel = 0
	mainWindow.Size = UDim2.new(0, 700, 0, 550)
	mainWindow.Position = UDim2.new(0.5, -350, 0.5, -275)
	mainWindow.Visible = false
	mainWindow.Parent = screenGui
	
	-- Glow Border Stroke
	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = Window.Theme.Accent
	borderStroke.Thickness = 3
	borderStroke.Parent = mainWindow
	
	-- Corner Radius
	local windowCorner = Instance.new("UICorner")
	windowCorner.CornerRadius = UDim.new(0, 15)
	windowCorner.Parent = mainWindow
	
	-- ========== TOP BAR ==========
	
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.BackgroundColor3 = Window.Theme.Secondary
	topBar.BorderSizePixel = 0
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.Parent = mainWindow
	
	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 15)
	topBarCorner.Parent = topBar
	
	-- Top Bar Divider
	local topDivider = Instance.new("Frame")
	topDivider.BackgroundColor3 = Window.Theme.Accent
	topDivider.BorderSizePixel = 0
	topDivider.Size = UDim2.new(1, 0, 0, 2)
	topDivider.Position = UDim2.new(0, 0, 1, 0)
	topDivider.Parent = topBar
	
	-- Window Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = options.Name or "Hexed"
	titleLabel.TextColor3 = Window.Theme.AccentLight
	titleLabel.TextSize = 22
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -100, 1, 0)
	titleLabel.Position = UDim2.new(0, 20, 0, 0)
	titleLabel.Parent = topBar
	
	-- Window Icon/Logo (Animated Red Dot)
	local iconDot = Instance.new("Frame")
	iconDot.Name = "Icon"
	iconDot.BackgroundColor3 = Window.Theme.Accent
	iconDot.BorderSizePixel = 0
	iconDot.Size = UDim2.new(0, 12, 0, 12)
	iconDot.Position = UDim2.new(0, 5, 0.5, -6)
	iconDot.Parent = topBar
	
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(1, 0)
	iconCorner.Parent = iconDot
	
	-- Toggle Button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Text = "−"
	toggleBtn.TextColor3 = Window.Theme.AccentLight
	toggleBtn.TextSize = 18
	toggleBtn.BackgroundColor3 = Window.Theme.Button
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Size = UDim2.new(0, 40, 0, 40)
	toggleBtn.Position = UDim2.new(1, -90, 0.5, -20)
	toggleBtn.Parent = topBar
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleBtn
	
	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Color = Window.Theme.Accent
	toggleStroke.Thickness = 1
	toggleStroke.Parent = toggleBtn
	
	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Window.Theme.AccentLight
	closeBtn.TextSize = 28
	closeBtn.BackgroundColor3 = Window.Theme.Button
	closeBtn.BorderSizePixel = 0
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -45, 0.5, -20)
	closeBtn.Parent = topBar
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn
	
	local closeStroke = Instance.new("UIStroke")
	closeStroke.Color = Window.Theme.Accent
	closeStroke.Thickness = 1
	closeStroke.Parent = closeBtn
	
	-- ========== TAB BUTTONS FRAME ==========
	
	local tabButtonsFrame = Instance.new("Frame")
	tabButtonsFrame.Name = "TabButtons"
	tabButtonsFrame.BackgroundColor3 = Window.Theme.Background
	tabButtonsFrame.BorderSizePixel = 0
	tabButtonsFrame.Size = UDim2.new(1, 0, 0, 45)
	tabButtonsFrame.Position = UDim2.new(0, 0, 0, 50)
	tabButtonsFrame.Parent = mainWindow
	
	-- Tab Buttons ScrollingFrame
	local tabScroll = Instance.new("ScrollingFrame")
	tabScroll.Name = "TabScroll"
	tabScroll.BackgroundTransparency = 1
	tabScroll.Size = UDim2.new(1, 0, 1, 0)
	tabScroll.ScrollBarThickness = 0
	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScroll.Parent = tabButtonsFrame
	
	-- UIListLayout for tabs
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabScroll
	
	-- Tab Divider
	local tabDivider = Instance.new("Frame")
	tabDivider.BackgroundColor3 = Window.Theme.Accent
	tabDivider.BorderSizePixel = 0
	tabDivider.Size = UDim2.new(1, 0, 0, 2)
	tabDivider.Position = UDim2.new(0, 0, 1, 0)
	tabDivider.Parent = tabButtonsFrame
	
	-- ========== CONTENT FRAME ==========
	
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, 0, 1, -95)
	contentFrame.Position = UDim2.new(0, 0, 0, 95)
	contentFrame.Parent = mainWindow
	
	-- ========== DRAGGING SYSTEM ==========
	
	local isDragging = false
	local dragStart = nil
	local windowPos = nil
	
	topBar.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			dragStart = input.Position
			windowPos = mainWindow.Position
		end
	end)
	
	local dragConnection = UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainWindow.Position = UDim2.new(windowPos.X.Scale, windowPos.X.Offset + delta.X, windowPos.Y.Scale, windowPos.Y.Offset + delta.Y)
		end
	end)
	
	table.insert(Window.Connections, dragConnection)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	
	-- ========== TOGGLE & CLOSE FUNCTIONS ==========
	
	local function ShowWindow()
		Window.IsOpen = true
		mainWindow.Visible = true
		TweenSize(mainWindow, UDim2.new(0, 700, 0, 550), 0.3)
	end
	
	local function HideWindow()
		Window.IsOpen = false
		-- Black hole suck effect
		local suckTween = TweenSize(mainWindow, UDim2.new(0, 50, 0, 50), 0.4)
		suckTween.Completed:Connect(function()
			mainWindow.Visible = false
			mainWindow.Size = UDim2.new(0, 700, 0, 550)
		end)
	end
	
	toggleBtn.MouseButton1Click:Connect(function()
		if Window.IsOpen then
			HideWindow()
		else
			ShowWindow()
		end
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		HideWindow()
	end)
	
	-- ========== INITIAL APPEARANCE ANIMATION ==========
	
	mainWindow.Visible = true
	mainWindow.Size = UDim2.new(0, 50, 0, 50)
	mainWindow.Position = UDim2.new(0.5, -25, 0.5, -25)
	TweenSize(mainWindow, UDim2.new(0, 700, 0, 550), 0.5)
	TweenPosition(mainWindow, UDim2.new(0.5, -350, 0.5, -275), 0.5)
	
	-- ========== CREATE TAB FUNCTION ==========
	
	function Window:CreateTab(tabName, tabIcon)
		local Tab = {}
		Tab.Name = tabName
		Tab.Icon = tabIcon or 0
		Tab.Sections = {}
		Tab.Window = self
		
		-- Tab Button
		local tabButton = Instance.new("TextButton")
		tabButton.Name = tabName .. "Button"
		tabButton.Text = "  " .. tabName .. "  "
		tabButton.TextColor3 = Window.Theme.TextSecondary
		tabButton.TextSize = 13
		tabButton.BackgroundColor3 = Window.Theme.Secondary
		tabButton.BorderSizePixel = 0
		tabButton.Size = UDim2.new(0, 120, 1, 0)
		tabButton.AutomaticSize = Enum.AutomaticSize.X
		tabButton.Parent = tabScroll
		
		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 8)
		tabCorner.Parent = tabButton
		
		local tabStroke = Instance.new("UIStroke")
		tabStroke.Color = Window.Theme.Accent
		tabStroke.Thickness = 1
		tabStroke.Transparency = 1
		tabStroke.Parent = tabButton
		
		-- Tab Content ScrollingFrame
		local tabContent = Instance.new("ScrollingFrame")
		tabContent.Name = tabName .. "Content"
		tabContent.BackgroundTransparency = 1
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.Position = UDim2.new(0, 0, 0, 0)
		tabContent.ScrollBarThickness = 5
		tabContent.ScrollBarImageColor3 = Window.Theme.Accent
		tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabContent.Visible = false
		tabContent.Parent = contentFrame
		
		-- UIListLayout for content
		local contentLayout = Instance.new("UIListLayout")
		contentLayout.Padding = UDim.new(0, 8)
		contentLayout.FillDirection = Enum.FillDirection.Vertical
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.Parent = tabContent
		
		contentLayout.Changed:Connect(function()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 15)
		end)
		
		Tab.Button = tabButton
		Tab.ContentFrame = tabContent
		Tab.ContentLayout = contentLayout
		
		-- Tab Click Event
		tabButton.MouseButton1Click:Connect(function()
			for _, tabObj in pairs(self.TabObjects) do
				tabObj.ContentFrame.Visible = false
				tabObj.Button.BackgroundColor3 = Window.Theme.Secondary
				tabObj.Button.TextColor3 = Window.Theme.TextSecondary
				tabObj.Button.UIStroke.Transparency = 1
			end
			tabContent.Visible = true
			tabButton.BackgroundColor3 = Window.Theme.Button
			tabButton.TextColor3 = Window.Theme.Accent
			tabStroke.Transparency = 0
		end)
		
		-- Make first tab active
		if #self.Tabs == 0 then
			tabContent.Visible = true
			tabButton.BackgroundColor3 = Window.Theme.Button
			tabButton.TextColor3 = Window.Theme.Accent
			tabStroke.Transparency = 0
		end
		
		table.insert(self.Tabs, tabName)
		table.insert(self.TabObjects, Tab)
		
		-- ========== CREATE SECTION ==========
		
		function Tab:CreateSection(sectionName)
			local Section = {}
			Section.Name = sectionName
			Section.Elements = {}
			Section.Tab = Tab
			Section.Window = Window
			
			local sectionFrame = Instance.new("Frame")
			sectionFrame.Name = sectionName
			sectionFrame.BackgroundColor3 = Window.Theme.Secondary
			sectionFrame.BorderSizePixel = 0
			sectionFrame.Size = UDim2.new(1, -15, 0, 28)
			sectionFrame.Parent = tabContent
			
			local sectionCorner = Instance.new("UICorner")
			sectionCorner.CornerRadius = UDim.new(0, 8)
			sectionCorner.Parent = sectionFrame
			
			local sectionStroke = Instance.new("UIStroke")
			sectionStroke.Color = Window.Theme.Accent
			sectionStroke.Thickness = 1
			sectionStroke.Parent = sectionFrame
			
			local sectionLabel = Instance.new("TextLabel")
			sectionLabel.Text = sectionName
			sectionLabel.TextColor3 = Window.Theme.Accent
			sectionLabel.TextSize = 12
			sectionLabel.BackgroundTransparency = 1
			sectionLabel.Size = UDim2.new(1, 0, 1, 0)
			sectionLabel.Position = UDim2.new(0, 12, 0, 0)
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.Parent = sectionFrame
			
			Section.Frame = sectionFrame
			
			-- ========== CREATE BUTTON ==========
			
			function Section:CreateButton(options)
				options = options or {}
				
				local buttonFrame = Instance.new("Frame")
				buttonFrame.Name = options.Name or "Button"
				buttonFrame.BackgroundColor3 = Window.Theme.Button
				buttonFrame.BorderSizePixel = 0
				buttonFrame.Size = UDim2.new(1, -15, 0, 38)
				buttonFrame.Parent = tabContent
				
				local buttonCorner = Instance.new("UICorner")
				buttonCorner.CornerRadius = UDim.new(0, 8)
				buttonCorner.Parent = buttonFrame
				
				local buttonStroke = Instance.new("UIStroke")
				buttonStroke.Color = Window.Theme.Accent
				buttonStroke.Thickness = 1
				buttonStroke.Parent = buttonFrame
				
				local buttonText = Instance.new("TextButton")
				buttonText.Name = "Button"
				buttonText.Text = options.Name or "Button"
				buttonText.TextColor3 = Window.Theme.AccentLight
				buttonText.TextSize = 12
				buttonText.BackgroundTransparency = 1
				buttonText.Size = UDim2.new(1, 0, 1, 0)
				buttonText.Parent = buttonFrame
				
				local clickCount = 0
				
				buttonText.MouseButton1Click:Connect(function()
					clickCount = clickCount + 1
					
					-- Visual feedback
					TweenSize(buttonFrame, UDim2.new(1, -12, 0, 38), 0.1)
					wait(0.1)
					TweenSize(buttonFrame, UDim2.new(1, -15, 0, 38), 0.1)
					
					if options.Callback then
						options.Callback()
					end
				end)
				
				buttonText.MouseEnter:Connect(function()
					buttonFrame.BackgroundColor3 = Window.Theme.ButtonHover
					buttonStroke.Color = Window.Theme.AccentLight
				end)
				
				buttonText.MouseLeave:Connect(function()
					buttonFrame.BackgroundColor3 = Window.Theme.Button
					buttonStroke.Color = Window.Theme.Accent
				end)
				
				return {
					Name = options.Name,
					Frame = buttonFrame,
					Button = buttonText,
					ClickCount = clickCount
				}
			end
			
			-- ========== CREATE TOGGLE ==========
			
			function Section:CreateToggle(options)
				options = options or {}
				
				local toggleFrame = Instance.new("Frame")
				toggleFrame.Name = options.Name or "Toggle"
				toggleFrame.BackgroundColor3 = Window.Theme.Button
				toggleFrame.BorderSizePixel = 0
				toggleFrame.Size = UDim2.new(1, -15, 0, 38)
				toggleFrame.Parent = tabContent
				
				local toggleCorner = Instance.new("UICorner")
				toggleCorner.CornerRadius = UDim.new(0, 8)
				toggleCorner.Parent = toggleFrame
				
				local toggleStroke = Instance.new("UIStroke")
				toggleStroke.Color = Window.Theme.Accent
				toggleStroke.Thickness = 1
				toggleStroke.Parent = toggleFrame
				
				local toggleLabel = Instance.new("TextLabel")
				toggleLabel.Text = options.Name or "Toggle"
				toggleLabel.TextColor3 = Window.Theme.AccentLight
				toggleLabel.TextSize = 12
				toggleLabel.BackgroundTransparency = 1
				toggleLabel.Size = UDim2.new(1, -55, 1, 0)
				toggleLabel.Position = UDim2.new(0, 12, 0, 0)
				toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
				toggleLabel.Parent = toggleFrame
				
				local toggleState = options.Default or false
				
				local toggleButton = Instance.new("TextButton")
				toggleButton.Name = "ToggleButton"
				toggleButton.Text = toggleState and "ON" or "OFF"
				toggleButton.TextColor3 = Window.Theme.Text
				toggleButton.TextSize = 11
				toggleButton.BackgroundColor3 = toggleState and Window.Theme.Accent or Window.Theme.Secondary
				toggleButton.BorderSizePixel = 0
				toggleButton.Size = UDim2.new(0, 45, 0, 28)
				toggleButton.Position = UDim2.new(1, -50, 0.5, -14)
				toggleButton.Parent = toggleFrame
				
				local toggleCornerBtn = Instance.new("UICorner")
				toggleCornerBtn.CornerRadius = UDim.new(0, 6)
				toggleCornerBtn.Parent = toggleButton
				
				toggleButton.MouseButton1Click:Connect(function()
					toggleState = not toggleState
					toggleButton.Text = toggleState and "ON" or "OFF"
					toggleButton.BackgroundColor3 = toggleState and Window.Theme.Accent or Window.Theme.Secondary
					
					if options.Callback then
						options.Callback(toggleState)
					end
				end)
				
				toggleButton.MouseEnter:Connect(function()
					toggleFrame.BackgroundColor3 = Window.Theme.ButtonHover
					toggleStroke.Color = Window.Theme.AccentLight
				end)
				
				toggleButton.MouseLeave:Connect(function()
					toggleFrame.BackgroundColor3 = Window.Theme.Button
					toggleStroke.Color = Window.Theme.Accent
				end)
				
				return {
					Name = options.Name,
					Frame = toggleFrame,
					Button = toggleButton,
					State = toggleState
				}
			end
			
			-- ========== CREATE SLIDER ==========
			
			function Section:CreateSlider(options)
				options = options or {}
				
				local sliderFrame = Instance.new("Frame")
				sliderFrame.Name = options.Name or "Slider"
				sliderFrame.BackgroundColor3 = Window.Theme.Button
				sliderFrame.BorderSizePixel = 0
				sliderFrame.Size = UDim2.new(1, -15, 0, 60)
				sliderFrame.Parent = tabContent
				
				local sliderCorner = Instance.new("UICorner")
				sliderCorner.CornerRadius = UDim.new(0, 8)
				sliderCorner.Parent = sliderFrame
				
				local sliderStroke = Instance.new("UIStroke")
				sliderStroke.Color = Window.Theme.Accent
				sliderStroke.Thickness = 1
				sliderStroke.Parent = sliderFrame
				
				local sliderLabel = Instance.new("TextLabel")
				sliderLabel.Text = (options.Name or "Slider") .. ": " .. (options.Default or options.Min or 0)
				sliderLabel.TextColor3 = Window.Theme.AccentLight
				sliderLabel.TextSize = 12
				sliderLabel.BackgroundTransparency = 1
				sliderLabel.Size = UDim2.new(1, 0, 0, 18)
				sliderLabel.Position = UDim2.new(0, 12, 0, 5)
				sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				sliderLabel.Parent = sliderFrame
				
				local sliderBar = Instance.new("Frame")
				sliderBar.Name = "Bar"
				sliderBar.BackgroundColor3 = Window.Theme.Secondary
				sliderBar.BorderSizePixel = 0
				sliderBar.Size = UDim2.new(1, -24, 0, 4)
				sliderBar.Position = UDim2.new(0, 12, 0, 30)
				sliderBar.Parent = sliderFrame
				
				local sliderBarCorner = Instance.new("UICorner")
				sliderBarCorner.CornerRadius = UDim.new(1, 0)
				sliderBarCorner.Parent = sliderBar
				
				local sliderFill = Instance.new("Frame")
				sliderFill.Name = "Fill"
				sliderFill.BackgroundColor3 = Window.Theme.Accent
				sliderFill.BorderSizePixel = 0
				sliderFill.Size = UDim2.new(0, 0, 1, 0)
				sliderFill.Parent = sliderBar
				
				local sliderFillCorner = Instance.new("UICorner")
				sliderFillCorner.CornerRadius = UDim.new(1, 0)
				sliderFillCorner.Parent = sliderFill
				
				-- Slider Knob
				local sliderKnob = Instance.new("Frame")
				sliderKnob.Name = "Knob"
				sliderKnob.BackgroundColor3 = Window.Theme.Accent
				sliderKnob.BorderSizePixel = 0
				sliderKnob.Size = UDim2.new(0, 12, 0, 12)
				sliderKnob.Position = UDim2.new(0, -6, 0.5, -6)
				sliderKnob.Parent = sliderBar
				
				local knobCorner = Instance.new("UICorner")
				knobCorner.CornerRadius = UDim.new(1, 0)
				knobCorner.Parent = sliderKnob
				
				local min = options.Min or 0
				local max = options.Max or 100
				local value = options.Default or min
				
				local function updateSlider(input)
					local barSize = sliderBar.AbsoluteSize.X
					local mousePos = input.Position.X - sliderBar.AbsolutePosition.X
					local percent = math.clamp(mousePos / barSize, 0, 1)
					value = math.floor(min + (max - min) * percent)
					sliderFill.Size = UDim2.new(percent, 0, 1, 0)
					sliderLabel.Text = (options.Name or "Slider") .. ": " .. value .. (options.Suffix or "")
					
					if options.Callback then
						options.Callback(value)
					end
				end
				
				sliderBar.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						updateSlider(input)
						local conn
						conn = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								updateSlider(input)
							end
						end)
						UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								conn:Disconnect()
							end
						end)
					end
				end)
				
				sliderBar.MouseEnter:Connect(function()
					sliderFrame.BackgroundColor3 = Window.Theme.ButtonHover
					sliderStroke.Color = Window.Theme.AccentLight
				end)
				
				sliderBar.MouseLeave:Connect(function()
					sliderFrame.BackgroundColor3 = Window.Theme.Button
					sliderStroke.Color = Window.Theme.Accent
				end)
				
				return {
					Name = options.Name,
					Frame = sliderFrame,
					Value = value
				}
			end
			
			-- ========== CREATE COLOR PICKER ==========
			
			function Section:CreateColorPicker(options)
				options = options or {}
				
				local colorFrame = Instance.new("Frame")
				colorFrame.Name = options.Name or "ColorPicker"
				colorFrame.BackgroundColor3 = Window.Theme.Button
				colorFrame.BorderSizePixel = 0
				colorFrame.Size = UDim2.new(1, -15, 0, 38)
				colorFrame.Parent = tabContent
				
				local colorCorner = Instance.new("UICorner")
				colorCorner.CornerRadius = UDim.new(0, 8)
				colorCorner.Parent = colorFrame
				
				local colorStroke = Instance.new("UIStroke")
				colorStroke.Color = Window.Theme.Accent
				colorStroke.Thickness = 1
				colorStroke.Parent = colorFrame
				
				local colorLabel = Instance.new("TextLabel")
				colorLabel.Text = options.Name or "Color"
				colorLabel.TextColor3 = Window.Theme.AccentLight
				colorLabel.TextSize = 12
				colorLabel.BackgroundTransparency = 1
				colorLabel.Size = UDim2.new(1, -55, 1, 0)
				colorLabel.Position = UDim2.new(0, 12, 0, 0)
				colorLabel.TextXAlignment = Enum.TextXAlignment.Left
				colorLabel.Parent = colorFrame
				
				local colorBox = Instance.new("Frame")
				colorBox.BackgroundColor3 = options.Default or Color3.fromRGB(255, 0, 0)
				colorBox.BorderSizePixel = 0
				colorBox.Size = UDim2.new(0, 40, 0, 28)
				colorBox.Position = UDim2.new(1, -45, 0.5, -14)
				colorBox.Parent = colorFrame
				
				local colorCornerBox = Instance.new("UICorner")
				colorCornerBox.CornerRadius = UDim.new(0, 6)
				colorCornerBox.Parent = colorBox
				
				colorBox.MouseButton1Click:Connect(function()
					-- Simple color selection (in real implementation, you'd use a color picker UI)
					if options.Callback then
						options.Callback(colorBox.BackgroundColor3)
					end
				end)
				
				colorFrame.MouseEnter:Connect(function()
					colorFrame.BackgroundColor3 = Window.Theme.ButtonHover
					colorStroke.Color = Window.Theme.AccentLight
				end)
				
				colorFrame.MouseLeave:Connect(function()
					colorFrame.BackgroundColor3 = Window.Theme.Button
					colorStroke.Color = Window.Theme.Accent
				end)
				
				return {
					Name = options.Name,
					Frame = colorFrame,
					Color = options.Default or Color3.fromRGB(255, 0, 0)
				}
			end
			
			-- ========== CREATE TEXT BOX ==========
			
			function Section:CreateTextBox(options)
				options = options or {}
				
				local textBoxFrame = Instance.new("Frame")
				textBoxFrame.Name = options.Name or "TextBox"
				textBoxFrame.BackgroundColor3 = Window.Theme.Button
				textBoxFrame.BorderSizePixel = 0
				textBoxFrame.Size = UDim2.new(1, -15, 0, 38)
				textBoxFrame.Parent = tabContent
				
				local textBoxCorner = Instance.new("UICorner")
				textBoxCorner.CornerRadius = UDim.new(0, 8)
				textBoxCorner.Parent = textBoxFrame
				
				local textBoxStroke = Instance.new("UIStroke")
				textBoxStroke.Color = Window.Theme.Accent
				textBoxStroke.Thickness = 1
				textBoxStroke.Parent = textBoxFrame
				
				local textInput = Instance.new("TextBox")
				textInput.Name = "Input"
				textInput.Text = options.Default or ""
				textInput.PlaceholderText = options.Placeholder or ""
				textInput.TextColor3 = Window.Theme.AccentLight
				textInput.PlaceholderColor3 = Window.Theme.TextSecondary
				textInput.TextSize = 12
				textInput.BackgroundTransparency = 1
				textInput.Size = UDim2.new(1, 0, 1, 0)
				textInput.Position = UDim2.new(0, 12, 0, 0)
				textInput.Parent = textBoxFrame
				
				textInput.FocusLost:Connect(function()
					if options.Callback then
						options.Callback(textInput.Text)
					end
				end)
				
				textBoxFrame.MouseEnter:Connect(function()
					textBoxFrame.BackgroundColor3 = Window.Theme.ButtonHover
					textBoxStroke.Color = Window.Theme.AccentLight
				end)
				
				textBoxFrame.MouseLeave:Connect(function()
					textBoxFrame.BackgroundColor3 = Window.Theme.Button
					textBoxStroke.Color = Window.Theme.Accent
				end)
				
				return {
					Name = options.Name,
					Frame = textBoxFrame,
					TextBox = textInput
				}
			end
			
			return Section
		end
		
		return Tab
	end
	
	Window.ScreenGui = screenGui
	Window.MainWindow = mainWindow
	Window.ShowWindow = ShowWindow
	Window.HideWindow = HideWindow
	
	return Window
end

-- ========== NOTIFICATION SYSTEM ==========

function Hexed.Notify(options)
	options = options or {}
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local notifGui = Instance.new("ScreenGui")
	notifGui.Name = "NotificationGui"
	notifGui.ResetOnSpawn = false
	notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	notifGui.Parent = playerGui
	
	local notifFrame = Instance.new("Frame")
	notifFrame.Name = "NotificationFrame"
	notifFrame.BackgroundColor3 = THEMES.BlackHole.Secondary
	notifFrame.BorderSizePixel = 0
	notifFrame.Size = UDim2.new(0, 300, 0, 80)
	notifFrame.Position = UDim2.new(0, 20, 1, -100)
	notifFrame.Parent = notifGui
	
	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 8)
	notifCorner.Parent = notifFrame
	
	local notifStroke = Instance.new("UIStroke")
	notifStroke.Color = THEMES.BlackHole.Accent
	notifStroke.Thickness = 2
	notifStroke.Parent = notifFrame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = options.Title or "Notification"
	titleLabel.TextColor3 = THEMES.BlackHole.AccentLight
	titleLabel.TextSize = 14
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, 0, 0, 25)
	titleLabel.Position = UDim2.new(0, 10, 0, 5)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notifFrame
	
	local contentLabel = Instance.new("TextLabel")
	contentLabel.Text = options.Content or ""
	contentLabel.TextColor3 = THEMES.BlackHole.TextSecondary
	contentLabel.TextSize = 12
	contentLabel.BackgroundTransparency = 1
	contentLabel.Size = UDim2.new(1, -20, 1, -30)
	contentLabel.Position = UDim2.new(0, 10, 0, 30)
	contentLabel.TextWrapped = true
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextYAlignment = Enum.TextYAlignment.Top
	contentLabel.Parent = notifFrame
	
	wait(options.Duration or 3)
	
	TweenTransparency(notifFrame, 1, 0.3)
	wait(0.3)
	notifGui:Destroy()
end

return Hexed
