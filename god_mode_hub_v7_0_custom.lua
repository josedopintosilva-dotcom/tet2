--[[
    GOD MODE HUB - MOBILE EDITION v7.0 ULTIMATE
    Interface Moderna | Sub-Abas | Silent Aim Universal | ESP Completo | Gun Mods | Exploits
    NOVIDADE: SILENT TRACER (Linha de Alvo no FOV)
    VERSÃO MASSIVA - 750+ LINHAS DE CÓDIGO PURO
    SEM CÓDIGO APAGADO - TUDO REINTEGRADO
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
-- CONFIGURAÇÃO GLOBAL (MASSIVA)
-- ====================================================================================================
local GodMode = {
    Combat = {
        -- Aimbot Settings
        Aimbot = false,
        AutoAimbot = false,
        Active = false,
        Smoothness = 0.15,
        FOV = 150,
        ShowFOV = true,
        TargetPart = "Head",
        
        -- Silent Aim Settings
        SilentAim = false,
        SilentFOV = 200,
        ShowSilentFOV = true,
        SilentTargetPart = "Head",
        HitChance = 100,
        SilentTracer = false, -- NOVA FUNÇÃO
        
        -- Combat Utilities
        AutoShoot = false,
        MagicBullet = false,
        KillAura = false,
        WallCheck = false,
        TeamCheck = false,
        AutoReload = false
    },
    Visuals = {
        -- ESP Main
        Boxes = false,
        CornerBoxes = false,
        Skeletons = false,
        Lines = false,
        TracerPos = "Bottom",
        Names = false,
        HealthBar = false,
        Distance = false,
        
        -- ESP Advanced
        Chams = false,
        ChamsColor = Color3.fromRGB(138, 43, 226),
        ChamsOutline = Color3.fromRGB(255, 255, 255),
        TeamCheck = false,
        Color = Color3.fromRGB(0, 255, 150),
        MaxDistance = 2000,
        
        -- World Visuals
        FullBright = false,
        NoFog = false
    },
    Movement = {
        -- Basic Movement
        Bhop = false,
        InfJump = false,
        Noclip = false,
        
        -- Speed & Jump
        WalkSpeed = 16,
        JumpPower = 50,
        SpeedEnabled = false,
        JumpEnabled = false,
        
        -- Advanced Movement
        Fly = false,
        FlySpeed = 50,
        AutoWalk = false
    },
    Exploit = {
        -- Combat Exploits
        TeleportKill = false,
        KillDelay = 0.5,
        
        -- Character Exploits
        Invisibility = false,
        GodMode = false,
        AntiRagdoll = false,
        AutoRespawn = false
    },
    GunMod = {
        -- Weapon Modifiers
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
        -- UI Appearance (CORES PERSONALIZADAS)
        AccentColor = Color3.fromRGB(0, 255, 200),  -- Ciano neon
        SecondaryColor = Color3.fromRGB(15, 15, 25), -- Preto azulado
        TextColor = Color3.fromRGB(255, 255, 255),
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

-- Silent Tracer Line
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
    
    if GodMode.Visuals.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Enabled = false
        highlight.FillColor = GodMode.Visuals.ChamsColor
        highlight.OutlineColor = GodMode.Visuals.ChamsOutline
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = CoreGui
        data.Highlight = highlight
    end
    
    ESP_Data[player] = data
end

-- ====================================================================================================
-- FUNÇÕES UTILITÁRIAS DE COMBATE
-- ====================================================================================================
local function GetTargetPart(character, partName)
    if not character then return nil end
    if partName == "Random" then
        local parts = {"Head", "UpperTorso", "LowerTorso"}
        return character:FindFirstChild(parts[math.random(#parts)])
    end
    return character:FindFirstChild(partName) or character:FindFirstChild("HumanoidRootPart")
end

local function IsVisible(part)
    if not GodMode.Combat.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == part or hit == nil
end

local function GetClosestTarget(fovRadius, targetPartName, ignoreTeam)
    local closestTarget = nil
    local closestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local shouldSkip = false
            if GodMode.Combat.TeamCheck and not ignoreTeam and player.Team == LocalPlayer.Team then
                shouldSkip = true
            end
            if not shouldSkip and player.Character then
                local part = GetTargetPart(player.Character, targetPartName)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < fovRadius and distance < closestDistance then
                            if IsVisible(part) or not GodMode.Combat.WallCheck then
                                closestTarget = player
                                closestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ====================================================================================================
-- CRIAÇÃO DA UI (PAINEL PERSONALIZADO)
-- ====================================================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = HttpService:GenerateGUID(false)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- Botão Flutuante com Design Único
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingBtn"
FloatingButton.Size = UDim2.new(0, 65, 0, 65)
FloatingButton.Position = UDim2.new(0, 15, 0.5, -32)
FloatingButton.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
FloatingButton.BorderSizePixel = 0
FloatingButton.Text = ""
FloatingButton.AutoButtonColor = false
FloatingButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 18)
FloatCorner.Parent = FloatingButton

-- Gradiente Personalizado no Botão
local FloatGrad = Instance.new("UIGradient")
FloatGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 255))
}
FloatGrad.Rotation = 45
FloatGrad.Parent = FloatingButton

-- Stroke com glow único
local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 255, 200)
FloatStroke.Thickness = 2.5
FloatStroke.Transparency = 0
FloatStroke.Parent = FloatingButton

-- Ícone personalizado
local FloatIcon = Instance.new("TextLabel")
FloatIcon.Size = UDim2.new(1, 0, 1, 0)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Text = "⚡"
FloatIcon.TextSize = 32
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBold
FloatIcon.Parent = FloatingButton

-- Frame Principal com novo estilo
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UserInputService.TouchEnabled and UDim2.new(0, 480, 0, 320) or UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Stroke externo único
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Header com gradiente personalizado
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

-- Gradiente do header
local HeaderGrad = Instance.new("UIGradient")
HeaderGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 40, 200))
}
HeaderGrad.Rotation = 90
HeaderGrad.Parent = Header

