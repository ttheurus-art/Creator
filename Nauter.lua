--[[
    NAUTER UI LIBRARY — WindUI-compatible wrapper
    Version: 1.1.0

    Load:
      local Nauter = loadstring(game:HttpGet("YOUR_RAW_NAUTER_URL"))()
      local Window = Nauter:CreateWindow({ Title = "Nauter" })
      local Tab = Window:CreateTab({ Title = "Main" })
      Tab:CreateButton({ Title = "Test", Callback = function() print("clicked") end })

    This library wraps WindUI and keeps Native references available so callers can
    access WindUI's native API when they need features not covered by the wrapper.
]]

local Nauter = {}
Nauter.__index = Nauter
Nauter.Version = "1.1.0"
Nauter.Name = "Nauter"

local WINDUI_URL = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
local WindUI
local WindUIError

local COLORS = {
    Background = Color3.fromRGB(10, 13, 11),
    Panel = Color3.fromRGB(17, 22, 18),
    PanelInner = Color3.fromRGB(22, 28, 23),
    PanelHover = Color3.fromRGB(29, 38, 30),
    BorderOuter = Color3.fromRGB(20, 66, 37),
    BorderInner = Color3.fromRGB(31, 94, 52),
    Accent = Color3.fromRGB(45, 150, 82),
    AccentDark = Color3.fromRGB(24, 91, 49),
    Text = Color3.fromRGB(240, 246, 241),
    Muted = Color3.fromRGB(163, 179, 166),
    Success = Color3.fromRGB(84, 218, 129),
    Warning = Color3.fromRGB(242, 190, 77),
    Error = Color3.fromRGB(240, 91, 91),
}

local function copyTable(source)
    local result = {}
    for key, value in pairs(source or {}) do result[key] = value end
    return result
end

local function safeCall(object, methodName, ...)
    if object == nil then return false, "missing object" end
    local method = object[methodName]
    if type(method) ~= "function" then return false, "missing method: " .. tostring(methodName) end
    return pcall(method, object, ...)
end

local function firstSuccessful(object, methods, ...)
    local args = table.pack(...)
    local lastError
    for _, methodName in ipairs(methods) do
        local ok, result = safeCall(object, methodName, table.unpack(args, 1, args.n))
        if ok then return true, result, methodName end
        lastError = result
    end
    return false, lastError
end

local function loadWindUI(customUrl)
    if WindUI then return WindUI end
    local url = customUrl or WINDUI_URL
    local ok, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk = loadstring(source)
        assert(type(chunk) == "function", "WindUI source did not return a function")
        return chunk()
    end)
    if not ok then
        WindUIError = tostring(result)
        error("Nauter could not load WindUI: " .. WindUIError, 2)
    end
    WindUI = result
    return WindUI
end

local function normalizeConfig(config)
    config = config or {}
    return {
        Title = config.Title or config.Name or "Nauter",
        Icon = config.Icon or "leaf",
        Author = config.Author or "Nauter Library",
        Folder = config.Folder or "Nauter",
        Size = config.Size or config.WindowSize,
        MinSize = config.MinSize,
        SideBarWidth = config.SideBarWidth,
        Acrylic = config.Acrylic,
        Transparent = config.Transparent,
        Theme = config.Theme,
        URL = config.WindUIURL,
        NativeConfig = config.NativeConfig or {},
    }
end

local function nativeWindowConfig(config)
    local result = copyTable(config.NativeConfig)
    result.Title = config.Title
    result.Icon = config.Icon
    result.Author = config.Author
    result.Folder = config.Folder
    if config.Size then result.Size = config.Size end
    if config.MinSize then result.MinSize = config.MinSize end
    if config.SideBarWidth then result.SideBarWidth = config.SideBarWidth end
    if config.Acrylic ~= nil then result.Acrylic = config.Acrylic end
    if config.Transparent ~= nil then result.Transparent = config.Transparent end
    if config.Theme then result.Theme = config.Theme end
    return result
end

