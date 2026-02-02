--[[
    GOD MODE HUB - MOBILE EDITION v6.5 FIXED CAM
    Interface Moderna | Sub-Abas | Silent Aim SEM CONGELAR CÂMERA
    
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
local Mouse = LocalPlayer:GetMouse()

-- ====================================================================================================
-- CONFIGURAÇÃO GLOBAL
-- ====================================================================================================
local GodMode = {
    Combat = {
        -- Aimbot
        Aimbot = false,
        AutoAimbot = false,
        Active = false,
        Smoothness = 0.15,
        FOV = 150,
        ShowFOV = true,
        TargetPart = "Head",
        
        -- Silent Aim (UNIVERSAL)
        SilentAim = false,
        SilentFOV = 200,
        ShowSilentFOV = true,
        SilentTargetPart = "Head",
        
        -- Others
        AutoShoot = false,
        MagicBullet = false,
        KillAura = false,
        WallCheck = false,
        TeamCheck = false
    },
    Visuals = {
        Boxes = false, CornerBoxes = false, Skeletons = false, Lines = false,
        TracerPos = "Bottom", Names = false, HealthBar = false, Chams = false,
        TeamCheck = false, Color = Color3.fromRGB(0, 255, 150), MaxDistance = 1000
    },
    Movement = { Bhop = false, InfJump = false, Noclip = false },
    Exploit = { TeleportKill = false, KillDelay = 0.5 },
    GunMod = { FastFire = false, InstantReload = false, NoRecoil = false },
    Config = { AccentColor = Color3.fromRGB(138, 43, 226), SecondaryColor = Color3.fromRGB(20, 20, 30), TextColor = Color3.fromRGB(255, 255, 255) }
}

-- ====================================================================================================
-- UTILITÁRIOS DE DESENHO
-- ====================================================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2; FOVCircle.NumSides = 48; FOVCircle.Filled = false; FOVCircle.Visible = false; FOVCircle.Color = GodMode.Config.AccentColor

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = 2; SilentFOVCircle.NumSides = 48; SilentFOVCircle.Filled = false; SilentFOVCircle.Visible = false; SilentFOVCircle.Color = Color3.fromRGB(255, 50, 50)

local ESP_Data = {}

local function RemoveESP(player)
    if ESP_Data[player] then
        local data = ESP_Data[player]
        pcall(function()
            data.Box:Remove(); data.Name:Remove(); data.Health:Remove(); data.HealthBg:Remove(); data.Line:Remove()
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
        Box = Drawing.new("Square"), Name = Drawing.new("Text"), Health = Drawing.new("Line"),
        HealthBg = Drawing.new("Line"), Line = Drawing.new("Line"), Corners = {}, Skeleton = {}, Highlight = nil
    }
    for i = 1, 8 do local l = Drawing.new("Line") l.Thickness = 2; l.Visible = false; table.insert(data.Corners, l) end
    for i = 1, 10 do local l = Drawing.new("Line") l.Thickness = 1.5; l.Visible = false; table.insert(data.Skeleton, l) end
    data.Box.Thickness = 2; data.Name.Size = 16; data.Name.Center = true; data.Name.Outline = true; data.Name.Font = 2
    data.HealthBg.Thickness = 5; data.HealthBg.Color = Color3.new(0, 0, 0); data.Health.Thickness = 3; data.Line.Thickness = 2
    ESP_Data[player] = data
end

-- ====================================================================================================
-- MOTOR DE COMBATE (CORRIGIDO)
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

-- Hooking de Metatable (CORRIGIDO PARA NÃO TRAVAR CÂMERA)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = newcclosure(function(self, index)
    -- Só intercepta se for o Mouse e o Silent Aim estiver ligado
    if not checkcaller() and GodMode.Combat.SilentAim and self == Mouse and (index == "Hit" or index == "Target") then
        local target = GetClosestTarget(GodMode.Combat.SilentFOV, GodMode.Combat.SilentTargetPart, false)
        if target and target.Character then
            local part = GetTargetPart(target.Character, GodMode.Combat.SilentTargetPart)
            if part then
                if index == "Hit" then return part.CFrame end
                if index == "Target" then return part end
            end
        end
    end
    return oldIndex(self, index)
end)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and GodMode.Combat.SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local target = GetClosestTarget(GodMode.Combat.SilentFOV, GodMode.Combat.SilentTargetPart, false)
        if target and target.Character then
            local part = GetTargetPart(target.Character, GodMode.Combat.SilentTargetPart)
            if part then
                if method == "FindPartOnRayWithIgnoreList" then
                    args[1] = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                    return oldNamecall(self, unpack(args))
                elseif method == "Raycast" then
                    args[2] = (part.Position - args[1]).Unit * 1000
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Lógica de Redirecionamento Físico (Muzzle) - SEM MEXER NA CÂMERA
RunService.Heartbeat:Connect(function()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local muzzle = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle")
    if not muzzle then return end

    if GodMode.Combat.SilentAim then
        local target = GetClosestTarget(GodMode.Combat.SilentFOV, GodMode.Combat.SilentTargetPart, false)
        if target and target.Character then
            local part = GetTargetPart(target.Character, GodMode.Combat.SilentTargetPart)
            if part then muzzle.CFrame = CFrame.new(muzzle.Position, part.Position) end
        end
    elseif GodMode.Combat.MagicBullet then
        local target = GetClosestTarget(GodMode.Combat.FOV, GodMode.Combat.TargetPart, false)
        if target and target.Character then
            local part = GetTargetPart(target.Character, GodMode.Combat.TargetPart)
            if part then muzzle.CFrame = CFrame.new(muzzle.Position, part.Position) end
        end
    end
end)

-- Loop de Ações (Aimbot e AutoShoot)
task.spawn(function()
    while task.wait() do
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        
        -- Aimbot (Único que move a câmera)
        if GodMode.Combat.Aimbot and GodMode.Combat.Active then
            local target = GetClosestTarget(GodMode.Combat.FOV, GodMode.Combat.TargetPart, false)
            if target and target.Character then
                local part = GetTargetPart(target.Character, GodMode.Combat.TargetPart)
                if part then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), GodMode.Combat.Smoothness) end
            end
        end

        -- Auto Shoot
        if GodMode.Combat.AutoShoot and tool then
            local target = GetClosestTarget(GodMode.Combat.FOV, GodMode.Combat.TargetPart, false)
            if target and target.Character then
                local part = GetTargetPart(target.Character, GodMode.Combat.TargetPart)
                if part and IsVisible(part) then tool:Activate() end
            end
        end
        
        -- Kill Aura
        if GodMode.Combat.KillAura and tool then
            local target = GetClosestTarget(20, "Torso", true)
            if target then tool:Activate() end
        end
    end
end)

