-- // =================================================================
-- // ⚡ CLASS QUID VIP • BUILD A BOAT FOR TREASURE (SUPER PREMIUM V9.1)
-- // COPYRIGHT © 2026 TRẦN LÊ GIA BẢO. ALL RIGHTS RESERVED.
-- // Engineered with Ultra Smooth Farm & Smart Quest Engine & Multi-Slot Saver.
-- // Enhanced with Auto Codes, Secret ESP, Plot Teleports, Invisible Water Walker & Anti-Lag.
-- // Integrated with GitHub Commit SHA Live Fetching & 24H Key System.
-- // =================================================================

-- Đợi game tải hoàn tất
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Engine = {
    Services = {},
    Modules = {},
    Cache = { 
        Stages = {}, 
        GoldenChest = nil, 
        TotalRuns = 0, 
        EstimatedGold = 0, 
        LastStatus = "Idle", 
        QuestsCompleted = 0, 
        SavedBoats = {},
        EspBoxes = {}
    },
    State = { 
        IsFarming = false, 
        FarmConnections = {}, 
        IsDoingQuest = false, 
        CurrentStageIndex = 0,
        JesusPlatform = nil
    },
    Status = "Booting",
    Author = "Trần Lê Gia Bảo",
    
    CustomLogoID = "https://github.com/giabaotranle04112011/zoo-or-oof-by-giabaotranle04112011/blob/main/bun.jpg",
    
    CachedLogoAsset = nil,
    IsFetchingLogo = false,
    
    GetLogoAsset = function(self)
        if self.CachedLogoAsset then
            return self.CachedLogoAsset
        end

        local rawUrl = "https://raw.githubusercontent.com/giabaotranle04112011/zoo-or-oof-by-giabaotranle04112011/main/bun.jpg"
        local getasset = getcustomasset or getsynasset or custom_asset
        
        -- Kiểm tra file bun.jpg trong local storage (tải nhanh 0ms)
        if isfile and isfile("bun.jpg") and getasset then
            local ok, asset = pcall(function() return getasset("bun.jpg") end)
            if ok and asset then 
                self.CachedLogoAsset = asset
                return asset 
            end
        end

        -- Tải ngầm không gây giật lag game
        if not self.IsFetchingLogo then
            self.IsFetchingLogo = true
            task.spawn(function()
                local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
                local imageBytes = nil

                if httpRequest then
                    pcall(function()
                        local res = httpRequest({ Url = rawUrl, Method = "GET" })
                        if res and res.Body and #res.Body > 100 then imageBytes = res.Body end
                    end)
                end
                if not imageBytes then
                    pcall(function()
                        local b = game:HttpGet(rawUrl)
                        if b and #b > 100 then imageBytes = b end
                    end)
                end

                if imageBytes and writefile and getasset then
                    pcall(function() writefile("bun.jpg", imageBytes) end)
                    pcall(function() self.CachedLogoAsset = getasset("bun.jpg") end)
                end

                if not self.CachedLogoAsset then
                    self.CachedLogoAsset = rawUrl
                end
                self.IsFetchingLogo = false
            end)
        end

        return rawUrl
    end
}

-- Hàm chuẩn hóa chuỗi
local function CleanStr(str)
    if not str or typeof(str) ~= "string" then return "" end
    str = str:gsub("%s+", ""):gsub("[%r%n]", "")
    return str:upper()
end

-- ==========================================
-- [1] SERVICES & GLOBALS
-- ==========================================
Engine.Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UIS = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    HttpService = game:GetService("HttpService"),
    TweenService = game:GetService("TweenService"),
    VirtualUser = game:GetService("VirtualUser"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Lighting = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui"),
    TeleportService = game:GetService("TeleportService")
}

local LocalPlayer = Engine.Services.Players.LocalPlayer
local Camera = Engine.Services.Workspace.CurrentCamera

-- Helper lấy GUI Parent an toàn chống crash
local function GetSafeGuiParent()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local g = Instance.new("Folder")
        syn.protect_gui(g)
        g.Parent = Engine.Services.CoreGui
        return g
    else
        return Engine.Services.CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    end
end

local GuiParent = GetSafeGuiParent()

-- Dọn dẹp GUI cũ trước khi khởi động
if getgenv().ClassQuidBABFT_Loaded then
    pcall(function()
        local list = {
            "RBZoo_V8_LoadingScreen", "ClassQuid_BABFT_LoadingGUI", "ClassQuid_BABFT_KeyGUI", 
            "ClassQuid_BABFT_HUD", "ClassQuid_BABFT_MobileBtn", "ClassQuid_BABFT_MasterGUI", 
            "RBZoo_KeySystem_UI", "ClassQuid_BABFT_LiquidGlass", "ClassQuid_BABFT_Notifications",
            "ClassQuid_BABFT_ESP"
        }
        for _, name in ipairs(list) do
            local g = GuiParent:FindFirstChild(name) or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(name)
            if g then g:Destroy() end
        end
    end)
end
getgenv().ClassQuidBABFT_Loaded = true

-- ==========================================
-- [2] CONFIG MANAGER
-- ==========================================
Engine.Modules.ConfigManager = {
    Settings = {
        -- Auto Farm Vàng
        AutoFarm = false,
        FarmSpeed = 160,
        FlyHeight = 75,
        ChestWaitTime = 16,
        FastSuicide = true,
        AntiWaterDamage = true,

        -- Auto Quests
        AutoQuest = false,
        SelectedQuest = "All",
        QuestDelay = 1.5,

        -- Boat Save / Load System
        SelectedSlot = 1,
        AutoSaveSlot = false,
        AutoLoadOnSpawn = false,
        SavedBoatFileName = "MyBoat_1",

        -- Auto Shop Rương
        AutoBuyChest = false,
        ChestType = "Common Chest",
        BuyInterval = 1.5,

        -- Di chuyển & Fly
        Fly = false,
        FlySpeed = 80,
        Speed = false,
        SpeedValue = 48,
        JumpPower = false,
        JumpPowerValue = 100,
        Noclip = false,
        InfJump = true,

        -- Tiện ích Nâng Cao VIP (New Cool Features)
        JesusMode = false,          -- Đi bộ trên nước tàng hình
        JesusHeightOffset = 0,      -- Thanh điều chỉnh độ cao đứng trên nước
        Godmode = true,             -- Chống vật cản bẫy đá 
        ChestESP = false,           -- Soi Rương Vàng & Vật Phẩm Bí Mật
        AutoRejoin = true,          -- Tự kết nối lại khi văng game

        -- Hệ thống & Tiện ích
        FPSBooster = true,
        AntiAFK = true,
        ShowHUD = true,
        EnableNotifications = true,
        SilentMode = false,
        LightingMode = "Normal",
        LightingBrightness = 2.5,
        LightingClockTime = 14,
        UITheme = "Dark",
        Language = "VN"
    },
    File = "ClassQuid_BABFT_Config_V9_0.json",

    Load = function(self)
        if isfile and readfile and isfile(self.File) then
            pcall(function()
                local decoded = Engine.Services.HttpService:JSONDecode(readfile(self.File))
                for k, v in pairs(decoded) do
                    if self.Settings[k] ~= nil then self.Settings[k] = v end
                end
            end)
        end
    end,

    Save = function(self)
        pcall(function()
            if writefile then
                writefile(self.File, Engine.Services.HttpService:JSONEncode(self.Settings))
            end
        end)
    end
}

-- ==========================================
-- [3] FPS & PERFORMANCE BOOSTER ENGINE
-- ==========================================
Engine.Modules.PerformanceBooster = {
    Init = function(self)
        if not Engine.Modules.ConfigManager.Settings.FPSBooster then return end
        pcall(function()
            if setfpscap then setfpscap(120) end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Engine.Services.Workspace.GlobalShadows = false
            for _, v in ipairs(Engine.Services.Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CastShadow = false
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
        end)
    end
}

-- ==========================================
-- [3.5] INTERNATIONALIZATION (I18N) LANGUAGE ENGINE (VN / EN)
-- ==========================================
Engine.Modules.I18n = {
    Current = "VN",
    
    Translations = {
        VN = {
            Title = "BABFT V9.1 • CLASS QUID VIP",
            SubTitle = "Owner: Trần Lê Gia Bảo  |  Build A Boat For Treasure",
            LoadingTitle = "⚡ CLASS QUID VIP V9.1",
            LoadingStatus = "🚀 Khởi động Class Quid VIP Engine...",
            Step1 = "⚡ [1/5] Nạp Service & Cấu hình BABFT Config...",
            Step2 = "🚀 [2/5] Kích hoạt Engine Tối ưu hóa FPS & Fix Lag...",
            Step3 = "🛡️ [3/5] Kích hoạt Anti-Water & Auto Quests Engine...",
            Step4 = "🔑 [4/5] Kết nối Server Key getkeyfree24h.netlify.app...",
            Step5 = "✨ [5/5] Nạp hoàn tất! Đang khởi chạy giao diện...",
            
            KeySystemTitle = "🔐 CLASS QUID KEY SYSTEM V9.1",
            KeySystemDesc = "Lấy Key miễn phí 24h tại: getkeyfree24h.netlify.app hoặc tham gia Discord chính thức.",
            PlaceholderKey = "Nhập Key (FREE-XXXX-XXXX) hoặc Mã Admin...",
            BtnGetKey = "🌐 LẤY KEY 24H",
            BtnDiscord = "💬 DISCORD",
            BtnVerify = "✔️ XÁC NHẬN",
            BtnLogout = "🚪 ĐĂNG XUẤT KEY",
            CopyKeySuccess = "✓ Đã sao chép Link Get Key: ",
            CopyDiscordSuccess = "✓ Đã sao chép Link Discord: ",
            Verifying = "⏳ Đang kết nối Server kiểm tra Key...",
            KeyValid = "✓ Key hợp lệ! Đang mở Script Class Quid...",
            AdminBypass = "👑 Đã kích hoạt CHẾ ĐỘ ADMIN BYPASS!",
            KeyRemaining = "Thời gian còn lại: ",
            
            TabFarm = "⛵ Auto Farm Vàng",
            TabQuest = "📜 Tự Làm NV [BETA]",
            TabBoatSave = "🛠️ Lưu Thuyền [BETA]",
            TabChest = "📦 Mua Rương & Shop",
            TabMovement = "🚀 Tốc Độ & Bay",
            TabExtraVIP = "⭐ Tính Năng VIP",
            TabWorld = "☀️ Ánh Sáng & Map",
            TabSystem = "⚙️ Hệ Thống & Fix Lag",
            TabKey = "🔑 Hệ Thống Key",
            TabLanguage = "🌐 Ngôn Ngữ (Language)",
            
            SecFarm = "⛵ AUTO FARM VÀNG SIÊU TỐC (0% LAG)",
            SecQuest = "📜 AUTO HOÀN THÀNH NHIỆM VỤ (BETA)",
            SecBoatSlot = "💾 QUẢN LÝ SLOT THUYỀN (BETA)",
            SecBoatFile = "📁 LƯU & XÂY THUYỀN TỪ FILE (BETA)",
            SecChest = "📦 AUTO MUA RƯƠNG TỰ ĐỘNG",
            SecMovement = "🚀 FLIGHT & MOVEMENT ENGINE",
            SecExtraVIP = "⭐ TÍNH NĂNG ĐỘC QUYỀN VIP & HACK TIỆN ÍCH",
            SecPlotTeleport = "🚩 DỊCH CHUYỂN NHANH ĐẾN CÁC KHU ĐẤT (PLOTS)",
            SecWorldLighting = "☀️🌅🌙 THỜI GIAN & ÁNH SÁNG BẢN ĐỒ",
            SecSystem = "⚙️ CÀI ĐẶT HỆ THỐNG & FIX LAG",
            SecKey = "🔑 QUẢN LÝ TÀI KHOẢN & KEY",
            SecLang = "🌐 CÀI ĐẶT NGÔN NGỮ",

            NoticeQuestBeta = "⚠️ TÍNH NĂNG ĐANG THỬ NGHIỆM: Nhiệm vụ tự động gửi Remote qua Server game. Nếu mạng lag có thể cần bấm làm lại.",
            NoticeBoatBeta = "⚠️ TÍNH NĂNG ĐANG THỬ NGHIỆM: Lưu/Xây thuyền từ File. Hãy đứng gần trung tâm sân và chuẩn bị đủ khối.",
            
            AutoFarm = "Tự Động Farm Vàng (Tween 10 Ải) [P]",
            FarmSpeed = "Tốc độ bay qua ải",
            FlyHeight = "Độ cao an toàn (Tránh bẫy)",
            ChestWaitTime = "Thời gian chờ nổ vàng (Giây)",
            FastSuicide = "Tự sát hồi sinh nhanh (Fast Respawn)",
            AntiWaterDamage = "Chống sát thương nước (Anti-Water)",

            BtnDoAllQuests = "✨ TỰ ĐỘNG LÀM TẤT CẢ NHIỆM VỤ (ALL QUESTS)",
            BtnQuestCloud = "☁️ Làm NV Mây (Cloud Quest)",
            BtnQuestTarget = "🎯 Làm NV Bia Ngắm (Target Quest)",
            BtnQuestRamp = "🛹 Làm NV Cầu Trượt (Ramp Quest)",
            BtnQuestFindMe = "🧈 Làm NV Tìm Khối Bơ (Find Me)",
            BtnQuestTheBox = "📦 Làm NV Chiếc Hộp (The Box)",
            BtnQuestSoccer = "⚽ Làm NV Bóng Đá (Soccer Quest)",
            BtnQuestThinIce = "🧊 Làm NV Băng Mỏng (Thin Ice)",
            BtnQuestDragon = "🐉 Làm NV Đánh Rồng (Dragon Quest)",

            BtnSaveSlot = "💾 Lưu Thuyền Vào Slot Hiện Tại",
            BtnLoadSlot = "🚀 Tải Thuyền Từ Slot Hiện Tại",
            AutoSaveSlot = "Tự động Lưu Thuyền định kỳ (Auto Save)",
            AutoLoadOnSpawn = "Tự động Tải lại Thuyền khi hồi sinh",
            BtnSaveToFile = "📁 Lưu Thuyền Thành File JSON",
            BtnLoadFromFile = "🔨 Tự Động Xây & Tải Thuyền Từ File",
            PlaceholderBoatName = "Tên file thuyền (vd: MyBoat_1)...",

            AutoBuyChest = "Tự động mua Rương khi đủ Vàng",
            BuyInterval = "Thời gian cách nhau mỗi lần mua (s)",
            
            Fly = "Chế độ bay (Fly Mode) [F]",
            FlySpeed = "Tốc độ bay",
            WalkSpeed = "Tăng tốc chạy (WalkSpeed)",
            SpeedValue = "Giá trị tốc độ",
            JumpPower = "Tăng lực nhảy (JumpPower)",
            JumpPowerValue = "Giá trị lực nhảy",
            Noclip = "Đi xuyên vật thể (Noclip)",
            InfJump = "Nhảy vô tận (Inf Jump)",

            BtnRedeemCodes = "🎁 TỰ ĐỘNG NHẬP MỌI CODE BABFT (NHẬN VÀNG & QUÀ)",
            BtnClaimGifts = "🎉 TỰ ĐỘNG NHẬN QUÀ TẶNG HÀNG NGÀY (DAILY GIFTS)",
            JesusMode = "🌊 Đi Bộ Trên Mặt Nước (Jesus Water Walker)",
            JesusHeight = "Độ cao đứng trên nước (Độ cao sàn)",
            Godmode = "🛡️ Chống Mọi Sát Thương Bẫy / Đá Rơi (Godmode)",
            ChestESP = "👁️ Soi Rương & Vật Phẩm Ẩn (Golden Chest ESP)",
            AutoRejoin = "🔄 Tự Động Kết Nối Lại Khi Văng Game (Auto Rejoin)",

            TimeDay = "☀️ Ban Sáng",
            TimeSunset = "🌅 Hoàng Hôn",
            TimeNight = "🌙 Buổi Tối",
            TimeDefault = "🍃 Mặc Định",

            ShowHUD = "Hiển thị HUD Farmer Góc Trái",
            EnableNotifications = "🔔 Bật / Tắt Thông Báo (Notifications)",
            SilentMode = "🔕 Chế độ Im Lặng (Silent Mode)",
            FPSBooster = "Tối ưu FPS (Fix Lag 120 FPS)",
            AntiAFK = "Chống văng AFK (24/7)",
            
            KeyInfoTitle = "🔑 THÔNG TIN KEY & CỘNG ĐỒNG",
            KeyVal = "Mã Key: ",
            KeyWebBtn = "🌐 Trang Get Key 24h: getkeyfree24h.netlify.app",
            KeyDiscordBtn = "💬 Tham Gia Server Discord: discord.gg/rMJAhJwgW",
            SwitchLangBtn = "🌐 Chuyển Ngôn Ngữ / Switch Language (VN ➔ EN)"
        },
        EN = {
            Title = "BABFT V9.1 • CLASS QUID VIP",
            SubTitle = "Owner: Trần Lê Gia Bảo  |  Build A Boat For Treasure",
            LoadingTitle = "⚡ CLASS QUID VIP V9.1",
            LoadingStatus = "🚀 Booting Class Quid VIP Engine...",
            Step1 = "⚡ [1/5] Loading Services & BABFT Config...",
            Step2 = "🚀 [2/5] Enabling FPS Booster & Anti-Lag Engine...",
            Step3 = "🛡️ [3/5] Activating Anti-Water & Auto Quests Engine...",
            Step4 = "🔑 [4/5] Connecting Key Server getkeyfree24h.netlify.app...",
            Step5 = "✨ [5/5] Loading Complete! Launching Interface...",
            
            KeySystemTitle = "🔐 CLASS QUID KEY SYSTEM V9.1",
            KeySystemDesc = "Get free 24h key at getkeyfree24h.netlify.app or join official Discord.",
            PlaceholderKey = "Enter Key (FREE-XXXX-XXXX) or Admin Code...",
            BtnGetKey = "🌐 GET KEY 24H",
            BtnDiscord = "💬 DISCORD",
            BtnVerify = "✔️ VERIFY",
            BtnLogout = "🚪 LOGOUT KEY",
            CopyKeySuccess = "✓ Copied Get Key Link: ",
            CopyDiscordSuccess = "✓ Copied Discord Link: ",
            Verifying = "⏳ Connecting to Key Verification Server...",
            KeyValid = "✓ Key Valid! Launching Class Quid Script...",
            AdminBypass = "👑 ADMIN BYPASS MODE ACTIVATED!",
            KeyRemaining = "Remaining Time: ",
            
            TabFarm = "⛵ Auto Farm Gold",
            TabQuest = "📜 Auto Quests [BETA]",
            TabBoatSave = "🛠️ Boat Saves [BETA]",
            TabChest = "📦 Chest & Shop",
            TabMovement = "🚀 Movement & Fly",
            TabExtraVIP = "⭐ VIP Features",
            TabWorld = "☀️ Lighting & Map",
            TabSystem = "⚙️ System & Fix Lag",
            TabKey = "🔑 Key System",
            TabLanguage = "🌐 Language (Ngôn Ngữ)",
            
            SecFarm = "⛵ ULTRA GOLD AUTO FARM (0% LAG)",
            SecQuest = "📜 AUTO COMPLETE ALL QUESTS (BETA)",
            SecBoatSlot = "💾 IN-GAME BOAT SAVE SLOTS (BETA)",
            SecBoatFile = "📁 FILE BOAT SAVER & BUILDER (BETA)",
            SecChest = "📦 AUTO BUY CHEST",
            SecMovement = "🚀 FLIGHT & MOVEMENT ENGINE",
            SecExtraVIP = "⭐ EXCLUSIVE VIP & UTILITY HACKS",
            SecPlotTeleport = "🚩 QUICK PLOT TELEPORTS",
            SecWorldLighting = "☀️🌅🌙 WORLD TIME & LIGHTING",
            SecSystem = "⚙️ SYSTEM SETUP & ANTI-LAG",
            SecKey = "🔑 ACCOUNT & KEY SYSTEM",
            SecLang = "🌐 LANGUAGE SETTINGS",

            NoticeQuestBeta = "⚠️ EXPERIMENTAL FEATURE: Quests run automatically via game remotes. Retry if lag occurs.",
            NoticeBoatBeta = "⚠️ EXPERIMENTAL FEATURE: File Boat Saver/Builder. Stand near plot center with blocks ready.",
            
            AutoFarm = "Auto Farm Gold (Tween 10 Stages) [P]",
            FarmSpeed = "Tween Flight Speed",
            FlyHeight = "Safe Flight Altitude",
            ChestWaitTime = "Chest Open Wait Time (s)",
            FastSuicide = "Fast Suicide / Respawn Loop",
            AntiWaterDamage = "Anti-Water Damage Protection",

            BtnDoAllQuests = "✨ AUTO COMPLETE ALL QUESTS",
            BtnQuestCloud = "☁️ Complete Cloud Quest",
            BtnQuestTarget = "🎯 Complete Target Quest",
            BtnQuestRamp = "🛹 Complete Ramp Quest",
            BtnQuestFindMe = "🧈 Complete Find Me Quest",
            BtnQuestTheBox = "📦 Complete The Box Quest",
            BtnQuestSoccer = "⚽ Complete Soccer Quest",
            BtnQuestThinIce = "🧊 Complete Thin Ice Quest",
            BtnQuestDragon = "🐉 Complete Dragon Quest",

            BtnSaveSlot = "💾 Save Boat to Current Slot",
            BtnLoadSlot = "🚀 Load Boat from Current Slot",
            AutoSaveSlot = "Periodic Auto Save Boat",
            AutoLoadOnSpawn = "Auto Load Boat upon Respawn",
            BtnSaveToFile = "📁 Save Boat to JSON File",
            BtnLoadFromFile = "🔨 Auto Build & Load from File",
            PlaceholderBoatName = "Boat file name (e.g. MyBoat_1)...",

            AutoBuyChest = "Auto Buy Chest when enough Gold",
            BuyInterval = "Buy Interval (s)",
            
            Fly = "Fly Mode [F]",
            FlySpeed = "Flight Speed",
            WalkSpeed = "WalkSpeed Booster",
            SpeedValue = "Speed Value",
            JumpPower = "JumpPower Booster",
            JumpPowerValue = "Jump Value",
            Noclip = "Noclip (Walk Through Walls)",
            InfJump = "Infinite Jump",

            BtnRedeemCodes = "🎁 AUTO REDEEM ALL BABFT CODES (FREE GOLD/BLOCKS)",
            BtnClaimGifts = "🎉 AUTO CLAIM DAILY / FREE GIFTS",
            JesusMode = "🌊 Jesus Mode (Walk On Water)",
            JesusHeight = "Water Standing Height (Offset)",
            Godmode = "🛡️ Obstacle Godmode (No Stage Trap Damage)",
            ChestESP = "👁️ Golden Chest & Hidden Items ESP",
            AutoRejoin = "🔄 Auto Reconnect on Disconnect",

            TimeDay = "☀️ Day",
            TimeSunset = "🌅 Sunset",
            TimeNight = "🌙 Night",
            TimeDefault = "🍃 Default",

            ShowHUD = "Show Farmer HUD (Top Left)",
            EnableNotifications = "Enable Notifications",
            SilentMode = "Silent Mode (No Notifications)",
            FPSBooster = "FPS Booster (Fix Lag 120 FPS)",
            AntiAFK = "Anti-AFK Protection (24/7)",
            
            KeyInfoTitle = "🔑 KEY INFO & COMMUNITY",
            KeyVal = "Current Key: ",
            KeyWebBtn = "🌐 Get Key 24h Web: getkeyfree24h.netlify.app",
            KeyDiscordBtn = "💬 Join Discord Server: discord.gg/rMJAhJwgW",
            SwitchLangBtn = "🌐 Switch Language / Chuyển Ngôn Ngữ (EN ➔ VN)"
        }
    },

    Get = function(self, key)
        local lang = Engine.Modules.ConfigManager.Settings.Language or self.Current or "VN"
        local dict = self.Translations[lang] or self.Translations["VN"]
        return dict[key] or key
    end,

    ToggleLang = function(self)
        local curr = Engine.Modules.ConfigManager.Settings.Language or "VN"
        local newLang = (curr == "VN") and "EN" or "VN"
        Engine.Modules.ConfigManager.Settings.Language = newLang
        self.Current = newLang
        Engine.Modules.ConfigManager:Save()
        return newLang
    end
}

-- ==========================================
-- [4] VIP ANIMATED LOADING SCREEN ENGINE
-- ==========================================
Engine.Modules.LoadingScreen = {
    Show = function(self)
        local coreGui = GuiParent
        local sg = Instance.new("ScreenGui")
        sg.Name = "RBZoo_V8_LoadingScreen"
        sg.ResetOnSpawn = false
        sg.Parent = coreGui

        -- 🌌 Cyber Dark Background with Floating Particles
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(6, 8, 15)
        bg.BackgroundTransparency = 0.05
        bg.Parent = sg

        -- 💫 Floating Energy Particles Background System
        local particles = {}
        for i = 1, 24 do
            local particle = Instance.new("Frame")
            local pSize = math.random(4, 10)
            particle.Size = UDim2.new(0, pSize, 0, pSize)
            particle.Position = UDim2.new(math.random(5, 95) / 100, 0, math.random(10, 100) / 100, 0)
            particle.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(0, 255, 170)
            particle.BackgroundTransparency = math.random(40, 80) / 100
            particle.Parent = bg
            Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
            table.insert(particles, {Obj = particle, Speed = math.random(15, 35) / 10, OrigX = particle.Position.X.Scale})
        end

        -- 🌀 Outer Hologram Pulsing Halo Ring
        local outerHalo = Instance.new("Frame")
        outerHalo.Size = UDim2.new(0, 510, 0, 290)
        outerHalo.Position = UDim2.new(0.5, -255, 0.5, -145)
        outerHalo.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
        outerHalo.BackgroundTransparency = 0.88
        outerHalo.Parent = bg
        Instance.new("UICorner", outerHalo).CornerRadius = UDim.new(0, 26)

        -- 💎 Main Cyberpunk Glass VIP Card
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 480, 0, 270)
        card.Position = UDim2.new(0.5, -240, 0.5, -135)
        card.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
        card.BackgroundTransparency = 0.12
        card.ClipsDescendants = true
        card.Parent = bg
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 22)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2.4
        stroke.Color = Color3.fromRGB(0, 240, 255)
        stroke.Parent = card

        -- 👑 Header Logo Badge with Glowing Hologram Ring
        local logoAsset = Engine:GetLogoAsset()
        local titleXOffset = 25
        if logoAsset then
            local logoFrame = Instance.new("Frame")
            logoFrame.Size = UDim2.new(0, 56, 0, 56)
            logoFrame.Position = UDim2.new(0, 24, 0, 20)
            logoFrame.BackgroundColor3 = Color3.fromRGB(18, 25, 42)
            logoFrame.Parent = card
            Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0, 14)

            local logoImg = Instance.new("ImageLabel")
            logoImg.Size = UDim2.new(1, 0, 1, 0)
            logoImg.BackgroundTransparency = 1
            logoImg.Image = logoAsset
            logoImg.ScaleType = Enum.ScaleType.Crop
            logoImg.Parent = logoFrame
            Instance.new("UICorner", logoImg).CornerRadius = UDim.new(0, 14)

            local logoStroke = Instance.new("UIStroke")
            logoStroke.Thickness = 1.8
            logoStroke.Color = Color3.fromRGB(0, 240, 255)
            logoStroke.Parent = logoFrame

            titleXOffset = 95
        end

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, - (titleXOffset + 20), 0, 30)
        title.Position = UDim2.new(0, titleXOffset, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = "👑 CLASS QUID VIP V9.1"
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 17
        title.TextColor3 = Color3.fromRGB(0, 240, 255)
        title.TextXAlignment = (titleXOffset > 25) and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
        title.Parent = card

        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, - (titleXOffset + 20), 0, 20)
        sub.Position = UDim2.new(0, titleXOffset, 0, 50)
        sub.BackgroundTransparency = 1
        sub.Text = "Owner: " .. Engine.Author .. "  |  Build A Boat For Treasure"
        sub.Font = Enum.Font.GothamBold
        sub.TextSize = 10
        sub.TextColor3 = Color3.fromRGB(0, 255, 180)
        sub.TextXAlignment = (titleXOffset > 25) and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
        sub.Parent = card

        -- 📊 Neon Progress Bar Container
        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(0.88, 0, 0, 14)
        barBg.Position = UDim2.new(0.06, 0, 0, 130)
        barBg.BackgroundColor3 = Color3.fromRGB(20, 28, 46)
        barBg.Parent = card
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        barFill.Parent = barBg
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

        local barGlow = Instance.new("UIStroke")
        barGlow.Thickness = 1.8
        barGlow.Color = Color3.fromRGB(0, 255, 180)
        barGlow.Transparency = 0.3
        barGlow.Parent = barFill

        -- Light Beam Scanner Moving Inside Bar
        local lightScanner = Instance.new("Frame")
        lightScanner.Size = UDim2.new(0.2, 0, 1, 0)
        lightScanner.Position = UDim2.new(0, 0, 0, 0)
        lightScanner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        lightScanner.BackgroundTransparency = 0.5
        lightScanner.Parent = barFill
        Instance.new("UICorner", lightScanner).CornerRadius = UDim.new(1, 0)

        local percentLabel = Instance.new("TextLabel")
        percentLabel.Size = UDim2.new(1, 0, 0, 24)
        percentLabel.Position = UDim2.new(0, 0, 0, 154)
        percentLabel.BackgroundTransparency = 1
        percentLabel.Text = "0%"
        percentLabel.Font = Enum.Font.GothamBlack
        percentLabel.TextSize = 15
        percentLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
        percentLabel.Parent = card

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -40, 0, 22)
        statusLabel.Position = UDim2.new(0, 20, 0, 192)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = Engine.Modules.I18n:Get("LoadingStatus")
        statusLabel.Font = Enum.Font.GothamMedium
        statusLabel.TextSize = 11.5
        statusLabel.TextColor3 = Color3.fromRGB(180, 205, 235)
        statusLabel.TextWrapped = true
        statusLabel.Parent = card

        local steps = {
            {time = 0.12, text = Engine.Modules.I18n:Get("Step1")},
            {time = 0.28, text = Engine.Modules.I18n:Get("Step2")},
            {time = 0.44, text = Engine.Modules.I18n:Get("Step3")},
            {time = 0.60, text = Engine.Modules.I18n:Get("Step4")},
            {time = 0.75, text = Engine.Modules.I18n:Get("Step5")}
        }

        -- Bounce Entrance Anim
        card.Size = UDim2.new(0, 420, 0, 230)
        card.Position = UDim2.new(0.5, -210, 0.5, -115)
        Engine.Services.TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 480, 0, 270),
            Position = UDim2.new(0.5, -240, 0.5, -135)
        }):Play()

        local totalDuration = 0.75
        local startTime = tick()
        Engine.Services.TweenService:Create(barFill, TweenInfo.new(totalDuration, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}):Play()

        local particleConnection
        particleConnection = Engine.Services.RunService.RenderStepped:Connect(function(dt)
            local now = tick()
            stroke.Color = Color3.fromHSV((now * 0.4) % 1, 0.85, 1)
            outerHalo.BackgroundColor3 = stroke.Color

            -- Animate background particles floating up
            for _, p in ipairs(particles) do
                local newY = p.Obj.Position.Y.Scale - (p.Speed * dt * 0.08)
                if newY < -0.05 then newY = 1.05 end
                local sineWiggle = math.sin(now * 2 + p.Speed) * 0.015
                p.Obj.Position = UDim2.new(p.OrigX + sineWiggle, 0, newY, 0)
            end

            -- Light beam scanner bounce
            local scanPos = (math.sin(now * 5) + 1) / 2 * 0.8
            lightScanner.Position = UDim2.new(scanPos, 0, 0, 0)
        end)

        while tick() - startTime < totalDuration do
            local elapsed = tick() - startTime
            local progress = math.clamp(elapsed / totalDuration, 0, 1)

            percentLabel.Text = math.floor(progress * 100) .. "%"

            if elapsed < 0.18 then statusLabel.Text = steps[1].text
            elseif elapsed < 0.35 then statusLabel.Text = steps[2].text
            elseif elapsed < 0.52 then statusLabel.Text = steps[3].text
            elseif elapsed < 0.68 then statusLabel.Text = steps[4].text
            else statusLabel.Text = steps[5].text
            end

            task.wait(0.03)
        end

        if particleConnection then particleConnection:Disconnect() end

        barFill.Size = UDim2.new(1, 0, 1, 0)
        percentLabel.Text = "100%"
        statusLabel.Text = "✨ " .. Engine.Modules.I18n:Get("Step5")
        task.wait(0.2)

        Engine.Services.TweenService:Create(bg, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        Engine.Services.TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 520, 0, 290),
            Position = UDim2.new(0.5, -260, 0.5, -145),
            BackgroundTransparency = 1
        }):Play()
        Engine.Services.TweenService:Create(outerHalo, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        Engine.Services.TweenService:Create(stroke, TweenInfo.new(0.35), {Transparency = 1}):Play()
        task.wait(0.38)
        sg:Destroy()
    end
}

