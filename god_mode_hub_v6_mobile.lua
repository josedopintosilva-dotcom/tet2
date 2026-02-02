--[[
    GOD MODE HUB - MOBILE EDITION v6.0 (ULTRA ADAPTIVE)
    Interface Moderna | Totalmente Responsiva | Glassmorphism
    
    CRÉDITOS:
    - Design & Dev: Manus AI
    - Base: Rekirts & Ruqqs
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
        AutoShoot = false,
        Smoothness = 0.15,
        FOV = 150,
        ShowFOV = true,
        TargetPart = "Head",
        TeamCheck = false,
        WallCheck = false
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
        AccentColor = Color3.fromRGB(138, 43, 226),
        SecondaryColor = Color3.fromRGB(20, 20, 30),
        TextColor = Color3.fromRGB(255, 255, 255)
    }
}

-- ====================================================================================================
-- LÓGICA DE COMBATE & ESP (MANTIDA)
-- ====================================================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 48
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
    for i = 1, 10 do
        local l = Drawing.new("Line")
        l.Thickness = 1.5
        l.Visible = false
        table.insert(data.Skeleton, l)
    end
    data.Box.Thickness = 2
    data.Name.Size = 16
    data.Name.Center = true
    data.Name.Outline = true
    data.Name.Font = 2
    data.HealthBg.Thickness = 5
    data.HealthBg.Color = Color3.new(0, 0, 0)
    data.Health.Thickness = 3
    data.Line.Thickness = 2
    ESP_Data[player] = data
end

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

-- Loops de Combate
task.spawn(function()
    while task.wait() do
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        
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

        if GodMode.Combat.AutoShoot and tool then
            local target = GetClosestTarget(false)
            if target and target.Character then
                local targetPart = GetBestTargetPart(target.Character)
                if targetPart and IsVisible(targetPart) then
                    tool:Activate()
                    local muzzle = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle")
                    if muzzle then muzzle.CFrame = CFrame.new(muzzle.Position, targetPart.Position) end
                end
            end
        end
    end
end)

-- ====================================================================================================
-- NOVA INTERFACE ULTRA ADAPTÁVEL (MOBILE)
-- ====================================================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeHubV6"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui)

-- Botão Flutuante (Design Moderno)
local FloatingButton = Instance.new("TextButton")
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Position = UDim2.new(1, -75, 0.5, -30)
FloatingButton.BackgroundColor3 = GodMode.Config.AccentColor
FloatingButton.Text = "G"
FloatingButton.TextSize = 28
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.Parent = ScreenGui
Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingButton)
FloatStroke.Color = Color3.fromRGB(255, 255, 255)
FloatStroke.Thickness = 2

-- Arrastar Botão Flutuante
local draggingFloat = false
local dragInput, dragStart, startPos
FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFloat = true
        dragStart = input.Position
        startPos = FloatingButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingFloat and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFloat = false
    end
end)

-- Painel Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Começa invisível para animação
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = GodMode.Config.SecondaryColor
MainFrame.BackgroundTransparency = 0.1
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = GodMode.Config.AccentColor
MainStroke.Thickness = 2

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "GOD MODE HUB <font color='#8A2BE2'>V6</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Header

-- Sidebar (Abas)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundTransparency = 0.8
Sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Container de Conteúdo
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -130, 1, -60)
Content.Position = UDim2.new(0, 125, 0, 55)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local TabPages = {}
local CurrentTab = nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = Content
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    TabPages[name] = {Button = btn, Page = page}
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(TabPages) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        page.Visible = true
        btn.BackgroundColor3 = GodMode.Config.AccentColor
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    if not CurrentTab then
        page.Visible = true
        btn.BackgroundColor3 = GodMode.Config.AccentColor
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = name
    end
end

local function AddToggle(tab, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Parent = TabPages[tab].Page
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = default and GodMode.Config.AccentColor or Color3.fromRGB(60, 60, 70)
    toggle.Text = ""
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggle
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and GodMode.Config.AccentColor or Color3.fromRGB(60, 60, 70)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

local function AddSlider(tab, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 65)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Parent = TabPages[tab].Page
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 12, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 45)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = GodMode.Config.AccentColor
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(1, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = sliderFill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        if max <= 1 then val = tonumber(string.format("%.2f", min + (max - min) * pos)) end
        label.Text = text .. ": " .. tostring(val)
        callback(val)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
end

local function AddButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 45)
    btn.BackgroundColor3 = GodMode.Config.AccentColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = TabPages[tab].Page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(callback)
end

-- Abrir/Fechar Painel
FloatingButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true, function() MainFrame.Visible = false end)
    else
        MainFrame.Visible = true
        local targetSize = UserInputService.TouchEnabled and UDim2.new(0, 450, 0, 300) or UDim2.new(0, 500, 0, 350)
        MainFrame:TweenSize(targetSize, "Out", "Back", 0.3, true)
    end
