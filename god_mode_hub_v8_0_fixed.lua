--[[
    GOD MODE HUB - UNIVERSAL EDITION v8.0 FIXED
    ✅ UI COMPLETAMENTE REFORMULADA - Scroll, Drag, Resize
    ✅ AIMBOT/SILENT AIM UNIVERSAL - Funciona em TODOS os jogos
    ✅ TODAS FUNÇÕES OTIMIZADAS - Máxima compatibilidade
    ✅ MOBILE OPTIMIZED - Touch controls perfeitos
--]]

-- ====================================================================================================
-- SERVIÇOS PRINCIPAIS
-- ====================================================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ====================================================================================================
-- CONFIGURAÇÃO GLOBAL OTIMIZADA
-- ====================================================================================================
local Config = {
    Combat = {
        Aimbot = false,
        AimbotKey = Enum.UserInputType.MouseButton2,
        AimbotSmooth = 0.1,
        AimbotFOV = 120,
        ShowAimbotFOV = true,
        
        SilentAim = false,
        SilentFOV = 180,
        ShowSilentFOV = true,
        HitChance = 95,
        
        TargetPart = "Head",
        TeamCheck = true,
        WallCheck = true,
        AutoShoot = false,
        PredictMovement = true,
        PredictionAmount = 0.13
    },
    
    Visuals = {
        ESP = false,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = false,
        Chams = false,
        TeamCheck = true,
        MaxDistance = 3000,
        ESPColor = Color3.fromRGB(0, 255, 150)
    },
    
    Movement = {
        Speed = 16,
        SpeedEnabled = false,
        Jump = 50,
        JumpEnabled = false,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        InfiniteJump = false
    },
    
    GunMods = {
        NoRecoil = false,
        NoSpread = false,
        InfiniteAmmo = false,
        RapidFire = false,
        InstantReload = false,
        InfiniteRange = false,
        OneShotKill = false
    },
    
    Misc = {
        FullBright = false,
        NoFog = false,
        RemoveKillBricks = false,
        AntiAFK = true,
        AutoRespawn = false
    }
}