local function makeElement(tab, kind, config, nativeMethods)
    config = config or {}
    local element = { Native = nil, Type = kind, Config = copyTable(config), Destroyed = false }
    local callback = config.Callback or config.Function or function() end
    local title = config.Title or config.Name or kind
    local description = config.Description or config.Desc or ""

    local nativeConfig = copyTable(config)
    nativeConfig.Title = title
    nativeConfig.Name = config.Name or title
    nativeConfig.Desc = description
    nativeConfig.Description = description
    nativeConfig.Callback = callback
    nativeConfig.Function = callback

    local ok, native = firstSuccessful(tab.Native, nativeMethods, nativeConfig)
    if ok then element.Native = native end

    function element:Set(value)
        if self.Destroyed then return false end
        if type(value) ~= "table" then value = { Value = value } end
        for key, newValue in pairs(value) do self.Config[key] = newValue end
        local target = self.Native
        if target then
            local success = false
            if value.Content ~= nil or value.Desc ~= nil or value.Title ~= nil then
                local content = value.Content or value.Desc or self.Config.Content or self.Config.Desc or ""
                local newTitle = value.Title or self.Config.Title or title
                success = firstSuccessful(target, { "Set", "Update", "Refresh" }, {
                    Title = newTitle, Content = content, Desc = content, Description = content,
                })
                if not success and type(target.SetDesc) == "function" then
                    success = pcall(function() target:SetDesc(content) end)
                end
                if not success and type(target.SetTitle) == "function" and value.Title then
                    success = pcall(function() target:SetTitle(newTitle) end)
                end
            elseif value.Value ~= nil then
                success = firstSuccessful(target, { "Set", "SetValue", "Update" }, value.Value)
            end
            return success == true
        end
        return false
    end

    function element:SetValue(value)
        return self:Set({ Value = value })
    end

    function element:GetValue()
        if self.Native then
            for _, key in ipairs({ "Value", "CurrentValue", "State" }) do
                local okRead, result = pcall(function() return self.Native[key] end)
                if okRead and result ~= nil then return result end
            end
        end
        return self.Config.Default
    end

    function element:Destroy()
        if self.Destroyed then return end
        self.Destroyed = true
        if self.Native then
            firstSuccessful(self.Native, { "Destroy", "Remove", "Delete" })
        end
        self.Native = nil
    end

    function element:OnChanged(fn)
        self.Config.Callback = fn
        self.Config.Function = fn
        if self.Native then
            pcall(function() self.Native.Callback = fn end)
            pcall(function() self.Native.Function = fn end)
        end
    end

    if not element.Native then
        warn("[Nauter] Could not create " .. kind .. ". Check your WindUI version/API.")
    end
    return element
end

function Nauter:GetTheme()
    return copyTable(COLORS)
end

function Nauter:GetWindUI()
    return loadWindUI()
end

