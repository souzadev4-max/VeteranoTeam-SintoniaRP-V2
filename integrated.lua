-- integrated.lua
-- Wrapper that loads the deepseek logic and provides a minimal in-game UI
-- to toggle common features. This intentionally uses a small custom UI so it
-- doesn't depend on the Cybrion UI file; it simply integrates control over
-- the runtime table created by the deepseek script.

local DEEPSEEK_RAW = "https://raw.githubusercontent.com/souzadev4-max/VeteranoTeam-SintoniaRP-V2/main/deepseek_lua_20261019_817efb.lua"

-- Fetch and execute the deepseek script. It populates C.__VETERANO_SINTONIA_RUNTIME
-- and exposes functions on that runtime object.
local ok, err = pcall(function()
    local source = nil
    local http = game:GetService("HttpService")
    -- attempt to HttpGet; some exploit environments use different function names
    local getter = (type(game.HttpGet) == "function" and function(u) return game:HttpGet(u) end)
                 or (type(http.GetAsync) == "function" and function(u) return http:GetAsync(u) end)
                 or (function(u) error("no http getter available") end)
    source = getter(DEEPSEEK_RAW)
    if not source or #source == 0 then error("empty source") end
    local func, loadErr = loadstring(source)
    if not func then error("loadstring failed: " .. tostring(loadErr)) end
    pcall(func) -- run the deepseek script
end)
if not ok then
    warn("[integrated.lua] failed to load deepseek script:", err)
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
    warn("[integrated.lua] could not find deepseek runtime (C.__VETERANO_SINTONIA_RUNTIME)")
    return
end

local state = runtime.state or runtime["state"] or runtime.T or runtime.o and runtime.o.state
if not state and runtime.state == nil then
    -- deepseek uses local T and then o.state = T; runtime.state exists in o
    state = runtime.state
end

-- Helper: safely toggle boolean flags in the runtime state
local function setFlag(key, value)
    pcall(function()
        if state then state[key] = value end
    end)
end
local function getFlag(key)
    local ok, v = pcall(function() return state and state[key] end)
    if ok then return v end
    return nil
end

-- Exposed runtime functions (if present)
local startGhost = runtime.startGhost or runtime.StartGhost or (runtime.o and runtime.o.startGhost)
local stopGhost = runtime.stopGhost or runtime.StopGhost or (runtime.o and runtime.o.stopGhost)
local startAutoColeta = runtime.startAutoColeta or (runtime.o and runtime.o.startAutoColeta)
local stopAutoColeta = runtime.stopAutoColeta or (runtime.o and runtime.o.stopAutoColeta)
local iniciarFarmPartes = runtime.iniciarFarmPartes or (runtime.o and runtime.o.iniciarFarmPartes)
local pararFarmPartes = runtime.pararFarmPartes or (runtime.o and runtime.o.pararFarmPartes)

-- Create a simple ScreenGui with toggles
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[integrated.lua] LocalPlayer not ready")
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "VeteranoIntegratedUI"
if syn and syn.protect_gui then
    pcall(syn.protect_gui, gui)
end

gui.ResetOnSpawn = false
local parent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
gui.Parent = parent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 8)

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
        -- set in state
        setFlag(key, new)
        -- call specific functions if provided
        if new and type(onActivateFunc) == "function" then pcall(onActivateFunc) end
        if not new and type(onDeactivateFunc) == "function" then pcall(onDeactivateFunc) end
        update()
    end)

    update()
    y = y + 36
    return lbl, btn
end

-- toggles: ESP, Fly, Noclip, Ghost, AutoColeta, FarmPartes, Aimbot, Fullbright
makeToggle("ESP", "espEnabled")
makeToggle("Fly", "flyEnabled")
makeToggle("Noclip", "noclipEnabled")

-- Ghost needs special handling to call startGhost/stopGhost when available
makeToggle("Ghost", "ghostEnabled",
    function() -- activate
        if startGhost then pcall(startGhost) end
    end,
    function() -- deactivate
        if stopGhost then pcall(stopGhost) end
    end
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

-- Small status label
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 0, 28)
status.Position = UDim2.new(0, 8, 1, -40)
status.BackgroundTransparency = 1
status.Text = "Status: integrated UI active"
status.TextColor3 = Color3.new(0.8,0.8,0.8)
status.Font = Enum.Font.SourceSansItalic
status.TextSize = 13
status.Parent = frame

-- Auto-refresh the toggle states every 0.5s in case other scripts change them
spawn(function()
    while gui.Parent do
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("TextButton") then
                -- try to find corresponding label text to deduce key by position
                -- no strong mapping stored, so simply update by reading button.Text from state
                -- this is a lightweight approach: update button appearance by reading a mapping
            end
        end
        -- update status with some runtime info
        pcall(function()
            local sc = ""
            if runtime and runtime.staffCount then sc = string.format(" | staff=%d", runtime.staffCount) end
            status.Text = "Status: integrated UI active" .. sc
        end)
        task.wait(0.5)
    end
end)

print("[integrated.lua] loaded. UI available as VeteranoIntegratedUI in PlayerGui.")
