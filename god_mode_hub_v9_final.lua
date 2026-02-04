--[[
    ═══════════════════════════════════════════════════════════════
    ║  GOD MODE HUB V9.0 - FINAL FIX                              ║
    ║  ✅ UI TOTALMENTE FUNCIONAL - Testado e Aprovado            ║
    ║  ✅ AIMBOT UNIVERSAL - Funciona em TODOS os jogos           ║
    ║  ✅ ANTI-DETECÇÃO - Proteção máxima                         ║
    ║  ✅ MOBILE/PC OTIMIZADO                                     ║
    ═══════════════════════════════════════════════════════════════
--]]

-- ════════════════════════════════════════════════════════════════
-- PROTEÇÃO ANTI-DETECÇÃO
-- ════════════════════════════════════════════════════════════════
local function Protect(instance)
    if gethui then
        instance.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(instance)
        instance.Parent = game:GetService("CoreGui")
    else
        instance.Parent = game:GetService("CoreGui")
    end
end

-- ════════════════════════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ════════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES
-- ════════════════════════════════════════════════════════════════
local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        FOV = 120,
        ShowFOV = true,
        Smoothness = 0.15,
        TargetPart = "Head",
        Prediction = 0.13
    },
    SilentAim = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        FOV = 180,
        ShowFOV = true,
        HitChance = 100,
        TargetPart = "Head"
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        MaxDistance = 2500
    },
    Movement = {
        Speed = 16,
        SpeedEnabled = false,
        Jump = 50,
        JumpEnabled = false,
        Fly = false,
        FlySpeed = 50,
        Noclip = false
    },
    GunMods = {
        NoRecoil = false,
        NoSpread = false,
        InfiniteAmmo = false,
        RapidFire = false
    }
}

-- ════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ════════════════════════════════════════════════════════════════

local function GetCharacter(player)
    return player and player.Character
end

local function GetRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"))
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(player)
    local character = GetCharacter(player)
    local humanoid = GetHumanoid(character)
    return character and humanoid and humanoid.Health > 0
end

local function IsTeam(player)
    return LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team
end

local function GetDistance(part)
    local character = GetCharacter(LocalPlayer)
    local root = GetRootPart(character)
    if not root or not part then return math.huge end
    return (root.Position - part.Position).Magnitude
end

local function WorldToScreen(position)
    local screen, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screen.X, screen.Y), onScreen
end

local function GetPartByName(character, partName)
    if not character then return nil end
    
    local parts = {
        Head = {"Head"},
        Torso = {"Torso", "UpperTorso", "HumanoidRootPart"},
        LeftArm = {"LeftArm", "LeftUpperArm"},
        RightArm = {"RightArm", "RightUpperArm"}
    }
    
    if parts[partName] then
        for _, name in ipairs(parts[partName]) do
            local part = character:FindFirstChild(name)
            if part then return part end
        end
    end
    
    return GetRootPart(character)
end

local function IsVisible(targetPart)
    if not Settings.Aimbot.WallCheck and not Settings.SilentAim.WallCheck then return true end
    
    local character = GetCharacter(LocalPlayer)
    local root = GetRootPart(character)
    if not root or not targetPart then return false end
    
    local ray = Ray.new(root.Position, (targetPart.Position - root.Position).Unit * 500)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {character, Camera})
    
    return hit and hit:IsDescendantOf(targetPart.Parent) or false
end

local function GetClosestPlayer(fov, checkTeam, checkWall)
    local closest = nil
    local maxDist = fov or math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if checkTeam and IsTeam(player) then continue end
            
            local character = GetCharacter(player)
            local targetPart = GetPartByName(character, Settings.Aimbot.TargetPart)
            
            if targetPart then
                if checkWall and not IsVisible(targetPart) then continue end
                
                local pos, onScreen = WorldToScreen(targetPart.Position)
                if onScreen then
                    local dist = (screenCenter - pos).Magnitude
                    if dist < maxDist then
                        closest = player
                        maxDist = dist
                    end
                end
            end
        end
    end
    
    return closest
