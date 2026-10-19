-- ============================================================
-- VETERANO TEAM | SINTONIA RP V2 — LÓGICA PURA
-- Sem login, sem menu, sem HUDs. Só as funções.
-- ============================================================
-- Uso:
--   VETERANO.T.flyEnabled = true        -- ativa fly
--   VETERANO.T.espEnabled = true        -- ativa ESP
--   VETERANO.startGhost()               -- ativa ghost
--   VETERANO.coletarItem(target)        -- coleta um item
--   VETERANO.cleanup()                  -- desliga tudo
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local TC = Color3.fromRGB(170,70,255)
local STAFF_RED = Color3.fromRGB(255,20,40)

local C = (getgenv and getgenv()) or _G
cloneref = cloneref or function(v) return v end
gethui = gethui or get_hidden_gui
protect_gui = protect_gui or protectgui or (syn and syn.protect_gui)

local parentGui = LocalPlayer:WaitForChild("PlayerGui")

local P = 1500
local z = Enum.KeyCode.K
local F = "125299131646017"

local o = {
    connections = {}, placeMatched = tostring(game.PlaceId)==F, destroyed=false,
    itemTeleportRunId=0, farmPartesRunId=0, farmPartesColetadas=0,
    garbageFarmRunId=0, garbageFarmStatus="Parado", durabilidadeRunId=0,
    relationships={}, relationshipConnections={}, staffCount=0, staffNames={},
    pescaRunId=0, pescaStatus="Parado", pescaColetados=0,
    coletaRunId = 0, coletaHudRunId = 0,
}

local T = {
    monitorarStaff=false, sorte2xEnabled=false,
    espEnabled=false, box=false, name=false, distance=false, heldItem=false,
    skeleton=false, highlight=false, tracer=false, arrow=false, box3d=false, teamTag=false,
    maxDistance=P, bundles={}, spoofWalkEnabled=false, spoofJumpEnabled=false,
    spoofWalkSpeed=40, spoofJumpPower=90,
    walkSpeedKeybind=Enum.KeyCode.V, menuKeybind=z,
    noclipEnabled=false, noclipKeybind=Enum.KeyCode.N,
    flyEnabled=false, flyKeybind=Enum.KeyCode.F, flySpeed=60,
    ghostEnabled=false,
    aimbotEnabled=false, aimbotMode="Legit", aimbotFov=120, aimbotDistance=500,
    aimbotVisibleOnly=false, aimbotFovVisible=false,
    aimbotHitChance=100, aimbotBodyPart="Cabeca", aimbotSmoothness=0.15,
    aimbotTargetMode="Closest", aimbotWallCheck=true, aimbotTeamCheck=true,
    aimbotKeybind=Enum.KeyCode.E, friendCheck=true, adminCheck=true,
    armaTracer=false, armaTracerCor="Ciano",
    perfectLockpick=false,
    itemTeleportSpeed=65,
    autoFarmLixeiroEnabled=false, autoFarmLixeiroQuantidade=20,
    farmPartesEnabled=false,
    durabilidadeHudEnabled=false, autoCintoEnabled=false,
    noclipCarEnabled=false, vFlyEnabled=false,
    vFlyHorizontalSpeed=60, vFlyVerticalSpeed=30,
    boostFactor=1, fullbright=false, noLag=false,
    autoFarmPescaEnabled=false,
    autoColetaEnabled=false, autoColetaCooldown=0.35,
    coletaHudEnabled=false, coletaYOffset=3, coletaReachDistance=4,
    camuflarNickEnabled=false,
}

if C.__VETERANO_SINTONIA_CLEANUP then pcall(C.__VETERANO_SINTONIA_CLEANUP) end

local function handleReady(conn) table.insert(o.connections, conn); return conn end
local GuiService = game:GetService("GuiService")

