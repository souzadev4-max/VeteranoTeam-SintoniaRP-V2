-- integrated.lua (final fix)
-- This file tries the deepseek script in this order:
-- 1) local file deepseek_lua_20261019_817efb.lua in the same folder
-- 2) raw GitHub URL when the executor allows HTTP
-- 3) shows a clear error if neither works
--
-- The deepseek file itself is valid in the repo. The issue is usually the
-- executor's loader or the script not being present locally when integrated.lua runs.

local DEEPSEEK_NAME = "deepseek_lua_20261019_817efb.lua"
local DEEPSEEK_RAW = "https://raw.githubusercontent.com/souzadev4-max/VeteranoTeam-SintoniaRP-V2/main/deepseek_lua_20261019_817efb.lua"

local function sanitizeSource(src)
    if type(src) ~= "string" then return src end
    if src:sub(1, 3) == '\239\187\191' then src = src:sub(4) end
    src = src:gsub('\r\n', '\n')
    src = src:gsub('\r', '\n')
    return src
end

local function looksLikeHtml(src)
    if type(src) ~= "string" then return false end
    local head = src:sub(1, 300):lower()
    return head:find("<html") ~= nil or head:find("<!doctype") ~= nil or head:find("<meta") ~= nil or head:find("<body") ~= nil
end

local function readLocalFile(path)
    if type(isfile) == "function" and type(readfile) == "function" then
        if isfile(path) then
            local ok, data = pcall(readfile, path)
            if ok and type(data) == "string" and #data > 0 then
                return data
            end
        end
    end
    return nil
end

local function httpGet(url)
    local getters = {
        function(u)
            if type(game) == "table" and type(game.HttpGet) == "function" then
                return game:HttpGet(u)
            end
        end,
        function(u)
            local hs = game:GetService("HttpService")
            if type(hs) == "table" and type(hs.GetAsync) == "function" then
                return hs:GetAsync(u)
            end
        end,
        function(u)
            if type(http) == "table" and type(http.request) == "function" then
                local res = http.request({ Url = u, Method = "GET" })
                if type(res) == "table" and type(res.Body) == "string" then
                    return res.Body
                end
            end
        end,
    }

    for _, getter in ipairs(getters) do
        local ok, res = pcall(getter, url)
        if ok and type(res) == "string" and #res > 0 then
            return res
        end
    end

    return nil
end

local function safeLoadScript(source, label)
    local s = sanitizeSource(source)
    if type(s) ~= "string" or #s == 0 then
        return nil, label .. ": empty source"
    end

    if looksLikeHtml(s) then
        return nil, label .. ": received HTML instead of Lua source"
    end

    local compile
    if type(loadstring) == "function" then
        compile = loadstring
    elseif type(load) == "function" then
        compile = load
    end

    if type(compile) ~= "function" then
        return nil, label .. ": no loadstring/load available in this executor"
    end

    local ok, fn = pcall(function()
        return compile(s, label)
    end)
    if not ok then
        return nil, label .. ": compile error -> " .. tostring(fn)
    end
    if type(fn) ~= "function" then
        return nil, label .. ": compiled result is not a function"
    end

    return fn, nil
end

local source = readLocalFile(DEEPSEEK_NAME)
local sourceLabel = "local deepseek file"
if not source then
    source = httpGet(DEEPSEEK_RAW)
    sourceLabel = "GitHub raw deepseek"
end

if type(source) == "string" and #source > 0 then
    local loader, err = safeLoadScript(source, sourceLabel)
    if loader then
        local ok, runErr = pcall(loader)
        if not ok then
            warn("[integrated.lua] failed to execute deepseek script:", tostring(runErr))
        end
    else
        warn("[integrated.lua] " .. tostring(err))
        if type(writefile) == "function" then
            pcall(function()
                writefile("deepseek_debug.lua", source)
            end)
        end
    end
else
    warn("[integrated.lua] deepseek script not found locally and failed to download from GitHub raw URL.")
end

local timeout = 10
local start = tick()
local runtime = nil
while tick() - start < timeout do
    runtime = (getgenv and getgenv().__VETERANO_SINTONIA_RUNTIME) or (_G and _G.__VETERANO_SINTONIA_RUNTIME)
    if runtime then break end
    task.wait(0.1)
end

if not runtime then
    warn("[integrated.lua] could not find deepseek runtime. Run deepseek_lua_20261019_817efb.lua manually once, then rerun this wrapper.")
end

local state = nil
if runtime then
    state = runtime.state or runtime["state"] or (runtime.o and runtime.o.state)
end

local function getFlag(key)
    local result = nil
    local ok, value = pcall(function()
        if state and state[key] ~= nil then return state[key] end
        if runtime and runtime.o and runtime.o.state and runtime.o.state[key] ~= nil then return runtime.o.state[key] end
        if getgenv and getgenv().__VETERANO_SINTONIA_RUNTIME and getgenv().__VETERANO_SINTONIA_RUNTIME.state and getgenv().__VETERANO_SINTONIA_RUNTIME.state[key] ~= nil then
            return getgenv().__VETERANO_SINTONIA_RUNTIME.state[key]
        end
        return nil
    end)
    if ok then result = value end
    return result
end

local function setFlag(key, value)
    pcall(function()
        if state then state[key] = value end
        if runtime and runtime.o and runtime.o.state then runtime.o.state[key] = value end
        if getgenv and getgenv().__VETERANO_SINTONIA_RUNTIME and getgenv().__VETERANO_SINTONIA_RUNTIME.state then
            getgenv().__VETERANO_SINTONIA_RUNTIME.state[key] = value
        end
    end)
end

local startGhost = runtime and (runtime.startGhost or runtime.StartGhost or (runtime.o and runtime.o.startGhost))
local stopGhost = runtime and (runtime.stopGhost or runtime.StopGhost or (runtime.o and runtime.o.stopGhost))
local startAutoColeta = runtime and (runtime.startAutoColeta or (runtime.o and runtime.o.startAutoColeta))
local stopAutoColeta = runtime and (runtime.stopAutoColeta or (runtime.o and runtime.o.stopAutoColeta))
local iniciarFarmPartes = runtime and (runtime.iniciarFarmPartes or (runtime.o and runtime.o.iniciarFarmPartes))
local pararFarmPartes = runtime and (runtime.pararFarmPartes or (runtime.o and runtime.o.pararFarmPartes))

-- Simple UI -------------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[integrated.lua] LocalPlayer not ready")
    return
end

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
title.TextColor3 = Color3.new(1, 1, 1)
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
    lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.35, -8, 0, 28)
    btn.Position = UDim2.new(0.65, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = frame
    btn.AutoButtonColor = true

    local function update()
        local val = getFlag(key)
        if val == true then
            btn.Text = "ON"
            btn.BackgroundColor3 = Color3.fromRGB(35, 150, 80)
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = Color3.fromRGB(80, 35, 35)
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
status.TextColor3 = Color3.new(0.8, 0.8, 0.8)
status.Font = Enum.Font.SourceSansItalic
status.TextSize = 13
status.Parent = frame

spawn(function()
    while gui.Parent do
        pcall(function()
            if runtime and runtime.staffCount then
                status.Text = "Status: integrated UI active | staff=" .. tostring(runtime.staffCount)
            else
                status.Text = "Status: integrated UI active"
            end
        end)
        task.wait(0.5)
    end
end)

print("[integrated.lua] loaded. UI available as VeteranoIntegratedUI in PlayerGui.")