-- ====================================================================================================
-- INTERFACE MOBILE V6.5 (SUB-ABAS)
-- ====================================================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodModeHubV6_5"
ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui)

local FloatingButton = Instance.new("TextButton")
FloatingButton.Size = UDim2.new(0, 60, 0, 60); FloatingButton.Position = UDim2.new(1, -75, 0.5, -30)
FloatingButton.BackgroundColor3 = GodMode.Config.AccentColor; FloatingButton.Text = "G"; FloatingButton.TextSize = 28
FloatingButton.Font = Enum.Font.GothamBold; FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255); FloatingButton.Parent = ScreenGui
Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingButton); FloatStroke.Color = Color3.fromRGB(255, 255, 255); FloatStroke.Thickness = 2

-- Arrastar Botão Flutuante
local draggingFloat = false; local dragStart, startPos
FloatingButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingFloat = true; dragStart = input.Position; startPos = FloatingButton.Position end end)
UserInputService.InputChanged:Connect(function(input) if draggingFloat and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingFloat = false end end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = GodMode.Config.SecondaryColor; MainFrame.BackgroundTransparency = 0.1; MainFrame.ClipsDescendants = true; MainFrame.Visible = false; MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = GodMode.Config.AccentColor; MainStroke.Thickness = 2

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50); Header.BackgroundTransparency = 1; Header.Parent = MainFrame
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1; Title.Text = "GOD MODE HUB <font color='#8A2BE2'>V6.5 FIXED</font>"
Title.RichText = true; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 18; Title.Parent = Header

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -50); Sidebar.Position = UDim2.new(0, 0, 0, 50); Sidebar.BackgroundTransparency = 0.8; Sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0); Sidebar.Parent = MainFrame
local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 5); SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -130, 1, -60); Content.Position = UDim2.new(0, 125, 0, 55); Content.BackgroundTransparency = 1; Content.Parent = MainFrame