-- ==========================================
-- [4.5] KEY SYSTEM & INSTANT LIVE FETCH MODULE
-- ==========================================
Engine.Modules.KeySystem = {
    KeyURL = "https://getkeyfree24h.netlify.app/",
    DiscordURL = "https://discord.gg/rMJAhJwgW",
    DiscordCode = "rMJAhJwgW",
    RepoOwner = "giabaotranle04112011",
    RepoName = "getkey",
    FilePath = "keys.json",
    KeySaveFile = "ClassQuid_BABFT_SavedKey.json",
    AdminKey = "14142022",
    CurrentKey = nil,
    CurrentKeyType = nil,

    JoinDiscord = function(self)
        if setclipboard or toclipboard then
            pcall(function() (setclipboard or toclipboard)(self.DiscordURL) end)
        end
        local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
        if httpRequest then
            pcall(function()
                httpRequest({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Origin"] = "https://discord.com"
                    },
                    Body = Engine.Services.HttpService:JSONEncode({
                        cmd = "INVITE_BROWSER",
                        args = { code = self.DiscordCode },
                        nonce = Engine.Services.HttpService:GenerateGUID(false)
                    })
                })
            end)
        end
        if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
            Engine.Modules.NotificationManager:Notify("Discord Community", "✓ Đã sao chép Link Discord: " .. self.DiscordURL, 4)
        end
    end,

    FetchLatestKeysJSON = function(self)
        local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
        
        local function httpGetRaw(targetUrl)
            if httpRequest then
                local success, res = pcall(function()
                    return httpRequest({
                        Url = targetUrl,
                        Method = "GET",
                        Headers = {
                            ["Cache-Control"] = "no-cache, no-store, must-revalidate",
                            ["Pragma"] = "no-cache"
                        }
                    })
                end)
                if success and res and res.Body then return res.Body end
            end
            local ok, body = pcall(function() return game:HttpGet(targetUrl) end)
            if ok then return body end
            return nil
        end

        local timestamp = os.time()
        local repoList = { self.RepoName, "zoo-or-oof-by-giabaotranle04112011" }
        for _, repo in ipairs(repoList) do
            local directUrl = string.format("https://raw.githubusercontent.com/%s/%s/main/%s?nocache=%d", self.RepoOwner, repo, self.FilePath, timestamp)
            local res = httpGetRaw(directUrl)
            if res and #res > 5 then return res end
        end

        return nil
    end,

    ValidateKeyFormat = function(self, inputKey)
        local cleaned = CleanStr(inputKey)
        if cleaned == "" then return false, "EMPTY", "" end
        
        if cleaned == CleanStr(self.AdminKey) then
            return true, "ADMIN", cleaned
        end

        local prefix, b1, b2 = cleaned:match("^([A-Z0-9]+)%-([A-Z0-9]+)%-([A-Z0-9]+)$")
        if prefix and b1 and b2 and #b1 == 4 and #b2 == 4 then
            return true, "USER", cleaned
        end

        return false, "INVALID", cleaned
    end,

    VerifyKeyOnline = function(self, inputKey)
        local isValidFormat, keyType, cleanedInput = self:ValidateKeyFormat(inputKey)
        if not isValidFormat then
            return false, "Cú pháp Key không đúng!"
        end
        
        if keyType == "ADMIN" then
            return true, "ADMIN"
        end

        local response = self:FetchLatestKeysJSON()

        if not response then
            return false, "Lỗi kết nối Server xác minh Key!"
        end

        local decodeSuccess, validKeys = pcall(function()
            return Engine.Services.HttpService:JSONDecode(response)
        end)

        if not decodeSuccess or typeof(validKeys) ~= "table" then
            return false, "Dữ liệu Server Key bị lỗi!"
        end

        local currentTime = os.time()

        for keyName, expireTimestamp in pairs(validKeys) do
            local keyToCheck = (typeof(expireTimestamp) == "string") and expireTimestamp or keyName

            if CleanStr(keyToCheck) == cleanedInput then
                if typeof(expireTimestamp) == "number" then
                    if currentTime > expireTimestamp then
                        return false, "Key này đã hết hạn sử dụng (24h)!"
                    end
                end
                return true, "USER"
            end
        end

        return false, "Key không tồn tại trên hệ thống!"
    end,

    CheckSavedKey = function(self)
        if isfile and readfile and isfile(self.KeySaveFile) then
            local success, result = pcall(function()
                return Engine.Services.HttpService:JSONDecode(readfile(self.KeySaveFile))
            end)
            if success and result and result.Key then
                local isValidOnline, keyType = self:VerifyKeyOnline(result.Key)
                if isValidOnline then
                    self.CurrentKey = CleanStr(result.Key)
                    self.CurrentKeyType = keyType
                    return true, result.Key, keyType
                end
            end
        end
        return false, nil, nil
    end,

    SaveKeyLocally = function(self, key, keyType)
        if writefile then
            pcall(function()
                local cleanedKey = CleanStr(key)
                local data = { Key = cleanedKey, Timestamp = os.time() }
                writefile(self.KeySaveFile, Engine.Services.HttpService:JSONEncode(data))
                self.CurrentKey = cleanedKey
                self.CurrentKeyType = keyType
            end)
        end
    end,

    GetRemainingTime = function(self)
        if not self.CurrentKey then
            self:CheckSavedKey()
        end
        if self.CurrentKeyType == "ADMIN" then
            return "Vĩnh viễn (Admin)"
        end
        if isfile and readfile and isfile(self.KeySaveFile) then
            local success, result = pcall(function()
                return Engine.Services.HttpService:JSONDecode(readfile(self.KeySaveFile))
            end)
            if success and result and result.Timestamp then
                local elapsed = os.time() - result.Timestamp
                local remaining = 86400 - elapsed
                if remaining <= 0 then
                    return "Đã hết hạn!"
                end
                local hours = math.floor(remaining / 3600)
                local mins = math.floor((remaining % 3600) / 60)
                local secs = remaining % 60
                return string.format("%02dh %02dm %02ds", hours, mins, secs)
            end
        end
        return "N/A"
    end,

    Logout = function(self)
        pcall(function()
            if delfile and isfile and isfile(self.KeySaveFile) then
                delfile(self.KeySaveFile)
            elseif writefile then
                writefile(self.KeySaveFile, "")
            end
        end)
        
        self.CurrentKey = nil
        self.CurrentKeyType = nil
        Engine.Modules.FarmManager:Stop()
        
        local coreGui = GuiParent
        for _, guiName in ipairs({"ClassQuid_BABFT_LiquidGlass", "ClassQuid_BABFT_HUD", "ClassQuid_BABFT_Notifications", "ClassQuid_BABFT_MobileBtn", "ClassQuid_BABFT_ESP"}) do
            local g = coreGui:FindFirstChild(guiName) or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(guiName)
            if g then g:Destroy() end
        end
        
        table.clear(Engine.Modules.UIController.ChromaObjects)
        
        task.spawn(function()
            local keyVerified = self:PromptKeyUI()
            if keyVerified then
                Engine:BootAfterKey()
            end
        end)
    end,

    PromptKeyUI = function(self)
        local isAlreadyValid, savedKey, keyType = self:CheckSavedKey()
        if isAlreadyValid then
            return true
        end

        local verified = false
        local coreGui = GuiParent
        
        local sg = Instance.new("ScreenGui")
        sg.Name = "RBZoo_KeySystem_UI"
        sg.ResetOnSpawn = false
        sg.Parent = coreGui

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
        bg.BackgroundTransparency = 0.2
        bg.Parent = sg

        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 480, 0, 285)
        card.Position = UDim2.new(0.5, -240, 0.5, -142)
        card.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
        card.Parent = bg
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(0, 240, 255)
        stroke.Parent = card

        -- Nút chuyển đổi ngôn ngữ trên cửa sổ Key System (VN / EN)
        local btnPromptLang = Instance.new("TextButton")
        btnPromptLang.Size = UDim2.new(0, 68, 0, 26)
        btnPromptLang.Position = UDim2.new(1, -80, 0, 12)
        btnPromptLang.BackgroundColor3 = Color3.fromRGB(24, 34, 52)
        btnPromptLang.Text = "🌐 " .. (Engine.Modules.ConfigManager.Settings.Language or "VN")
        btnPromptLang.Font = Enum.Font.GothamBold
        btnPromptLang.TextSize = 11
        btnPromptLang.TextColor3 = Color3.fromRGB(0, 255, 180)
        btnPromptLang.Parent = card
        Instance.new("UICorner", btnPromptLang).CornerRadius = UDim.new(0, 8)

        local logoAsset = Engine:GetLogoAsset()
        local headerOffset = 0
        if logoAsset then
            local logoImg = Instance.new("ImageLabel")
            logoImg.Size = UDim2.new(0, 42, 0, 42)
            logoImg.Position = UDim2.new(0, 20, 0, 12)
            logoImg.BackgroundTransparency = 1
            logoImg.Image = logoAsset
            logoImg.ScaleType = Enum.ScaleType.Crop
            logoImg.Parent = card
            Instance.new("UICorner", logoImg).CornerRadius = UDim.new(0, 10)
            headerOffset = 50
        end

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, - (headerOffset + 110), 0, 35)
        title.Position = UDim2.new(0, headerOffset + 20, 0, 15)
        title.BackgroundTransparency = 1
        title.Text = Engine.Modules.I18n:Get("KeySystemTitle")
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 14
        title.TextColor3 = Color3.fromRGB(0, 240, 255)
        title.TextXAlignment = (headerOffset > 0) and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
        title.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -40, 0, 32)
        desc.Position = UDim2.new(0, 20, 0, 52)
        desc.BackgroundTransparency = 1
        desc.Text = Engine.Modules.I18n:Get("KeySystemDesc")
        desc.Font = Enum.Font.GothamMedium
        desc.TextSize = 11
        desc.TextColor3 = Color3.fromRGB(180, 195, 215)
        desc.TextWrapped = true
        desc.Parent = card

        local textBoxBg = Instance.new("Frame")
        textBoxBg.Size = UDim2.new(0.9, 0, 0, 42)
        textBoxBg.Position = UDim2.new(0.05, 0, 0, 95)
        textBoxBg.BackgroundColor3 = Color3.fromRGB(25, 32, 48)
        textBoxBg.Parent = card
        Instance.new("UICorner", textBoxBg).CornerRadius = UDim.new(0, 10)

        local tbStroke = Instance.new("UIStroke")
        tbStroke.Thickness = 1
        tbStroke.Color = Color3.fromRGB(0, 240, 255)
        tbStroke.Transparency = 0.5
        tbStroke.Parent = textBoxBg

        local keyBox = Instance.new("TextBox")
        keyBox.Size = UDim2.new(1, -20, 1, 0)
        keyBox.Position = UDim2.new(0, 10, 0, 0)
        keyBox.BackgroundTransparency = 1
        keyBox.PlaceholderText = Engine.Modules.I18n:Get("PlaceholderKey")
        keyBox.PlaceholderColor3 = Color3.fromRGB(110, 125, 145)
        keyBox.Text = ""
        keyBox.Font = Enum.Font.GothamBold
        keyBox.TextSize = 12
        keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        keyBox.Parent = textBoxBg

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -20, 0, 20)
        statusLabel.Position = UDim2.new(0, 10, 0, 144)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = ""
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.TextSize = 11
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Parent = card

        local btnGetKey = Instance.new("TextButton")
        btnGetKey.Size = UDim2.new(0.28, 0, 0, 40)
        btnGetKey.Position = UDim2.new(0.05, 0, 0, 175)
        btnGetKey.BackgroundColor3 = Color3.fromRGB(30, 42, 65)
        btnGetKey.Text = Engine.Modules.I18n:Get("BtnGetKey")
        btnGetKey.Font = Enum.Font.GothamBlack
        btnGetKey.TextSize = 11
        btnGetKey.TextColor3 = Color3.fromRGB(0, 240, 255)
        btnGetKey.Parent = card
        Instance.new("UICorner", btnGetKey).CornerRadius = UDim.new(0, 10)

        local btnDiscord = Instance.new("TextButton")
        btnDiscord.Size = UDim2.new(0.3, 0, 0, 40)
        btnDiscord.Position = UDim2.new(0.35, 0, 0, 175)
        btnDiscord.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        btnDiscord.Text = Engine.Modules.I18n:Get("BtnDiscord")
        btnDiscord.Font = Enum.Font.GothamBlack
        btnDiscord.TextSize = 11
        btnDiscord.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnDiscord.Parent = card
        Instance.new("UICorner", btnDiscord).CornerRadius = UDim.new(0, 10)

        local btnVerify = Instance.new("TextButton")
        btnVerify.Size = UDim2.new(0.28, 0, 0, 40)
        btnVerify.Position = UDim2.new(0.67, 0, 0, 175)
        btnVerify.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        btnVerify.Text = Engine.Modules.I18n:Get("BtnVerify")
        btnVerify.Font = Enum.Font.GothamBlack
        btnVerify.TextSize = 11
        btnVerify.TextColor3 = Color3.fromRGB(10, 15, 25)
        btnVerify.Parent = card
        Instance.new("UICorner", btnVerify).CornerRadius = UDim.new(0, 10)

        local authorSub = Instance.new("TextLabel")
        authorSub.Size = UDim2.new(1, 0, 0, 20)
        authorSub.Position = UDim2.new(0, 0, 0, 238)
        authorSub.BackgroundTransparency = 1
        authorSub.Text = "Build A Boat For Treasure • Owner: " .. Engine.Author .. " • 24h Key"
        authorSub.Font = Enum.Font.GothamMedium
        authorSub.TextSize = 9
        authorSub.TextColor3 = Color3.fromRGB(100, 115, 135)
        authorSub.Parent = card

        local function refreshPromptLanguage()
            title.Text = Engine.Modules.I18n:Get("KeySystemTitle")
            desc.Text = Engine.Modules.I18n:Get("KeySystemDesc")
            keyBox.PlaceholderText = Engine.Modules.I18n:Get("PlaceholderKey")
            btnGetKey.Text = Engine.Modules.I18n:Get("BtnGetKey")
            btnDiscord.Text = Engine.Modules.I18n:Get("BtnDiscord")
            btnVerify.Text = Engine.Modules.I18n:Get("BtnVerify")
            btnPromptLang.Text = "🌐 " .. (Engine.Modules.ConfigManager.Settings.Language or "VN")
        end

        btnPromptLang.MouseButton1Click:Connect(function()
            Engine.Modules.I18n:ToggleLang()
            refreshPromptLanguage()
        end)

        btnGetKey.MouseButton1Click:Connect(function()
            if setclipboard or toclipboard then
                pcall(function() (setclipboard or toclipboard)(self.KeyURL) end)
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
                statusLabel.Text = Engine.Modules.I18n:Get("CopyKeySuccess") .. self.KeyURL
            else
                statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                statusLabel.Text = "Link: " .. self.KeyURL
            end
        end)

        btnDiscord.MouseButton1Click:Connect(function()
            self:JoinDiscord()
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
            statusLabel.Text = Engine.Modules.I18n:Get("CopyDiscordSuccess") .. self.DiscordURL
        end)

        btnVerify.MouseButton1Click:Connect(function()
            local input = keyBox.Text
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            statusLabel.Text = Engine.Modules.I18n:Get("Verifying")

            task.spawn(function()
                local isValidOnline, resultMessage = self:VerifyKeyOnline(input)

                if isValidOnline then
                    self:SaveKeyLocally(input, resultMessage)
                    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
                    if resultMessage == "ADMIN" then
                        statusLabel.Text = Engine.Modules.I18n:Get("AdminBypass")
                    else
                        statusLabel.Text = Engine.Modules.I18n:Get("KeyValid")
                    end
                    task.wait(0.8)
                    verified = true
                    sg:Destroy()
                else
                    statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
                    statusLabel.Text = "❌ " .. tostring(resultMessage)
                end
            end)
        end)

        repeat task.wait(0.1) until verified
        return true
    end
}

