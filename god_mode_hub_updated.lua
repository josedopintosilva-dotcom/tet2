--[[
    GOD MODE HUB - MOBILE EDITION v5.1
    Interface Otimizada para Dispositivos Móveis
    Controles Touch-Friendly | Performance Otimizada
    
    CONTROLES MOBILE:
    - Botão flutuante para abrir menu
    - Interface adaptativa para telas pequenas
    - Botões grandes para toque preciso
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ====================================================================================================
-- CONFIGURAÇÃO GLOBAL
-- ====================================================================================================
local GodMode = {
    Combat = {
        Aimbot = false,
        AutoAimbot = false,
        Active = false,
        MagicBullet = false,
        KillAura = false,
        AutoShoot = false, -- Nova função: Auto Shoot
        Smoothness = 0.15,
        FOV = 150,
        ShowFOV = true,
        TargetPart = "Head",
        TeamCheck = false,
        WallCheck = false,
        TouchActivated = false -- Ativação por toque
    },
    Visuals = {
        Boxes = false,
        CornerBoxes = false,
        Skeletons = false,
        Lines = false,
        Names = false,
        HealthBar = false,
        Chams = false,
        TeamCheck = false,
        Color = Color3.fromRGB(0, 255, 150),
        MaxDistance = 1000
    },
    Movement = {
        Bhop = false,
        InfJump = false,
        Noclip = false
    },
    Exploit = {
        TeleportKill = false,
        KillDelay = 0.5
    },
    GunMod = {
        FastFire = false,
        InstantReload = false,
        NoRecoil = false
    },
    Config = {
        PhantomOverlay = false,
        AccentColor = Color3.fromRGB(138, 43, 226),
        MobileMode = true
    }
}

-- ====================================================================================================
-- UTILITÁRIOS DE DESENHO (Otimizado para Mobile)
-- ====================================================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 48 -- Reduzido para melhor performance
FOVCircle.Radius = GodMode.Combat.FOV
FOVCircle.Filled = false
FOVCircle.Visible = GodMode.Combat.ShowFOV
FOVCircle.Color = GodMode.Config.AccentColor

local ESP_Data = {}

local function RemoveESP(player)
    if ESP_Data[player] then
        local data = ESP_Data[player]
        pcall(function()
            data.Box:Remove()
            data.Name:Remove()
            data.Health:Remove()
            data.HealthBg:Remove()
            data.Line:Remove()
            for _, corner in pairs(data.Corners) do corner:Remove() end
            for _, line in pairs(data.Skeleton) do line:Remove() end
            if data.Highlight then data.Highlight:Destroy() end
        end)
        ESP_Data[player] = nil
    end
end

local function CreateESP(player)
    RemoveESP(player)
    local data = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line"),
        HealthBg = Drawing.new("Line"),
        Line = Drawing.new("Line"),
        Corners = {},
        Skeleton = {},
        Highlight = nil
    }
    for i = 1, 8 do
        local l = Drawing.new("Line")
        l.Thickness = 2
        l.Visible = false
        table.insert(data.Corners, l)
    end
    for i = 1, 10 do -- Reduzido para performance
        local l = Drawing.new("Line")
        l.Thickness = 1.5
        l.Visible = false
        table.insert(data.Skeleton, l)
    end
    data.Box.Thickness = 2 -- Mais grosso para visibilidade mobile
    data.Name.Size = 16 -- Texto maior
    data.Name.Center = true
    data.Name.Outline = true
    data.Name.Font = 2
    data.HealthBg.Thickness = 5
    data.HealthBg.Color = Color3.new(0, 0, 0)
    data.Health.Thickness = 3
    data.Line.Thickness = 2
    ESP_Data[player] = data
end

-- ====================================================================================================
-- LÓGICA DE COMBATE
-- ====================================================================================================

local function GetBestTargetPart(character)
    if not character then return nil end
    return character:FindFirstChild(GodMode.Combat.TargetPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function IsVisible(targetPart)
    if not GodMode.Combat.WallCheck then return true end
    local character = LocalPlayer.Character
    if not character then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude, raycastParams)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetClosestTarget(ignoreFOV)
    local target = nil
    local dist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if GodMode.Combat.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            
            local targetPart = GetBestTargetPart(p.Character)
            if targetPart then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                local magToPlayer = (targetPart.Position - Camera.CFrame.Position).Magnitude
                
                if ignoreFOV then
                    if magToPlayer < dist then
                        if GodMode.Combat.MagicBullet or IsVisible(targetPart) then
                            target = p
                            dist = magToPlayer
                        end
                    end
                elseif onScreen then
                    local magToCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if magToCenter <= GodMode.Combat.FOV and magToCenter < dist then
                        if GodMode.Combat.MagicBullet or IsVisible(targetPart) then
                            target = p
                            dist = magToCenter
                        end
                    end
                end
            end
        end
    end
    return target
end

task.spawn(function()
    while task.wait() do
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        
        -- Lógica de Kill Aura
        if GodMode.Combat.KillAura then
            local target = GetClosestTarget(true)
            if target and target.Character and tool then
                local targetPart = GetBestTargetPart(target.Character)
                if targetPart then
                    tool:Activate()
                    if GodMode.Combat.MagicBullet then
                        local muzzle = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle")
                        if muzzle then muzzle.CFrame = CFrame.new(muzzle.Position, targetPart.Position) end
                    end
                end
            end
        end
        
        -- Lógica de Aimbot
        if GodMode.Combat.Aimbot and GodMode.Combat.Active and not GodMode.Combat.KillAura then
            local target = GetClosestTarget(false)
            if target and target.Character then
                local targetPart = GetBestTargetPart(target.Character)
                if targetPart then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), GodMode.Combat.Smoothness)
                    if GodMode.Combat.MagicBullet and tool then
                        local muzzle = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle")
                        if muzzle then muzzle.CFrame = CFrame.new(muzzle.Position, targetPart.Position) end
                    end
                end
            end
        end

        -- Lógica de Auto Shoot (Nova)
        if GodMode.Combat.AutoShoot and tool then
            local target = GetClosestTarget(false)
            if target and target.Character then
                local targetPart = GetBestTargetPart(target.Character)
                if targetPart and IsVisible(targetPart) then
                    -- Disparo Automático
                    tool:Activate()
                    -- Silent Aim (Bala vai direto pro alvo se Magic Bullet estiver ON ou se for parte do Auto Shoot)
                    local muzzle = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle")
                    if muzzle then 
                        muzzle.CFrame = CFrame.new(muzzle.Position, targetPart.Position) 
                    end
                end
            end
        end
    end