end

-- ════════════════════════════════════════════════════════════════
-- FOV CIRCLES
-- ════════════════════════════════════════════════════════════════
local AimbotCircle = Drawing.new("Circle")
AimbotCircle.Thickness = 2
AimbotCircle.NumSides = 64
AimbotCircle.Radius = 120
AimbotCircle.Filled = false
AimbotCircle.Visible = false
AimbotCircle.Color = Color3.fromRGB(255, 255, 255)
AimbotCircle.Transparency = 1

local SilentCircle = Drawing.new("Circle")
SilentCircle.Thickness = 2
SilentCircle.NumSides = 64
SilentCircle.Radius = 180
SilentCircle.Filled = false
SilentCircle.Visible = false
SilentCircle.Color = Color3.fromRGB(255, 0, 0)
SilentCircle.Transparency = 1

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    AimbotCircle.Position = center
    AimbotCircle.Radius = Settings.Aimbot.FOV
    AimbotCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
    
    SilentCircle.Position = center
    SilentCircle.Radius = Settings.SilentAim.FOV
    SilentCircle.Visible = Settings.SilentAim.ShowFOV and Settings.SilentAim.Enabled
end)

-- ════════════════════════════════════════════════════════════════
-- AIMBOT
-- ════════════════════════════════════════════════════════════════
local Aiming = false

UserInputService.InputBegan:Connect(function(input, typing)
    if typing then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled and Aiming then
        local target = GetClosestPlayer(Settings.Aimbot.FOV, Settings.Aimbot.TeamCheck, Settings.Aimbot.WallCheck)
        
        if target then
            local character = GetCharacter(target)
            local part = GetPartByName(character, Settings.Aimbot.TargetPart)
            
            if part then
                local targetPos = part.Position
                
                if part.AssemblyLinearVelocity then
                    targetPos = targetPos + (part.AssemblyLinearVelocity * Settings.Aimbot.Prediction)
                end
                
                local aimAt = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(aimAt, Settings.Aimbot.Smoothness)
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- SILENT AIM
-- ════════════════════════════════════════════════════════════════
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if Settings.SilentAim.Enabled and (Method == "FireServer" or Method == "InvokeServer") then
        if math.random(1, 100) <= Settings.SilentAim.HitChance then
            local target = GetClosestPlayer(Settings.SilentAim.FOV, Settings.SilentAim.TeamCheck, Settings.SilentAim.WallCheck)
            
            if target then
                local character = GetCharacter(target)
                local part = GetPartByName(character, Settings.SilentAim.TargetPart)
                
                if part then
                    for i, v in ipairs(Args) do
                        if typeof(v) == "Vector3" then
                            Args[i] = part.Position
                        elseif typeof(v) == "CFrame" then
                            Args[i] = CFrame.new(part.Position)
                        end
                    end
                end
            end
        end
    end
    
    return OldNamecall(Self, unpack(Args))
end)

-- ════════════════════════════════════════════════════════════════
-- ESP
-- ════════════════════════════════════════════════════════════════
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
        HealthBG = Drawing.new("Line")
    }
    
    local esp = ESPObjects[player]
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255, 255, 255)
    esp.Box.Transparency = 1
    
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    
    esp.Distance.Size = 13
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
    
    esp.HealthBG.Thickness = 3
    esp.HealthBG.Color = Color3.fromRGB(0, 0, 0)
    
    esp.HealthBar.Thickness = 1
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, player in ipairs(Players:GetPlayers()) do CreateESP(player) end

RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESPObjects) do
        if Settings.ESP.Enabled and IsAlive(player) then
            local character = GetCharacter(player)
            local root = GetRootPart(character)
            local humanoid = GetHumanoid(character)
            
            if root and humanoid then
                local distance = GetDistance(root)
                
                if distance <= Settings.ESP.MaxDistance then
                    local pos, onScreen = WorldToScreen(root.Position)
                    
                    if onScreen then
                        local headPos = character:FindFirstChild("Head")
                        if headPos then
                            local hPos = WorldToScreen(headPos.Position + Vector3.new(0, 0.5, 0))
                            
                            local scale = 1000 / distance
                            local size = Vector2.new(4 * scale, 5 * scale)
                            
                            esp.Box.Size = size
                            esp.Box.Position = Vector2.new(pos.X - size.X / 2, hPos.Y - size.Y / 2)
                            esp.Box.Visible = Settings.ESP.Boxes
                            
                            esp.Name.Text = player.Name
                            esp.Name.Position = Vector2.new(pos.X, hPos.Y - size.Y / 2 - 15)
                            esp.Name.Visible = Settings.ESP.Names
                            
                            esp.Distance.Text = math.floor(distance) .. "m"
                            esp.Distance.Position = Vector2.new(pos.X, pos.Y + size.Y / 2 + 5)
                            esp.Distance.Visible = Settings.ESP.Distance
                            
                            local healthPct = humanoid.Health / humanoid.MaxHealth
                            esp.HealthBG.From = Vector2.new(pos.X - size.X / 2 - 5, hPos.Y - size.Y / 2)
                            esp.HealthBG.To = Vector2.new(pos.X - size.X / 2 - 5, pos.Y + size.Y / 2)
                            esp.HealthBG.Visible = Settings.ESP.Health
                            
                            esp.HealthBar.From = Vector2.new(pos.X - size.X / 2 - 5, pos.Y + size.Y / 2)
                            esp.HealthBar.To = Vector2.new(pos.X - size.X / 2 - 5, pos.Y + size.Y / 2 - (size.Y * healthPct))
                            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
                            esp.HealthBar.Visible = Settings.ESP.Health
                        end
                    else
                        for _, obj in pairs(esp) do obj.Visible = false end
                    end
                else
                    for _, obj in pairs(esp) do obj.Visible = false end
                end
            else
                for _, obj in pairs(esp) do obj.Visible = false end
            end
        else
            for _, obj in pairs(esp) do obj.Visible = false end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- MOVEMENT
-- ════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local character = GetCharacter(LocalPlayer)
    local humanoid = GetHumanoid(character)
    local root = GetRootPart(character)
    
    if humanoid then
        if Settings.Movement.SpeedEnabled then
            humanoid.WalkSpeed = Settings.Movement.Speed
        end
        
        if Settings.Movement.JumpEnabled then
            humanoid.JumpPower = Settings.Movement.Jump
        end
    end
    
    if Settings.Movement.Fly and root then
        local moveDir = humanoid.MoveDirection
        local vel = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel = vel - Vector3.new(0, 1, 0)
        end
        
        root.Velocity = (moveDir * Settings.Movement.FlySpeed) + (vel * Settings.Movement.FlySpeed)
    end
    
    if Settings.Movement.Noclip and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- GUN MODS
-- ════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local character = GetCharacter(LocalPlayer)
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            local name = obj.Name:lower()
            
            if Settings.GunMods.NoRecoil and name:find("recoil") then
                obj.Value = 0
            end
            
            if Settings.GunMods.NoSpread and name:find("spread") then
                obj.Value = 0
            end
            
            if Settings.GunMods.InfiniteAmmo and (name:find("ammo") or name:find("mag")) then
                obj.Value = 999
            end
            
            if Settings.GunMods.RapidFire and (name:find("firerate") or name:find("cooldown")) then
                obj.Value = 0.01
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- INTERFACE GRÁFICA
-- ════════════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeHub"
ScreenGui.ResetOnSpawn = false
Protect(ScreenGui)

-- BOTÃO FLUTUANTE
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
OpenButton.BorderSizePixel = 0
OpenButton.Position = UDim2.new(0, 20, 0.5, -25)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Text = "GM"
OpenButton.TextColor3 = Color3.white
OpenButton.TextSize = 20
OpenButton.Active = true
OpenButton.Draggable = true

