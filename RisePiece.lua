-- Anti-Duplicate Framework Window Shield
if game:GetService("CoreGui"):FindFirstChild("Cero_Hub_RisePiece") then
    game:GetService("CoreGui").Cero_Hub_RisePiece:Destroy()
end

-- Global Configuration States
_G.autofarmNPC = false
_G.autofarmBoss = false

local Config = {
    FarmMethod = "Upper",      -- "Upper", "Lower", "Behind"
    FarmDistance = 5,          -- Bound distance via slider config
    SelectedWeapon = "Default",-- Managed dynamically by your gear choices
    MovementType = "Teleport", -- "Tween" or "Teleport"
    TweenSpeed = 300
}

-- Multi-Selection Target Arrays (Meticulously matched to Rise Piece indexes)
local TargetsSelected = {
    -- Normal Grunts Class
    ["Bandit"] = false,
    ["Clown"] = false,
    ["Clown Strong"] = false,
    ["Dark Bandit"] = false,
    ["Green Bandit"] = false,
    ["Hollow"] = false,
    ["Jujutsu Student"] = false,
    ["Sand Bandit"] = false,
    ["Zombie"] = false,

    -- Bosses Class (Updated with Steve Boss!)
    ["Bandit Boss"] = false,
    ["Buggy Boss"] = false,
    ["Ichigo Wizard Boss"] = false,
    ["Sand Bandit Boss"] = false,
    ["Shadow Boss"] = false,
    ["Steve Boss"] = false,
    ["Sukuna Boss"] = false,
    ["Vasto Lorde Boss"] = false
}

-- Game Engine Hierarchy Paths Mappings
local EnemiesFolder = workspace:WaitForChild("Mapa"):WaitForChild("Enemies")

local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local inputService = game:GetService("UserInputService")

-- Active Character Tool Inventory Scanner Core
local function getAvailableWeapons()
    local list = {}
    local char = Player.Character
    local backpack = Player:FindFirstChild("Backpack")
    
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") and not table.find(list, item.Name) then table.insert(list, item.Name) end
        end
    end
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and not table.find(list, item.Name) then table.insert(list, item.Name) end
        end
    end
    if #list == 0 then table.insert(list, "Combat") end
    return list
end

Config.SelectedWeapon = getAvailableWeapons() or "Combat"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Cero_Hub_RisePiece"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Draggable mechanical framework calculation helper
local function makeDraggable(frame, parentFrame)
    local target = parentFrame or frame
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = target.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    inputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Main Window Frame Window Panel
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 540, 0, 390)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Signature Thick Border Line Accent 
local BorderStroke = Instance.new("UIStroke")
BorderStroke.Thickness = 4
BorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BorderStroke.Parent = MainFrame
task.spawn(function()
    while task.wait() do
        BorderStroke.Color = Color3.fromHSV((tick() % 4) / 4, 0.8, 1)
    end
end)

-- Header Top Bar Panel Bar Layout
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
makeDraggable(TopBar, MainFrame)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 250, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "  Cero's Hub: Rise Piece Edition"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TopBar

-- Floating Overlay Toggle Orb Button Frame
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
FloatBtn.Text = "Cero Hub"
FloatBtn.TextColor3 = Color3.fromRGB(255, 165, 0)
FloatBtn.Font = Enum.Font.SourceSansBold
FloatBtn.TextSize = 11
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn
task.spawn(function() while task.wait() do FloatStroke.Color = BorderStroke.Color end end)
makeDraggable(FloatBtn)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    FloatBtn.Text = MainFrame.Visible and "Close" or "Cero Hub"
    FloatBtn.TextColor3 = MainFrame.Visible and Color3.fromRGB(230, 50, 50) or Color3.fromRGB(255, 165, 0)
end)

-- Left Sidebar Tabs Navigation Panel Layout
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabBtn = Instance.new("TextButton")
TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
TabBtn.Position = UDim2.new(0.05, 0, 0, 10)
TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabBtn.Text = "Main Modules"
TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabBtn.Font = Enum.Font.SourceSansBold
TabBtn.TextSize = 13
TabBtn.Parent = Sidebar
Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

-- Scrolling Panel Container Window Canvas
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -150, 1, -55)
ContentFrame.Position = UDim2.new(0, 140, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ContentFrame

ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 30)
end)