-- ==========================================
-- [5] NOTIFICATION MANAGER
-- ==========================================
Engine.Modules.NotificationManager = {
    Container = nil,
    Init = function(self)
        local coreGui = GuiParent
        local sg = Instance.new("ScreenGui")
        sg.Name = "ClassQuid_BABFT_Notifications"
        sg.ResetOnSpawn = false
        sg.Parent = coreGui
        
        self.Container = Instance.new("Frame")
        self.Container.Size = UDim2.new(0, 320, 1, -20)
        self.Container.Position = UDim2.new(1, -340, 0, 10)
        self.Container.BackgroundTransparency = 1
        self.Container.Parent = sg
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 8)
        layout.Parent = self.Container
    end,
    
    Notify = function(self, title, text, duration)
        if Engine.Modules.ConfigManager and Engine.Modules.ConfigManager.Settings then
            if Engine.Modules.ConfigManager.Settings.EnableNotifications == false or Engine.Modules.ConfigManager.Settings.SilentMode == true then 
                return 
            end
        end
        duration = duration or 3.5
        if not self.Container then self:Init() end
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 68)
        frame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
        frame.BackgroundTransparency = 1
        frame.ClipsDescendants = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.4
        stroke.Transparency = 1
        stroke.Color = Color3.fromRGB(0, 240, 255)
        stroke.Parent = frame
        
        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 4, 1, 0)
        accentBar.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        accentBar.BackgroundTransparency = 1
        accentBar.Parent = frame
        Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 4)
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -24, 0, 22)
        titleLabel.Position = UDim2.new(0, 16, 0, 8)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextTransparency = 1
        titleLabel.Font = Enum.Font.GothamBlack
        titleLabel.TextSize = 12
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = frame
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -24, 0, 26)
        textLabel.Position = UDim2.new(0, 16, 0, 30)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(190, 205, 225)
        textLabel.TextTransparency = 1
        textLabel.Font = Enum.Font.GothamMedium
        textLabel.TextSize = 10.5
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.Parent = frame

        local timerBar = Instance.new("Frame")
        timerBar.Size = UDim2.new(1, 0, 0, 3)
        timerBar.Position = UDim2.new(0, 0, 1, -3)
        timerBar.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        timerBar.BackgroundTransparency = 1
        timerBar.Parent = frame
        
        frame.Parent = self.Container
        
        local TweenInfoIn = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        Engine.Services.TweenService:Create(frame, TweenInfoIn, {BackgroundTransparency = 0.22}):Play()
        Engine.Services.TweenService:Create(stroke, TweenInfoIn, {Transparency = 0.35}):Play()
        Engine.Services.TweenService:Create(accentBar, TweenInfoIn, {BackgroundTransparency = 0}):Play()
        Engine.Services.TweenService:Create(titleLabel, TweenInfoIn, {TextTransparency = 0}):Play()
        Engine.Services.TweenService:Create(textLabel, TweenInfoIn, {TextTransparency = 0}):Play()
        Engine.Services.TweenService:Create(timerBar, TweenInfoIn, {BackgroundTransparency = 0.2}):Play()
        Engine.Services.TweenService:Create(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
        
        task.delay(duration, function()
            if frame and frame.Parent then
                Engine.Services.TweenService:Create(frame, TweenInfoIn, {BackgroundTransparency = 1}):Play()
                Engine.Services.TweenService:Create(stroke, TweenInfoIn, {Transparency = 1}):Play()
                Engine.Services.TweenService:Create(accentBar, TweenInfoIn, {BackgroundTransparency = 1}):Play()
                Engine.Services.TweenService:Create(titleLabel, TweenInfoIn, {TextTransparency = 1}):Play()
                Engine.Services.TweenService:Create(textLabel, TweenInfoIn, {TextTransparency = 1}):Play()
                Engine.Services.TweenService:Create(timerBar, TweenInfoIn, {BackgroundTransparency = 1}):Play()
                task.wait(0.4)
                frame:Destroy()
            end
        end)
    end
}

-- ==========================================
-- [6] FARMER HUD DASHBOARD (FLOATING STATS)
-- ==========================================
Engine.Modules.HUDManager = {
    Gui = nil,
    Labels = {},
    Init = function(self)
        local coreGui = GuiParent
        local sg = Instance.new("ScreenGui")
        sg.Name = "ClassQuid_BABFT_HUD"
        sg.ResetOnSpawn = false
        sg.Parent = coreGui
        self.Gui = sg
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 260, 0, 245)
        frame.Position = UDim2.new(0, 16, 0.22, 0)
        frame.BackgroundColor3 = Color3.fromRGB(252, 254, 255)
        frame.BackgroundTransparency = 0.52
        frame.Active = true
        frame.Draggable = true
        frame.ClipsDescendants = true
        frame.Parent = sg
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.8
        stroke.Color = Color3.fromRGB(0, 180, 255)
        stroke.Transparency = 0.2
        stroke.Parent = frame
        
        local headerBar = Instance.new("Frame")
        headerBar.Size = UDim2.new(1, 0, 0, 32)
        headerBar.BackgroundColor3 = Color3.fromRGB(15, 22, 36)
        headerBar.Parent = frame
        Instance.new("UICorner", headerBar).CornerRadius = UDim.new(0, 16)
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -38, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "⚡ BABFT FARMER VIP V9.1"
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 11
        title.TextColor3 = Color3.fromRGB(0, 240, 255)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = headerBar
        
        local btnCollapse = Instance.new("TextButton")
        btnCollapse.Size = UDim2.new(0, 24, 0, 24)
        btnCollapse.Position = UDim2.new(1, -28, 0, 4)
        btnCollapse.BackgroundColor3 = Color3.fromRGB(28, 40, 62)
        btnCollapse.Text = "-"
        btnCollapse.Font = Enum.Font.GothamBlack
        btnCollapse.TextSize = 14
        btnCollapse.TextColor3 = Color3.fromRGB(0, 255, 180)
        btnCollapse.Parent = headerBar
        Instance.new("UICorner", btnCollapse).CornerRadius = UDim.new(0, 6)
        
        local isCollapsed = false
        btnCollapse.MouseButton1Click:Connect(function()
            isCollapsed = not isCollapsed
            btnCollapse.Text = isCollapsed and "+" or "-"
            Engine.Services.TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = isCollapsed and UDim2.new(0, 260, 0, 32) or UDim2.new(0, 260, 0, 245)
            }):Play()
        end)
        
        local contentContainer = Instance.new("Frame")
        contentContainer.Size = UDim2.new(1, -16, 1, -40)
        contentContainer.Position = UDim2.new(0, 8, 0, 36)
        contentContainer.BackgroundTransparency = 1
        contentContainer.Parent = frame

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 3)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = contentContainer
        
        local function addLabel(key, defaultText)
            local lblFrame = Instance.new("Frame")
            lblFrame.Size = UDim2.new(1, 0, 0, 18)
            lblFrame.BackgroundColor3 = Color3.fromRGB(238, 244, 254)
            lblFrame.BackgroundTransparency = 0.65
            lblFrame.Parent = contentContainer
            Instance.new("UICorner", lblFrame).CornerRadius = UDim.new(0, 6)
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -12, 1, 0)
            lbl.Position = UDim2.new(0, 6, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = defaultText
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10
            lbl.TextColor3 = Color3.fromRGB(15, 28, 48)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = lblFrame
            self.Labels[key] = lbl
            return lblFrame
        end
        
        addLabel("Status", "⛵ Status: Idle").LayoutOrder = 1
        addLabel("Progress", "🚩 Tiến độ: Đang chờ").LayoutOrder = 2
        addLabel("Runs", "🏆 Đã hoàn tất: 0 vòng").LayoutOrder = 3
        addLabel("Speed", "🚀 Tốc độ bay: 160 studs/s").LayoutOrder = 4
        addLabel("Hotkeys", "⌨️ [P]Farm:OFF | [F]Fly:OFF").LayoutOrder = 5
        addLabel("GodMode", "🛡️ Godmode: ON | Anti-AFK: ON").LayoutOrder = 6
        addLabel("KeyTime", "⏳ Key Hạn: N/A").LayoutOrder = 7
        addLabel("Author", "👑 Author: " .. Engine.Author).LayoutOrder = 8
        
        -- Cập nhật HUD nhẹ nhàng mỗi 0.5 giây để tránh giật lag CPU
        task.spawn(function()
            local ticks = 0
            while task.wait(0.5) do
                ticks = ticks + 1
                if not Engine.Modules.ConfigManager.Settings.ShowHUD then
                    frame.Visible = false
                else
                    frame.Visible = true
                    stroke.Color = Color3.fromHSV((tick() * 0.15) % 1, 0.7, 1)
                    
                    local farmTxt = Engine.Modules.ConfigManager.Settings.AutoFarm and "🟢 ĐANG CHẠY FARM" or (Engine.State.IsDoingQuest and "🟡 ĐANG LÀM NHIỆM VỤ" or "🔴 ĐÃ TẮT FARM")
                    self.Labels.Status.Text = "⛵ Status: " .. farmTxt
                    self.Labels.Status.TextColor3 = Engine.Modules.ConfigManager.Settings.AutoFarm and Color3.fromRGB(0, 180, 80) or (Engine.State.IsDoingQuest and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(220, 40, 40))
                    
                    self.Labels.Progress.Text = "🚩 Tiến độ: " .. tostring(Engine.Cache.LastStatus or "Đang chờ...")
                    self.Labels.Runs.Text = "🏆 Hoàn tất: " .. tostring(Engine.Cache.TotalRuns) .. " vòng (~" .. (Engine.Cache.TotalRuns * 45) .. " Gold)"
                    self.Labels.Speed.Text = string.format("🚀 Tốc độ: %d | Độ cao: %d", Engine.Modules.ConfigManager.Settings.FarmSpeed, Engine.Modules.ConfigManager.Settings.FlyHeight)
                    
                    local pFarm = Engine.Modules.ConfigManager.Settings.AutoFarm and "ON" or "OFF"
                    local fFly = Engine.Modules.ConfigManager.Settings.Fly and "ON" or "OFF"
                    self.Labels.Hotkeys.Text = string.format("⌨️ [P]Farm:%s | [F]Fly:%s", pFarm, fFly)
                    
                    if ticks % 2 == 0 then
                        self.Labels.KeyTime.Text = "⏳ Key Hạn: " .. Engine.Modules.KeySystem:GetRemainingTime()
                        self.Labels.Author.Text = "👑 Author: " .. Engine.Author
                    end
                end
            end
        end)
    end
}

-- ==========================================
-- [7] LIGHTING & THEME MANAGERS
-- ==========================================
Engine.Modules.LightingManager = {
    OriginalSettings = nil,

    Init = function(self)
        if not self.OriginalSettings then
            local lighting = Engine.Services.Lighting
            self.OriginalSettings = {
                Ambient = lighting.Ambient,
                OutdoorAmbient = lighting.OutdoorAmbient,
                Brightness = lighting.Brightness,
                ClockTime = lighting.ClockTime,
                GlobalShadows = lighting.GlobalShadows,
                FogEnd = lighting.FogEnd
            }
        end
    end,

    ApplyMode = function(self, mode)
        self:Init()
        mode = mode or Engine.Modules.ConfigManager.Settings.LightingMode or "Normal"
        Engine.Modules.ConfigManager.Settings.LightingMode = mode

        local lighting = Engine.Services.Lighting
        pcall(function()
            if mode == "Light" then
                lighting.Ambient = Color3.fromRGB(210, 215, 230)
                lighting.OutdoorAmbient = Color3.fromRGB(220, 225, 240)
                lighting.Brightness = Engine.Modules.ConfigManager.Settings.LightingBrightness or 3.0
                lighting.ClockTime = Engine.Modules.ConfigManager.Settings.LightingClockTime or 14
                lighting.GlobalShadows = false
                lighting.FogEnd = 9e9
            elseif mode == "Sunset" then
                lighting.Ambient = Color3.fromRGB(255, 140, 90)
                lighting.OutdoorAmbient = Color3.fromRGB(210, 110, 70)
                lighting.Brightness = 2.2
                lighting.ClockTime = 17.8
                lighting.GlobalShadows = true
                lighting.FogEnd = 8000
                lighting.FogColor = Color3.fromRGB(200, 90, 50)
            elseif mode == "Dark" then
                lighting.Ambient = Color3.fromRGB(22, 28, 45)
                lighting.OutdoorAmbient = Color3.fromRGB(12, 16, 30)
                lighting.Brightness = 0.6
                lighting.ClockTime = 0
                lighting.GlobalShadows = true
                lighting.FogEnd = 6000
                lighting.FogColor = Color3.fromRGB(8, 12, 25)
            else
                lighting.Ambient = self.OriginalSettings.Ambient
                lighting.OutdoorAmbient = self.OriginalSettings.OutdoorAmbient
                lighting.Brightness = self.OriginalSettings.Brightness
                lighting.ClockTime = self.OriginalSettings.ClockTime
                lighting.GlobalShadows = self.OriginalSettings.GlobalShadows
                lighting.FogEnd = self.OriginalSettings.FogEnd
            end
        end)
    end
}

