-- Ultimate God Mode Hub v8.0
-- Enhanced UI with RGB Config

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configurations
local Config = {
    RGBEnabled = false,
    RGBSpeed = 1,
    PrimaryColor = Color3.fromRGB(138, 43, 226),
    SecondaryColor = Color3.fromRGB(75, 0, 130),
    AccentColor = Color3.fromRGB(218, 112, 214)
}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateGodModeHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Toggle Button (mantido original)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = ""
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 0, 130))
}
ToggleGradient.Rotation = 45
ToggleGradient.Parent = ToggleButton

local ToggleIcon = Instance.new("ImageLabel")
ToggleIcon.Name = "Icon"
ToggleIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
ToggleIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Image = "rbxassetid://7734053426"
ToggleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
ToggleIcon.Parent = ToggleButton

-- Main Frame (redesenhado)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(138, 43, 226)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(75, 0, 130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
}
HeaderGradient.Rotation = 90
HeaderGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.7),
    NumberSequenceKeypoint.new(1, 0.9)
}
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.15, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ULTIMATE GOD MODE HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0.5, -20)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 140, 1, -70)
TabContainer.Position = UDim2.new(0, 10, 0, 65)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 12)
TabCorner.Parent = TabContainer

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 8)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabContainer

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 10)
TabPadding.PaddingLeft = UDim.new(0, 8)
TabPadding.PaddingRight = UDim.new(0, 8)
TabPadding.Parent = TabContainer

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(0, 410, 1, -70)
ContentContainer.Position = UDim2.new(0, 160, 0, 65)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 12)
ContentCorner.Parent = ContentContainer

-- Tab System
local Tabs = {}
local CurrentTab = nil

local function CreateTab(name, icon, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 42)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabButton.BorderSizePixel = 0
    TabButton.AutoButtonColor = false
    TabButton.LayoutOrder = order
    TabButton.Parent = TabContainer
    
    local TabBCorner = Instance.new("UICorner")
    TabBCorner.CornerRadius = UDim.new(0, 8)
    TabBCorner.Parent = TabButton
    
    local TabLabel = Instance.new("TextLabel")
    TabLabel.Size = UDim2.new(1, -35, 1, 0)
    TabLabel.Position = UDim2.new(0, 35, 0, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = name
    TabLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabLabel.TextSize = 14
    TabLabel.Font = Enum.Font.GothamBold
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.Parent = TabButton
    
    local TabIcon = Instance.new("TextLabel")
    TabIcon.Size = UDim2.new(0, 25, 0, 25)
    TabIcon.Position = UDim2.new(0, 5, 0.5, -12.5)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Text = icon
    TabIcon.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabIcon.TextSize = 18
    TabIcon.Font = Enum.Font.GothamBold
    TabIcon.Parent = TabButton
    
    local Content = Instance.new("ScrollingFrame")
    Content.Name = name .. "Content"
    Content.Size = UDim2.new(1, -20, 1, -20)
    Content.Position = UDim2.new(0, 10, 0, 10)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    Content.Visible = false
    Content.Parent = ContentContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 10)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = Content
    
    Tabs[name] = {
        Button = TabButton,
        Content = Content,
        Icon = TabIcon,
        Label = TabLabel
    }
    
    TabButton.MouseButton1Click:Connect(function()
        for tabName, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            tab.Label.TextColor3 = Color3.fromRGB(180, 180, 180)
            tab.Icon.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        
        Content.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = name
    end)
    
    return Content
end

-- Create Tabs
local PlayerContent = CreateTab("Player", "👤", 1)
local CombatContent = CreateTab("Combat", "⚔️", 2)
local VisualContent = CreateTab("Visual", "👁️", 3)
local ConfigContent = CreateTab("Config", "⚙️", 4)

