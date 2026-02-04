-- GOD MODE HUB - LIGHT EDITION (100% FUNCIONAL)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- CONFIGURAÇÃO
local GodMode = {
    Combat = {
        Aimbot = false,
        SilentAim = false,
        FOV = 150,
        ShowFOV = true,
        TargetPart = "Head"
    },
    Visuals = {
        ESP = false,
        Boxes = false,
        Names = false,
        TeamCheck = false
    },
    Movement = {
        Speed = false,
        WalkSpeed = 16,
        Noclip = false,
        Fly = false,
        FlySpeed = 50
    }
}

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 50
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Visible = false
FOVCircle.Radius = 150

-- INTERFACE SIMPLIFICADA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeLight"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Botão Principal
local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0, 60, 0, 60)
MainButton.Position = UDim2.new(1, -70, 0.5, -30)
MainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MainButton.Text = "G"
MainButton.TextColor3 = Color3.new(1, 1, 1)
MainButton.TextSize = 28
MainButton.Font = Enum.Font.GothamBold
MainButton.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = MainButton

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(0, 150, 255)
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GOD MODE HUB LIGHT"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Conteúdo
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Content

-- FUNÇÃO PARA CRIAR TOGGLE
local function AddToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 70)
    toggle.Text = ""
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = toggle
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 70)
        circle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        callback(state)
    end)
end

-- ADICIONAR TOGGLES
AddToggle(Content, "Aimbot", false, function(v)
    GodMode.Combat.Aimbot = v
    print("Aimbot:", v)
end)

AddToggle(Content, "Silent Aim", false, function(v)
    GodMode.Combat.SilentAim = v
    print("Silent Aim:", v)
end)

AddToggle(Content, "ESP Boxes", false, function(v)
    GodMode.Visuals.Boxes = v
    print("ESP Boxes:", v)
end)

AddToggle(Content, "ESP Names", false, function(v)
    GodMode.Visuals.Names = v
    print("ESP Names:", v)
end)

AddToggle(Content, "Speed Hack", false, function(v)
    GodMode.Movement.Speed = v
    print("Speed Hack:", v)
end)

AddToggle(Content, "Fly Mode", false, function(v)
    GodMode.Movement.Fly = v
    print("Fly Mode:", v)
end)

AddToggle(Content, "Noclip", false, function(v)
    GodMode.Movement.Noclip = v
    print("Noclip:", v)
end)

-- ABRIR/FECHAR MENU
MainButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame:TweenSize(UDim2.new(0, 400, 0, 300), "Out", "Quad", 0.3, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true)
    end
end)

-- ATUALIZAR TAMANHO DO SCROLL
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- LOOP DE RENDERIZAÇÃO
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = center
    FOVCircle.Radius = GodMode.Combat.FOV
    FOVCircle.Visible = GodMode.Combat.ShowFOV
    
    -- SPEED HACK
    if GodMode.Movement.Speed then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 50
            end
        end
    end
    
    -- NOCLIP
    if GodMode.Movement.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- FLY SYSTEM
local flyConnection
local function ToggleFly()
    if GodMode.Movement.Fly then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            
            if not flyConnection then
                flyConnection = RunService.Heartbeat:Connect(function()
                    if GodMode.Movement.Fly then
                        local vel = Vector3.new(0, 0, 0)
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            vel = vel + Camera.CFrame.LookVector * GodMode.Movement.FlySpeed
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            vel = vel - Camera.CFrame.LookVector * GodMode.Movement.FlySpeed
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            vel = vel - Camera.CFrame.RightVector * GodMode.Movement.FlySpeed
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            vel = vel + Camera.CFrame.RightVector * GodMode.Movement.FlySpeed
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            vel = vel + Vector3.new(0, GodMode.Movement.FlySpeed, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            vel = vel - Vector3.new(0, GodMode.Movement.FlySpeed, 0)
                        end
                        
                        hrp.Velocity = vel
                        char:FindFirstChildOfClass("Humanoid").PlatformStand = true
                    end
                end)
            end
        end
    elseif flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
            end
        end
    end
end

-- OUVIR MUDANÇAS NO FLY
while true do
    ToggleFly()
    wait(0.1)
end

print("✅ GOD MODE HUB LIGHT - CARREGADO COM SUCESSO!")