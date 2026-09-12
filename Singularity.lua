-- ====================================================================
-- PERFORMANCE CACHING: Reduces CPU and memory overhead on mobile
-- ====================================================================
local c_Instance = Instance.new
local c_Color3   = Color3.fromRGB
local c_UDim2     = UDim2.new
local c_Enum      = Enum

local BlackHoleLib = {}
local WindowClass = {}
WindowClass.__index = WindowClass

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Global current window reference for shorthand creation style
local CurrentActiveContainer = nil
local CurrentActiveTheme = nil

-- High-performance internal helper for smooth, rounded corners
local function makeCorner(instance, radius)
    local corner = c_Instance("UICorner")
    corner.CornerRadius = c_UDim2(0, radius or 8)
    corner.Parent = instance
    return corner
end

-- Single global ScreenGui container for all Windows and Floating Buttons
local GlobalScreenGui = nil
local function getGlobalGui()
    if not GlobalScreenGui or not GlobalScreenGui.Parent then
        GlobalScreenGui = c_Instance("ScreenGui")
        GlobalScreenGui.Name = "BlackHole_PremiumSuite"
        GlobalScreenGui.ZIndexBehavior = c_Enum.ZIndexBehavior.Sibling
        GlobalScreenGui.Parent = game:GetService("CoreGui")
    end
    return GlobalScreenGui
end

-- ====================================================================
-- THEME CONFIGURATIONS (VIOLET, BLACK, RED, WHITE, BLUE)
-- ====================================================================
local Themes = {
    VIOLET = {
        Bg = c_Color3(10, 10, 15), Top = c_Color3(15, 12, 25), Stroke = c_Color3(45, 20, 80),
        Element = c_Color3(20, 18, 32), Accent = c_Color3(90, 40, 160), Text = c_Color3(240, 240, 255), SubText = c_Color3(200, 190, 220)
    },
    BLACK = {
        Bg = c_Color3(5, 5, 5), Top = c_Color3(15, 15, 15), Stroke = c_Color3(40, 40, 40),
        Element = c_Color3(22, 22, 22), Accent = c_Color3(200, 200, 200), Text = c_Color3(255, 255, 255), SubText = c_Color3(170, 170, 170)
    },
    RED = {
        Bg = c_Color3(15, 5, 5), Top = c_Color3(25, 10, 10), Stroke = c_Color3(90, 20, 20),
        Element = c_Color3(32, 15, 15), Accent = c_Color3(180, 30, 30), Text = c_Color3(255, 230, 230), SubText = c_Color3(220, 170, 170)
    },
    WHITE = {
        Bg = c_Color3(245, 245, 250), Top = c_Color3(230, 230, 235), Stroke = c_Color3(180, 180, 190),
        Element = c_Color3(255, 255, 255), Accent = c_Color3(60, 60, 70), Text = c_Color3(20, 20, 30), SubText = c_Color3(80, 80, 95)
    },
    BLUE = {
        Bg = c_Color3(5, 10, 20), Top = c_Color3(10, 15, 30), Stroke = c_Color3(20, 45, 90),
        Element = c_Color3(15, 22, 40), Accent = c_Color3(30, 90, 180), Text = c_Color3(230, 240, 255), SubText = c_Color3(170, 190, 220)
    }
}