local TabPages = {}
local CurrentTab = nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false; page.Parent = Content
    TabPages[name] = {Button = btn, Page = page}
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(TabPages) do t.Page.Visible = false; t.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50); t.Button.TextColor3 = Color3.fromRGB(200, 200, 200) end
        page.Visible = true; btn.BackgroundColor3 = GodMode.Config.AccentColor; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    if not CurrentTab then page.Visible = true; btn.BackgroundColor3 = GodMode.Config.AccentColor; btn.TextColor3 = Color3.fromRGB(255, 255, 255); CurrentTab = name end
    return page
end

-- Utilitários de UI
local function AddToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 45); frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40); frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.BackgroundTransparency = 1; label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230); label.Font = Enum.Font.GothamSemibold; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = frame
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20); toggle.Position = UDim2.new(1, -50, 0.5, -10); toggle.BackgroundColor3 = default and GodMode.Config.AccentColor or Color3.fromRGB(60, 60, 70); toggle.Text = ""; toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16); circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); circle.Parent = toggle
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and GodMode.Config.AccentColor or Color3.fromRGB(60, 60, 70)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 65); frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40); frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 30); label.Position = UDim2.new(0, 12, 0, 5); label.BackgroundTransparency = 1; label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(230, 230, 230); label.Font = Enum.Font.GothamSemibold; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = frame
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6); sliderBg.Position = UDim2.new(0, 12, 0, 45); sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60); sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); sliderFill.BackgroundColor3 = GodMode.Config.AccentColor; sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(1, -8, 0.5, -8); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.Parent = sliderFill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        if max <= 1 then val = tonumber(string.format("%.2f", min + (max - min) * pos)) end
        label.Text = text .. ": " .. tostring(val); callback(val)
    end
    knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
end

local function AddSelector(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 45); frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40); frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.BackgroundTransparency = 1; label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230); label.Font = Enum.Font.GothamSemibold; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = frame
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 30); btn.Position = UDim2.new(1, -110, 0.5, -15); btn.BackgroundColor3 = GodMode.Config.AccentColor; btn.Text = default; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local currentIdx = 1
    for i, opt in ipairs(options) do if opt == default then currentIdx = i end end
    btn.MouseButton1Click:Connect(function()
        currentIdx = currentIdx + 1; if currentIdx > #options then currentIdx = 1 end
        btn.Text = options[currentIdx]; callback(options[currentIdx])
    end)
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 45); btn.BackgroundColor3 = GodMode.Config.AccentColor; btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10); btn.MouseButton1Click:Connect(callback)
end

local function CreateScroll(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2; scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.Parent = parent
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) end)
    return scroll
end

-- ====================================================================================================
-- CONSTRUÇÃO DA ABA COMBAT (SUB-ABAS)
-- ====================================================================================================
local CombatPage = CreateTab("Combat", "⚔️")
local CombatSubMenu = Instance.new("Frame")
CombatSubMenu.Size = UDim2.new(1, 0, 0, 40); CombatSubMenu.BackgroundTransparency = 1; CombatSubMenu.Parent = CombatPage
local CombatSubLayout = Instance.new("UIListLayout", CombatSubMenu); CombatSubLayout.FillDirection = Enum.FillDirection.Horizontal; CombatSubLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; CombatSubLayout.Padding = UDim.new(0, 10)

