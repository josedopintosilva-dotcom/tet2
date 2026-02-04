--[[
    GOD MODE HUB - NEO EDITION v8.0
    Interface Moderna Redesenhada | Todas as funcionalidades originais preservadas
    DESIGN PREMIUM - Aparência futurística e minimalista
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
-- CONFIGURAÇÃO GLOBAL (MANTIDA)
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
        ChamsColor = Color3.fromRGB(0, 255, 255),
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
        AccentColor = Color3.fromRGB(0, 200, 255),
        SecondaryColor = Color3.fromRGB(15, 15, 25),
        TextColor = Color3.fromRGB(240, 240, 240),
        MenuKey = Enum.KeyCode.RightControl,
        RainbowUI = false
    }
}

-- ====================================================================================================
-- SISTEMA DE DESENHO (MANTIDO)
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
SilentFOVCircle.Color = Color3.fromRGB(255, 50, 100)

local SilentTracerLine = Drawing.new("Line")
SilentTracerLine.Thickness = 2
SilentTracerLine.Color = Color3.fromRGB(255, 50, 100)
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
    
    for i = 1, 15 do
        local l = Drawing.new("Line")
        l.Thickness = 1.5; l.Visible = false
        table.insert(data.Skeleton, l)
    end
    
    ESP_Data[player] = data
end

-- ====================================================================================================
-- MOTOR DE COMBATE (MANTIDO)
-- ====================================================================================================
local function GetTargetPart(character, partName)
    if not character then return nil end
    if partName == "Head" then return character:FindFirstChild("Head")
    elseif partName == "Torso" then return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    elseif partName == "Legs" then return character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("LeftLeg") or character:FindFirstChild("RightLowerLeg")
    end
    return character:FindFirstChild("HumanoidRootPart")
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

local function GetClosestTarget(fov, targetPartName, ignoreFOV)
    local target = nil
    local dist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if GodMode.Combat.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            
            local part = GetTargetPart(p.Character, targetPartName)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local magToPlayer = (part.Position - Camera.CFrame.Position).Magnitude
                
                if ignoreFOV then
                    if magToPlayer < dist then
                        if IsVisible(part) then target = p; dist = magToPlayer end
                    end
                elseif onScreen then
                    local magToCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if magToCenter <= fov and magToCenter < dist then
                        if IsVisible(part) then target = p; dist = magToCenter end
                    end
                end
            end
        end
    end
    return target
end

local function RedirectShot()
    if not GodMode.Combat.SilentAim then return nil end
    local target = GetClosestTarget(GodMode.Combat.SilentFOV, GodMode.Combat.SilentTargetPart, false)
    if target and target.Character then
        local part = GetTargetPart(target.Character, GodMode.Combat.SilentTargetPart)
        if part then return part.CFrame end
    end
    return nil
end

local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, index)
    if not checkcaller() and GodMode.Combat.SilentAim and self == Mouse and (index == "Hit" or index == "Target") then
        local hit = RedirectShot()
        if hit then
            if index == "Hit" then return hit end
            if index == "Target" then return hit.Position end
        end
    end
    return oldIndex(self, index)
end)
setreadonly(mt, true)

-- ====================================================================================================
-- INTERFACE NEO EDITION (REDESENHADA)
-- ====================================================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeHubNeo"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui)

-- Botão Flutuante Neon
local FloatingButton = Instance.new("ImageButton")
FloatingButton.Size = UDim2.new(0, 70, 0, 70)
FloatingButton.Position = UDim2.new(1, -85, 0.5, -35)
FloatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FloatingButton.Image = "rbxassetid://10723451871"
FloatingButton.ImageColor3 = GodMode.Config.AccentColor
FloatingButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner", FloatingButton)
FloatCorner.CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", FloatingButton)
FloatStroke.Color = GodMode.Config.AccentColor
FloatStroke.Thickness = 3

