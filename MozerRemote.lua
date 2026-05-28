-- ===================================================
-- 🧭 MOZER AUTO TRIGGER MONITOR
-- ⚡ يبدأ تلقائياً | يراقب كل المسارات
-- ===================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- ===================================================
-- المتغيرات
-- ===================================================
local triggeredPaths = {}
local scrollFrame = nil

-- ===================================================
-- إنشاء الواجهة
-- ===================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozerTriggerMonitor"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = plr:WaitForChild("PlayerGui")

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 400)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- شريط العنوان
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Mozer • Auto Trigger Monitor"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- زر X
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar

-- زر التصغير M
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 55, 0, 55)
MiniBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MiniBtn.Text = "M"
MiniBtn.TextColor3 = Color3.fromRGB(255, 120, 0)
MiniBtn.Font = Enum.Font.FredokaOne
MiniBtn.TextSize = 30
MiniBtn.Visible = false
MiniBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 12)

-- التبويبات
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tab1 = Instance.new("TextButton")
Tab1.Size = UDim2.new(0.5, -5, 1, 0)
Tab1.Position = UDim2.new(0, 10, 0, 0)
Tab1.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
Tab1.Text = "Status"
Tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1.Font = Enum.Font.GothamBold
Tab1.TextSize = 13
Tab1.Parent = TabBar
Instance.new("UICorner", Tab1).CornerRadius = UDim.new(0, 8)

local Tab2 = Instance.new("TextButton")
Tab2.Size = UDim2.new(0.5, -5, 1, 0)
Tab2.Position = UDim2.new(0.5, 5, 0, 0)
Tab2.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Tab2.Text = "Captured"
Tab2.TextColor3 = Color3.fromRGB(200, 200, 200)
Tab2.Font = Enum.Font.GothamBold
Tab2.TextSize = 13
Tab2.Parent = TabBar
Instance.new("UICorner", Tab2).CornerRadius = UDim.new(0, 8)

-- تبويب Status
local Tab1Content = Instance.new("Frame")
Tab1Content.Size = UDim2.new(1, -20, 1, -100)
Tab1Content.Position = UDim2.new(0, 10, 0, 90)
Tab1Content.BackgroundTransparency = 1
Tab1Content.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
StatusLabel.Text = "🟢 Monitoring ACTIVE (Auto)"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.Parent = Tab1Content
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)

local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(0.9, 0, 0, 40)
CountLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
CountLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
CountLabel.Text = "📦 Paths captured: 0"
CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 12
CountLabel.Parent = Tab1Content
Instance.new("UICorner", CountLabel).CornerRadius = UDim.new(0, 8)

-- تبويب Captured
local Tab2Content = Instance.new("Frame")
Tab2Content.Size = UDim2.new(1, -20, 1, -100)
Tab2Content.Position = UDim2.new(0, 10, 0, 90)
Tab2Content.BackgroundTransparency = 1
Tab2Content.Visible = false
Tab2Content.Parent = MainFrame

scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 10)
scrollFrame.Parent = Tab2Content
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- ===================================================
-- تحديث القائمة
-- ===================================================
local function updateCapturedList()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
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
        itemFrame.Size = UDim2.new(1, -10, 0, 65)
        itemFrame.Position = UDim2.new(0, 5, 0, yOffset)
        itemFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = scrollFrame
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 8)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -70, 0, 18)
        nameLabel.Position = UDim2.new(0, 8, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "🔗 " .. (data.name or "Unknown")
        nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -70, 0, 30)
        pathLabel.Position = UDim2.new(0, 8, 0, 22)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Text = path
        pathLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 9
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.TextWrapped = true
        pathLabel.Parent = itemFrame
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 45, 0, 28)
        copyBtn.Position = UDim2.new(1, -52, 0, 18)
        copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        copyBtn.Text = "Copy"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 10
        copyBtn.Parent = itemFrame
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
        
        copyBtn.MouseButton1Click:Connect(function()
            setclipboard(path)
            copyBtn.Text = "✓"
            copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(1, function()
                if copyBtn and copyBtn.Parent then
                    copyBtn.Text = "Copy"
                    copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                end
            end)
        end)
        
        yOffset = yOffset + 72
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    CountLabel.Text = "📦 Paths captured: " .. (#triggeredPaths)
end

-- ===================================================
-- التقاط أي مسار يحدث
-- ===================================================
local function capturePath(instance, action)
    if not instance then return end
    
    local fullPath = instance:GetFullName()
    if not triggeredPaths[fullPath] then
        triggeredPaths[fullPath] = {
            name = instance.Name,
            className = instance.ClassName,
            time = os.time(),
            action = action or "triggered"
        }
        updateCapturedList()
        print("📌 Captured: " .. fullPath)
    end
end

-- ===================================================
-- المراقبة التلقائية (تبدأ فوراً)
-- ===================================================
-- 1. أي كائن جديد ينضاف للعبة
game.DescendantAdded:Connect(function(desc)
    capturePath(desc, "added")
end)

-- 2. مراقبة ClickDetectors
local function hookClickDetector(detector)
    if detector:IsA("ClickDetector") then
        detector.MouseClick:Connect(function(player)
            if player == plr then capturePath(detector, "clicked") end
        end)
    end
end
for _, d in pairs(Workspace:GetDescendants()) do hookClickDetector(d) end
game.DescendantAdded:Connect(hookClickDetector)

-- 3. مراقبة ProximityPrompts
local function hookPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.Triggered:Connect(function(player)
            if player == plr then capturePath(prompt, "triggered") end
        end)
    end
end
for _, p in pairs(Workspace:GetDescendants()) do hookPrompt(p) end
game.DescendantAdded:Connect(hookPrompt)

-- 4. مراقبة أزرار الواجهة (GUI)
local function hookGuiButton(btn)
    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
        btn.MouseButton1Click:Connect(function()
            capturePath(btn, "clicked")
        end)
    end
end
for _, btn in pairs(plr.PlayerGui:GetDescendants()) do hookGuiButton(btn) end
game.DescendantAdded:Connect(hookGuiButton)

-- 5. مراقبة RemoteEvents (عند استدعائها)
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
            capturePath(remote, "fired")
            return oldFire(self, ...)
        end
    end
end
for _, r in pairs(ReplicatedStorage:GetDescendants()) do hookRemote(r) end
game.DescendantAdded:Connect(hookRemote)

-- 6. مراقبة Workspace بشكل عام
local function hookWorkspace(obj)
    capturePath(obj, "exists")
end
for _, obj in pairs(Workspace:GetDescendants()) do
    if not triggeredPaths[obj:GetFullName()] then
        capturePath(obj, "found")
    end
end

-- ===================================================
-- التبديل بين التبويبات
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
    updateCapturedList()
end)

-- ===================================================
-- السحب
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
-- تصغير وتكبير
-- ===================================================
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniBtn.Visible = true
end)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniBtn.Visible = false
    updateCapturedList()
end)

-- قوس قزح
task.spawn(function()
    while true do
        local hue = tick() % 5 / 5
        MiniBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.15)
    end
end)

-- ===================================================
-- بدء التشغيل
-- ===================================================
print("✅ MOZER AUTO TRIGGER MONITOR READY")
print("📡 Monitoring ALL paths automatically")
print("📍 Any path you trigger will appear in 'Captured' tab")
