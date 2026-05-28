-- ===================================================
-- 🔍 MOZER REMOTE MONITOR
-- ⚡ Live Remote Tracker | Save Data | Copy Path
-- ===================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer

-- ===================================================
-- 📦 SAVE SYSTEM (حفظ البيانات بين الجلسات)
-- ===================================================
local SAVE_KEY = "MozerRemoteData_" .. plr.UserId
local savedRemotes = {}

local function loadSavedData()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(SAVE_KEY .. ".json"))
    end)
    if success and type(data) == "table" then
        savedRemotes = data
    else
        savedRemotes = {}
    end
end

local function saveData()
    pcall(function()
        writefile(SAVE_KEY .. ".json", HttpService:JSONEncode(savedRemotes))
    end)
end

loadSavedData()

-- ===================================================
-- 🎨 VARIABLES & UI COMPONENTS
-- ===================================================
local monitoring = false
local detectedRemotes = {} -- name -> {path, className, time}
local remoteListFrame = nil
local scrollFrame = nil
local listLayout = nil

-- ألوان
local COLOR_ON = Color3.fromRGB(0, 200, 0)    -- أخضر ON
local COLOR_OFF = Color3.fromRGB(80, 80, 80)  -- رمادي OFF

-- ===================================================
-- 🖥️ CREATE UI (MozerRemote)
-- ===================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozerRemoteUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = plr:WaitForChild("PlayerGui")

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MozerRemote Monitor"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- زر إغلاق للتصغير
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = TitleBar

-- زر التصغير (M)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 60, 0, 60)
MiniBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MiniBtn.Text = "M"
MiniBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
MiniBtn.Font = Enum.Font.FredokaOne
MiniBtn.TextSize = 32
MiniBtn.Visible = false
MiniBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 12)

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 45)
TabBar.Position = UDim2.new(0, 0, 0, 45)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tab1 = Instance.new("TextButton")
Tab1.Size = UDim2.new(0.5, -5, 1, 0)
Tab1.Position = UDim2.new(0, 10, 0, 0)
Tab1.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Tab1.Text = "🛡️ Monitor"
Tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1.Font = Enum.Font.GothamBold
Tab1.TextSize = 14
Tab1.Parent = TabBar
Instance.new("UICorner", Tab1).CornerRadius = UDim.new(0, 8)

local Tab2 = Instance.new("TextButton")
Tab2.Size = UDim2.new(0.5, -5, 1, 0)
Tab2.Position = UDim2.new(0.5, 5, 0, 0)
Tab2.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Tab2.Text = "📡 Remotes"
Tab2.TextColor3 = Color3.fromRGB(200, 200, 200)
Tab2.Font = Enum.Font.GothamBold
Tab2.TextSize = 14
Tab2.Parent = TabBar
Instance.new("UICorner", Tab2).CornerRadius = UDim.new(0, 8)

-- ===================================================
-- 📁 TAB 1: MONITOR (ON/OFF + STATUS)
-- ===================================================
local Tab1Content = Instance.new("Frame")
Tab1Content.Size = UDim2.new(1, -20, 1, -110)
Tab1Content.Position = UDim2.new(0, 10, 0, 100)
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
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
StatusLabel.Text = "🔴 Monitoring stopped"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = Tab1Content
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)

local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(0.9, 0, 0, 40)
CountLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
CountLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
CountLabel.Text = "📦 Remotes detected: 0"
CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 14
CountLabel.Parent = Tab1Content
Instance.new("UICorner", CountLabel).CornerRadius = UDim.new(0, 8)

-- ===================================================
-- 📁 TAB 2: REMOTES LIST (مع سكرول)
-- ===================================================
local Tab2Content = Instance.new("Frame")
Tab2Content.Size = UDim2.new(1, -20, 1, -110)
Tab2Content.Position = UDim2.new(0, 10, 0, 100)
Tab2Content.BackgroundTransparency = 1
Tab2Content.Visible = false
Tab2Content.Parent = MainFrame

-- Scrolling Frame لعرض الـ Remotes
scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 10)
scrollFrame.Parent = Tab2Content
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)

listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- ===================================================
-- 🧹 وظيفة تحديث قائمة الـ Remotes
-- ===================================================
local function updateRemotesList()
    -- حذف القديم
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            if child.Name ~= "UIListLayout" then
                child:Destroy()
            end
        end
    end
    
    local yOffset = 0
    for name, data in pairs(detectedRemotes) do
        -- خلفية لكل Remote
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -20, 0, 70)
        itemFrame.Position = UDim2.new(0, 10, 0, yOffset)
        itemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = scrollFrame
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 8)
        
        -- اسم الـ Remote
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -80, 0, 20)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📡 " .. name
        nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        -- المسار
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -80, 0, 30)
        pathLabel.Position = UDim2.new(0, 10, 0, 25)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Text = "📁 " .. data.path
        pathLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 10
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.TextWrapped = true
        pathLabel.Parent = itemFrame
        
        -- نوع الـ Remote
        local typeLabel = Instance.new("TextLabel")
        typeLabel.Size = UDim2.new(0.5, 0, 0, 15)
        typeLabel.Position = UDim2.new(0, 10, 0, 52)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = "🔧 " .. data.className
        typeLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
        typeLabel.Font = Enum.Font.Gotham
        typeLabel.TextSize = 10
        typeLabel.TextXAlignment = Enum.TextXAlignment.Left
        typeLabel.Parent = itemFrame
        
        -- زر النسخ
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 50, 0, 30)
        copyBtn.Position = UDim2.new(1, -60, 0, 20)
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        copyBtn.Text = "📋"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 16
        copyBtn.Parent = itemFrame
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
        
        copyBtn.MouseButton1Click:Connect(function()
            setclipboard(data.path)
            copyBtn.Text = "✓"
            task.delay(0.8, function()
                if copyBtn and copyBtn.Parent then
                    copyBtn.Text = "📋"
                end
            end)
        end)
        
        yOffset = yOffset + 80
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    CountLabel.Text = "📦 Remotes detected: " .. (#detectedRemotes + #savedRemotes)
end

-- ===================================================
-- 🕵️ REMOTE DETECTION (MONITORING)
-- ===================================================
local function scanForRemotes()
    if not monitoring then return end
    
    local function addRemote(name, obj, path)
        if not detectedRemotes[name] then
            detectedRemotes[name] = {
                name = name,
                className = obj.ClassName,
                path = path,
                time = os.time()
            }
            updateRemotesList()
        end
    end
    
    -- فحص ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local fullPath = obj:GetFullName()
            addRemote(obj.Name, obj, fullPath)
        end
    end
    
    -- فحص Workspace (بعض الألعاب تحط Remotes هناك)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local fullPath = obj:GetFullName()
            addRemote(obj.Name, obj, fullPath)
        end
    end
    
    -- فحص Players (قد يكون فيه Remotes عند لاعبين آخرين)
    for _, player in pairs(Players:GetPlayers()) do
        for _, obj in pairs(player:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local fullPath = obj:GetFullName()
                addRemote(obj.Name, obj, fullPath)
            end
        end
    end
end

-- ===================================================
-- 🧠 تشغيل المراقبة بشكل مستمر
-- ===================================================
task.spawn(function()
    while true do
        if monitoring then
            scanForRemotes()
        end
        task.wait(2) -- كل ثانيتين
    end
end)

-- ===================================================
-- 🔘 ON/OFF FUNCTION
-- ===================================================
local function setMonitoring(state)
    monitoring = state
    if monitoring then
        OnOffBtn.BackgroundColor3 = COLOR_ON
        OnOffBtn.Text = "ON"
        StatusLabel.Text = "🟢 Monitoring active - scanning for Remotes..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        print("✅ Remote Monitoring STARTED")
        scanForRemotes() -- مسح فوري
    else
        OnOffBtn.BackgroundColor3 = COLOR_OFF
        OnOffBtn.Text = "OFF"
        StatusLabel.Text = "🔴 Monitoring stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        print("⛔ Remote Monitoring STOPPED")
    end
end

-- ===================================================
-- 🧩 TAB SWITCHING
-- ===================================================
Tab1.MouseButton1Click:Connect(function()
    Tab1.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Tab2.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Tab1Content.Visible = true
    Tab2Content.Visible = false
end)

Tab2.MouseButton1Click:Connect(function()
    Tab1.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Tab2.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Tab1Content.Visible = false
    Tab2Content.Visible = true
    updateRemotesList()
end)

OnOffBtn.MouseButton1Click:Connect(function()
    setMonitoring(not monitoring)
end)

-- ===================================================
-- 🖱️ DRAG SYSTEM (سحب الواجهة)
-- ===================================================
local function MakeDraggable(frame)
    local UIS = game:GetService("UserInputService")
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
    
    UIS.InputChanged:Connect(function(input)
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
    updateRemotesList()
end)

-- تأثير قوس قزح لـ M
task.spawn(function()
    while true do
        local hue = tick() % 5 / 5
        MiniBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.15)
    end
end)

-- ===================================================
-- 🚀 LOAD SAVED REMOTES
-- ===================================================
for name, data in pairs(savedRemotes) do
    if not detectedRemotes[name] then
        detectedRemotes[name] = data
    end
end
updateRemotesList()

-- ===================================================
-- 💾 SAVE ON GAME EXIT (اختياري)
-- =================================================--
local function saveOnExit()
    pcall(function()
        writefile(SAVE_KEY .. ".json", HttpService:JSONEncode(detectedRemotes))
    end)
end

game:BindToClose(saveOnExit)

print("✅ MOZER REMOTE MONITOR READY")
print("🔘 Click ON to start monitoring")
print("📋 Remotes will appear in the 'Remotes' tab")
