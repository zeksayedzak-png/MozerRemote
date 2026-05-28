-- ===================================================
-- 🧭 MOZER PATH MONITOR (MOBILE)
-- 📍 مراقب مسارات فقط | زر تفعيل (Select) | لا يخرب اللعبة
-- ===================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- تنظيف الواجهة القديمة
if plr.PlayerGui:FindFirstChild("MozerPathMonitor") then
    plr.PlayerGui.MozerPathMonitor:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozerPathMonitor"
ScreenGui.Parent = plr:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- المتغيرات
local triggeredPaths = {}

-- ===================================================
-- وظيفة السحب (سلسة جداً للجوال)
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
-- تصميم الواجهة
-- ===================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MOZER PATH MONITOR 📍"
TitleLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = TitleBar

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -10, 1, -45)
Container.Position = UDim2.new(0, 5, 0, 40)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.ScrollBarThickness = 3
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.Parent = Container

-- ===================================================
-- وظيفة التفعيل (Select Trigger)
-- ===================================================
local function TriggerObject(obj)
    if obj:IsA("ProximityPrompt") then
        fireproximityprompt(obj)
    elseif obj:IsA("ClickDetector") then
        fireclickdetector(obj)
    elseif obj:IsA("TextButton") or obj:IsA("ImageButton") then
        -- تفعيل اتصالات الزر بدون تخريب
        local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
        for _, eventName in pairs(events) do
            for _, conn in pairs(getconnections(obj[eventName])) do
                conn:Fire()
            end
        end
    end
end

-- ===================================================
-- تسجيل المسارات
-- ===================================================
local function LogPath(obj, actionType)
    local path = obj:GetFullName()
    if triggeredPaths[path] then return end
    triggeredPaths[path] = true

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -5, 0, 55)
    Card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Card.Parent = Container
    Instance.new("UICorner", Card)

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -100, 1, 0)
    Info.Position = UDim2.new(0, 8, 0, 0)
    Info.BackgroundTransparency = 1
    Info.Text = "[" .. actionType .. "] " .. obj.Name .. "\n" .. path
    Info.TextColor3 = Color3.fromRGB(200, 200, 200)
    Info.TextSize = 10
    Info.TextWrapped = true
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.Parent = Card

    -- زر النسخ
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 40, 0, 20)
    CopyBtn.Position = UDim2.new(1, -45, 0, 5)
    CopyBtn.Text = "Copy"
    CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.TextSize = 10
    CopyBtn.Parent = Card
    Instance.new("UICorner", CopyBtn)

    -- زر التفعيل (Select)
    local SelectBtn = Instance.new("TextButton")
    SelectBtn.Size = UDim2.new(0, 40, 0, 20)
    SelectBtn.Position = UDim2.new(1, -45, 0, 28)
    SelectBtn.Text = "Select"
    SelectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectBtn.TextSize = 10
    SelectBtn.Parent = Card
    Instance.new("UICorner", SelectBtn)

    CopyBtn.MouseButton1Click:Connect(function()
        setclipboard(path)
        CopyBtn.Text = "✔"
        task.wait(0.5)
        CopyBtn.Text = "Copy"
    end)

    SelectBtn.MouseButton1Click:Connect(function()
        TriggerObject(obj)
        SelectBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(0.3)
        SelectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    end)

    Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end

-- ===================================================
-- مراقبة الكائنات (أزرار وعالم فقط)
-- ===================================================
local function HookObject(v)
    if v:IsA("TextButton") or v:IsA("ImageButton") then
        v.MouseButton1Click:Connect(function()
            task.defer(LogPath, v, "UI")
        end)
    elseif v:IsA("ClickDetector") then
        v.MouseClick:Connect(function()
            task.defer(LogPath, v, "CLICK")
        end)
    elseif v:IsA("ProximityPrompt") then
        v.Triggered:Connect(function()
            task.defer(LogPath, v, "PROX")
        end)
    end
end

-- تشغيل المراقبة
for _, v in pairs(game:GetDescendants()) do HookObject(v) end
game.DescendantAdded:Connect(HookObject)

-- تفعيل السحب والإغلاق
EnableDrag(MainFrame)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

print("✅ Mozer Path Monitor Active - (Paths Only)")