local AimbotSubPage = CreateScroll(CombatPage)
AimbotSubPage.Position = UDim2.new(0, 0, 0, 45); AimbotSubPage.Size = UDim2.new(1, 0, 1, -45); AimbotSubPage.Visible = true

local SilentSubPage = CreateScroll(CombatPage)
SilentSubPage.Position = UDim2.new(0, 0, 0, 45); SilentSubPage.Size = UDim2.new(1, 0, 1, -45); SilentSubPage.Visible = false

local function CreateSubBtn(text, active)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 1, 0); btn.BackgroundColor3 = active and GodMode.Config.AccentColor or Color3.fromRGB(40, 40, 50); btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.Parent = CombatSubMenu
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local AimbotBtn = CreateSubBtn("AIMBOT", true)
local SilentBtn = CreateSubBtn("SILENT AIM", false)

AimbotBtn.MouseButton1Click:Connect(function()
    AimbotSubPage.Visible = true; SilentSubPage.Visible = false
    AimbotBtn.BackgroundColor3 = GodMode.Config.AccentColor; SilentBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
end)

SilentBtn.MouseButton1Click:Connect(function()
    AimbotSubPage.Visible = false; SilentSubPage.Visible = true
    SilentBtn.BackgroundColor3 = GodMode.Config.AccentColor; AimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
end)

-- Conteúdo Aimbot
AddToggle(AimbotSubPage, "Enable Aimbot", false, function(v) GodMode.Combat.Aimbot = v end)
AddToggle(AimbotSubPage, "Auto Lock (Touch)", false, function(v) GodMode.Combat.AutoAimbot = v end)
AddSlider(AimbotSubPage, "Smoothness", 0.01, 1, 0.15, function(v) GodMode.Combat.Smoothness = v end)
AddSlider(AimbotSubPage, "Aimbot FOV", 50, 800, 150, function(v) GodMode.Combat.FOV = v end)
AddToggle(AimbotSubPage, "Show Aimbot FOV", true, function(v) GodMode.Combat.ShowFOV = v end)
AddSelector(AimbotSubPage, "Aimbot Target", {"Head", "Torso", "Legs"}, "Head", function(v) GodMode.Combat.TargetPart = v end)
AddToggle(AimbotSubPage, "Auto Shoot", false, function(v) GodMode.Combat.AutoShoot = v end)
AddToggle(AimbotSubPage, "Wall Check", false, function(v) GodMode.Combat.WallCheck = v end)
AddToggle(AimbotSubPage, "Team Check", false, function(v) GodMode.Combat.TeamCheck = v end)
AddButton(AimbotSubPage, "🎯 ACTIVATE AIMBOT (HOLD)", function() GodMode.Combat.Active = true task.wait(0.1) end)

-- Conteúdo Silent Aim
AddToggle(SilentSubPage, "Enable Silent Aim", false, function(v) GodMode.Combat.SilentAim = v end)
AddSlider(SilentSubPage, "Silent FOV", 50, 800, 200, function(v) GodMode.Combat.SilentFOV = v end)
AddToggle(SilentSubPage, "Show Silent FOV", true, function(v) GodMode.Combat.ShowSilentFOV = v end)
AddSelector(SilentSubPage, "Silent Target", {"Head", "Torso", "Legs"}, "Head", function(v) GodMode.Combat.SilentTargetPart = v end)
AddToggle(SilentSubPage, "Magic Bullet", false, function(v) GodMode.Combat.MagicBullet = v end)
AddToggle(SilentSubPage, "Kill Aura", false, function(v) GodMode.Combat.KillAura = v end)

