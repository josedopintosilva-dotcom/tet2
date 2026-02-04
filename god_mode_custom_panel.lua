--[[
    GOD MODE HUB - CUSTOM EDITION v7.0
    🔥 PAINEL EXCLUSIVO E PERSONALIZADO 🔥
    Interface Única | Sub-Abas | Silent Aim Universal | ESP Completo | Gun Mods | Exploits
    DESIGN TOTALMENTE RENOVADO
--]]

-- ====================================================================================================
-- SERVIÇOS E VARIÁVEIS INICIAIS
-- ====================================================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ====================================================================================================
-- CONFIGURAÇÃO GLOBAL
-- ====================================================================================================
local GodMode = {
    Combat = {
        Aimbot = false,
        AutoAimbot = false,
        Active = false,
        Smoothness = 0.15,
        FOV = 150,
        ShowFOV = true,
        TargetPart = "Head",
        SilentAim = false,
        SilentFOV = 200,
        ShowSilentFOV = true,
        SilentTargetPart = "Head",
        HitChance = 100,
        SilentTracer = false,
        AutoShoot = false,
        MagicBullet = false,
        KillAura = false,
        WallCheck = false,
        TeamCheck = false,
        AutoReload = false
    },
    Visuals = {
        Boxes = false,
        CornerBoxes = false,
        Skeletons = false,
        Lines = false,
        TracerPos = "Bottom",
        Names = false,
        HealthBar = false,
        Distance = false,
        Chams = false,
        ChamsColor = Color3.fromRGB(138, 43, 226),
        ChamsOutline = Color3.fromRGB(255, 255, 255),
        TeamCheck = false,
        Color = Color3.fromRGB(0, 255, 150),
        MaxDistance = 2000,
        FullBright = false,
        NoFog = false
    },
    Movement = {
        Bhop = false,
        InfJump = false,
        Noclip = false,
        WalkSpeed = 16,
        JumpPower = 50,
        SpeedEnabled = false,
        JumpEnabled = false,
        Fly = false,
        FlySpeed = 50,
        AutoWalk = false
    },
    Exploit = {
        TeleportKill = false,
        KillDelay = 0.5,
        Invisibility = false,
        GodMode = false,
        AntiRagdoll = false,
        AutoRespawn = false
    },
    GunMod = {
        FastFire = false,
        InstantReload = false,
        NoRecoil = false,
        NoSpread = false,
        InfiniteAmmo = false,
        RangeHack = false,
        RapidFire = false,
        OneTap = false
    },
    Config = {
        -- 🎨 CORES PERSONALIZADAS EXCLUSIVAS
        AccentColor = Color3.fromRGB(255, 85, 127),      -- Rosa/Vermelho vibrante
        SecondaryColor = Color3.fromRGB(15, 18, 28),      -- Azul escuro profundo
        GlowColor = Color3.fromRGB(127, 255, 212),        -- Aqua brilhante
        TextColor = Color3.fromRGB(240, 240, 255),        -- Branco azulado
        MenuKey = Enum.KeyCode.RightControl,
        RainbowUI = false
    }
}

-- ====================================================================================================
-- SISTEMA DE DESENHO (ESP & FOV)
-- ====================================================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = GodMode.Config.AccentColor

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = 2
SilentFOVCircle.NumSides = 60
SilentFOVCircle.Filled = false
SilentFOVCircle.Visible = false
SilentFOVCircle.Color = Color3.fromRGB(255, 50, 50)

local SilentTracerLine = Drawing.new("Line")
SilentTracerLine.Thickness = 2
SilentTracerLine.Color = Color3.fromRGB(255, 50, 50)
SilentTracerLine.Visible = false

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
            data.Distance:Remove()
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
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Line"),
        HealthBg = Drawing.new("Line"),
        Line = Drawing.new("Line"),
        Corners = {},
        Skeleton = {},
        Highlight = nil
    }
    
    data.Box.Thickness = 2; data.Box.Filled = false; data.Box.Visible = false
    data.Name.Size = 16; data.Name.Center = true; data.Name.Outline = true; data.Name.Font = 2; data.Name.Visible = false
    data.Distance.Size = 14; data.Distance.Center = true; data.Distance.Outline = true; data.Distance.Font = 2; data.Distance.Visible = false
    data.HealthBg.Thickness = 4; data.HealthBg.Color = Color3.new(0, 0, 0); data.HealthBg.Visible = false
    data.Health.Thickness = 2; data.Health.Visible = false
    data.Line.Thickness = 1.5; data.Line.Visible = false
    
    for i = 1, 8 do
        local l = Drawing.new("Line")
        l.Thickness = 2; l.Visible = false
        table.insert(data.Corners, l)
    end
    
    for i = 1, 14 do
        local l = Drawing.new("Line")
        l.Thickness = 1.5; l.Visible = false
        table.insert(data.Skeleton, l)
    end
    
    ESP_Data[player] = data
