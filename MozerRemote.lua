-- ===================================================
-- 🧭 MOZER TRIGGER MONITOR
-- ⚡ Detects ANY path that gets triggered during gameplay
-- 📋 Copy path with one click
-- 🟢 ON/OFF button
-- ===================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- ===================================================
-- 📦 VARIABLES
-- ===================================================
local monitoring = false
local triggeredPaths = {}
local pathHistory = {}
local scrollFrame = nil
local listLayout = nil

local COLOR_ON = Color3.fromRGB(0, 200, 0)
local COLOR_OFF = Color3.fromRGB(80, 80, 80)

-- ===================================================
-- 🖥️ CREATE UI
-- ===================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozerTriggerMonitor"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = plr:WaitForChild("PlayerGui")

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 480)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Mozer • Trigger Monitor"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 17
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -48, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.Parent = TitleBar

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 65, 0, 65)
MiniBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MiniBtn.Text = "M"
MiniBtn.TextColor3 = Color3.fromRGB(255, 120, 0)
MiniBtn.Font = Enum.Font.FredokaOne
MiniBtn.TextSize = 34
MiniBtn.Visible = false
MiniBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 14)

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 48)
TabBar.Position = UDim2.new(0, 0, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tab1 = Instance.new("TextButton")
Tab1.Size = UDim2.new(0.5, -5, 1, 0)
Tab1.Position = UDim2.new(0, 10, 0, 0)
Tab1.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
Tab1.Text = "🎮 Monitor"
Tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1.Font = Enum.Font.GothamBold
Tab1.TextSize = 14
Tab1.Parent = TabBar
Instance.new("UICorner", Tab1).CornerRadius = UDim.new(0, 10)

local Tab2 = Instance.new("TextButton")
Tab2.Size = UDim2.new(0.5, -5, 1, 0)
Tab2.Position = UDim2.new(0.5, 5, 0, 0)
Tab2.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Tab2.Text = "📋 Captured Paths"
Tab2.TextColor3 = Color3.fromRGB(200, 200, 200)
Tab2.Font = Enum.Font.GothamBold
Tab2.TextSize = 14
Tab2.Parent = TabBar
Instance.new("UICorner", Tab2).CornerRadius = UDim.new(0, 10)

-- ===================================================
-- TAB 1: MONITOR (ON/OFF)
-- ===================================================
local Tab1Content = Instance.new("Frame")
Tab1Content.Size = UDim2.new(1, -20, 1, -110)
Tab1Content.Position = UDim2.new(0, 10, 0, 105)
Tab1Content.BackgroundTransparency = 1
Tab1Content.Parent = MainFrame

local OnOffBtn = Instance.new("TextButton")
OnOffBtn.Size = UDim2.new(0.4, 0, 0, 60)
OnOffBtn.Position = UDim2.new(0.3, 0, 0.1, 0)
OnOffBtn.BackgroundColor3 = COLOR_OFF
OnOffBtn.Text = "OFF"
OnOffBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OnOffBtn.Font = Enum.Font.GothamBold
OnOffBtn.TextSize = 24
OnOffBtn.Parent = Tab1Content
Instance.new("UICorner", OnOffBtn).CornerRadius = UDim.new(0, 12)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
StatusLabel.Text = "🔴 Monitoring OFF"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = Tab1Content
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)

local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(0.9, 0, 0, 40)
CountLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
CountLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
CountLabel.Text = "📦 Paths captured: 0"
CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 14
CountLabel.Parent = Tab1Content
Instance.new("UICorner", CountLabel).CornerRadius = UDim.new(0, 8)

-- ===================================================
-- TAB 2: CAPTURED PATHS
-- ===================================================
local Tab2Content = Instance.new("Frame")
Tab2Content.Size = UDim2.new(1, -20, 1, -110)
Tab2Content.Position = UDim2.new(0, 10, 0, 105)
Tab2Content.BackgroundTransparency = 1
Tab2Content.Visible = false
Tab2Content.Parent = MainFrame

scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 10)
scrollFrame.Parent = Tab2Content
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)

listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- ===================================================
-- 🧹 FUNCTION TO UPDATE LIST
-- ===================================================
local function updatePathsList()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local yOffset = 0
    local sortedPaths = {}
    for path, data in pairs(triggeredPaths) do
        table.insert(sortedPaths, {path = path, data = data})
    end
    table.sort(sortedPaths, function(a, b) return a.data.time > b.data.time end)
    
    for _, item in ipairs(sortedPaths) do
        local path = item.path
        local data = item.data
        
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -20, 0, 80)
        itemFrame.Position = UDim2.new(0, 10, 0, yOffset)
        itemFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = scrollFrame
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 10)
        
        -- الاسم
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -80, 0, 22)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "🔗 " .. (data.name or "Unknown")
        nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        -- المسار الكامل
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -80, 0, 40)
        pathLabel.Position = UDim2.new(0, 10, 0, 28)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Text = "📁 " .. path
        pathLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 10
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.TextWrapped = true
        pathLabel.Parent = itemFrame
        
        -- نوع الكائن
        local typeLabel = Instance.new("TextLabel")
        typeLabel.Size = UDim2.new(0.5, 0, 0, 15)
        typeLabel.Position = UDim2.new(0, 10, 0, 62)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = "📦 " .. data.className
        typeLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
        typeLabel.Font = Enum.Font.Gotham
        typeLabel.TextSize = 10
        typeLabel.TextXAlignment = Enum.TextXAlignment.Left
        typeLabel.Parent = itemFrame
        
        -- زر النسخ
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 55, 0, 32)
        copyBtn.Position = UDim2.new(1, -68, 0, 25)
        copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        copyBtn.Text = "📋 Copy"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 12
        copyBtn.Parent = itemFrame
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
        
        copyBtn.MouseButton1Click:Connect(function()
            setclipboard(path)
            copyBtn.Text = "✓"
            copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(1, function()
                if copyBtn and copyBtn.Parent then
                    copyBtn.Text = "📋 Copy"
                    copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                end
            end)
        end)
        
        yOffset = yOffset + 92
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    CountLabel.Text = "📦 Paths captured: " .. (#triggeredPaths)
end

-- ===================================================
-- 🕵️ DETECT ANY TRIGGERED PATH
-- ===================================================
local function capturePath(instance, actionName)
    if not monitoring then return end
    if not instance then return end
    
    local fullPath = instance:GetFullName()
    if not triggeredPaths[fullPath] then
        triggeredPaths[fullPath] = {
            name = instance.Name,
            className = instance.ClassName,
            time = os.time(),
            action = actionName or "triggered"
        }
        updatePathsList()
    end
end

-- ===================================================
-- 🌐 HOOK INTO GAME EVENTS
-- ===================================================
local connections = {}

local function startMonitoring()
    if monitoring then return end
    monitoring = true
    
    -- مراقبة الـ DescendantAdded (أي كائن جديد ينضاف)
    local connAdded = game.DescendantAdded:Connect(function(descendant)
        capturePath(descendant, "added")
    end)
    table.insert(connections, connAdded)
    
    -- مراقبة الـ ClickDetectors
    local function hookClickDetector(detector)
        if detector:IsA("ClickDetector") then
            local conn = detector.MouseClick:Connect(function(player)
                if player == plr then
                    capturePath(detector, "clicked")
                end
            end)
            table.insert(connections, conn)
        end
    end
    
    for _, detector in pairs(Workspace:GetDescendants()) do
        hookClickDetector(detector)
    end
    
    game.DescendantAdded:Connect(hookClickDetector)
    
    -- مراقبة الـ RemoteEvents (عند استدعائها)
    local function hookRemote(remote)
        if remote:IsA("RemoteEvent") then
            local oldFire = remote.FireServer
            remote.FireServer = function(self, ...)
                capturePath(remote, "fired")
                return oldFire(self, ...)
            end
        end
    end
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        hookRemote(remote)
    end
    
    game.DescendantAdded:Connect(hookRemote)
    
    -- مراقبة الـ ProximityPrompts
    local function hookPrompt(prompt)
        if prompt:IsA("ProximityPrompt") then
            local conn = prompt.Triggered:Connect(function(player)
                if player == plr then
                    capturePath(prompt, "triggered")
                end
            end)
            table.insert(connections, conn)
        end
    end
    
    for _, prompt in pairs(Workspace:GetDescendants()) do
        hookPrompt(prompt)
    end
    
    game.DescendantAdded:Connect(hookPrompt)
    
    -- مراقبة الـ TextButtons / GUI
    local function hookGuiButton(button)
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local conn = button.MouseButton1Click:Connect(function()
                capturePath(button, "clicked")
            end)
            table.insert(connections, conn)
        end
    end
    
    for _, btn in pairs(plr.PlayerGui:GetDescendants()) do
        hookGuiButton(btn)
    end
    
    game.DescendantAdded:Connect(hookGuiButton)
    
    print("✅ Monitoring STARTED")
end

local function stopMonitoring()
    if not monitoring then return end
    monitoring = false
    
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    
    print("⛔ Monitoring STOPPED")
end

-- ===================================================
-- 🔘 ON/OFF TOGGLE
-- ===================================================
OnOffBtn.MouseButton1Click:Connect(function()
    if monitoring then
        stopMonitoring()
        OnOffBtn.BackgroundColor3 = COLOR_OFF
        OnOffBtn.Text = "OFF"
        StatusLabel.Text = "🔴 Monitoring OFF"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        startMonitoring()
        OnOffBtn.BackgroundColor3 = COLOR_ON
        OnOffBtn.Text = "ON"
        StatusLabel.Text = "🟢 Monitoring ACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

-- ===================================================
-- 🧩 TAB SWITCHING
-- ===================================================
Tab1.MouseButton1Click:Connect(function()
    Tab1.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    Tab2.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Tab1Content.Visible = true
    Tab2Content.Visible = false
end)

Tab2.MouseButton1Click:Connect(function()
    Tab1.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Tab2.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    Tab1Content.Visible = false
    Tab2Content.Visible = true
    updatePathsList()
end)

-- ===================================================
-- 🖱️ DRAG SYSTEM
-- ===================================================
local function MakeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(MainFrame)
MakeDraggable(MiniBtn)

-- ===================================================
-- 🔘 MINIMIZE & RESTORE
-- ===================================================
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniBtn.Visible = true
end)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniBtn.Visible = false
    updatePathsList()
end)

-- قوس قزح لـ M
task.spawn(function()
    while true do
        local hue = tick() % 5 / 5
        MiniBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.15)
    end
end)

-- ===================================================
-- 🚀 START
-- ===================================================
print("✅ MOZER TRIGGER MONITOR READY")
print("🔘 Click ON to start capturing triggered paths")
print("📋 Any path you trigger will appear in 'Captured Paths'")