local FloatGlow = Instance.new("ImageLabel", FloatingButton)
FloatGlow.Size = UDim2.new(1, 20, 1, 20)
FloatGlow.Position = UDim2.new(0, -10, 0, -10)
FloatGlow.BackgroundTransparency = 1
FloatGlow.Image = "rbxassetid://10723451871"
FloatGlow.ImageColor3 = GodMode.Config.AccentColor
FloatGlow.ImageTransparency = 0.7
FloatGlow.ZIndex = -1

-- Frame Principal Redesenhado
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BackgroundTransparency = 0.05
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 20)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = GodMode.Config.AccentColor
MainStroke.Thickness = 2

local MainGradient = Instance.new("UIGradient", MainFrame)
MainGradient.Rotation = 90
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
})

-- Header Futurista
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🚀 <font color='#00C8FF'>GOD MODE HUB</font> <font color='#FFFFFF'>NEO EDITION</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(0, 100, 0, 20)
Version.Position = UDim2.new(1, -120, 0.5, -10)
Version.BackgroundTransparency = 1
Version.Text = "v8.0 PREMIUM"
Version.TextColor3 = GodMode.Config.AccentColor
Version.Font = Enum.Font.GothamSemibold
Version.TextSize = 12
Version.TextXAlignment = Enum.TextXAlignment.Right
Version.Parent = Header

-- Sidebar Redesenhada
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -75)
Sidebar.Position = UDim2.new(0, 0, 0, 75)
Sidebar.BackgroundTransparency = 0.95
Sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 8)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -145, 1, -85)
Content.Position = UDim2.new(0, 140, 0, 80)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Sistema de Tabs
local TabPages = {}
local CurrentTab = nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 48)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    
    local btnPadding = Instance.new("UIPadding", btn)
    btnPadding.PaddingLeft = UDim.new(0, 15)
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 10)
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(50, 50, 70)
    btnStroke.Thickness = 1
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = Content
    
    TabPages[name] = {Button = btn, Page = page}
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(TabPages) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            t.Button.TextColor3 = Color3.fromRGB(180, 180, 200)
            t.Button.UIStroke.Color = Color3.fromRGB(50, 50, 70)
        end
        page.Visible = true
        btn.BackgroundColor3 = GodMode.Config.AccentColor
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.UIStroke.Color = Color3.fromRGB(255, 255, 255)
    end)
    
    if not CurrentTab then
        page.Visible = true
        btn.BackgroundColor3 = GodMode.Config.AccentColor
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.UIStroke.Color = Color3.fromRGB(255, 255, 255)
        CurrentTab = name
    end
    return page
end

-- Utilitários de UI Redesenhados
local function AddToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 12)
    
    local frameStroke = Instance.new("UIStroke", frame)
    frameStroke.Color = Color3.fromRGB(50, 50, 65)
    frameStroke.Thickness = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 45, 0, 25)
    toggle.Position = UDim2.new(1, -55, 0.5, -12)
    toggle.BackgroundColor3 = default and GodMode.Config.AccentColor or Color3.fromRGB(60, 60, 75)
    toggle.Text = ""
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner", toggle)
    toggleCorner.CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 19, 0, 19)
    circle.Position = default and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggle
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and GodMode.Config.AccentColor or Color3.fromRGB(60, 60, 75)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)}):Play()
        callback(state)
    end)
    
    return frame
end

local function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 12)
    
    local frameStroke = Instance.new("UIStroke", frame)
    frameStroke.Color = Color3.fromRGB(50, 50, 65)
    frameStroke.Thickness = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": <font color='" .. tostring(GodMode.Config.AccentColor:ToHex()) .. "'>" .. tostring(default) .. "</font>"
    label.RichText = true
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -30, 0, 8)
    sliderBg.Position = UDim2.new(0, 15, 0, 50)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = GodMode.Config.AccentColor
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(1, -10, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = sliderFill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local knobGlow = Instance.new("Frame", knob)
    knobGlow.Size = UDim2.new(1, 6, 1, 6)
    knobGlow.Position = UDim2.new(0, -3, 0, -3)
    knobGlow.BackgroundColor3 = GodMode.Config.AccentColor
    knobGlow.BackgroundTransparency = 0.7
    knobGlow.ZIndex = -1
    Instance.new("UICorner", knobGlow).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
   