end

-- ====================================================================================================
-- 🎨 INTERFACE PERSONALIZADA EXCLUSIVA
-- ====================================================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeCustom"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 🔘 BOTÃO FLUTUANTE PERSONALIZADO
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.new(0, 70, 0, 70)
FloatingButton.Position = UDim2.new(1, -90, 0.5, -35)
FloatingButton.BackgroundColor3 = GodMode.Config.SecondaryColor
FloatingButton.BorderSizePixel = 0
FloatingButton.Text = ""
FloatingButton.Parent = ScreenGui

-- Gradiente no botão
local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, GodMode.Config.AccentColor),
    ColorSequenceKeypoint.new(0.5, GodMode.Config.GlowColor),
    ColorSequenceKeypoint.new(1, GodMode.Config.AccentColor)
}
ButtonGradient.Rotation = 45
ButtonGradient.Parent = FloatingButton

-- Borda brilhante
local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = GodMode.Config.GlowColor
ButtonStroke.Thickness = 3
ButtonStroke.Transparency = 0.3
ButtonStroke.Parent = FloatingButton

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 16)
ButtonCorner.Parent = FloatingButton

-- Ícone customizado
local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.new(0, 40, 0, 40)
Icon.Position = UDim2.new(0.5, -20, 0.5, -20)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://7733992901"
Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
Icon.Parent = FloatingButton

-- Efeito de brilho pulsante
local Glow = Instance.new("ImageLabel")
Glow.Name = "Glow"
Glow.Size = UDim2.new(1.4, 0, 1.4, 0)
Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = GodMode.Config.GlowColor
Glow.ImageTransparency = 0.5
Glow.Parent = FloatingButton

-- 📦 FRAME PRINCIPAL PERSONALIZADO
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = GodMode.Config.SecondaryColor
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true

-- Gradiente de fundo único
local BGGradient = Instance.new("UIGradient")
BGGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 18, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 45))
}
BGGradient.Rotation = 135
BGGradient.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

-- Borda externa brilhante
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = GodMode.Config.AccentColor
MainStroke.Thickness = 2.5
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Sombra externa
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5028857084"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

-- 📌 HEADER PERSONALIZADO
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, GodMode.Config.AccentColor),
    ColorSequenceKeypoint.new(1, GodMode.Config.GlowColor)
}
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 18)
HeaderCorner.Parent = Header

-- Título com estilo
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 60, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ GOD MODE ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Ícone do título
local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Size = UDim2.new(0, 35, 0, 35)
TitleIcon.Position = UDim2.new(0, 15, 0.5, -17.5)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = "rbxassetid://7733992901"
TitleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
TitleIcon.Parent = Header

-- Botão fechar customizado
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0.5, -20)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

-- 📑 SISTEMA DE ABAS CUSTOMIZADO
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 130, 1, -65)
TabContainer.Position = UDim2.new(0, 10, 0, 60)
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 22, 35)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 12)
TabCorner.Parent = TabContainer

local TabStroke = Instance.new("UIStroke")
TabStroke.Color = GodMode.Config.AccentColor
TabStroke.Thickness = 1.5
TabStroke.Transparency = 0.6
TabStroke.Parent = TabContainer