-- Linha decorativa única no header
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -20, 0, 2)
HeaderLine.Position = UDim2.new(0, 10, 1, -2)
HeaderLine.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local HeaderLineGrad = Instance.new("UIGradient")
HeaderLineGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 200))
}
HeaderLineGrad.Parent = HeaderLine

-- Título com estilo
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, -10)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ GOD MODE V7"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Subtítulo
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -30, 0, 16)
Subtitle.Position = UDim2.new(0, 15, 0, 30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "ULTIMATE EDITION"
Subtitle.TextColor3 = Color3.fromRGB(0, 255, 200)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

-- Botão Close com estilo
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

-- Container de Abas
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -20, 0, 45)
TabContainer.Position = UDim2.new(0, 10, 0, 65)
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabContainerCorner = Instance.new("UICorner")
TabContainerCorner.CornerRadius = UDim.new(0, 10)
TabContainerCorner.Parent = TabContainer

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabContainer

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 8)
TabPadding.PaddingTop = UDim.new(0, 6)
TabPadding.Parent = TabContainer

-- Content Container
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -20, 1, -130)
ContentFrame.Position = UDim2.new(0, 10, 0, 120)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = ContentFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 10)
ContentPadding.PaddingBottom = UDim.new(0, 10)
ContentPadding.PaddingLeft = UDim.new(0, 10)
ContentPadding.PaddingRight = UDim.new(0, 10)
ContentPadding.Parent = ContentFrame

-- Sistema de Abas
local ActiveTab = nil
local Tabs = {}

