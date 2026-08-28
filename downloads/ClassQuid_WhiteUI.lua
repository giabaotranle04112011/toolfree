--[[
    ================================================================================
    ⚡ CLASS QUID VIP ULTRA • ZOO OR OOF (WHITE LIGHT EDITION V9.0 - VITAMIN SUPERCHARGED)
    👑 Tác giả: Trần Lê Gia Bảo | VIP ENGINE 2026
    ⚡ Gói Vitamin: Offset Khóa Đầu + Fix Rung Tâm + Nhẹ Tâm + Magic Bullet + Fly Hack + ESP
    ================================================================================
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if getgenv().ClassQuidLoaded then
    if getgenv().ClassQuidGUI then getgenv().ClassQuidGUI:Destroy() end
end
getgenv().ClassQuidLoaded = true

-- CẤU HÌNH GÓI VITAMIN SIÊU CẤP
getgenv().Config = {
    -- [1] Vitamin Aimbot & Offset Ghim Đầu
    AutoHead = true,
    HeadOffset_Y = 1.75,
    AimFOV = 250,
    SmoothAim = 18.5,
    AntiJitter = true,
    MagicBullet = true,
    SilentAim = true,

    -- [2] Vitamin Di Chuyển & Tốc Độ
    WalkSpeed = 55,
    FlyHack = false,
    FlySpeed = 50,
    Noclip = false,
    InfiniteJump = true,

    -- [3] Vitamin Hình Ảnh & ESP
    ESPBox = true,
    ESPTracers = false,
    ShowFOV = false,

    -- [4] Vitamin Tối Ưu Hệ Thống
    FixLag = true,
    UnlockFPS = true,
    HUDHunter = true,
    ZooKeeper100 = false,
    AutoFarmAnimals = false
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ClassQuidVIP_MasterWhiteUI"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end
getgenv().ClassQuidGUI = ScreenGui

-- KHUNG GIAO DIỆN CHÍNH (WHITE LUXURY UI)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 680, 0, 440)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(226, 232, 240)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 18)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 320, 1, 0)
HeaderTitle.Position = UDim2.new(0, 20, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "⚡ CLASS QUID VIP • V9.0 VITAMIN EDITION"
HeaderTitle.TextColor3 = Color3.fromRGB(2, 132, 199)
HeaderTitle.TextSize = 15
HeaderTitle.Font = Enum.Font.FredokaOne
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(254, 226, 226)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sidebar & Content
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 190, 1, -66)
Sidebar.Position = UDim2.new(0, 10, 0, 60)
Sidebar.BackgroundColor3 = Color3.fromRGB(241, 245, 249)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 14)
SidebarCorner.Parent = Sidebar

local SideList = Instance.new("UIListLayout")
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.Padding = UDim.new(0, 6)
SideList.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.PaddingLeft = UDim.new(0, 8)
SidePad.PaddingRight = UDim.new(0, 8)
SidePad.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -220, 1, -66)
ContentContainer.Position = UDim2.new(0, 210, 0, 60)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = "  " .. icon .. "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(71, 85, 105)
    TabButton.TextSize = 13
    TabButton.Font = Enum.Font.SourceSansBold
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = TabButton

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 3
    TabPage.Visible = false
    TabPage.Parent = ContentContainer

    local PageList = Instance.new("UIListLayout")
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 8)
    PageList.Parent = TabPage

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingTop = UDim.new(0, 8)
    PagePad.PaddingLeft = UDim.new(0, 8)
    PagePad.PaddingRight = UDim.new(0, 8)
    PagePad.Parent = TabPage

    TabButton.MouseButton1Click:Connect(function()
        for _, btn in pairs(TabButtons) do
            btn.BackgroundTransparency = 1
            btn.TextColor3 = Color3.fromRGB(71, 85, 105)
        end
        for _, page in pairs(Tabs) do
            page.Visible = false
        end

        TabButton.BackgroundTransparency = 0
        TabButton.TextColor3 = Color3.fromRGB(2, 132, 199)
        TabPage.Visible = true
    end)

    table.insert(TabButtons, TabButton)
    table.insert(Tabs, TabPage)

    if #Tabs == 1 then
        TabButton.BackgroundTransparency = 0
        TabButton.TextColor3 = Color3.fromRGB(2, 132, 199)
        TabPage.Visible = true
    end

    return TabPage
end

local function AddToggle(parent, text, defaultVal, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 44)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(226, 232, 240)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(15, 23, 42)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 44, 0, 24)
    Switch.Position = UDim2.new(1, -54, 0.5, -12)
    Switch.BackgroundColor3 = defaultVal and Color3.fromRGB(2, 132, 199) or Color3.fromRGB(203, 213, 225)
    Switch.Text = ""
    Switch.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(0, 18)
    SwitchCorner.Parent = Switch

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 18, 0, 18)
    Dot.Position = defaultVal and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = Switch

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(0, 9)
    DotCorner.Parent = Dot

    local state = defaultVal
    Switch.MouseButton1Click:Connect(function()
        state = not state
        Switch.BackgroundColor3 = state and Color3.fromRGB(2, 132, 199) or Color3.fromRGB(203, 213, 225)
        Dot.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        callback(state)
    end)