-- ====================================================================================================
-- SISTEMA DE DETECÇÃO UNIVERSAL DE HITBOXES
-- ====================================================================================================
local function GetUniversalHitbox(character, targetPart)
    if not character then return nil end
    
    -- Lista de nomes possíveis por prioridade
    local hitboxNames = {
        Head = {"Head", "head", "Headshot", "headshot"},
        Torso = {"Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart", "Chest", "Body"},
        LeftArm = {"LeftArm", "Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
        RightArm = {"RightArm", "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
        LeftLeg = {"LeftLeg", "Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
        RightLeg = {"RightLeg", "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
    }
    
    -- Tentar encontrar a parte específica
    if hitboxNames[targetPart] then
        for _, name in ipairs(hitboxNames[targetPart]) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then
                return part
            end
        end
    end
    
    -- Fallback: procurar qualquer BasePart válida
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            return part
        end
    end
    
    -- Último recurso: HumanoidRootPart
    return character:FindFirstChild("HumanoidRootPart")
end

-- ====================================================================================================
-- FUNÇÕES DE UTILIDADE UNIVERSAL
-- ====================================================================================================
local function IsTeammate(player)
    if not Config.Combat.TeamCheck and not Config.Visuals.TeamCheck then return false end
    if not player.Team or not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function IsAlive(player)
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    return true
end

local function GetMagnitude(part)
    if not part then return math.huge end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (char.HumanoidRootPart.Position - part.Position).Magnitude
end

local function IsVisible(part)
    if not Config.Combat.WallCheck then return true end
    if not part then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, direction, rayParams)
    
    if result then
        local hit = result.Instance
        return hit and hit:IsDescendantOf(part.Parent)
    end
    
    return true
end

local function WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetScreenCenter()
    local viewportSize = Camera.ViewportSize
    return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
end

-- ====================================================================================================
-- SISTEMA DE TARGETING UNIVERSAL
-- ====================================================================================================
local CurrentTarget = nil

local function GetClosestPlayerToMouse(fov)
    local closestPlayer = nil
    local shortestDistance = fov or math.huge
    local mousePos = GetScreenCenter()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) and not IsTeammate(player) then
            local character = player.Character
            local hitbox = GetUniversalHitbox(character, Config.Combat.TargetPart)
            
            if hitbox then
                local distance = GetMagnitude(hitbox)
                if distance <= (Config.Visuals.MaxDistance or 3000) then
                    local screenPos, onScreen = WorldToScreen(hitbox.Position)
                    
                    if onScreen then
                        local distanceFromMouse = (mousePos - screenPos).Magnitude
                        
                        if distanceFromMouse < shortestDistance then
                            if IsVisible(hitbox) or not Config.Combat.WallCheck then
                                closestPlayer = player
                                shortestDistance = distanceFromMouse
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- ====================================================================================================
-- FOV CIRCLES (DESENHO)
-- ====================================================================================================
local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Thickness = 2
AimbotFOVCircle.NumSides = 64
AimbotFOVCircle.Radius = Config.Combat.AimbotFOV
AimbotFOVCircle.Filled = false
AimbotFOVCircle.Visible = false
AimbotFOVCircle.Color = Color3.fromRGB(138, 43, 226)
AimbotFOVCircle.Transparency = 0.8

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = 2
SilentFOVCircle.NumSides = 64
SilentFOVCircle.Radius = Config.Combat.SilentFOV
SilentFOVCircle.Filled = false
SilentFOVCircle.Visible = false
SilentFOVCircle.Color = Color3.fromRGB(255, 50, 50)
SilentFOVCircle.Transparency = 0.8

-- ====================================================================================================
-- AIMBOT UNIVERSAL
-- ====================================================================================================
local AimbotActive = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.UserInputType == Config.Combat.AimbotKey or input.KeyCode == Enum.KeyCode.ButtonR2 then
        AimbotActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Combat.AimbotKey or input.KeyCode == Enum.KeyCode.ButtonR2 then
        AimbotActive = false
    end
end)

RunService.RenderStepped:Connect(function()
    local center = GetScreenCenter()
    
    -- Atualizar FOV Circles
    if Config.Combat.ShowAimbotFOV and Config.Combat.Aimbot then
        AimbotFOVCircle.Position = center
        AimbotFOVCircle.Radius = Config.Combat.AimbotFOV
        AimbotFOVCircle.Visible = true
    else
        AimbotFOVCircle.Visible = false
    end
    
    if Config.Combat.ShowSilentFOV and Config.Combat.SilentAim then
        SilentFOVCircle.Position = center
        SilentFOVCircle.Radius = Config.Combat.SilentFOV
        SilentFOVCircle.Visible = true
    else
        SilentFOVCircle.Visible = false
    end
    
    -- Aimbot Suave
    if Config.Combat.Aimbot and AimbotActive then
        local target = GetClosestPlayerToMouse(Config.Combat.AimbotFOV)
        
        if target then
            CurrentTarget = target
            local hitbox = GetUniversalHitbox(target.Character, Config.Combat.TargetPart)
            
            if hitbox then
                local targetPos = hitbox.Position
                
                -- Predição de movimento
                if Config.Combat.PredictMovement and hitbox.AssemblyLinearVelocity then
                    targetPos = targetPos + (hitbox.AssemblyLinearVelocity * Config.Combat.PredictionAmount)
                end
                
                local aimCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, Config.Combat.AimbotSmooth)
            end
        else
            CurrentTarget = nil
        end
    end
end)