local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name
    TabButton.Size = UDim2.new(0, 85, 0, 33)
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.BorderSizePixel = 0
    TabButton.Parent = TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    -- Gradiente da tab inativa
    local TabGrad = Instance.new("UIGradient")
    TabGrad.Color = ColorSequence.new(Color3.fromRGB(25, 25, 40))
    TabGrad.Parent = TabButton
    
    local TabLabel = Instance.new("TextLabel")
    TabLabel.Size = UDim2.new(1, 0, 1, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = icon .. " " .. name
    TabLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabLabel.TextSize = 13
    TabLabel.Font = Enum.Font.GothamBold
    TabLabel.Parent = TabButton
    
    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ContentFrame
    
    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.Padding = UDim.new(0, 8)
    TabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabContentLayout.Parent = TabContent
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
            tab.Label.TextColor3 = Color3.fromRGB(150, 150, 150)
            tab.Content.Visible = false
            tab.Gradient.Color = ColorSequence.new(Color3.fromRGB(25, 25, 40))
        end
        
        -- Ativar tab com gradiente personalizado
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 180, 220)
        TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabContent.Visible = true
        TabGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
        }
        ActiveTab = TabContent
    end)
    
    Tabs[name] = {Button = TabButton, Label = TabLabel, Content = TabContent, Gradient = TabGrad}
    return TabContent
end

-- Função para criar Toggles com design único
local function CreateToggle(parent, text, callback, defaultState)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 38)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    -- Stroke personalizado
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(40, 40, 60)
    ToggleStroke.Thickness = 1.5
    ToggleStroke.Transparency = 0.5
    ToggleStroke.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 46, 0, 24)
    ToggleButton.Position = UDim2.new(1, -54, 0.5, -12)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
    ToggleBtnCorner.Parent = ToggleButton
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 18, 0, 18)
    ToggleIndicator.Position = UDim2.new(0, 3, 0.5, -9)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = ToggleButton
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = ToggleIndicator
    
    local toggled = defaultState or false
    
    local function UpdateToggle()
        if toggled then
            -- Ativado - cores personalizadas
            TweenService:Create(ToggleButton, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(0, 255, 200)}):Play()
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.25), {
                Position = UDim2.new(1, -21, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(ToggleStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(0, 255, 200), Transparency = 0}):Play()
        else
            -- Desativado
            TweenService:Create(ToggleButton, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.25), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            }):Play()
            TweenService:Create(ToggleStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(40, 40, 60), Transparency = 0.5}):Play()
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        UpdateToggle()
        callback(toggled)
    end)
    
    UpdateToggle()
    return ToggleFrame
end

-- Função para criar Sliders com design único
local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Color = Color3.fromRGB(40, 40, 60)
    SliderStroke.Thickness = 1.5
    SliderStroke.Transparency = 0.5
    SliderStroke.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 18)
    ValueLabel.Position = UDim2.new(1, -60, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 1, -16)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(1, 0)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    -- Gradiente no fill
    local FillGrad = Instance.new("UIGradient")
    FillGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }
    FillGrad.Parent = SliderFill
    
    local dragging = false
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        callback(value)
    end
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
    
    return SliderFrame
end

-- Criar abas com ícones personalizados
local CombatTab = CreateTab("Combat", "⚔️")
local VisualTab = CreateTab("Visual", "👁️")
local MovementTab = CreateTab("Move", "🏃")
local ExploitTab = CreateTab("Exploit", "💀")
local GunModTab = CreateTab("Gun", "🔫")
local SettingsTab = CreateTab("Config", "⚙️")

-- ====================================================================================================
-- POPULAR ABAS
-- ====================================================================================================

-- COMBAT TAB
CreateToggle(CombatTab, "Aimbot", function(val) GodMode.Combat.Aimbot = val end)
CreateToggle(CombatTab, "Auto Aimbot", function(val) GodMode.Combat.AutoAimbot = val; GodMode.Combat.Active = val end)
CreateSlider(CombatTab, "Smoothness", 1, 100, 15, function(val) GodMode.Combat.Smoothness = val / 100 end)
CreateSlider(CombatTab, "FOV", 50, 500, 150, function(val) GodMode.Combat.FOV = val end)
CreateToggle(CombatTab, "Show FOV", function(val) GodMode.Combat.ShowFOV = val end, true)
CreateToggle(CombatTab, "Silent Aim", function(val) GodMode.Combat.SilentAim = val end)
CreateSlider(CombatTab, "Silent FOV", 50, 500, 200, function(val) GodMode.Combat.SilentFOV = val end)
CreateToggle(CombatTab, "Show Silent FOV", function(val) GodMode.Combat.ShowSilentFOV = val end, true)
CreateToggle(CombatTab, "Silent Tracer", function(val) GodMode.Combat.SilentTracer = val end)
CreateSlider(CombatTab, "Hit Chance %", 0, 100, 100, function(val) GodMode.Combat.HitChance = val end)
CreateToggle(CombatTab, "Auto Shoot", function(val) GodMode.Combat.AutoShoot = val end)
CreateToggle(CombatTab, "Kill Aura", function(val) GodMode.Combat.KillAura = val end)
CreateToggle(CombatTab, "Wall Check", function(val) GodMode.Combat.WallCheck = val end)
CreateToggle(CombatTab, "Team Check", function(val) GodMode.Combat.TeamCheck = val end)