end)

-- ====================================================================================================
-- INTERFACE MOBILE OTIMIZADA
-- ====================================================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeHubMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui)

-- Botão Flutuante para Abrir Menu (Mobile Friendly)
local FloatingButton = Instance.new("TextButton")
FloatingButton.Size = UDim2.new(0, 70, 0, 70)
FloatingButton.Position = UDim2.new(1, -85, 0.5, -35)
FloatingButton.BackgroundColor3 = GodMode.Config.AccentColor
FloatingButton.Text = "🎮"
FloatingButton.TextSize = 32
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.Active = true
FloatingButton.Draggable = true
FloatingButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner", FloatingButton)
FloatCorner.CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", FloatingButton)
FloatStroke.Color = Color3.fromRGB(255, 255, 255)
FloatStroke.Thickness = 3

-- Container Principal (Otimizado para Mobile - Tela Cheia)
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0.95, 0, 0.85, 0)
MainContainer.Position = UDim2.new(0.025, 0, 0.075, 0)
MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.Visible = false
MainContainer.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 20)

local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = GodMode.Config.AccentColor
MainStroke.Thickness = 3
MainStroke.Transparency = 0.3

-- Header Mobile
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Header.Parent = MainContainer
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 20)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GOD MODE HUB <font color='#8A2BE2'>MOBILE</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -50, 0.5, -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

CloseBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
end)

FloatingButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = not MainContainer.Visible
end)

-- Sidebar de Abas (Horizontal para Mobile)
local TabList = Instance.new("ScrollingFrame")
TabList.Size = UDim2.new(1, -20, 0, 50)
TabList.Position = UDim2.new(0, 10, 0, 70)
TabList.BackgroundTransparency = 1
TabList.CanvasSize = UDim2.new(1.5, 0, 0, 0)
TabList.ScrollBarThickness = 0
TabList.Parent = MainContainer

local TabListLayout = Instance.new("UIListLayout", TabList)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.Padding = UDim.new(0, 10)
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Container de Páginas
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -20, 1, -130)
PageContainer.Position = UDim2.new(0, 10, 0, 125)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainContainer

local TabPages = {}
local CurrentTab = nil

local function CreateTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 100, 0, 40)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabBtn.Text = icon .. " " .. name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 14
    tabBtn.Parent = TabList
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 10)
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = GodMode.Config.AccentColor
    page.Parent = PageContainer
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    TabPages[name] = page
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(TabPages) do p.Visible = false end
        page.Visible = true
        CurrentTab = name
    end)
    
    if not CurrentTab then
        page.Visible = true
        CurrentTab = name
    end