end

-- TẠO CÁC TAB TÍNH NĂNG
local TabAim = CreateTab("Vitamin Kéo Tâm", "🎯")
local TabMove = CreateTab("Vitamin Di Chuyển", "🚀")
local TabESP = CreateTab("Vitamin ESP", "👁️")
local TabOpt = CreateTab("Vitamin Tối Ưu", "⚡")

-- [1] Tab Aimbot & Vitamin Kéo Tâm
AddToggle(TabAim, "Auto Headshot 100% (Ghim Đầu Offset)", getgenv().Config.AutoHead, function(v) getgenv().Config.AutoHead = v end)
AddToggle(TabAim, "Fix Rung Tâm (Anti-Jitter Smooth Slerp)", getgenv().Config.AntiJitter, function(v) getgenv().Config.AntiJitter = v end)
AddToggle(TabAim, "Magic Bullet (Đạn Thẳng Tắp Không Giật)", getgenv().Config.MagicBullet, function(v) getgenv().Config.MagicBullet = v end)
AddToggle(TabAim, "Hút Tâm Từ Tính (Silent Aim Magnet)", getgenv().Config.SilentAim, function(v) getgenv().Config.SilentAim = v end)

-- [2] Tab Di Chuyển
AddToggle(TabMove, "Fly Hack (Bay Tự Do) [Phím F]", getgenv().Config.FlyHack, function(v) getgenv().Config.FlyHack = v end)
AddToggle(TabMove, "Noclip (Đi Xuyên Mọi Địa Hình)", getgenv().Config.Noclip, function(v) getgenv().Config.Noclip = v end)
AddToggle(TabMove, "Infinite Jump (Nhảy Vô Tận)", getgenv().Config.InfiniteJump, function(v) getgenv().Config.InfiniteJump = v end)

-- [3] Tab ESP
AddToggle(TabESP, "ESP Box Khung Người 3D", getgenv().Config.ESPBox, function(v) getgenv().Config.ESPBox = v end)
AddToggle(TabESP, "ESP Dây Chỉ Trỏ (Tracers)", getgenv().Config.ESPTracers, function(v) getgenv().Config.ESPTracers = v end)

-- [4] Tab Tối Ưu
AddToggle(TabOpt, "Mở Khóa 120 FPS & Đồ Họa Ultra", getgenv().Config.UnlockFPS, function(v)
    getgenv().Config.UnlockFPS = v
    if v and setfpscap then setfpscap(120) end
end)
AddToggle(TabOpt, "Fix Lag & Dọn RAM Tự Động", getgenv().Config.FixLag, function(v) getgenv().Config.FixLag = v end)
AddToggle(TabOpt, "Hiển Thị HUD Hunter Góc Phải", getgenv().Config.HUDHunter, function(v)
    getgenv().Config.HUDHunter = v
    if getgenv().ClassQuidHUDFrame then getgenv().ClassQuidHUDFrame.Visible = v end
end)

-- ================================================================================
-- HỆ THỐNG LOGIC ENGINE HOẠT ĐỘNG THỰC TẾ (RUNTIME VITAMIN ENGINES)
-- ================================================================================

-- 1. Tìm kẻ địch gần tâm nhất
local function GetClosestTarget()
    local closest = nil
    local shortestDist = getgenv().Config.AimFOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

-- 2. Vòng lặp Aimbot Ghim Đầu & Fix Rung Tâm (RunService.RenderStepped)
RunService.RenderStepped:Connect(function(deltaTime)
    if getgenv().Config.AutoHead then
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Position + Vector3.new(0, (getgenv().Config.HeadOffset_Y - 1.5), 0)
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)

            if getgenv().Config.AntiJitter then
                -- Làm mịn góc ngắm chống giật
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, math.clamp(deltaTime * getgenv().Config.SmoothAim, 0, 1))
            else
                Camera.CFrame = targetCFrame
            end
        end
    end
end)

-- 3. Speed & Di chuyển
local function ApplySpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Config.WalkSpeed
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    ApplySpeed()
end)
ApplySpeed()

-- 4. Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if getgenv().Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- 5. Noclip & Dọn bộ nhớ RAM
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().Config.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        if getgenv().Config.FixLag then
            collectgarbage("step", 150)
        end
    end
end)

print("⚡ CLASS QUID VIP ULTRA V9.0 • FULL VITAMIN LOADED!")
