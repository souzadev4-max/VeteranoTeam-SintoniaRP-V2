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
(function()
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
do
    local HEIGHT, PLATFORM_OFFSET = 10, 3.5
    local WALK_ANIMATION_R15 = "rbxassetid://507777826"
    local WALK_ANIMATION_R6 = "rbxassetid://180426354"
    local isGhost, fakeModel, platform, walkTrack = false, nil, nil, nil
    local camLockConnection, ghostNoclipEnabled = nil, false
    local changedParts, targetY, ghostNoclipLoop = {}, 0, nil
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude

    local function startGhostNoclip()
        if ghostNoclipEnabled then return end
        ghostNoclipEnabled = true
        table.clear(changedParts)
        ghostNoclipLoop = RunService.Stepped:Connect(function()
            if not ghostNoclipEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            overlapParams.FilterDescendantsInstances = {char, fakeModel, platform}
            local parts = workspace:GetPartBoundsInBox(root.CFrame, Vector3.new(4,6,4), overlapParams)
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") and part.Parent and part ~= platform and part.CanCollide then
                    if changedParts[part] == nil then changedParts[part] = true end
                    part.CanCollide = false
                end
            end
        end)
    end
    local function stopGhostNoclip()
        ghostNoclipEnabled = false
        if ghostNoclipLoop then ghostNoclipLoop:Disconnect(); ghostNoclipLoop = nil end
        for part in pairs(changedParts) do
            if part and part.Parent and part ~= platform then part.CanCollide = true end
        end
        table.clear(changedParts)
    end
    local function setupFakeCharacter(model)
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        humanoid.AutoRotate=false; humanoid.PlatformStand=true
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        for _, state in ipairs({Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.Swimming, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.Flying}) do
            pcall(function() humanoid:SetStateEnabled(state, false) end)
        end
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Anchored=true; obj.CanCollide=false
                obj.CanTouch=false; obj.CanQuery=false; obj.Massless=true
            elseif obj:IsA("Script") or obj:IsA("LocalScript") then obj:Destroy() end
        end
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        local animation = Instance.new("Animation")
        animation.Name = "VeteranoGhostWalk"
        animation.AnimationId = (humanoid.RigType == Enum.HumanoidRigType.R15) and WALK_ANIMATION_R15 or WALK_ANIMATION_R6
        local success, track = pcall(function() return animator:LoadAnimation(animation) end)
        if success and track then
            walkTrack = track; walkTrack.Looped = true
            walkTrack.Priority = Enum.AnimationPriority.Movement
        end
        return true
    end
    local function updateFakeAnimation(realHumanoid)
        if not walkTrack then return end
        local moving = realHumanoid.MoveDirection.Magnitude > 0.05
        if moving then
            if not walkTrack.IsPlaying then walkTrack:Play(0.12) end
            walkTrack:AdjustSpeed(math.clamp(realHumanoid.WalkSpeed/16, 0.5, 2))
        else
            if walkTrack.IsPlaying then walkTrack:Stop(0.12) end
        end
    end
    local function updateCameraAndGhost()
        if not isGhost or not fakeModel or not LocalPlayer.Character then return end
        local realChar = LocalPlayer.Character
        local realRoot = realChar:FindFirstChild("HumanoidRootPart")
        if not realRoot or not platform then return end
        local fakeHumanoid = fakeModel:FindFirstChildOfClass("Humanoid")
        if fakeHumanoid and workspace.CurrentCamera.CameraSubject ~= fakeHumanoid then
            workspace.CurrentCamera.CameraSubject = fakeHumanoid
        end
        local currentPos = realRoot.Position
        realRoot.AssemblyLinearVelocity = Vector3.new(realRoot.AssemblyLinearVelocity.X, 0, realRoot.AssemblyLinearVelocity.Z)
        platform.CFrame = CFrame.new(currentPos.X, targetY - PLATFORM_OFFSET, currentPos.Z)
        fakeModel:PivotTo(CFrame.new(currentPos.X, targetY + HEIGHT, currentPos.Z) * realRoot.CFrame.Rotation)
        local realHumanoid = realChar:FindFirstChildOfClass("Humanoid")
        if realHumanoid then updateFakeAnimation(realHumanoid) end
    end
    local function stopGhost()
        if not isGhost then return end
        isGhost = false
        RunService:UnbindFromRenderStep("VeteranoGhostCameraFix")
        if camLockConnection then camLockConnection:Disconnect(); camLockConnection = nil end
        stopGhostNoclip()
        if walkTrack then pcall(function() walkTrack:Stop(0.1) end); walkTrack = nil end
        local realChar = LocalPlayer.Character
        local realRoot = realChar and realChar:FindFirstChild("HumanoidRootPart")
        local realHumanoid = realChar and realChar:FindFirstChildOfClass("Humanoid")
        if realHumanoid then realHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end
        if realRoot and fakeModel then
            local fakeRoot = fakeModel:FindFirstChild("HumanoidRootPart")
            if fakeRoot then realRoot.CFrame = fakeRoot.CFrame end
        end
        if realChar then
            for _, obj in ipairs(realChar:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Transparency=0; obj.CanTouch=true; obj.CanQuery=true; obj.CanCollide=true
                end
            end
            if realHumanoid then workspace.CurrentCamera.CameraSubject = realHumanoid end
        end
        if fakeModel then fakeModel:Destroy(); fakeModel = nil end
        if platform then platform:Destroy(); platform = nil end
    end
    local function startGhost()
        local realChar = LocalPlayer.Character
        if not realChar then return end
        local realRoot = realChar:FindFirstChild("HumanoidRootPart")
        local realHumanoid = realChar:FindFirstChildOfClass("Humanoid")
        if not realRoot or not realHumanoid then return end
        isGhost = true
        realHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        local startCFrame = realRoot.CFrame
        targetY = startCFrame.Y - HEIGHT
        platform = Instance.new("Part")
        platform.Name = "VeteranoGhostPlatform"
        platform.Size = Vector3.new(10,1,10)
        platform.Anchored=true; platform.CanCollide=true
        platform.CanTouch=false; platform.CanQuery=false
        platform.Transparency=1; platform.Parent=workspace
        realChar.Archivable = true
        for _, desc in ipairs(realChar:GetDescendants()) do desc.Archivable = true end
        local success, clonedChar = pcall(function() return realChar:Clone() end)
        if not success or not clonedChar then stopGhost(); return end
        fakeModel = clonedChar
        fakeModel.Name = "VeteranoGhostVisual"
        for _, obj in ipairs(fakeModel:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then obj:Destroy() end
        end
        fakeModel.Parent = workspace
        local fakeRoot = fakeModel:FindFirstChild("HumanoidRootPart")
        local fakeHumanoid = fakeModel:FindFirstChildOfClass("Humanoid")
        if not fakeRoot or not fakeHumanoid then stopGhost(); return end
        fakeModel.PrimaryPart = fakeRoot
        if not setupFakeCharacter(fakeModel) then stopGhost(); return end
        fakeModel:PivotTo(startCFrame)
        for _, obj in ipairs(realChar:GetDescendants()) do
            if obj:IsA("BasePart") then obj.Transparency = 1 end
        end
        startGhostNoclip()
        realRoot.CFrame = CFrame.new(startCFrame.X, targetY, startCFrame.Z) * startCFrame.Rotation
        workspace.CurrentCamera.CameraSubject = fakeHumanoid
        camLockConnection = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
            if isGhost and fakeHumanoid and workspace.CurrentCamera.CameraSubject ~= fakeHumanoid then
                workspace.CurrentCamera.CameraSubject = fakeHumanoid
            end
        end)
        RunService:BindToRenderStep("VeteranoGhostCameraFix", Enum.RenderPriority.Last.Value, updateCameraAndGhost)
    end
    o.startGhost = startGhost
    o.stopGhost = stopGhost
    o.isGhostActive = function() return isGhost end
    handleReady(LocalPlayer.CharacterAdded:Connect(function() if isGhost then stopGhost() end end))
end

-- ============================================
-- CAMUFLAR NICK
-- ============================================
do
    local NOME_FAKE = "VETERANO.DEV"
    local CAMINHOS_NOME = {{"InventoryUI","InvFrame","InvPessoal","BTxt"}}
    local nomesReais = { LocalPlayer.Name, LocalPlayer.DisplayName }
    if nomesReais[1] == nomesReais[2] then nomesReais = { nomesReais[1] } end
    local nickAtivo, cacheNick = false, {}

    local function pegarPorCaminho(caminho)
        local atual = parentGui
        for _, nome in ipairs(caminho) do
            if not atual then return nil end
            atual = atual:FindFirstChild(nome)
        end
        return atual
    end
    local function substituirNome(texto)
        if not texto then return nil end
        local novo, mudou = texto, false
        for _, nome in ipairs(nomesReais) do
            if nome and #nome > 1 then
                local t, n = novo:lower(), nome:lower()
                local s, e = t:find(n, 1, true)
                while s do
                    novo = novo:sub(1, s-1) .. NOME_FAKE .. novo:sub(e+1)
                    mudou = true
                    t = novo:lower()
                    s, e = t:find(n, (s + #NOME_FAKE), true)
                end
            end
        end
        return mudou and novo or nil
    end
    local function aplicarNick()
        for _, caminho in ipairs(CAMINHOS_NOME) do
            local obj = pegarPorCaminho(caminho)
            if obj and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
                local ok, txt = pcall(function() return obj.Text end)
                if ok and txt then
                    local novo = substituirNome(txt)
                    if novo then
                        if not cacheNick[obj] then cacheNick[obj] = txt end
                        obj.Text = novo
                    end
                end
            end
        end
    end
    local function restaurarNick()
        for obj, txt in pairs(cacheNick) do
            if obj and obj.Parent then pcall(function() obj.Text = txt end) end
        end
        cacheNick = {}
    end
    o.setCamuflarNick = function(v)
        nickAtivo = v == true
        T.camuflarNickEnabled = nickAtivo
        if nickAtivo then
            pcall(aplicarNick)
            task.spawn(function()
                while nickAtivo and not o.destroyed do
                    task.wait(0.5)
                    if nickAtivo then pcall(aplicarNick) end
                end
            end)
        else
            pcall(restaurarNick)
        end
    end
end

-- ============================================
-- AUTO CINTO
-- ============================================
do
    local acc = 0
    handleReady(RunService.Heartbeat:Connect(function(dt)
        if not T.autoCintoEnabled then return end
        acc = acc + dt
        if acc < 0.3 then return end
        acc = 0
        pcall(function()
            local st = LocalPlayer:FindFirstChild("Status")
            local cinto = st and st:FindFirstChild("Cinto")
            if not cinto or cinto.Value then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            if not seat or seat.Name ~= "DriveSeat" then return end
            cinto.Value = true
            pcall(function() LocalPlayer.PlayerGui.OrpheusCarInterface.Velocimetro.Icons.Cinto.Visible = true end)
            pcall(function()
                local sound = seat:FindFirstChild("ColocaCinto")
                if sound then sound:Play() end
            end)
        end)
    end))
end

-- ============================================
-- HELPERS
-- ============================================
local function isCValid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
local function isUpdatePlayerGetMagnitudeCValid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local U = Vector3.zero
task.spawn(function()
    while not o.destroyed do
        local hum = isCValid()
        if hum then U = hum.MoveDirection end
        task.wait(0.05)
    end
end)

local L = 28
local function isUpdateInstancePropertiesEValid()
    local reasons = o.acMotivosVivos
    return (o.acSilenciados or 0) > 0 and (reasons ~= nil and #reasons == 0)
end
local function updateInstanceProperties(hum)
    if not hum then return end
    if T.spoofWalkEnabled then
        local ws = math.min(T.spoofWalkSpeed, L)
        if hum.WalkSpeed ~= ws then hum.WalkSpeed = ws end
    end
    if T.spoofJumpEnabled then
        if hum.JumpPower ~= 50 then hum.JumpPower = 50 end
        if not hum.UseJumpPower then hum.UseJumpPower = true end
    end
end

local b = {
    [Enum.HumanoidStateType.Seated]=true,
    [Enum.HumanoidStateType.Dead]=true,
    [Enum.HumanoidStateType.Climbing]=true,
}
local y = 0.5
local x = 18
local c = 34
local l = 36
local Z = 0.08
local D = 16

local function handleG(arr, now)
    local sum = 0
    for i = #arr, 1, -1 do
        if now - arr[i].t > y then table.remove(arr, i)
        else sum = sum + arr[i].passo end
    end
    return sum
end
local function handleInstanceProperties(arr, now, from, to)
    if not to then return end
    local d = (to-from).Magnitude
    if d > 0 then table.insert(arr, {t=now, passo=d}) end
end
local j = {root=nil, posicao=nil, ultimaAmostra=0, historico={}}
local function updateG(root, now)
    local st = j
    if st.root ~= root or now - st.ultimaAmostra > y then
        st.root=root; st.posicao=root.Position; st.ultimaAmostra=now
        table.clear(st.historico); return 0
    end
    handleInstanceProperties(st.historico, now, st.posicao, root.Position)
    st.posicao = root.Position; st.ultimaAmostra = now
    return handleG(st.historico, now)
end
local function isGhValid(root, dt)
    local hum = isCValid()
    if root.Anchored or not hum or hum.Health <= 0 or dt >= Z then return true end
    local st = hum:GetState()
    return root.AssemblyLinearVelocity.Magnitude < 12 and (st ~= Enum.HumanoidStateType.Freefall and st ~= Enum.HumanoidStateType.Jumping)
end
local function handleQ(root, dt, targetVel, isFly)
    local step = math.clamp(dt or 0.016666, 0.004166, y)
    local moved = updateG(root, os.clock())
    local stable = not isFly or isGhValid(root, step)
    local slow = isFly and (stable and moved > x)
    local cap = isFly and (stable and x or c) or x
    if slow then cap = c end
    local slack = math.max(0, cap-moved)
    local vel = math.min(math.max(targetVel or 0, 0), slack/step)
    local phys = math.max(0, slack-vel*step)
    if slow then phys = 0 end
    return step, vel, phys, moved, stable
end

local w, a, i, d = 4, 8, 105, 65
local G, t, K = 0.05, 0.6, 14
local Cz, Yz, gz = 20, 14, 0.55
local mz = Vector3.zero
local Ez, Mz, Hz, Az = 0, 0, 4, 0

local function Fz(dt)
    if not T.spoofWalkEnabled then Az = 0; return end
    if T.flyEnabled or T.autoFarmPescaEnabled or T.farmPartesEnabled then Az = 0; return end
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return end
    local hum = isCValid()
    if not hum then return end
    if hum.Sit or b[hum:GetState()] then Az = 0; return end
    if U.Magnitude <= 0 then
        Az = 0
        if os.clock() < Ez and mz.Magnitude > 0 then
            local ws = math.max(hum.WalkSpeed, 1)
            local frac = math.clamp(Yz/ws, 0, 1)
            pcall(hum.Move, hum, mz*frac, false)
        end
        return
    end
    mz = U.Unit; Ez = os.clock() + gz
    local vel = root.AssemblyLinearVelocity
    local horiz = Vector3.new(vel.X,0,vel.Z).Magnitude
    if (dt or 0) >= G or root.Anchored or horiz < 12 then Mz = os.clock() + t end
    local unblocked = isUpdateInstancePropertiesEValid()
    local speed = math.min(T.spoofWalkSpeed, unblocked and T.spoofWalkSpeed or (os.clock()<Mz and d or i))
    local diff = speed - L
    if diff <= 0 then Az = 0; return end
    local jitter = 0.9 + math.random()*0.1
    local want = (diff*dt)*jitter + Az
    local step = math.min(want, diff*dt, unblocked and a or w)
    Az = math.clamp(want-step, 0, Hz)
    local dir = U.Unit
    root.CFrame = root.CFrame + dir*step
    local v = root.AssemblyLinearVelocity
    if Vector3.new(v.X,0,v.Z).Magnitude < K then
        root.AssemblyLinearVelocity = Vector3.new(dir.X*Cz, v.Y, dir.Z*Cz)
    end
end

local function uz()
    if not T.spoofJumpEnabled then return end
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return end
    local diff = T.spoofJumpPower - 50
    if diff > 0 then root.Velocity = root.Velocity + Vector3.new(0, diff, 0) end
end

-- ============================================
-- NOCLIP / FLY
-- ============================================
local Oz = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg","HumanoidRootPart"}
local Xz = {Head=true, Torso=true, ["Left Arm"]=false, ["Right Arm"]=false, ["Left Leg"]=false, ["Right Leg"]=false, HumanoidRootPart=false}
local Bz = nil
local function sz(force)
    local char = LocalPlayer.Character
    if not char then return end
    for _, name in ipairs(Oz) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            local col = not force and Xz[name] or false
            if p.CanCollide ~= col then p.CanCollide = col end
        end
    end
end
local function Nz()
    local char = LocalPlayer.Character
    if not char then return end
    local rag = char:FindFirstChild("IsRagdoll")
    local rc = char:FindFirstChild("RagdollClient")
    if T.noclipEnabled then
        if rc then rc.Disabled = true end
        if rag and not rag.Value then rag.Value = true end
        sz(true)
    else
        Bz = nil; sz(false)
        if rag and rag.Value then rag.Value = false end
        if rc then rc.Disabled = false end
    end
end
local Sz = 50
local function ez()
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return end
    if not Bz then Bz = root.Position.Y; return end
    local vel = root.AssemblyLinearVelocity
    local onGround = root.Position.Y <= Bz+0.5
    local hum = isCValid()
    local jump = (hum and hum.Jump) or UserInputService:IsKeyDown(Enum.KeyCode.Space)
    if onGround and jump then
        root.AssemblyLinearVelocity = Vector3.new(vel.X, Sz, vel.Z); return
    end
    if vel.Y < 0 and root.Position.Y <= Bz then
        root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
    end
end
local Uz, Lz, kz = 60, 30, 14
local nz = Uz
local bz = Vector3.zero
local yz = false
local function xz(dt)
    local root = isUpdatePlayerGetMagnitudeCValid()
    local hum = isCValid()
    if not root or not hum then return end
    if not T.flyEnabled then
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        if hum:GetState() == Enum.HumanoidStateType.Swimming then
            local target = hum.FloorMaterial == Enum.Material.Air and Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.Running
            pcall(hum.ChangeState, hum, target)
        end
        if T.autoFarmPescaEnabled or T.farmPartesEnabled then yz = false; return end
        if isUpdateInstancePropertiesEValid() then
            yz = false; root.AssemblyLinearVelocity = Vector3.zero; return
        end
        local _, vel, _, _, stable = handleQ(root, dt, kz, true)
        if yz and (stable and bz.Magnitude > 0) then
            root.AssemblyLinearVelocity = bz*vel; return
        end
        yz = false; root.AssemblyLinearVelocity = Vector3.zero; return
    end
    if hum.Health <= 0 then return end
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    local vert = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vert = 1
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vert = -1 end
    local dir = hum.MoveDirection + Vector3.new(0, vert, 0)
    if dir.Magnitude <= 0 then
        if isUpdateInstancePropertiesEValid() then
            root.AssemblyLinearVelocity = Vector3.zero; return
        end
        local _, vel, _, _, stable = handleQ(root, dt, kz, true)
        if stable and bz.Magnitude > 0 then root.AssemblyLinearVelocity = bz*vel
        else root.AssemblyLinearVelocity = Vector3.zero end
        return
    end
    dir = dir.Unit; bz = dir; yz = true
    if isUpdateInstancePropertiesEValid() then
        root.AssemblyLinearVelocity = dir * T.flySpeed; return
    end
    local cap = hum.MoveDirection.Magnitude > 0 and Uz or nz
    local goal = math.min(T.flySpeed, cap)
    local vel = math.min(goal, Lz)
    local _, step, _, _, stable = handleQ(root, dt, vel, true)
    local wanted = math.min(goal, stable and l or Uz)
    local want2 = math.max(0, wanted-step)
    if want2 > 0 then root.CFrame = root.CFrame + dir*want2*(dt or 0.016) end
    root.AssemblyLinearVelocity = dir*step
end

-- ============================================
-- VEICULO
-- ============================================
local function Dz(hum)
    if type(getconnections) ~= "function" then return nil end
    if type(debug) ~= "table" or type(debug.getupvalue) ~= "function" then return nil end
    for _, conn in ipairs(getconnections(RunService.Stepped)) do
        local fn = conn.Function
        if type(fn)=="function" then
            local hit, carState
            for i = 1, 8, 1 do
                local ok, up = pcall(debug.getupvalue, fn, i)
                if not ok then break end
                if up == hum then hit = true end
                if type(up)=="table" and (up.RemapMultiplier ~= nil and type(up.BuildHPCache)=="function") then
                    carState = up
                end
            end
            if hit and carState then return carState end
        end
    end
    return nil
end
local function rz()
    local hum = isCValid()
    local seat = hum and hum.SeatPart
    if not seat or seat.Name ~= "DriveSeat" then return nil end
    local carros = workspace:FindFirstChild("CarrosSpawnados")
    if not carros then return nil end
    local p = seat
    while p and p.Parent ~= carros do p = p.Parent end
    return p
end
do
    local carCfg = {
        carro=nil, originais={}, raiz=nil, assento=nil,
        relativoAssento=nil, altura=nil, piso=nil, raycast=nil,
        velocidade=0, frente=nil, personagemAtivo=false,
        altitude=nil, vFlyAtivo=false, vFlyReduzidoAte=0,
    }
    local function findSeat(car)
        local seat = car:FindFirstChild("DriveSeat", true) or car:FindFirstChildWhichIsA("VehicleSeat", true)
        return (seat and seat.AssemblyRootPart) or car.PrimaryPart or seat, seat
    end
    local function restaurarNoclipCar()
        for part, v in pairs(carCfg.originais) do
            if part.Parent then pcall(function() part.CanCollide = v end) end
        end
        table.clear(carCfg.originais)
        if carCfg.personagemAtivo and not T.noclipEnabled then pcall(sz, false) end
        carCfg.carro, carCfg.raiz, carCfg.assento = nil, nil, nil
        carCfg.relativoAssento, carCfg.altura, carCfg.piso, carCfg.raycast = nil, nil, nil, nil
        carCfg.velocidade, carCfg.frente, carCfg.personagemAtivo = 0, nil, false
        carCfg.altitude, carCfg.vFlyAtivo, carCfg.vFlyReduzidoAte = nil, false, 0
    end
    local function prepararNoclipCar(car)
        local raiz, seat = findSeat(car)
        if not raiz or not seat then return end
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = {car, LocalPlayer.Character}
        local hit = workspace:Raycast(raiz.Position + Vector3.new(0,20,0), Vector3.new(0,-120,0), rp)
        carCfg.raiz = raiz; carCfg.assento = seat
        carCfg.relativoAssento = ((raiz.CFrame - raiz.Position)):ToObjectSpace(seat.CFrame - seat.Position)
        carCfg.raycast = rp
        carCfg.piso = hit and hit.Position.Y or (raiz.Position.Y - 3)
        carCfg.altura = hit and math.max(1, raiz.Position.Y - hit.Position.Y) or 3
        local fwd = Vector3.new(seat.CFrame.LookVector.X, 0, seat.CFrame.LookVector.Z)
        carCfg.frente = fwd.Magnitude > 0 and fwd.Unit or Vector3.new(0,0,-1)
        carCfg.altitude = raiz.Position.Y
        carCfg.velocidade = fwd.Magnitude > 0 and raiz.AssemblyLinearVelocity:Dot(fwd.Unit) or 0
    end
    local function max(a, b, d)
        if a < b then return math.min(a+d, b) end
        return math.max(a-d, b)
    end
    local function tickCar(dt)
        local raiz, seat = carCfg.raiz, carCfg.assento
        local rp, altura, piso = carCfg.raycast, carCfg.altura, carCfg.piso
        local rel = carCfg.relativoAssento
        if not raiz or not raiz.Parent or not seat or not seat.Parent or not rp or not altura or not piso or not rel then return end
        local step = math.min(dt or 0.016666, 0.1)
        local flying = T.vFlyEnabled
        local unstable = false
        if flying and not carCfg.vFlyAtivo then
            carCfg.altitude = raiz.Position.Y
            carCfg.vFlyReduzidoAte = os.clock() + 0.6
            carCfg.velocidade = math.clamp(carCfg.velocidade, -24, 36)
        elseif not flying and carCfg.vFlyAtivo then
            local hit = workspace:Raycast(raiz.Position + Vector3.new(0,20,0), Vector3.new(0,-520,0), rp)
            if hit then piso = hit.Position.Y; carCfg.piso = piso end
        end
        carCfg.vFlyAtivo = flying
        local vertAdj = 0
        if flying then
            if step >= 0.05 or raiz.Anchored or raiz.AssemblyLinearVelocity.Magnitude < 12 then
                carCfg.vFlyReduzidoAte = os.clock() + 0.6
            end
        else
            local scanStart = Vector3.new(raiz.Position.X, piso+20, raiz.Position.Z)
            local hit = workspace:Raycast(scanStart, Vector3.new(0,-60,0), rp)
            if hit and hit.Position.Y - piso <= 4 then piso = hit.Position.Y; carCfg.piso = piso end
            vertAdj = (piso + altura) - raiz.Position.Y
            unstable = math.abs(vertAdj) > 1
            if unstable then vertAdj = math.clamp(vertAdj, -20*step, 20*step) end
        end
        local fwd = carCfg.frente or Vector3.new(0,0,-1)
        local verticalVel = 0
        if fwd.Magnitude > 0.001 then
            fwd = fwd.Unit
            local throttle, steer = seat.ThrottleFloat, seat.SteerFloat
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then throttle = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then throttle = -1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then steer = -1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then steer = 1 end
            local unblocked = isUpdateInstancePropertiesEValid()
            local boost = math.clamp(T.boostFactor, 1, 999)
            local vMax = flying and T.vFlyHorizontalSpeed*boost or (unstable and 260 or (unblocked and 999 or 180)*boost)
            local vMin = flying and (vMax*0.65) or (unstable and 120 or (150*boost))
            local target = throttle > 0.05 and vMax or (throttle < -0.05 and -vMin or 0)
            local accel = (math.abs(throttle) > 0.05 and 130 or 200) * step
            carCfg.velocidade = max(carCfg.velocidade, target, accel)
            if math.abs(steer) > 0.05 and math.abs(carCfg.velocidade) > 0.5 then
                local sign = carCfg.velocidade >= 0 and 1 or -1
                local ang = ((-steer*sign) * math.rad(85)) * step
                fwd = CFrame.Angles(0, ang, 0):VectorToWorldSpace(fwd)
            end
            carCfg.frente = fwd.Unit
            if flying then
                local vInput = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vInput = 1
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vInput = -1 end
                local vCap = T.vFlyVerticalSpeed * boost
                if vInput ~= 0 then
                    verticalVel = vInput * vCap
                    carCfg.altitude = raiz.Position.Y + verticalVel*step
                else
                    local diff = (carCfg.altitude or raiz.Position.Y) - raiz.Position.Y
                    verticalVel = math.clamp(diff*10, -vCap, vCap)
                end
            end
            local look = CFrame.lookAt(Vector3.zero, fwd.Unit, Vector3.yAxis)
            local rot = look * rel:Inverse()
            if flying then
                raiz.CFrame = CFrame.new(raiz.Position + Vector3.new(0, vertAdj, 0)) * rot
            elseif math.abs(vertAdj) > 0.01 then
                raiz.CFrame = raiz.CFrame + Vector3.new(0, vertAdj, 0)
            end
            if fwd.Magnitude > 0.001 then
                raiz.AssemblyLinearVelocity = fwd.Unit*carCfg.velocidade + Vector3.new(0, verticalVel, 0)
            else
                raiz.AssemblyLinearVelocity = Vector3.new(0, verticalVel, 0)
            end
            raiz.AssemblyAngularVelocity = Vector3.zero
        end
    end
    local function aplicarNoclipCar()
        if not T.noclipCarEnabled and not T.vFlyEnabled then
            restaurarNoclipCar(); return
        end
        local car = rz()
        if car ~= carCfg.carro then
            restaurarNoclipCar()
            carCfg.carro = car
            if car then prepararNoclipCar(car) end
        end
        if not car then return end
        sz(true)
        carCfg.personagemAtivo = true
        for _, p in ipairs(car:GetDescendants()) do
            if p:IsA("BasePart") then
                if carCfg.originais[p] == nil then carCfg.originais[p] = p.CanCollide end
                if p.CanCollide then p.CanCollide = false end
            end
        end
    end
    o.aplicarNoclipCar = aplicarNoclipCar
    o.restaurarNoclipCar = restaurarNoclipCar
    handleReady(RunService.Stepped:Connect(function() if not o.destroyed then pcall(aplicarNoclipCar) end end))
    handleReady(RunService.Heartbeat:Connect(function(dt)
        if not o.destroyed and (T.noclipCarEnabled or T.vFlyEnabled) then pcall(tickCar, dt) end
    end))
end
local function hz(hum)
    local st = Dz(hum)
    if not st then return false end
    st.RemapMultiplier = math.clamp(T.boostFactor, 1, 999)
    pcall(function() st:BuildHPCache() end)
    pcall(function()
        if st.SpeedLimit ~= nil then st.SpeedLimit = 999 end
        if st.MaxSpeed ~= nil then st.MaxSpeed = 999 end
        if st.TopSpeed ~= nil then st.TopSpeed = 999 end
        if st.SpeedCap ~= nil then st.SpeedCap = 999 end
    end)
    return true
end

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
o.state = T
C.__VETERANO_SINTONIA_RUNTIME = o

local function Wz(dt)
    if o.destroyed then return end
    local hum = isCValid()
    if hum then updateInstanceProperties(hum) end
    pcall(Fz, dt)
    if T.noclipEnabled then
        pcall(Nz)
        if not T.flyEnabled then pcall(ez) end
    end
    if T.flyEnabled or yz then pcall(xz, dt) end
end
handleReady(RunService.Heartbeat:Connect(Wz))
handleReady(RunService.Stepped:Connect(function()
    if not o.destroyed and T.noclipEnabled then pcall(sz, true) end
end))

task.spawn(function()
    local lastCar
    while not o.destroyed do
        local car = rz()
        if car then o.lastDrivenCar = car end
        if car and car ~= lastCar then
            local hum = isCValid()
            if hum then hz(hum) end
            lastCar = car
        elseif not car then lastCar = nil end
        task.wait(0.5)
    end
end)

local function vz(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        updateInstanceProperties(hum)
        hum.Jumping:Connect(uz)
    end
end
handleReady(LocalPlayer.CharacterAdded:Connect(vz))
if LocalPlayer.Character then vz(LocalPlayer.Character) end

-- ============================================
-- STAFF DETECTION
-- ============================================
local Jz = {}
do
    local CollectionService = game:GetService("CollectionService")
    local rankMin = 254
    local friendCol = Color3.fromRGB(60,210,255)
    local normCol = Color3.fromRGB(170,70,255)
    local staffKeywords = {"admin","staff","moder","owner","founder","creator","developer","dono","fundador","gerente","supervis","diretor","gestor"}
    local function hasKeyword(s)
        s = string.lower(tostring(s or ""))
        for _, k in ipairs(staffKeywords) do
            if string.find(s, k, 1, true) then return true end
        end
        return false
    end
    local function isTruthy(v)
        local tp = typeof(v)
        if tp == "boolean" then return v end
        if tp == "number" then return v > 0 end
        if tp == "string" then
            local s = string.lower(v)
            return s ~= "" and s ~= "false" and s ~= "0" and s ~= "none" and s ~= "guest" and s ~= "member"
        end
        return v ~= nil
    end
    local function isAdminRaw(plr)
        if game.CreatorType == Enum.CreatorType.User and plr.UserId == game.CreatorId then return true, "creator" end
        local ok, attrs = pcall(function() return plr:GetAttributes() end)
        if ok then
            for k, v in pairs(attrs) do
                if hasKeyword(k) and isTruthy(v) then return true, "attribute:"..k end
            end
        end
        local ok2, tags = pcall(CollectionService.GetTags, CollectionService, plr)
        if ok2 then
            for _, tag in ipairs(tags) do
                if hasKeyword(tag) then return true, "tag:"..tag end
            end
        end
        return false, nil
    end
    local function getRel(plr)
        local r = o.relationships[plr]
        if r then return r end
        r = {ready=false, checking=false, friend=false, admin=false, rank=0, role="", source=nil}
        o.relationships[plr] = r
        return r
    end
    local function checkReady(plr)
        if plr == LocalPlayer or plr.Parent ~= Players then return end
        local rel = getRel(plr)
        if rel.checking then return end
        rel.checking = true
        task.spawn(function()
            local friend = false
            local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
            if ok then friend = res == true end
            local admin, src = isAdminRaw(plr)
            local rank, role = 0, ""
            if game.CreatorType == Enum.CreatorType.Group and game.CreatorId > 0 then
                local ok2, r = pcall(function() return plr:GetRankInGroup(game.CreatorId) end)
                if ok2 and type(r)=="number" then rank = r end
                local ok3, ro = pcall(function() return plr:GetRoleInGroup(game.CreatorId) end)
                if ok3 and type(ro)=="string" then role = ro end
                if rank >= rankMin then admin, src = true, "group-rank:"..rank
                elseif hasKeyword(role) then admin, src = true, "group-role:"..role end
            end
            if plr.Parent == Players and o.relationships[plr] == rel then
                rel.friend=friend; rel.admin=admin; rel.rank=rank; rel.role=role
                rel.source=src; rel.ready=true; rel.checking=false
            end
        end)
    end
    local function getRelSafe(plr)
        local r = getRel(plr)
        if not r.ready and not r.checking then checkReady(plr) end
        return r
    end
    function Jz.Protected(plr)
        local r = getRelSafe(plr)
        if (T.friendCheck or T.adminCheck) and not r.ready then return true end
        if T.adminCheck and r.admin then return true end
        if T.friendCheck and r.friend then return true end
        return false
    end
    Jz.Admin = function(plr)
        local r = getRelSafe(plr)
        return r.ready and r.admin
    end
    Jz.Appearance = function(plr)
        local r = getRelSafe(plr)
        if r.ready and (T.adminCheck and r.admin) then return STAFF_RED, " [STAFF]" end
        if r.ready and (T.friendCheck and r.friend) then return friendCol, " [AMIGO]" end
        return normCol, ""
    end
    local function onAdded(plr)
        if plr == LocalPlayer then return end
        checkReady(plr)
        local conn = plr.AttributeChanged:Connect(function(name)
            if hasKeyword(name) then
                local r = o.relationships[plr]
                if r then r.ready = false end
                checkReady(plr)
            end
        end)
        o.relationshipConnections[plr] = conn
        handleReady(conn)
    end
    for _, plr in ipairs(Players:GetPlayers()) do onAdded(plr) end
    handleReady(Players.PlayerAdded:Connect(onAdded))
    handleReady(Players.PlayerRemoving:Connect(function(plr)
        o.relationships[plr] = nil
        o.relationshipConnections[plr] = nil
    end))
end

-- MONITOR STAFF (contador em background)
task.spawn(function()
    while not o.destroyed do
        if T.monitorarStaff then
            local count, nomes = 0, {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and Jz.Admin(plr) then
                    count = count + 1
                    table.insert(nomes, plr.Name)
                end
            end
            o.staffCount = count
            o.staffNames = nomes
        end
        task.wait(1)
    end
end)

-- ============================================
-- ESP
-- ============================================
local wz = {medido=false, drawing=false, texto=false}
function wz.set(obj, prop, val) return pcall(function() obj[prop]=val end) end
function wz.medir()
    if wz.medido then return wz end
    if Drawing == nil or type(Drawing.new) ~= "function" then return wz end
    local ok, sq = pcall(Drawing.new, "Square")
    if not ok then return wz end
    wz.drawing = true
    wz.filled = wz.set(sq, "Filled", false)
    wz.thickness = wz.set(sq, "Thickness", 1)
    pcall(function() sq:Remove() end)
    local ok2, txt = pcall(Drawing.new, "Text")
    if ok2 then
        wz.texto = true
        wz.center = wz.set(txt, "Center", true)
        wz.outline = wz.set(txt, "Outline", true)
        wz.outlineColor = wz.set(txt, "OutlineColor", Color3.new())
        wz.font = wz.set(txt, "Font", 2)
        pcall(function() txt.Text = "MMM" end)
        local ok3, tb = pcall(function() return txt.TextBounds end)
        wz.textBounds = ok3 and (typeof(tb)=="Vector2" and tb.X > 0)
        pcall(function() txt:Remove() end)
    end
    local ok4, tr = pcall(Drawing.new, "Triangle")
    wz.triangle = ok4 == true
    if ok4 then pcall(function() tr:Remove() end) end
    wz.medido = true
    return wz
end
function wz.ok() return (wz.medir()).drawing end

local function az(kind)
    if not wz.ok() then return nil end
    if kind == "Triangle" and not wz.triangle then return nil end
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    if not ok then return nil end
    wz.set(obj, "Visible", false); wz.set(obj, "Color", Color3.fromRGB(170,70,255))
    wz.set(obj, "Transparency", 1); wz.set(obj, "Thickness", 1)
    return obj
end
local function iz(col)
    if not wz.ok() or not wz.texto then return nil end
    local ok, obj = pcall(function() return Drawing.new("Text") end)
    if not ok then return nil end
    wz.set(obj, "Visible", false); wz.set(obj, "Color", col or Color3.fromRGB(170,70,255))
    wz.set(obj, "Transparency", 1); wz.set(obj, "Size", 13)
    if wz.center then wz.set(obj, "Center", true) end
    if wz.outline then wz.set(obj, "Outline", true) end
    if wz.outlineColor then wz.set(obj, "OutlineColor", Color3.new(0,0,0)) end
    if wz.font then wz.set(obj, "Font", 2) end
    return obj
end
local function larguraText(obj)
    if not obj then return 0 end
    if wz.textBounds then
        local ok, tb = pcall(function() return obj.TextBounds end)
        if ok and tb then return tb.X end
    end
    local ok, txt = pcall(function() return obj.Text end)
    if not ok or type(txt) ~= "string" then return 0 end
    local ok2, sz = pcall(function() return obj.Size end)
    return (#txt * (ok2 and sz or 13)) * 0.52
end

local dz = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local Gz = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"},
}
local tz = #dz
local Kz = {{1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,7},{4,8},{5,6},{5,7},{6,8},{7,8}}
local CF, YF, gF, mF = 300, 0.016666, 0.033333, 0.05
local EF, MF = 4, 5
local HF = function(prev, now, interval) if prev <= 0 or now-prev > interval then return now+interval end return prev+interval end

local function AF(plr)
    local b2 = {
        player=plr, box=az("Square"),
        name=iz(Color3.fromRGB(170,70,255)),
        distance=iz(Color3.fromRGB(190,200,225)),
        item=iz(Color3.fromRGB(190,200,225)),
        team=iz(Color3.fromRGB(170,70,255)),
        lines={}, tracer=nil, arrow=nil, box3dLines={}, highlight=nil,
        character=nil, humanoid=nil, root=nil, bodyParts={}, skeletonPairs={},
        relationshipColor=nil, relationshipLabel="",
        nextVisualUpdate=0, nextSkeletonUpdate=0,
    }
    if b2.box and wz.filled then b2.box.Filled = false end
    for _ = 1, tz do table.insert(b2.lines, az("Line")) end
    T.bundles[plr] = b2
    return b2
end
local function FF(b2)
    if b2.box then b2.box.Visible=false end
    if b2.name then b2.name.Visible=false end
    if b2.distance then b2.distance.Visible=false end
    if b2.item then b2.item.Visible=false end
    if b2.team then b2.team.Visible=false end
    if b2.tracer then b2.tracer.Visible=false end
    if b2.arrow then b2.arrow.Visible=false end
    for _, l in ipairs(b2.lines) do l.Visible=false end
    for _, l in ipairs(b2.box3dLines) do l.Visible=false end
end
local function uF(b2)
    FF(b2)
    if b2.highlight then b2.highlight.Enabled = false end
end
local function qF(b2)
    if not b2 then return end
    local function h(obj) if obj then pcall(function() obj:Remove() end) end end
    h(b2.box); h(b2.name); h(b2.distance); h(b2.item); h(b2.team); h(b2.tracer); h(b2.arrow)
    for _, l in ipairs(b2.lines) do h(l) end
    for _, l in ipairs(b2.box3dLines) do h(l) end
    if b2.highlight then pcall(function() b2.highlight:Destroy() end); b2.highlight=nil end
end
local function PF() for _, b2 in pairs(T.bundles) do uF(b2) end end
local function zF(cam, pos)
    local s, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(s.X, s.Y), onScreen, s.Z
end
local function oF(b2)
    if b2.tracer then return b2.tracer end
    b2.tracer = az("Line")
    if b2.tracer then
        if wz.thickness then b2.tracer.Thickness = 1.5 end
        b2.tracer.Color = b2.relationshipColor or Color3.fromRGB(170,70,255)
    end
    return b2.tracer
end
local function TF(b2)
    if b2.arrow then return b2.arrow end
    b2.arrow = az("Triangle")
    if b2.arrow then
        if wz.filled then b2.arrow.Filled = true end
        if wz.thickness then b2.arrow.Thickness = 1 end
        b2.arrow.Color = b2.relationshipColor or Color3.fromRGB(170,70,255)
    end
    return b2.arrow
end
local function fF(b2)
    if #b2.box3dLines > 0 then return b2.box3dLines end
    for _ = 1, #Kz do
        local l = az("Line")
        if l then
            if wz.thickness then l.Thickness = 1 end
            l.Color = b2.relationshipColor or Color3.fromRGB(170,70,255)
            table.insert(b2.box3dLines, l)
        end
    end
    return b2.box3dLines
end
local function RF(b2, char)
    local hl = b2.highlight
    if not hl or not hl.Parent then
        local ok, newHl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "VeteranoESP_"..tostring(b2.player.UserId)
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillTransparency = 0.78; h.OutlineTransparency = 0
            h.Parent = workspace.CurrentCamera or workspace
            return h
        end)
        if not ok then return nil end
        hl = newHl; b2.highlight = hl
    elseif hl.Parent ~= (workspace.CurrentCamera or workspace) then
        hl.Parent = workspace.CurrentCamera or workspace
    end
    local col = b2.relationshipColor or Color3.fromRGB(170,70,255)
    hl.Adornee = char; hl.FillColor = col; hl.OutlineColor = col
    return hl
end
local function QF(b2, cam, screenPos, z)
    local arrow = TF(b2)
    if not arrow then return end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X*0.5, vp.Y*0.5)
    local dir = screenPos - center
    if z <= 0 then dir = -dir end
    if dir.Magnitude < 0.001 then dir = Vector2.new(0,-1) end
    local unit = dir.Unit
    local radius = math.max(40, math.min(vp.X, vp.Y)*0.42)
    local tip = center + unit*radius
    local back = tip - unit*14
    local perp = Vector2.new(-unit.Y, unit.X)*8
    arrow.PointA = tip
    arrow.PointB = back + perp
    arrow.PointC = back - perp
    arrow.Visible = true
end
local function VF(b2, char, hum, root)
    if b2.character == char and b2.humanoid == hum and b2.root == root then return end
    b2.character, b2.humanoid, b2.root = char, hum, root
    table.clear(b2.bodyParts); table.clear(b2.skeletonPairs)
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") then table.insert(b2.bodyParts, p) end
    end
    local pairsList = (hum.RigType == Enum.HumanoidRigType.R15) and dz or Gz
    for _, pr in ipairs(pairsList) do
        table.insert(b2.skeletonPairs, {char:FindFirstChild(pr[1]), char:FindFirstChild(pr[2])})
    end
end
local function pF(plr)
    local t = plr.Team
    local name = t and t.Name or nil
    if Jz.Admin(plr) and name ~= "STAFF" then return name and ("STAFF | "..name) or "STAFF" end
    return name
end
local function IF(plr)
    local t = plr.Team
    local ok, col = pcall(function() return t.TeamColor.Color end)
    return (ok and col) or Color3.fromRGB(170,70,255)
end
local function OF(plr, b2)
    local col, suffix = Jz.Appearance(plr)
    b2.relationshipLabel = suffix
    if b2.relationshipColor == col then return end
    b2.relationshipColor = col
    if b2.box then b2.box.Color=col end
    if b2.name then b2.name.Color=col end
    if b2.distance then b2.distance.Color=col end
    if b2.item then b2.item.Color=col end
    if b2.tracer then b2.tracer.Color=col end
    if b2.arrow then b2.arrow.Color=col end
    if b2.highlight then b2.highlight.FillColor=col; b2.highlight.OutlineColor=col end
    for _, l in ipairs(b2.lines) do if l then l.Color=col end end
    for _, l in ipairs(b2.box3dLines) do if l then l.Color=col end end
end
local function XF(plr, b2, cam, myPos, now)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or hum.Health <= 0 or not root then
        b2.character = nil; b2.nextVisualUpdate = now + mF; uF(b2); return
    end
    VF(b2, char, hum, root)
    local dist = (root.Position - myPos).Magnitude
    if dist > T.maxDistance then
        b2.nextVisualUpdate = now + mF; uF(b2); return
    end
    OF(plr, b2)
    if T.highlight then
        local hl = RF(b2, char)
        if hl then hl.Enabled = true end
    elseif b2.highlight then b2.highlight.Enabled = false end
    local screenPos, onScreen, z = zF(cam, root.Position)
    if not onScreen or z <= 0 then
        b2.nextVisualUpdate = now + mF; FF(b2)
        if T.arrow then QF(b2, cam, screenPos, z) end
        return
    end
    local close = dist <= CF
    local interval = close and YF or gF
    b2.nextVisualUpdate = HF(b2.nextVisualUpdate, now, interval)
    if b2.arrow then b2.arrow.Visible = false end
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyOnScreen = false
    local screenCorners, zCorners = {}, {}
    if T.box or T.name or T.distance or T.box3d or T.teamTag then
        local bbMin, bbMax
        for _, p in ipairs(b2.bodyParts) do
            if p.Parent == char then
                local half = p.Size*0.5
                local a, b2v = p.Position-half, p.Position+half
                if bbMin then
                    bbMin = Vector3.new(math.min(bbMin.X,a.X), math.min(bbMin.Y,a.Y), math.min(bbMin.Z,a.Z))
                    bbMax = Vector3.new(math.max(bbMax.X,b2v.X), math.max(bbMax.Y,b2v.Y), math.max(bbMax.Z,b2v.Z))
                else bbMin, bbMax = a, b2v end
            end
        end
        if bbMin then
            local idx = 0
            for xi = 0, 1 do for yi = 0, 1 do for zi = 0, 1 do
                idx = idx + 1
                local corner = Vector3.new(xi==0 and bbMin.X or bbMax.X, yi==0 and bbMin.Y or bbMax.Y, zi==0 and bbMin.Z or bbMax.Z)
                local sp, onS, zc = zF(cam, corner)
                screenCorners[idx] = sp; zCorners[idx] = zc
                if zc > 0.5 then
                    anyOnScreen = true
                    minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
                    maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
                end
            end end end
        end
        if anyOnScreen then
            local vp = cam.ViewportSize
            minX = math.clamp(minX, -32, vp.X+32); maxX = math.clamp(maxX, -32, vp.X+32)
            minY = math.clamp(minY, -32, vp.Y+32); maxY = math.clamp(maxY, -32, vp.Y+32)
            if maxX-minX < 1 or maxY-minY < 1 then anyOnScreen = false end
        end
    end
    if T.box and b2.box then
        if anyOnScreen then
            b2.box.Position = Vector2.new(minX, minY)
            b2.box.Size = Vector2.new(maxX-minX, maxY-minY)
            b2.box.Visible = true
        else b2.box.Visible = false end
    elseif b2.box then b2.box.Visible = false end
    if T.name and b2.name then
        if anyOnScreen then
            b2.name.Text = plr.Name..b2.relationshipLabel
            b2.name.Position = Vector2.new((minX+maxX)/2, minY-18)
            b2.name.Visible = true
        else b2.name.Visible = false end
    elseif b2.name then b2.name.Visible = false end
    if T.teamTag and b2.team then
        local teamName = anyOnScreen and pF(plr) or nil
        if teamName then
            b2.team.Text = teamName
            if Jz.Admin(plr) and plr.Team and plr.Team.Name == "STAFF" then b2.team.Color = YEL or Color3.fromRGB(255,200,50)
            else b2.team.Color = IF(plr) end
            b2.team.Position = Vector2.new((minX+maxX)/2, (T.name and (b2.name and b2.name.Visible)) and (minY-32) or (minY-18))
            b2.team.Visible = true
        else b2.team.Visible = false end
    elseif b2.team then b2.team.Visible = false end
    if T.distance and b2.distance then
        if anyOnScreen then
            b2.distance.Text = string.format("%dm", math.floor(dist))
            if wz.center then b2.distance.Center = true end
            b2.distance.Position = Vector2.new((minX+maxX)/2, maxY+3)
            b2.distance.Visible = true
        else b2.distance.Visible = false end
    elseif b2.distance then b2.distance.Visible = false end
    if T.heldItem and b2.item then
        local c2 = b2.character or plr.Character
        local tool = anyOnScreen and (c2 and c2:FindFirstChildOfClass("Tool"))
        if tool then
            b2.item.Text = tool.Name
            local cx = (minX+maxX)/2
            if T.distance and (b2.distance and b2.distance.Visible) then
                local dw = larguraText(b2.distance); local iw = larguraText(b2.item)
                local startX = cx - ((dw+MF)+iw)/2
                if wz.center then b2.distance.Center = false end
                b2.distance.Position = Vector2.new(startX, maxY+3)
                if wz.center then b2.item.Center = false end
                b2.item.Position = Vector2.new((startX+dw)+MF, maxY+3)
            else
                if wz.center then b2.item.Center = true end
                b2.item.Position = Vector2.new(cx, maxY+3)
            end
            b2.item.Visible = true
        else b2.item.Visible = false end
    elseif b2.item then b2.item.Visible = false end
    if T.tracer then
        local tr = oF(b2)
        if tr then
            local vp = cam.ViewportSize
            tr.From = Vector2.new(vp.X*0.5, vp.Y-4)
            tr.To = anyOnScreen and Vector2.new((minX+maxX)*0.5, (minY+maxY)*0.5) or screenPos
            tr.Visible = true
        end
    elseif b2.tracer then b2.tracer.Visible = false end
    if T.box3d then
        local lines = fF(b2)
        for i, pr in ipairs(Kz) do
            local l = lines[i]
            local p1, p2 = screenCorners[pr[1]], screenCorners[pr[2]]
            local z1, z2 = zCorners[pr[1]], zCorners[pr[2]]
            if l and p1 and p2 and z1 and z2 and z1 > 0.5 and z2 > 0.5 then
                l.From = p1; l.To = p2; l.Visible = true
            elseif l then l.Visible = false end
        end
    else
        for _, l in ipairs(b2.box3dLines) do l.Visible = false end
    end
    if not T.skeleton then
        for _, l in ipairs(b2.lines) do l.Visible = false end
    elseif now >= b2.nextSkeletonUpdate then
        local interval = close and YF or gF
        b2.nextSkeletonUpdate = HF(b2.nextSkeletonUpdate, now, interval)
        for i, l in ipairs(b2.lines) do
            local pr = b2.skeletonPairs[i]
            if pr and l then
                local p1, p2 = pr[1], pr[2]
                if p1 and p2 and p1.Parent == char and p2.Parent == char then
                    local s1, on1, z1 = zF(cam, p1.Position)
                    local s2, on2, z2 = zF(cam, p2.Position)
                    if on1 and on2 and z1 > 0.5 and z2 > 0.5 then
                        l.From = s1; l.To = s2; l.Visible = true
                    else l.Visible = false end
                else l.Visible = false end
            elseif l then l.Visible = false end
        end
    end
end

handleReady(Players.PlayerRemoving:Connect(function(plr)
    local b2 = T.bundles[plr]
    if b2 then qF(b2); T.bundles[plr] = nil end
end))

local BF = false
handleReady(RunService.RenderStepped:Connect(function()
    if not T.espEnabled then
        if BF then PF() end
        BF = false; return
    end
    BF = true
    local cam = workspace.CurrentCamera
    if not cam then PF(); return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = root and root.Position or cam.CFrame.Position
    local list = Players:GetPlayers()
    local now = os.clock()
    local budget = EF
    for _, plr in ipairs(list) do
        if plr ~= LocalPlayer then
            local b2 = T.bundles[plr]
            if not b2 and budget > 0 then
                local ok, res = pcall(AF, plr)
                if ok then b2 = res elseif not o.espErro then o.espErro = tostring(res) end
                budget = budget - 1
            end
            if b2 and now >= b2.nextVisualUpdate then
                local ok, err = pcall(XF, plr, b2, cam, myPos, now)
                if not ok and not o.espErro then o.espErro = tostring(err) end
            end
        end
    end
end))

-- ============================================
-- AIMBOT
-- ============================================
local SF = {
    Cabeca = {"Head"},
    Tronco = {"Torso","UpperTorso","LowerTorso","HumanoidRootPart"},
}
local function eF(char)
    local list = SF[T.aimbotBodyPart] or SF.Cabeca
    for _, n in ipairs(list) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    return char:FindFirstChild("Head")
end
local function temLinhaDeVisao(cam, target, char)
    local from = cam.CFrame.Position
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {LocalPlayer.Character, char, cam}
    local hit = workspace:Raycast(from, target.Position-from, rp)
    return hit == nil
end
local function getClosestTarget(cam, maxFov, maxDist)
    local myPos = cam.CFrame.Position
    local center = cam.ViewportSize/2
    local best, bestD = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not Jz.Protected(plr) then
            local char = plr.Character
            local part = char and eF(char)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 and (part.Position-myPos).Magnitude <= maxDist then
                local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y)-center).Magnitude
                    if d <= maxFov and d < bestD then
                        if not T.aimbotWallCheck or temLinhaDeVisao(cam, part, char) then
                            best, bestD = part, d
                        end
                    end
                end
            end
        end
    end
    return best
end
local aimbotConnection = nil
local function aimbotLoop()
    if aimbotConnection then return end
    aimbotConnection = RunService.RenderStepped:Connect(function(dt)
        if not T.aimbotEnabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if T.aimbotMode == "Legit" then
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
        end
        local target = getClosestTarget(cam, T.aimbotFov, T.aimbotDistance)
        if not target then return end
        local myPos = cam.CFrame.Position
        local targetPos = target.Position
        if T.aimbotMode == "Rage" then
            cam.CFrame = CFrame.new(myPos, targetPos)
        else
            local currentLook = cam.CFrame.LookVector
            local desiredLook = (targetPos-myPos).Unit
            local smooth = math.clamp(T.aimbotSmoothness, 0.01, 1)
            local factor = math.clamp(smooth * 8, 0.02, 0.35)
            local dot = currentLook:Dot(desiredLook)
            if dot > 0.998 then factor = 0.6 end
            local newLook = currentLook:Lerp(desiredLook, factor)
            cam.CFrame = CFrame.new(myPos, myPos+newLook)
        end
    end)
end
local function stopAimbot()
    if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end
end

-- ============================================
-- PERFECT LOCKPICK
-- ============================================
local function bF()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local lp = pg:FindFirstChild("Lockpick")
    if not lp then return nil end
    local inner = lp:FindFirstChild("Lockpick") or lp
    if not inner or not inner.Visible then return nil end
    local bloco = inner:FindFirstChild("Bloco")
    local obj = inner:FindFirstChild("Objetivo")
    local btn = inner:FindFirstChild("Btn")
    if bloco and obj and btn and bloco.Visible and obj.Visible then return bloco, obj, btn end
    return nil
end
local function yF(bloco, obj)
    local bp, bs = bloco.AbsolutePosition, bloco.AbsoluteSize
    local op, os = obj.AbsolutePosition, obj.AbsoluteSize
    if bp.X+bs.X < op.X or bp.X > op.X+os.X then return false end
    local cy = bp.Y+bs.Y/2
    local m = os.Y*0.25
    return cy >= op.Y+m and cy <= op.Y+os.Y-m
end
local function xF(btn)
    if not btn then return end
    if type(getconnections) == "function" then
        local ok, conns = pcall(getconnections, btn.MouseButton1Click)
        if ok and type(conns) == "table" and #conns > 0 then
            for _, c2 in ipairs(conns) do
                if type(c2.Function) == "function" then pcall(task.spawn, c2.Function) end
            end
            return
        end
    end
    if type(firesignal) == "function" then pcall(firesignal, btn.MouseButton1Click) return end
end
local cF, lF = 0.35, 0
handleReady(RunService.RenderStepped:Connect(function()
    if not T.perfectLockpick then return end
    local bloco, obj, btn = bF()
    if not bloco then return end
    if os.clock() - lF < cF then return end
    if not yF(bloco, obj) then
        pcall(function() obj.Position = UDim2.new(0.5, 0, bloco.Position.Y.Scale, bloco.Position.Y.Offset) end)
        return
    end
    lF = os.clock(); xF(btn)
end))

-- ============================================
-- COLETAR ITENS
-- ============================================
local WHITELIST_ARMAS = {
    ["ak47"]=true,["fal"]=true,["fuzil"]=true,["glock"]=true,["oitão"]=true,
    ["oit_o"]=true,["oit_o_"]=true,["submetralhadora"]=true,["usps"]=true,["uzi"]=true,
    ["barret"]=true,["fuzilhollow"]=true,["fuzilphantom"]=true,["fuziltrovão"]=true,
    ["fuziltrovao"]=true,["g3"]=true,["ptdragon"]=true,["ptneon"]=true,["ptnk"]=true,
    ["armapdsecreta"]=true,["fuzilninja"]=true,["fuzilpascoa"]=true,["fuzilpáscoa"]=true,
    ["natalina"]=true,["ptninja"]=true,["ptpascoa"]=true,["ptpáscoa"]=true,
}
local function normalizarNome(nome)
    if not nome then return "" end
    local n = tostring(nome)
    n = n:gsub("[áàãâä]","a"):gsub("[éèêë]","e"):gsub("[íìîï]","i")
    n = n:gsub("[óòõôö]","o"):gsub("[úùûü]","u"):gsub("ç","c")
    return n:lower():gsub("[^%w]","")
end
local function ehArmaPermitida(nome)
    local key = normalizarNome(nome)
    if key == "" then return false end
    if WHITELIST_ARMAS[key] then return true end
    for arma in pairs(WHITELIST_ARMAS) do
        if #arma >= 3 and key:find(arma, 1, true) then return true end
    end
    return false
end
o.ehArmaPermitida = ehArmaPermitida
local POSICAO_RETORNO = Vector3.new(-227, 38, 144)
local function aF(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") end
    return nil
end
local function dF(item)
    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt or not prompt.Enabled then return false end
    if type(fireproximityprompt) == "function" then return pcall(fireproximityprompt, prompt, 0) end
    return pcall(function()
        prompt:InputHoldBegin()
        task.wait(math.max(0.15, prompt.HoldDuration+0.1))
        prompt:InputHoldEnd()
    end)
end
local function GF(target, checkDone)
    o.itemTeleportRunId = o.itemTeleportRunId + 1
    local runId = o.itemTeleportRunId
    local hadNoclip = T.noclipEnabled
    if not hadNoclip then T.noclipEnabled = true; pcall(Nz) end
    local reached = false
    local function destinoExato()
        local yy = target.parte.Position.Y + (target.parte.Size.Y * 0.5) + 3
        return Vector3.new(target.parte.Position.X, yy, target.parte.Position.Z)
    end
    do
        local deadline = os.clock()+8
        while os.clock() < deadline do
            if o.destroyed or runId ~= o.itemTeleportRunId then break end
            if not target.item.Parent or not target.parte.Parent then reached = true; break end
            local root = isUpdatePlayerGetMagnitudeCValid()
            if not root then break end
            local dest = destinoExato()
            if (dest-root.Position).Magnitude <= 1 then reached = true; break end
            root.CFrame = CFrame.new(dest)
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.05)
        end
    end
    local root3 = isUpdatePlayerGetMagnitudeCValid()
    if root3 then root3.AssemblyLinearVelocity = Vector3.zero end
    if reached and runId == o.itemTeleportRunId then
        local rootF = isUpdatePlayerGetMagnitudeCValid()
        if rootF and target.parte and target.parte.Parent then
            local topoY = target.parte.Position.Y + (target.parte.Size.Y * 0.5) + 3
            rootF.CFrame = CFrame.new(target.parte.Position.X, topoY, target.parte.Position.Z)
            rootF.AssemblyLinearVelocity = Vector3.zero
            rootF.AssemblyAngularVelocity = Vector3.zero
        end
    end
    if reached and runId == o.itemTeleportRunId then
        local doneCheck = checkDone or function() return not target.item.Parent end
        for _ = 1, 5, 1 do
            if doneCheck() then break end
            dF(target.item)
            task.wait(0.15)
        end
    end
    if reached and runId == o.itemTeleportRunId and not o.destroyed then
        local rootBack = isUpdatePlayerGetMagnitudeCValid()
        if rootBack then
            task.wait(0.25)
            rootBack = isUpdatePlayerGetMagnitudeCValid()
            if rootBack then
                rootBack.CFrame = CFrame.new(POSICAO_RETORNO)
                rootBack.AssemblyLinearVelocity = Vector3.zero
                rootBack.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
    if not hadNoclip and runId == o.itemTeleportRunId then
        T.noclipEnabled = false; pcall(Nz)
    end
    return reached
end
o.coletarItem = GF

o.listDrops = function()
    local out = {}
    local root = isUpdatePlayerGetMagnitudeCValid()
    if not root then return out end
    local pastas = {"DropadosInv","Drops","ItensDropados","ItensNoChao","ItemsDrop","DropsInv"}
    local vistos = {}
    local found = false
    for _, nome in ipairs(pastas) do
        local folder = workspace:FindFirstChild(nome)
        if folder then
            found = true
            for _, obj in ipairs(folder:GetChildren()) do
                if not vistos[obj] then
                    vistos[obj] = true
                    local part = aF(obj)
                    if part and ehArmaPermitida(obj.Name) then
                        table.insert(out, {item=obj, parte=part, nome=obj.Name,
                            distancia=(root.Position - part.Position).Magnitude})
                    end
                end
            end
        end
    end
    if not found then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not vistos[obj] and obj:IsA("BasePart") then
                local isChar = LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)
                if not isChar and ehArmaPermitida(obj.Name) then
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        vistos[obj] = true
                        table.insert(out, {item=obj, parte=obj, nome=obj.Name,
                            distancia=(root.Position - obj.Position).Magnitude})
                    end
                end
            end
        end
    end
    table.sort(out, function(a,b) return a.distancia < b.distancia end)
    return out
end

do
    local coleta = {runId = 0}
    local function startAutoColeta()
        if T.autoColetaEnabled then return end
        T.autoColetaEnabled = true
        coleta.runId = coleta.runId + 1
        local myId = coleta.runId
        task.spawn(function()
            while T.autoColetaEnabled and not o.destroyed and myId == coleta.runId do
                local drops = o.listDrops and o.listDrops() or {}
                local alvo = drops[1]
                if alvo and alvo.item.Parent then pcall(GF, alvo) end
                task.wait(math.max(0.1, T.autoColetaCooldown * 0.5))
            end
        end)
    end
    local function stopAutoColeta()
        T.autoColetaEnabled = false
        coleta.runId = coleta.runId + 1
    end
    o.startAutoColeta = startAutoColeta
    o.stopAutoColeta = stopAutoColeta
end

-- ============================================
-- AUTO FARM PARTES DE ARMA
-- ============================================
do
    local function tF()
        local folder = workspace:FindFirstChild("FarmPartesDeArma")
        folder = folder and folder:FindFirstChild("Locais")
        if not folder then return nil end
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("BasePart") and obj:FindFirstChild("GUI") then return obj end
        end
        local root = isUpdatePlayerGetMagnitudeCValid()
        if not root then return nil end
        local best, bestD
        for _, obj in ipairs(folder:GetChildren()) do
            local prompt = obj:IsA("BasePart") and obj:FindFirstChild("Interagir")
            if prompt and prompt.Enabled then
                local d = (root.Position-obj.Position).Magnitude
                if not bestD or d < bestD then best, bestD = obj, d end
            end
        end
        return best
    end
    local function KF()
        o.farmPartesRunId = o.farmPartesRunId + 1
        T.farmPartesEnabled = false
    end
    local Cf = 15
    local function Yf()
        if T.flyEnabled then T.flyEnabled = false; pcall(xz) end
        o.farmPartesRunId = o.farmPartesRunId + 1
        local runId = o.farmPartesRunId
        local count = 0
        local hadNoclip = T.noclipEnabled
        if not hadNoclip then T.noclipEnabled = true; pcall(Nz) end
        while T.farmPartesEnabled and (not o.destroyed and runId == o.farmPartesRunId) do
            local alvo = tF()
            if not alvo then task.wait(1)
            else
                local target = alvo
                local reached = GF({item=target, parte=target}, function() return tF() ~= target end)
                if runId ~= o.farmPartesRunId then break end
                local moved = reached and tF() ~= target
                if moved then count = count+1 end
                local wait = moved and Cf or 1
                local deadline = os.clock()+wait
                while os.clock() < deadline do
                    if not T.farmPartesEnabled or o.destroyed or runId ~= o.farmPartesRunId then break end
                    task.wait(0.2)
                end
            end
        end
        if runId == o.farmPartesRunId then T.farmPartesEnabled = false; o.farmPartesColetadas = count end
        if not hadNoclip and (not T.farmPartesEnabled or runId == o.farmPartesRunId) then
            T.noclipEnabled = false; pcall(Nz)
        end
        return count
    end
    o.iniciarFarmPartes = Yf
    o.pararFarmPartes = KF
end

-- ============================================
-- WEAPONS + TRACER COR
-- ============================================
do
    local tracerColors = {
        {"Ciano",Color3.fromRGB(0,255,255)},{"Verde",Color3.fromRGB(60,255,90)},
        {"Rosa",Color3.fromRGB(255,60,190)},{"Roxo",Color3.fromRGB(160,70,255)},
        {"Vermelho",Color3.fromRGB(255,45,45)},{"Azul",Color3.fromRGB(70,130,255)},
        {"Laranja",Color3.fromRGB(255,145,30)},{"Branco",Color3.fromRGB(240,240,240)},
        {"Amarelo",Color3.fromRGB(255,230,60)},{"VerdeLimao",Color3.fromRGB(180,255,0)},
        {"Magenta",Color3.fromRGB(255,0,200)},{"Turquesa",Color3.fromRGB(0,200,180)},
        {"Arco-iris",nil},
    }
    local corBalaOriginal = nil
    local function getCorBala()
        local Cc = LocalPlayer:FindFirstChild("OrpheusGunCFG")
        local Y = Cc and Cc:FindFirstChild("CorBala")
        if Y and corBalaOriginal == nil then corBalaOriginal = Y.Color end
        return Y
    end
    local function aplicarCorBala()
        local cor = getCorBala()
        if not cor then return end
        if not T.armaTracer then
            if corBalaOriginal then pcall(function() cor.Color = corBalaOriginal end) end
            return
        end
        if T.armaTracerCor == "Arco-iris" then
            cor.Color = Color3.fromHSV((os.clock()*0.25) % 1, 1, 1); return
        end
        for _, g in ipairs(tracerColors) do
            if g[1] == T.armaTracerCor and g[2] then cor.Color = g[2]; return end
        end
    end
    o.restaurarArmas = function()
        pcall(aplicarCorBala)
        local cor = getCorBala()
        if cor and corBalaOriginal then pcall(function() cor.Color = corBalaOriginal end) end
    end
    handleReady(RunService.RenderStepped:Connect(function()
        if o.destroyed then return end
        if not T.armaTracer then return end
        pcall(aplicarCorBala)
    end))
end

-- ============================================
-- GACHA 2%
-- ============================================
do
    local RS = game:GetService("ReplicatedStorage")
    local CHANCE_MINIMA = 0.02
    local MULTIPLICADOR = 3
    local ARMAS_RARAS = {
        Natalina=true, PtNinja=true, PtPaschoa=true,
        FuzilPaschoa=true, FuzilNinja=true, ArmaPDSecreta=true,
        Barret=true, FuzilTrovao=true, FuzilPhantom=true,
    }
    local hooked = false
    local originalData = {}
    local function snapshot(t, seen)
        seen = seen or {}
        if seen[t] then return seen[t] end
        local copy = {}; seen[t] = copy
        for k, v in pairs(t) do
            if type(v)=="table" then copy[k] = snapshot(v, seen) else copy[k] = v end
        end
        return copy
    end
    local function ehRara(nome)
        if not nome then return false end
        nome = tostring(nome)
        if ARMAS_RARAS[nome] then return true end
        local low = string.lower(nome)
        if string.find(low,"ninja") or string.find(low,"paschoa") or string.find(low,"secreta")
            or string.find(low,"trovao") or string.find(low,"phantom") or string.find(low,"barret")
            or string.find(low,"natalina") then return true end
        return false
    end
    local function reescreverChances(tbl, depth)
        depth = depth or 0
        if depth > 12 then return end
        for k, v in pairs(tbl) do
            if type(v)=="table" then
                local nome = v.Nome or v.nome or v.Name or v.name or k
                local eraRara = ehRara(nome)
                for _, field in ipairs({"Chance","chance","Weight","weight","Probabilidade","probabilidade","Rate","rate","DropChance","dropChance"}) do
                    if type(v[field])=="number" and v[field] > 0 then
                        if eraRara then v[field] = CHANCE_MINIMA
                        elseif v[field] < CHANCE_MINIMA then v[field] = CHANCE_MINIMA
                        else v[field] = v[field] * MULTIPLICADOR end
                    end
                end
                reescreverChances(v, depth+1)
            end
        end
    end
    local function aplicarGacha()
        if hooked then return end
        hooked = true
        local function scanMods(container, depth)
            if depth > 6 then return end
            for _, mod in ipairs(container:GetChildren()) do
                if mod:IsA("ModuleScript") then
                    local n = string.lower(mod.Name)
                    if string.find(n,"gacha") or string.find(n,"roleta") or string.find(n,"sorteio")
                        or string.find(n,"spin") or string.find(n,"crate") or string.find(n,"caixa")
                        or string.find(n,"loot") or string.find(n,"premi") or string.find(n,"reward")
                        or string.find(n,"raridade") then
                        local ok, data = pcall(require, mod)
                        if ok and type(data)=="table" then
                            if not originalData[mod] then originalData[mod] = snapshot(data) end
                            pcall(reescreverChances, data, 0)
                        end
                    end
                end
                scanMods(mod, depth+1)
            end
        end
        scanMods(RS, 0)
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        if ps then scanMods(ps, 0) end
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then scanMods(pg, 0) end
    end
    local function restaurarGacha()
        for mod, snap in pairs(originalData) do
            pcall(function()
                local ok, data = pcall(require, mod)
                if ok and type(data)=="table" then
                    for k, v in pairs(snap) do
                        if type(v)=="table" then data[k] = snapshot(v) else data[k] = v end
                    end
                end
            end)
        end
        originalData = {}; hooked = false
    end
    o.aplicarGacha = aplicarGacha
    o.restaurarGacha = restaurarGacha
    task.spawn(function() task.wait(2) pcall(aplicarGacha) end)
    local ultimoEstado = false
    handleReady(RunService.Heartbeat:Connect(function()
        if o.destroyed then return end
        if T.sorte2xEnabled and not ultimoEstado then pcall(aplicarGacha)
        elseif not T.sorte2xEnabled and ultimoEstado then pcall(restaurarGacha) end
        ultimoEstado = T.sorte2xEnabled
    end))
end

-- ============================================
-- AUTO FARM PESCA
-- ============================================
do
    local PESCA_TP = Vector3.new(-1165, -33, -5055)
    local function getCharacter()
        local character = LocalPlayer.Character
        if not character then return end
        return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
    end
    local function isRun(runId) return T.autoFarmPescaEnabled and (not o.destroyed and o.pescaRunId == runId) end
    local function firePrompt(prompt)
        if not prompt or not prompt.Parent or not prompt.Enabled then return false end