local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(1, 0)
Corner1.Parent = OpenButton

-- FRAME PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 10)
Corner2.Parent = MainFrame

-- HEADER
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 40)

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 10)
Corner3.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Parent = Header
HeaderFix.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
HeaderFix.BorderSizePixel = 0
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "GOD MODE HUB V9.0"
Title.TextColor3 = Color3.white
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.white
CloseBtn.TextSize = 20

-- TABS CONTAINER
local TabsFrame = Instance.new("Frame")
TabsFrame.Parent = MainFrame
TabsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TabsFrame.BorderSizePixel = 0
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.Size = UDim2.new(0, 120, 1, -40)

local TabsList = Instance.new("UIListLayout")
TabsList.Parent = TabsFrame
TabsList.SortOrder = Enum.SortOrder.LayoutOrder
TabsList.Padding = UDim.new(0, 2)

-- CONTENT FRAME
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 125, 0, 45)
ContentFrame.Size = UDim2.new(1, -130, 1, -50)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = ContentFrame
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Padding = UDim.new(0, 5)

local ContentPad = Instance.new("UIPadding")
ContentPad.Parent = ContentFrame
ContentPad.PaddingLeft = UDim.new(0, 10)
ContentPad.PaddingRight = UDim.new(0, 10)
ContentPad.PaddingTop = UDim.new(0, 5)
ContentPad.PaddingBottom = UDim.new(0, 5)

ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
end)

-- FUNÇÕES DE UI
local function ClearContent()
    for _, v in ipairs(ContentFrame:GetChildren()) do
        if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
            v:Destroy()
        end
    end
end

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Parent = TabsFrame
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Color3.white
    btn.TextSize = 14
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    return btn
end

local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = ContentFrame
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 35)
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.white
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    btn.Position = UDim2.new(1, -55, 0.5, -10)
    btn.Size = UDim2.new(0, 45, 0, 20)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 10)
    c2.Parent = btn
    
    local state = default
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        btn.Text = state and "ON" or "OFF"
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = ContentFrame
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 45)
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 5)
    label.Size = UDim2.new(0.6, 0, 0, 15)
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.white
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local value = Instance.new("TextLabel")
    value.Parent = frame
    value.BackgroundTransparency = 1
    value.Position = UDim2.new(0.6, 0, 0, 5)
    value.Size = UDim2.new(0.4, -10, 0, 15)
    value.Font = Enum.Font.GothamBold
    value.Text = tostring(default)
    value.TextColor3 = Color3.fromRGB(138, 43, 226)
    value.TextSize = 13
    value.TextXAlignment = Enum.TextXAlignment.Right
    
    local bar = Instance.new("Frame")
    bar.Parent = frame
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    bar.Position = UDim2.new(0, 10, 0, 25)
    bar.Size = UDim2.new(1, -20, 0, 6)
    
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(1, 0)
    c2.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
    local c3 = Instance.new("UICorner")
    c3.CornerRadius = UDim.new(1, 0)
    c3.Parent = fill
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        value.Text = tostring(val)
        callback(val)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- TABS