function Nauter:CreateWindow(userConfig)
    local config = normalizeConfig(userConfig)
    local lib = loadWindUI(config.URL)
    local ok, nativeWindow = firstSuccessful(lib, { "CreateWindow", "Window" }, nativeWindowConfig(config))
    if not ok or nativeWindow == nil then
        error("Nauter: WindUI did not create a window. " .. tostring(nativeWindow), 2)
    end

    local window = {
        Native = nativeWindow,
        Library = lib,
        Config = config,
        Theme = copyTable(COLORS),
        Tabs = {},
        Destroyed = false,
    }

    function window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local nativeTabConfig = copyTable(tabConfig)
        nativeTabConfig.Title = tabConfig.Title or tabConfig.Name or "Tab"
        nativeTabConfig.Name = tabConfig.Name or nativeTabConfig.Title
        nativeTabConfig.Icon = tabConfig.Icon or "layout-dashboard"
        local success, nativeTab = firstSuccessful(self.Native, { "Tab", "CreateTab", "AddTab" }, nativeTabConfig)
        if not success or nativeTab == nil then
            error("Nauter: Could not create tab '" .. nativeTabConfig.Title .. "'.", 2)
        end

        local tab = { Native = nativeTab, Window = self, Config = nativeTabConfig, Elements = {} }

        function tab:CreateSection(sectionConfig)
            if type(sectionConfig) == "string" then sectionConfig = { Title = sectionConfig } end
            sectionConfig = sectionConfig or {}
            local cfg = copyTable(sectionConfig)
            cfg.Title = cfg.Title or cfg.Name or "Section"
            local okSection, nativeSection = firstSuccessful(self.Native, { "Section", "CreateSection", "AddSection" }, cfg)
            if not okSection then
                warn("[Nauter] Could not create Section: " .. tostring(cfg.Title))
                return nil
            end
            local section = { Native = nativeSection, Type = "Section", Config = cfg, Destroyed = false }
            function section:Destroy()
                if self.Destroyed then return end
                self.Destroyed = true
                firstSuccessful(self.Native, { "Destroy", "Remove", "Delete" })
                self.Native = nil
            end
            table.insert(self.Elements, section)
            return section
        end

        function tab:CreateParagraph(paragraphConfig)
            paragraphConfig = paragraphConfig or {}
            local cfg = copyTable(paragraphConfig)
            cfg.Title = cfg.Title or "Paragraph"
            cfg.Content = cfg.Content or cfg.Desc or ""
            cfg.Desc = cfg.Content
            local paragraph = makeElement(self, "Paragraph", cfg, { "Paragraph", "CreateParagraph", "AddParagraph" })
            local baseSet = paragraph.Set
            function paragraph:Set(nextConfig)
                if type(nextConfig) == "string" then nextConfig = { Content = nextConfig } end
                nextConfig = nextConfig or {}
                if nextConfig.Content ~= nil then self.Config.Content = nextConfig.Content end
                if nextConfig.Desc ~= nil then self.Config.Desc = nextConfig.Desc; self.Config.Content = nextConfig.Desc end
                if nextConfig.Title ~= nil then self.Config.Title = nextConfig.Title end
                local okSet = baseSet(self, nextConfig)
                if not okSet and not self.Destroyed then
                    -- Some WindUI builds do not expose Paragraph:Set; recreate it safely.
                    local old = self.Native
                    if old then firstSuccessful(old, { "Destroy", "Remove", "Delete" }) end
                    self.Native = nil
                    local updated = copyTable(self.Config)
                    updated.Desc = updated.Content or updated.Desc or ""
                    local created, native = firstSuccessful(tab.Native, { "Paragraph", "CreateParagraph", "AddParagraph" }, updated)
                    if created then self.Native = native; return true end
                end
                return okSet
            end
            table.insert(self.Elements, paragraph)
            return paragraph
        end

        function tab:CreateButton(cfg)
            cfg = cfg or {}
            local element = makeElement(self, "Button", cfg, { "Button", "CreateButton", "AddButton" })
            table.insert(self.Elements, element); return element
        end

        function tab:CreateToggle(cfg)
            cfg = cfg or {}
            if cfg.Default == nil then cfg.Default = false end
            local element = makeElement(self, "Toggle", cfg, { "Toggle", "CreateToggle", "AddToggle" })
            table.insert(self.Elements, element); return element
        end

        function tab:CreateSlider(cfg)
            cfg = cfg or {}
            local element = makeElement(self, "Slider", cfg, { "Slider", "CreateSlider", "AddSlider" })
            table.insert(self.Elements, element); return element
        end

        function tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local element = makeElement(self, "Dropdown", cfg, { "Dropdown", "CreateDropdown", "AddDropdown" })
            table.insert(self.Elements, element); return element
        end

        function tab:CreateInput(cfg)
            cfg = cfg or {}
            local element = makeElement(self, "Input", cfg, { "Input", "CreateInput", "AddInput" })
            table.insert(self.Elements, element); return element
        end

        function tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local element = makeElement(self, "Keybind", cfg, { "Keybind", "CreateKeybind", "AddKeybind" })
            table.insert(self.Elements, element); return element
        end

        function tab:CreateColorPicker(cfg)
            cfg = cfg or {}
            local element = makeElement(self, "ColorPicker", cfg, { "Colorpicker", "ColorPicker", "CreateColorPicker", "AddColorpicker" })
            table.insert(self.Elements, element); return element
        end

        function tab:CreateCode(cfg)
            cfg = cfg or {}
            local element = makeElement(self, "Code", cfg, { "Code", "CreateCode", "AddCode" })
            table.insert(self.Elements, element); return element
        end

        -- Compatibility aliases for common Rayfield/WindUI naming.
        tab.Paragraph = tab.CreateParagraph
        tab.Button = tab.CreateButton
        tab.Toggle = tab.CreateToggle
        tab.Slider = tab.CreateSlider
        tab.Dropdown = tab.CreateDropdown
        tab.Input = tab.CreateInput
        tab.Keybind = tab.CreateKeybind
        tab.ColorPicker = tab.CreateColorPicker
        tab.Section = tab.CreateSection

        table.insert(self.Tabs, tab)
        return tab
    end

    function window:Notify(notifyConfig)
        notifyConfig = copyTable(notifyConfig or {})
        -- WindUI owns the toast animation/progress bar. Use one explicit duration
        -- value so the visible timer and auto-dismiss use the same requested time.
        local duration = tonumber(notifyConfig.Duration or notifyConfig.duration or notifyConfig.Time)
        if not duration or duration <= 0 then duration = 5 end
        duration = math.clamp(duration, 0.25, 120)
        notifyConfig.Duration = duration
        notifyConfig.duration = nil
        notifyConfig.Time = nil
        local okNotify, result = firstSuccessful(self.Library, { "Notify", "Notification", "notify" }, notifyConfig)
        if okNotify then return result end
        return firstSuccessful(self.Native, { "Notify", "Notification" }, notifyConfig)
    end

    function window:SetTheme(theme)
        self.Theme = copyTable(self.Theme)
        for key, value in pairs(theme or {}) do self.Theme[key] = value end
        local okTheme = firstSuccessful(self.Library, { "AddTheme", "SetTheme", "Theme" }, self.Theme)
        if not okTheme then warn("[Nauter] Theme values saved, but this WindUI build may require native theme configuration.") end
        return okTheme
    end

    function window:Destroy()
        if self.Destroyed then return end
        self.Destroyed = true
        for _, tab in ipairs(self.Tabs) do
            for _, element in ipairs(tab.Elements) do pcall(function() element:Destroy() end) end
        end
        firstSuccessful(self.Native, { "Destroy", "Close", "Unload" })
    end

    function window:Close()
        return firstSuccessful(self.Native, { "Close", "Hide", "Minimize" })
    end

    function window:SelectTab(tabName)
        for _, tab in ipairs(self.Tabs) do
            if tab.Config.Title == tabName or tab.Config.Name == tabName then
                return firstSuccessful(self.Native, { "SelectTab", "SetTab", "ChangeTab" }, tab.Native)
            end
        end
        return false, "tab not found"
    end

    return window
end

-- Common WindUI passthroughs, kept available rather than hidden behind the wrapper.
function Nauter:Notify(config)
    local lib = loadWindUI()
    config = copyTable(config or {})
    local duration = tonumber(config.Duration or config.duration or config.Time)
    if not duration or duration <= 0 then duration = 5 end
    duration = math.clamp(duration, 0.25, 120)
    config.Duration = duration
    config.duration = nil
    config.Time = nil
    return firstSuccessful(lib, { "Notify", "Notification", "notify" }, config)
end

function Nauter:Dialog(config)
    local lib = loadWindUI()
    return firstSuccessful(lib, { "Dialog", "CreateDialog", "Prompt" }, config or {})
end

function Nauter:CreateTheme(name, theme)
    local lib = loadWindUI()
    return firstSuccessful(lib, { "AddTheme", "CreateTheme", "SetTheme" }, name, theme)
end

function Nauter:Destroy()
    if WindUI then firstSuccessful(WindUI, { "Destroy", "Unload", "Close" }) end
    WindUI = nil
end

-- Returning the module keeps the Rayfield-like `Nauter:CreateWindow(...)` interface.
return setmetatable(Nauter, Nauter)