Engine.Modules.UIThemeManager = {
    ApplyTheme = function(self, theme)
        theme = theme or Engine.Modules.ConfigManager.Settings.UITheme or "Dark"
        Engine.Modules.ConfigManager.Settings.UITheme = theme

        local ui = Engine.Modules.UIController
        if not ui or not ui.MainFrame then return end

        local isDark = (theme == "Dark")
        local mainBg = isDark and Color3.fromRGB(14, 18, 28) or Color3.fromRGB(246, 250, 255)
        local mainTrans = isDark and 0.18 or 0.38
        local tabBg = isDark and Color3.fromRGB(22, 30, 46) or Color3.fromRGB(232, 240, 252)
        local cardBg = isDark and Color3.fromRGB(20, 28, 44) or Color3.fromRGB(238, 244, 254)
        local textCol = isDark and Color3.fromRGB(240, 248, 255) or Color3.fromRGB(18, 28, 48)

        pcall(function()
            ui.MainFrame.BackgroundColor3 = mainBg
            ui.MainFrame.BackgroundTransparency = mainTrans
            if ui.TabContainer then ui.TabContainer.BackgroundColor3 = tabBg end

            for _, frame in ipairs(ui.ThemeFrames or {}) do
                if frame and frame.Parent then frame.BackgroundColor3 = cardBg end
            end
            for _, label in ipairs(ui.ThemeLabels or {}) do
                if label and label.Parent then label.TextColor3 = textCol end
            end

            if ui.BtnTopTheme then
                ui.BtnTopTheme.Text = isDark and "🌙 Tối" or "☀️ Sáng"
                ui.BtnTopTheme.TextColor3 = isDark and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(15, 25, 45)
                ui.BtnTopTheme.BackgroundColor3 = isDark and Color3.fromRGB(22, 32, 52) or Color3.fromRGB(220, 235, 255)
            end
        end)
    end
}

-- ==========================================
-- [8] BABFT ULTRA SMOOTH FARM ENGINE (0% LAG)
-- ==========================================
Engine.Modules.FarmManager = {
    GetAliveCharacter = function(self)
        local char = LocalPlayer.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root and hum and hum.Health > 0 then
            return char, root, hum
        end
        return nil
    end,

    GlideTo = function(self, root, hum, targetPos, speed)
        if not root or hum.Health <= 0 then return false end
        speed = math.max(speed, 60)
        
        local reached = false
        while not reached and (Engine.Modules.ConfigManager.Settings.AutoFarm or Engine.State.IsDoingQuest) do
            if not root or not root.Parent or hum.Health <= 0 then return false end
            
            local currentPos = root.Position
            local dist = (targetPos - currentPos).Magnitude
            
            if dist < 4 then
                root.CFrame = CFrame.new(targetPos)
                reached = true
                break
            end
            
            local dt = Engine.Services.RunService.Heartbeat:Wait()
            local stepDist = math.min(dist, speed * dt)
            local moveDir = (targetPos - currentPos).Unit
            local nextPos = currentPos + (moveDir * stepDist)
            
            root.CFrame = CFrame.new(nextPos)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        
        return reached
    end,

    Start = function(self)
        self:Stop()
        Engine.State.IsFarming = true

        local farmThread = task.spawn(function()
            while Engine.Modules.ConfigManager.Settings.AutoFarm do
                task.wait(0.1)
                local char, root, hum = self:GetAliveCharacter()
                
                if char and root and hum then
                    Engine.Cache.LastStatus = "Cất cánh an toàn..."
                    
                    hum.PlatformStand = true
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end

                    local stagesFolder = Engine.Services.Workspace:FindFirstChild("BoatStages") and Engine.Services.Workspace.BoatStages:FindFirstChild("NormalStages")

                    if stagesFolder then
                        -- 1. Nâng lên độ cao an toàn
                        local safeElevation = root.Position.Y + Engine.Modules.ConfigManager.Settings.FlyHeight
                        self:GlideTo(root, hum, Vector3.new(root.Position.X, safeElevation, root.Position.Z), Engine.Modules.ConfigManager.Settings.FarmSpeed)

                        -- 2. Bay qua 10 Ải liên tục
                        for i = 1, 10 do
                            if not Engine.Modules.ConfigManager.Settings.AutoFarm or hum.Health <= 0 then break end
                            local stage = stagesFolder:FindFirstChild("CaveStage" .. i)
                            if stage and stage:FindFirstChild("DarknessPart") then
                                Engine.Cache.LastStatus = "Đang qua Ải " .. i .. "/10"
                                local basePos = stage.DarknessPart.Position
                                local targetPos = Vector3.new(basePos.X, safeElevation, basePos.Z)
                                
                                local success = self:GlideTo(root, hum, targetPos, Engine.Modules.ConfigManager.Settings.FarmSpeed)
                                if not success then break end
                            end
                        end

                        -- 3. Tiếp cận Rương Vàng (The End)
                        local theEnd = stagesFolder:FindFirstChild("TheEnd")
                        if theEnd and theEnd:FindFirstChild("GoldenChest") and Engine.Modules.ConfigManager.Settings.AutoFarm and hum.Health > 0 then
                            local chest = theEnd.GoldenChest
                            local trigger = chest:FindFirstChild("Trigger") or chest:FindFirstChildWhichIsA("BasePart")
                            if trigger then
                                Engine.Cache.LastStatus = "Chạm mở Rương Vàng..."
                                local targetChestPos = trigger.Position + Vector3.new(0, 1.5, 0)
                                
                                self:GlideTo(root, hum, targetChestPos, Engine.Modules.ConfigManager.Settings.FarmSpeed * 1.2)

                                if firetouchinterest and hum.Health > 0 then
                                    firetouchinterest(root, trigger, 0)
                                    task.wait(0.05)
                                    firetouchinterest(root, trigger, 1)
                                end

                                Engine.Cache.TotalRuns = Engine.Cache.TotalRuns + 1

                                for t = Engine.Modules.ConfigManager.Settings.ChestWaitTime, 1, -1 do
                                    if not Engine.Modules.ConfigManager.Settings.AutoFarm or hum.Health <= 0 then break end
                                    Engine.Cache.LastStatus = "Chờ nổ vàng: " .. t .. "s"
                                    task.wait(1)
                                end
                            end
                        end
                    end

                    -- 4. Tự tử hồi sinh về căn cứ ban đầu
                    if Engine.Modules.ConfigManager.Settings.AutoFarm and Engine.Modules.ConfigManager.Settings.FastSuicide and hum.Health > 0 then
                        hum.Health = 0
                    end

                    -- 5. Chờ nhân vật tái sinh
                    Engine.Cache.LastStatus = "Đang hồi sinh..."
                    repeat
                        task.wait(0.2)
                    until self:GetAliveCharacter() ~= nil or not Engine.Modules.ConfigManager.Settings.AutoFarm

                    task.wait(0.5)
                end
            end
        end)
        table.insert(Engine.State.FarmConnections, farmThread)

        if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
            Engine.Modules.NotificationManager:Notify("BABFT Auto Farm", "🚀 Kích hoạt Farm Vàng Siêu Mượt 0% Lag!", 3)
        end
    end,

    Stop = function(self)
        Engine.State.IsFarming = false
        for _, conn in ipairs(Engine.State.FarmConnections) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
            if typeof(conn) == "thread" then task.cancel(conn) end
            if typeof(conn) == "function" then conn() end
        end
        table.clear(Engine.State.FarmConnections)
        
        local char, root, hum = self:GetAliveCharacter()
        if hum then hum.PlatformStand = false end
        Engine.Cache.LastStatus = "Đã dừng Farm"
    end
}