end

local function CreateSection(tab, title)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.95, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = "--- " .. title .. " ---"
    label.TextColor3 = GodMode.Config.AccentColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = TabPages[tab]
end

local function AddToggle(tab, text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    container.Parent = TabPages[tab]
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 45, 0, 25)
    toggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    toggle.BackgroundColor3 = default and GodMode.Config.AccentColor or Color3.fromRGB(45, 45, 55)
    toggle.Text = ""
    toggle.Parent = container
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 21, 0, 21)
    circle.Position = default and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggle
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and GodMode.Config.AccentColor or Color3.fromRGB(45, 45, 55)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)}):Play()
        callback(state)
    end)
end

local function AddSlider(tab, text, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 80)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    container.Parent = TabPages[tab]
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 30)
    label.Position = UDim2.new(0, 15, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 15
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -30, 0, 10)
    sliderBg.Position = UDim2.new(0, 15, 0, 60)
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = GodMode.Config.AccentColor
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = UDim2.new(1, -12, 0.5, -12)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderFill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        
        local value = math.floor(min + (max - min) * pos)
        if max <= 1 then value = tonumber(string.format("%.2f", min + (max - min) * pos)) end
        label.Text = text .. ": " .. tostring(value)
        callback(value)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
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

local function AddButton(tab, text, callback)
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(0.95, 0, 0, 60)
    container.BackgroundColor3 = GodMode.Config.AccentColor
    container.Text = text
    container.TextColor3 = Color3.fromRGB(255, 255, 255)
    container.Font = Enum.Font.GothamBold
    container.TextSize = 16
    container.Parent = TabPages[tab]
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.7
    
    container.MouseButton1Click:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 30, 180)}):Play()
        task.wait(0.1)
        TweenService:Create(container, TweenInfo.new(0.1), {BackgroundColor3 = GodMode.Config.AccentColor}):Play()
        callback()
    end)
end

-- ====================================================================================================
-- CRIAR ABAS E FUNCIONALIDADES
-- ====================================================================================================

-- ABA COMBAT
CreateTab("Combat", "⚔️")
CreateSection("Combat", "Aimbot")
AddToggle("Combat", "Enable Aimbot", false, function(v) GodMode.Combat.Aimbot = v end)
AddToggle("Combat", "Auto Lock (Touch)", false, function(v) GodMode.Combat.AutoAimbot = v end)
AddToggle("Combat", "Show FOV", true, function(v) GodMode.Combat.ShowFOV = v FOVCircle.Visible = v end)
AddSlider("Combat", "Smoothness", 0.01, 1, 0.15, function(v) GodMode.Combat.Smoothness = v end)
AddSlider("Combat", "FOV Size", 50, 800, 150, function(v) GodMode.Combat.FOV = v end)

CreateSection("Combat", "Features")
AddToggle("Combat", "Auto Shoot", false, function(v) GodMode.Combat.AutoShoot = v end) -- Novo Toggle
AddToggle("Combat", "Magic Bullet", false, function(v) GodMode.Combat.MagicBullet = v end)
AddToggle("Combat", "Kill Aura", false, function(v) GodMode.Combat.KillAura = v end)
AddToggle("Combat", "Team Check", false, function(v) GodMode.Combat.TeamCheck = v end)
AddToggle("Combat", "Wall Check", false, function(v) GodMode.Combat.WallCheck = v end)

-- Botão de Ativação Touch para Aimbot
AddButton("Combat", "🎯 ACTIVATE AIMBOT (HOLD)", function()
    GodMode.Combat.Active = true
    task.wait(0.1)
end)

-- ABA VISUALS
CreateTab("Visuals", "👁️")
CreateSection("Visuals", "ESP")
AddToggle("Visuals", "Box ESP", false, function(v) GodMode.Visuals.Boxes = v end)
AddToggle("Visuals", "Corner Boxes", false, function(v) GodMode.Visuals.CornerBoxes = v end)
AddToggle("Visuals", "Tracers", false, function(v) GodMode.Visuals.Lines = v end)
AddToggle("Visuals", "Names", false, function(v) GodMode.Visuals.Names = v end)
AddToggle("Visuals", "Health Bar", false, function(v) GodMode.Visuals.HealthBar = v end)
AddToggle("Visuals", "Chams", false, function(v) GodMode.Visuals.Chams = v end)
AddToggle("Visuals", "Skeleton", false, function(v) GodMode.Visuals.Skeletons = v end)
AddToggle("Visuals", "Team Check", false, function(v) GodMode.Visuals.TeamCheck = v end)
AddSlider("Visuals", "Max Distance", 100, 2000, 1000, function(v) GodMode.Visuals.MaxDistance = v end)