local function createDropdown(parent, labelText, currentVal, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0.75, 0)
    btn.Position = UDim2.new(0.45, 0, 0.125, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = tostring(currentVal)
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local index = 1
    for i, o in ipairs(options) do if o == currentVal then index = i end end
    btn.MouseButton1Click:Connect(function()
        index = index + 1 if index > #options then index = 1 end
        btn.Text = tostring(options[index]) callback(options[index])
    end)
end

local function createWeaponDropdown(parent, labelText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0.75, 0)
    btn.Position = UDim2.new(0.45, 0, 0.125, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = tostring(Config.SelectedWeapon)
    btn.TextColor3 = Color3.fromRGB(255, 165, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        local active = getAvailableWeapons()
        local idx = 1
        for i, w in ipairs(active) do if w == Config.SelectedWeapon then idx = i end end
        idx = idx + 1 if idx > #active then idx = 1 end
        Config.SelectedWeapon = active[idx] btn.Text = active[idx]
    end)
end

local function createDistanceSlider(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Farm Distance: " .. tostring(Config.FarmDistance) .. " studs"
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local sliderBar = Instance.new("TextButton")
    sliderBar.Size = UDim2.new(0.9, 0, 0, 6)
    sliderBar.Position = UDim2.new(0.05, 0, 0, 28)
    sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    sliderBar.Text = ""
    sliderBar.Parent = frame
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((Config.FarmDistance - 6) / 18, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)
    
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        local calculatedDistance = math.floor(6 + (percentage * 18))
        Config.FarmDistance = calculatedDistance
        lbl.Text = "Farm Distance: " .. tostring(calculatedDistance) .. " studs"
    end
    
    local slidingActive = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slidingActive = true updateSlider(input)
        end
    end)
    inputService.InputChanged:Connect(function(input)
        if slidingActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slidingActive = false
        end
    end)
end

local function createUnifiedFarmWindow(parent, panelTitle, farmGlobalKey, arrayOptionsList)
    local containerFrame = Instance.new("Frame")
    containerFrame.Size = UDim2.new(1, -5, 0, 85)
    containerFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    containerFrame.Parent = parent
    Instance.new("UICorner", containerFrame).CornerRadius = UDim.new(0, 6)
    
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(0.6, 0, 0, 22)
    descLbl.Position = UDim2.new(0, 12, 0, 4)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = panelTitle
    descLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    descLbl.Font = Enum.Font.SourceSansBold
    descLbl.TextSize = 13
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = containerFrame
    
    local subDesc = Instance.new("TextLabel")
    subDesc.Size = UDim2.new(0.6, 0, 0, 15)
    subDesc.Position = UDim2.new(0, 12, 0, 22)
    subDesc.BackgroundTransparency = 1
    subDesc.Text = "Toggle to start/stop loop targeting choices."
    subDesc.TextColor3 = Color3.fromRGB(130, 130, 135)
    subDesc.Font = Enum.Font.SourceSans
    subDesc.TextSize = 11
    subDesc.TextXAlignment = Enum.TextXAlignment.Left
    subDesc.Parent = containerFrame

    local farmToggle = Instance.new("TextButton")
    farmToggle.Size = UDim2.new(0, 45, 0, 20)
    farmToggle.Position = UDim2.new(1, -60, 0, 12)
    farmToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    farmToggle.Text = ""
    farmToggle.Parent = containerFrame
    Instance.new("UICorner", farmToggle).CornerRadius = UDim.new(0, 10)
    
    local slideBall = Instance.new("Frame")
    slideBall.Size = UDim2.new(0, 16, 0, 16)
    slideBall.Position = UDim2.new(0, 2, 0, 2)
    slideBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slideBall.Parent = farmToggle
    Instance.new("UICorner", slideBall).CornerRadius = UDim.new(1, 0)
    
    farmToggle.MouseButton1Click:Connect(function()
        _G[farmGlobalKey] = not _G[farmGlobalKey]
        farmToggle.BackgroundColor3 = _G[farmGlobalKey] and Color3.fromRGB(40, 150, 80) or Color3.fromRGB(50, 50, 55)
        slideBall.Position = _G[farmGlobalKey] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    end)

    local selectLbl = Instance.new("TextLabel")
    selectLbl.Size = UDim2.new(0.4, 0, 0, 30)
    selectLbl.Position = UDim2.new(0, 12, 0, 48)
    selectLbl.BackgroundTransparency = 1
    selectLbl.Text = "Select Target"
    selectLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    selectLbl.Font = Enum.Font.SourceSansBold
    selectLbl.TextSize = 13
    selectLbl.TextXAlignment = Enum.TextXAlignment.Left
    selectLbl.Parent = containerFrame

    local dropdownSelector = Instance.new("TextButton")
    dropdownSelector.Size = UDim2.new(0, 160, 0, 26)
    dropdownSelector.Position = UDim2.new(1, -175, 0, 50)
    dropdownSelector.BackgroundColor3 = Color3.fromRGB(32, 32, 35)
    dropdownSelector.Text = "Choose target..."
    dropdownSelector.TextColor3 = Color3.fromRGB(150, 150, 155)
    dropdownSelector.Font = Enum.Font.SourceSans
    dropdownSelector.TextSize = 13
    dropdownSelector.Parent = containerFrame
    Instance.new("UICorner", dropdownSelector).CornerRadius = UDim.new(0, 4)

local function createDropdown(parent, labelText, currentVal, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0.75, 0)
    btn.Position = UDim2.new(0.45, 0, 0.125, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = tostring(currentVal)
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local index = 1
    for i, o in ipairs(options) do if o == currentVal then index = i end end
    btn.MouseButton1Click:Connect(function()
        index = index + 1 if index > #options then index = 1 end
        btn.Text = tostring(options[index]) callback(options[index])
    end)
end

local function createWeaponDropdown(parent, labelText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0.75, 0)
    btn.Position = UDim2.new(0.45, 0, 0.125, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = tostring(Config.SelectedWeapon)
    btn.TextColor3 = Color3.fromRGB(255, 165, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        local active = getAvailableWeapons()
        local idx = 1
        for i, w in ipairs(active) do if w == Config.SelectedWeapon then idx = i end end
        idx = idx + 1 if idx > #active then idx = 1 end
        Config.SelectedWeapon = active[idx] btn.Text = active[idx]
    end)
end

local function createDistanceSlider(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Farm Distance: " .. tostring(Config.FarmDistance) .. " studs"
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local sliderBar = Instance.new("TextButton")
    sliderBar.Size = UDim2.new(0.9, 0, 0, 6)
    sliderBar.Position = UDim2.new(0.05, 0, 0, 28)
    sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    sliderBar.Text = ""
    sliderBar.Parent = frame
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((Config.FarmDistance - 6) / 18, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)
    
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        local calculatedDistance = math.floor(6 + (percentage * 18))
        Config.FarmDistance = calculatedDistance
        lbl.Text = "Farm Distance: " .. tostring(calculatedDistance) .. " studs"
    end
    
    local slidingActive = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slidingActive = true updateSlider(input)
        end
    end)
    inputService.InputChanged:Connect(function(input)
        if slidingActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slidingActive = false
        end
    end)
end

local function createUnifiedFarmWindow(parent, panelTitle, farmGlobalKey, arrayOptionsList)
    local containerFrame = Instance.new("Frame")
    containerFrame.Size = UDim2.new(1, -5, 0, 85)
    containerFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    containerFrame.Parent = parent
    Instance.new("UICorner", containerFrame).CornerRadius = UDim.new(0, 6)
    
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(0.6, 0, 0, 22)
    descLbl.Position = UDim2.new(0, 12, 0, 4)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = panelTitle
    descLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    descLbl.Font = Enum.Font.SourceSansBold
    descLbl.TextSize = 13
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = containerFrame
    
    local subDesc = Instance.new("TextLabel")
    subDesc.Size = UDim2.new(0.6, 0, 0, 15)
    subDesc.Position = UDim2.new(0, 12, 0, 22)
    subDesc.BackgroundTransparency = 1
    subDesc.Text = "Toggle to start/stop loop targeting choices."
    subDesc.TextColor3 = Color3.fromRGB(130, 130, 135)
    subDesc.Font = Enum.Font.SourceSans
    subDesc.TextSize = 11
    subDesc.TextXAlignment = Enum.TextXAlignment.Left
    subDesc.Parent = containerFrame

    local farmToggle = Instance.new("TextButton")
    farmToggle.Size = UDim2.new(0, 45, 0, 20)
    farmToggle.Position = UDim2.new(1, -60, 0, 12)
    farmToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    farmToggle.Text = ""
    farmToggle.Parent = containerFrame
    Instance.new("UICorner", farmToggle).CornerRadius = UDim.new(0, 10)
    
    local slideBall = Instance.new("Frame")
    slideBall.Size = UDim2.new(0, 16, 0, 16)
    slideBall.Position = UDim2.new(0, 2, 0, 2)
    slideBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slideBall.Parent = farmToggle
    Instance.new("UICorner", slideBall).CornerRadius = UDim.new(1, 0)
    
    farmToggle.MouseButton1Click:Connect(function()
        _G[farmGlobalKey] = not _G[farmGlobalKey]
        farmToggle.BackgroundColor3 = _G[farmGlobalKey] and Color3.fromRGB(40, 150, 80) or Color3.fromRGB(50, 50, 55)
        slideBall.Position = _G[farmGlobalKey] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    end)

    local selectLbl = Instance.new("TextLabel")
    selectLbl.Size = UDim2.new(0.4, 0, 0, 30)
    selectLbl.Position = UDim2.new(0, 12, 0, 48)
    selectLbl.BackgroundTransparency = 1
    selectLbl.Text = "Select Target"
    selectLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    selectLbl.Font = Enum.Font.SourceSansBold
    selectLbl.TextSize = 13
    selectLbl.TextXAlignment = Enum.TextXAlignment.Left
    selectLbl.Parent = containerFrame

    local dropdownSelector = Instance.new("TextButton")
    dropdownSelector.Size = UDim2.new(0, 160, 0, 26)
    dropdownSelector.Position = UDim2.new(1, -175, 0, 50)
    dropdownSelector.BackgroundColor3 = Color3.fromRGB(32, 32, 35)
    dropdownSelector.Text = "Choose target..."
    dropdownSelector.TextColor3 = Color3.fromRGB(150, 150, 155)
    dropdownSelector.Font = Enum.Font.SourceSans
    dropdownSelector.TextSize = 13
    dropdownSelector.Parent = containerFrame
    Instance.new("UICorner", dropdownSelector).CornerRadius = UDim.new(0, 4)

    local popoutMenu = Instance.new("ScrollingFrame")
    popoutMenu.Size = UDim2.new(0, 160, 0, 140)
    popoutMenu.Position = UDim2.new(1, -175, 0, 80)
    popoutMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    popoutMenu.BorderSizePixel = 1
    popoutMenu.BorderColor3 = Color3.fromRGB(45, 45, 50)
    popoutMenu.CanvasSize = UDim2.new(0, 0, 0, (#arrayOptionsList * 28) + 10)
    popoutMenu.ScrollBarThickness = 3
    popoutMenu.Visible = false
    popoutMenu.ZIndex = 10
    popoutMenu.Parent = containerFrame
    local popList = Instance.new("UIListLayout", popoutMenu)
    popList.Padding = UDim.new(0, 2)

    dropdownSelector.MouseButton1Click:Connect(function() popoutMenu.Visible = not popoutMenu.Visible end)

    for _, optName in ipairs(arrayOptionsList) do
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, -4, 0, 26)
        row.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
        row.Text = "  " .. optName
        row.TextColor3 = Color3.fromRGB(170, 170, 170)
        row.Font = Enum.Font.SourceSans
        row.TextSize = 12
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.ZIndex = 11
        row.Parent = popoutMenu
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

        row.MouseButton1Click:Connect(function()
        TargetsSelected[optName] = not TargetsSelected[optName]
        row.BackgroundColor3 = TargetsSelected[optName] and Color3.fromRGB(240, 140, 20) or Color3.fromRGB(28, 28, 30)
        row.TextColor3 = TargetsSelected[optName] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
        
        local activeCount = 0
        for _, v in ipairs(arrayOptionsList) do 
            if TargetsSelected[v] then 
                activeCount = activeCount + 1 
            end 
        end
        dropdownSelector.Text = activeCount > 0 and "(" .. activeCount .. ") Selected" or "Choose target..."
    end)
end
end

-- Render settings panel fields
createDropdown(ContentFrame, "Farming Vector Angle:", Config.FarmMethod, {"Upper", "Lower", "Behind"}, function(v) Config.FarmMethod = v end)
createWeaponDropdown(ContentFrame, "Equipped Attack Gear:")
createDropdown(ContentFrame, "Movement Vector:", Config.MovementType, {"Tween", "Teleport"}, function(v) Config.MovementType = v end)
createDropdown(ContentFrame, "Tween Velocity speed:", Config.TweenSpeed, {150, 300, 450, 600}, function(v) Config.TweenSpeed = v end)
createDistanceSlider(ContentFrame)

local divMain = Instance.new("Frame", ContentFrame)
divMain.Size = UDim2.new(1, 0, 0, 2)
divMain.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

createUnifiedFarmWindow(ContentFrame, "Start Farm Mobs", "autofarmNPC", {"Bandit", "Clown", "Clown Strong", "Dark Bandit", "Green Bandit", "Hollow", "Jujutsu Student", "Sand Bandit", "Zombie"})
createUnifiedFarmWindow(ContentFrame, "Start Farm Bosses", "autofarmBoss", {"Bandit Boss", "Buggy Boss", "Ichigo Wizard Boss", "Sand Bandit Boss", "Shadow Boss", "Steve Boss", "Sukuna Boss", "Vasto Lorde Boss"})
-- =============================================================================
-- [BOX 4: NAVIGATION MOVEMENT ENGINE & PHYSICAL WEAPON ACTUATOR]
-- =============================================================================

task.spawn(function()
    while true do
        if _G.autofarmNPC or _G.autofarmBoss then
            pcall(function()
                local char = Player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- SAFE STABLE TARGETED AUTO-EQUIP CONTROLLER (Never spams or triggers slot stutters)
local function handleStableAutoEquip(character)
    task.wait(1.2) -- Safe interval for tools to load cleanly into backpack
    if (_G.autofarmNPC or _G.autofarmBoss) and Config.SelectedWeapon ~= "Equip a weapon!" then
        pcall(function()
            local backpack = Player:WaitForChild("Backpack", 5)
            if backpack then
                local targetWeapon = backpack:FindFirstChild(Config.SelectedWeapon)
                if targetWeapon then
                    targetWeapon.Parent = character
                    task.wait(0.15)
                end
            end
        end)
    end
end

Player.CharacterAdded:Connect(handleStableAutoEquip)
if Player.Character then task.spawn(handleStableAutoEquip, Player.Character) end

-- Background Thread: Native Physical Click Actuator 
task.spawn(function()
    while true do
        if _G.autofarmNPC or _G.autofarmBoss then
            pcall(function()
                local char = Player.Character
                if char and Config.SelectedWeapon ~= "Equip a weapon!" then
                    local currentTool = char:FindFirstChild(Config.SelectedWeapon)
                    if currentTool and currentTool:IsA("Tool") then
                        currentTool:Activate()
                    end
                end
            end)
        end
        task.wait(0.15)
    end
end)

local function getFarmingCFrame(targetHrp)
    local d = Config.FarmDistance
    if Config.FarmMethod == "Upper" then
        return targetHrp.CFrame * CFrame.new(0, d, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    elseif Config.FarmMethod == "Lower" then
        return targetHrp.CFrame * CFrame.new(0, -d, 0) * CFrame.Angles(math.rad(90), 0, 0)
    else
        return targetHrp.CFrame * CFrame.new(0, 0, d)
    end
end

local function moveToTarget(hrp, targetCFrame)
    if Config.MovementType == "Teleport" then
        hrp.CFrame = targetCFrame
    else
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = dist / math.max(Config.TweenSpeed, 50)
        local tInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Persistent Search Scraper Engine
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.autofarmNPC or _G.autofarmBoss then
            pcall(function()
                local char = Player.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    for _, entity in pairs(EnemiesFolder:GetChildren()) do
                        if not _G.autofarmNPC and not _G.autofarmBoss then break end
                        
                        if entity:IsA("Model") and TargetsSelected[entity.Name] == true then
                            local isBoss = string.find(string.lower(entity.Name), "boss") ~= nil
                            local allowedToFarm = false
                            
                            if isBoss and _G.autofarmBoss then allowedToFarm = true
                            elseif not isBoss and _G.autofarmNPC then allowedToFarm = true end
                            
                            if allowedToFarm then
                                local enemyHrp = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart
                                local enemyHum = entity:FindFirstChildOfClass("Humanoid")
                                
                                if enemyHrp and enemyHum and enemyHum.Health > 0 and entity.Parent then
                                    moveToTarget(hrp, getFarmingCFrame(enemyHrp))
                                    task.wait(0.02)
                                    
                                    while (_G.autofarmNPC or _G.autofarmBoss) and enemyHum.Health > 0 and entity.Parent and humanoid.Health > 0 do
                                        hrp.CFrame = getFarmingCFrame(enemyHrp)
                                        task.wait()
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

print("Cero's Hub: Rise Piece Edition successfully initialized!")