-- ====================================================================
-- INDEPENDENT WINDOW INITIALIZER (Supports Multi-Window Structure)
-- ====================================================================
local function buildWindowFrame(title, isSettings, selectedTheme)
    local ScreenGui = getGlobalGui()
    local cfg = Themes[string.upper(tostring(selectedTheme or "VIOLET"))] or Themes.VIOLET
    
    local MainFrame = c_Instance("Frame")
    MainFrame.Name = isSettings and "SettingsFrame" or "MainFrame_" .. tostring(title)
    MainFrame.Size = c_UDim2(0, 440, 0, 260)
    
    if isSettings then
        MainFrame.Position = c_UDim2(0.5, 230, 0.5, -130)
    else
        local randomOffset = math.random(-20, 20)
        MainFrame.Position = c_UDim2(0.5, -220 + randomOffset, 0.5, -130 + randomOffset)
    end
    
    MainFrame.BackgroundColor3 = cfg.Bg
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    makeCorner(MainFrame, 12)
    
    local UIStroke = c_Instance("UIStroke")
    UIStroke.Thickness = 1.5
    UIStroke.Color = cfg.Stroke
    UIStroke.ApplyStrokeMode = c_Enum.ApplyStrokeMode.Border
    UIStroke.Parent = MainFrame
    
    local TopBar = c_Instance("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = c_UDim2(1, 0, 0, 40)
    TopBar.BackgroundColor3 = cfg.Top
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    makeCorner(TopBar, 12)
    
    local TitleLabel = c_Instance("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = c_UDim2(1, -20, 1, 0)
    TitleLabel.Position = c_UDim2(0, 15, 0, 0)
    TitleLabel.Text = tostring(title or "WINDOW")
    TitleLabel.TextColor3 = cfg.Text
    TitleLabel.TextXAlignment = c_Enum.TextXAlignment.Left
    TitleLabel.Font = c_Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = MainFrame
    
    local ContentScroll = c_Instance("ScrollingFrame")
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Size = c_UDim2(1, -20, 1, -55)
    ContentScroll.Position = c_UDim2(0, 10, 0, 48)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 3
    ContentScroll.ScrollBarImageColor3 = cfg.Stroke
    ContentScroll.CanvasSize = c_UDim2(0, 0, 0, 0)
    ContentScroll.Parent = MainFrame
    
    local UIListLayout = c_Instance("UIListLayout")
    UIListLayout.SortOrder = c_Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = ContentScroll
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentScroll.CanvasSize = c_UDim2(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    return MainFrame, ContentScroll, cfg
end

-- Settings Window Initialization Helper
local SettingsWindowCreated = false
local function initSettingsWindow(themeName)
    if SettingsWindowCreated then return end
    SettingsWindowCreated = true
    
    local MainFrame, ContentScroll, cfg = buildWindowFrame("⚙️ SETTINGS", true, themeName)
    
    local function addSettingsButton(text, cb)
        local Fr = c_Instance("Frame") Fr.Size = c_UDim2(1, -6, 0, 38) Fr.BackgroundColor3 = cfg.Element
        Fr.Parent = ContentScroll makeCorner(Fr, 8)
        local Btn = c_Instance("TextButton") Btn.Size = c_UDim2(1, 0, 1, 0) Btn.BackgroundTransparency = 1
        Btn.Text = text Btn.TextColor3 = cfg.SubText Btn.Font = c_Enum.Font.GothamMedium Btn.TextSize = 13 Btn.Parent = Fr
        Btn.MouseButton1Click:Connect(cb)
    end
    
    addSettingsButton("Unload GUI (Close All Menus)", function()
        local gui = getGlobalGui() if gui then gui:Destroy() end
    end)
end

function BlackHoleLib.CreateWindow(options)
    -- Memeriksa apakah inputnya berupa tabel (seperti Rayfield) atau teks biasa
    local title = type(options) == "table" and options.Name or tostring(options or "WINDOW")
    local themeName = type(options) == "table" and options.Theme or "VIOLET"
    
    initSettingsWindow(themeName)
    
    local MainFrame, ContentScroll, cfg = buildWindowFrame(title, false, themeName)
    
    CurrentActiveContainer = ContentScroll
    CurrentActiveTheme = cfg
    
    local ScreenGui = getGlobalGui()
    local FloatingButton = c_Instance("TextButton")
    FloatingButton.Name = "Toggle_" .. tostring(title)
    FloatingButton.Size = c_UDim2(0, 45, 0, 45)
    FloatingButton.Position = c_UDim2(0, 15, 0, 15)
    FloatingButton.BackgroundColor3 = cfg.Top
    FloatingButton.Text = "🕳️"
    FloatingButton.TextColor3 = cfg.Text
    FloatingButton.TextSize = 18
    FloatingButton.Active = true
    FloatingButton.Draggable = true 
    FloatingButton.Parent = ScreenGui
    makeCorner(FloatingButton, 22)
    
    local ButtonStroke = c_Instance("UIStroke")
    ButtonStroke.Thickness = 1.5
    ButtonStroke.Color = cfg.Accent
    ButtonStroke.Parent = FloatingButton

    local isOpen = true
    local isTweening = false
    local originalSize = c_UDim2(0, 440, 0, 260)
    local closedSize = c_UDim2(0, 440, 0, 0)
    local tweenInfoData = TweenInfo.new(0.3, c_Enum.EasingStyle.Quart, c_Enum.EasingDirection.Out)
    
    FloatingButton.MouseButton1Click:Connect(function()
        if isTweening then return end
        isTweening = true
        local targetSize = isOpen and closedSize or originalSize
        local tween = TweenService:Create(MainFrame, tweenInfoData, {Size = targetSize})
        tween:Play()
        tween.Completed:Connect(function()
            isOpen = not isOpen
            isTweening = false
            if not isOpen then MainFrame.Visible = false end
        end)
        if not isOpen then MainFrame.Visible = true end
    end)
end


function BlackHoleLib.CreateButton(text, callback)
    if not CurrentActiveContainer then return end
    local cfg = CurrentActiveTheme
    
    local Frame = c_Instance("Frame")
    Frame.Size = c_UDim2(1, -6, 0, 38)
    Frame.BackgroundColor3 = cfg.Element
    Frame.Parent = CurrentActiveContainer
    makeCorner(Frame, 8)
    
    local Button = c_Instance("TextButton")
    Button.Size = c_UDim2(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = text or "Button"
    Button.TextColor3 = cfg.SubText
    Button.Font = c_Enum.Font.GothamMedium
    Button.TextSize = 13
    Button.Parent = Frame
    
    Button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

function BlackHoleLib.CreateToggle(text, callback)
    if not CurrentActiveContainer then return end
    local cfg = CurrentActiveTheme
    
    local Frame = c_Instance("Frame")
    Frame.Size = c_UDim2(1, -6, 0, 38)
    Frame.BackgroundColor3 = cfg.Element
    Frame.Parent = CurrentActiveContainer
    makeCorner(Frame, 8)
    
    local Label = c_Instance("TextLabel")
    Label.Size = c_UDim2(1, -60, 1, 0)
    Label.Position = c_UDim2(0, 12, 0, 0)
    Label.Text = text or "Toggle"
    Label.TextColor3 = cfg.SubText
    Label.Font = c_Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = c_Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local Indicator = c_Instance("Frame")
    Indicator.Size = c_UDim2(0, 35, 0, 18)
    Indicator.Position = c_UDim2(1, -47, 0.5, -9)
    Indicator.BackgroundColor3 = cfg.Bg
    Indicator.Parent = Frame
    makeCorner(Indicator, 9)
    
    local Toggled = false
    local Clicker = c_Instance("TextButton")
    Clicker.Size = c_UDim2(1, 0, 1, 0)
    Clicker.BackgroundTransparency = 1
    Clicker.Text = ""
    Clicker.Parent = Frame
    
    Clicker.MouseButton1Click:Connect(function()
        Toggled = not Toggled
        Indicator.BackgroundColor3 = Toggled and cfg.Accent or cfg.Bg
        
        if callback then
            pcall(callback, Toggled)
        end
    end)
end

function BlackHoleLib.CreateSlider(text, min, max, default, callback)
    if not CurrentActiveContainer then return end
    local cfg = CurrentActiveTheme
    
    local Frame = c_Instance("Frame")
    Frame.Size = c_UDim2(1, -6, 0, 48)
    Frame.BackgroundColor3 = cfg.Element
    Frame.Parent = CurrentActiveContainer
    makeCorner(Frame, 8)
    
    local Label = c_Instance("TextLabel")
    Label.Size = c_UDim2(1, -100, 0, 22)
    Label.Position = c_UDim2(0, 12, 0, 2)
    Label.Text = text or "Slider"
    Label.TextColor3 = cfg.SubText
    Label.Font = c_Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = c_Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local ValueLabel = c_Instance("TextLabel")
    ValueLabel.Size = c_UDim2(0, 60, 0, 22)
    ValueLabel.Position = c_UDim2(1, -72, 0, 2)
    ValueLabel.Text = tostring(default or min)
    ValueLabel.TextColor3 = cfg.Accent
    ValueLabel.Font = c_Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = c_Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Parent = Frame
    
    local Track = c_Instance("Frame")
    Track.Size = c_UDim2(1, -24, 0, 6)
    Track.Position = c_UDim2(0, 12, 0, 32)
    Track.BackgroundColor3 = cfg.Bg
    Track.Parent = Frame
    makeCorner(Track, 3)
    
    local Fill = c_Instance("Frame")
    Fill.Size = c_UDim2(0, 100, 1, 0)
    Fill.BackgroundColor3 = cfg.Accent
    Fill.Parent = Track
    makeCorner(Fill, 3)
end

setmetatable(BlackHoleLib, {
    __call = function(t, title, themeName)
        t.CreateWindow(title, themeName)
        return t
    end
})

task.defer(initSettingsWindow)

return BlackHoleLib