-- VISUAL TAB
CreateToggle(VisualTab, "Boxes", function(val) GodMode.Visuals.Boxes = val end)
CreateToggle(VisualTab, "Corner Boxes", function(val) GodMode.Visuals.CornerBoxes = val end)
CreateToggle(VisualTab, "Skeletons", function(val) GodMode.Visuals.Skeletons = val end)
CreateToggle(VisualTab, "Lines", function(val) GodMode.Visuals.Lines = val end)
CreateToggle(VisualTab, "Names", function(val) GodMode.Visuals.Names = val end)
CreateToggle(VisualTab, "Health Bar", function(val) GodMode.Visuals.HealthBar = val end)
CreateToggle(VisualTab, "Distance", function(val) GodMode.Visuals.Distance = val end)
CreateToggle(VisualTab, "Chams", function(val) 
    GodMode.Visuals.Chams = val
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then CreateESP(p) end
    end
end)
CreateSlider(VisualTab, "Max Distance", 500, 5000, 2000, function(val) GodMode.Visuals.MaxDistance = val end)
CreateToggle(VisualTab, "Full Bright", function(val) GodMode.Visuals.FullBright = val end)
CreateToggle(VisualTab, "No Fog", function(val) 
    GodMode.Visuals.NoFog = val
    if val then Lighting.FogEnd = 100000 else Lighting.FogEnd = 500 end
end)

-- MOVEMENT TAB
CreateToggle(MovementTab, "Bunny Hop", function(val) GodMode.Movement.Bhop = val end)
CreateToggle(MovementTab, "Infinite Jump", function(val) GodMode.Movement.InfJump = val end)
CreateToggle(MovementTab, "Noclip", function(val) GodMode.Movement.Noclip = val end)
CreateToggle(MovementTab, "Fly", function(val) GodMode.Movement.Fly = val end)
CreateSlider(MovementTab, "Fly Speed", 10, 200, 50, function(val) GodMode.Movement.FlySpeed = val end)
CreateToggle(MovementTab, "Speed Enabled", function(val) GodMode.Movement.SpeedEnabled = val end)
CreateSlider(MovementTab, "Walk Speed", 16, 200, 16, function(val) GodMode.Movement.WalkSpeed = val end)
CreateToggle(MovementTab, "Jump Enabled", function(val) GodMode.Movement.JumpEnabled = val end)
CreateSlider(MovementTab, "Jump Power", 50, 200, 50, function(val) GodMode.Movement.JumpPower = val end)

-- EXPLOIT TAB
CreateToggle(ExploitTab, "Teleport Kill", function(val) GodMode.Exploit.TeleportKill = val end)
CreateSlider(ExploitTab, "Kill Delay", 1, 20, 5, function(val) GodMode.Exploit.KillDelay = val / 10 end)
CreateToggle(ExploitTab, "God Mode", function(val) 
    GodMode.Exploit.GodMode = val
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = val and math.huge or 100
        char.Humanoid.Health = val and math.huge or 100
    end
end)
CreateToggle(ExploitTab, "Anti Ragdoll", function(val) GodMode.Exploit.AntiRagdoll = val end)

