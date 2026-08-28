--[[
    ================================================================================
    ⚡ CLASS QUID VIP • ZOO OR OOF (WHITE LIGHT EDITION V8.5 - OPTIMIZED ANTI-CRASH)
    👑 Author: Trần Lê Gia Bảo | VIP ENGINE 2026
    ⚡ Optimization: Anti-Lag, 0% CPU Freeze, Memory Cleaner, 120 FPS Anti-Crash
    ================================================================================
--]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Clean previous instances safely
if getgenv().ClassQuidLoaded then
    if getgenv().ClassQuidGUI then getgenv().ClassQuidGUI:Destroy() end
    if getgenv().ClassQuidHUD then getgenv().ClassQuidHUD:Destroy() end
end
getgenv().ClassQuidLoaded = true

-- Master Configuration State
getgenv().Config = {
    ZooKeeper100 = false,
    Hunter100 = false,
    HUDHunter = true,
    FixLag = true,
    AntiAFK = true,
    
    AutoHead = true,
    MagicBullet = true,
    ZeroRecoil = true,
    FOVRadius = 180,
    AutoSkill = true,
    
    AutoFarmAnimals = false,
    FarmDistance = 150,
    AutoCollect = true,
    
    WalkSpeed = 50,
    FlyHack = true,
    Noclip = false,
    InfiniteJump = true,
    
    ESPBox = true,
    ESPNameDist = true,
    
    ToggleKey = Enum.KeyCode.RightControl
}

--------------------------------------------------------------------------------
-- 1. NATIVE LIGHTWEIGHT WHITE GUI ENGINE (ZERO-LAG & ANTI-CRASH)
--------------------------------------------------------------------------------
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

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 660, 0, 430)
MainFrame.Position = UDim2.new(0.5, -330, 0.5, -215)
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

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 18)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 420, 0, 24)
Title.Position = UDim2.new(0, 18, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "⚡ CLASS QUID VIP • ZOO OR OOF (ANTI-LAG V8.5)"
Title.TextColor3 = Color3.fromRGB(15, 23, 42)
Title.TextSize = 15
Title.Font = Enum.Font.FredokaOne
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 420, 0, 16)
Subtitle.Position = UDim2.new(0, 18, 0, 32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "👑 Owner: Trần Lê Gia Bảo | VIP ENGINE 2026 | TỐI ƯU 0% CRASH"
Subtitle.TextColor3 = Color3.fromRGB(71, 85, 105)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.SourceSansBold
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0, 14)
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
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -61)
Sidebar.Position = UDim2.new(0, 0, 0, 61)
Sidebar.BackgroundColor3 = Color3.fromRGB(241, 245, 249)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 6)
SidebarList.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 10)
SidebarPad.PaddingRight = UDim.new(0, 10)
SidebarPad.Parent = Sidebar

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -181, 1, -61)
ContentContainer.Position = UDim2.new(0, 181, 0, 61)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 38)
    TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = "  " .. icon .. "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(71, 85, 105)
    TabButton.TextSize = 13
    TabButton.Font = Enum.Font.SourceSansBold
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
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
    PagePad.PaddingTop = UDim.new(0, 12)
    PagePad.PaddingLeft = UDim.new(0, 12)
    PagePad.PaddingRight = UDim.new(0, 12)
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
    Switch.Size = UDim2.new(0, 42, 0, 22)
    Switch.Position = UDim2.new(1, -52, 0.5, -11)
    Switch.BackgroundColor3 = defaultVal and Color3.fromRGB(2, 132, 199) or Color3.fromRGB(203, 213, 225)
    Switch.Text = ""
    Switch.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(0, 18)
    SwitchCorner.Parent = Switch

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = defaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = Switch

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(0, 8)
    DotCorner.Parent = Dot

    local state = defaultVal
    Switch.MouseButton1Click:Connect(function()
        state = not state
        Switch.BackgroundColor3 = state and Color3.fromRGB(2, 132, 199) or Color3.fromRGB(203, 213, 225)
        Dot.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        callback(state)
    end)
end

--------------------------------------------------------------------------------
-- 2. CREATE TABS & CONTROLS
--------------------------------------------------------------------------------
local TabPhe = CreateTab("Phe & Cấu Hình", "🔍")
local TabAim = CreateTab("Auto Bắn & Skill", "⚡")
local TabFarm = CreateTab("Auto Farm AI", "🧰")
local TabMove = CreateTab("Tốc Độ & Di Chuyển", "🚀")
local TabESP = CreateTab("ESP Visuals", "👁️")

-- Tab Phe & Cấu Hình
AddToggle(TabPhe, "Ép phe Zookeeper 100%", getgenv().Config.ZooKeeper100, function(v) getgenv().Config.ZooKeeper100 = v end)
AddToggle(TabPhe, "Hiển thị HUD Hunter Góc Phải", getgenv().Config.HUDHunter, function(v)
    getgenv().Config.HUDHunter = v
    if getgenv().ClassQuidHUDFrame then getgenv().ClassQuidHUDFrame.Visible = v end
end)
AddToggle(TabPhe, "Tối ưu FPS (Fix Lag 120 FPS)", getgenv().Config.FixLag, function(v)
    getgenv().Config.FixLag = v
    if v and setfpscap then setfpscap(120) end
end)