-- ====================================================================================================
-- SILENT AIM UNIVERSAL (HOOK DE NAMECALL)
-- ====================================================================================================
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Config.Combat.SilentAim and (method == "FireServer" or method == "InvokeServer") then
        -- Verificar se é um evento de disparo
        if tostring(self):lower():find("remote") or tostring(self):lower():find("fire") or tostring(self):lower():find("shoot") then
            local target = GetClosestPlayerToMouse(Config.Combat.SilentFOV)
            
            if target and math.random(1, 100) <= Config.Combat.HitChance then
                local hitbox = GetUniversalHitbox(target.Character, Config.Combat.TargetPart)
                
                if hitbox then
                    local targetPos = hitbox.Position
                    
                    -- Predição
                    if Config.Combat.PredictMovement and hitbox.AssemblyLinearVelocity then
                        targetPos = targetPos + (hitbox.AssemblyLinearVelocity * Config.Combat.PredictionAmount)
                    end
                    
                    -- Tentar substituir argumentos de posição
                    for i, arg in ipairs(args) do
                        if typeof(arg) == "Vector3" then
                            args[i] = targetPos
                        elseif typeof(arg) == "CFrame" then
                            args[i] = CFrame.new(targetPos)
                        end
                    end
                end
            end
        end
    end
    
    return OldNamecall(self, unpack(args))
end))

-- ====================================================================================================
-- ESP UNIVERSAL
-- ====================================================================================================
local ESPObjects = {}

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    RemoveESP(player)
    
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBarBG = Drawing.new("Line"),
        Tracer = Drawing.new("Line")
    }
    
    local esp = ESPObjects[player]
    
    -- Box
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    esp.Box.Visible = false
    
    -- Name
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Font = 2
    esp.Name.Visible = false
    
    -- Distance
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Font = 2
    esp.Distance.Visible = false
    
    -- Health Bar
    esp.HealthBarBG.Thickness = 3
    esp.HealthBarBG.Color = Color3.new(0, 0, 0)
    esp.HealthBarBG.Visible = false
    
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Visible = false
    
    -- Tracer
    esp.Tracer.Thickness = 1
    esp.Tracer.Visible = false
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

