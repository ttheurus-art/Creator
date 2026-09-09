--[[
	Hexed - Black Hole Red Theme GUI Library
	Works like Rayfield but with Black Hole aesthetic
	Author: ttheurus-art
]]

local Hexed = {}
Hexed.__index = Hexed

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

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
		ButtonHover = Color3.fromRGB(30, 10, 10)
	}
}

-- ========== CREATE WINDOW ==========

function Hexed:CreateWindow(options)
	options = options or {}
	
	local Window = {}
	Window.Tabs = {}
	Window.TabObjects = {}
	Window.Theme = THEMES.BlackHole
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Main Screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HexedGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	
	-- Main Window Frame
	local mainWindow = Instance.new("Frame")
	mainWindow.Name = "MainWindow"
	mainWindow.BackgroundColor3 = Window.Theme.Background
	mainWindow.BorderSizePixel = 0
	mainWindow.Size = UDim2.new(0, 650, 0, 500)
	mainWindow.Position = UDim2.new(0.5, -325, 0.5, -250)
	mainWindow.Parent = screenGui
	
	-- Add glow border
	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = Window.Theme.Accent
	borderStroke.Thickness = 2
	borderStroke.Parent = mainWindow
	
	-- Corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainWindow
	
	-- Top Bar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.BackgroundColor3 = Window.Theme.Secondary
	topBar.BorderSizePixel = 0
	topBar.Size = UDim2.new(1, 0, 0, 45)
	topBar.Parent = mainWindow
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = options.Name or "Hexed"
	titleLabel.TextColor3 = Window.Theme.AccentLight
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -50, 1, 0)
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.Parent = topBar
	
	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Window.Theme.AccentLight
	closeBtn.TextSize = 24
	closeBtn.BackgroundColor3 = Window.Theme.Button
	closeBtn.BorderSizePixel = 0
	closeBtn.Size = UDim2.new(0, 45, 1, 0)
	closeBtn.Position = UDim2.new(1, -45, 0, 0)
	closeBtn.Parent = topBar
	
	closeBtn.MouseButton1Click:Connect(function()
		mainWindow.Visible = false
	end)
	
	-- Tab Buttons Frame
	local tabButtonsFrame = Instance.new("Frame")
	tabButtonsFrame.Name = "TabButtons"
	tabButtonsFrame.BackgroundColor3 = Window.Theme.Background
	tabButtonsFrame.BorderSizePixel = 0
	tabButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
	tabButtonsFrame.Position = UDim2.new(0, 0, 0, 45)
	tabButtonsFrame.Parent = mainWindow
	
	-- Divider
	local divider = Instance.new("Frame")
	divider.BackgroundColor3 = Window.Theme.Accent
	divider.BorderSizePixel = 0
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 0, 40)
	divider.Parent = tabButtonsFrame
	
	-- Content Frame
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, 0, 1, -85)
	contentFrame.Position = UDim2.new(0, 0, 0, 85)
	contentFrame.Parent = mainWindow
	
	-- Dragging
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
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainWindow.Position = UDim2.new(windowPos.X.Scale, windowPos.X.Offset + delta.X, windowPos.Y.Scale, windowPos.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	
	-- CreateTab Function
	function Window:CreateTab(tabName, tabIcon)
		local Tab = {}
		Tab.Name = tabName
		Tab.Sections = {}
		
		-- Tab Button
		local tabButton = Instance.new("TextButton")
		tabButton.Name = tabName .. "Button"
		tabButton.Text = tabName
		tabButton.TextColor3 = Window.Theme.TextSecondary
		tabButton.TextSize = 14
		tabButton.BackgroundColor3 = Window.Theme.Secondary
		tabButton.BorderSizePixel = 0
		tabButton.Size = UDim2.new(0, 120, 1, 0)
		tabButton.Position = UDim2.new(0, (#self.Tabs) * 120, 0, 0)
		tabButton.Parent = tabButtonsFrame
		
		-- Tab Content
		local tabContent = Instance.new("ScrollingFrame")
		tabContent.Name = tabName .. "Content"
		tabContent.BackgroundTransparency = 1
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.Position = UDim2.new(0, 0, 0, 0)
		tabContent.ScrollBarThickness = 6
		tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabContent.Visible = false
		tabContent.Parent = contentFrame
		
		-- UIListLayout for auto-sizing
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 5)
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = tabContent
		
		layout.Changed:Connect(function()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)
		
		Tab.ContentFrame = tabContent
		Tab.Button = tabButton
		Tab.Window = Window
		
		-- Tab Button Click
		tabButton.MouseButton1Click:Connect(function()
			for _, tab in pairs(self.TabObjects) do
				tab.ContentFrame.Visible = false
				tab.Button.BackgroundColor3 = Window.Theme.Secondary
				tab.Button.TextColor3 = Window.Theme.TextSecondary
			end
			tabContent.Visible = true
			tabButton.BackgroundColor3 = Window.Theme.Button
			tabButton.TextColor3 = Window.Theme.Accent
		end)
		
		if #self.Tabs == 0 then
			tabContent.Visible = true
			tabButton.BackgroundColor3 = Window.Theme.Button
			tabButton.TextColor3 = Window.Theme.Accent
		end
		
		table.insert(self.Tabs, tabName)
		table.insert(self.TabObjects, Tab)
		
		-- CreateSection
		function Tab:CreateSection(sectionName)
			local Section = {}
			Section.Name = sectionName
			Section.Elements = {}
			
			local sectionFrame = Instance.new("Frame")
			sectionFrame.Name = sectionName
			sectionFrame.BackgroundColor3 = Window.Theme.Secondary
			sectionFrame.BorderSizePixel = 0
			sectionFrame.Size = UDim2.new(1, -10, 0, 25)
			sectionFrame.Parent = tabContent
			
			local sectionLabel = Instance.new("TextLabel")
			sectionLabel.Text = sectionName
			sectionLabel.TextColor3 = Window.Theme.Accent
			sectionLabel.TextSize = 13
			sectionLabel.BackgroundTransparency = 1
			sectionLabel.Size = UDim2.new(1, 0, 1, 0)
			sectionLabel.Position = UDim2.new(0, 10, 0, 0)
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.Parent = sectionFrame
			
			Section.Frame = sectionFrame
			Section.Tab = Tab
			
			-- CreateButton
			function Section:CreateButton(options)
				local buttonFrame = Instance.new("Frame")
				buttonFrame.BackgroundColor3 = Window.Theme.Button
				buttonFrame.BorderSizePixel = 0
				buttonFrame.Size = UDim2.new(1, -10, 0, 40)
				buttonFrame.Parent = tabContent
				
				local stroke = Instance.new("UIStroke")
				stroke.Color = Window.Theme.Accent
				stroke.Thickness = 1
				stroke.Parent = buttonFrame
				
				local buttonText = Instance.new("TextButton")
				buttonText.Text = options.Name or "Button"
				buttonText.TextColor3 = Window.Theme.AccentLight
				buttonText.TextSize = 13
				buttonText.BackgroundTransparency = 1
				buttonText.Size = UDim2.new(1, 0, 1, 0)
				buttonText.Parent = buttonFrame
				
				buttonText.MouseButton1Click:Connect(function()
					if options.Callback then
						options.Callback()
					end
				end)
				
				buttonText.MouseEnter:Connect(function()
					buttonFrame.BackgroundColor3 = Window.Theme.ButtonHover
				end)
				
				buttonText.MouseLeave:Connect(function()
					buttonFrame.BackgroundColor3 = Window.Theme.Button
				end)
				
				return {Name = options.Name}
			end
			
			-- CreateToggle
			function Section:CreateToggle(options)
				local toggleFrame = Instance.new("Frame")
				toggleFrame.BackgroundColor3 = Window.Theme.Button
				toggleFrame.BorderSizePixel = 0
				toggleFrame.Size = UDim2.new(1, -10, 0, 40)
				toggleFrame.Parent = tabContent
				
				local stroke = Instance.new("UIStroke")
				stroke.Color = Window.Theme.Accent
				stroke.Thickness = 1
				stroke.Parent = toggleFrame
				
				local toggleLabel = Instance.new("TextLabel")
				toggleLabel.Text = options.Name or "Toggle"
				toggleLabel.TextColor3 = Window.Theme.AccentLight
				toggleLabel.TextSize = 13
				toggleLabel.BackgroundTransparency = 1
				toggleLabel.Size = UDim2.new(1, -50, 1, 0)
				toggleLabel.Position = UDim2.new(0, 10, 0, 0)
				toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
				toggleLabel.Parent = toggleFrame
				
				local toggleState = options.Default or false
				
				local toggleButton = Instance.new("TextButton")
				toggleButton.Text = toggleState and "ON" or "OFF"
				toggleButton.TextColor3 = Window.Theme.Text
				toggleButton.TextSize = 11
				toggleButton.BackgroundColor3 = toggleState and Window.Theme.Accent or Window.Theme.Secondary
				toggleButton.BorderSizePixel = 0
				toggleButton.Size = UDim2.new(0, 40, 0, 25)
				toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
				toggleButton.Parent = toggleFrame
				
				toggleButton.MouseButton1Click:Connect(function()
					toggleState = not toggleState
					toggleButton.Text = toggleState and "ON" or "OFF"
					toggleButton.BackgroundColor3 = toggleState and Window.Theme.Accent or Window.Theme.Secondary
					if options.Callback then
						options.Callback(toggleState)
					end
				end)
				
				return {State = toggleState}
			end
			
			-- CreateSlider
			function Section:CreateSlider(options)
				local sliderFrame = Instance.new("Frame")
				sliderFrame.BackgroundColor3 = Window.Theme.Button
				sliderFrame.BorderSizePixel = 0
				sliderFrame.Size = UDim2.new(1, -10, 0, 55)
				sliderFrame.Parent = tabContent
				
				local stroke = Instance.new("UIStroke")
				stroke.Color = Window.Theme.Accent
				stroke.Thickness = 1
				stroke.Parent = sliderFrame
				
				local sliderLabel = Instance.new("TextLabel")
				sliderLabel.Text = (options.Name or "Slider") .. ": " .. (options.Default or options.Min or 0)
				sliderLabel.TextColor3 = Window.Theme.AccentLight
				sliderLabel.TextSize = 12
				sliderLabel.BackgroundTransparency = 1
				sliderLabel.Size = UDim2.new(1, 0, 0, 15)
				sliderLabel.Position = UDim2.new(0, 10, 0, 5)
				sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				sliderLabel.Parent = sliderFrame
				
				local sliderBar = Instance.new("Frame")
				sliderBar.BackgroundColor3 = Window.Theme.Secondary
				sliderBar.BorderSizePixel = 0
				sliderBar.Size = UDim2.new(1, -20, 0, 4)
				sliderBar.Position = UDim2.new(0, 10, 0, 28)
				sliderBar.Parent = sliderFrame
				
				local sliderFill = Instance.new("Frame")
				sliderFill.BackgroundColor3 = Window.Theme.Accent
				sliderFill.BorderSizePixel = 0
				sliderFill.Size = UDim2.new(0, 0, 1, 0)
				sliderFill.Parent = sliderBar
				
				local min = options.Min or 0
				local max = options.Max or 100
				local value = options.Default or min
				
				local function updateSlider(input)
					local barSize = sliderBar.AbsoluteSize.X
					local mousePos = input.Position.X - sliderBar.AbsolutePosition.X
					local percent = math.clamp(mousePos / barSize, 0, 1)
					value = math.floor(min + (max - min) * percent)
					sliderFill.Size = UDim2.new(percent, 0, 1, 0)
					sliderLabel.Text = (options.Name or "Slider") .. ": " .. value
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
				
				return {Value = value}
			end
			
			-- CreateColorPicker
			function Section:CreateColorPicker(options)
				local colorFrame = Instance.new("Frame")
				colorFrame.BackgroundColor3 = Window.Theme.Button
				colorFrame.BorderSizePixel = 0
				colorFrame.Size = UDim2.new(1, -10, 0, 40)
				colorFrame.Parent = tabContent
				
				local stroke = Instance.new("UIStroke")
				stroke.Color = Window.Theme.Accent
				stroke.Thickness = 1
				stroke.Parent = colorFrame
				
				local colorLabel = Instance.new("TextLabel")
				colorLabel.Text = options.Name or "Color"
				colorLabel.TextColor3 = Window.Theme.AccentLight
				colorLabel.TextSize = 13
				colorLabel.BackgroundTransparency = 1
				colorLabel.Size = UDim2.new(1, -50, 1, 0)
				colorLabel.Position = UDim2.new(0, 10, 0, 0)
				colorLabel.TextXAlignment = Enum.TextXAlignment.Left
				colorLabel.Parent = colorFrame
				
				local colorBox = Instance.new("Frame")
				colorBox.BackgroundColor3 = options.Default or Color3.fromRGB(255, 255, 255)
				colorBox.BorderSizePixel = 0
				colorBox.Size = UDim2.new(0, 40, 0, 30)
				colorBox.Position = UDim2.new(1, -50, 0.5, -15)
				colorBox.Parent = colorFrame
				
				return {Color = options.Default or Color3.fromRGB(255, 255, 255)}
			end
			
			return Section
		end
		
		return Tab
	end
	
	Window.ScreenGui = screenGui
	Window.MainWindow = mainWindow
	
	return Window
end

return Hexed
