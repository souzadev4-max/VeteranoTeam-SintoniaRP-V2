-- integrated.lua (updated loader)
-- Robust wrapper that loads the deepseek logic and provides a minimal in-game UI
-- to toggle common features. Improved HTTP/source validation and error messages.

local DEEPSEEK_RAW = "https://raw.githubusercontent.com/souzadev4-max/VeteranoTeam-SintoniaRP-V2/main/deepseek_lua_20261019_817efb.lua"

local function httpGet(url)
    -- Try common getters. Some exploit envs expose different functions.
    local getters = {
        function(u) return (type(game.HttpGet) == "function") and game:HttpGet(u) end,
        function(u) local hs = game:GetService("HttpService") if type(hs.GetAsync)=="function" then return hs:GetAsync(u) end end,
        function(u) if type(http and http.request) == "function" then return http.request({Url=u, Method="GET"}).Body end end,
    }
    for _, g in ipairs(getters) do
        local ok, res = pcall(g, url)
        if ok and res and type(res) == "string" and #res > 0 then return res end
    end
    return nil, "no http getter available or all getters failed"
end

local function sanitizeSource(src)
    if not src or type(src) ~= "string" then return src end
    -- remove UTF-8 BOM
    if src:sub(1,3) == '\239\187\191' then src = src:sub(4) end
    -- normalize line endings
    src = src:gsub('\r\n', '\n')
    src = src:gsub('\r', '\n')
    return src
end

local function looksLikeHtml(s)
    if not s then return false end
    local head = s:sub(1,300):lower()
    return head:find("<html") or head:find("<!doctype html") or head:find("<meta") or head:find("https://github.com")
end

-- Try to download & load the deepseek script
local source, getErr = httpGet(DEEPSEEK_RAW)
if not source then
    warn("[integrated.lua] http get failed: ", tostring(getErr))
else
    source = sanitizeSource(source)
    if looksLikeHtml(source) then
        warn("[integrated.lua] fetched content looks like HTML (not raw). Check the URL or GH rate limits. URL: "..DEEPSEEK_RAW)
    else
        -- attempt load using load or loadstring with safer error reporting
        local loaded, loadErr
        if type(load) == "function" then
            loaded, loadErr = load(source)
        elseif type(loadstring) == "function" then
            loaded, loadErr = loadstring(source)
        else
            warn("[integrated.lua] no load/loadstring available in this environment")
        end
        if not loaded then
            -- give a clearer hint: save a copy (if writefile available) and print load error
            warn("[integrated.lua] load failed: ", tostring(loadErr))
            if type(writefile) == "function" then
                pcall(function() writefile("deepseek_debug.lua", source) end)
                warn("[integrated.lua] source saved to deepseek_debug.lua via writefile for inspection")
            end
        else
            local ok, rc = pcall(function() return loaded() end)
            if not ok then
                warn("[integrated.lua] error while running deepseek script: ", tostring(rc))
                if type(writefile) == "function" then
                    pcall(function() writefile("deepseek_runtime_error.lua", source) end)
                    warn("[integrated.lua] source saved to deepseek_runtime_error.lua via writefile for inspection")
                end
            end
        end
    end
end

-- Wait for the runtime object created by the deepseek script
local timeout = 10
local start = tick()
local runtime = nil
while tick() - start < timeout do
    runtime = (getgenv and getgenv().__VETERANO_SINTONIA_RUNTIME) or (_G and _G.__VETERANO_SINTONIA_RUNTIME)
    if runtime then break end
    task.wait(0.1)
end
if not runtime then
    warn("[integrated.lua] could not find deepseek runtime (C.__VETERANO_SINTONIA_RUNTIME). If the loader failed, run the deepseek script manually first, then run integrated.lua.")
    -- continue anyway: we still create UI but toggles will only modify state when runtime appears
end

local state = nil
if runtime then
    state = runtime.state or runtime["state"] or (runtime.o and runtime.o.state) or (getgenv and getgenv().__VETERANO_SINTONIA_RUNTIME and getgenv().__VETERANO_SINTONIA_RUNTIME.state)
end

local function setFlag(key, value)
    pcall(function()
        if state then state[key] = value end
        -- also try common paths
        if runtime and runtime.state == nil and runtime.o and runtime.o.state then runtime.o.state[key] = value end
        if getgenv and getgenv().__VETERANO_SINTONIA_RUNTIME and getgenv().__VETERANO_SINTONIA_RUNTIME.state then
            getgenv().__VETERANO_SINTONIA_RUNTIME.state[key] = value
        end
    end)
