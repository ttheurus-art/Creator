-- WindUI: MainTab/sidebar on the RIGHT
-- This file fetches the official WindUI bundle and patches its layout before execution.
-- If the upstream layout has changed, it stops with a clear error rather than silently
-- returning an unmodified UI.

local SOURCE_URL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)

if not ok or type(source) ~= "string" or #source < 500000 then
    error("[WindUI RightTab] Could not retrieve the full official WindUI bundle.")
end

local function replaceOne(oldText, newText, label)
    local first, last = string.find(source, oldText, 1, true)
    if not first then
        error("[WindUI RightTab] Could not locate layout code: " .. label .. ". Upstream source may have changed.")
    end
    local second = string.find(source, oldText, last + 1, true)
    if second then
        error("[WindUI RightTab] Layout match is ambiguous: " .. label .. ". No changes were executed.")
    end
    source = string.sub(source, 1, first - 1) .. newText .. string.sub(source, last + 1)
end

-- Move the sidebar tab list to the right edge.
replaceOne(
    'Position=UDim2.new(0,0,0,aw.Topbar.Height),BackgroundTransparency=1,Visible=true,',
    'Position=UDim2.new(1,-aw.SideBarWidth,0,aw.Topbar.Height),BackgroundTransparency=1,Visible=true,',
    "sidebar container position"
)

-- Move the content panel to the left so it does not overlap the sidebar.
replaceOne(
    'Position=UDim2.new(1,0,1,0),AnchorPoint=Vector2.new(1,1),BackgroundTransparency=1,',
    'Position=UDim2.new(0,0,1,0),AnchorPoint=Vector2.new(0,1),BackgroundTransparency=1,',
    "main content position"
)

-- Place the sidebar scroll indicator on its right edge.
replaceOne(
    'VerticalScrollBarPosition="Left",',
    'VerticalScrollBarPosition="Right",',
    "sidebar scrollbar position"
)

local compiler = loadstring or load
if type(compiler) ~= "function" then
    error("[WindUI RightTab] This environment does not support compiling Luau source.")
end

local chunk, compileError = compiler(source)
if not chunk then
    error("[WindUI RightTab] Compilation failed: " .. tostring(compileError))
end

local runOk, WindUI = pcall(chunk)
if not runOk then
    error("[WindUI RightTab] Initialization failed: " .. tostring(WindUI))
end

return WindUI