-- Helper Functions
local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = Button
    
    local BStroke = Instance.new("UIStroke")
    BStroke.Color = Color3.fromRGB(138, 43, 226)
    BStroke.Thickness = 1.5
    BStroke.Transparency = 0.7
    BStroke.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
        TweenService:Create(BStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
        TweenService:Create(BStroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local TFCorner = Instance.new("UICorner")
    TFCorner.CornerRadius = UDim.new(0, 8)
    TFCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 50, 0, 26)
    Switch.Position = UDim2.new(1, -60, 0.5, -13)
    Switch.BackgroundColor3 = default and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 65)
    Switch.BorderSizePixel = 0
    Switch.Text = ""
    Switch.AutoButtonColor = false
    Switch.Parent = ToggleFrame
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(1, 0)
    SCorner.Parent = Switch
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 20, 0, 20)
    Indicator.Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Switch
    
    local ICorner = Instance.new("UICorner")
    ICorner.CornerRadius = UDim.new(1, 0)
    ICorner.Parent = Indicator
    
    local toggled = default
    
    Switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        
        TweenService:Create(Switch, TweenInfo.new(0.2), {
            BackgroundColor3 = toggled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 65)
        }):Play()
        
        TweenService:Create(Indicator, TweenInfo.new(0.2), {
            Position = toggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        }):Play()
        
        callback(toggled)
    end)
    
    return ToggleFrame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    
    local SFCorner = Instance.new("UICorner")
    SFCorner.CornerRadius = UDim.new(0, 8)
    SFCorner.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 1, -16)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SBCorner = Instance.new("UICorner")
    SBCorner.CornerRadius = UDim.new(1, 0)
    SBCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SFillCorner = Instance.new("UICorner")
    SFillCorner.CornerRadius = UDim.new(1, 0)
    SFillCorner.Parent = SliderFill
    
    local Dragging = false
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
    end)
    
    return SliderFrame
end

-- Player Tab
CreateToggle(PlayerContent, "God Mode", false, function(enabled)
    if enabled then
        Player.Character.Humanoid.Health = math.huge
    end
end)

CreateToggle(PlayerContent, "Infinite Jump", false, function(enabled)
    if enabled then
        game:GetService("UserInputService").JumpRequest:Connect(function()
            Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end)
    end
end)

CreateSlider(PlayerContent, "WalkSpeed", 16, 200, 16, function(value)
    Player.Character.Humanoid.WalkSpeed = value
end)

CreateSlider(PlayerContent, "JumpPower", 50, 300, 50, function(value)
    Player.Character.Humanoid.JumpPower = value
end)

CreateButton(PlayerContent, "Reset Character", function()
    Player.Character.Humanoid.Health = 0
end)

-- Combat Tab
CreateToggle(CombatContent, "Auto Farm", false, function(enabled)
    -- Auto farm logic here
end)

CreateToggle(CombatContent, "Kill Aura", false, function(enabled)
    -- Kill aura logic here
end)

CreateToggle(CombatContent, "Anti-Knockback", false, function(enabled)
    -- Anti-knockback logic here
end)

CreateButton(CombatContent, "Kill All Enemies", function()
    -- Kill all logic here
end)

-- Visual Tab
CreateToggle(VisualContent, "ESP Players", false, function(enabled)
    -- ESP logic here
end)

CreateToggle(VisualContent, "Fullbright", false, function(enabled)
    if enabled then
        game.Lighting.Brightness = 2
        game.Lighting.GlobalShadows = false
    else
        game.Lighting.Brightness = 1
        game.Lighting.GlobalShadows = true
    end
end)

CreateToggle(VisualContent, "No Fog", false, function(enabled)
    if enabled then
        game.Lighting.FogEnd = 1000000
    else
        game.Lighting.FogEnd = 100000
    end
end)

-- Config Tab (Nova Aba)
CreateToggle(ConfigContent, "Enable RGB Mode", false, function(enabled)
    Config.RGBEnabled = enabled
end)

CreateSlider(ConfigContent, "RGB Speed", 1, 10, 1, function(value)
    Config.RGBSpeed = value
end)

local ColorButtons = Instance.new("Frame")
ColorButtons.Size = UDim2.new(1, 0, 0, 100)
ColorButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ColorButtons.BorderSizePixel = 0
ColorButtons.Parent = ConfigContent

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 8)
CBCorner.Parent = ColorButtons