-- ABA MOVEMENT
CreateTab("Move", "🏃")
CreateSection("Move", "Movement")
AddToggle("Move", "Bunny Hop", false, function(v) GodMode.Movement.Bhop = v end)
AddToggle("Move", "Infinite Jump", false, function(v) GodMode.Movement.InfJump = v end)
AddToggle("Move", "Noclip", false, function(v) GodMode.Movement.Noclip = v end)

-- ABA GUN MOD
CreateTab("Gun", "🔫")
CreateSection("Gun", "Modifications")
AddToggle("Gun", "Fast Fire", false, function(v) GodMode.GunMod.FastFire = v end)
AddToggle("Gun", "Instant Reload", false, function(v) GodMode.GunMod.InstantReload = v end)
AddToggle("Gun", "No Recoil", false, function(v) GodMode.GunMod.NoRecoil = v end)

-- ABA EXPLOIT
CreateTab("Exploit", "💀")
CreateSection("Exploit", "Dangerous")
AddToggle("Exploit", "Teleport Kill", false, function(v) GodMode.Exploit.TeleportKill = v end)
AddSlider("Exploit", "Kill Delay", 0.1, 2, 0.5, function(v) GodMode.Exploit.KillDelay = v end)

-- ====================================================================================================
-- RENDERIZAÇÃO ESP
-- ====================================================================================================

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = GodMode.Combat.FOV
    FOVCircle.Color = GodMode.Config.AccentColor
    FOVCircle.Visible = GodMode.Combat.ShowFOV

    for player, data in pairs(ESP_Data) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        local isAlly = (player.Team == LocalPlayer.Team)
        local shouldShow = true
        if GodMode.Visuals.TeamCheck and isAlly then shouldShow = false end

        if shouldShow and char and hrp and hum and hum.Health > 0 then
            local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
            if dist <= GodMode.Visuals.MaxDistance then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local size = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y)
                    local w, h = size * 0.6, size
                    local x, y = pos.X - w/2, pos.Y - h/2
                    
                    if GodMode.Visuals.Chams then
                        if not data.Highlight then data.Highlight = Instance.new("Highlight") data.Highlight.Parent = char end
                        data.Highlight.FillColor = GodMode.Visuals.Color
                        data.Highlight.OutlineColor = Color3.new(1, 1, 1)
                        data.Highlight.FillTransparency = 0.5
                        data.Highlight.Enabled = true
                    elseif data.Highlight then data.Highlight.Enabled = false end

                    data.Box.Visible = GodMode.Visuals.Boxes
                    data.Box.Size = Vector2.new(w, h); data.Box.Position = Vector2.new(x, y); data.Box.Color = GodMode.Visuals.Color
                    
                    if GodMode.Visuals.CornerBoxes then
                        local l = h/4; local corners = data.Corners
                        corners[1].Visible = true; corners[1].From = Vector2.new(x, y); corners[1].To = Vector2.new(x + l, y); corners[1].Color = GodMode.Visuals.Color
                        corners[2].Visible = true; corners[2].From = Vector2.new(x, y); corners[2].To = Vector2.new(x, y + l); corners[2].Color = GodMode.Visuals.Color
                        corners[3].Visible = true; corners[3].From = Vector2.new(x + w, y); corners[3].To = Vector2.new(x + w - l, y); corners[3].Color = GodMode.Visuals.Color
                        corners[4].Visible = true; corners[4].From = Vector2.new(x + w, y); corners[4].To = Vector2.new(x + w, y + l); corners[4].Color = GodMode.Visuals.Color
                        corners[5].Visible = true; corners[5].From = Vector2.new(x, y + h); corners[5].To = Vector2.new(x + l, y + h); corners[5].Color = GodMode.Visuals.Color
                        corners[6].Visible = true; corners[6].From = Vector2.new(x, y + h); corners[6].To = Vector2.new(x, y + h - l); corners[6].Color = GodMode.Visuals.Color
                        corners[7].Visible = true; corners[7].From = Vector2.new(x + w, y + h); corners[7].To = Vector2.new(x + w - l, y + h); corners[7].Color = GodMode.Visuals.Color
                        corners[8].Visible = true; corners[8].From = Vector2.new(x + w, y + h); corners[8].To = Vector2.new(x + w, y + h - l); corners[8].Color = GodMode.Visuals.Color
                    else for i=1,8 do data.Corners[i].Visible = false end end
                    
                    data.Name.Visible = GodMode.Visuals.Names
                    data.Name.Text = string.format("%s\n[%dm]", player.Name, math.floor(dist))
                    data.Name.Position = Vector2.new(pos.X, y - 35); data.Name.Color = Color3.new(1, 1, 1)
                    
                    if GodMode.Visuals.HealthBar then
                        local healthPercent = hum.Health / hum.MaxHealth; local barHeight = h * healthPercent
                        data.HealthBg.Visible = true; data.HealthBg.From = Vector2.new(x - 8, y + h); data.HealthBg.To = Vector2.new(x - 8, y)
                        data.Health.Visible = true; data.Health.From = Vector2.new(x - 8, y + h); data.Health.To = Vector2.new(x - 8, y + h - barHeight)
                        data.Health.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
                    else data.Health.Visible = false; data.HealthBg.Visible = false end
                    
                    data.Line.Visible = GodMode.Visuals.Lines
                    data.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); data.Line.To = Vector2.new(pos.X, pos.Y); data.Line.Color = GodMode.Visuals.Color
                    
                    if GodMode.Visuals.Skeletons then
                        local bones = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}
                        for i, bone in ipairs(bones) do
                            local p1 = char:FindFirstChild(bone[1]); local p2 = char:FindFirstChild(bone[2])
                            if p1 and p2 then
                                local pos1 = Camera:WorldToViewportPoint(p1.Position); local pos2 = Camera:WorldToViewportPoint(p2.Position)
                                data.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y); data.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                data.Skeleton[i].Color = GodMode.Visuals.Color; data.Skeleton[i].Visible = true
                            elseif i <= 10 then data.Skeleton[i].Visible = false end
                        end
                    else for _, line in pairs(data.Skeleton) do line.Visible = false end end
                else
                    for i=1,8 do data.Corners[i].Visible = false end
                    for _, line in pairs(data.Skeleton) do line.Visible = false end
                    data.Box.Visible = false; data.Name.Visible = false; data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
                end
            else
                for i=1,8 do data.Corners[i].Visible = false end
                for _, line in pairs(data.Skeleton) do line.Visible = false end
                data.Box.Visible = false; data.Name.Visible = false; data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
            end
        else
            for i=1,8 do data.Corners[i].Visible = false end
            for _, line in pairs(data.Skeleton) do line.Visible = false end
            data.Box.Visible = false; data.Name.Visible = false; data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
            if data.Highlight then data.Highlight.Enabled = false end
        end
    end