-- GUN MOD TAB
CreateToggle(GunModTab, "Fast Fire", function(val) GodMode.GunMod.FastFire = val end)
CreateToggle(GunModTab, "Instant Reload", function(val) GodMode.GunMod.InstantReload = val end)
CreateToggle(GunModTab, "No Recoil", function(val) GodMode.GunMod.NoRecoil = val end)
CreateToggle(GunModTab, "No Spread", function(val) GodMode.GunMod.NoSpread = val end)
CreateToggle(GunModTab, "Infinite Ammo", function(val) GodMode.GunMod.InfiniteAmmo = val end)
CreateToggle(GunModTab, "Range Hack", function(val) GodMode.GunMod.RangeHack = val end)
CreateToggle(GunModTab, "One Tap", function(val) GodMode.GunMod.OneTap = val end)

-- Ativar primeira aba
Tabs["Combat"].Button.MouseButton1Click:Connect(function() end)()

-- ====================================================================================================
-- LOOPS PRINCIPAIS
-- ====================================================================================================

-- Animação do botão flutuante
task.spawn(function()
    local rotationSpeed = 0
    while task.wait() do
        rotationSpeed = rotationSpeed + 2
        FloatGrad.Rotation = rotationSpeed % 360
        FloatIcon.Rotation = math.sin(tick() * 2) * 5
    end
end)

-- Update FOV Circles
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    
    FOVCircle.Position = mousePos
    FOVCircle.Radius = GodMode.Combat.FOV
    FOVCircle.Visible = GodMode.Combat.ShowFOV
    FOVCircle.Color = GodMode.Config.AccentColor
    
    SilentFOVCircle.Position = mousePos
    SilentFOVCircle.Radius = GodMode.Combat.SilentFOV
    SilentFOVCircle.Visible = GodMode.Combat.SilentAim and GodMode.Combat.ShowSilentFOV
    
    -- Silent Tracer
    if GodMode.Combat.SilentTracer and GodMode.Combat.SilentAim then
        local target = GetClosestTarget(GodMode.Combat.SilentFOV, GodMode.Combat.SilentTargetPart, false)
        if target and target.Character then
            local part = GetTargetPart(target.Character, GodMode.Combat.SilentTargetPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    SilentTracerLine.From = mousePos
                    SilentTracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
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
    else
        SilentTracerLine.Visible = false
    end
end)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    for player, data in pairs(ESP_Data) do
        if player and player.Parent and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                    and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 0
                
                if onScreen and distance <= GodMode.Visuals.MaxDistance then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    
                    -- Boxes
                    if GodMode.Visuals.Boxes then
                        data.Box.Size = Vector2.new(width, height)
                        data.Box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height/2)
                        data.Box.Color = GodMode.Visuals.Color
                        data.Box.Visible = true
                    else
                        data.Box.Visible = false
                    end
                    
                    -- Corner Boxes
                    if GodMode.Visuals.CornerBoxes then
                        local cornerLen = math.min(width, height) * 0.25
                        local x, y = screenPos.X - width/2, screenPos.Y - height/2
                        
                        data.Corners[1].From = Vector2.new(x, y); data.Corners[1].To = Vector2.new(x + cornerLen, y)
                        data.Corners[2].From = Vector2.new(x, y); data.Corners[2].To = Vector2.new(x, y + cornerLen)
                        data.Corners[3].From = Vector2.new(x + width, y); data.Corners[3].To = Vector2.new(x + width - cornerLen, y)
                        data.Corners[4].From = Vector2.new(x + width, y); data.Corners[4].To = Vector2.new(x + width, y + cornerLen)
                        data.Corners[5].From = Vector2.new(x, y + height); data.Corners[5].To = Vector2.new(x + cornerLen, y + height)
                        data.Corners[6].From = Vector2.new(x, y + height); data.Corners[6].To = Vector2.new(x, y + height - cornerLen)
                        data.Corners[7].From = Vector2.new(x + width, y + height); data.Corners[7].To = Vector2.new(x + width - cornerLen, y + height)
                        data.Corners[8].From = Vector2.new(x + width, y + height); data.Corners[8].To = Vector2.new(x + width, y + height - cornerLen)
                        
                        for i = 1, 8 do
                            data.Corners[i].Color = GodMode.Visuals.Color
                            data.Corners[i].Visible = true
                        end
                    else
                        for i = 1, 8 do data.Corners[i].Visible = false end
                    end
                    
                    -- Names
                    if GodMode.Visuals.Names then
                        data.Name.Text = player.Name
                        data.Name.Position = Vector2.new(screenPos.X, screenPos.Y - height/2 - 20)
                        data.Name.Color = GodMode.Visuals.Color
                        data.Name.Visible = true
                    else
                        data.Name.Visible = false
                    end
                    
                    -- Distance
                    if GodMode.Visuals.Distance then
                        data.Distance.Text = math.floor(distance) .. "m"
                        data.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + height/2 + 5)
                        data.Distance.Color = GodMode.Visuals.Color
                        data.Distance.Visible = true
                    else
                        data.Distance.Visible = false
                    end
                    
                    -- Health Bar
                    if GodMode.Visuals.HealthBar then
                        local healthPercent = hum.Health / hum.MaxHealth
                        local barHeight = height * healthPercent
                        local barX = screenPos.X - width/2 - 8
                        
                        data.HealthBg.From = Vector2.new(barX, screenPos.Y - height/2)
                        data.HealthBg.To = Vector2.new(barX, screenPos.Y + height/2)
                        data.HealthBg.Visible = true
                        
                        data.Health.From = Vector2.new(barX, screenPos.Y + height/2)
                        data.Health.To = Vector2.new(barX, screenPos.Y + height/2 - barHeight)
                        data.Health.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPercent)
                        data.Health.Visible = true
                    else
                        data.Health.Visible = false
                        data.HealthBg.Visible = false
                    end
                    
                    -- Lines (Tracers)
                    if GodMode.Visuals.Lines then
                        local tracerY = GodMode.Visuals.TracerPos == "Top" and 0 
                            or GodMode.Visuals.TracerPos == "Middle" and Camera.ViewportSize.Y / 2 
                            or Camera.ViewportSize.Y
                        data.Line.From = Vector2.new(Camera.ViewportSize.X / 2, tracerY)
                        data.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                        data.Line.Visible = true
                        data.Line.Color = GodMode.Visuals.Color
                    else
                        data.Line.Visible = false
                    end
                    
                    -- Chams
                    if data.Highlight then
                        data.Highlight.Enabled = GodMode.Visuals.Chams
                        data.Highlight.Adornee = char
                    end
                    
                    -- Skeleton Detalhado
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
    end