-- Container de conteúdo
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -150, 1, -65)
ContentFrame.Position = UDim2.new(0, 145, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- ====================================================================================================
-- FUNÇÕES AUXILIARES
-- ====================================================================================================
local function GetClosestTarget(fov, partName, ignoreWallCheck)
    local closest, closestDist = nil, fov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if GodMode.Combat.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local char = player.Character
            local part = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < closestDist then
                        if not GodMode.Combat.WallCheck or ignoreWallCheck or not workspace:FindPartOnRay(Ray.new(Camera.CFrame.Position, part.Position - Camera.CFrame.Position), LocalPlayer.Character) then
                            closest = player
                            closestDist = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function GetTargetPart(char, partName)
    return char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function IsVisible(part)
    if not GodMode.Combat.WallCheck then return true end
    local ray = Ray.new(Camera.CFrame.Position, part.Position - Camera.CFrame.Position)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

-- ====================================================================================================
-- CRIAÇÃO DE ELEMENTOS UI
-- ====================================================================================================
local function CreateTab(name, icon, order)
    local tab = Instance.new("TextButton")
    tab.Name = name
    tab.Size = UDim2.new(1, -10, 0, 45)
    tab.Position = UDim2.new(0, 5, 0, 5 + (order * 50))
    tab.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    tab.BorderSizePixel = 0
    tab.Text = ""
    tab.AutoButtonColor = false
    tab.Parent = TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tab
    
    local tabIcon = Instance.new("TextLabel")
    tabIcon.Size = UDim2.new(0, 30, 1, 0)
    tabIcon.Position = UDim2.new(0, 8, 0, 0)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Text = icon
    tabIcon.TextColor3 = GodMode.Config.TextColor
    tabIcon.Font = Enum.Font.GothamBold
    tabIcon.TextSize = 18
    tabIcon.Parent = tab
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, -45, 1, 0)
    tabLabel.Position = UDim2.new(0, 40, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = GodMode.Config.TextColor
    tabLabel.Font = Enum.Font.Gotham
    tabLabel.TextSize = 13
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = tab
    
    return tab
end

local function CreateToggle(parent, text, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -10, 0, 35)
    toggle.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = GodMode.Config.TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 45, 0, 25)
    button.Position = UDim2.new(1, -50, 0.5, -12.5)
    button.BackgroundColor3 = default and GodMode.Config.AccentColor or Color3.fromRGB(60, 60, 70)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = toggle
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = button
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 19, 0, 19)
    indicator.Position = default and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator
    
    local enabled = default
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if enabled then
            TweenService:Create(button, tweenInfo, {BackgroundColor3 = GodMode.Config.AccentColor}):Play()
            TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -22, 0.5, -9.5)}):Play()
        else
            TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
            TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -9.5)}):Play()
        end
    end)
    
    return toggle
end

local function CreateSlider(parent, text, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -10, 0, 50)
    slider.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
    slider.BorderSizePixel = 0
    slider.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = slider
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = GodMode.Config.TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 6)
    sliderBar.Position = UDim2.new(0, 10, 1, -15)
    sliderBar.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = slider
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = sliderBar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = GodMode.Config.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
        callback(value)
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    return slider
end