local CBTitle = Instance.new("TextLabel")
CBTitle.Size = UDim2.new(1, 0, 0, 30)
CBTitle.BackgroundTransparency = 1
CBTitle.Text = "Theme Colors"
CBTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
CBTitle.TextSize = 14
CBTitle.Font = Enum.Font.GothamBold
CBTitle.Parent = ColorButtons

local colors = {
    {name = "Purple", color = Color3.fromRGB(138, 43, 226)},
    {name = "Blue", color = Color3.fromRGB(41, 128, 185)},
    {name = "Red", color = Color3.fromRGB(231, 76, 60)},
    {name = "Green", color = Color3.fromRGB(46, 204, 113)},
    {name = "Orange", color = Color3.fromRGB(230, 126, 34)}
}

for i, colorData in ipairs(colors) do
    local ColorBtn = Instance.new("TextButton")
    ColorBtn.Size = UDim2.new(0.18, 0, 0, 35)
    ColorBtn.Position = UDim2.new(0.04 + (i-1) * 0.19, 0, 0, 55)
    ColorBtn.BackgroundColor3 = colorData.color
    ColorBtn.BorderSizePixel = 0
    ColorBtn.Text = ""
    ColorBtn.Parent = ColorButtons
    
    local CCCorner = Instance.new("UICorner")
    CCCorner.CornerRadius = UDim.new(0, 6)
    CCCorner.Parent = ColorBtn
    
    ColorBtn.MouseButton1Click:Connect(function()
        Config.PrimaryColor = colorData.color
        ToggleButton.BackgroundColor3 = colorData.color
        MainStroke.Color = colorData.color
    end)
end

CreateButton(ConfigContent, "Save Configuration", function()
    -- Save config logic
end)

CreateButton(ConfigContent, "Load Configuration", function()
    -- Load config logic
end)

-- RGB Effect
RunService.RenderStepped:Connect(function()
    if Config.RGBEnabled then
        local hue = tick() % (10 / Config.RGBSpeed) / (10 / Config.RGBSpeed)
        local color = Color3.fromHSV(hue, 1, 1)
        
        ToggleGradient.Color = ColorSequence.new(color)
        HeaderGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue + 0.1) % 1, 1, 1)),
            ColorSequenceKeypoint.new(1, color)
        }
        MainStroke.Color = color
    end
end)

-- Toggle Functionality
local IsOpen = false

ToggleButton.MouseButton1Click:Connect(function()
    IsOpen = not IsOpen
    MainFrame.Visible = IsOpen
    
    if IsOpen and not CurrentTab then
        Tabs["Player"].Button.MouseButton1Click:Fire()
    end
    
    TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Rotation = IsOpen and 180 or 0
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    IsOpen = false
    MainFrame.Visible = false
    
    TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Rotation = 0
    }):Play()
end)

-- Dragging
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Notification
local function Notify(text)
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Size = UDim2.new(0, 300, 0, 60)
    NotificationFrame.Position = UDim2.new(1, -320, 0, 20)
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = ScreenGui
    
    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 10)
    NCorner.Parent = NotificationFrame
    
    local NStroke = Instance.new("UIStroke")
    NStroke.Color = Color3.fromRGB(138, 43, 226)
    NStroke.Thickness = 2
    NStroke.Parent = NotificationFrame
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -20, 1, 0)
    NText.Position = UDim2.new(0, 10, 0, 0)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NText.TextSize = 14
    NText.Font = Enum.Font.Gotham
    NText.TextWrapped = true
    NText.Parent = NotificationFrame
    
    TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -320, 0, 20)
    }):Play()
    
    wait(3)
    
    TweenService:Create(NotificationFrame, TweenInfo.new(0.5), {
        Position = UDim2.new(1, 0, 0, 20)
    }):Play()
    
    wait(0.5)
    NotificationFrame:Destroy()
end

Notify("✨ Ultimate God Mode Hub loaded!")