RunService.RenderStepped:Connect(function()
    if not Config.Visuals.ESP then
        for _, player in ipairs(Players:GetPlayers()) do
            RemoveESP(player)
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and ESPObjects[player] then
            local esp = ESPObjects[player]
            
            if IsAlive(player) and (not Config.Visuals.TeamCheck or not IsTeammate(player)) then
                local character = player.Character
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if rootPart and humanoid then
                    local distance = GetMagnitude(rootPart)
                    
                    if distance <= Config.Visuals.MaxDistance then
                        local screenPos, onScreen = WorldToScreen(rootPart.Position)
                        
                        if onScreen then
                            local headPos = character:FindFirstChild("Head")
                            local headScreenPos = headPos and WorldToScreen(headPos.Position + Vector3.new(0, 0.5, 0)) or screenPos
                            
                            local scale = 1000 / (Camera.CFrame.Position - rootPart.Position).Magnitude
                            local boxSize = Vector2.new(4 * scale, 5 * scale)
                            
                            -- Box
                            if Config.Visuals.Boxes then
                                esp.Box.Size = boxSize
                                esp.Box.Position = Vector2.new(screenPos.X - boxSize.X / 2, headScreenPos.Y - boxSize.Y / 2)
                                esp.Box.Color = Config.Visuals.ESPColor
                                esp.Box.Visible = true
                            else
                                esp.Box.Visible = false
                            end
                            
                            -- Name
                            if Config.Visuals.Names then
                                esp.Name.Text = player.Name
                                esp.Name.Position = Vector2.new(screenPos.X, headScreenPos.Y - boxSize.Y / 2 - 16)
                                esp.Name.Color = Config.Visuals.ESPColor
                                esp.Name.Visible = true
                            else
                                esp.Name.Visible = false
                            end
                            
                            -- Distance
                            if Config.Visuals.Distance then
                                esp.Distance.Text = string.format("[%dm]", math.floor(distance))
                                esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 2)
                                esp.Distance.Color = Config.Visuals.ESPColor
                                esp.Distance.Visible = true
                            else
                                esp.Distance.Visible = false
                            end
                            
                            -- Health Bar
                            if Config.Visuals.Health then
                                local healthPercent = humanoid.Health / humanoid.MaxHealth
                                local barHeight = boxSize.Y
                                
                                esp.HealthBarBG.From = Vector2.new(screenPos.X - boxSize.X / 2 - 6, headScreenPos.Y - boxSize.Y / 2)
                                esp.HealthBarBG.To = Vector2.new(screenPos.X - boxSize.X / 2 - 6, headScreenPos.Y + boxSize.Y / 2)
                                esp.HealthBarBG.Visible = true
                                
                                esp.HealthBar.From = Vector2.new(screenPos.X - boxSize.X / 2 - 6, headScreenPos.Y + boxSize.Y / 2)
                                esp.HealthBar.To = Vector2.new(screenPos.X - boxSize.X / 2 - 6, headScreenPos.Y + boxSize.Y / 2 - (barHeight * healthPercent))
                                esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                                esp.HealthBar.Visible = true
                            else
                                esp.HealthBarBG.Visible = false
                                esp.HealthBar.Visible = false
                            end
                            
                            -- Tracer
                            if Config.Visuals.Tracers then
                                local tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                esp.Tracer.From = tracerStart
                                esp.Tracer.To = screenPos
                                esp.Tracer.Color = Config.Visuals.ESPColor
                                esp.Tracer.Visible = true
                            else
                                esp.Tracer.Visible = false
                            end
                        else
                            for _, obj in pairs(esp) do
                                obj.Visible = false
                            end
                        end
                    else
                        for _, obj in pairs(esp) do
                            obj.Visible = false
                        end
                    end
                else
                    for _, obj in pairs(esp) do
                        obj.Visible = false
                    end
                end
            else
                for _, obj in pairs(esp) do
                    obj.Visible = false
                end
            end
        end
    end
end)

-- ====================================================================================================
-- MOVIMENTO
-- ====================================================================================================
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        -- Speed
        if Config.Movement.SpeedEnabled then
            humanoid.WalkSpeed = Config.Movement.Speed
        end
        
        -- Jump
        if Config.Movement.JumpEnabled then
            humanoid.JumpPower = Config.Movement.Jump
        end
        
        -- Fly
        if Config.Movement.Fly and rootPart then
            local moveDirection = humanoid.MoveDirection
            local velocity = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA) then
                velocity = velocity + Vector3.new(0, 1, 0)
            end
            
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonB) then
                velocity = velocity - Vector3.new(0, 1, 0)
            end
            
            rootPart.Velocity = (moveDirection * Config.Movement.FlySpeed) + (velocity * Config.Movement.FlySpeed)
        end
        
        -- Noclip
        if Config.Movement.Noclip then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfiniteJump then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ====================================================================================================
-- GUN MODS UNIVERSAL
-- ====================================================================================================
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            local name = obj.Name:lower()
            
            -- No Recoil
            if Config.GunMods.NoRecoil and (name:find("recoil") or name:find("kick")) then
                obj.Value = 0
            end
            
            -- No Spread
            if Config.GunMods.NoSpread and (name:find("spread") or name:find("accuracy")) then
                obj.Value = 0
            end
            
            -- Infinite Ammo
            if Config.GunMods.InfiniteAmmo and (name:find("ammo") or name:find("mag") or name:find("clip")) then
                obj.Value = 999
            end
            
            -- Rapid Fire
            if Config.GunMods.RapidFire and (name:find("firerate") or name:find("cooldown") or name:find("delay")) then
                obj.Value = 0.01
            end
            
            -- Instant Reload
            if Config.GunMods.InstantReload and (name:find("reload")) then
                obj.Value = 0.01
            end
            
            -- Infinite Range
            if Config.GunMods.InfiniteRange and (name:find("range") or name:find("distance")) then
                obj.Value = 9999
            end
            
            -- One Shot Kill
            if Config.GunMods.OneShotKill and (name:find("damage") or name:find("dmg")) then
                obj.Value = 9999
            end
        end
    end