end
local function getFlag(key)
    local ok, v = pcall(function()
        if state and state[key] ~= nil then return state[key] end
        if runtime and runtime.o and runtime.o.state and runtime.o.state[key] ~= nil then return runtime.o.state[key] end
        if getgenv and getgenv().__VETERANO_SINTONIA_RUNTIME and getgenv().__VETERANO_SINTONIA_RUNTIME.state then return getgenv().__VETERANO_SINTONIA_RUNTIME.state[key] end
        return nil
    end)
    if ok then return v end
    return nil
end

local startGhost = runtime and (runtime.startGhost or runtime.StartGhost or (runtime.o and runtime.o.startGhost))
local stopGhost = runtime and (runtime.stopGhost or runtime.StopGhost or (runtime.o and runtime.o.stopGhost))
local startAutoColeta = runtime and (runtime.startAutoColeta or (runtime.o and runtime.o.startAutoColeta))
local stopAutoColeta = runtime and (runtime.stopAutoColeta or (runtime.o and runtime.o.stopAutoColeta))
local iniciarFarmPartes = runtime and (runtime.iniciarFarmPartes or (runtime.o and runtime.o.iniciarFarmPartes))
local pararFarmPartes = runtime and (runtime.pararFarmPartes or (runtime.o and runtime.o.pararFarmPartes))

-- Create UI
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then warn("[integrated.lua] LocalPlayer not ready") return end

local gui = Instance.new("ScreenGui")
gui.Name = "VeteranoIntegratedUI"
if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

gui.ResetOnSpawn = false
local parent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
gui.Parent = parent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "VETERANO - Controls"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local y = 44
local function makeToggle(labelText, key, onActivateFunc, onDeactivateFunc)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, -8, 0, 28)
    lbl.Position = UDim2.new(0, 8, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.new(0.9,0.9,0.9)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.35, -8, 0, 28)
    btn.Position = UDim2.new(0.65, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = frame
    btn.AutoButtonColor = true

    local function update()
        local val = getFlag(key)
        if val == true then
            btn.Text = "ON"
            btn.BackgroundColor3 = Color3.fromRGB(35,150,80)
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = Color3.fromRGB(80,35,35)
        end
    end

    btn.MouseButton1Click:Connect(function()
        local cur = getFlag(key)
        local new = not cur
        setFlag(key, new)
        if new and type(onActivateFunc) == "function" then pcall(onActivateFunc) end
        if not new and type(onDeactivateFunc) == "function" then pcall(onDeactivateFunc) end
        update()
    end)

    update()
    y = y + 36
    return lbl, btn
end

makeToggle("ESP", "espEnabled")
makeToggle("Fly", "flyEnabled")
makeToggle("Noclip", "noclipEnabled")
makeToggle("Ghost", "ghostEnabled",
    function() if startGhost then pcall(startGhost) end end,
    function() if stopGhost then pcall(stopGhost) end end
)
makeToggle("AutoColeta", "autoColetaEnabled",
    function() if startAutoColeta then pcall(startAutoColeta) end end,
    function() if stopAutoColeta then pcall(stopAutoColeta) end end
)
makeToggle("FarmPartes", "farmPartesEnabled",
    function() if iniciarFarmPartes then pcall(iniciarFarmPartes) end end,
    function() if pararFarmPartes then pcall(pararFarmPartes) end end
)
makeToggle("Aimbot", "aimbotEnabled")
makeToggle("Fullbright/NoLag", "fullbright")

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 0, 28)
status.Position = UDim2.new(0, 8, 1, -40)
status.BackgroundTransparency = 1
status.Text = "Status: integrated UI active"
status.TextColor3 = Color3.new(0.8,0.8,0.8)
status.Font = Enum.Font.SourceSansItalic
status.TextSize = 13
status.Parent = frame

spawn(function()
    while gui.Parent do
        pcall(function()
            local sc = ""
            if runtime and runtime.staffCount then sc = string.format(" | staff=%d", runtime.staffCount) end
            status.Text = "Status: integrated UI active" .. sc
        end)
        task.wait(0.5)
    end
end)

print("[integrated.lua] loaded. UI available as VeteranoIntegratedUI in PlayerGui.")