-- ==========================================
-- [8.5] AUTO QUESTS 2.0 (BETA - SMART POLLING & RETRY)
-- ==========================================
Engine.Modules.QuestManager = {
    StartQuestRemote = function(self, questName)
        pcall(function()
            local aliases = { questName, questName .. "Quest", questName:gsub("%s+", "") }
            local locations = { Engine.Services.Workspace, Engine.Services.ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui") }
            
            for _, loc in ipairs(locations) do
                if loc then
                    for _, rName in ipairs({"SyncStartedQuest", "StartQuest", "ClaimQuest", "QuestFunction", "QuestEvent"}) do
                        local r = loc:FindFirstChild(rName)
                        if r then
                            for _, alias in ipairs(aliases) do
                                pcall(function()
                                    if r:IsA("RemoteFunction") then r:InvokeServer(alias)
                                    elseif r:IsA("RemoteEvent") then r:FireServer(alias) end
                                end)
                            end
                        end
                    end
                end
            end
        end)
    end,

    CompleteCloud = function(self)
        self:StartQuestRemote("Cloud")
        task.wait(0.4)
        local char, root, hum = Engine.Modules.FarmManager:GetAliveCharacter()
        if not root then return false end

        local cloudPart = nil
        for _, obj in ipairs(Engine.Services.Workspace:GetDescendants()) do
            if obj.Name:lower():find("cloud") and obj:IsA("BasePart") then
                cloudPart = obj
                break
            end
        end

        local targetPos = cloudPart and cloudPart.Position or Vector3.new(-50, 480, -200)
        Engine.Cache.LastStatus = "Đang bay chạm Mây (Cloud)..."
        Engine.Modules.FarmManager:GlideTo(root, hum, targetPos, 180)
        if cloudPart and firetouchinterest then
            firetouchinterest(root, cloudPart, 0)
            task.wait(0.05)
            firetouchinterest(root, cloudPart, 1)
        end
        self:StartQuestRemote("Cloud")
        task.wait(1.5)
        return true
    end,

    CompleteTarget = function(self)
        self:StartQuestRemote("Target")
        task.wait(0.4)
        local char, root, hum = Engine.Modules.FarmManager:GetAliveCharacter()
        if not root then return false end

        local targetPart = nil
        local targetModel = Engine.Services.Workspace:FindFirstChild("Target")
        if targetModel then
            targetPart = targetModel:FindFirstChild("Target") or targetModel:FindFirstChild("Middle") or targetModel:FindFirstChildWhichIsA("BasePart")
        end
        if not targetPart then
            for _, obj in ipairs(Engine.Services.Workspace:GetDescendants()) do
                if obj.Name:lower():find("target") and obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
                    targetPart = obj
                    break
                end
            end
        end

        local targetPos = targetPart and targetPart.Position or Vector3.new(-50, 80, -780)
        Engine.Cache.LastStatus = "Đang bay chạm Bia Ngắm (Target)..."
        Engine.Modules.FarmManager:GlideTo(root, hum, targetPos, 180)
        if targetPart and firetouchinterest then
            firetouchinterest(root, targetPart, 0)
            task.wait(0.05)
            firetouchinterest(root, targetPart, 1)
        end
        self:StartQuestRemote("Target")
        task.wait(1.5)
        return true
    end,

    CompleteRamp = function(self)
        self:StartQuestRemote("Ramp")
        task.wait(0.4)
        local char, root, hum = Engine.Modules.FarmManager:GetAliveCharacter()
        if not root then return false end

        local rampModel = Engine.Services.Workspace:FindFirstChild("Ramp")
        local endPart = rampModel and (rampModel:FindFirstChild("EndRing") or rampModel:FindFirstChild("Target") or rampModel:FindFirstChildWhichIsA("BasePart"))
        local targetPos = endPart and endPart.Position or Vector3.new(-50, 150, -1200)

        Engine.Cache.LastStatus = "Đang bay qua Cầu Trượt (Ramp)..."
        Engine.Modules.FarmManager:GlideTo(root, hum, targetPos, 180)
        if endPart and firetouchinterest then
            firetouchinterest(root, endPart, 0)
            task.wait(0.05)
            firetouchinterest(root, endPart, 1)
        end
        self:StartQuestRemote("Ramp")
        task.wait(1.5)
        return true
    end,

    CompleteFindMe = function(self)
        self:StartQuestRemote("FindMe")
        task.wait(0.4)
        local char, root, hum = Engine.Modules.FarmManager:GetAliveCharacter()
        if not root then return false end

        for i = 1, 5 do
            local foundButter = nil
            for attempt = 1, 10 do
                for _, v in ipairs(Engine.Services.Workspace:GetDescendants()) do
                    if (v.Name:lower():find("findme") or v.Name:lower():find("butter")) and v:IsA("BasePart") then
                        foundButter = v
                        break
                    end
                end
                if foundButter then break end
                task.wait(0.3)
            end

            if foundButter then
                Engine.Cache.LastStatus = string.format("Thu thập Khối Bơ %d/5...", i)
                Engine.Modules.FarmManager:GlideTo(root, hum, foundButter.Position + Vector3.new(0, 1, 0), 180)
                if firetouchinterest then
                    firetouchinterest(root, foundButter, 0)
                    task.wait(0.05)
                    firetouchinterest(root, foundButter, 1)
                end
                task.wait(0.8)
            end
        end
        self:StartQuestRemote("FindMe")
        return true
    end,

    CompleteTheBox = function(self)
        self:StartQuestRemote("TheBox")
        task.wait(0.4)
        local char, root, hum = Engine.Modules.FarmManager:GetAliveCharacter()
        if not root then return false end

        local boxPart = nil
        for _, obj in ipairs(Engine.Services.Workspace:GetDescendants()) do
            if obj.Name:lower():find("thebox") and obj:IsA("BasePart") then
                boxPart = obj
                break
            end
        end

        local targetPos = boxPart and boxPart.Position or Vector3.new(-50, 240, -1600)
        Engine.Cache.LastStatus = "Đang bay chạm Chiếc Hộp (The Box)..."
        Engine.Modules.FarmManager:GlideTo(root, hum, targetPos, 180)
        if boxPart and firetouchinterest then
            firetouchinterest(root, boxPart, 0)
            task.wait(0.05)
            firetouchinterest(root, boxPart, 1)
        end
        self:StartQuestRemote("TheBox")
        task.wait(1.5)
        return true
    end,

    CompleteSoccer = function(self)
        self:StartQuestRemote("Soccer")
        task.wait(0.4)
        local char, root, hum = Engine.Modules.FarmManager:GetAliveCharacter()
        if not root then return false end

        local soccerBall = Engine.Services.Workspace:FindFirstChild("SoccerBall") or Engine.Services.Workspace:FindFirstChild("Ball")
        local soccerGoal = Engine.Services.Workspace:FindFirstChild("SoccerGoal") or Engine.Services.Workspace:FindFirstChild("Goal")
        
        if soccerBall and soccerGoal then
            Engine.Cache.LastStatus = "Đang sút Bóng vào Gôn (Soccer)..."
            Engine.Modules.FarmManager:GlideTo(root, hum, soccerBall.Position + Vector3.new(0, 1, 0), 180)
            task.wait(0.2)
            if soccerBall:IsA("BasePart") then
                soccerBall.CFrame = soccerGoal.CFrame
                soccerBall.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
            end
        end
        self:StartQuestRemote("Soccer")
        task.wait(1.5)
        return true
    end,

    CompleteThinIce = function(self)
        self:StartQuestRemote("ThinIce")
        task.wait(0.4)
        local char, root, hum = Engine.Modules.FarmManager:GetAliveCharacter()
        if not root then return false end

        Engine.Cache.LastStatus = "Đang bay qua Băng Mỏng (Thin Ice)..."
        local stagesFolder = Engine.Services.Workspace:FindFirstChild("BoatStages") and Engine.Services.Workspace.BoatStages:FindFirstChild("NormalStages")
        local targetEnd = stagesFolder and stagesFolder:FindFirstChild("TheEnd")
        local targetPos = targetEnd and targetEnd:FindFirstChildWhichIsA("BasePart") and targetEnd:FindFirstChildWhichIsA("BasePart").Position or Vector3.new(-50, 90, -3200)

        Engine.Modules.FarmManager:GlideTo(root, hum, targetPos, 200)
        self:StartQuestRemote("ThinIce")
        task.wait(1.5)
        return true
    end,

    CompleteDragon = function(self)
        self:StartQuestRemote("Dragon")
        task.wait(0.4)
        local char, root, hum = Engine.Modules.FarmManager:GetAliveCharacter()
        if not root then return false end

        local dragon = Engine.Services.Workspace:FindFirstChild("Dragon") or Engine.Services.Workspace:FindFirstChild("DragonModel")
        local dragonHead = dragon and (dragon:FindFirstChild("Head") or dragon:FindFirstChildWhichIsA("BasePart"))
        local targetPos = dragonHead and dragonHead.Position or Vector3.new(-50, 120, -2200)

        Engine.Cache.LastStatus = "Đang bay tiếp cận Rồng (Dragon)..."
        Engine.Modules.FarmManager:GlideTo(root, hum, targetPos, 180)
        if dragonHead and firetouchinterest then
            firetouchinterest(root, dragonHead, 0)
            task.wait(0.05)
            firetouchinterest(root, dragonHead, 1)
        end
        self:StartQuestRemote("Dragon")
        task.wait(1.5)
        return true
    end,

    DoAllQuests = function(self)
        if Engine.State.IsDoingQuest then return end
        Engine.State.IsDoingQuest = true

        task.spawn(function()
            local list = {
                {Name = "Cloud", Func = function() return self:CompleteCloud() end},
                {Name = "Target", Func = function() return self:CompleteTarget() end},
                {Name = "Ramp", Func = function() return self:CompleteRamp() end},
                {Name = "Find Me", Func = function() return self:CompleteFindMe() end},
                {Name = "The Box", Func = function() return self:CompleteTheBox() end},
                {Name = "Soccer", Func = function() return self:CompleteSoccer() end},
                {Name = "Thin Ice", Func = function() return self:CompleteThinIce() end},
                {Name = "Dragon", Func = function() return self:CompleteDragon() end}
            }

            for _, q in ipairs(list) do
                if not Engine.State.IsDoingQuest then break end
                if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                    Engine.Modules.NotificationManager:Notify("Auto Quests (BETA)", "🚀 Đang thực hiện NV: " .. q.Name, 2.5)
                end
                pcall(q.Func)
                task.wait(Engine.Modules.ConfigManager.Settings.QuestDelay or 1.5)
            end

            Engine.State.IsDoingQuest = false
            Engine.Cache.LastStatus = "Hoàn thành tất cả NV!"
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Auto Quests (BETA)", "✨ ĐÃ HOÀN THÀNH TẤT CẢ NHIỆM VỤ THÀNH CÔNG!", 4)
            end
        end)
    end
}

-- ==========================================
-- [8.6] BOAT SAVE / LOAD & AUTO BUILDER ENGINE (BETA)
-- ==========================================
Engine.Modules.BoatSaveManager = {
    TriggerGameSaveGui = function(self, slotIndex, action)
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return false end
        slotIndex = tonumber(slotIndex) or 1
        action = tostring(action or "Save"):lower()
        
        local triggered = false
        pcall(function()
            for _, obj in ipairs(playerGui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local pName = obj.Parent and obj.Parent.Name:lower() or ""
                    local btnName = obj.Name:lower()
                    local btnText = (obj:IsA("TextButton") and obj.Text:lower()) or ""
                    
                    local matchSlot = pName:find(tostring(slotIndex)) or btnName:find(tostring(slotIndex)) or btnText:find(tostring(slotIndex))
                    local matchAction = btnName:find(action) or btnText:find(action)
                    
                    if (matchSlot and matchAction) or (matchAction and (pName:find("slot") or btnName:find("slot"))) then
                        if firesignal then
                            pcall(function() firesignal(obj.MouseButton1Click) end)
                            pcall(function() firesignal(obj.MouseButton1Down) end)
                            pcall(function() firesignal(obj.MouseButton1Up) end)
                            pcall(function() firesignal(obj.Activated) end)
                        end
                        triggered = true
                    end
                end
            end
        end)
        return triggered
    end,

    SaveSlot = function(self, slotIndex)
        slotIndex = tonumber(slotIndex or Engine.Modules.ConfigManager.Settings.SelectedSlot) or 1
        self:TriggerGameSaveGui(slotIndex, "Save")

        pcall(function()
            local remoteNames = {"SaveSlot", "SaveBoat", "Save", "SaveData", "SaveShip", "BuildingParts"}
            local locations = {Engine.Services.Workspace, Engine.Services.ReplicatedStorage}
            
            for _, loc in ipairs(locations) do
                for _, rName in ipairs(remoteNames) do
                    local r = loc:FindFirstChild(rName)
                    if r then
                        if r:IsA("RemoteFunction") then
                            pcall(function() r:InvokeServer(slotIndex) end)
                            pcall(function() r:InvokeServer("Slot" .. slotIndex) end)
                            pcall(function() r:InvokeServer("Slot " .. slotIndex) end)
                        elseif r:IsA("RemoteEvent") then
                            pcall(function() r:FireServer(slotIndex) end)
                            pcall(function() r:FireServer("Slot" .. slotIndex) end)
                            pcall(function() r:FireServer("Slot " .. slotIndex) end)
                        end
                    end
                end
            end
        end)

        if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
            Engine.Modules.NotificationManager:Notify("In-Game Saves (BETA)", string.format("💾 Đã gửi lệnh Lưu Thuyền vào Slot %d!", slotIndex), 3.5)
        end
    end,

    LoadSlot = function(self, slotIndex)
        slotIndex = tonumber(slotIndex or Engine.Modules.ConfigManager.Settings.SelectedSlot) or 1
        self:TriggerGameSaveGui(slotIndex, "Load")

        pcall(function()
            local remoteNames = {"LoadSlot", "LoadBoat", "Load", "LoadData", "LoadShip"}
            local locations = {Engine.Services.Workspace, Engine.Services.ReplicatedStorage}
            
            for _, loc in ipairs(locations) do
                for _, rName in ipairs(remoteNames) do
                    local r = loc:FindFirstChild(rName)
                    if r then
                        if r:IsA("RemoteFunction") then
                            pcall(function() r:InvokeServer(slotIndex) end)
                            pcall(function() r:InvokeServer("Slot" .. slotIndex) end)
                            pcall(function() r:InvokeServer("Slot " .. slotIndex) end)
                        elseif r:IsA("RemoteEvent") then
                            pcall(function() r:FireServer(slotIndex) end)
                            pcall(function() r:FireServer("Slot" .. slotIndex) end)
                            pcall(function() r:FireServer("Slot " .. slotIndex) end)
                        end
                    end
                end
            end
        end)

        if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
            Engine.Modules.NotificationManager:Notify("In-Game Saves (BETA)", string.format("🚀 Đang tải dữ liệu thuyền từ Slot %d...", slotIndex), 3.5)
        end
    end,

    SaveBoatToFile = function(self, customName)
        customName = customName or Engine.Modules.ConfigManager.Settings.SavedBoatFileName or "MyBoat_1"
        if customName == "" then customName = "MyBoat_1" end
        local fileName = "ClassQuid_Boat_" .. customName .. ".json"

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Boat Saver (BETA)", "❌ Nhân vật chưa xuất hiện! Hãy hồi sinh rồi thử lại.", 3)
            end
            return false
        end

        local baseCF = root.CFrame
        local playerPos = root.Position
        local savedItems = {}
        local visitedModels = {}

        local allObjects = Engine.Services.Workspace:GetChildren()
        for _, obj in ipairs(allObjects) do
            if obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid") and obj.Name ~= "BoatStages" and obj.Name ~= "Terrain" then
                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primaryPart and not visitedModels[obj] then
                    local dist = (Vector2.new(primaryPart.Position.X, primaryPart.Position.Z) - Vector2.new(playerPos.X, playerPos.Z)).Magnitude
                    if dist <= 180 and math.abs(primaryPart.Position.Y - playerPos.Y) < 120 then
                        visitedModels[obj] = true
                        
                        local subParts = {}
                        for _, sub in ipairs(obj:GetDescendants()) do
                            if sub:IsA("BasePart") then
                                local relCF = baseCF:ToObjectSpace(sub.CFrame)
                                table.insert(subParts, {
                                    Name = sub.Name,
                                    CFrame = {relCF:GetComponents()},
                                    Size = {sub.Size.X, sub.Size.Y, sub.Size.Z},
                                    Color = {sub.Color.R, sub.Color.G, sub.Color.B},
                                    Material = tostring(sub.Material.Name),
                                    Transparency = sub.Transparency,
                                    Anchored = sub.Anchored
                                })
                            end
                        end
                        
                        local relModelCF = baseCF:ToObjectSpace(primaryPart.CFrame)
                        table.insert(savedItems, {
                            ItemType = "Model",
                            ItemName = obj.Name,
                            RootCFrame = {relModelCF:GetComponents()},
                            Parts = subParts
                        })
                    end
                end
            elseif obj:IsA("BasePart") and obj.Name ~= "Baseplate" and obj.Name ~= "Terrain" and obj.Name ~= "DarknessPart" then
                local dist = (Vector2.new(obj.Position.X, obj.Position.Z) - Vector2.new(playerPos.X, playerPos.Z)).Magnitude
                if dist <= 180 and math.abs(obj.Position.Y - playerPos.Y) < 120 then
                    local relCF = baseCF:ToObjectSpace(obj.CFrame)
                    table.insert(savedItems, {
                        ItemType = "Part",
                        ItemName = obj.Name,
                        RootCFrame = {relCF:GetComponents()},
                        Parts = {{
                            Name = obj.Name,
                            CFrame = {relCF:GetComponents()},
                            Size = {obj.Size.X, obj.Size.Y, obj.Size.Z},
                            Color = {obj.Color.R, obj.Color.G, obj.Color.B},
                            Material = tostring(obj.Material.Name),
                            Transparency = obj.Transparency,
                            Anchored = obj.Anchored
                        }}
                    })
                end
            end
        end

        if #savedItems == 0 then
            for _, desc in ipairs(Engine.Services.Workspace:GetDescendants()) do
                if desc:IsA("BasePart") and desc.Name ~= "Baseplate" and desc.Name ~= "Terrain" and not desc:IsDescendantOf(char) then
                    local dist = (Vector2.new(desc.Position.X, desc.Position.Z) - Vector2.new(playerPos.X, playerPos.Z)).Magnitude
                    if dist <= 140 and math.abs(desc.Position.Y - playerPos.Y) < 90 then
                        local relCF = baseCF:ToObjectSpace(desc.CFrame)
                        table.insert(savedItems, {
                            ItemType = "Part",
                            ItemName = (desc.Parent and desc.Parent:IsA("Model") and desc.Parent.Name ~= "Workspace") and desc.Parent.Name or desc.Name,
                            RootCFrame = {relCF:GetComponents()},
                            Parts = {{
                                Name = desc.Name,
                                CFrame = {relCF:GetComponents()},
                                Size = {desc.Size.X, desc.Size.Y, desc.Size.Z},
                                Color = {desc.Color.R, desc.Color.G, desc.Color.B},
                                Material = tostring(desc.Material.Name),
                                Transparency = desc.Transparency,
                                Anchored = desc.Anchored
                            }}
                        })
                    end
                end
            end
        end

        if #savedItems == 0 then
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Boat Saver (BETA)", "⚠️ Không tìm thấy khối nào! Hãy đứng gần thuyền trên sân rồi bấm Lưu lại.", 4)
            end
            return false
        end

        local exportData = {
            Author = Engine.Author,
            Game = "Build A Boat For Treasure",
            Timestamp = os.time(),
            BoatName = customName,
            TotalItems = #savedItems,
            Items = savedItems
        }

        if writefile then
            pcall(function()
                writefile(fileName, Engine.Services.HttpService:JSONEncode(exportData))
            end)
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Boat Saver (BETA)", string.format("📁 Đã lưu thành công %d khối/ghế vào file '%s'!", #savedItems, fileName), 4)
            end
            return true
        end
        return false
    end,

    LoadBoatFromFile = function(self, customName)
        customName = customName or Engine.Modules.ConfigManager.Settings.SavedBoatFileName or "MyBoat_1"
        local fileName = "ClassQuid_Boat_" .. customName .. ".json"

        if not (isfile and readfile and isfile(fileName)) then
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Auto Builder (BETA)", "❌ Không tìm thấy file: " .. fileName .. "! Hãy bấm Lưu Thuyền trước.", 4)
            end
            return false
        end

        local success, data = pcall(function()
            return Engine.Services.HttpService:JSONDecode(readfile(fileName))
        end)

        if not success or not data or (not data.Items and not data.Parts) then
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Auto Builder (BETA)", "❌ File dữ liệu thuyền bị lỗi hoặc rỗng!", 3.5)
            end
            return false
        end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Auto Builder (BETA)", "❌ Nhân vật chưa sẵn sàng!", 3)
            end
            return false
        end

        local baseCF = root.CFrame
        local itemList = data.Items or data.Parts
        local totalCount = #itemList

        if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
            Engine.Modules.NotificationManager:Notify("Auto Builder (BETA)", string.format("🔨 Đang tự động xây %d khối từ file '%s'...", totalCount, customName), 3.5)
        end

        pcall(function()
            local bTool = LocalPlayer.Backpack:FindFirstChild("BuildingTool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
            if bTool and char and char:FindFirstChild("Humanoid") then
                char.Humanoid:EquipTool(bTool)
                task.wait(0.2)
            end
        end)

        task.spawn(function()
            local buildRemotes = {}
            local locations = {Engine.Services.Workspace, Engine.Services.ReplicatedStorage, LocalPlayer.Character, LocalPlayer.Backpack}
            for _, loc in ipairs(locations) do
                if loc then
                    for _, name in ipairs({"BuildingTools", "BuildingParts", "BuildingFunction", "Function"}) do
                        local r = loc:FindFirstChild(name)
                        if r then table.insert(buildRemotes, r) end
                    end
                    for _, child in ipairs(loc:GetChildren()) do
                        if child:IsA("Tool") then
                            local r = child:FindFirstChildWhichIsA("RemoteFunction") or child:FindFirstChildWhichIsA("RemoteEvent")
                            if r then table.insert(buildRemotes, r) end
                        end
                    end
                end
            end

            for idx, item in ipairs(itemList) do
                local itemName = item.ItemName or item.Name or "WoodBlock"
                local cfComponents = item.RootCFrame or item.CFrame
                
                if cfComponents then
                    local targetCF = baseCF:ToWorldSpace(CFrame.new(unpack(cfComponents)))
                    
                    for _, remote in ipairs(buildRemotes) do
                        pcall(function()
                            if remote:IsA("RemoteFunction") then
                                remote:InvokeServer(itemName, targetCF)
                            elseif remote:IsA("RemoteEvent") then
                                remote:FireServer(itemName, targetCF)
                            end
                        end)
                    end
                end
                
                if idx % 5 == 0 then
                    task.wait(0.04)
                end
            end

            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Auto Builder (BETA)", string.format("✨ ĐÃ XÂY XONG TOÀN BỘ %d KHỐI THUYỀN!", totalCount), 4)
            end
        end)

        return true
    end
}

-- ==========================================
-- [8.7] EXTRA VIP UTILITIES ENGINE (CODES, JESUS, ESP, GODMODE, TELEPORTS)
-- ==========================================
Engine.Modules.ExtraVIP = {
    RedeemAllCodes = function(self)
        local codes = {
            "hi",
            "squid army",
            "=D",
            "=p",
            "chillthrill709 was here",
            "Free gifts",
            "1B Visits",
            "Lurking Legend",
            "Be a big f00t print",
            "fuzzy friend?"
        }

        task.spawn(function()
            local redeemedCount = 0
            for _, code in ipairs(codes) do
                pcall(function()
                    local r = Engine.Services.Workspace:FindFirstChild("RedeemCode") or Engine.Services.ReplicatedStorage:FindFirstChild("RedeemCode")
                    if r then
                        if r:IsA("RemoteFunction") then r:InvokeServer(code)
                        elseif r:IsA("RemoteEvent") then r:FireServer(code) end
                        redeemedCount = redeemedCount + 1
                    end
                end)
                task.wait(0.4)
            end

            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Promo Codes", string.format("🎁 Đã tự động nhập %d Promo Codes của BABFT!", #codes), 4)
            end
        end)
    end,

    ClaimDailyGifts = function(self)
        pcall(function()
            local giftRemotes = {"ClaimDailyGift", "DailyGift", "ClaimGift", "ClaimReward"}
            for _, rName in ipairs(giftRemotes) do
                local r = Engine.Services.Workspace:FindFirstChild(rName) or Engine.Services.ReplicatedStorage:FindFirstChild(rName)
                if r then
                    if r:IsA("RemoteFunction") then r:InvokeServer()
                    elseif r:IsA("RemoteEvent") then r:FireServer() end
                end
            end
        end)
        if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
            Engine.Modules.NotificationManager:Notify("Daily Gifts", "🎉 Đã gửi yêu cầu nhận toàn bộ Quà Điểm Danh!", 3.5)
        end
    end,

    CachedWaterY = nil,
    GetWaterSurfaceY = function(self)
        if self.CachedWaterY then return self.CachedWaterY end
        
        -- 1. Tìm part Water trong Workspace
        local w = Engine.Services.Workspace:FindFirstChild("Water") or Engine.Services.Workspace:FindFirstChild("WaterPart")
        if w and w:IsA("BasePart") then
            self.CachedWaterY = w.Position.Y + (w.Size.Y / 2)
            return self.CachedWaterY
        end

        -- 2. Tìm trong BoatStages
        local stages = Engine.Services.Workspace:FindFirstChild("BoatStages")
        if stages then
            for _, child in ipairs(stages:GetDescendants()) do
                if child:IsA("BasePart") and child.Name:lower():find("water") then
                    self.CachedWaterY = child.Position.Y + (child.Size.Y / 2)
                    return self.CachedWaterY
                end
            end
        end

        -- 3. Mực nước sông chuẩn xác trong BABFT (-9.8)
        self.CachedWaterY = -9.8
        return self.CachedWaterY
    end,

    -- 3. Jesus Mode (Đi bộ trên mặt nước HOÀN TOÀN VÔ HÌNH - KHÔNG CÒN HÌNH VUÔNG)
    ToggleJesusMode = function(self, enable)
        if enable then
            if not Engine.State.JesusPlatform then
                local p = Instance.new("Part")
                p.Name = "ClassQuid_WaterWalker"
                p.Size = Vector3.new(40, 0.4, 40)
                p.Anchored = true
                p.CanCollide = true
                p.Transparency = 1 -- 100% Vô hình tuyệt đối, không hiện khối xanh
                p.CastShadow = false
                p.Material = Enum.Material.SmoothPlastic
                p.Parent = Engine.Services.Workspace
                Engine.State.JesusPlatform = p
            end
        else
            if Engine.State.JesusPlatform then
                Engine.State.JesusPlatform:Destroy()
                Engine.State.JesusPlatform = nil
            end
        end
    end,

    TeleportToPlot = function(self, plotName)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local targetPlot = nil
        for _, obj in ipairs(Engine.Services.Workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:lower():find(plotName:lower()) then
                targetPlot = obj
                break
            end
        end

        if targetPlot then
            local cf = targetPlot:GetPivot() or targetPlot:FindFirstChildWhichIsA("BasePart") and targetPlot:FindFirstChildWhichIsA("BasePart").CFrame
            if cf then
                root.CFrame = cf + Vector3.new(0, 6, 0)
                if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                    Engine.Modules.NotificationManager:Notify("Plot Teleport", "🚩 Đã dịch chuyển đến khu đất: " .. plotName, 3)
                end
            end
        else
            local zones = {"RedZone", "BlueZone", "GreenZone", "YellowZone", "WhiteZone", "BlackZone", "MagentaZone"}
            for _, zName in ipairs(zones) do
                if zName:lower():find(plotName:lower()) then
                    local zoneObj = Engine.Services.Workspace:FindFirstChild(zName)
                    if zoneObj then
                        local zPart = zoneObj:FindFirstChildWhichIsA("BasePart")
                        if zPart then
                            root.CFrame = zPart.CFrame + Vector3.new(0, 6, 0)
                            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                                Engine.Modules.NotificationManager:Notify("Plot Teleport", "🚩 Đã dịch chuyển đến sân: " .. zName, 3)
                            end
                            return
                        end
                    end
                end
            end
        end
    end,

    ToggleChestESP = function(self, enable)
        local coreGui = GuiParent
        local espGui = coreGui:FindFirstChild("ClassQuid_BABFT_ESP")
        
        if not enable then
            if espGui then espGui:Destroy() end
            return
        end

        if not espGui then
            espGui = Instance.new("ScreenGui")
            espGui.Name = "ClassQuid_BABFT_ESP"
            espGui.ResetOnSpawn = false
            espGui.Parent = coreGui
        end

        task.spawn(function()
            while Engine.Modules.ConfigManager.Settings.ChestESP do
                pcall(function()
                    for _, v in ipairs(Engine.Services.Workspace:GetDescendants()) do
                        if (v.Name == "GoldenChest" or v.Name == "TheBox" or v.Name == "Cloud" or v.Name == "Target" or v.Name:find("Butter")) and v:IsA("Model") or v:IsA("BasePart") then
                            local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                            if part and not part:FindFirstChild("ClassQuid_Highlight") then
                                local hl = Instance.new("Highlight")
                                hl.Name = "ClassQuid_Highlight"
                                hl.FillColor = Color3.fromRGB(255, 215, 0)
                                hl.OutlineColor = Color3.fromRGB(0, 240, 255)
                                hl.FillTransparency = 0.4
                                hl.OutlineTransparency = 0.1
                                hl.Parent = part

                                local bb = Instance.new("BillboardGui")
                                bb.Name = "ClassQuid_BB"
                                bb.Size = UDim2.new(0, 120, 0, 30)
                                bb.AlwaysOnTop = true
                                bb.StudsOffset = Vector3.new(0, 3, 0)
                                bb.Parent = part

                                local txt = Instance.new("TextLabel")
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.Text = "⭐ " .. v.Name
                                txt.Font = Enum.Font.GothamBlack
                                txt.TextSize = 11
                                txt.TextColor3 = Color3.fromRGB(255, 220, 0)
                                txt.Parent = bb
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
}

-- Water Walker & Godmode Step Handler
Engine.Services.RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Cập nhật sàn đi bộ trên nước (Jesus Mode) hoàn toàn vô hình, khớp chuẩn mực nước sông + thanh trượt độ cao
    if Engine.Modules.ConfigManager.Settings.JesusMode and root and Engine.State.JesusPlatform then
        local waterSurface = Engine.Modules.ExtraVIP:GetWaterSurfaceY()
        local offset = Engine.Modules.ConfigManager.Settings.JesusHeightOffset or 0
        local targetY = waterSurface - 0.2 + offset
        Engine.State.JesusPlatform.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
    end

    -- Chống sát thương nước & bẫy đá (Godmode)
    if (Engine.Modules.ConfigManager.Settings.AntiWaterDamage or Engine.Modules.ConfigManager.Settings.Godmode) and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health < hum.MaxHealth and not Engine.Modules.ConfigManager.Settings.FastSuicide then
            hum.Health = hum.MaxHealth
        end
    end
end)

-- Tự động Load thuyền khi nhân vật hồi sinh (Auto Load On Spawn)
LocalPlayer.CharacterAdded:Connect(function()
    if Engine.Modules.ConfigManager.Settings.AutoLoadOnSpawn then
        task.wait(1.5)
        Engine.Modules.BoatSaveManager:LoadSlot(Engine.Modules.ConfigManager.Settings.SelectedSlot or 1)
    end
end)

-- Vòng lặp Auto Save Slot định kỳ
task.spawn(function()
    while true do
        task.wait(60)
        if Engine.Modules.ConfigManager.Settings.AutoSaveSlot then
            Engine.Modules.BoatSaveManager:SaveSlot(Engine.Modules.ConfigManager.Settings.SelectedSlot or 1)
        end
    end
end)

-- Vòng lặp Auto Shop Mua Rương
task.spawn(function()
    while true do
        if Engine.Modules.ConfigManager.Settings.AutoBuyChest then
            pcall(function()
                Engine.Services.Workspace.ItemBoughtFromShop:InvokeServer(Engine.Modules.ConfigManager.Settings.ChestType, 1)
            end)
        end
        task.wait(Engine.Modules.ConfigManager.Settings.BuyInterval or 1.5)
    end
end)

-- Fly Hack Controller
local flyBv, flyBg = nil, nil
Engine.Services.RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if Engine.Modules.ConfigManager.Settings.Speed and hum then
        hum.WalkSpeed = Engine.Modules.ConfigManager.Settings.SpeedValue
    end
    if Engine.Modules.ConfigManager.Settings.JumpPower and hum then
        hum.JumpPower = Engine.Modules.ConfigManager.Settings.JumpPowerValue
    end
    
    if Engine.Modules.ConfigManager.Settings.Fly and hrp and hum then
        hum.PlatformStand = true
        if not flyBv then
            flyBv = Instance.new("BodyVelocity")
            flyBv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBv.Parent = hrp
        end
        if not flyBg then
            flyBg = Instance.new("BodyGyro")
            flyBg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBg.P = 15000
            flyBg.Parent = hrp
        end
        
        local cam = Camera.CFrame
        local move = Vector3.new()
        if Engine.Services.UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if Engine.Services.UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if Engine.Services.UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if Engine.Services.UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
        if Engine.Services.UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if Engine.Services.UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        
        flyBv.Velocity = move.Magnitude > 0 and move.Unit * Engine.Modules.ConfigManager.Settings.FlySpeed or Vector3.zero
        flyBg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + cam.LookVector)
    elseif flyBv or flyBg then
        if flyBv then flyBv:Destroy(); flyBv = nil end
        if flyBg then flyBg:Destroy(); flyBg = nil end
        if hum then hum.PlatformStand = false end
    end
end)

-- Noclip Handler tối ưu
Engine.Services.RunService.Stepped:Connect(function()
    if Engine.Modules.ConfigManager.Settings.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump Listener
Engine.Services.UIS.JumpRequest:Connect(function()
    if Engine.Modules.ConfigManager.Settings.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti-AFK Listener
LocalPlayer.Idled:Connect(function()
    if Engine.Modules.ConfigManager.Settings.AntiAFK then
        Engine.Services.VirtualUser:CaptureController()
        Engine.Services.VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Auto Rejoin on Disconnect
Engine.Services.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if Engine.Modules.ConfigManager.Settings.AutoRejoin and child.Name == "ErrorPrompt" then
        task.wait(1)
        Engine.Services.TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- ==========================================
-- [9] UI CONTROLLER (LIQUID GLASS & FLOATING LOGO)
-- ==========================================
Engine.Modules.UIController = {
    ChromaObjects = {},
    Toggles = {},
    RegisteredLabels = {},
    MainFrame = nil,
    LogoButton = nil,
    BtnTopLang = nil,
    BtnSwitchLang = nil,
    BtnTopTheme = nil,
    
    AddHoverAnim = function(self, btn, defaultColor, hoverColor)
        local origSize = btn.Size
        btn.MouseEnter:Connect(function()
            Engine.Services.TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = hoverColor or (defaultColor and defaultColor:Lerp(Color3.fromRGB(255, 255, 255), 0.15) or Color3.fromRGB(40, 55, 80)),
                BackgroundTransparency = math.max(0, btn.BackgroundTransparency - 0.1)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            Engine.Services.TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = defaultColor or btn.BackgroundColor3,
                BackgroundTransparency = btn.BackgroundTransparency
            }):Play()
        end)
        btn.MouseButton1Down:Connect(function()
            Engine.Services.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 2, origSize.Y.Scale, origSize.Y.Offset - 2)
            }):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            Engine.Services.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = origSize
            }):Play()
        end)
    end,

    RegisterLabel = function(self, obj, key, prefix, suffix, isSlider, configKey)
        table.insert(self.RegisteredLabels, {
            Obj = obj,
            Key = key,
            Prefix = prefix or "",
            Suffix = suffix or "",
            IsSlider = isSlider or false,
            ConfigKey = configKey
        })
    end,

    RefreshLanguage = function(self)
        for _, item in ipairs(self.RegisteredLabels) do
            if item.Obj and item.Obj.Parent then
                local txt = Engine.Modules.I18n:Get(item.Key)
                if item.IsSlider and item.ConfigKey then
                    local val = Engine.Modules.ConfigManager.Settings[item.ConfigKey] or 0
                    item.Obj.Text = item.Prefix .. txt .. ": " .. string.format("%.2f", val) .. item.Suffix
                else
                    item.Obj.Text = item.Prefix .. txt .. item.Suffix
                end
            end
        end
        if self.BtnTopLang then
            self.BtnTopLang.Text = "🌐 " .. (Engine.Modules.ConfigManager.Settings.Language or "VN")
        end
        if self.BtnSwitchLang then
            local curr = Engine.Modules.ConfigManager.Settings.Language or "VN"
            self.BtnSwitchLang.Text = (curr == "VN") and "🌐 Switch Language / Chuyển Ngôn Ngữ (VN ➔ EN)" or "🌐 Switch Language / Chuyển Ngôn Ngữ (EN ➔ VN)"
        end
    end,

    Init = function(self)
        self.ThemeFrames = {}
        self.ThemeLabels = {}
        local coreGui = GuiParent
        local sg = Instance.new("ScreenGui")
        sg.Name = "ClassQuid_BABFT_LiquidGlass"
        sg.ResetOnSpawn = false
        sg.Parent = coreGui
        
        -- Floating Ultra-Cyber Crystal Orb Logo Holder (Draggable)
        local logoHolder = Instance.new("Frame")
        logoHolder.Name = "BABFT_LogoHolder"
        logoHolder.Size = UDim2.new(0, 68, 0, 68)
        logoHolder.Position = UDim2.new(0, 24, 0.5, -34)
        logoHolder.BackgroundTransparency = 1
        logoHolder.Active = true
        logoHolder.Parent = sg

        self.LogoButton = Instance.new("TextButton")
        self.LogoButton.Size = UDim2.new(1, 0, 1, 0)
        self.LogoButton.Position = UDim2.new(0, 0, 0, 0)
        self.LogoButton.BackgroundColor3 = Color3.fromRGB(252, 254, 255)
        self.LogoButton.BackgroundTransparency = 0.15
        self.LogoButton.Text = ""
        self.LogoButton.Active = true
        self.LogoButton.Parent = logoHolder
        Instance.new("UICorner", self.LogoButton).CornerRadius = UDim.new(1, 0)

        -- Outer Hologram Glow Halo Ring (Pulsing)
        local outerGlowHalo = Instance.new("Frame")
        outerGlowHalo.Size = UDim2.new(1, 20, 1, 20)
        outerGlowHalo.Position = UDim2.new(0, -10, 0, -10)
        outerGlowHalo.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
        outerGlowHalo.BackgroundTransparency = 0.8
        outerGlowHalo.Parent = self.LogoButton
        Instance.new("UICorner", outerGlowHalo).CornerRadius = UDim.new(1, 0)
        table.insert(self.ChromaObjects, outerGlowHalo)

        -- Inner Rotating Rainbow Stroke Ring
        local logoStroke = Instance.new("UIStroke")
        logoStroke.Thickness = 3
        logoStroke.Transparency = 0.1
        logoStroke.Parent = self.LogoButton
        table.insert(self.ChromaObjects, logoStroke)
        table.insert(self.ChromaObjects, self.LogoButton)
        
        local logoAsset = Engine:GetLogoAsset()
        local logoImg = Instance.new("ImageLabel")
        logoImg.Size = UDim2.new(1, -8, 1, -8)
        logoImg.Position = UDim2.new(0, 4, 0, 4)
        logoImg.BackgroundTransparency = 1
        if logoAsset then logoImg.Image = logoAsset end
        logoImg.ScaleType = Enum.ScaleType.Crop
        logoImg.Parent = self.LogoButton
        Instance.new("UICorner", logoImg).CornerRadius = UDim.new(1, 0)

        -- Pulsing Radar Waves on Online Status Dot
        local radarWave = Instance.new("Frame")
        radarWave.Size = UDim2.new(0, 14, 0, 14)
        radarWave.Position = UDim2.new(1, -13, 1, -13)
        radarWave.BackgroundColor3 = Color3.fromRGB(0, 255, 160)
        radarWave.BackgroundTransparency = 0.5
        radarWave.Parent = self.LogoButton
        Instance.new("UICorner", radarWave).CornerRadius = UDim.new(1, 0)

        local onlineDot = Instance.new("Frame")
        onlineDot.Size = UDim2.new(0, 12, 0, 12)
        onlineDot.Position = UDim2.new(1, -12, 1, -12)
        onlineDot.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        onlineDot.Parent = self.LogoButton
        Instance.new("UICorner", onlineDot).CornerRadius = UDim.new(1, 0)

        local onlineDotStroke = Instance.new("UIStroke")
        onlineDotStroke.Thickness = 1.5
        onlineDotStroke.Color = Color3.fromRGB(15, 22, 36)
        onlineDotStroke.Parent = onlineDot

        -- Mini VIP Hologram Label Badge attached to Logo
        local logoBadge = Instance.new("Frame")
        logoBadge.Size = UDim2.new(0, 80, 0, 18)
        logoBadge.Position = UDim2.new(0.5, -40, 1, 4)
        logoBadge.BackgroundColor3 = Color3.fromRGB(250, 252, 255)
        logoBadge.BackgroundTransparency = 0.2
        logoBadge.Parent = self.LogoButton
        Instance.new("UICorner", logoBadge).CornerRadius = UDim.new(0, 9)

        local badgeStroke = Instance.new("UIStroke")
        badgeStroke.Thickness = 1.2
        badgeStroke.Color = Color3.fromRGB(0, 200, 255)
        badgeStroke.Parent = logoBadge
        table.insert(self.ChromaObjects, badgeStroke)

        local badgeText = Instance.new("TextLabel")
        badgeText.Size = UDim2.new(1, 0, 1, 0)
        badgeText.BackgroundTransparency = 1
        badgeText.Text = "⚡ CLASS QUID"
        badgeText.Font = Enum.Font.GothamBlack
        badgeText.TextSize = 8.5
        badgeText.TextColor3 = Color3.fromRGB(15, 25, 45)
        badgeText.Parent = logoBadge

        -- 60 FPS Levitation & Rainbow Chroma Cycling
        task.spawn(function()
            local tickCounter = 0
            Engine.Services.RunService.RenderStepped:Connect(function(dt)
                tickCounter = tickCounter + dt
                
                local hoverY = math.sin(tickCounter * 2.2) * 10
                self.LogoButton.Position = UDim2.new(0, 0, 0, hoverY)
                
                local chromaColor = Color3.fromHSV((tickCounter * 0.35) % 1, 0.85, 1)
                local chromaColor2 = Color3.fromHSV(((tickCounter * 0.35) + 0.25) % 1, 0.85, 1)
                
                logoStroke.Color = chromaColor
                outerGlowHalo.BackgroundColor3 = chromaColor
                badgeStroke.Color = chromaColor2
                
                local pulseScale = 22 + math.sin(tickCounter * 3.5) * 8
                local pulseTrans = 0.7 + math.sin(tickCounter * 3.5) * 0.18
                outerGlowHalo.Size = UDim2.new(1, pulseScale, 1, pulseScale)
                outerGlowHalo.Position = UDim2.new(0, -pulseScale/2, 0, -pulseScale/2)
                outerGlowHalo.BackgroundTransparency = pulseTrans
                
                local waveSize = 12 + ((tickCounter * 22) % 16)
                local waveAlpha = (16 - (waveSize - 12)) / 16 * 0.75
                radarWave.Size = UDim2.new(0, waveSize, 0, waveSize)
                radarWave.Position = UDim2.new(1, -6 - (waveSize/2), 1, -6 - (waveSize/2))
                radarWave.BackgroundTransparency = math.clamp(1 - waveAlpha, 0.25, 1)

                local retryAsset = Engine:GetLogoAsset()
                if retryAsset and logoImg.Image ~= retryAsset then
                    logoImg.Image = retryAsset
                end
            end)
        end)

        self.LogoButton.MouseEnter:Connect(function()
            Engine.Services.TweenService:Create(self.LogoButton, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 76, 0, 76),
                BackgroundTransparency = 0.05
            }):Play()
            Engine.Services.TweenService:Create(logoImg, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Rotation = 12
            }):Play()
        end)

        self.LogoButton.MouseLeave:Connect(function()
            Engine.Services.TweenService:Create(self.LogoButton, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 68, 0, 68),
                BackgroundTransparency = 0.15
            }):Play()
            Engine.Services.TweenService:Create(logoImg, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Rotation = 0
            }):Play()
        end)

        -- Draggable Logo
        local isDraggingLogo = false
        local dragStartPos = nil
        local startHolderPos = nil
        local dragDistance = 0

        local function handleInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingLogo = true
                dragStartPos = input.Position
                startHolderPos = logoHolder.Position
                dragDistance = 0
                
                local connChanged, connEnded
                connChanged = Engine.Services.UIS.InputChanged:Connect(function(inp)
                    if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and isDraggingLogo then
                        local delta = inp.Position - dragStartPos
                        dragDistance = dragDistance + math.abs(delta.X) + math.abs(delta.Y)
                        logoHolder.Position = UDim2.new(
                            startHolderPos.X.Scale, startHolderPos.X.Offset + delta.X,
                            startHolderPos.Y.Scale, startHolderPos.Y.Offset + delta.Y
                        )
                    end
                end)
                
                connEnded = Engine.Services.UIS.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        isDraggingLogo = false
                        if connChanged then connChanged:Disconnect() end
                        if connEnded then connEnded:Disconnect() end
                        
                        if dragDistance < 8 then
                            Engine.Services.TweenService:Create(self.LogoButton, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                                Size = UDim2.new(1, -8, 1, -8)
                            }):Play()
                            task.delay(0.1, function()
                                Engine.Services.TweenService:Create(self.LogoButton, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                    Size = UDim2.new(1, 0, 1, 0)
                                }):Play()
                            end)
                            self.MainFrame.Visible = not self.MainFrame.Visible
                        end
                    end
                end)
            end
        end

        self.LogoButton.InputBegan:Connect(handleInputBegan)
        logoHolder.InputBegan:Connect(handleInputBegan)
        
        -- Main Cyberpunk Liquid Glass Frame
        self.MainFrame = Instance.new("Frame")
        self.MainFrame.Size = UDim2.new(0, 580, 0, 400)
        self.MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
        self.MainFrame.BackgroundColor3 = Color3.fromRGB(246, 250, 255)
        self.MainFrame.BackgroundTransparency = 0.42
        self.MainFrame.Active = true
        self.MainFrame.Draggable = true
        self.MainFrame.ClipsDescendants = true
        self.MainFrame.Parent = sg
        Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 20)
        
        local mainStroke = Instance.new("UIStroke")
        mainStroke.Thickness = 1.8
        mainStroke.Transparency = 0.25
        mainStroke.Parent = self.MainFrame
        table.insert(self.ChromaObjects, mainStroke)
        
        local topBar = Instance.new("Frame")
        topBar.Size = UDim2.new(1, 0, 0, 58)
        topBar.BackgroundTransparency = 1
        topBar.Parent = self.MainFrame

        local headerLogoAsset = Engine:GetLogoAsset()
        local titleLeftPos = 68

        local headerLogoFrame = Instance.new("Frame")
        headerLogoFrame.Size = UDim2.new(0, 42, 0, 42)
        headerLogoFrame.Position = UDim2.new(0, 14, 0, 8)
        headerLogoFrame.BackgroundColor3 = Color3.fromRGB(16, 22, 36)
        headerLogoFrame.Parent = topBar
        Instance.new("UICorner", headerLogoFrame).CornerRadius = UDim.new(0, 12)

        local headerLogoImg = Instance.new("ImageLabel")
        headerLogoImg.Size = UDim2.new(1, -4, 1, -4)
        headerLogoImg.Position = UDim2.new(0, 2, 0, 2)
        headerLogoImg.BackgroundTransparency = 1
        if headerLogoAsset then headerLogoImg.Image = headerLogoAsset end
        headerLogoImg.ScaleType = Enum.ScaleType.Crop
        headerLogoImg.Parent = headerLogoFrame
        Instance.new("UICorner", headerLogoImg).CornerRadius = UDim.new(0, 10)

        local headerLogoStroke = Instance.new("UIStroke")
        headerLogoStroke.Thickness = 1.8
        headerLogoStroke.Color = Color3.fromRGB(0, 240, 255)
        headerLogoStroke.Parent = headerLogoFrame
        table.insert(self.ChromaObjects, headerLogoStroke)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -(titleLeftPos + 330), 0, 26)
        title.Position = UDim2.new(0, titleLeftPos, 0, 8)
        title.BackgroundTransparency = 1
        title.Text = "⚡ CLASS QUID VIP • V9.1"
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = topBar
        table.insert(self.ChromaObjects, title)

        local authorLabel = Instance.new("TextLabel")
        authorLabel.Size = UDim2.new(1, -(titleLeftPos + 330), 0, 16)
        authorLabel.Position = UDim2.new(0, titleLeftPos, 0, 32)
        authorLabel.BackgroundTransparency = 1
        authorLabel.Text = "👑 Owner: " .. Engine.Author .. "  |  BABFT ENGINE 2026"
        authorLabel.Font = Enum.Font.GothamBold
        authorLabel.TextSize = 9.5
        authorLabel.TextColor3 = Color3.fromRGB(0, 150, 220)
        authorLabel.TextXAlignment = Enum.TextXAlignment.Left
        authorLabel.Parent = topBar

        self.BtnTopLang = Instance.new("TextButton")
        self.BtnTopLang.Size = UDim2.new(0, 66, 0, 28)
        self.BtnTopLang.Position = UDim2.new(1, -320, 0, 15)
        self.BtnTopLang.BackgroundColor3 = Color3.fromRGB(230, 238, 252)
        self.BtnTopLang.Text = "🌐 " .. (Engine.Modules.ConfigManager.Settings.Language or "VN")
        self.BtnTopLang.Font = Enum.Font.GothamBold
        self.BtnTopLang.TextSize = 11
        self.BtnTopLang.TextColor3 = Color3.fromRGB(0, 140, 220)
        self.BtnTopLang.Parent = topBar
        Instance.new("UICorner", self.BtnTopLang).CornerRadius = UDim.new(0, 8)
        self:AddHoverAnim(self.BtnTopLang, Color3.fromRGB(18, 26, 42), Color3.fromRGB(28, 40, 64))
        
        self.BtnTopLang.MouseButton1Click:Connect(function()
            local newLang = Engine.Modules.I18n:ToggleLang()
            self:RefreshLanguage()
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Language / Ngôn Ngữ", (newLang == "VN") and "✓ Đã chuyển sang Tiếng Việt!" or "✓ Switched language to English!", 3)
            end
        end)

        local btnTopDiscord = Instance.new("TextButton")
        btnTopDiscord.Size = UDim2.new(0, 80, 0, 28)
        btnTopDiscord.Position = UDim2.new(1, -248, 0, 15)
        btnTopDiscord.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        btnTopDiscord.Text = "💬 Discord"
        btnTopDiscord.Font = Enum.Font.GothamBold
        btnTopDiscord.TextSize = 11
        btnTopDiscord.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnTopDiscord.Parent = topBar
        Instance.new("UICorner", btnTopDiscord).CornerRadius = UDim.new(0, 8)
        self:AddHoverAnim(btnTopDiscord, Color3.fromRGB(88, 101, 242), Color3.fromRGB(105, 118, 255))
        btnTopDiscord.MouseButton1Click:Connect(function()
            Engine.Modules.KeySystem:JoinDiscord()
        end)

        local isDarkTheme = (Engine.Modules.ConfigManager.Settings.UITheme == "Dark")
        self.BtnTopTheme = Instance.new("TextButton")
        self.BtnTopTheme.Size = UDim2.new(0, 66, 0, 28)
        self.BtnTopTheme.Position = UDim2.new(1, -162, 0, 15)
        self.BtnTopTheme.BackgroundColor3 = isDarkTheme and Color3.fromRGB(22, 32, 52) or Color3.fromRGB(220, 235, 255)
        self.BtnTopTheme.Text = isDarkTheme and "🌙 Tối" or "☀️ Sáng"
        self.BtnTopTheme.Font = Enum.Font.GothamBold
        self.BtnTopTheme.TextSize = 11
        self.BtnTopTheme.TextColor3 = isDarkTheme and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(15, 25, 45)
        self.BtnTopTheme.Parent = topBar
        Instance.new("UICorner", self.BtnTopTheme).CornerRadius = UDim.new(0, 8)
        self:AddHoverAnim(self.BtnTopTheme, Color3.fromRGB(22, 32, 52), Color3.fromRGB(34, 52, 82))
        
        self.BtnTopTheme.MouseButton1Click:Connect(function()
            local currTheme = Engine.Modules.ConfigManager.Settings.UITheme or "Dark"
            local nextTheme = (currTheme == "Dark") and "Light" or "Dark"
            Engine.Modules.UIThemeManager:ApplyTheme(nextTheme)
            Engine.Modules.ConfigManager:Save()
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("UI Theme", (nextTheme == "Dark") and "🌙 Đã chuyển Giao diện Menu sang Chế Độ Tối!" or "☀️ Đã chuyển Giao diện Menu sang Chế Độ Sáng!", 2.5)
            end
        end)

        local btnTopGetKey = Instance.new("TextButton")
        btnTopGetKey.Size = UDim2.new(0, 80, 0, 28)
        btnTopGetKey.Position = UDim2.new(1, -90, 0, 15)
        btnTopGetKey.BackgroundColor3 = Color3.fromRGB(22, 35, 56)
        btnTopGetKey.Text = "🌐 Get Key"
        btnTopGetKey.Font = Enum.Font.GothamBold
        btnTopGetKey.TextSize = 11
        btnTopGetKey.TextColor3 = Color3.fromRGB(0, 240, 255)
        btnTopGetKey.Parent = topBar
        Instance.new("UICorner", btnTopGetKey).CornerRadius = UDim.new(0, 8)
        self:AddHoverAnim(btnTopGetKey, Color3.fromRGB(22, 35, 56), Color3.fromRGB(34, 52, 82))
        btnTopGetKey.MouseButton1Click:Connect(function()
            if setclipboard or toclipboard then
                pcall(function() (setclipboard or toclipboard)(Engine.Modules.KeySystem.KeyURL) end)
            end
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Get Key", "✓ Đã sao chép Link Get Key 24h!", 3)
            end
        end)

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -30, 0, 1)
        line.Position = UDim2.new(0, 15, 1, -1)
        line.BorderSizePixel = 0
        line.BackgroundTransparency = 0.5
        line.Parent = topBar
        table.insert(self.ChromaObjects, line)
        
        local contentArea = Instance.new("Frame")
        contentArea.Size = UDim2.new(1, 0, 1, -58)
        contentArea.Position = UDim2.new(0, 0, 0, 58)
        contentArea.BackgroundTransparency = 1
        contentArea.Parent = self.MainFrame
        
        self:BuildTabs(contentArea)
        
        task.spawn(function()
            while task.wait(0.1) do
                if self.MainFrame and self.MainFrame.Visible then
                    local hue = (tick() % 6) / 6
                    local color = Color3.fromHSV(hue, 0.75, 1)
                    for _, obj in ipairs(self.ChromaObjects) do
                        if obj and obj.Parent then
                            if obj:IsA("UIStroke") then obj.Color = color
                            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then obj.TextColor3 = color
                            elseif obj:IsA("Frame") and (obj.Size.Y.Offset == 1 or obj.Name == "ToggledBG") then obj.BackgroundColor3 = color end
                        end
                    end
                end
            end
        end)
        
        -- HOTKEYS: P (Farm), F (Fly), RightShift / RightControl (UI)
        Engine.Services.UIS.InputBegan:Connect(function(input)
            if Engine.Services.UIS:GetFocusedTextBox() then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

            if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.RightControl then
                if self.MainFrame then
                    self.MainFrame.Visible = not self.MainFrame.Visible
                end
            elseif input.KeyCode == Enum.KeyCode.P then
                local newState = not Engine.Modules.ConfigManager.Settings.AutoFarm
                Engine.Modules.ConfigManager.Settings.AutoFarm = newState
                Engine.Modules.ConfigManager:Save()
                
                if newState then 
                    Engine.Modules.FarmManager:Start() 
                else 
                    Engine.Modules.FarmManager:Stop() 
                end

                if self.Toggles["AutoFarm"] then
                    self.Toggles["AutoFarm"](newState)
                end

                Engine.Modules.NotificationManager:Notify("Hotkey [P]", "Auto Farm Vàng: " .. (newState and "BẬT [ON]" or "TẮT [OFF]"), 2)
            elseif input.KeyCode == Enum.KeyCode.F then
                local newState = not Engine.Modules.ConfigManager.Settings.Fly
                Engine.Modules.ConfigManager.Settings.Fly = newState
                Engine.Modules.ConfigManager.Settings.FlySpeed = Engine.Modules.ConfigManager.Settings.FlySpeed or 80
                Engine.Modules.ConfigManager:Save()
                if self.Toggles["Fly"] then self.Toggles["Fly"](newState) end
                Engine.Modules.NotificationManager:Notify("Hotkey [F]", "Fly Mode: " .. (newState and "BẬT [ON]" or "TẮT [OFF]"), 2)
            end
        end)
    end,
    
    CreateSectionHeader = function(self, parent, translationKey)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(228, 238, 252)
        frame.BackgroundTransparency = 0.52
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local lineLeft = Instance.new("Frame")
        lineLeft.Size = UDim2.new(0, 4, 1, -8)
        lineLeft.Position = UDim2.new(0, 4, 0, 4)
        lineLeft.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        lineLeft.Parent = frame
        Instance.new("UICorner", lineLeft).CornerRadius = UDim.new(1, 0)
        table.insert(self.ChromaObjects, lineLeft)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = Engine.Modules.I18n:Get(translationKey)
        label.TextColor3 = Color3.fromRGB(15, 25, 45)
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        self:RegisterLabel(label, translationKey)
        table.insert(self.ChromaObjects, label)
    end,

    CreateNoticeBanner = function(self, parent, translationKey)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 38)
        frame.BackgroundColor3 = Color3.fromRGB(42, 34, 18)
        frame.BackgroundTransparency = 0.35
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(255, 190, 40)
        stroke.Transparency = 0.5
        stroke.Parent = frame

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 24, 1, 0)
        icon.Position = UDim2.new(0, 6, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "⚠️"
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 13
        icon.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -38, 1, 0)
        label.Position = UDim2.new(0, 32, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = Engine.Modules.I18n:Get(translationKey)
        label.TextColor3 = Color3.fromRGB(255, 215, 110)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 9.5
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        self:RegisterLabel(label, translationKey)
    end,

    CreateButton = function(self, parent, translationKey, callback, customBg, customTextCol)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 38)
        btn.BackgroundColor3 = customBg or Color3.fromRGB(22, 32, 52)
        btn.Text = Engine.Modules.I18n:Get(translationKey)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = customTextCol or Color3.fromRGB(0, 240, 255)
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        self:AddHoverAnim(btn, customBg or Color3.fromRGB(22, 32, 52), (customBg and customBg:Lerp(Color3.fromRGB(255,255,255), 0.15)) or Color3.fromRGB(34, 48, 76))
        self:RegisterLabel(btn, translationKey)
        
        if callback then
            btn.MouseButton1Click:Connect(callback)
        end
        return btn
    end,

    BuildTabs = function(self, parent)
        local tabContainer = Instance.new("Frame")
        tabContainer.Size = UDim2.new(0, 150, 1, -20)
        tabContainer.Position = UDim2.new(0, 12, 0, 10)
        tabContainer.BackgroundColor3 = Color3.fromRGB(232, 240, 252)
        tabContainer.BackgroundTransparency = 0.55
        tabContainer.Parent = parent
        Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 14)

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Thickness = 1.2
        tabStroke.Color = Color3.fromRGB(0, 240, 255)
        tabStroke.Transparency = 0.8
        tabStroke.Parent = tabContainer

        local tabList = Instance.new("UIListLayout")
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        tabList.Padding = UDim.new(0, 5)
        tabList.Parent = tabContainer

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        pad.Parent = tabContainer
        
        local pageContainer = Instance.new("Frame")
        pageContainer.Size = UDim2.new(1, -180, 1, -20)
        pageContainer.Position = UDim2.new(0, 170, 0, 10)
        pageContainer.BackgroundTransparency = 1
        pageContainer.Parent = parent
        
        local pages = {}
        local tabButtons = {}
        
        local function createTab(translationKey, first)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = first and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(240, 246, 255)
            btn.BackgroundTransparency = first and 0.85 or 1
            btn.Text = "  " .. Engine.Modules.I18n:Get(translationKey)
            btn.TextColor3 = first and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 62, 88)
            btn.Font = Enum.Font.GothamBlack
            btn.TextSize = 10.5
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = tabContainer
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            self:RegisterLabel(btn, translationKey, "  ")
            
            local page = Instance.new("ScrollingFrame")
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.ScrollBarThickness = 3
            page.ScrollBarImageTransparency = 0.7
            page.Visible = first
            page.Parent = pageContainer
            
            local pageLayout = Instance.new("UIListLayout")
            pageLayout.Padding = UDim.new(0, 8)
            pageLayout.Parent = page
            
            if first then
                table.insert(self.ChromaObjects, btn)
            end
            
            btn.MouseButton1Click:Connect(function()
                for _, p in pairs(pages) do 
                    if p.Visible then p.Visible = false end 
                end
                for _, b in pairs(tabButtons) do 
                    Engine.Services.TweenService:Create(b, TweenInfo.new(0.2), {
                        TextColor3 = Color3.fromRGB(45, 62, 88),
                        BackgroundTransparency = 1
                    }):Play() 
                end
                page.Visible = true
                page.CanvasPosition = Vector2.new(0, 0)
                Engine.Services.TweenService:Create(btn, TweenInfo.new(0.2), {
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundColor3 = Color3.fromRGB(0, 180, 255),
                    BackgroundTransparency = 0
                }):Play()
                table.insert(self.ChromaObjects, btn)
            end)
            
            table.insert(pages, page)
            table.insert(tabButtons, btn)
            return page
        end
        
        local pageFarm = createTab("TabFarm", true)
        local pageQuest = createTab("TabQuest", false)
        local pageBoatSave = createTab("TabBoatSave", false)
        local pageChest = createTab("TabChest", false)
        local pageMovement = createTab("TabMovement", false)
        local pageVIP = createTab("TabExtraVIP", false)
        local pageWorld = createTab("TabWorld", false)
        local pageSystem = createTab("TabSystem", false)
        local pageKey = createTab("TabKey", false)
        local pageLang = createTab("TabLanguage", false)
        
        -- TAB 1: AUTO FARM VÀNG
        self:CreateSectionHeader(pageFarm, "SecFarm")
        self:CreateToggle(pageFarm, "AutoFarm", "AutoFarm", function(v)
            if v then Engine.Modules.FarmManager:Start() else Engine.Modules.FarmManager:Stop() end
        end)
        self:CreateSlider(pageFarm, "FarmSpeed", 50, 350, "FarmSpeed")
        self:CreateSlider(pageFarm, "FlyHeight", 20, 200, "FlyHeight")
        self:CreateSlider(pageFarm, "ChestWaitTime", 5, 30, "ChestWaitTime")
        self:CreateToggle(pageFarm, "FastSuicide", "FastSuicide")
        self:CreateToggle(pageFarm, "AntiWaterDamage", "AntiWaterDamage")

        -- TAB 2: TỰ LÀM NHIỆM VỤ (AUTO QUESTS 2.0 - BETA)
        self:CreateSectionHeader(pageQuest, "SecQuest")
        self:CreateNoticeBanner(pageQuest, "NoticeQuestBeta")
        
        self:CreateButton(pageQuest, "BtnDoAllQuests", function()
            Engine.Modules.QuestManager:DoAllQuests()
        end, Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 255, 255))
        
        self:CreateButton(pageQuest, "BtnQuestCloud", function()
            Engine.Modules.QuestManager:CompleteCloud()
        end)
        self:CreateButton(pageQuest, "BtnQuestTarget", function()
            Engine.Modules.QuestManager:CompleteTarget()
        end)
        self:CreateButton(pageQuest, "BtnQuestRamp", function()
            Engine.Modules.QuestManager:CompleteRamp()
        end)
        self:CreateButton(pageQuest, "BtnQuestFindMe", function()
            Engine.Modules.QuestManager:CompleteFindMe()
        end)
        self:CreateButton(pageQuest, "BtnQuestTheBox", function()
            Engine.Modules.QuestManager:CompleteTheBox()
        end)
        self:CreateButton(pageQuest, "BtnQuestSoccer", function()
            Engine.Modules.QuestManager:CompleteSoccer()
        end)
        self:CreateButton(pageQuest, "BtnQuestThinIce", function()
            Engine.Modules.QuestManager:CompleteThinIce()
        end)
        self:CreateButton(pageQuest, "BtnQuestDragon", function()
            Engine.Modules.QuestManager:CompleteDragon()
        end)

        -- TAB 3: LƯU & TẢI THUYỀN (SAVES & AUTO BUILDER - BETA)
        self:CreateSectionHeader(pageBoatSave, "SecBoatSlot")
        self:CreateNoticeBanner(pageBoatSave, "NoticeBoatBeta")
        
        -- Chọn Slot 1 -> 5
        local slotContainer = Instance.new("Frame")
        slotContainer.Size = UDim2.new(1, -10, 0, 36)
        slotContainer.BackgroundTransparency = 1
        slotContainer.Parent = pageBoatSave

        local slotBtns = {}
        for s = 1, 5 do
            local sBtn = Instance.new("TextButton")
            sBtn.Size = UDim2.new(0.18, 0, 1, 0)
            sBtn.Position = UDim2.new((s - 1) * 0.205, 0, 0, 0)
            local isSel = (Engine.Modules.ConfigManager.Settings.SelectedSlot == s)
            sBtn.BackgroundColor3 = isSel and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(25, 35, 54)
            sBtn.Text = "Slot " .. s
            sBtn.Font = Enum.Font.GothamBold
            sBtn.TextSize = 10.5
            sBtn.TextColor3 = isSel and Color3.fromRGB(10, 15, 25) or Color3.fromRGB(210, 230, 255)
            sBtn.Parent = slotContainer
            Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 8)

            sBtn.MouseButton1Click:Connect(function()
                Engine.Modules.ConfigManager.Settings.SelectedSlot = s
                Engine.Modules.ConfigManager:Save()
                for i, b in ipairs(slotBtns) do
                    b.BackgroundColor3 = (i == s) and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(25, 35, 54)
                    b.TextColor3 = (i == s) and Color3.fromRGB(10, 15, 25) or Color3.fromRGB(210, 230, 255)
                end
                if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                    Engine.Modules.NotificationManager:Notify("Slot Selected", "📌 Đã chọn Slot " .. s, 2)
                end
            end)
            table.insert(slotBtns, sBtn)
        end

        local actionSlotContainer = Instance.new("Frame")
        actionSlotContainer.Size = UDim2.new(1, -10, 0, 38)
        actionSlotContainer.BackgroundTransparency = 1
        actionSlotContainer.Parent = pageBoatSave

        local btnSaveSlot = Instance.new("TextButton")
        btnSaveSlot.Size = UDim2.new(0.48, 0, 1, 0)
        btnSaveSlot.Position = UDim2.new(0, 0, 0, 0)
        btnSaveSlot.BackgroundColor3 = Color3.fromRGB(210, 60, 120)
        btnSaveSlot.Text = Engine.Modules.I18n:Get("BtnSaveSlot")
        btnSaveSlot.Font = Enum.Font.GothamBold
        btnSaveSlot.TextSize = 10.5
        btnSaveSlot.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnSaveSlot.Parent = actionSlotContainer
        Instance.new("UICorner", btnSaveSlot).CornerRadius = UDim.new(0, 8)
        self:RegisterLabel(btnSaveSlot, "BtnSaveSlot")
        btnSaveSlot.MouseButton1Click:Connect(function()
            Engine.Modules.BoatSaveManager:SaveSlot()
        end)

        local btnLoadSlot = Instance.new("TextButton")
        btnLoadSlot.Size = UDim2.new(0.48, 0, 1, 0)
        btnLoadSlot.Position = UDim2.new(0.52, 0, 0, 0)
        btnLoadSlot.BackgroundColor3 = Color3.fromRGB(0, 200, 140)
        btnLoadSlot.Text = Engine.Modules.I18n:Get("BtnLoadSlot")
        btnLoadSlot.Font = Enum.Font.GothamBold
        btnLoadSlot.TextSize = 10.5
        btnLoadSlot.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnLoadSlot.Parent = actionSlotContainer
        Instance.new("UICorner", btnLoadSlot).CornerRadius = UDim.new(0, 8)
        self:RegisterLabel(btnLoadSlot, "BtnLoadSlot")
        btnLoadSlot.MouseButton1Click:Connect(function()
            Engine.Modules.BoatSaveManager:LoadSlot()
        end)

        self:CreateToggle(pageBoatSave, "AutoSaveSlot", "AutoSaveSlot")
        self:CreateToggle(pageBoatSave, "AutoLoadOnSpawn", "AutoLoadOnSpawn")

        -- File Boat Saver & Builder Section
        self:CreateSectionHeader(pageBoatSave, "SecBoatFile")
        
        local fileNameBoxBg = Instance.new("Frame")
        fileNameBoxBg.Size = UDim2.new(1, -10, 0, 36)
        fileNameBoxBg.BackgroundColor3 = Color3.fromRGB(22, 30, 46)
        fileNameBoxBg.Parent = pageBoatSave
        Instance.new("UICorner", fileNameBoxBg).CornerRadius = UDim.new(0, 8)

        local fileNameBox = Instance.new("TextBox")
        fileNameBox.Size = UDim2.new(1, -16, 1, 0)
        fileNameBox.Position = UDim2.new(0, 8, 0, 0)
        fileNameBox.BackgroundTransparency = 1
        fileNameBox.Text = Engine.Modules.ConfigManager.Settings.SavedBoatFileName or "MyBoat_1"
        fileNameBox.PlaceholderText = Engine.Modules.I18n:Get("PlaceholderBoatName")
        fileNameBox.PlaceholderColor3 = Color3.fromRGB(110, 130, 160)
        fileNameBox.TextColor3 = Color3.fromRGB(0, 240, 255)
        fileNameBox.Font = Enum.Font.GothamBold
        fileNameBox.TextSize = 11.5
        fileNameBox.Parent = fileNameBoxBg

        fileNameBox.FocusLost:Connect(function()
            Engine.Modules.ConfigManager.Settings.SavedBoatFileName = fileNameBox.Text
            Engine.Modules.ConfigManager:Save()
        end)

        local actionFileContainer = Instance.new("Frame")
        actionFileContainer.Size = UDim2.new(1, -10, 0, 38)
        actionFileContainer.BackgroundTransparency = 1
        actionFileContainer.Parent = pageBoatSave

        local btnSaveFile = Instance.new("TextButton")
        btnSaveFile.Size = UDim2.new(0.48, 0, 1, 0)
        btnSaveFile.Position = UDim2.new(0, 0, 0, 0)
        btnSaveFile.BackgroundColor3 = Color3.fromRGB(34, 48, 76)
        btnSaveFile.Text = Engine.Modules.I18n:Get("BtnSaveToFile")
        btnSaveFile.Font = Enum.Font.GothamBold
        btnSaveFile.TextSize = 10.5
        btnSaveFile.TextColor3 = Color3.fromRGB(0, 240, 255)
        btnSaveFile.Parent = actionFileContainer
        Instance.new("UICorner", btnSaveFile).CornerRadius = UDim.new(0, 8)
        self:RegisterLabel(btnSaveFile, "BtnSaveToFile")
        btnSaveFile.MouseButton1Click:Connect(function()
            Engine.Modules.BoatSaveManager:SaveBoatToFile(fileNameBox.Text)
        end)

        local btnLoadFile = Instance.new("TextButton")
        btnLoadFile.Size = UDim2.new(0.48, 0, 1, 0)
        btnLoadFile.Position = UDim2.new(0.52, 0, 0, 0)
        btnLoadFile.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        btnLoadFile.Text = Engine.Modules.I18n:Get("BtnLoadFromFile")
        btnLoadFile.Font = Enum.Font.GothamBold
        btnLoadFile.TextSize = 10.5
        btnLoadFile.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnLoadFile.Parent = actionFileContainer
        Instance.new("UICorner", btnLoadFile).CornerRadius = UDim.new(0, 8)
        self:RegisterLabel(btnLoadFile, "BtnLoadFromFile")
        btnLoadFile.MouseButton1Click:Connect(function()
            Engine.Modules.BoatSaveManager:LoadBoatFromFile(fileNameBox.Text)
        end)
        
        -- TAB 4: MUA RƯƠNG & SHOP
        self:CreateSectionHeader(pageChest, "SecChest")
        self:CreateToggle(pageChest, "AutoBuyChest", "AutoBuyChest")
        self:CreateSlider(pageChest, "BuyInterval", 0.5, 5, "BuyInterval")

        -- TAB 5: TỐC ĐỘ & BAY
        self:CreateSectionHeader(pageMovement, "SecMovement")
        self:CreateToggle(pageMovement, "Fly", "Fly")
        self:CreateSlider(pageMovement, "FlySpeed", 30, 300, "FlySpeed")
        self:CreateToggle(pageMovement, "WalkSpeed", "Speed")
        self:CreateSlider(pageMovement, "SpeedValue", 16, 150, "SpeedValue")
        self:CreateToggle(pageMovement, "JumpPower", "JumpPower")
        self:CreateSlider(pageMovement, "JumpPowerValue", 50, 300, "JumpPowerValue")
        self:CreateToggle(pageMovement, "Noclip", "Noclip")
        self:CreateToggle(pageMovement, "InfJump", "InfJump")

        -- TAB 6: TÍNH NĂNG ĐỘC QUYỀN VIP & HACK TIỆN ÍCH
        self:CreateSectionHeader(pageVIP, "SecExtraVIP")
        self:CreateButton(pageVIP, "BtnRedeemCodes", function()
            Engine.Modules.ExtraVIP:RedeemAllCodes()
        end, Color3.fromRGB(240, 160, 0), Color3.fromRGB(15, 20, 30))
        self:CreateButton(pageVIP, "BtnClaimGifts", function()
            Engine.Modules.ExtraVIP:ClaimDailyGifts()
        end, Color3.fromRGB(0, 200, 120), Color3.fromRGB(255, 255, 255))
        self:CreateToggle(pageVIP, "JesusMode", "JesusMode", function(v)
            Engine.Modules.ExtraVIP:ToggleJesusMode(v)
        end)
        self:CreateSlider(pageVIP, "JesusHeight", -10, 25, "JesusHeightOffset")
        self:CreateToggle(pageVIP, "Godmode", "Godmode")
        self:CreateToggle(pageVIP, "ChestESP", "ChestESP", function(v)
            Engine.Modules.ExtraVIP:ToggleChestESP(v)
        end)
        self:CreateToggle(pageVIP, "AutoRejoin", "AutoRejoin")

        self:CreateSectionHeader(pageVIP, "SecPlotTeleport")
        local plotBtns = {
            {Name = "🔴 Sân Đỏ (Red)", Key = "Red"},
            {Name = "🔵 Sân Xanh Dương (Blue)", Key = "Blue"},
            {Name = "🟢 Sân Xanh Lá (Green)", Key = "Green"},
            {Name = "🟡 Sân Vàng (Yellow)", Key = "Yellow"},
            {Name = "⚪ Sân Trắng (White)", Key = "White"},
            {Name = "⚫ Sân Đen (Black)", Key = "Black"},
            {Name = "🟣 Sân Hồng (Magenta)", Key = "Magenta"}
        }
        for _, p in ipairs(plotBtns) do
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -10, 0, 32)
            pBtn.BackgroundColor3 = Color3.fromRGB(24, 34, 52)
            pBtn.Text = p.Name
            pBtn.Font = Enum.Font.GothamBold
            pBtn.TextSize = 11
            pBtn.TextColor3 = Color3.fromRGB(0, 240, 255)
            pBtn.Parent = pageVIP
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 8)
            self:AddHoverAnim(pBtn, Color3.fromRGB(24, 34, 52), Color3.fromRGB(36, 50, 78))
            pBtn.MouseButton1Click:Connect(function()
                Engine.Modules.ExtraVIP:TeleportToPlot(p.Key)
            end)
        end

        -- TAB 7: THỜI GIAN & ÁNH SÁNG
        self:CreateSectionHeader(pageWorld, "SecWorldLighting")
        local btnLightContainer = Instance.new("Frame")
        btnLightContainer.Size = UDim2.new(1, -10, 0, 42)
        btnLightContainer.BackgroundTransparency = 1
        btnLightContainer.Parent = pageWorld

        local function createTimeBtn(keyName, posScale, widthScale, bgCol, textCol, modeName, notifyMsg)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(widthScale, -3, 1, 0)
            btn.Position = UDim2.new(posScale, 0, 0, 0)
            btn.BackgroundColor3 = bgCol
            btn.Text = Engine.Modules.I18n:Get(keyName)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10.5
            btn.TextColor3 = textCol
            btn.Parent = btnLightContainer
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            self:AddHoverAnim(btn, bgCol, Color3.fromRGB(math.clamp(math.floor(bgCol.R*255)+20,0,255), math.clamp(math.floor(bgCol.G*255)+20,0,255), math.clamp(math.floor(bgCol.B*255)+20,0,255)))
            self:RegisterLabel(btn, keyName)

            btn.MouseButton1Click:Connect(function()
                Engine.Modules.LightingManager:ApplyMode(modeName)
                Engine.Modules.ConfigManager:Save()
                if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                    Engine.Modules.NotificationManager:Notify("World Time", notifyMsg, 2.5)
                end
            end)
        end

        createTimeBtn("TimeDay", 0, 0.24, Color3.fromRGB(220, 235, 255), Color3.fromRGB(15, 25, 45), "Light", "☀️ Đã chuyển sang Thời Gian Ban Sáng!")
        createTimeBtn("TimeSunset", 0.25, 0.24, Color3.fromRGB(255, 140, 90), Color3.fromRGB(255, 255, 255), "Sunset", "🌅 Đã chuyển sang Thời Gian Hoàng Hôn!")
        createTimeBtn("TimeNight", 0.50, 0.24, Color3.fromRGB(22, 32, 52), Color3.fromRGB(0, 240, 255), "Dark", "🌙 Đã chuyển sang Thời Gian Buổi Tối!")
        createTimeBtn("TimeDefault", 0.75, 0.24, Color3.fromRGB(30, 45, 65), Color3.fromRGB(0, 255, 180), "Normal", "🍃 Đã khôi phục Thời Gian Mặc Định!")

        -- TAB 8: HỆ THỐNG & FIX LAG
        self:CreateSectionHeader(pageSystem, "SecSystem")
        self:CreateToggle(pageSystem, "ShowHUD", "ShowHUD")
        self:CreateToggle(pageSystem, "EnableNotifications", "EnableNotifications")
        self:CreateToggle(pageSystem, "SilentMode", "SilentMode")
        self:CreateToggle(pageSystem, "FPSBooster", "FPSBooster", function(v)
            if v then Engine.Modules.PerformanceBooster:Init() end
        end)
        self:CreateToggle(pageSystem, "AntiAFK", "AntiAFK")

        -- TAB 9: NGÔN NGỮ
        self:CreateSectionHeader(pageLang, "SecLang")
        self.BtnSwitchLang = Instance.new("TextButton")
        self.BtnSwitchLang.Size = UDim2.new(1, -10, 0, 44)
        self.BtnSwitchLang.BackgroundColor3 = Color3.fromRGB(22, 32, 52)
        local currLang = Engine.Modules.ConfigManager.Settings.Language or "VN"
        self.BtnSwitchLang.Text = (currLang == "VN") and "🌐 Switch Language / Chuyển Ngôn Ngữ (VN ➔ EN)" or "🌐 Switch Language / Chuyển Ngôn Ngữ (EN ➔ VN)"
        self.BtnSwitchLang.Font = Enum.Font.GothamBold
        self.BtnSwitchLang.TextSize = 11
        self.BtnSwitchLang.TextColor3 = Color3.fromRGB(0, 255, 180)
        self.BtnSwitchLang.Parent = pageLang
        Instance.new("UICorner", self.BtnSwitchLang).CornerRadius = UDim.new(0, 10)
        self:AddHoverAnim(self.BtnSwitchLang, Color3.fromRGB(22, 32, 52), Color3.fromRGB(34, 48, 76))
        
        self.BtnSwitchLang.MouseButton1Click:Connect(function()
            local newLang = Engine.Modules.I18n:ToggleLang()
            self:RefreshLanguage()
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Language / Ngôn Ngữ", (newLang == "VN") and "✓ Đã chuyển sang Tiếng Việt!" or "✓ Switched language to English!", 3)
            end
        end)

        -- TAB 10: HỆ THỐNG KEY & ACC
        self:CreateSectionHeader(pageKey, "SecKey")
        local keyCard = Instance.new("Frame")
        keyCard.Size = UDim2.new(1, -10, 0, 210)
        keyCard.BackgroundColor3 = Color3.fromRGB(16, 22, 35)
        keyCard.BackgroundTransparency = 0.45
        keyCard.Parent = pageKey
        Instance.new("UICorner", keyCard).CornerRadius = UDim.new(0, 12)

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Thickness = 1
        cardStroke.Color = Color3.fromRGB(0, 240, 255)
        cardStroke.Transparency = 0.85
        cardStroke.Parent = keyCard
        
        local keyTitle = Instance.new("TextLabel")
        keyTitle.Size = UDim2.new(1, -20, 0, 24)
        keyTitle.Position = UDim2.new(0, 12, 0, 8)
        keyTitle.BackgroundTransparency = 1
        keyTitle.Text = Engine.Modules.I18n:Get("KeyInfoTitle")
        keyTitle.Font = Enum.Font.GothamBlack
        keyTitle.TextSize = 12.5
        keyTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
        keyTitle.TextXAlignment = Enum.TextXAlignment.Left
        keyTitle.Parent = keyCard
        self:RegisterLabel(keyTitle, "KeyInfoTitle")
        
        local keyValLabel = Instance.new("TextLabel")
        keyValLabel.Size = UDim2.new(1, -24, 0, 20)
        keyValLabel.Position = UDim2.new(0, 12, 0, 36)
        keyValLabel.BackgroundTransparency = 1
        keyValLabel.Text = Engine.Modules.I18n:Get("KeyVal") .. (Engine.Modules.KeySystem.CurrentKey or "N/A")
        keyValLabel.Font = Enum.Font.GothamMedium
        keyValLabel.TextSize = 11
        keyValLabel.TextColor3 = Color3.fromRGB(220, 230, 245)
        keyValLabel.TextXAlignment = Enum.TextXAlignment.Left
        keyValLabel.Parent = keyCard
        self:RegisterLabel(keyValLabel, "KeyVal", "", (Engine.Modules.KeySystem.CurrentKey or "N/A"))

        local keyTimeLabel = Instance.new("TextLabel")
        keyTimeLabel.Size = UDim2.new(1, -24, 0, 20)
        keyTimeLabel.Position = UDim2.new(0, 12, 0, 58)
        keyTimeLabel.BackgroundTransparency = 1
        keyTimeLabel.Text = Engine.Modules.I18n:Get("KeyRemaining") .. Engine.Modules.KeySystem:GetRemainingTime()
        keyTimeLabel.Font = Enum.Font.GothamMedium
        keyTimeLabel.TextSize = 11
        keyTimeLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
        keyTimeLabel.TextXAlignment = Enum.TextXAlignment.Left
        keyTimeLabel.Parent = keyCard
        self:RegisterLabel(keyTimeLabel, "KeyRemaining")
        
        task.spawn(function()
            while task.wait(1) do
                if pageKey and pageKey.Visible then
                    keyTimeLabel.Text = Engine.Modules.I18n:Get("KeyRemaining") .. Engine.Modules.KeySystem:GetRemainingTime()
                end
            end
        end)

        local btnCardGetKey = Instance.new("TextButton")
        btnCardGetKey.Size = UDim2.new(1, -24, 0, 32)
        btnCardGetKey.Position = UDim2.new(0, 12, 0, 88)
        btnCardGetKey.BackgroundColor3 = Color3.fromRGB(22, 35, 56)
        btnCardGetKey.Text = Engine.Modules.I18n:Get("KeyWebBtn")
        btnCardGetKey.Font = Enum.Font.GothamBold
        btnCardGetKey.TextSize = 10
        btnCardGetKey.TextColor3 = Color3.fromRGB(0, 240, 255)
        btnCardGetKey.Parent = keyCard
        Instance.new("UICorner", btnCardGetKey).CornerRadius = UDim.new(0, 8)
        self:AddHoverAnim(btnCardGetKey, Color3.fromRGB(22, 35, 56), Color3.fromRGB(34, 52, 82))
        self:RegisterLabel(btnCardGetKey, "KeyWebBtn")
        btnCardGetKey.MouseButton1Click:Connect(function()
            if setclipboard or toclipboard then
                pcall(function() (setclipboard or toclipboard)(Engine.Modules.KeySystem.KeyURL) end)
            end
            if Engine.Modules.NotificationManager and Engine.Modules.NotificationManager.Notify then
                Engine.Modules.NotificationManager:Notify("Get Key", "✓ Đã sao chép Link Get Key 24h!", 3)
            end
        end)

        local btnCardDiscord = Instance.new("TextButton")
        btnCardDiscord.Size = UDim2.new(1, -24, 0, 32)
        btnCardDiscord.Position = UDim2.new(0, 12, 0, 126)
        btnCardDiscord.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        btnCardDiscord.Text = Engine.Modules.I18n:Get("KeyDiscordBtn")
        btnCardDiscord.Font = Enum.Font.GothamBold
        btnCardDiscord.TextSize = 10
        btnCardDiscord.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnCardDiscord.Parent = keyCard
        Instance.new("UICorner", btnCardDiscord).CornerRadius = UDim.new(0, 8)
        self:AddHoverAnim(btnCardDiscord, Color3.fromRGB(88, 101, 242), Color3.fromRGB(105, 118, 255))
        self:RegisterLabel(btnCardDiscord, "KeyDiscordBtn")
        btnCardDiscord.MouseButton1Click:Connect(function()
            Engine.Modules.KeySystem:JoinDiscord()
        end)
        
        local btnLogout = Instance.new("TextButton")
        btnLogout.Size = UDim2.new(1, -24, 0, 32)
        btnLogout.Position = UDim2.new(0, 12, 0, 164)
        btnLogout.BackgroundColor3 = Color3.fromRGB(210, 45, 55)
        btnLogout.Text = Engine.Modules.I18n:Get("BtnLogout")
        btnLogout.Font = Enum.Font.GothamBlack
        btnLogout.TextSize = 11
        btnLogout.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnLogout.Parent = keyCard
        Instance.new("UICorner", btnLogout).CornerRadius = UDim.new(0, 8)
        self:AddHoverAnim(btnLogout, Color3.fromRGB(210, 45, 55), Color3.fromRGB(235, 65, 75))
        self:RegisterLabel(btnLogout, "BtnLogout")
        
        btnLogout.MouseButton1Click:Connect(function()
            Engine.Modules.KeySystem:Logout()
        end)
        
        for _, p in pairs(pages) do p.CanvasSize = UDim2.new(0, 0, 0, #p:GetChildren() * 46 + 60) end
    end,
    
    CreateToggle = function(self, parent, translationKey, configKey, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 44)
        frame.BackgroundColor3 = Color3.fromRGB(238, 244, 254)
        frame.BackgroundTransparency = 0.52
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Thickness = 1
        frameStroke.Color = Color3.fromRGB(205, 220, 242)
        frameStroke.Transparency = 0.85
        frameStroke.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -72, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = Engine.Modules.I18n:Get(translationKey)
        label.TextColor3 = Color3.fromRGB(18, 28, 48)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        self:RegisterLabel(label, translationKey)
        if self.ThemeFrames then table.insert(self.ThemeFrames, frame) end
        if self.ThemeLabels then table.insert(self.ThemeLabels, label) end
        
        local toggleBtn = Instance.new("TextButton")
        local isON = Engine.Modules.ConfigManager.Settings[configKey]
        toggleBtn.Name = isON and "ToggledBG" or "OffBG"
        toggleBtn.Size = UDim2.new(0, 46, 0, 24)
        toggleBtn.Position = UDim2.new(1, -56, 0.5, -12)
        toggleBtn.BackgroundColor3 = isON and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(28, 36, 52)
        toggleBtn.BackgroundTransparency = isON and 0.15 or 0.4
        toggleBtn.Text = ""
        toggleBtn.Parent = frame
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

        local toggleStroke = Instance.new("UIStroke")
        toggleStroke.Thickness = 1.2
        toggleStroke.Color = isON and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(60, 70, 90)
        toggleStroke.Transparency = 0.3
        toggleStroke.Parent = toggleBtn
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = isON and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.Parent = toggleBtn
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Position = UDim2.new(0.5, -3, 0.5, -3)
        dot.BackgroundColor3 = isON and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(150, 160, 180)
        dot.Parent = circle
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        
        if isON then table.insert(self.ChromaObjects, toggleBtn) end
        
        local function updateVisual(newState)
            toggleBtn.Name = newState and "ToggledBG" or "OffBG"
            local goalPos = newState and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
            local goalColor = newState and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(28, 36, 52)
            local goalStroke = newState and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(60, 70, 90)
            local dotColor = newState and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(150, 160, 180)
            
            Engine.Services.TweenService:Create(circle, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = goalPos}):Play()
            Engine.Services.TweenService:Create(toggleBtn, TweenInfo.new(0.22), {BackgroundColor3 = goalColor}):Play()
            Engine.Services.TweenService:Create(toggleStroke, TweenInfo.new(0.22), {Color = goalStroke}):Play()
            Engine.Services.TweenService:Create(dot, TweenInfo.new(0.22), {BackgroundColor3 = dotColor}):Play()
            
            if newState then 
                table.insert(self.ChromaObjects, toggleBtn) 
            else
                for i, obj in ipairs(self.ChromaObjects) do 
                    if obj == toggleBtn then table.remove(self.ChromaObjects, i) break end 
                end
            end
        end

        self.Toggles[configKey] = updateVisual

        toggleBtn.MouseButton1Click:Connect(function()
            local newState = not Engine.Modules.ConfigManager.Settings[configKey]
            Engine.Modules.ConfigManager.Settings[configKey] = newState
            Engine.Modules.ConfigManager:Save()
            updateVisual(newState)
            if callback then callback(newState) end
        end)
    end,
    
    CreateSlider = function(self, parent, translationKey, min, max, configKey)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 60)
        frame.BackgroundColor3 = Color3.fromRGB(238, 244, 254)
        frame.BackgroundTransparency = 0.52
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Thickness = 1
        frameStroke.Color = Color3.fromRGB(205, 220, 242)
        frameStroke.Transparency = 0.85
        frameStroke.Parent = frame
        
        local default = Engine.Modules.ConfigManager.Settings[configKey]
        if default == nil then default = min end
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -14, 0, 24)
        label.Position = UDim2.new(0, 14, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = Engine.Modules.I18n:Get(translationKey) .. ": " .. string.format("%.2f", default)
        label.TextColor3 = Color3.fromRGB(18, 28, 48)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        self:RegisterLabel(label, translationKey, "", "", true, configKey)
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -28, 0, 7)
        bar.Position = UDim2.new(0, 14, 0, 39)
        bar.BackgroundColor3 = Color3.fromRGB(28, 36, 52)
        bar.BackgroundTransparency = 0.3
        bar.Parent = frame
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        
        local fillRatio = math.clamp((default - min) / (max - min), 0, 1)
        local fill = Instance.new("Frame")
        fill.Name = "ToggledBG"
        fill.Size = UDim2.new(fillRatio, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 230, 255)
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        table.insert(self.ChromaObjects, fill)
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 17, 0, 17)
        knob.Position = UDim2.new(fillRatio, -8.5, 0.5, -8.5)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Text = ""
        knob.Parent = bar
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local knobStroke = Instance.new("UIStroke")
        knobStroke.Thickness = 1.6
        knobStroke.Color = Color3.fromRGB(0, 240, 255)
        knobStroke.Parent = knob
        
        local dragging = false
        knob.MouseButton1Down:Connect(function() 
            dragging = true 
            Engine.Services.TweenService:Create(knob, TweenInfo.new(0.15), {Size = UDim2.new(0, 21, 0, 21)}):Play()
        end)
        Engine.Services.UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                dragging = false
                Engine.Services.TweenService:Create(knob, TweenInfo.new(0.15), {Size = UDim2.new(0, 17, 0, 17)}):Play()
                Engine.Modules.ConfigManager:Save()
            end
        end)
        
        Engine.Services.RunService.RenderStepped:Connect(function()
            if dragging then
                local mouseX = Engine.Services.UIS:GetMouseLocation().X
                local barX = bar.AbsolutePosition.X
                local barW = bar.AbsoluteSize.X
                local percent = math.clamp((mouseX - barX) / barW, 0, 1)
                local val = min + (max - min) * percent
                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, -8.5, 0.5, -8.5)
                label.Text = Engine.Modules.I18n:Get(translationKey) .. ": " .. string.format("%.2f", val)
                Engine.Modules.ConfigManager.Settings[configKey] = val
            end
        end)
    end
}

