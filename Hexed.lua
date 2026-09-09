--[[
	Hexed - Black Hole Red Theme GUI Library
	Works 80% like Rayfield
	Author: ttheurus-art
]]

local Hexed = {}
Hexed.__index = Hexed

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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

function Hexed:CreateWindow(config)
	config = config or {}
	
	local Window = {}
	Window.Tabs = {}
	Window.TabObjects = {}
	Window.Theme = THEMES.BlackHole
	Window.Config = config
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Main ScreenGui
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
	mainWindow.Size = UDim2.new(0, 600, 0, 400)
	mainWindow.Position = UDim2.new(0.5, -300, 0.5, -200)
	mainWindow.Parent = screenGui
	
	-- Add border
	local stroke = Instance.new("UIStroke")
	stroke.Color = Window.Theme.Accent
	stroke.Thickness = 2
	stroke.Parent = mainWindow
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainWindow
	
	-- Top Bar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.BackgroundColor3 = Window.Theme.Secondary
	topBar.BorderSizePixel = 0
	topBar.Size = UDim2.new(1, 0, 0, 45)
	topBar.Parent = mainWindow
	
	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 12)
	topCorner.Parent = topBar
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = config.Name or "Hexed"
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
	
	-- Tab Buttons Container
	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabContainer"
	tabContainer.BackgroundColor3 = Window.Theme.Background
	tabContainer.BorderSizePixel = 0
	tabContainer.Size = UDim2.new(1, 0, 0, 35)
	tabContainer.Position = UDim2.new(0, 0, 0, 45)
	tabContainer.Parent = mainWindow
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabContainer
	
	-- Content Container
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.BackgroundTransparency = 1
	contentContainer.Size = UDim2.new(1, 0, 1, -80)
	contentContainer.Position = UDim2.new(0, 0, 0, 80)
	contentContainer.Parent = mainWindow
	
	-- Dragging
	local isDragging = false
	local dragStart = nil
	local windowStart = nil
	
	topBar.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			dragStart = input.Position
			windowStart = mainWindow.Position
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainWindow.Position = UDim2.new(windowStart.X.Scale, windowStart.X.Offset + delta.X, windowStart.Y.Scale, windowStart.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	
	-- Close Function
	closeBtn.MouseButton1Click:Connect(function()
		mainWindow.Visible = false
	end)
	
	-- CreateTab Function
	function Window:CreateTab(tabName, tabIcon)
		local Tab = {}
		Tab.Name = tabName
		Tab.Sections = {}
		Tab.Window = self
		
		-- Tab Button
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = tabName .. "Tab"
		tabBtn.Text = tabName
		tabBtn.TextColor3 = Window.Theme.TextSecondary
		tabBtn.TextSize = 13
		tabBtn.BackgroundColor3 = Window.Theme.Secondary
		tabBtn.BorderSizePixel = 0
		tabBtn.Size = UDim2.new(0, 100, 1, 0)
		tabBtn.Parent = tabContainer
		
		local tabBtnCorner = Instance.new("UICorner")
		tabBtnCorner.CornerRadius = UDim.new(0, 6)
		tabBtnCorner.Parent = tabBtn
		
		-- Tab Content
		local tabContent = Instance.new("ScrollingFrame")
		tabContent.Name = tabName .. "Content"
		tabContent.BackgroundTransparency = 1
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.ScrollBarThickness = 5
		tabContent.ScrollBarImageColor3 = Window.Theme.Accent
		tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabContent.Visible = false
		tabContent.Parent = contentContainer
		
		local tabLayout = Instance.new("UIListLayout")
		tabLayout.Padding = UDim.new(0, 5)
		tabLayout.FillDirection = Enum.FillDirection.Vertical
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Parent = tabContent
		
		tabLayout.Changed:Connect(function()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
		end)
		
		Tab.Button = tabBtn
		Tab.ContentFrame = tabContent
		
		-- Tab Button Click
		tabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(self.TabObjects) do
				t.ContentFrame.Visible = false
				t.Button.BackgroundColor3 = Window.Theme.Secondary
				t.Button.TextColor3 = Window.Theme.TextSecondary
			end
			tabContent.Visible = true
			tabBtn.BackgroundColor3 = Window.Theme.Button
			tabBtn.TextColor3 = Window.Theme.Accent
		end)
		
		-- Activate first tab
		if #self.Tabs == 0 then
			tabContent.Visible = true
			tabBtn.BackgroundColor3 = Window.Theme.Button
			tabBtn.TextColor3 = Window.Theme.Accent
		end
		
		table.insert(self.Tabs, tabName)
		table.insert(self.TabObjects, Tab)
		
		-- CreateSection
		function Tab:CreateSection(sectionName)
			local Section = {}
			Section.Name = sectionName
			Section.Tab = Tab
			Section.Window = Window
			
			local sectionLabel = Instance.new("TextLabel")
			sectionLabel.Name = sectionName
			sectionLabel.Text = sectionName
			sectionLabel.TextColor3 = Window.Theme.Accent
			sectionLabel.TextSize = 12
			sectionLabel.BackgroundTransparency = 1
			sectionLabel.Size = UDim2.new(1, -10, 0, 20)
			sectionLabel.Position = UDim2.new(0, 5, 0, 0)
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.Parent = tabContent
			
			Section.Frame = sectionLabel
			
			-- CreateButton
			function Section:CreateButton(options)
				options = options or {}
				
				local buttonFrame = Instance.new("Frame")
				buttonFrame.Name = options.Name or "Button"
				buttonFrame.BackgroundColor3 = Window.Theme.Button
				buttonFrame.BorderSizePixel = 0
				buttonFrame.Size = UDim2.new(1, -10, 0, 35)
				buttonFrame.Parent = tabContent
				
				local btnStroke = Instance.new("UIStroke")
				btnStroke.Color = Window.Theme.Accent
				btnStroke.Thickness = 1
				btnStroke.Parent = buttonFrame
				
				local btnCorner = Instance.new("UICorner")
				btnCorner.CornerRadius = UDim.new(0, 6)
				btnCorner.Parent = buttonFrame
				
				local btn = Instance.new("TextButton")
				btn.Name = "Button"
				btn.Text = options.Name or "Button"
				btn.TextColor3 = Window.Theme.AccentLight
				btn.TextSize = 13
				btn.BackgroundTransparency = 1
				btn.Size = UDim2.new(1, 0, 1, 0)
				btn.Parent = buttonFrame
				
				btn.MouseButton1Click:Connect(function()
					if options.Callback then
						options.Callback()
					end
				end)
				
				btn.MouseEnter:Connect(function()
					buttonFrame.BackgroundColor3 = Window.Theme.ButtonHover
				end)
				
				btn.MouseLeave:Connect(function()
					buttonFrame.BackgroundColor3 = Window.Theme.Button
				end)
				
				return btn
			end
			
			-- CreateToggle
			function Section:CreateToggle(options)
				options = options or {}
				
				local toggleFrame = Instance.new("Frame")
				toggleFrame.Name = options.Name or "Toggle"
				toggleFrame.BackgroundColor3 = Window.Theme.Button
				toggleFrame.BorderSizePixel = 0
				toggleFrame.Size = UDim2.new(1, -10, 0, 35)
				toggleFrame.Parent = tabContent
				
				local togStroke = Instance.new("UIStroke")
				togStroke.Color = Window.Theme.Accent
				togStroke.Thickness = 1
				togStroke.Parent = toggleFrame
				
				local togCorner = Instance.new("UICorner")
				togCorner.CornerRadius = UDim.new(0, 6)
				togCorner.Parent = toggleFrame
				
				local togLabel = Instance.new("TextLabel")
				togLabel.Text = options.Name or "Toggle"
				togLabel.TextColor3 = Window.Theme.AccentLight
				togLabel.TextSize = 13
				togLabel.BackgroundTransparency = 1
				togLabel.Size = UDim2.new(1, -50, 1, 0)
				togLabel.Position = UDim2.new(0, 10, 0, 0)
				togLabel.TextXAlignment = Enum.TextXAlignment.Left
				togLabel.Parent = toggleFrame
				
				local state = options.Default or false
				
				local togBtn = Instance.new("TextButton")
				togBtn.Name = "TogButton"
				togBtn.Text = state and "ON" or "OFF"
				togBtn.TextColor3 = Window.Theme.Text
				togBtn.TextSize = 11
				togBtn.BackgroundColor3 = state and Window.Theme.Accent or Window.Theme.Secondary
				togBtn.BorderSizePixel = 0
				togBtn.Size = UDim2.new(0, 40, 0, 25)
				togBtn.Position = UDim2.new(1, -45, 0.5, -12)
				togBtn.Parent = toggleFrame
				
				local togBtnCorner = Instance.new("UICorner")
				togBtnCorner.CornerRadius = UDim.new(0, 5)
				togBtnCorner.Parent = togBtn
				
				togBtn.MouseButton1Click:Connect(function()
					state = not state
					togBtn.Text = state and "ON" or "OFF"
					togBtn.BackgroundColor3 = state and Window.Theme.Accent or Window.Theme.Secondary
					if options.Callback then
						options.Callback(state)
					end
				end)
				
				return {State = state}
			end
			
			-- CreateSlider
			function Section:CreateSlider(options)
				options = options or {}
				
				local sliderFrame = Instance.new("Frame")
				sliderFrame.Name = options.Name or "Slider"
				sliderFrame.BackgroundColor3 = Window.Theme.Button
				sliderFrame.BorderSizePixel = 0
				sliderFrame.Size = UDim2.new(1, -10, 0, 50)
				sliderFrame.Parent = tabContent
				
				local sliderCorner = Instance.new("UICorner")
				sliderCorner.CornerRadius = UDim.new(0, 6)
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
				sliderLabel.Size = UDim2.new(1, 0, 0, 15)
				sliderLabel.Position = UDim2.new(0, 10, 0, 5)
				sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				sliderLabel.Parent = sliderFrame
				
				local sliderBar = Instance.new("Frame")
				sliderBar.BackgroundColor3 = Window.Theme.Secondary
				sliderBar.BorderSizePixel = 0
				sliderBar.Size = UDim2.new(1, -20, 0, 4)
				sliderBar.Position = UDim2.new(0, 10, 0, 25)
				sliderBar.Parent = sliderFrame
				
				local barCorner = Instance.new("UICorner")
				barCorner.CornerRadius = UDim.new(1, 0)
				barCorner.Parent = sliderBar
				
				local sliderFill = Instance.new("Frame")
				sliderFill.BackgroundColor3 = Window.Theme.Accent
				sliderFill.BorderSizePixel = 0
				sliderFill.Size = UDim2.new(0, 0, 1, 0)
				sliderFill.Parent = sliderBar
				
				local fillCorner = Instance.new("UICorner")
				fillCorner.CornerRadius = UDim.new(1, 0)
				fillCorner.Parent = sliderFill
				
				local min = options.Min or 0
				local max = options.Max or 100
				local value = options.Default or min
				
				local function update(input)
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
						update(input)
						local conn
						conn = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								update(input)
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
				options = options or {}
				
				local colorFrame = Instance.new("Frame")
				colorFrame.Name = options.Name or "ColorPicker"
				colorFrame.BackgroundColor3 = Window.Theme.Button
				colorFrame.BorderSizePixel = 0
				colorFrame.Size = UDim2.new(1, -10, 0, 35)
				colorFrame.Parent = tabContent
				
				local colorCorner = Instance.new("UICorner")
				colorCorner.CornerRadius = UDim.new(0, 6)
				colorCorner.Parent = colorFrame
				
				local colorStroke = Instance.new("UIStroke")
				colorStroke.Color = Window.Theme.Accent
				colorStroke.Thickness = 1
				colorStroke.Parent = colorFrame
				
				local colorLabel = Instance.new("TextLabel")
				colorLabel.Text = options.Name or "Color"
				colorLabel.TextColor3 = Window.Theme.AccentLight
				colorLabel.TextSize = 13
				colorLabel.BackgroundTransparency = 1
				colorLabel.Size = UDim2.new(1, -45, 1, 0)
				colorLabel.Position = UDim2.new(0, 10, 0, 0)
				colorLabel.TextXAlignment = Enum.TextXAlignment.Left
				colorLabel.Parent = colorFrame
				
				local colorBox = Instance.new("Frame")
				colorBox.BackgroundColor3 = options.Default or Color3.fromRGB(255, 0, 0)
				colorBox.BorderSizePixel = 0
				colorBox.Size = UDim2.new(0, 30, 0, 25)
				colorBox.Position = UDim2.new(1, -35, 0.5, -12)
				colorBox.Parent = colorFrame
				
				local colorBoxCorner = Instance.new("UICorner")
				colorBoxCorner.CornerRadius = UDim.new(0, 5)
				colorBoxCorner.Parent = colorBox
				
				return {Color = options.Default or Color3.fromRGB(255, 0, 0)}
			end
			
			-- CreateTextBox
			function Section:CreateTextBox(options)
				options = options or {}
				
				local textBoxFrame = Instance.new("Frame")
				textBoxFrame.Name = options.Name or "TextBox"
				textBoxFrame.BackgroundColor3 = Window.Theme.Button
				textBoxFrame.BorderSizePixel = 0
				textBoxFrame.Size = UDim2.new(1, -10, 0, 35)
				textBoxFrame.Parent = tabContent
				
				local textCorner = Instance.new("UICorner")
				textCorner.CornerRadius = UDim.new(0, 6)
				textCorner.Parent = textBoxFrame
				
				local textStroke = Instance.new("UIStroke")
				textStroke.Color = Window.Theme.Accent
				textStroke.Thickness = 1
				textStroke.Parent = textBoxFrame
				
				local textInput = Instance.new("TextBox")
				textInput.Name = "Input"
				textInput.Text = options.Default or ""
				textInput.PlaceholderText = options.Placeholder or "Enter text..."
				textInput.TextColor3 = Window.Theme.AccentLight
				textInput.PlaceholderColor3 = Window.Theme.TextSecondary
				textInput.TextSize = 13
				textInput.BackgroundTransparency = 1
				textInput.Size = UDim2.new(1, -10, 1, 0)
				textInput.Position = UDim2.new(0, 5, 0, 0)
				textInput.Parent = textBoxFrame
				
				textInput.FocusLost:Connect(function()
					if options.Callback then
						options.Callback(textInput.Text)
					end
				end)
				
				return {Value = textInput.Text}
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
