-- ===================================================
-- 🧭 MOZER PATH MONITOR PRO (V2)
-- 📍 نظام أتمتة ذكي | واجهة متطورة للجوال
-- ✍️ Designed for: Delta Executor & Mobile Users
-- ===================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

-- تنظيف النسخ القديمة
if plr.PlayerGui:FindFirstChild("MozerPro") then
    plr.PlayerGui.MozerPro:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozerPro"
ScreenGui.Parent = plr:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- المتغيرات العالمية
local triggeredPaths = {}
local autoTasks = {}
local globalDelay = 1000 -- الافتراضي 1 ثانية

-- ===================================================
-- وظيفة السحب السلس (للجوال)
-- ===================================================
local function EnableDrag(frame)
    local dragStart, startPos, dragging
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ===================================================
-- تصميم الواجهة الرئيسية (أكبر قليلاً)
-- ===================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 300) -- تكبير الواجهة
MainFrame.Position = UDim2.new(0.5, -190, 0.4, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- العنوان
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MOZER PRO MONITOR ⚙️"
TitleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- أزرار التحكم في الأعلى
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextSize = 20
CloseBtn.Parent = TitleBar

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 35, 0, 35)
SettingsBtn.Position = UDim2.new(1, -80, 0, 2)
SettingsBtn.Text = "⚙️"
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.TextSize = 18
SettingsBtn.Parent = TitleBar

-- الحاويات (صفحة القائمة وصفحة الإعدادات)
local ListContainer = Instance.new("ScrollingFrame")
ListContainer.Size = UDim2.new(1, -15, 1, -55)
ListContainer.Position = UDim2.new(0, 7, 0, 45)
ListContainer.BackgroundTransparency = 1
ListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ListContainer.ScrollBarThickness = 2
ListContainer.Parent = MainFrame

local SettingsPage = Instance.new("Frame")
SettingsPage.Size = UDim2.new(1, 0, 1, -40)
SettingsPage.Position = UDim2.new(0, 0, 0, 40)
SettingsPage.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
SettingsPage.Visible = false
SettingsPage.Parent = MainFrame
Instance.new("UICorner", SettingsPage)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = ListContainer

-- ===================================================
-- تصميم صفحة الإعدادات (Auto Settings)
-- ===================================================
local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 30)
SettingsTitle.Text = "AUTO CONFIGURATION"
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.Parent = SettingsPage

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(0, 200, 0, 35)
DelayInput.Position = UDim2.new(0.5, -100, 0, 50)
DelayInput.PlaceholderText = "Interval (ms) e.g 1000"
DelayInput.Text = "1000"
DelayInput.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
DelayInput.TextColor3 = Color3.fromRGB(0, 255, 150)
DelayInput.Parent = SettingsPage
Instance.new("UICorner", DelayInput)

local BackBtn = Instance.new("TextButton")
BackBtn.Size = UDim2.new(0, 100, 0, 30)
BackBtn.Position = UDim2.new(0.5, -50, 0, 100)
BackBtn.Text = "BACK"
BackBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BackBtn.Parent = SettingsPage
Instance.new("UICorner", BackBtn)

-- ===================================================
-- وظيفة التفعيل (Trigger)
-- ===================================================
local function TriggerObject(obj)
    if obj:IsA("ProximityPrompt") then fireproximityprompt(obj)
    elseif obj:IsA("ClickDetector") then fireclickdetector(obj)
    elseif obj:IsA("TextButton") or obj:IsA("ImageButton") then
        for _, conn in pairs(getconnections(obj.MouseButton1Click)) do conn:Fire() end
        for _, conn in pairs(getconnections(obj.Activated)) do conn:Fire() end
    end
end

-- ===================================================
-- إضافة بطاقة المسار (Path Card) مع زر Auto
-- ===================================================
local function LogPath(obj, actionType)
    local path = obj:GetFullName()
    if triggeredPaths[path] then return end
    triggeredPaths[path] = true

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -10, 0, 65)
    Card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Card.Parent = ListContainer
    Instance.new("UICorner", Card)

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -120, 1, 0)
    Info.Position = UDim2.new(0, 10, 0, 0)
    Info.BackgroundTransparency = 1
    Info.Text = "["..actionType.."] "..obj.Name.."\n"..path
    Info.TextColor3 = Color3.fromRGB(220, 220, 220)
    Info.TextSize = 10; Info.TextWrapped = true; Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.Parent = Card

    -- زر Copy
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 45, 0, 25)
    CopyBtn.Position = UDim2.new(1, -55, 0, 5)
    CopyBtn.Text = "Copy"
    CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.Parent = Card
    Instance.new("UICorner", CopyBtn)

    -- زر Auto
    local AutoBtn = Instance.new("TextButton")
    AutoBtn.Size = UDim2.new(0, 45, 0, 25)
    AutoBtn.Position = UDim2.new(1, -105, 0, 5)
    AutoBtn.Text = "Auto"
    AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- أحمر (مغلق)
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBtn.Parent = Card
    Instance.new("UICorner", AutoBtn)

    -- زر Select (يدوي)
    local SelectBtn = Instance.new("TextButton")
    SelectBtn.Size = UDim2.new(1, -10, 0, 20)
    SelectBtn.Position = UDim2.new(0, 5, 1, -25)
    SelectBtn.Text = "Manual Select"
    SelectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectBtn.Parent = Card
    Instance.new("UICorner", SelectBtn)

    -- منطق الـ Auto
    local isAutoOn = false
    AutoBtn.MouseButton1Click:Connect(function()
        isAutoOn = not isAutoOn
        if isAutoOn then
            AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100) -- أخضر
            autoTasks[path] = true
            task.spawn(function()
                while autoTasks[path] do
                    TriggerObject(obj)
                    local delayTime = tonumber(DelayInput.Text) or 1000
                    task.wait(delayTime / 1000)
                end
            end)
        else
            AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- أحمر
            autoTasks[path] = false
        end
    end)

    CopyBtn.MouseButton1Click:Connect(function()
        setclipboard(path)
        CopyBtn.Text = "✔"
        task.wait(0.5); CopyBtn.Text = "Copy"
    end)

    SelectBtn.MouseButton1Click:Connect(function()
        TriggerObject(obj)
    end)

    ListContainer.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

-- ===================================================
-- تفعيل الوظائف
-- ===================================================
local function Hook(v)
    if v:IsA("TextButton") or v:IsA("ImageButton") then
        v.MouseButton1Click:Connect(function() task.defer(LogPath, v, "UI") end)
    elseif v:IsA("ClickDetector") then
        v.MouseClick:Connect(function() task.defer(LogPath, v, "CLICK") end)
    elseif v:IsA("ProximityPrompt") then
        v.Triggered:Connect(function() task.defer(LogPath, v, "PROX") end)
    end
end

for _, v in pairs(game:GetDescendants()) do Hook(v) end
game.DescendantAdded:Connect(Hook)

-- التحكم في الصفحات
SettingsBtn.MouseButton1Click:Connect(function()
    ListContainer.Visible = false
    SettingsPage.Visible = true
end)

BackBtn.MouseButton1Click:Connect(function()
    SettingsPage.Visible = false
    ListContainer.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
EnableDrag(MainFrame)

print("🚀 Mozer Pro Active - High IQ Automation Ready")