-- ============================================
-- BYPASS ANTI-CHEAT
-- ============================================
;(function()
    local RS = game:GetService("ReplicatedStorage")
    local isEValid = function(k) return (getgenv and getgenv()[k]) or (_G and _G[k]) end
    local g = isEValid("filtergc")
    local m = isEValid("hookfunction")
    local E = isEValid("newcclosure")
    local M = debug or {}
    local A, F = M.getconstants, M.getprotos
    local u2, q2 = M.getupvalues, M.setupvalue
    if not (g and m and E and A and F and u2 and q2) then
        o.acStatus = "Executor sem filtergc/hookfunction/debug.* - AC intacto."
        return
    end
    local P2 = {}
    local function secondaryZ(C, isEValid2, g2)
        g2 = g2 or 0
        if g2 > 8 then return false end
        local m2, E2 = pcall(A, C)
        if m2 and type(E2)=="table" then
            for _, v in next, E2 do if type(v)=="string" and isEValid2(v) then return true end end
        end
        local M2, H2 = pcall(F, C)
        if M2 and type(H2)=="table" then
            for _, p in next, H2 do if secondaryZ(p, isEValid2, g2+1) then return true end end
        end
        return false
    end
    local function alternateZ(C)
        return secondaryZ(C, function(s) return string.find(s, "__ACK__", 1, true) ~= nil end)
    end
    local f2 = {"Hitbox Expander", "ESP Detectado"}
    local function isYValid(C)
        local isEValid2, g2 = false, true
        secondaryZ(C, function(s)
            if #s < 4 or not string.find(s, " ", 1, true) then return false end
            isEValid2 = true
            for _, bad in ipairs(f2) do if string.find(s, bad, 1, true) then return false end end
            g2 = false
            return true
        end)
        return isEValid2 and g2
    end
    local V = {"CFrame TP: ","Tween TP: ","TP Absurdo","Velocity","VFly","WalkFling IY","Noclip","WalkSpeed: ","JumpPower: ","Fly mal feito"}
    local handleM2 = {FireServer = function() end}
    local updateInstancePropertiesPosition2 = {
        WaitForChild = function() return handleM2 end,
        FindFirstChild = function() return handleM2 end,
    }
    local O = {"CFrame TP: ","TP Absurdo","VFly"}
    local function handleY(C)
        local ok, consts = pcall(A, C)
        if not ok or type(consts)~="table" then return false end
        for _, v in next, consts do
            if type(v)=="string" then
                for _, reason in ipairs(O) do if v == reason then return true end end
            end
        end
        return false
    end
    local function handleG()
        local ok, res = pcall(g, "function", {Constants={"VFly"}, IgnoreExecutor=true})
        if not ok or type(res)~="table" then return nil end
        return res
    end
    local function handler(fn)
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return true end
        for _, v in next, ups do if v == RS then return true end end
        return false
    end
    local function secondaryHandleG(fn)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return false end
        for _, v in next, ups do if v == root then return true end end
        return false
    end
    local function isValid(fn)
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return false end
        for k, v in next, ups do
            if v == RS then return (pcall(q2, fn, k, updateInstancePropertiesPosition2)) and true or false end
        end
        return true
    end
    local getconnectionsFn = isEValid("getconnections")
    local function handleM3(fn, depth)
        depth = depth or 0
        if depth > 6 then return nil end
        local ok, consts = pcall(A, fn)
        if ok and type(consts)=="table" then
            for _, v in next, consts do
                if type(v)=="string" then
                    for _, reason in ipairs(V) do if v == reason then return reason end end
                end
            end
        end
        local ok2, protos = pcall(F, fn)
        if ok2 and type(protos)=="table" then
            for _, p in next, protos do
                local r = handleM3(p, depth+1)
                if r then return r end
            end
        end
        return nil
    end
    local function alternateHandleG()
        local out = {}
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            out[#out+1] = hum:GetPropertyChangedSignal("WalkSpeed")
            out[#out+1] = hum:GetPropertyChangedSignal("JumpPower")
            out[#out+1] = hum.StateChanged
        end
        if char then
            out[#out+1] = char.DescendantAdded
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then out[#out+1] = p:GetPropertyChangedSignal("CanCollide") end
            end
        end
        out[#out+1] = RunService.Heartbeat
        return out
    end
    local function handleAcReaplicar()
        if not getconnectionsFn then return nil end
        local seen, reasons = {}, {}
        for _, sig in ipairs(alternateHandleG()) do
            local ok, conns = pcall(getconnectionsFn, sig)
            if ok and type(conns)=="table" then
                for _, c in ipairs(conns) do
                    local fn = c.Function
                    if type(fn)=="function" and c.Connected then
                        local r = handleM3(fn)
                        if r and not seen[r] then seen[r]=true; reasons[#reasons+1]=r end
                    end
                end
            end
        end
        local fns = handleG()
        if fns == nil then return nil end
        local hasApproved, hasUnapproved = false, false
        for _, fn in next, fns do
            if secondaryHandleG(fn) then
                if handler(fn) then hasApproved = true else hasUnapproved = true end
            end
        end
        if (hasApproved or not hasUnapproved) and not seen["CFrame TP: "] then
            seen["CFrame TP: "] = true
            reasons[#reasons+1] = "CFrame TP: "
        end
        return reasons
    end
    local function secondaryHandleY()
        if not RS:FindFirstChild("SignalSendACK") then return 0 end
        local ok, fns = pcall(g, "function", {Constants={"SignalSendACK","FireServer"}, IgnoreExecutor=true})
        if not ok or type(fns)~="table" then return 0 end
        local hit, total = 0, 0
        for _, fn in next, fns do
            if not P2[fn] then
                if handleY(fn) then
                    if isValid(fn) then P2[fn] = true; hit = hit+1 end
                else
                    P2[fn] = true
                    if not alternateZ(fn) and not isYValid(fn) then
                        if pcall(m, fn, E(function() end)) then hit = hit+1 end
                    end
                end
                total = total + 1
                if total >= 200 then total = 0; task.wait() end
            end
        end
        return hit
    end
    local b2 = false
    local function acReaplicar(tag)
        if b2 or o.destroyed then return end
        b2 = true
        o.acSilenciados = 0
        o.acMotivosVivos = nil
        o.acStatus = "Aplicando ("..tag..")..."
        task.spawn(function()
            local silenced, reasons = 0, nil
            for _ = 1, 120, 1 do
                if o.destroyed then break end
                silenced = silenced + secondaryHandleY()
                reasons = handleAcReaplicar()
                if reasons == nil then break end
                if #reasons == 0 then break end
                task.wait(0.5)
            end
            b2 = false
            o.acSilenciados = silenced
            o.acMotivosVivos = reasons
            if reasons == nil then o.acStatus = silenced.." silenciado(s) ("..tag..")"
            elseif #reasons > 0 then o.acStatus = "AC parcial: "..silenced.." OK, vivos: "..table.concat(reasons, ", ")
            elseif silenced > 0 then o.acStatus = silenced.." denunciante(s) silenciado(s)"
            else o.acStatus = "Nenhum denunciante encontrado" end
        end)
    end
    o.acReaplicar = acReaplicar
    acReaplicar("carga")
    handleReady(LocalPlayer.CharacterAdded:Connect(function() acReaplicar("respawn") end))
end)()

-- ============================================
-- MUNDO (Fullbright / No Lag)
-- ============================================
do
    local function capture()
        local L = game:GetService("Lighting")
        return {
            Brightness=L.Brightness, ClockTime=L.ClockTime,
            GeographicLatitude=L.GeographicLatitude, FogEnd=L.FogEnd,
            FogStart=L.FogStart, GlobalShadows=L.GlobalShadows,
            Ambient=L.Ambient, OutdoorAmbient=L.OutdoorAmbient,
            ExposureCompensation=L.ExposureCompensation,
            EnvironmentDiffuseScale=L.EnvironmentDiffuseScale,
            EnvironmentSpecularScale=L.EnvironmentSpecularScale,
        }
    end
    local function restore()
        local L = game:GetService("Lighting")
        if not o.worldOriginal then return end
        for k, v in pairs(o.worldOriginal) do pcall(function() L[k] = v end) end
        for _, atm in ipairs(L:GetChildren()) do
            if atm:IsA("Atmosphere") and o.worldAtmOriginal then
                pcall(function() atm.Density = o.worldAtmOriginal end)
            end
        end
    end
    local function applyWorld()
        local L = game:GetService("Lighting")
        local active = T.fullbright or T.noLag
        if active and not o.worldOriginal then
            o.worldOriginal = capture()
            local atm = L:FindFirstChildOfClass("Atmosphere")
            o.worldAtmOriginal = atm and atm.Density or 0.3
        elseif not active and o.worldOriginal then
            restore(); o.worldOriginal = nil; return
        end
        if not active then return end
        if T.fullbright then
            pcall(function()
                L.Brightness=3; L.ExposureCompensation=0
                L.EnvironmentDiffuseScale=1; L.EnvironmentSpecularScale=1
                L.Ambient=Color3.new(1,1,1); L.OutdoorAmbient=Color3.new(1,1,1)
                L.GlobalShadows=false; L.FogStart=0; L.FogEnd=1e9
            end)
            for _, atm in ipairs(L:GetChildren()) do
                if atm:IsA("Atmosphere") then pcall(function() atm.Density=0 end) end
            end
        elseif T.noLag then
            pcall(function() L.GlobalShadows=false; L.FogStart=0; L.FogEnd=1e6 end)
            for _, atm in ipairs(L:GetChildren()) do
                if atm:IsA("Atmosphere") then pcall(function() atm.Density=0 end) end
            end
            for _, v in ipairs(L:GetDescendants()) do
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                    pcall(function() v.Enabled=false end)
                end
            end
        end
    end
    o.applyWorld = applyWorld
    local acc = 0
    handleReady(RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc < 0.2 then return end
        acc = 0
        if T.fullbright or T.noLag then pcall(applyWorld) end
    end))
end

-- ============================================
-- GHOST MODE
-- ============================================
.do
end