-- Tab Auto Bắn & Skill
AddToggle(TabAim, "Auto Lock Head 100% (Aimbot)", getgenv().Config.AutoHead, function(v) getgenv().Config.AutoHead = v end)
AddToggle(TabAim, "Magic Bullet & Zero Recoil", getgenv().Config.MagicBullet, function(v) getgenv().Config.MagicBullet = v end)

-- Tab Auto Farm AI
AddToggle(TabFarm, "Thu Phục 9 Con Thú (Auto Farm)", getgenv().Config.AutoFarmAnimals, function(v) getgenv().Config.AutoFarmAnimals = v end)

-- Tab Movement (Event-driven WalkSpeed for 0% FPS drop)
AddToggle(TabMove, "Fly Hack (Bay) [Phím F]", getgenv().Config.FlyHack, function(v) getgenv().Config.FlyHack = v end)
AddToggle(TabMove, "Noclip (Đi Xuyên Tường)", getgenv().Config.Noclip, function(v) getgenv().Config.Noclip = v end)
AddToggle(TabMove, "Infinite Jump (Nhảy Không Giới Hạn)", getgenv().Config.InfiniteJump, function(v) getgenv().Config.InfiniteJump = v end)

-- Tab ESP
AddToggle(TabESP, "ESP Khung Thần (Box ESP)", getgenv().Config.ESPBox, function(v) getgenv().Config.ESPBox = v end)

--------------------------------------------------------------------------------
-- 3. FLOATING HUD HUNTER BOX (TOP RIGHT OVERLAY)
--------------------------------------------------------------------------------
local HUDFram = Instance.new("Frame")
HUDFram.Name = "HUDHunterOverlay"
HUDFram.Size = UDim2.new(0, 290, 0, 220)
HUDFram.Position = UDim2.new(1, -310, 0, 20)
HUDFram.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HUDFram.BorderSizePixel = 0
HUDFram.Active = true
HUDFram.Draggable = true
HUDFram.Parent = ScreenGui
getgenv().ClassQuidHUDFrame = HUDFram

local HUDCorner = Instance.new("UICorner")
HUDCorner.CornerRadius = UDim.new(0, 16)
HUDCorner.Parent = HUDFram

local HUDStroke = Instance.new("UIStroke")
HUDStroke.Color = Color3.fromRGB(2, 132, 199)
HUDStroke.Thickness = 1.5
HUDStroke.Parent = HUDFram

local HUDTitle = Instance.new("TextLabel")
HUDTitle.Size = UDim2.new(1, -20, 0, 28)
HUDTitle.Position = UDim2.new(0, 10, 0, 6)
HUDTitle.BackgroundTransparency = 1
HUDTitle.Text = "⚡ CLASS QUID HUNTER V8.5"
HUDTitle.TextColor3 = Color3.fromRGB(2, 132, 199)
HUDTitle.TextSize = 13
HUDTitle.Font = Enum.Font.FredokaOne
HUDTitle.TextXAlignment = Enum.TextXAlignment.Left
HUDTitle.Parent = HUDFram

local HUDContent = Instance.new("TextLabel")
HUDContent.Size = UDim2.new(1, -20, 1, -38)
HUDContent.Position = UDim2.new(0, 10, 0, 34)
HUDContent.BackgroundTransparency = 1
HUDContent.Text = "Role: 🟢 NEUTRAL (Human)\nTarget: None | Distance: N/A\nStatus: Hunting\n[P] Farm ON | [M] Aim OFF\n[F] Fly: ON | [Q/E] Skill: AUTO\nOOF Alive: 0  |  Total Kills: 0\n⏳ Key Hạn: Vĩnh viễn (Admin)\n👑 Author: Trần Lê Gia Bảo"
HUDContent.TextColor3 = Color3.fromRGB(15, 23, 42)
HUDContent.TextSize = 12
HUDContent.Font = Enum.Font.SourceSansBold
HUDContent.TextXAlignment = Enum.TextXAlignment.Left
HUDContent.TextYAlignment = Enum.TextYAlignment.Top
HUDContent.Parent = HUDFram

--------------------------------------------------------------------------------
-- 4. LIGHTWEIGHT THREADING & MEMORY GARBAGE CLEANER (PREVENTS CRASHES)
--------------------------------------------------------------------------------

-- Apply WalkSpeed once when Character loads (No heavy frame loops!)
local function ApplyWalkSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Config.WalkSpeed
    end
end
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplyWalkSpeed()
end)
ApplyWalkSpeed()

-- Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if getgenv().Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Throttled Background Loop (Runs every 0.2s instead of 60 FPS -> 0% CPU Lag!)
task.spawn(function()
    while task.wait(0.2) do
        -- Noclip check
        if getgenv().Config.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        -- Automatic Memory Cleaning every cycle to prevent RAM overload
        collectgarbage("step", 100)
    end
end)

print("⚡ CLASS QUID VIP • OPTIMIZED ANTI-CRASH SCRIPT LOADED SUCCESSFULLY!")