end)

-- ====================================================================================================
-- CONSTRUÇÃO DAS ABAS
-- ====================================================================================================
CreateTab("Combat", "⚔️")
AddToggle("Combat", "Enable Aimbot", false, function(v) GodMode.Combat.Aimbot = v end)
AddToggle("Combat", "Auto Shoot", false, function(v) GodMode.Combat.AutoShoot = v end)
AddToggle("Combat", "Magic Bullet", false, function(v) GodMode.Combat.MagicBullet = v end)
AddToggle("Combat", "Kill Aura", false, function(v) GodMode.Combat.KillAura = v end)
AddToggle("Combat", "Wall Check", false, function(v) GodMode.Combat.WallCheck = v end)
AddToggle("Combat", "Team Check", false, function(v) GodMode.Combat.TeamCheck = v end)
AddSlider("Combat", "FOV Size", 50, 800, 150, function(v) GodMode.Combat.FOV = v end)
AddButton("Combat", "🎯 ACTIVATE AIMBOT (HOLD)", function() GodMode.Combat.Active = true task.wait(0.1) end)

CreateTab("Visuals", "👁️")
AddToggle("Visuals", "Box ESP", false, function(v) GodMode.Visuals.Boxes = v end)
AddToggle("Visuals", "Names", false, function(v) GodMode.Visuals.Names = v end)
AddToggle("Visuals", "Health Bar", false, function(v) GodMode.Visuals.HealthBar = v end)
AddToggle("Visuals", "Chams", false, function(v) GodMode.Visuals.Chams = v end)
AddToggle("Visuals", "Tracers", false, function(v) GodMode.Visuals.Lines = v end)
AddSlider("Visuals", "Max Distance", 100, 2000, 1000, function(v) GodMode.Visuals.MaxDistance = v end)

CreateTab("Move", "🏃")
AddToggle("Move", "Bunny Hop", false, function(v) GodMode.Movement.Bhop = v end)
AddToggle("Move", "Infinite Jump", false, function(v) GodMode.Movement.InfJump = v end)
AddToggle("Move", "Noclip", false, function(v) GodMode.Movement.Noclip = v end)

CreateTab("Gun", "🔫")
AddToggle("Gun", "Fast Fire", false, function(v) GodMode.GunMod.FastFire = v end)
AddToggle("Gun", "Instant Reload", false, function(v) GodMode.GunMod.InstantReload = v end)
AddToggle("Gun", "No Recoil", false, function(v) GodMode.GunMod.NoRecoil = v end)

-- ====================================================================================================
-- SISTEMAS ADICIONAIS (ESP, MOVEMENT, ETC)
-- ====================================================================================================
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = GodMode.Combat.FOV
    FOVCircle.Visible = GodMode.Combat.ShowFOV
    
    for player, data in pairs(ESP_Data) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
            if onScreen and dist <= GodMode.Visuals.MaxDistance then
                local size = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y)
                local w, h = size * 0.6, size
                local x, y = pos.X - w/2, pos.Y - h/2
                
                data.Box.Visible = GodMode.Visuals.Boxes
                data.Box.Size = Vector2.new(w, h); data.Box.Position = Vector2.new(x, y); data.Box.Color = GodMode.Visuals.Color
                
                data.Name.Visible = GodMode.Visuals.Names
                data.Name.Text = player.Name; data.Name.Position = Vector2.new(pos.X, y - 20)
                
                data.Health.Visible = GodMode.Visuals.HealthBar
                data.Health.From = Vector2.new(x - 5, y + h); data.Health.To = Vector2.new(x - 5, y + h - (h * (hum.Health/hum.MaxHealth)))
                data.Health.Color = Color3.fromHSV((hum.Health/hum.MaxHealth) * 0.3, 1, 1)
                
                data.Line.Visible = GodMode.Visuals.Lines
                data.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); data.Line.To = Vector2.new(pos.X, pos.Y)
            else
                data.Box.Visible = false; data.Name.Visible = false; data.Health.Visible = false; data.Line.Visible = false
            end
        else
            data.Box.Visible = false; data.Name.Visible = false; data.Health.Visible = false; data.Line.Visible = false
        end
    end
end)

-- Gerenciamento de Jogadores
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

-- Movement
RunService.PreSimulation:Connect(function()
    if GodMode.Movement.Bhop and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
    if GodMode.Movement.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if GodMode.Movement.InfJump and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

-- Auto Deactivate Aimbot
task.spawn(function()
    while task.wait(0.1) do if not GodMode.Combat.AutoAimbot then GodMode.Combat.Active = false end end
end)

print("📱 GOD MODE HUB V6 - MOBILE ADAPTIVE LOADED!")