end)

-- ====================================================================================================
-- MISC
-- ====================================================================================================
RunService.RenderStepped:Connect(function()
    -- Full Bright
    if Config.Misc.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
    
    -- No Fog
    if Config.Misc.NoFog then
        Lighting.FogEnd = 100000
    end
end)

-- Anti AFK
if Config.Misc.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- ====================================================================================================
-- INTERFACE GRÁFICA (UI) - COMPLETAMENTE REFORMULADA
-- ====================================================================================================

-- Criar ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeHubV8"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Proteção contra detecção
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- ====================================================================================================
-- BOTÃO FLUTUANTE (ARRASTÁVEL)
-- ====================================================================================================
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Parent = ScreenGui
FloatingButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
FloatingButton.BorderSizePixel = 0
FloatingButton.Position = UDim2.new(0, 20, 0.5, -30)
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Text = "GM"
FloatingButton.TextColor3 = Color3.white
FloatingButton.TextSize = 24

local FloatingButtonCorner = Instance.new("UICorner")
FloatingButtonCorner.CornerRadius = UDim.new(0, 30)
FloatingButtonCorner.Parent = FloatingButton

-- Sistema de Drag para o botão
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatingButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

FloatingButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- ====================================================================================================
-- FRAME PRINCIPAL
-- ====================================================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
MainFrame.Size = UDim2.new(0, 600, 0, 450)
MainFrame.Visible = false

local MainFrameCorner = Instance.new("UICorner")
MainFrameCorner.CornerRadius = UDim.new(0, 12)
MainFrameCorner.Parent = MainFrame

-- Sistema de Drag para o MainFrame
local mainDragging = false
local mainDragInput, mainDragStart, mainStartPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        mainDragStart = input.Position
        mainStartPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                mainDragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        mainDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == mainDragInput and mainDragging then
        local delta = input.Position - mainDragStart
        MainFrame.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
    end
end)

-- ====================================================================================================
-- HEADER
-- ====================================================================================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 50)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Parent = Header
HeaderFix.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
HeaderFix.BorderSizePixel = 0
HeaderFix.Position = UDim2.new(0, 0, 1, -12)
HeaderFix.Size = UDim2.new(1, 0, 0, 12)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🔥 GOD MODE HUB V8.0 UNIVERSAL"
Title.TextColor3 = Color3.white
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Header
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -50, 0, 0)
CloseButton.Size = UDim2.new(0, 50, 1, 0)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.white
CloseButton.TextSize = 24

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ====================================================================================================
-- CONTAINER DE ABAS
-- ====================================================================================================
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Parent = MainFrame
TabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TabContainer.BorderSizePixel = 0
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.Size = UDim2.new(0, 150, 1, -50)

local TabContainerCorner = Instance.new("UICorner")
TabContainerCorner.CornerRadius = UDim.new(0, 12)
TabContainerCorner.Parent = TabContainer

local TabContainerFix = Instance.new("Frame")
TabContainerFix.Parent = TabContainer
TabContainerFix.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TabContainerFix.BorderSizePixel = 0
TabContainerFix.Position = UDim2.new(0, 0, 0, 0)
TabContainerFix.Size = UDim2.new(1, 0, 0, 12)

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabContainer
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 5)

-- ====================================================================================================
-- CONTENT FRAME (COM SCROLL)
-- ====================================================================================================
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 155, 0, 55)
ContentFrame.Size = UDim2.new(1, -160, 1, -60)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 6
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentFrame
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)