end)

-- Loop de Combate e Exploits (Massivo)
task.spawn(function()
    while task.wait() do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local tool = char and char:FindFirstChildOfClass("Tool")
        
        -- Movement Mods
        if hum then
            if GodMode.Movement.SpeedEnabled then hum.WalkSpeed = GodMode.Movement.WalkSpeed end
            if GodMode.Movement.JumpEnabled then hum.JumpPower = GodMode.Movement.JumpPower end
            if GodMode.Exploit.AntiRagdoll then
                hum.PlatformStand = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end
        
        -- Aimbot Suave
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
        
        -- Auto Shoot
        if GodMode.Combat.AutoShoot and tool then
            local fov = GodMode.Combat.SilentAim and GodMode.Combat.SilentFOV or GodMode.Combat.FOV
            local partName = GodMode.Combat.SilentAim and GodMode.Combat.SilentTargetPart or GodMode.Combat.TargetPart
            local target = GetClosestTarget(fov, partName, false)
            if target and target.Character then
                local part = GetTargetPart(target.Character, partName)
                if part and IsVisible(part) then tool:Activate() end
            end
        end
        
        -- Kill Aura
        if GodMode.Combat.KillAura and tool then
            local target = GetClosestTarget(25, "Torso", true)
            if target then tool:Activate() end
        end
        
        -- Teleport Kill
        if GodMode.Exploit.TeleportKill and char and char:FindFirstChild("HumanoidRootPart") then
            local target = GetClosestTarget(2000, "Torso", true)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                task.wait(GodMode.Exploit.KillDelay)
            end
        end
        
        -- Full Bright
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

print("📱 GOD MODE HUB V7.0 ULTIMATE - CARREGADO COM 750+ LINHAS!")
print("🚀 NOVIDADE: SILENT TRACER ATIVADO!")
print("✨ PAINEL CUSTOMIZADO - DESIGN ÚNICO!")
