-- ===================================================
-- 🧭 MOZER AUTO TRIGGER MONITOR (MOBILE OPTIMIZED)
-- 📱 متوافق مع Delta Executor | سحب باللمس | مراقبة فورية
-- ===================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

-- ضمان عدم تكرار الواجهة
if plr.PlayerGui:FindFirstChild("MozerTriggerMonitor") then
    plr.PlayerGui.MozerTriggerMonitor:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozerTriggerMonitor"
ScreenGui.Parent = plr:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- المتغيرات
local triggeredPaths = {}
local pathsCount = 0

-- ===================================================
-- وظيفة السحب المخصصة للجوال (Touch Dragging)
-- ===================================================
local function EnableDrag(frame)
    local dragStart, startPos
    local dragging = false

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

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ===================================================
-- تصميم الواجهة (أحجام مناسبة للجوال)
-- ===================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 250)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MOZER MONITOR (MOBILE)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

-- زر التصغير (M)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(0, 10, 0.5, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MiniBtn.Text = "M"
MiniBtn.TextColor3 = Color3.fromRGB(255, 165, 0)
MiniBtn.Font = Enum.Font.FredokaOne
MiniBtn.TextSize = 25
MiniBtn.Visible = false
MiniBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 25)
EnableDrag(MiniBtn)

-- منطقة المحتوى
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -10, 1, -45)
Container.Position = UDim2.new(0, 5, 0, 40)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.Parent = Container

-- ===================================================
-- وظيفة تسجيل المسارات
-- ===================================================
local function LogPath(obj, actionType)
    local path = obj:GetFullName()
    if not triggeredPaths[path] then
        triggeredPaths[path] = true
        pathsCount = pathsCount + 1
        
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, -5, 0, 45)
        Card.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Card.Parent = Container
        Instance.new("UICorner", Card)

        local Info = Instance.new("TextLabel")
        Info.Size = UDim2.new(1, -60, 1, 0)
        Info.Position = UDim2.new(0, 5, 0, 0)
        Info.BackgroundTransparency = 1
        Info.Text = "[" .. actionType .. "] " .. obj.Name .. "\n" .. path
        Info.TextColor3 = Color3.fromRGB(200, 200, 200)
        Info.TextSize = 10
        Info.TextWrapped = true
        Info.TextXAlignment = Enum.TextXAlignment.Left
        Info.Parent = Card

        local Copy = Instance.new("TextButton")
        Copy.Size = UDim2.new(0, 50, 0, 30)
        Copy.Position = UDim2.new(1, -55, 0.5, -15)
        Copy.Text = "Copy"
        Copy.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        Copy.TextColor3 = Color3.fromRGB(255, 255, 255)
        Copy.Parent = Card
        Instance.new("UICorner", Copy)

        Copy.MouseButton1Click:Connect(function()
            setclipboard(path)
            Copy.Text = "Saved!"
            task.wait(1)
            Copy.Text = "Copy"
        end)

        Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end
end

-- ===================================================
-- المراقبة النشطة (Hooks)
-- ===================================================

-- 1. مراقبة الضغط على الأزرار (Buttons)
local function monitorGuis(gui)
    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
        gui.MouseButton1Click:Connect(function()
            LogPath(gui, "UI_CLICK")
        end)
    end
end

-- 2. مراقبة الأشياء التفاعلية في العالم (Proximity & Click)
local function monitorWorld(obj)
    if obj:IsA("ClickDetector") then
        obj.MouseClick:Connect(function() LogPath(obj, "CLICK") end)
    elseif obj:IsA("ProximityPrompt") then
        obj.Triggered:Connect(function() LogPath(obj, "TRIGGER") end)
    end
end

-- تطبيق المراقبة على كل شيء
for _, v in pairs(game:GetDescendants()) do
    monitorGuis(v)
    monitorWorld(v)
end

game.DescendantAdded:Connect(function(v)
    monitorGuis(v)
    monitorWorld(v)
end)

-- 3. مراقبة الـ RemoteEvents (مهم جداً للـ Delta)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        LogPath(self, "REMOTE")
    end
    return oldNamecall(self, ...)
end)

-- تفعيل السحب للإطار الرئيسي
EnableDrag(MainFrame)

-- إغلاق وتصغير
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniBtn.Visible = true
end)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniBtn.Visible = false
end)

print("✅ Mozer Mobile Monitor Loaded!")