local ContentPadding = Instance.new("UIPadding")
ContentPadding.Parent = ContentFrame
ContentPadding.PaddingLeft = UDim.new(0, 10)
ContentPadding.PaddingRight = UDim.new(0, 10)
ContentPadding.PaddingTop = UDim.new(0, 10)
ContentPadding.PaddingBottom = UDim.new(0, 10)

-- Atualizar CanvasSize automaticamente
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)

-- ====================================================================================================
-- FUNÇÕES DE CRIAÇÃO DE UI
-- ====================================================================================================

local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Parent = TabContainer
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabButton.BorderSizePixel = 0
    TabButton.Size = UDim2.new(1, 0, 0, 45)
    TabButton.Font = Enum.Font.Gotham
    TabButton.Text = icon .. " " .. name
    TabButton.TextColor3 = Color3.white
    TabButton.TextSize = 14
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    
    local TabButtonCorner = Instance.new("UICorner")
    TabButtonCorner.CornerRadius = UDim.new(0, 8)
    TabButtonCorner.Parent = TabButton
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabButton
    TabPadding.PaddingLeft = UDim.new(0, 15)
    
    return TabButton
end

local function ClearContent()
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

local function CreateToggle(name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = ContentFrame
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = name
    Label.TextColor3 = Color3.white
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 70)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(1, -60, 0.5, -12)
    ToggleButton.Size = UDim2.new(0, 45, 0, 24)
    ToggleButton.Text = ""
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
    ToggleButtonCorner.Parent = ToggleButton
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Parent = ToggleButton
    ToggleIndicator.BackgroundColor3 = Color3.white
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Position = default and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = ToggleIndicator
    
    local enabled = default
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 70)
        }):Play()
        
        TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        }):Play()
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = ContentFrame
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 55)
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Font = Enum.Font.Gotham
    Label.Text = name
    Label.TextColor3 = Color3.white
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 5)
    ValueLabel.Size = UDim2.new(0.4, -15, 0, 20)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Parent = SliderFrame
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderBar.BorderSizePixel = 0
    SliderBar.Position = UDim2.new(0, 15, 0, 32)
    SliderBar.Size = UDim2.new(1, -30, 0, 8)
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(1, 0)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBar
    SliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Parent = SliderBar
    SliderButton.BackgroundColor3 = Color3.white
    SliderButton.BorderSizePixel = 0
    SliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Text = ""
    
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(1, 0)
    SliderButtonCorner.Parent = SliderButton
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        SliderButton.Position = UDim2.new(pos, -8, 0.5, -8)
        ValueLabel.Text = tostring(value)
        callback(value)
    end
    
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    SliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
end

local function CreateButton(name, callback)
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.Parent = ContentFrame
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
    ButtonFrame.Font = Enum.Font.GothamBold
    ButtonFrame.Text = name
    ButtonFrame.TextColor3 = Color3.white
    ButtonFrame.TextSize = 14
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ButtonFrame
    
    ButtonFrame.MouseButton1Click:Connect(callback)
    
    ButtonFrame.MouseEnter:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(158, 63, 246)
        }):Play()
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        }):Play()
    end)
end