local function CreateDropdown(parent, text, options, default, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -10, 0, 35)
    dropdown.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
    dropdown.BorderSizePixel = 0
    dropdown.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dropdown
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = GodMode.Config.TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdown
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.5, -10, 0, 28)
    button.Position = UDim2.new(0.5, 5, 0.5, -14)
    button.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    button.BorderSizePixel = 0
    button.Text = default
    button.TextColor3 = GodMode.Config.TextColor
    button.Font = Enum.Font.Gotham
    button.TextSize = 11
    button.Parent = dropdown
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(0.5, -10, 0, #options * 30)
    dropdownList.Position = UDim2.new(0.5, 5, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.Parent = dropdown
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownList
    
    button.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
    
    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, 0, 0, 30)
        optionBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        optionBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
        optionBtn.BorderSizePixel = 0
        optionBtn.Text = option
        optionBtn.TextColor3 = GodMode.Config.TextColor
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 11
        optionBtn.ZIndex = 11
        optionBtn.Parent = dropdownList
        
        optionBtn.MouseButton1Click:Connect(function()
            button.Text = option
            callback(option)
            dropdownList.Visible = false
        end)
    end
    
    return dropdown
end

-- ====================================================================================================
-- CRIAÇÃO DAS ABAS
-- ====================================================================================================
local Tabs = {}
local TabPages = {}

-- Criar abas
Tabs.Combat = CreateTab("Combat", "🎯", 0)
Tabs.Visuals = CreateTab("Visuals", "👁️", 1)
Tabs.Movement = CreateTab("Movement", "🏃", 2)
Tabs.GunMod = CreateTab("GunMod", "🔫", 3)
Tabs.Exploit = CreateTab("Exploit", "⚡", 4)

-- Criar páginas
for name, _ in pairs(Tabs) do
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = GodMode.Config.AccentColor
    page.Visible = false
    page.Parent = ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    
    TabPages[name] = page
end

-- Sistema de troca de abas
local currentTab = nil
local function SwitchTab(tabName)
    for name, page in pairs(TabPages) do
        page.Visible = (name == tabName)
    end
    
    for name, tab in pairs(Tabs) do
        if name == tabName then
            tab.BackgroundColor3 = GodMode.Config.AccentColor
            currentTab = tab
        else
            tab.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
        end
    end
end

for name, tab in pairs(Tabs) do
    tab.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

SwitchTab("Combat")

-- ====================================================================================================
-- POPULAR ABAS COM CONTROLES
-- ====================================================================================================

-- ABA COMBAT
CreateToggle(TabPages.Combat, "Aimbot", false, function(v) GodMode.Combat.Aimbot = v end)
CreateToggle(TabPages.Combat, "Auto Aimbot", false, function(v) GodMode.Combat.AutoAimbot = v end)
CreateSlider(TabPages.Combat, "Smoothness", 1, 100, 15, function(v) GodMode.Combat.Smoothness = v / 100 end)
CreateSlider(TabPages.Combat, "FOV", 50, 500, 150, function(v) GodMode.Combat.FOV = v end)
CreateToggle(TabPages.Combat, "Show FOV", true, function(v) GodMode.Combat.ShowFOV = v end)
CreateDropdown(TabPages.Combat, "Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(v) GodMode.Combat.TargetPart = v end)
CreateToggle(TabPages.Combat, "Silent Aim", false, function(v) GodMode.Combat.SilentAim = v end)
CreateSlider(TabPages.Combat, "Silent FOV", 100, 500, 200, function(v) GodMode.Combat.SilentFOV = v end)
CreateToggle(TabPages.Combat, "Show Silent FOV", true, function(v) GodMode.Combat.ShowSilentFOV = v end)
CreateToggle(TabPages.Combat, "Silent Tracer", false, function(v) GodMode.Combat.SilentTracer = v end)
CreateToggle(TabPages.Combat, "Auto Shoot", false, function(v) GodMode.Combat.AutoShoot = v end)
CreateToggle(TabPages.Combat, "Kill Aura", false, function(v) GodMode.Combat.KillAura = v end)
CreateToggle(TabPages.Combat, "Team Check", false, function(v) GodMode.Combat.TeamCheck = v end)
CreateToggle(TabPages.Combat, "Wall Check", false, function(v) GodMode.Combat.WallCheck = v end)

-- ABA VISUALS
CreateToggle(TabPages.Visuals, "Boxes", false, function(v) GodMode.Visuals.Boxes = v end)
CreateToggle(TabPages.Visuals, "Corner Boxes", false, function(v) GodMode.Visuals.CornerBoxes = v end)
CreateToggle(TabPages.Visuals, "Skeletons", false, function(v) GodMode.Visuals.Skeletons = v end)
CreateToggle(TabPages.Visuals, "Lines", false, function(v) GodMode.Visuals.Lines = v end)
CreateToggle(TabPages.Visuals, "Names", false, function(v) GodMode.Visuals.Names = v end)
CreateToggle(TabPages.Visuals, "Health Bar", false, function(v) GodMode.Visuals.HealthBar = v end)
CreateToggle(TabPages.Visuals, "Distance", false, function(v) GodMode.Visuals.Distance = v end)
CreateToggle(TabPages.Visuals, "Chams", false, function(v) GodMode.Visuals.Chams = v end)
CreateToggle(TabPages.Visuals, "Full Bright", false, function(v) GodMode.Visuals.FullBright = v end)
CreateSlider(TabPages.Visuals, "Max Distance", 500, 5000, 2000, function(v) GodMode.Visuals.MaxDistance = v end)
CreateDropdown(TabPages.Visuals, "Tracer Position", {"Top", "Middle", "Bottom"}, "Bottom", function(v) GodMode.Visuals.TracerPos = v end)

-- ABA MOVEMENT
CreateToggle(TabPages.Movement, "Bunny Hop", false, function(v) GodMode.Movement.Bhop = v end)
CreateToggle(TabPages.Movement, "Infinite Jump", false, function(v) GodMode.Movement.InfJump = v end)
CreateToggle(TabPages.Movement, "Noclip", false, function(v) GodMode.Movement.Noclip = v end)
CreateToggle(TabPages.Movement, "Fly", false, function(v) GodMode.Movement.Fly = v end)
CreateSlider(TabPages.Movement, "Fly Speed", 10, 200, 50, function(v) GodMode.Movement.FlySpeed = v end)
CreateToggle(TabPages.Movement, "Speed Enabled", false, function(v) GodMode.Movement.SpeedEnabled = v end)
CreateSlider(TabPages.Movement, "Walk Speed", 16, 200, 16, function(v) GodMode.Movement.WalkSpeed = v end)
CreateToggle(TabPages.Movement, "Jump Enabled", false, function(v) GodMode.Movement.JumpEnabled = v end)
CreateSlider(TabPages.Movement, "Jump Power", 50, 300, 50, function(v) GodMode.Movement.JumpPower = v end)

-- ABA GUN MOD
CreateToggle(TabPages.GunMod, "Fast Fire", false, function(v) GodMode.GunMod.FastFire = v end)
CreateToggle(TabPages.GunMod, "Instant Reload", false, function(v) GodMode.GunMod.InstantReload = v end)
CreateToggle(TabPages.GunMod, "No Recoil", false, function(v) GodMode.GunMod.NoRecoil = v end)
CreateToggle(TabPages.GunMod, "No Spread", false, function(v) GodMode.GunMod.NoSpread = v end)
CreateToggle(TabPages.GunMod, "Infinite Ammo", false, function(v) GodMode.GunMod.InfiniteAmmo = v end)
CreateToggle(TabPages.GunMod, "Range Hack", false, function(v) GodMode.GunMod.RangeHack = v end)
CreateToggle(TabPages.GunMod, "Rapid Fire", false, function(v) GodMode.GunMod.RapidFire = v end)
CreateToggle(TabPages.GunMod, "One Tap", false, function(v) GodMode.GunMod.OneTap = v end)

-- ABA EXPLOIT
CreateToggle(TabPages.Exploit, "Teleport Kill", false, function(v) GodMode.Exploit.TeleportKill = v end)
CreateSlider(TabPages.Exploit, "Kill Delay", 0, 2, 0.5, function(v) GodMode.Exploit.KillDelay = v end)
CreateToggle(TabPages.Exploit, "God Mode", false, function(v) GodMode.Exploit.GodMode = v end)
CreateToggle(TabPages.Exploit, "Anti Ragdoll", false, function(v) GodMode.Exploit.AntiRagdoll = v end)
CreateToggle(TabPages.Exploit, "Auto Respawn", false, function(v) GodMode.Exploit.AutoRespawn = v end)

-- ====================================================================================================
-- ANIMAÇÕES E EFEITOS
-- ====================================================================================================

-- Animação do botão flutuante
task.spawn(function()
    while task.wait(0.05) do
        if FloatingButton.Parent then
            ButtonGradient.Rotation = (ButtonGradient.Rotation + 2) % 360
        end
    end
end)

-- Efeito de brilho pulsante
task.spawn(function()
    while task.wait(0.03) do
        if Glow.Parent then
            local pulse = math.abs(math.sin(tick() * 2))
            Glow.ImageTransparency = 0.3 + (pulse * 0.4)
            Glow.Size = UDim2.new(1.4 + (pulse * 0.2), 0, 1.4 + (pulse * 0.2), 0)
        end
    end
end)

-- ====================================================================================================
-- LOOPS DE FUNCIONALIDADE
-- ====================================================================================================

-- Loop FOV
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if GodMode.Combat.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = center
        FOVCircle.Radius = GodMode.Combat.FOV
    else
        FOVCircle.Visible = false
    end
    
    if GodMode.Combat.ShowSilentFOV then
        SilentFOVCircle.Visible = true
        SilentFOVCircle.Position = center
        SilentFOVCircle.Radius = GodMode.Combat.SilentFOV
    else
        SilentFOVCircle.Visible = false
    end
    
    if GodMode.Combat.SilentTracer and GodMode.Combat.SilentAim then
        local target = GetClosestTarget(GodMode.Combat.SilentFOV, GodMode.Combat.SilentTargetPart, false)
        if target and target.Character then
            local part = GetTargetPart(target.Character, GodMode.Combat.SilentTargetPart)
            if part then
                local pos = Camera:WorldToViewportPoint(part.Position)
                SilentTracerLine.From = center
                SilentTracerLine.To = Vector2.new(pos.X, pos.Y)
                SilentTracerLine.Visible = true
            else
                SilentTracerLine.Visible = false
            end
        else
            SilentTracerLine.Visible = false
        end
    else
        SilentTracerLine.Visible = false
    end
end)

-- Loop ESP
RunService.RenderStepped:Connect(function()
    for player, data in pairs(ESP_Data) do
        if player and player.Parent and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 9999
                
                if dist <= GodMode.Visuals.MaxDistance then
                    if GodMode.Visuals.TeamCheck and player.Team == LocalPlayer.Team then
                        data.Box.Visible = false
                        data.Name.Visible = false
                        data.Distance.Visible = false
                        data.Health.Visible = false
                        data.HealthBg.Visible = false
                        data.Line.Visible = false
                        for i=1,8 do data.Corners[i].Visible = false end
                        for _, line in pairs(data.Skeleton) do line.Visible = false end
                        if data.Highlight then data.Highlight.Enabled = false end
                    else
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        
                        if onScreen then
                            local head = char:FindFirstChild("Head")
                            local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or pos
                            local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                            
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height * 0.5
                            
                            if GodMode.Visuals.Boxes then
                                data.Box.Size = Vector2.new(width, height)
                                data.Box.Position = Vector2.new(pos.X - width / 2, headPos.Y)
                                data.Box.Color = GodMode.Visuals.Color
                                data.Box.Visible = true
                            else
                                data.Box.Visible = false
                            end
                            
                            if GodMode.Visuals.CornerBoxes then
                                local corners = {
                                    {Vector2.new(pos.X - width/2, headPos.Y), Vector2.new(pos.X - width/2 + width/4, headPos.Y)},
                                    {Vector2.new(pos.X - width/2, headPos.Y), Vector2.new(pos.X - width/2, headPos.Y + height/4)},
                                    {Vector2.new(pos.X + width/2, headPos.Y), Vector2.new(pos.X + width/2 - width/4, headPos.Y)},
                                    {Vector2.new(pos.X + width/2, headPos.Y), Vector2.new(pos.X + width/2, headPos.Y + height/4)},
                                    {Vector2.new(pos.X - width/2, headPos.Y + height), Vector2.new(pos.X - width/2 + width/4, headPos.Y + height)},
                                    {Vector2.new(pos.X - width/2, headPos.Y + height), Vector2.new(pos.X - width/2, headPos.Y + height - height/4)},
                                    {Vector2.new(pos.X + width/2, headPos.Y + height), Vector2.new(pos.X + width/2 - width/4, headPos.Y + height)},
                                    {Vector2.new(pos.X + width/2, headPos.Y + height), Vector2.new(pos.X + width/2, headPos.Y + height - height/4)}
                                }
                                for i, corner in ipairs(corners) do
                                    data.Corners[i].From = corner[1]
                                    data.Corners[i].To = corner[2]
                                    data.Corners[i].Color = GodMode.Visuals.Color
                                    data.Corners[i].Visible = true
                                end
                            else
                                for i=1,8 do data.Corners[i].Visible = false end
                            end
                            
                            if GodMode.Visuals.Names then
                                data.Name.Text = player.Name
                                data.Name.Position = Vector2.new(pos.X, headPos.Y - 20)
                                data.Name.Color = GodMode.Visuals.Color
                                data.Name.Visible = true
                            else
                                data.Name.Visible = false
                            end
                            
                            if GodMode.Visuals.Distance then
                                data.Distance.Text = math.floor(dist) .. "m"
                                data.Distance.Position = Vector2.new(pos.X, headPos.Y + height + 5)
                                data.Distance.Color = GodMode.Visuals.Color
                                data.Distance.Visible = true
                            else
                                data.Distance.Visible = false
                            end
                            
                            if GodMode.Visuals.HealthBar then
                                local healthPercent = hum.Health / hum.MaxHealth
                                data.HealthBg.From = Vector2.new(pos.X - width/2 - 6, headPos.Y)
                                data.HealthBg.To = Vector2.new(pos.X - width/2 - 6, headPos.Y + height)
                                data.HealthBg.Visible = true
                                
                                data.Health.From = Vector2.new(pos.X - width/2 - 6, headPos.Y + height)
                                data.Health.To = Vector2.new(pos.X - width/2 - 6, headPos.Y + height - (height * healthPercent))
                                data.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                                data.Health.Visible = true
                            else
                                data.Health.Visible = false
                                data.HealthBg.Visible = false
                            end
                            
                            if GodMode.Visuals.Lines then
                                local tracerY = GodMode.Visuals.TracerPos == "Top" and 0 or (GodMode.Visuals.TracerPos == "Middle" and Camera.ViewportSize.Y / 2 or Camera.ViewportSize.Y)
                                data.Line.From = Vector2.new(Camera.ViewportSize.X / 2, tracerY)
                                data.Line.To = Vector2.new(pos.X, headPos.Y + height)
                                data.Line.Color = GodMode.Visuals.Color
                                data.Line.Visible = true
                            else
                                data.Line.Visible = false
                            end
                            
                            if GodMode.Visuals.Chams then
                                if not data.Highlight then
                                    data.Highlight = Instance.new("Highlight")
                                    data.Highlight.FillColor = GodMode.Visuals.ChamsColor
                                    data.Highlight.OutlineColor = GodMode.Visuals.ChamsOutline
                                    data.Highlight.FillTransparency = 0.5
                                    data.Highlight.OutlineTransparency = 0
                                    data.Highlight.Parent = char
                                end
                                data.Highlight.Enabled = true
                            elseif data.Highlight then
                                data.Highlight.Enabled = false
                            end
                            
                            if GodMode.Visuals.Skeletons then
                                local bones = {
                                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, 
                                    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                                    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                                    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                                    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                                }
                                for i, bone in ipairs(bones) do
                                    local p1 = char:FindFirstChild(bone[1])
                                    local p2 = char:FindFirstChild(bone[2])
                                    if p1 and p2 then
                                        local pos1 = Camera:WorldToViewportPoint(p1.Position)
                                        local pos2 = Camera:WorldToViewportPoint(p2.Position)
                                        data.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                        data.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                        data.Skeleton[i].Color = GodMode.Visuals.Color
                                        data.Skeleton[i].Visible = true
                                    elseif i <= #data.Skeleton then
                                        data.Skeleton[i].Visible = false
                                    end
                                end
                            else
                                for _, line in pairs(data.Skeleton) do line.Visible = false end
                            end
                        else
                            for i=1,8 do data.Corners[i].Visible = false end
                            for _, line in pairs(data.Skeleton) do line.Visible = false end
                            data.Box.Visible = false; data.Name.Visible = false; data.Distance.Visible = false
                            data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
                        end
                    end
                else
                    for i=1,8 do data.Corners[i].Visible = false end
                    for _, line in pairs(data.Skeleton) do line.Visible = false end
                    data.Box.Visible = false; data.Name.Visible = false; data.Distance.Visible = false
                    data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
                end
            else
                for i=1,8 do data.Corners[i].Visible = false end
                for _, line in pairs(data.Skeleton) do line.Visible = false end
                data.Box.Visible = false; data.Name.Visible = false; data.Distance.Visible = false
                data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
                if data.Highlight then data.Highlight.Enabled = false end
            end
        else
            for i=1,8 do data.Corners[i].Visible = false end
            for _, line in pairs(data.Skeleton) do line.Visible = false end
            data.Box.Visible = false; data.Name.Visible = false; data.Distance.Visible = false
            data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
            if data.Highlight then data.Highlight.Enabled = false end
        end
    end
end)

-- Loop de Combate e Exploits
task.spawn(function()
    while task.wait() do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local tool = char and char:FindFirstChildOfClass("Tool")
        
        if hum then
            if GodMode.Movement.SpeedEnabled then hum.WalkSpeed = GodMode.Movement.WalkSpeed end
            if GodMode.Movement.JumpEnabled then hum.JumpPower = GodMode.Movement.JumpPower end
            if GodMode.Exploit.AntiRagdoll then
                hum.PlatformStand = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end
        
        if GodMode.Combat.Aimbot and GodMode.Combat.Active then
            local target = GetClosestTarget(GodMode.Combat.FOV, GodMode.Combat.TargetPart, false)
            if target and target.Character then
                local part = GetTargetPart(target.Character, GodMode.Combat.TargetPart)
                if part then
                    local lookAt = CFrame.new(Camera.CFrame.Position, part.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(lookAt, GodMode.Combat.Smoothness)
                end
            end
        end
        
        if GodMode.Combat.AutoShoot and tool then
            local fov = GodMode.Combat.SilentAim and GodMode.Combat.SilentFOV or GodMode.Combat.FOV
            local partName = GodMode.Combat.SilentAim and GodMode.Combat.SilentTargetPart or GodMode.Combat.TargetPart
            local target = GetClosestTarget(fov, partName, false)
            if target and target.Character then
                local part = GetTargetPart(target.Character, partName)
                if part and IsVisible(part) then tool:Activate() end
            end
        end
        
        if GodMode.Combat.KillAura and tool then
            local target = GetClosestTarget(25, "Torso", true)
            if target then tool:Activate() end
        end
        
        if GodMode.Exploit.TeleportKill and char and char:FindFirstChild("HumanoidRootPart") then
            local target = GetClosestTarget(2000, "Torso", true)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                task.wait(GodMode.Exploit.KillDelay)
            end
        end
        
        if GodMode.Visuals.FullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end
end)

-- Gun Mod Loop
task.spawn(function()
    while task.wait(1) do
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local n = v.Name:lower()
                    if GodMode.GunMod.FastFire and (n:find("fire") or n:find("delay") or n:find("cooldown")) then v.Value = 0.01 end
                    if GodMode.GunMod.InstantReload and (n:find("reload") or n:find("reloadtime")) then v.Value = 0.01 end
                    if GodMode.GunMod.NoRecoil and (n:find("recoil") or n:find("kick") or n:find("shake")) then v.Value = 0 end
                    if GodMode.GunMod.NoSpread and (n:find("spread") or n:find("accuracy") or n:find("minspread")) then v.Value = 0 end
                    if GodMode.GunMod.InfiniteAmmo and (n:find("ammo") or n:find("clip") or n:find("mag") or n:find("stored")) then v.Value = 999 end
                    if GodMode.GunMod.RangeHack and (n:find("range") or n:find("distance") or n:find("maxrange")) then v.Value = 9999 end
                    if GodMode.GunMod.OneTap and (n:find("damage") or n:find("dmg")) then v.Value = 9999 end
                end
            end
        end
    end
end)

-- Eventos de Jogador e Movimento
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

RunService.PreSimulation:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if GodMode.Movement.Bhop and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        if GodMode.Movement.Noclip then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        if GodMode.Movement.Fly and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local moveDir = hum.MoveDirection
            local flyVel = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyVel = flyVel + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then flyVel = flyVel - Vector3.new(0, 1, 0) end
            hrp.Velocity = (moveDir * GodMode.Movement.FlySpeed) + (flyVel * GodMode.Movement.FlySpeed)
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if GodMode.Movement.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- Abrir/Fechar Menu
FloatingButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true, function() MainFrame.Visible = false end)
    else
        MainFrame.Visible = true
        local targetSize = UserInputService.TouchEnabled and UDim2.new(0, 480, 0, 320) or UDim2.new(0, 550, 0, 380)
        MainFrame:TweenSize(targetSize, "Out", "Back", 0.3, true)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true, function() MainFrame.Visible = false end)
end)

task.spawn(function()
    while task.wait(0.1) do
        if not GodMode.Combat.AutoAimbot then
            GodMode.Combat.Active = false
        end
    end
end)

print("🔥 GOD MODE HUB - CUSTOM EDITION CARREGADO!")
print("✨ PAINEL PERSONALIZADO E EXCLUSIVO!")