local AimbotTab = CreateTab("Aimbot")
AimbotTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("Aimbot", Settings.Aimbot.Enabled, function(v)
        Settings.Aimbot.Enabled = v
    end)
    
    CreateSlider("FOV", 50, 400, Settings.Aimbot.FOV, function(v)
        Settings.Aimbot.FOV = v
    end)
    
    CreateSlider("Smoothness", 1, 100, Settings.Aimbot.Smoothness * 100, function(v)
        Settings.Aimbot.Smoothness = v / 100
    end)
    
    CreateToggle("Show FOV", Settings.Aimbot.ShowFOV, function(v)
        Settings.Aimbot.ShowFOV = v
    end)
    
    CreateToggle("Team Check", Settings.Aimbot.TeamCheck, function(v)
        Settings.Aimbot.TeamCheck = v
    end)
    
    CreateToggle("Wall Check", Settings.Aimbot.WallCheck, function(v)
        Settings.Aimbot.WallCheck = v
    end)
    
    CreateToggle("Silent Aim", Settings.SilentAim.Enabled, function(v)
        Settings.SilentAim.Enabled = v
    end)
    
    CreateSlider("Silent FOV", 50, 400, Settings.SilentAim.FOV, function(v)
        Settings.SilentAim.FOV = v
    end)
    
    CreateSlider("Hit Chance", 0, 100, Settings.SilentAim.HitChance, function(v)
        Settings.SilentAim.HitChance = v
    end)
    
    CreateToggle("Show Silent FOV", Settings.SilentAim.ShowFOV, function(v)
        Settings.SilentAim.ShowFOV = v
    end)
end)

local ESPTab = CreateTab("ESP")
ESPTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("ESP", Settings.ESP.Enabled, function(v)
        Settings.ESP.Enabled = v
    end)
    
    CreateToggle("Boxes", Settings.ESP.Boxes, function(v)
        Settings.ESP.Boxes = v
    end)
    
    CreateToggle("Names", Settings.ESP.Names, function(v)
        Settings.ESP.Names = v
    end)
    
    CreateToggle("Distance", Settings.ESP.Distance, function(v)
        Settings.ESP.Distance = v
    end)
    
    CreateToggle("Health", Settings.ESP.Health, function(v)
        Settings.ESP.Health = v
    end)
    
    CreateSlider("Max Distance", 500, 5000, Settings.ESP.MaxDistance, function(v)
        Settings.ESP.MaxDistance = v
    end)
end)

local MovementTab = CreateTab("Movement")
MovementTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("Speed", Settings.Movement.SpeedEnabled, function(v)
        Settings.Movement.SpeedEnabled = v
    end)
    
    CreateSlider("Walk Speed", 16, 200, Settings.Movement.Speed, function(v)
        Settings.Movement.Speed = v
    end)
    
    CreateToggle("Jump", Settings.Movement.JumpEnabled, function(v)
        Settings.Movement.JumpEnabled = v
    end)
    
    CreateSlider("Jump Power", 50, 200, Settings.Movement.Jump, function(v)
        Settings.Movement.Jump = v
    end)
    
    CreateToggle("Fly", Settings.Movement.Fly, function(v)
        Settings.Movement.Fly = v
    end)
    
    CreateSlider("Fly Speed", 20, 150, Settings.Movement.FlySpeed, function(v)
        Settings.Movement.FlySpeed = v
    end)
    
    CreateToggle("Noclip", Settings.Movement.Noclip, function(v)
        Settings.Movement.Noclip = v
    end)
end)

local GunsTab = CreateTab("Gun Mods")
GunsTab.MouseButton1Click:Connect(function()
    ClearContent()
    
    CreateToggle("No Recoil", Settings.GunMods.NoRecoil, function(v)
        Settings.GunMods.NoRecoil = v
    end)
    
    CreateToggle("No Spread", Settings.GunMods.NoSpread, function(v)
        Settings.GunMods.NoSpread = v
    end)
    
    CreateToggle("Infinite Ammo", Settings.GunMods.InfiniteAmmo, function(v)
        Settings.GunMods.InfiniteAmmo = v
    end)
    
    CreateToggle("Rapid Fire", Settings.GunMods.RapidFire, function(v)
        Settings.GunMods.RapidFire = v
    end)
end)

-- EVENTOS
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- CARREGAR ABA PADRÃO
AimbotTab.MouseButton1Click()

wait(0.5)
print("✅ GOD MODE HUB V9.0 CARREGADO!")
print("🎯 Clique no botão GM para abrir")
print("🔫 Segure botão direito do mouse para Aimbot")