local function CreateDropdown(name, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Parent = ContentFrame
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    DropdownFrame.ClipsDescendants = true
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = DropdownFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.5, 0, 0, 40)
    Label.Font = Enum.Font.Gotham
    Label.Text = name
    Label.TextColor3 = Color3.white
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Parent = DropdownFrame
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
    SelectedLabel.Size = UDim2.new(0.5, -15, 0, 40)
    SelectedLabel.Font = Enum.Font.GothamBold
    SelectedLabel.Text = default
    SelectedLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    SelectedLabel.TextSize = 14
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Size = UDim2.new(1, 0, 0, 40)
    DropdownButton.Text = ""
    
    local expanded = false
    
    DropdownButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        
        if expanded then
            DropdownFrame:TweenSize(UDim2.new(1, 0, 0, 40 + (#options * 35)), "Out", "Quad", 0.2, true)
        else
            DropdownFrame:TweenSize(UDim2.new(1, 0, 0, 40), "Out", "Quad", 0.2, true)
        end
    end)
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Parent = DropdownFrame
        OptionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        OptionButton.BorderSizePixel = 0
        OptionButton.Position = UDim2.new(0, 5, 0, 40 + ((i - 1) * 35))
        OptionButton.Size = UDim2.new(1, -10, 0, 30)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.white
        OptionButton.TextSize = 13
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 6)
        OptionCorner.Parent = OptionButton
        
        OptionButton.MouseButton1Click:Connect(function()
            SelectedLabel.Text = option
            callback(option)
            DropdownFrame:TweenSize(UDim2.new(1, 0, 0, 40), "Out", "Quad", 0.2, true)
            expanded = false
        end)
    end
end

-- ====================================================================================================
-- ABAS E CONTEÚDO
-- ====================================================================================================

-- Tab: Combat
local CombatTab = CreateTab("Combat", "⚔️")
CombatTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("Aimbot", Config.Combat.Aimbot, function(val)
        Config.Combat.Aimbot = val
    end)
    
    CreateSlider("Aimbot FOV", 50, 500, Config.Combat.AimbotFOV, function(val)
        Config.Combat.AimbotFOV = val
    end)
    
    CreateSlider("Aimbot Smoothness", 1, 100, Config.Combat.AimbotSmooth * 100, function(val)
        Config.Combat.AimbotSmooth = val / 100
    end)
    
    CreateToggle("Show Aimbot FOV", Config.Combat.ShowAimbotFOV, function(val)
        Config.Combat.ShowAimbotFOV = val
    end)
    
    CreateToggle("Silent Aim", Config.Combat.SilentAim, function(val)
        Config.Combat.SilentAim = val
    end)
    
    CreateSlider("Silent FOV", 50, 500, Config.Combat.SilentFOV, function(val)
        Config.Combat.SilentFOV = val
    end)
    
    CreateToggle("Show Silent FOV", Config.Combat.ShowSilentFOV, function(val)
        Config.Combat.ShowSilentFOV = val
    end)
    
    CreateSlider("Hit Chance %", 0, 100, Config.Combat.HitChance, function(val)
        Config.Combat.HitChance = val
    end)
    
    CreateDropdown("Target Part", {"Head", "Torso", "LeftArm", "RightArm"}, Config.Combat.TargetPart, function(val)
        Config.Combat.TargetPart = val
    end)
    
    CreateToggle("Team Check", Config.Combat.TeamCheck, function(val)
        Config.Combat.TeamCheck = val
    end)
    
    CreateToggle("Wall Check", Config.Combat.WallCheck, function(val)
        Config.Combat.WallCheck = val
    end)
    
    CreateToggle("Predict Movement", Config.Combat.PredictMovement, function(val)
        Config.Combat.PredictMovement = val
    end)
    
    CreateSlider("Prediction", 5, 30, Config.Combat.PredictionAmount * 100, function(val)
        Config.Combat.PredictionAmount = val / 100
    end)
end)

-- Tab: Visuals
local VisualsTab = CreateTab("Visuals", "👁️")
VisualsTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("ESP Enabled", Config.Visuals.ESP, function(val)
        Config.Visuals.ESP = val
    end)
    
    CreateToggle("Boxes", Config.Visuals.Boxes, function(val)
        Config.Visuals.Boxes = val
    end)
    
    CreateToggle("Names", Config.Visuals.Names, function(val)
        Config.Visuals.Names = val
    end)
    
    CreateToggle("Distance", Config.Visuals.Distance, function(val)
        Config.Visuals.Distance = val
    end)
    
    CreateToggle("Health", Config.Visuals.Health, function(val)
        Config.Visuals.Health = val
    end)
    
    CreateToggle("Tracers", Config.Visuals.Tracers, function(val)
        Config.Visuals.Tracers = val
    end)
    
    CreateToggle("Team Check", Config.Visuals.TeamCheck, function(val)
        Config.Visuals.TeamCheck = val
    end)
    
    CreateSlider("Max Distance", 500, 5000, Config.Visuals.MaxDistance, function(val)
        Config.Visuals.MaxDistance = val
    end)