end)

-- ====================================================================================================
-- GUN MOD LOOP
-- ====================================================================================================
task.spawn(function()
    while task.wait(1) do
        if GodMode.GunMod.FastFire or GodMode.GunMod.InstantReload or GodMode.GunMod.NoRecoil then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, v in pairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        local name = v.Name:lower()
                        if GodMode.GunMod.FastFire and (name:find("firerate") or name:find("delay") or name:find("cooldown")) then v.Value = 0.01 end
                        if GodMode.GunMod.InstantReload and (name:find("reload") or name:find("reloadtime")) then v.Value = 0.01 end
                        if GodMode.GunMod.NoRecoil and (name:find("recoil") or name:find("shake") or name:find("kick")) then v.Value = 0 end
                    end
                end
            end
        end
    end
end)

-- ====================================================================================================
-- TELEPORT KILL LOOP
-- ====================================================================================================
task.spawn(function()
    while task.wait() do
        if GodMode.Exploit.TeleportKill then
            local target = GetClosestTarget(true)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    task.wait(GodMode.Exploit.KillDelay)
                end
            end
        end
    end
end)

-- ====================================================================================================
-- GERENCIAMENTO DE JOGADORES
-- ====================================================================================================
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

-- ====================================================================================================
-- MOVEMENT SYSTEMS
-- ====================================================================================================
RunService.PreSimulation:Connect(function()
    if GodMode.Movement.Bhop and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then 
            hum:ChangeState(Enum.HumanoidStateType.Jumping) 
        end
    end
    if GodMode.Movement.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do 
            if part:IsA("BasePart") then 
                part.CanCollide = false 
            end 
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function() 
    if GodMode.Movement.InfJump and LocalPlayer.Character then 
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end 
end)

-- Aimbot desativa ao soltar
task.spawn(function()
    while task.wait(0.1) do
        if not GodMode.Combat.AutoAimbot then
            GodMode.Combat.Active = false
        end
    end
end)

print("📱 GOD MODE HUB - MOBILE EDITION v5.1 LOADED!")
print("🎮 Auto Shoot Function Added")
print("✨ Made by Rekirts & Ruqqs")