-- Outras Abas
local VisualsPage = CreateScroll(CreateTab("Visuals", "👁️"))
AddToggle(VisualsPage, "Box ESP", false, function(v) GodMode.Visuals.Boxes = v end)
AddToggle(VisualsPage, "Corner Boxes", false, function(v) GodMode.Visuals.CornerBoxes = v end)
AddToggle(VisualsPage, "Skeleton", false, function(v) GodMode.Visuals.Skeletons = v end)
AddToggle(VisualsPage, "Names", false, function(v) GodMode.Visuals.Names = v end)
AddToggle(VisualsPage, "Health Bar", false, function(v) GodMode.Visuals.HealthBar = v end)
AddToggle(VisualsPage, "Chams", false, function(v) GodMode.Visuals.Chams = v end)
AddToggle(VisualsPage, "Tracers", false, function(v) GodMode.Visuals.Lines = v end)
AddSelector(VisualsPage, "Tracer Position", {"Bottom", "Top"}, "Bottom", function(v) GodMode.Visuals.TracerPos = v end)
AddToggle(VisualsPage, "Team Check", false, function(v) GodMode.Visuals.TeamCheck = v end)
AddSlider(VisualsPage, "Max Distance", 100, 2000, 1000, function(v) GodMode.Visuals.MaxDistance = v end)

local MovePage = CreateScroll(CreateTab("Move", "🏃"))
AddToggle(MovePage, "Bunny Hop", false, function(v) GodMode.Movement.Bhop = v end)
AddToggle(MovePage, "Infinite Jump", false, function(v) GodMode.Movement.InfJump = v end)
AddToggle(MovePage, "Noclip", false, function(v) GodMode.Movement.Noclip = v end)

local GunPage = CreateScroll(CreateTab("Gun", "🔫"))
AddToggle(GunPage, "Fast Fire", false, function(v) GodMode.GunMod.FastFire = v end)
AddToggle(GunPage, "Instant Reload", false, function(v) GodMode.GunMod.InstantReload = v end)
AddToggle(GunPage, "No Recoil", false, function(v) GodMode.GunMod.NoRecoil = v end)

local ExploitPage = CreateScroll(CreateTab("Exploit", "💀"))
AddToggle(ExploitPage, "Teleport Kill", false, function(v) GodMode.Exploit.TeleportKill = v end)
AddSlider(ExploitPage, "Kill Delay", 0.1, 2, 0.5, function(v) GodMode.Exploit.KillDelay = v end)

FloatingButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible then MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true, function() MainFrame.Visible = false end)
    else MainFrame.Visible = true; local targetSize = UserInputService.TouchEnabled and UDim2.new(0, 450, 0, 300) or UDim2.new(0, 500, 0, 350); MainFrame:TweenSize(targetSize, "Out", "Back", 0.3, true) end
end)