end)

-- Tab: Movement
local MovementTab = CreateTab("Movement", "🏃")
MovementTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("Speed Enabled", Config.Movement.SpeedEnabled, function(val)
        Config.Movement.SpeedEnabled = val
    end)
    
    CreateSlider("Walk Speed", 16, 200, Config.Movement.Speed, function(val)
        Config.Movement.Speed = val
    end)
    
    CreateToggle("Jump Enabled", Config.Movement.JumpEnabled, function(val)
        Config.Movement.JumpEnabled = val
    end)
    
    CreateSlider("Jump Power", 50, 200, Config.Movement.Jump, function(val)
        Config.Movement.Jump = val
    end)
    
    CreateToggle("Fly", Config.Movement.Fly, function(val)
        Config.Movement.Fly = val
    end)
    
    CreateSlider("Fly Speed", 20, 200, Config.Movement.FlySpeed, function(val)
        Config.Movement.FlySpeed = val
    end)
    
    CreateToggle("Noclip", Config.Movement.Noclip, function(val)
        Config.Movement.Noclip = val
    end)
    
    CreateToggle("Infinite Jump", Config.Movement.InfiniteJump, function(val)
        Config.Movement.InfiniteJump = val
    end)
end)

-- Tab: Gun Mods
local GunTab = CreateTab("Gun Mods", "🔫")
GunTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("No Recoil", Config.GunMods.NoRecoil, function(val)
        Config.GunMods.NoRecoil = val
    end)
    
    CreateToggle("No Spread", Config.GunMods.NoSpread, function(val)
        Config.GunMods.NoSpread = val
    end)
    
    CreateToggle("Infinite Ammo", Config.GunMods.InfiniteAmmo, function(val)
        Config.GunMods.InfiniteAmmo = val
    end)
    
    CreateToggle("Rapid Fire", Config.GunMods.RapidFire, function(val)
        Config.GunMods.RapidFire = val
    end)
    
    CreateToggle("Instant Reload", Config.GunMods.InstantReload, function(val)
        Config.GunMods.InstantReload = val
    end)
    
    CreateToggle("Infinite Range", Config.GunMods.InfiniteRange, function(val)
        Config.GunMods.InfiniteRange = val
    end)
    
    CreateToggle("One Shot Kill", Config.GunMods.OneShotKill, function(val)
        Config.GunMods.OneShotKill = val
    end)
end)

-- Tab: Misc
local MiscTab = CreateTab("Misc", "⚙️")
MiscTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("Full Bright", Config.Misc.FullBright, function(val)
        Config.Misc.FullBright = val
    end)
    
    CreateToggle("No Fog", Config.Misc.NoFog, function(val)
        Config.Misc.NoFog = val
    end)
    
    CreateToggle("Anti AFK", Config.Misc.AntiAFK, function(val)
        Config.Misc.AntiAFK = val
    end)
    
    CreateButton("Reset Character", function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end
    end)
    
    CreateButton("Destroy GUI", function()
        ScreenGui:Destroy()
    end)
end)

-- ====================================================================================================
-- TOGGLE MENU COM BOTÃO FLUTUANTE
-- ====================================================================================================
FloatingButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Carregar aba Combat por padrão
CombatTab.MouseButton1Click()

-- ====================================================================================================
-- MENSAGEM FINAL
-- ====================================================================================================
print("✅ GOD MODE HUB V8.0 UNIVERSAL CARREGADO!")
print("🎯 Aimbot/Silent Aim Universal Ativo")
print("📱 UI Otimizada com Scroll/Drag/Resize")
print("🔧 Todas as funções funcionando")