-- ==========================================
-- [10] BOOTSTRAPPER
-- ==========================================
Engine.BootAfterKey = function(self)
    self.Modules.NotificationManager:Init()
    self.Modules.HUDManager:Init()
    self.Modules.UIController:Init()
    if self.Modules.UIThemeManager then
        self.Modules.UIThemeManager:ApplyTheme()
    end
    self.Status = "Running"
    
    self.Modules.NotificationManager:Notify("BABFT CLASS QUID V9.1", "Khởi động thành công! Bản quyền: " .. Engine.Author, 5)
    
    if self.Modules.ConfigManager.Settings.AutoFarm then
        self.Modules.FarmManager:Start()
    end
    if self.Modules.ConfigManager.Settings.ChestESP then
        self.Modules.ExtraVIP:ToggleChestESP(true)
    end
    if self.Modules.ConfigManager.Settings.JesusMode then
        self.Modules.ExtraVIP:ToggleJesusMode(true)
    end
end

Engine.Boot = function(self)
    self.Modules.ConfigManager:Load()
    self.Modules.PerformanceBooster:Init()
    
    self.Modules.LoadingScreen:Show()
    
    local keyVerified = self.Modules.KeySystem:PromptKeyUI()
    if not keyVerified then return end
    
    self:BootAfterKey()
end

-- Khởi chạy Engine
Engine:Boot()