-- ====================================================================================================
-- SISTEMAS DE RENDERIZAÇÃO
-- ====================================================================================================
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = center; FOVCircle.Radius = GodMode.Combat.FOV; FOVCircle.Visible = GodMode.Combat.ShowFOV
    SilentFOVCircle.Position = center; SilentFOVCircle.Radius = GodMode.Combat.SilentFOV; SilentFOVCircle.Visible = GodMode.Combat.ShowSilentFOV
    
    for player, data in pairs(ESP_Data) do
        local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
        local isAlly = (player.Team == LocalPlayer.Team); local shouldShow = true
        if GodMode.Visuals.TeamCheck and isAlly then shouldShow = false end

        if shouldShow and char and hrp and hum and hum.Health > 0 then
            local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
            if dist <= GodMode.Visuals.MaxDistance then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local size = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y)
                    local w, h = size * 0.6, size; local x, y = pos.X - w/2, pos.Y - h/2
                    
                    if GodMode.Visuals.Chams then
                        if not data.Highlight then data.Highlight = Instance.new("Highlight") data.Highlight.Parent = char end
                        data.Highlight.FillColor = GodMode.Visuals.Color; data.Highlight.OutlineColor = Color3.new(1, 1, 1); data.Highlight.FillTransparency = 0.5; data.Highlight.Enabled = true
                    elseif data.Highlight then data.Highlight.Enabled = false end

                    data.Box.Visible = GodMode.Visuals.Boxes; data.Box.Size = Vector2.new(w, h); data.Box.Position = Vector2.new(x, y); data.Box.Color = GodMode.Visuals.Color
                    
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
                    
                    data.Name.Visible = GodMode.Visuals.Names; data.Name.Text = string.format("%s\n[%dm]", player.Name, math.floor(dist)); data.Name.Position = Vector2.new(pos.X, y - 35); data.Name.Color = Color3.new(1, 1, 1)
                    
                    if GodMode.Visuals.HealthBar then
                        local healthPercent = hum.Health / hum.MaxHealth; local barHeight = h * healthPercent
                        data.HealthBg.Visible = true; data.HealthBg.From = Vector2.new(x - 8, y + h); data.HealthBg.To = Vector2.new(x - 8, y)
                        data.Health.Visible = true; data.Health.From = Vector2.new(x - 8, y + h); data.Health.To = Vector2.new(x - 8, y + h - barHeight); data.Health.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
                    else data.Health.Visible = false; data.HealthBg.Visible = false end
                    
                    data.Line.Visible = GodMode.Visuals.Lines
                    local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    if GodMode.Visuals.TracerPos == "Top" then startPos = Vector2.new(Camera.ViewportSize.X / 2, 0) end
                    data.Line.From = startPos; data.Line.To = Vector2.new(pos.X, pos.Y); data.Line.Color = GodMode.Visuals.Color
                    
                    if GodMode.Visuals.Skeletons then
                        local bones = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}
                        for i, bone in ipairs(bones) do
                            local p1 = char:FindFirstChild(bone[1]); local p2 = char:FindFirstChild(bone[2])
                            if p1 and p2 then
                                local pos1 = Camera:WorldToViewportPoint(p1.Position); local pos2 = Camera:WorldToViewportPoint(p2.Position)
                                data.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y); data.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y); data.Skeleton[i].Color = GodMode.Visuals.Color; data.Skeleton[i].Visible = true
                            elseif i <= 10 then data.Skeleton[i].Visible = false end
                        end
                    else for _, line in pairs(data.Skeleton) do line.Visible = false end end
                else
                    for i=1,8 do data.Corners[i].Visible = false end; for _, line in pairs(data.Skeleton) do line.Visible = false end
                    data.Box.Visible = false; data.Name.Visible = false; data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
                end
            else
                for i=1,8 do data.Corners[i].Visible = false end; for _, line in pairs(data.Skeleton) do line.Visible = false end
                data.Box.Visible = false; data.Name.Visible = false; data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
            end
        else
            for i=1,8 do data.Corners[i].Visible = false end; for _, line in pairs(data.Skeleton) do line.Visible = false end
            data.Box.Visible = false; data.Name.Visible = false; data.Health.Visible = false; data.HealthBg.Visible = false; data.Line.Visible = false
            if data.Highlight then data.Highlight.Enabled = false end
        end
    end
end)

-- Gun Mod Loop
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

-- Teleport Kill Loop
task.spawn(function()
    while task.wait() do
        if GodMode.Exploit.TeleportKill then
            local target = GetClosestTarget(999, "Torso", true)
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

Players.PlayerAdded:Connect(CreateESP); Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

RunService.PreSimulation:Connect(function()
    if GodMode.Movement.Bhop and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
    if GodMode.Movement.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)
UserInputService.JumpRequest:Connect(function() if GodMode.Movement.InfJump and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end end)

task.spawn(function() while task.wait(0.1) do if not GodMode.Combat.AutoAimbot then GodMode.Combat.Active = false end end end)

print("📱 GOD MODE HUB V6.5 FIXED - CAMERA BUG RESOLVED!")
