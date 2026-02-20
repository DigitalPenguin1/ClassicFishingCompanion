-- Classic Fishing Companion - Core Module
-- Handles initialization, event handling, and core functionality

local addonName, addon = ...
CFC = LibStub("AceAddon-3.0"):NewAddon("ClassicFishingCompanion", "AceEvent-3.0", "AceConsole-3.0") or {}

-- Create namespace if Ace3 not available
if not CFC.RegisterEvent then
    CFC = {
        events = {},
        db = {}
    }
end

-- Local references
local CFC = CFC

-- Version constant (single source of truth)
CFC.VERSION = "1.1.2"

-- Centralized color codes for consistent styling
CFC.COLORS = {
    SUCCESS = "|cff00ff00",   -- Green - success messages, positive values
    ERROR = "|cffff0000",     -- Red - error messages, critical warnings
    WARNING = "|cffffff00",   -- Yellow - warnings, caution
    DEBUG = "|cffff8800",     -- Orange - debug messages
    TIP = "|cffffcc00",       -- Gold - tips, hints
    INFO = "|cffaaaaaa",      -- Gray - secondary info
    HEADER = "|cffffd700",    -- Gold - section headers
    RESET = "|r",             -- Reset color
    -- Item quality colors (WoW standard)
    QUALITY = {
        [0] = "|cff9d9d9d",   -- Poor (gray)
        [1] = "|cffffffff",   -- Common (white)
        [2] = "|cff1eff00",   -- Uncommon (green)
        [3] = "|cff0070dd",   -- Rare (blue)
        [4] = "|cffa335ee",   -- Epic (purple)
        [5] = "|cffff8000",   -- Legendary (orange)
        [6] = "|cffe6cc80",   -- Artifact (light gold)
        [7] = "|cff00ccff",   -- Heirloom (light blue)
    },
}

-- Centralized constants to avoid magic numbers
CFC.CONSTANTS = {
    -- Equipment slot IDs
    SLOTS = {
        MAIN_HAND = 16,
        OFF_HAND = 17,
        TABARD = 19,
    },
    -- Bag indices
    BAGS = {
        FIRST = 0,
        LAST = 4,
    },
    -- Timing intervals (seconds)
    INTERVALS = {
        CAST_TIMEOUT = 2,
        BUFF_CHECK = 60,
        ICON_REFRESH = 300,
        AUTO_BACKUP = 86400,      -- 24 hours
        EXPORT_REMINDER = 604800, -- 7 days
    },
    -- Known fishing lure item IDs (for reliable detection)
    LURE_IDS = {
        [6529] = "Shiny Bauble",
        [6530] = "Nightcrawlers",
        [6811] = "Bright Baubles",
        [7307] = "Flesh Eating Worm",
        [6533] = "Aquadynamic Fish Attractor",
    },
    -- Weapon enchant IDs for fishing lures (locale-independent detection)
    LURE_ENCHANT_IDS = {
        [2603] = "Shiny Bauble",           -- +25 fishing
        [2604] = "Nightcrawlers",          -- +50 fishing
        [2605] = "Bright Baubles",         -- +75 fishing
        [2606] = "Aquadynamic Fish Attractor", -- +100 fishing
        [2607] = "Flesh Eating Worm",      -- +75 fishing
        [2608] = "Aquadynamic Fish Lens",  -- +50 fishing (Engineering)
        [34861] = "Sharpened Fish Hook",   -- +100 fishing (TBC)
    },
    -- Catch milestones for notifications
    MILESTONES = {
        100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000
    },
    -- Rare fish item IDs (for sound notification)
    RARE_FISH = {
        [19803] = "Brownell's Blue Striped Racer",
        [19806] = "Dezian Queenfish",
        [8221] = "Keefer's Angelfish",
        [27388] = "Mr. Pinchy",
        [16967] = "Feralas Ahi",
        [16970] = "Misty Reed Mahi Mahi",
        [16968] = "Sar'theris Striker",
        [16969] = "Savage Coast Blue Sailfin",
    },
    -- Sound ID for rare fish catch (Classic-compatible)
    RARE_FISH_SOUND = 2689,
}

-- Default database structure
local defaults = {
    profile = {
        minimap = {
            hide = false,  -- Show by default
            minimapPos = 220,
        },
        settings = {
            perCharacterMode = false,  -- Use per-character statistics instead of account-wide (disabled by default)
            announceLures = true,  -- Warn when fishing without lure (enabled by default)
            lureWarningInterval = 30,  -- Interval in seconds for lure warning (30, 60, or 90)
            announceCatches = false,  -- Announce fish catches in chat
            announceSkillUps = true,  -- Announce fishing skill increases (enabled by default)
            maxSkillAnnounceEnabled = false,  -- Enable/disable max skill announcements (disabled by default)
            maxSkillAnnounce = "GUILD",  -- Channel to announce max fishing skill: SAY, PARTY, GUILD, EMOTE
            milestonesAnnounceEnabled = false,  -- Enable/disable milestone announcements (disabled by default)
            milestonesAnnounce = "GUILD",  -- Channel to announce milestones: SAY, PARTY, GUILD, EMOTE
            autoSwapOnHUD = false,  -- Auto-swap to fishing gear when showing HUD via minimap right-click
            autoSwapCombatWeapons = false,  -- Auto-swap to combat weapons when entering combat while fishing (disabled by default)
            easyCast = false,  -- Double right-click to cast fishing
            rareFishSound = true,  -- Play sound when catching rare fish (enabled by default)
            minimalHUD = false,  -- Minimal HUD mode: no border, more translucent background (disabled by default)
            hudShowLureButton = true,  -- Show lure button on HUD (enabled by default)
            hudShowSwapButton = true,  -- Show gear swap button on HUD (enabled by default)
        },
        hud = {
            show = true,  -- Show stats HUD by default
            locked = false,  -- HUD is unlocked by default (can be dragged)
            scale = 1.0,  -- HUD scale factor (0.75 to 1.5)
            point = "CENTER",
            relativeTo = "UIParent",
            relativePoint = "CENTER",
            xOffset = 0,
            yOffset = 200,
        },
        catches = {},  -- Stores all fish catches
        statistics = {
            totalCatches = 0,
            sessionCatches = 0,
            sessionStartTime = 0,
            totalFishingTime = 0,
            currentSkill = 0,
            maxSkill = 0,
        },
        fishData = {},  -- Stores data per fish type
        sessions = {},  -- Stores fishing session data
        buffUsage = {},  -- Tracks fishing buff usage (lures, bobbers, etc)
        skillLevels = {},  -- Tracks fishing skill level ups
        poleUsage = {},  -- Tracks fishing pole usage
        gearSets = {
            fishing = {},  -- Fishing gear set (saved item links)
            combat = {},   -- Combat gear set (saved item links)
            currentMode = "combat",  -- Current gear mode: "fishing" or "combat"
        },
        backup = {
            enabled = true,  -- Enable automatic backups (enabled by default)
            lastBackupTime = 0,  -- Timestamp of last backup (total play time in seconds)
            lastExportReminder = 0,  -- Timestamp of last export reminder (total play time in seconds)
            data = nil,  -- Backup snapshot of fishing data
        },
        goals = {},        -- Active fishing goals: { fishName, targetCount, sessionCatches }
        releaseList = {},  -- Catch & Release: { ["Fish Name"] = true }
    }
}

-- Initialize database
function CFC:OnInitialize()
    -- Initialize saved variables (both account-wide and per-character)
    if not ClassicFishingCompanionDB then
        ClassicFishingCompanionDB = {}
    end
    if not ClassicFishingCompanionCharDB then
        ClassicFishingCompanionCharDB = {}
    end

    -- Initialize account-wide database first (to get settings)
    if not ClassicFishingCompanionDB.profile then
        ClassicFishingCompanionDB.profile = {}
    end

    -- Ensure settings exist in account-wide DB (settings are always account-wide)
    if not ClassicFishingCompanionDB.profile.settings then
        ClassicFishingCompanionDB.profile.settings = {}
    end
    for k, v in pairs(defaults.profile.settings) do
        if ClassicFishingCompanionDB.profile.settings[k] == nil then
            ClassicFishingCompanionDB.profile.settings[k] = v
        end
    end

    -- Choose which database to use based on perCharacterMode setting
    local usePerCharacter = ClassicFishingCompanionDB.profile.settings.perCharacterMode
    if usePerCharacter then
        self.db = ClassicFishingCompanionCharDB
    else
        self.db = ClassicFishingCompanionDB
    end

    -- Set defaults if not exist
    if not self.db.profile then
        self.db.profile = {}
    end

    -- Ensure all default structures exist
    for key, value in pairs(defaults.profile) do
        if self.db.profile[key] == nil then
            -- Deep copy for nested tables
            if type(value) == "table" then
                self.db.profile[key] = {}
                for k, v in pairs(value) do
                    if type(v) == "table" then
                        self.db.profile[key][k] = {}
                        for kk, vv in pairs(v) do
                            self.db.profile[key][k][kk] = vv
                        end
                    else
                        self.db.profile[key][k] = v
                    end
                end
            else
                self.db.profile[key] = value
            end
        end
    end

    -- Database migration system
    if not self.db.profile.dbVersion or self.db.profile.dbVersion < 2 then
        -- Mark database version immediately
        self.db.profile.dbVersion = 2

        -- Schedule migration message after 30 seconds to allow item cache to load
        C_Timer.After(30, function()
            -- Check if user has any fish data
            local fishCount = 0
            for _ in pairs(self.db.profile.fishData) do
                fishCount = fishCount + 1
            end

            if fishCount > 0 then
                print("|cffffcc00Classic Fishing Companion:|r Database upgraded to v" .. CFC.VERSION .. "!")
                print("|cffffcc00Tip:|r Fish icons will now cache reliably. Use 'Refresh Icons' button in Fish List if you have fish in your bags.")
            end
        end)
    end

    -- Reset session statistics on login
    self.db.profile.statistics.sessionCatches = 0
    self.db.profile.statistics.sessionStartTime = time()

    -- Reset goal session progress
    if self.db.profile.goals then
        for _, goal in ipairs(self.db.profile.goals) do
            goal.sessionCatches = 0
        end
    end

    print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion" .. CFC.COLORS.RESET .. " loaded! v" .. CFC.VERSION .. " by Relyk. Type " .. CFC.COLORS.DEBUG .. "/cfc" .. CFC.COLORS.RESET .. " to open or use the minimap button.")
    print(CFC.COLORS.TIP .. "Tip:" .. CFC.COLORS.RESET .. " Always export your fishing data from Settings for backup!")
end

-- Handle addon loading
function CFC:OnEnable()
    -- Initialize spell tracking variables
    self.lastSpellCast = nil
    self.lastSpellTime = 0
    self.fishingStartTime = 0
    self.isFishing = false
    self.lastSkillCheck = 0
    self.lastLootWasFishing = false
    self.lastBuffWarningTime = 0  -- Track when we last warned about missing buff
    self.currentTrackedBuff = nil  -- Track currently active buff to detect changes
    self.currentBuffExpiration = 0  -- Track buff expiration time to detect reapplications
    self.currentTrackedPole = nil  -- Track current pole to detect changes
    self.lastPoleTrackTime = 0  -- Track last time we counted a pole cast
    self.lastBuffTrackTime = 0  -- Track last time we counted a buff application
    self.addonJustLoaded = true  -- Flag to prevent counting existing lures on first check after load/reload
    self.easyCastLootClosedTime = 0  -- Track when loot window closed for Easy Cast
    self.lastFishingCastTime = 0  -- Track when player last cast Fishing spell (for fallback detection)
    self.autoSwappedCombatWeapons = false  -- Track if we auto-swapped to combat weapons during combat
    self.isFishingChannelActive = false  -- Track if we're currently channeling fishing
    self.combatStopBindingActive = false  -- Track if combat stop binding is set
    self.lastNoLureWarningTime = 0  -- Track when we last warned about being out of lures

    -- Create scanning tooltip for lure detection
    if not CFC_ScanTooltip then
        CFC_ScanTooltip = CreateFrame("GameTooltip", "CFC_ScanTooltip", nil, "GameTooltipTemplate")
        CFC_ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end

    -- Start automatic background icon refresh (runs every 5 minutes)
    self:ScheduleBackgroundIconRefresh()

    -- Register events
    self:RegisterEvent("CHAT_MSG_LOOT", "OnLootReceived")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEntering")
    self:RegisterEvent("PLAYER_LOGOUT", "OnLogout")
    self:RegisterEvent("CHAT_MSG_SKILL", "OnSkillUpdate")

    -- Register fishing detection events
    self:RegisterEvent("LOOT_OPENED", "OnLootOpened")
    self:RegisterEvent("LOOT_CLOSED", "OnLootClosed")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "OnSpellChannelStart")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "OnSpellChannelStop")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatStart")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd")
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "OnEquipmentChanged")

    -- Initialize Easy Cast system (double right-click to cast fishing)
    -- Called after event registration to ensure fishing detection works even if Easy Cast fails
    self:InitializeEasyCast()

    -- Create frame for periodic checking (Classic WoW compatible)
    -- Check every 2 seconds for fishing state and lure changes
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame.timeSinceLastUpdate = 0
    self.updateFrame.timeSinceLastBackupCheck = 0
    self.updateFrame:SetScript("OnUpdate", function(self, elapsed)
        self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
        self.timeSinceLastBackupCheck = self.timeSinceLastBackupCheck + elapsed

        if self.timeSinceLastUpdate >= 2 then
            CFC:CheckFishingState()
            CFC:CheckLureChanges()
            self.timeSinceLastUpdate = 0
        end

        -- Check backup/reminder needs every 60 seconds
        if self.timeSinceLastBackupCheck >= 60 then
            CFC:CheckBackupNeeded()
            self.timeSinceLastBackupCheck = 0
        end
    end)

    -- Initialize UI
    if CFC.InitializeUI then
        CFC:InitializeUI()
    end

    -- Initialize Minimap button
    if CFC.InitializeMinimap then
        CFC:InitializeMinimap()
    end

    -- Initialize HUD
    if CFC.InitializeHUD then
        CFC:InitializeHUD()
    end
end

-- Handle player entering world
function CFC:OnPlayerEntering()
    -- Update session start time
    self.db.profile.statistics.sessionStartTime = time()

    -- Update fishing skill
    self:UpdateFishingSkill()
end

-- Update fishing skill from character info
function CFC:UpdateFishingSkill()
    -- Get fishing skill (profession ID 356 for Fishing)
    local numSkills = GetNumSkillLines()
    for i = 1, numSkills do
        local skillName, _, _, skillLevel, _, _, skillMaxLevel = GetSkillLineInfo(i)
        if skillName and string.find(skillName, "Fishing") then
            local oldSkill = self.db.profile.statistics.currentSkill or 0
            self.db.profile.statistics.currentSkill = skillLevel
            self.db.profile.statistics.maxSkill = skillMaxLevel

            -- Track skill level up
            if oldSkill > 0 and skillLevel > oldSkill then
                table.insert(self.db.profile.skillLevels, {
                    timestamp = time(),
                    oldLevel = oldSkill,
                    newLevel = skillLevel,
                    date = date("%Y-%m-%d %H:%M:%S", time()),
                })
                if self.db.profile.settings.announceSkillUps then
                    print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " Fishing skill increased to " .. skillLevel .. "!")
                end

                -- Check if just hit max skill (300 in Classic)
                if skillLevel >= skillMaxLevel and oldSkill < skillMaxLevel then
                    self:AnnounceMaxSkill(skillLevel)
                end
            end
            break
        end
    end
end

-- Handle skill updates
function CFC:OnSkillUpdate()
    self:UpdateFishingSkill()
end

-- Check fishing state (called every second via OnUpdate - Classic WoW compatible)
function CFC:CheckFishingState()
    -- Check if player has fishing pole equipped
    local mainHandLink = GetInventoryItemLink("player", 16)
    if not mainHandLink then
        -- No fishing pole, clear fishing state
        if self.isFishing then
            self.isFishing = false
            self.currentTrackedPole = nil
            if self.debug then
                print("|cffff0000[CFC Debug]|r Fishing ended (no pole)")
            end
        end
        return
    end

    -- Check if it's a valid item (assume any item in slot 16 is a fishing pole)
    local itemName = GetItemInfo(mainHandLink)
    if not itemName then
        if self.isFishing then
            self.isFishing = false
            self.currentTrackedPole = nil
        end
        return
    end

    -- We have a fishing pole equipped
    local currentTime = time()

    -- Check if fishing cast timed out (30 seconds since last cast)
    if self.isFishing and currentTime - self.lastSpellTime > 30 then
        -- Cast timed out, reset for next cast
        self.isFishing = false
        self.currentTrackedPole = nil
        if self.debug then
            print("|cffff0000[CFC Debug]|r Fishing cast timed out - ready for next cast")
        end
    end

    -- Update fishing skill periodically
    if currentTime - self.lastSkillCheck > 30 then
        self:UpdateFishingSkill()
        self.lastSkillCheck = currentTime
    end

    -- Check for missing lure warning when we have pole equipped
    if self.db.profile.settings.announceLures then
        local warningInterval = self.db.profile.settings.lureWarningInterval or 30
        if currentTime - self.lastBuffWarningTime >= warningInterval then
            if not self:HasFishingBuff() then
                -- Only warn if in fishing gear mode (we already know pole is equipped since we're in CheckFishingState)
                local currentMode = self:GetCurrentGearMode()
                if currentMode == "fishing" then
                    RaidNotice_AddMessage(RaidWarningFrame, "No Fishing Lure!", ChatTypeInfo["RAID_WARNING"], 10)
                    self.lastBuffWarningTime = currentTime
                    if self.debug then
                        print("|cffff8800[CFC Debug]|r Warning: Fishing without lure!")
                    end
                end
            else
                -- Reset timer when lure is active to restart the countdown
                self.lastBuffWarningTime = currentTime
            end
        end
    end
end

-- Check for lure changes (called every 2 seconds)
function CFC:CheckLureChanges()
    -- Check if player has fishing pole equipped
    local mainHandLink = GetInventoryItemLink("player", 16)
    if not mainHandLink then
        self.currentTrackedBuff = nil
        self.currentBuffExpiration = 0
        return
    end

    -- Check weapon enchantment
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID = GetWeaponEnchantInfo()

    if hasMainHandEnchant then
        -- Convert expiration from milliseconds to seconds
        local expirationSeconds = math.floor(mainHandExpiration / 1000)

        -- First try to detect lure by enchant ID (locale-independent, most reliable)
        local lureName = CFC.CONSTANTS.LURE_ENCHANT_IDS[mainHandEnchantID]

        -- Fallback: Parse tooltip if enchant ID not in our mapping (handles unknown/future lures)
        if not lureName then
            CFC_ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            CFC_ScanTooltip:ClearLines()
            CFC_ScanTooltip:SetInventoryItem("player", CFC.CONSTANTS.SLOTS.MAIN_HAND)

            for i = 1, CFC_ScanTooltip:NumLines() do
                local line = _G["CFC_ScanTooltipTextLeft" .. i]
                if line then
                    local text = line:GetText()
                    -- Look for fishing-related text (works for English clients, fallback for unknown enchants)
                    if text and (string.find(text, "Lure") or string.find(text, "Increased Fishing") or string.find(text, "Fishing Skill")) then
                        -- Normalize lure name to consistent format "Fishing Lure +XX"
                        -- TBC format: "Fishing Lure (+75 Fishing Skill) (10 min)"
                        -- Classic Era format: "Fishing Lure +75"
                        local bonus = string.match(text, "%+(%d+)")
                        if bonus then
                            lureName = "Fishing Lure +" .. bonus
                        else
                            -- Fallback: just remove duration text
                            lureName = string.gsub(text, "%s*%(%d+%s*%w+%)%s*$", "")
                        end
                        break
                    end
                end
            end
            -- If still no name found, this is not a fishing lure - ignore it entirely
            -- (e.g., weapon enchants like sharpening stones should not be tracked)
        end

        if lureName then
            -- Detect lure application by checking:
            -- 1. Different lure than currently tracked, OR
            -- 2. Expiration time increased significantly (fresh lure application)
            --    Most lures last 10 minutes (600s), so require jump of at least 500s
            local isNewApplication = false

            if self.currentTrackedBuff ~= lureName then
                -- Different lure
                isNewApplication = true
                if self.debug then
                    print("|cffff8800[CFC Debug]|r Different lure: " .. tostring(self.currentTrackedBuff) .. " -> " .. lureName)
                end
            elseif expirationSeconds > self.currentBuffExpiration + 500 then
                -- Same lure but expiration time jumped significantly (fresh application)
                -- 500+ second increase indicates a new lure was applied
                isNewApplication = true
                if self.debug then
                    print("|cffff8800[CFC Debug]|r Same lure reapplied: " .. lureName .. " (" .. self.currentBuffExpiration .. "s -> " .. expirationSeconds .. "s)")
                end
            end

            if isNewApplication then
                -- Check if this is just the first detection after addon load/reload
                -- Don't count it if the addon just loaded - we're just detecting an existing lure
                if self.addonJustLoaded then
                    -- Just start tracking, don't increment count
                    self.currentTrackedBuff = lureName
                    self.currentBuffExpiration = expirationSeconds
                    self.addonJustLoaded = false  -- Clear the flag

                    if self.debug then
                        print("|cffff8800[CFC Debug]|r Detected existing lure after addon load: " .. lureName .. " (not counting)")
                    end
                else
                    -- This is a genuine new lure application, count it
                    -- Initialize tracking for this lure if needed
                    if not self.db.profile.buffUsage[lureName] then
                        self.db.profile.buffUsage[lureName] = {
                            name = lureName,
                            count = 0,
                            firstUsed = time(),
                            lastUsed = time(),
                        }
                    end

                    -- Increment count
                    self.db.profile.buffUsage[lureName].count = self.db.profile.buffUsage[lureName].count + 1
                    self.db.profile.buffUsage[lureName].lastUsed = time()
                    self.currentTrackedBuff = lureName
                    self.currentBuffExpiration = expirationSeconds

                    if self.debug then
                        print("|cffff8800[CFC Debug]|r NEW lure applied: " .. lureName .. " (Total: " .. self.db.profile.buffUsage[lureName].count .. ")")
                    end
                end
            else
                -- Just update the expiration time for tracking (time naturally decreases)
                self.currentBuffExpiration = expirationSeconds
            end
        end
    else
        -- No enchantment, reset tracked buff
        if self.currentTrackedBuff ~= nil then
            if self.debug then
                print("|cffff8800[CFC Debug]|r Lure expired or removed")
            end
            self.currentTrackedBuff = nil
            self.currentBuffExpiration = 0
        end

        -- Clear the "just loaded" flag if no lure is present
        -- This handles the case where player reloads without a lure active
        if self.addonJustLoaded then
            self.addonJustLoaded = false
            if self.debug then
                print("|cffff8800[CFC Debug]|r Addon loaded with no lure active - ready to track new lures")
            end
        end
    end
end

-- Check if backup or export reminder is needed (called every 60 seconds)
function CFC:CheckBackupNeeded()
    if not self.db or not self.db.profile or not self.db.profile.backup then
        return
    end

    -- Skip if backup is disabled
    if not self.db.profile.backup.enabled then
        return
    end

    -- Get current time
    local currentTime = time()

    -- Check if this is the first time (no backup exists)
    -- Treat nil lastBackupTime as 0 to ensure initial backup is created
    if not self.db.profile.backup.data or (self.db.profile.backup.lastBackupTime or 0) == 0 then
        -- Create initial backup immediately
        local success = self:CreateBackup()
        if success then
            print("|cff00ff00Classic Fishing Companion:|r Initial backup created")
        end
        return
    end

    -- Check if 24 hours (86400 seconds) have passed since last backup
    local timeSinceLastBackup = currentTime - (self.db.profile.backup.lastBackupTime or 0)
    if timeSinceLastBackup >= 86400 then  -- 24 hours = 86400 seconds
        -- Create automatic backup
        local success = self:CreateBackup()
        if success then
            print("|cff00ff00Classic Fishing Companion:|r Automatic backup created (24 hours elapsed)")
        end
    end

    -- Calculate total play time for export reminder
    local totalPlayTime = (self.db.profile.statistics.totalFishingTime or 0) + (time() - self.db.profile.statistics.sessionStartTime)

    -- Check if 7 days (604800 seconds) have passed since last export reminder
    local timeSinceLastReminder = totalPlayTime - (self.db.profile.backup.lastExportReminder or 0)
    if timeSinceLastReminder >= 604800 then  -- 7 days = 604800 seconds
        -- Show export reminder
        print("|cffffcc00Classic Fishing Companion:|r Reminder: Consider exporting your fishing data for backup!")
        print("|cffffcc00Tip:|r Open Settings and click 'Export Data' to save your data externally.")
        self.db.profile.backup.lastExportReminder = totalPlayTime
    end
end

-- Track fishing pole cast (called when Fishing spell is cast)
function CFC:TrackFishingPoleCast()
    -- Get the main hand item (fishing pole)
    local itemLink = GetInventoryItemLink("player", 16)

    if itemLink then
        local itemName = GetItemInfo(itemLink)

        if itemName then
            -- Initialize pole data if needed
            if not self.db.profile.poleUsage[itemName] then
                self.db.profile.poleUsage[itemName] = {
                    name = itemName,
                    count = 0,
                    firstUsed = time(),
                    lastUsed = time(),
                }
            end

            -- Only increment if this is a different pole from the currently tracked one
            -- currentTrackedPole is reset to nil when fishing ends, so each new cast is counted
            if self.currentTrackedPole ~= itemName then
                self.db.profile.poleUsage[itemName].count = self.db.profile.poleUsage[itemName].count + 1
                self.db.profile.poleUsage[itemName].lastUsed = time()
                self.currentTrackedPole = itemName
                self.lastPoleTrackTime = time()

                if self.debug then
                    print("|cffff8800[CFC Debug]|r Tracked fishing pole cast: " .. itemName .. " (Total: " .. self.db.profile.poleUsage[itemName].count .. ")")
                end
            else
                if self.debug then
                    print("|cffff8800[CFC Debug]|r Skipping duplicate pole cast (already tracked this cast)")
                end
            end

            return itemName
        end
    end

    return nil
end

-- Check if player currently has a fishing buff/lure active
function CFC:HasFishingBuff()
    -- Check weapon enchantment (lures applied to fishing pole)
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantId = GetWeaponEnchantInfo()

    if hasMainHandEnchant then
        -- Check if it's a fishing lure by scanning tooltip
        local tooltip = CreateFrame("GameTooltip", "CFCBuffCheckTooltip", nil, "GameTooltipTemplate")
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetInventoryItem("player", 16)

        for i = 1, tooltip:NumLines() do
            local line = _G["CFCBuffCheckTooltipTextLeft" .. i]
            if line then
                local text = line:GetText()
                -- Check both formats:
                -- TBC format: "Fishing Lure (+25 Fishing Skill) (10 min)"
                -- Classic Era format: "Fishing Lure +25"
                if text and (string.match(text, "Lure.*%(%+(%d+)") or string.match(text, "Fishing Lure %+(%d+)")) then
                    tooltip:Hide()
                    return true
                end
            end
        end

        tooltip:Hide()
    end

    -- Check for fishing-related buffs
    local fishingBuffs = {
        "lure", "aquadynamic", "bright baubles", "nightcrawlers",
        "shiny bauble", "flesh eating worm", "attractor", "bait"
    }

    for i = 1, 40 do
        local buffName = UnitBuff("player", i)
        if buffName then
            local buffLower = string.lower(buffName)
            for _, buffPattern in ipairs(fishingBuffs) do
                if string.find(buffLower, buffPattern) then
                    return true
                end
            end
        end
    end

    return false
end

-- Detect fishing pole buffs (lures, bobbers, etc.)

-- Handle loot window opening
function CFC:OnLootOpened()
    -- Check if we have a fishing pole equipped
    local mainHandLink = GetInventoryItemLink("player", 16)

    if self.debug then
        print("|cffff8800[CFC Debug]|r OnLootOpened called")
        print("|cffff8800[CFC Debug]|r  mainHandLink: " .. tostring(mainHandLink))
    end

    if mainHandLink then
        local itemName, _, _, _, _, itemType, itemSubType = GetItemInfo(mainHandLink)

        if self.debug then
            print("|cffff8800[CFC Debug]|r  itemName: " .. tostring(itemName))
            print("|cffff8800[CFC Debug]|r  itemType: " .. tostring(itemType))
            print("|cffff8800[CFC Debug]|r  itemSubType: " .. tostring(itemSubType))
        end

        -- Check if it's actually a fishing pole
        -- In Classic WoW, fishing poles have itemSubType "Fishing Poles"
        local isFishingPole = false
        if itemSubType then
            local subTypeLower = string.lower(itemSubType)
            isFishingPole = string.find(subTypeLower, "fishing") ~= nil
        end

        if self.debug then
            print("|cffff8800[CFC Debug]|r  isFishingPole: " .. tostring(isFishingPole))
        end

        -- Check if it's a fishing pole AND not looting a dead mob
        -- In Classic WoW, when looting a fishing bobber, you typically don't have a dead target
        -- When looting a mob, UnitIsDead("target") is true
        local hasDeadTarget = UnitExists("target") and UnitIsDead("target")

        if self.debug then
            print("|cffff8800[CFC Debug]|r  hasDeadTarget: " .. tostring(hasDeadTarget))
        end

        local recentlyCastFishing = (GetTime() - self.lastFishingCastTime) < 30

        if itemName and isFishingPole and not hasDeadTarget and recentlyCastFishing then
            -- We have fishing pole equipped, no dead target, and recently cast Fishing
            self.lastLootWasFishing = true
            self.isFishing = true
            self.lastSpellTime = time()

            -- Track the fishing pole cast
            self:TrackFishingPoleCast()

            if self.debug then
                print("|cffff8800[CFC Debug]|r Loot opened from fishing - tracking cast")
            end
            return
        elseif self.debug and itemName and not isFishingPole then
            print("|cffff8800[CFC Debug]|r Loot opened with non-fishing-pole equipped: " .. itemName)
        elseif self.debug and itemName and isFishingPole and hasDeadTarget then
            print("|cffff8800[CFC Debug]|r Loot opened with pole equipped but has dead target (combat loot)")
        elseif self.debug and itemName and isFishingPole and not recentlyCastFishing then
            print("|cffff8800[CFC Debug]|r Loot opened with pole equipped but no recent Fishing cast (ground loot?)")
        end
    end

    -- Not fishing
    self.lastLootWasFishing = false
    if self.debug then
        print("|cffff8800[CFC Debug]|r Loot opened but NOT fishing")
    end
end

-- Handle loot window closing
function CFC:OnLootClosed()
    -- Reset tracked pole so next cast will count
    self.currentTrackedPole = nil
    self.isFishing = false

    -- Mark loot closed time for Easy Cast (allows quick re-cast)
    self.easyCastLootClosedTime = GetTime()

    if self.debug then
        print("|cffff8800[CFC Debug]|r Loot closed - ready for next cast")
    end
end

-- Handle spell channel start (for detecting Fishing casts)
function CFC:OnSpellChannelStart(event, unit, _, spellID)
    if unit ~= "player" then return end

    -- Get spell name from ID
    local spellName = GetSpellInfo(spellID)

    if self.debug then
        print("|cffff8800[CFC Debug]|r OnSpellChannelStart: unit=" .. tostring(unit) .. " spellID=" .. tostring(spellID) .. " spellName=" .. tostring(spellName))
    end

    -- Check if it's the Fishing spell (works across locales by checking spell ID or name)
    -- Fishing spell ID is 7620 in Classic, but name check is more reliable
    if spellName and string.lower(spellName) == "fishing" then
        self.lastFishingCastTime = GetTime()
        self.isFishingChannelActive = true

        if self.debug then
            print("|cffff8800[CFC Debug]|r Fishing started - isFishingChannelActive = true")
        end
    end
end

-- Handle spell channel stop
function CFC:OnSpellChannelStop(event, unit, _, spellID)
    if unit ~= "player" then return end

    if self.debug then
        print("|cffff8800[CFC Debug]|r OnSpellChannelStop")
    end

    -- Mark fishing as no longer active
    self.isFishingChannelActive = false
end

-- Create the combat weapon swap button (must be created before combat)
function CFC:CreateCombatSwapButton()
    if self.combatSwapButton then
        return self.combatSwapButton
    end

    local btn = CreateFrame("Button", "CFCCombatSwapButton", UIParent, "SecureActionButtonTemplate,BackdropTemplate")
    btn:SetSize(220, 50)
    btn:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    btn:SetFrameStrata("DIALOG")
    btn:SetFrameLevel(100)
    btn:SetAttribute("type", "macro")
    btn:SetAttribute("macrotext", "")  -- Set by UpdateCombatSwapMacro
    btn:EnableMouse(true)
    btn:RegisterForClicks("AnyUp", "AnyDown")

    -- Visual styling
    btn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    btn:SetBackdropColor(0.8, 0.1, 0.1, 0.95)

    -- Text
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("CENTER", 0, 0)
    text:SetText("|cffFF0000COMBAT! Click to Swap|r")
    btn.text = text

    -- Highlight
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

    -- Track when clicked and hide button
    btn:SetScript("PostClick", function()
        if CFC.debug then
            print("|cff00ff00[CFC Debug]|r Combat swap button clicked!")
        end
        CFC.autoSwappedCombatWeapons = true
        -- Can't Hide() during combat, but can make invisible
        btn:SetAlpha(0)
    end)

    btn:Hide()
    self.combatSwapButton = btn

    if self.debug then
        print("|cff00ff00[CFC Debug]|r Combat swap button created")
    end

    return btn
end

-- Update the combat swap button macro with combat weapon names
-- MUST be called outside of combat (e.g., when entering fishing mode)
function CFC:UpdateCombatSwapMacro()
    if InCombatLockdown() then
        if self.debug then
            print("|cffff0000[CFC Debug]|r Cannot update combat swap macro during combat!")
        end
        return false
    end

    local btn = self:CreateCombatSwapButton()

    if not self.db or not self.db.profile.gearSets or not self.db.profile.gearSets.combat then
        if self.debug then
            print("|cffff0000[CFC Debug]|r No combat gear saved for swap macro")
        end
        return false
    end

    local combatGear = self.db.profile.gearSets.combat
    local macroLines = {"/stopcasting"}  -- Always stop fishing first

    -- Main hand (slot 16)
    if combatGear[16] then
        local itemName = string.match(combatGear[16], "%[(.-)%]")
        if itemName then
            table.insert(macroLines, "/equip " .. itemName)
            if self.debug then
                print("|cff00ff00[CFC Debug]|r Combat swap macro - Main hand: " .. itemName)
            end
        end
    end

    -- Off-hand (slot 17)
    if combatGear[17] then
        local itemName = string.match(combatGear[17], "%[(.-)%]")
        if itemName then
            table.insert(macroLines, "/equipslot 17 " .. itemName)
            if self.debug then
                print("|cff00ff00[CFC Debug]|r Combat swap macro - Off-hand: " .. itemName)
            end
        end
    end

    local macroText = table.concat(macroLines, "\n")
    btn:SetAttribute("macrotext", macroText)

    if self.debug then
        print("|cff00ff00[CFC Debug]|r Combat swap macro updated:")
        print(macroText)
    end

    return true
end

-- Show the combat swap button
function CFC:ShowCombatSwapButton()
    if self.combatSwapButton then
        self.combatSwapButton:SetAlpha(1)  -- Reset alpha in case it was hidden
        self.combatSwapButton:Show()
        if self.debug then
            print("|cff00ff00[CFC Debug]|r Combat swap button shown")
        end
    end
end

-- Handle entering combat
function CFC:OnCombatStart()
    self.lastFishingCastTime = 0

    if self.debug then
        print("|cffff8800[CFC Debug]|r === OnCombatStart ===")
        print("|cffff8800[CFC Debug]|r   currentMode = " .. tostring(self.db and self.db.profile.gearSets and self.db.profile.gearSets.currentMode))
        print("|cffff8800[CFC Debug]|r   isFishingChannelActive = " .. tostring(self.isFishingChannelActive))
    end

    -- Auto-swap to combat weapons if enabled and in fishing mode
    if self.db and self.db.profile.settings.autoSwapCombatWeapons then
        local currentMode = self.db.profile.gearSets and self.db.profile.gearSets.currentMode
        if currentMode == "fishing" then
            if self.isFishingChannelActive then
                -- Currently fishing - show button to stop cast and swap
                self:ShowCombatSwapButton()
                if self.debug then
                    print("|cffff8800[CFC Debug]|r Currently fishing - showing swap button")
                end
            else
                -- Not fishing - try to swap immediately (before combat lockdown kicks in)
                if self:SwapWeaponsOnly("combat") then
                    self.autoSwappedCombatWeapons = true
                    print("|cff00ff00Classic Fishing Companion:|r Swapped to combat weapons!")
                else
                    -- Swap failed, show button as fallback
                    self:ShowCombatSwapButton()
                end
                if self.debug then
                    print("|cffff8800[CFC Debug]|r Not fishing - attempted immediate swap")
                end
            end
        end
    end
end

-- Create secure button for combat stop casting (hidden, used for override binding)
function CFC:CreateCombatStopButton()
    if not self.combatStopButton then
        local btn = CreateFrame("Button", "CFCCombatStopButton", UIParent, "SecureActionButtonTemplate")
        btn:SetSize(1, 1)
        btn:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        btn:SetAttribute("type", "macro")
        btn:SetAttribute("macrotext", "/stopcasting")
        btn:Hide()
        self.combatStopButton = btn
    end
    return self.combatStopButton
end

-- Set up override binding to stop casting on next left-click (used to attack)
function CFC:SetupCombatStopBinding()
    local btn = self:CreateCombatStopButton()

    -- Set override binding - next left-click will stop casting
    -- Using BUTTON1 (left-click) since you'll left-click to attack anyway
    SetOverrideBindingClick(btn, true, "BUTTON1", "CFCCombatStopButton")
    self.combatStopBindingActive = true

    if self.debug then
        print("|cffff8800[CFC Debug]|r Combat stop binding set - next left-click will stop fishing")
    end
end

-- Clear the combat stop binding
function CFC:ClearCombatStopBinding()
    if self.combatStopButton and self.combatStopBindingActive then
        ClearOverrideBindings(self.combatStopButton)
        self.combatStopBindingActive = false

        if self.debug then
            print("|cffff8800[CFC Debug]|r Combat stop binding cleared")
        end
    end
end

-- Handle leaving combat (clear any Easy Cast bindings that might be stuck)
function CFC:OnCombatEnd()
    -- Clear any Easy Cast bindings that might have been stuck during combat
    self:ClearEasyCastBinding()
    if self.debug then
        print("|cffff8800[CFC Debug]|r Combat ended")
    end

    -- Hide the combat swap button (safe to do outside combat)
    if self.combatSwapButton then
        self.combatSwapButton:Hide()
    end

    -- Auto-swap back to fishing weapons if we swapped to combat weapons
    if self.autoSwappedCombatWeapons then
        if self.debug then
            print("|cffff8800[CFC Debug]|r Auto-swapping back to fishing weapons...")
        end
        if self:SwapWeaponsOnly("fishing") then
            print("|cff00ff00Classic Fishing Companion:|r Combat ended - swapped back to fishing pole!")
        end
        self.autoSwappedCombatWeapons = false
    end
end

-- Handle equipment changes (detect manual weapon swaps to keep currentMode in sync)
function CFC:OnEquipmentChanged(event, slot)
    -- Only care about main hand slot (16)
    if slot ~= 16 then return end

    -- Don't process if gear sets aren't configured
    if not self.db or not self.db.profile or not self.db.profile.gearSets then return end

    -- Check what's now in the main hand
    local mainHandLink = GetInventoryItemLink("player", 16)
    local isFishingPole = false

    if mainHandLink then
        local _, _, _, _, _, _, itemSubType = GetItemInfo(mainHandLink)
        if itemSubType then
            isFishingPole = string.find(string.lower(itemSubType), "fishing") ~= nil
        end
    end

    local currentMode = self.db.profile.gearSets.currentMode or "combat"

    -- Update mode if it's out of sync
    if isFishingPole and currentMode ~= "fishing" then
        self.db.profile.gearSets.currentMode = "fishing"
        if self.debug then
            print("|cffff8800[CFC Debug]|r Detected fishing pole equipped - mode set to 'fishing'")
        end
        -- Prepare combat swap button macro
        if self.db.profile.settings.autoSwapCombatWeapons then
            self:UpdateCombatSwapMacro()
        end
    elseif not isFishingPole and currentMode == "fishing" then
        self.db.profile.gearSets.currentMode = "combat"
        if self.debug then
            print("|cffff8800[CFC Debug]|r Detected non-fishing weapon equipped - mode set to 'combat'")
        end
    end
end

-- Handle logout
function CFC:OnLogout()
    -- Save session data
    local sessionTime = time() - self.db.profile.statistics.sessionStartTime
    self.db.profile.statistics.totalFishingTime = self.db.profile.statistics.totalFishingTime + sessionTime
end

-- Check if item is a fishing lure or buff item (should not be tracked as a catch)
function CFC:IsFishingLure(itemName)
    if not itemName then return false end

    local nameLower = string.lower(itemName)

    -- List of specific fishing lures and buff items that should NOT be tracked as catches
    -- Using exact matches or very specific patterns to avoid false positives
    local lureNames = {
        "aquadynamic fish attractor",
        "bright baubles",
        "nightcrawlers",
        "shiny bauble",
        "flesh eating worm",
    }

    -- Check for exact matches
    for _, lureName in ipairs(lureNames) do
        if nameLower == lureName then
            return true
        end
    end

    -- Only check for "lure" keyword if it appears with "fishing"
    if string.find(nameLower, "fishing") and string.find(nameLower, "lure") then
        return true
    end

    return false
end

-- Parse loot message to detect items caught while fishing
function CFC:OnLootReceived(event, message)
    -- Debug: Print all loot messages
    if self.debug then
        print("|cffff8800[CFC Debug]|r LOOT: " .. tostring(message))
    end

    -- Only process "You receive loot:" messages, NOT "You create:" (from cooking/crafting)
    if not string.find(message, "You receive loot:") then
        if self.debug then
            print("|cffff8800[CFC Debug]|r Skipping non-loot message (probably crafting/cooking)")
        end
        return
    end

    -- Pattern for loot: "You receive loot: [Item Name]."
    -- Extract full item link
    local itemLink = string.match(message, "(|c%x+|Hitem:.-|h%[.-%]|h|r)")
    local itemName = string.match(message, "|c%x+|Hitem:.-|h%[(.-)%]|h|r")

    if not itemLink or not itemName then
        return
    end

    -- Skip fishing lures and bait items
    if self:IsFishingLure(itemName) then
        if self.debug then
            print("|cffff8800[CFC Debug]|r Skipping fishing lure: " .. itemName)
        end
        return
    end

    -- Check if this loot was obtained while fishing
    -- Primary: LOOT_OPENED event confirmed this was fishing loot
    -- Fallback: Check fishing conditions directly (for compatibility with fast auto-loot addons)
    local wasFishing = self.lastLootWasFishing

    -- Fallback detection if LOOT_OPENED didn't fire (e.g., SpeedyAutoLoot)
    if not wasFishing then
        local mainHandLink = GetInventoryItemLink("player", 16)
        if mainHandLink then
            local _, _, _, _, _, _, itemSubType = GetItemInfo(mainHandLink)
            if itemSubType then
                local isFishingPole = string.find(string.lower(itemSubType), "fishing") ~= nil
                local hasDeadTarget = UnitExists("target") and UnitIsDead("target")
                -- Check if player recently cast Fishing (within 30 seconds - bobber lasts ~20-25 sec)
                local recentlyCastFishing = (GetTime() - self.lastFishingCastTime) < 30
                if isFishingPole and not hasDeadTarget and recentlyCastFishing then
                    wasFishing = true
                    -- Track the fishing pole cast (since OnLootOpened didn't fire)
                    self:TrackFishingPoleCast()
                    if self.debug then
                        print("|cffff8800[CFC Debug]|r Fallback fishing detection: pole equipped, no dead target, recently cast Fishing")
                    end
                elseif isFishingPole and not hasDeadTarget and self.debug then
                    print("|cffff8800[CFC Debug]|r Fallback detection SKIPPED: pole equipped but no recent Fishing cast (mob loot?)")
                end
            end
        end
    end

    -- Debug output
    if self.debug then
        print("|cffff8800[CFC Debug]|r Found item: " .. itemName)
        print("|cffff8800[CFC Debug]|r Was fishing: " .. tostring(wasFishing))
        print("|cffff8800[CFC Debug]|r lastLootWasFishing: " .. tostring(self.lastLootWasFishing))
    end

    if wasFishing then
        if self.debug then
            print("|cffff8800[CFC Debug]|r Recording catch from fishing")
            print("|cffff8800[CFC Debug]|r Item link: " .. tostring(itemLink))
        end
        self:RecordFishCatch(itemName, itemLink)
    else
        if self.debug then
            print("|cffff8800[CFC Debug]|r Skipping - not from fishing")
        end
    end
end

-- Record a fish catch
-- Items to never track as catches
local ignoredCatches = { "glowcap", "nutriment" }

function CFC:RecordFishCatch(itemName, itemLink)
    -- Skip ignored items entirely
    local nameLower = string.lower(itemName)
    for _, keyword in ipairs(ignoredCatches) do
        if string.find(nameLower, keyword) then
            if self.debug then
                print("|cffff8800[CFC Debug]|r Skipping ignored item: " .. itemName)
            end
            return
        end
    end

    local timestamp = time()
    local zone = GetRealZoneText() or "Unknown"
    local subzone = GetSubZoneText() or ""
    local position = self:GetPlayerPosition()

    -- Create catch record
    local catch = {
        itemName = itemName,
        timestamp = timestamp,
        zone = zone,
        subzone = subzone,
        x = position.x,
        y = position.y,
        date = date("%Y-%m-%d %H:%M:%S", timestamp),
    }

    -- Add to catches table
    table.insert(self.db.profile.catches, catch)

    -- Update statistics
    self.db.profile.statistics.totalCatches = self.db.profile.statistics.totalCatches + 1
    self.db.profile.statistics.sessionCatches = self.db.profile.statistics.sessionCatches + 1

    -- Check for rare fish and play sound
    if self.db.profile.settings.rareFishSound and itemLink then
        local itemID = tonumber(itemLink:match("item:(%d+)"))
        if itemID and CFC.CONSTANTS.RARE_FISH[itemID] then
            PlaySound(CFC.CONSTANTS.RARE_FISH_SOUND, "Master")
            if self.debug then
                print("|cffff8800[CFC Debug]|r Rare fish caught! Playing sound for: " .. CFC.CONSTANTS.RARE_FISH[itemID])
            end
        end
    end

    -- Update fish-specific data
    if not self.db.profile.fishData[itemName] then
        -- Get item info when first catching this item
        -- Use itemLink if available (more reliable), otherwise fall back to itemName
        local itemTexture = nil
        local itemType = nil
        local itemSubType = nil

        if itemLink then
            local _, _, _, _, _, iType, iSubType, _, _, texture = GetItemInfo(itemLink)
            itemTexture = texture
            itemType = iType
            itemSubType = iSubType
            if self.debug and texture then
                print("|cffff8800[CFC Debug]|r Got icon from itemLink: " .. tostring(texture))
                print("|cffff8800[CFC Debug]|r itemType: " .. tostring(itemType) .. ", itemSubType: " .. tostring(itemSubType))
            end
        end

        -- Fallback to itemName if itemLink didn't work
        if not itemTexture then
            local _, _, _, _, _, iType, iSubType, _, _, texture = GetItemInfo(itemName)
            itemTexture = texture
            itemType = iType
            itemSubType = iSubType
            if self.debug and texture then
                print("|cffff8800[CFC Debug]|r Got icon from itemName: " .. tostring(texture))
                print("|cffff8800[CFC Debug]|r itemType: " .. tostring(itemType) .. ", itemSubType: " .. tostring(itemSubType))
            end
        end

        self.db.profile.fishData[itemName] = {
            count = 0,
            firstCatch = timestamp,
            lastCatch = timestamp,
            locations = {},
            icon = itemTexture,  -- Cache the icon texture (may be nil if item not cached yet)
            itemType = itemType,  -- Cache item type for categorization
            itemSubType = itemSubType,  -- Cache item subtype for categorization
        }

        if self.debug then
            print("|cffff8800[CFC Debug]|r Created fishData for: " .. itemName .. ", icon: " .. tostring(itemTexture))
        end
    end

    local fishData = self.db.profile.fishData[itemName]
    fishData.count = fishData.count + 1
    fishData.lastCatch = timestamp

    -- Update cached icon and item type info if we don't have them yet
    if (not fishData.icon or not fishData.itemType) and itemLink then
        local _, _, _, _, _, iType, iSubType, _, _, itemTexture = GetItemInfo(itemLink)
        if itemTexture and not fishData.icon then
            fishData.icon = itemTexture
            if self.debug then
                print("|cffff8800[CFC Debug]|r Updated icon for " .. itemName .. ": " .. tostring(itemTexture))
            end
        end
        if iType and not fishData.itemType then
            fishData.itemType = iType
            fishData.itemSubType = iSubType
            if self.debug then
                print("|cffff8800[CFC Debug]|r Updated itemType for " .. itemName .. ": " .. tostring(iType) .. ", " .. tostring(iSubType))
            end
        end
    end

    -- Add location if not already recorded
    local locationKey = zone .. ":" .. subzone
    if not fishData.locations[locationKey] then
        fishData.locations[locationKey] = {
            zone = zone,
            subzone = subzone,
            count = 0,
        }
    end
    fishData.locations[locationKey].count = fishData.locations[locationKey].count + 1

    -- Print notification if setting is enabled
    if self.db.profile.settings.announceCatches then
        print("|cff00ff00Classic Fishing Companion Announcements:|r Caught " .. itemName .. " in " .. zone)
    end

    -- Check for milestone notifications
    self:CheckMilestone(self.db.profile.statistics.totalCatches)

    -- Check goal progress
    self:CheckGoalProgress(itemName)

    -- Check catch and release
    self:CheckCatchAndRelease(itemName)

    -- Update UI if open
    if CFC.UpdateUI then
        CFC:UpdateUI()
    end

    -- Update HUD
    if CFC.HUD and CFC.HUD.Update then
        CFC.HUD:Update()
    end
end

-- Get player position
function CFC:GetPlayerPosition()
    local y, x = UnitPosition("player")
    return { x = x or 0, y = y or 0 }
end

-- Calculate fish per hour
function CFC:GetFishPerHour()
    local sessionTime = time() - self.db.profile.statistics.sessionStartTime

    if sessionTime <= 0 then
        return 0
    end

    local hours = sessionTime / 3600
    return self.db.profile.statistics.sessionCatches / hours
end

-- Get total fishing time in hours
function CFC:GetTotalFishingTime()
    local sessionTime = time() - self.db.profile.statistics.sessionStartTime
    local totalSeconds = self.db.profile.statistics.totalFishingTime + sessionTime
    return totalSeconds / 3600
end

-- Get item name with quality color
function CFC:GetColoredItemName(itemName)
    if not itemName then return "Unknown" end

    -- Try to get item info
    local _, _, quality = GetItemInfo(itemName)

    -- Default to common (white) if quality not found
    quality = quality or 1

    local colorCode = CFC.COLORS.QUALITY[quality] or CFC.COLORS.QUALITY[1]
    return colorCode .. itemName .. CFC.COLORS.RESET
end

-- Announce max fishing skill to chosen channel
function CFC:AnnounceMaxSkill(skillLevel)
    local enabled = self.db.profile.settings.maxSkillAnnounceEnabled
    local channel = self.db.profile.settings.maxSkillAnnounce

    -- Always show local notification
    print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " " .. CFC.COLORS.TIP .. "Congratulations! You've reached maximum fishing skill (" .. skillLevel .. ")!" .. CFC.COLORS.RESET)
    RaidNotice_AddMessage(RaidWarningFrame, "MAX FISHING SKILL REACHED!", ChatTypeInfo["RAID_WARNING"], 5)
    PlaySound(SOUNDKIT.UI_PLAYER_LEVEL_UP or 888)

    -- Send to chat channel if enabled
    if enabled and channel then
        local playerName = UnitName("player")
        local message = "[Classic Fishing Companion]: " .. playerName .. " has reached Fishing skill (" .. skillLevel .. ")!"

        if channel == "SAY" then
            SendChatMessage(message, "SAY")
        elseif channel == "PARTY" then
            if IsInGroup() then
                SendChatMessage(message, "PARTY")
            end
        elseif channel == "GUILD" then
            if IsInGuild() then
                SendChatMessage(message, "GUILD")
            end
        elseif channel == "EMOTE" then
            SendChatMessage("has reached maximum Fishing skill (" .. skillLevel .. ") using [Classic Fishing Companion]!", "EMOTE")
        end
    end
end

-- Check if a catch count hits a milestone and notify
function CFC:CheckMilestone(catchCount)
    for _, milestone in ipairs(CFC.CONSTANTS.MILESTONES) do
        if catchCount == milestone then
            local enabled = self.db.profile.settings.milestonesAnnounceEnabled
            local channel = self.db.profile.settings.milestonesAnnounce

            -- Show milestone notification
            local message = "Milestone reached: " .. milestone .. " fish caught!"
            print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " " .. CFC.COLORS.TIP .. message .. CFC.COLORS.RESET)

            -- Show raid warning style notification
            RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"], 5)

            -- Play a sound (level up fanfare)
            PlaySound(888)

            -- Send to chat channel if enabled
            if enabled and channel then
                local playerName = UnitName("player")
                local chatMessage = "[Classic Fishing Companion]: " .. playerName .. " has caught " .. milestone .. " fish!"

                if channel == "SAY" then
                    SendChatMessage(chatMessage, "SAY")
                elseif channel == "PARTY" then
                    if IsInGroup() then
                        SendChatMessage(chatMessage, "PARTY")
                    end
                elseif channel == "GUILD" then
                    if IsInGuild() then
                        SendChatMessage(chatMessage, "GUILD")
                    end
                elseif channel == "EMOTE" then
                    SendChatMessage("has caught " .. milestone .. " fish using [Classic Fishing Companion]!", "EMOTE")
                end
            end

            return true
        end
    end
    return false
end

-- Check if a catch contributes to active goals
function CFC:CheckGoalProgress(fishName)
    if not self.db.profile.goals then return end

    for _, goal in ipairs(self.db.profile.goals) do
        if goal.fishName == fishName then
            goal.sessionCatches = (goal.sessionCatches or 0) + 1

            if goal.sessionCatches == goal.targetCount then
                local message = "Goal completed: " .. goal.targetCount .. " " .. fishName .. "!"
                print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " " .. CFC.COLORS.TIP .. message .. CFC.COLORS.RESET)
                RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"], 5)
                PlaySound(888)
            end

            break
        end
    end
end

-- Auto-delete fish on the release list
-- Catch and Release: track pending fish for keybind deletion
CFC.pendingRelease = nil

function CFC:CheckCatchAndRelease(fishName)
    if not self.db.profile.releaseList or not self.db.profile.releaseList[fishName] then return end

    -- Store for keybind pickup+delete
    self.pendingRelease = fishName

    -- Notify the user
    print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " Caught " .. fishName .. " (on release list) - press your |cffffff00Release Fish|r keybind to delete it.")
end

-- Called by the keybind (hardware event) - picks up and deletes the fish
function CFC:ReleaseFishKeybind()
    local fishName = self.pendingRelease
    if not fishName then
        print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " No fish pending release.")
        return
    end

    local GetNumSlots, GetItemLink, PickupItem

    if C_Container and type(C_Container.GetContainerNumSlots) == "function" then
        GetNumSlots = C_Container.GetContainerNumSlots
        GetItemLink = C_Container.GetContainerItemLink
        PickupItem = C_Container.PickupContainerItem
    elseif _G.GetContainerNumSlots then
        GetNumSlots = _G.GetContainerNumSlots
        GetItemLink = _G.GetContainerItemLink
        PickupItem = _G.PickupContainerItem
    else
        return
    end

    for bag = 0, 4 do
        local numSlots = GetNumSlots(bag)
        for slot = 1, numSlots do
            local link = GetItemLink(bag, slot)
            if link then
                local name = GetItemInfo(link)
                if name == fishName then
                    ClearCursor()
                    PickupItem(bag, slot)
                    DeleteCursorItem()
                    print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " Released: " .. fishName)
                    self.pendingRelease = nil
                    return
                end
            end
        end
    end

    -- Fish not found (maybe already deleted or used)
    print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " " .. fishName .. " not found in bags.")
    self.pendingRelease = nil
end

-- ========================================
-- GEAR SWAP SYSTEM
-- ========================================

-- Equipment slot IDs
local GEAR_SLOTS = {
    HEADSLOT = 1,
    NECKSLOT = 2,
    SHOULDERSLOT = 3,
    SHIRTSLOT = 4,
    CHESTSLOT = 5,
    WAISTSLOT = 6,
    LEGSSLOT = 7,
    FEETSLOT = 8,
    WRISTSLOT = 9,
    HANDSSLOT = 10,
    FINGER0SLOT = 11,
    FINGER1SLOT = 12,
    TRINKET0SLOT = 13,
    TRINKET1SLOT = 14,
    BACKSLOT = 15,
    MAINHANDSLOT = 16,
    SECONDARYHANDSLOT = 17,
    TABARDSLOT = 19,
}

-- Helper function to count table entries
function CFC:CountTableEntries(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Save current equipment to a gear set
function CFC:SaveGearSet(setName)
    if not self.db or not self.db.profile then
        if self.debug then
            print("|cffff0000[CFC Debug]|r SaveGearSet failed: No database")
        end
        return false
    end

    if not self.db.profile.gearSets then
        self.db.profile.gearSets = {
            fishing = {},
            combat = {},
            currentMode = "combat",
        }
        if self.debug then
            print("|cffff8800[CFC Debug]|r Initialized gearSets database")
        end
    end

    local gearSet = {}
    local itemCount = 0

    if self.debug then
        print("|cffff8800[CFC Debug]|r === Saving " .. setName .. " gear set ===")
    end

    -- Save each equipment slot
    for slotName, slotID in pairs(GEAR_SLOTS) do
        local itemLink = GetInventoryItemLink("player", slotID)
        if itemLink then
            gearSet[slotID] = itemLink
            itemCount = itemCount + 1
            if self.debug then
                local itemName = string.match(itemLink, "%[(.-)%]") or "Unknown"
                print("|cffff8800[CFC Debug]|r   Slot " .. slotID .. " (" .. slotName .. "): " .. itemName)
            end
        end
    end

    self.db.profile.gearSets[setName] = gearSet

    if self.debug then
        print("|cffff8800[CFC Debug]|r Saved " .. itemCount .. " items to " .. setName .. " gear set")
    end

    -- Check if both gear sets are identical
    local otherSet = (setName == "fishing") and "combat" or "fishing"
    if self.db.profile.gearSets[otherSet] and next(self.db.profile.gearSets[otherSet]) then
        local matchingItems = 0
        local totalItems = 0

        for slotID, itemLink in pairs(gearSet) do
            totalItems = totalItems + 1
            local otherItemLink = self.db.profile.gearSets[otherSet][slotID]
            if otherItemLink then
                local itemID = tonumber(string.match(itemLink, "item:(%d+)"))
                local otherItemID = tonumber(string.match(otherItemLink, "item:(%d+)"))
                if itemID == otherItemID then
                    matchingItems = matchingItems + 1
                end
            end
        end

        -- If all items match exactly, warn the user
        if totalItems > 0 and matchingItems == totalItems then
            print("|cffffcc00Classic Fishing Companion:|r |cffff8800WARNING:|r Your fishing and combat gear are identical!")
            print("|cffffcc00Tip:|r Equip different gear for each set to make swapping useful.")
        end
    end

    return true
end

-- Load and equip a gear set
function CFC:LoadGearSet(setName)
    if self.debug then
        print("|cffff8800[CFC Debug]|r === Loading " .. setName .. " gear set ===")
    end

    if not self.db or not self.db.profile or not self.db.profile.gearSets then
        print("|cffff0000Classic Fishing Companion:|r No gear sets saved yet!")
        if self.debug then
            print("|cffff0000[CFC Debug]|r Database not initialized")
        end
        return false
    end

    local gearSet = self.db.profile.gearSets[setName]
    if not gearSet or not next(gearSet) then
        print("|cffff0000Classic Fishing Companion:|r No " .. setName .. " gear set saved. Equip your gear and use /cfc save" .. setName .. " first!")
        if self.debug then
            print("|cffff0000[CFC Debug]|r Gear set '" .. setName .. "' is empty or doesn't exist")
        end
        return false
    end

    -- Check if in combat
    if InCombatLockdown() then
        print("|cffff0000Classic Fishing Companion:|r Cannot swap gear while in combat!")
        if self.debug then
            print("|cffff0000[CFC Debug]|r Combat lockdown active")
        end
        return false
    end

    if self.debug then
        print("|cffff8800[CFC Debug]|r Found " .. self:CountTableEntries(gearSet) .. " items in " .. setName .. " gear set")
    end

    local swappedCount = 0
    local notFoundCount = 0
    local alreadyEquippedCount = 0

    -- Track used bag slots to handle duplicate items (e.g., two identical one-handed weapons)
    local usedBagSlots = {}

    -- Define slot processing order - main hand before off-hand to handle dual-wield properly
    local slotOrder = {
        16, -- MAINHANDSLOT - process first for dual-wield
        17, -- SECONDARYHANDSLOT - process second
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 19  -- Other slots
    }

    -- Equip each item from the set in defined order
    for _, slotID in ipairs(slotOrder) do
        local itemLink = gearSet[slotID]
        if itemLink then
            -- Check if this item is already equipped in the correct slot
            local currentItemLink = GetInventoryItemLink("player", slotID)
            local targetItemID = tonumber(string.match(itemLink, "item:(%d+)"))
            local currentItemID = currentItemLink and tonumber(string.match(currentItemLink, "item:(%d+)"))

            if currentItemID == targetItemID then
                -- Item is already equipped in the correct slot, skip it
                alreadyEquippedCount = alreadyEquippedCount + 1
            else
                -- Need to equip this item
                local itemID = targetItemID
                if itemID then
                    local itemName = string.match(itemLink, "%[(.-)%]") or "Unknown"
                    local bag, slot = self:FindItemInBags(itemID, usedBagSlots)

                    if bag and slot then
                        -- Mark this bag slot as used so we don't pick the same item twice
                        usedBagSlots[bag .. ":" .. slot] = true

                        if self.debug then
                            print("|cff00ff00[CFC Debug]|r   Equipping " .. itemName .. " (slot " .. slotID .. ") from bag " .. bag .. ", slot " .. slot)
                        end
                        ClearCursor()  -- Make sure cursor is clear before pickup

                        -- Use C_Container API if available (Classic Anniversary), otherwise use old API
                        if C_Container and C_Container.PickupContainerItem then
                            C_Container.PickupContainerItem(bag, slot)
                            if self.debug then
                                print("|cffff8800[CFC Debug]|r   Using C_Container.PickupContainerItem")
                            end
                        else
                            PickupContainerItem(bag, slot)
                            if self.debug then
                                print("|cffff8800[CFC Debug]|r   Using legacy PickupContainerItem")
                            end
                        end

                        -- Validate that item was picked up
                        local cursorType = GetCursorInfo()
                        if cursorType ~= "item" then
                            print("|cffffff00Classic Fishing Companion:|r Could not pick up " .. itemName .. " - item may be locked")
                            ClearCursor()
                            notFoundCount = notFoundCount + 1
                            -- Remove from used slots since we didn't actually use it
                            usedBagSlots[bag .. ":" .. slot] = nil
                        else
                            PickupInventoryItem(slotID)
                            ClearCursor()  -- Clear cursor after swap
                            swappedCount = swappedCount + 1
                        end
                    else
                        notFoundCount = notFoundCount + 1
                        print("|cffffff00Classic Fishing Companion:|r Could not find " .. itemName .. " in your bags")
                        if self.debug then
                            print("|cffff0000[CFC Debug]|r   Item not in bags: " .. itemName .. " (ID: " .. itemID .. ")")
                        end
                    end
                else
                    if self.debug then
                        print("|cffff0000[CFC Debug]|r   Could not extract item ID from: " .. itemLink)
                    end
                end
            end
        end
    end

    self.db.profile.gearSets.currentMode = setName

    -- If entering fishing mode, prepare the combat swap button macro
    if setName == "fishing" and self.db.profile.settings.autoSwapCombatWeapons then
        self:UpdateCombatSwapMacro()
    end

    if self.debug then
        print("|cffff8800[CFC Debug]|r Gear swap complete: " .. swappedCount .. " equipped, " .. alreadyEquippedCount .. " already equipped, " .. notFoundCount .. " not found")
    end

    return true
end

-- Swap only weapons (main hand and off-hand) to a gear set
-- This can be done during combat since weapons are swappable in combat
function CFC:SwapWeaponsOnly(setName)
    if self.debug then
        print("|cffff8800[CFC Debug]|r === Swapping weapons to " .. setName .. " set ===")
    end

    if not self.db or not self.db.profile or not self.db.profile.gearSets then
        if self.debug then
            print("|cffff0000[CFC Debug]|r No gear sets configured")
        end
        return false
    end

    local gearSet = self.db.profile.gearSets[setName]
    if not gearSet then
        if self.debug then
            print("|cffff0000[CFC Debug]|r Gear set '" .. setName .. "' not found")
        end
        return false
    end

    local swappedCount = 0
    local usedBagSlots = {}

    -- Only swap weapon slots (16 = main hand, 17 = off-hand)
    -- Process main hand first for dual-wield handling
    local weaponSlots = {16, 17}

    for _, slotID in ipairs(weaponSlots) do
        local itemLink = gearSet[slotID]
        if itemLink then
            local currentItemLink = GetInventoryItemLink("player", slotID)
            local targetItemID = tonumber(string.match(itemLink, "item:(%d+)"))
            local currentItemID = currentItemLink and tonumber(string.match(currentItemLink, "item:(%d+)"))

            if currentItemID ~= targetItemID then
                local itemName = string.match(itemLink, "%[(.-)%]") or "Unknown"
                local bag, slot = self:FindItemInBags(targetItemID, usedBagSlots)

                if bag and slot then
                    usedBagSlots[bag .. ":" .. slot] = true

                    if self.debug then
                        print("|cff00ff00[CFC Debug]|r   Equipping weapon: " .. itemName .. " to slot " .. slotID)
                    end

                    ClearCursor()
                    if C_Container and C_Container.PickupContainerItem then
                        C_Container.PickupContainerItem(bag, slot)
                    else
                        PickupContainerItem(bag, slot)
                    end

                    local cursorType = GetCursorInfo()
                    if cursorType == "item" then
                        PickupInventoryItem(slotID)
                        ClearCursor()
                        swappedCount = swappedCount + 1
                    else
                        ClearCursor()
                        usedBagSlots[bag .. ":" .. slot] = nil
                    end
                else
                    if self.debug then
                        print("|cffff0000[CFC Debug]|r   Weapon not in bags: " .. itemName)
                    end
                end
            else
                if self.debug then
                    local itemName = string.match(itemLink, "%[(.-)%]") or "Unknown"
                    print("|cff00ff00[CFC Debug]|r   Weapon already equipped: " .. itemName)
                end
            end
        end
    end

    if self.debug then
        print("|cffff8800[CFC Debug]|r Weapon swap complete: " .. swappedCount .. " weapons swapped")
    end

    return swappedCount > 0
end

-- Find item in bags by item ID
-- Optional usedBagSlots table to skip already-used slots (for handling duplicate items like dual-wield)
function CFC:FindItemInBags(itemID, usedBagSlots)
    if self.debug then
        print("|cffff8800[CFC Debug]|r Searching bags for item ID: " .. itemID)
    end

    usedBagSlots = usedBagSlots or {}

    -- Determine which bag API to use with explicit checks
    local GetNumSlots, GetItemID

    -- Try C_Container API first (Classic Anniversary / Retail)
    if C_Container and type(C_Container.GetContainerNumSlots) == "function" then
        GetNumSlots = function(bag) return C_Container.GetContainerNumSlots(bag) end
        GetItemID = function(bag, slot)
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            return itemInfo and itemInfo.itemID
        end
        if self.debug then
            print("|cffff8800[CFC Debug]|r Using C_Container API (Classic Anniversary)")
        end
    -- Fallback to old global API (Classic Era)
    elseif _G.GetContainerNumSlots and type(_G.GetContainerNumSlots) == "function" then
        GetNumSlots = _G.GetContainerNumSlots
        GetItemID = _G.GetContainerItemID
        if self.debug then
            print("|cffff8800[CFC Debug]|r Using legacy bag API (Classic Era)")
        end
    else
        print("|cffff0000Classic Fishing Companion:|r Unable to access bag contents. Please try /reload or restart WoW.")
        if self.debug then
            print("|cffff0000[CFC Debug]|r C_Container exists: " .. tostring(C_Container ~= nil))
            if C_Container then
                print("|cffff0000[CFC Debug]|r C_Container.GetContainerNumSlots: " .. tostring(C_Container.GetContainerNumSlots ~= nil))
                print("|cffff0000[CFC Debug]|r C_Container.GetContainerItemInfo: " .. tostring(C_Container.GetContainerItemInfo ~= nil))
            end
            print("|cffff0000[CFC Debug]|r _G.GetContainerNumSlots: " .. tostring(_G.GetContainerNumSlots ~= nil))
        end
        return nil, nil
    end

    for b = CFC.CONSTANTS.BAGS.FIRST, CFC.CONSTANTS.BAGS.LAST do
        local numSlots = GetNumSlots(b) or 0
        if self.debug then
            print("|cffff8800[CFC Debug]|r   Checking bag " .. b .. " (" .. numSlots .. " slots)")
        end

        if numSlots > 0 then
            for s = 1, numSlots do
                local slotKey = b .. ":" .. s
                -- Skip slots that have already been used (for handling duplicate items)
                if not usedBagSlots[slotKey] then
                    local containerItemID = GetItemID(b, s)
                    if self.debug and containerItemID then
                        print("|cffff8800[CFC Debug]|r     Bag " .. b .. " Slot " .. s .. ": Item " .. containerItemID)
                    end
                    if containerItemID and containerItemID == itemID then
                        if self.debug then
                            print("|cff00ff00[CFC Debug]|r   ✓ Found item " .. itemID .. " in bag " .. b .. ", slot " .. s)
                        end
                        return b, s
                    end
                end
            end
        end
    end

    if self.debug then
        print("|cffff0000[CFC Debug]|r   ✗ Item " .. itemID .. " not found in any bag")
    end

    return nil, nil
end

-- Validate a gear set: check which items are available (equipped or in bags)
-- Returns: { available = count, missing = count, total = count, items = { [slotID] = { name, texture, quality, available } } }
function CFC:ValidateGearSet(setName)
    local result = { available = 0, missing = 0, total = 0, items = {} }
    local gearSet = self.db and self.db.profile and self.db.profile.gearSets and self.db.profile.gearSets[setName]
    if not gearSet or not next(gearSet) then
        return result
    end

    for slotID, itemLink in pairs(gearSet) do
        local itemName, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemLink)
        local itemID = tonumber(string.match(itemLink, "item:(%d+)"))
        if itemName and itemID then
            result.total = result.total + 1
            -- Check if already equipped in this slot
            local equippedLink = GetInventoryItemLink("player", slotID)
            local equippedID = equippedLink and tonumber(string.match(equippedLink, "item:(%d+)"))
            local isAvailable = false
            if equippedID == itemID then
                isAvailable = true
            else
                -- Check bags
                local bag, slot = self:FindItemInBags(itemID, {})
                if bag then
                    isAvailable = true
                end
            end
            if isAvailable then
                result.available = result.available + 1
            else
                result.missing = result.missing + 1
            end
            result.items[slotID] = {
                name = itemName,
                texture = texture,
                quality = quality or 1,
                available = isAvailable,
            }
        end
    end
    return result
end

-- Swap between fishing and combat gear
function CFC:SwapGear()
    if self.debug then
        print("|cffff8800[CFC Debug]|r ===== GEAR SWAP INITIATED =====")
    end

    -- Check if in combat
    if InCombatLockdown() then
        print("|cffff0000Classic Fishing Companion:|r Cannot swap gear while in combat!")
        if self.debug then
            print("|cffff0000[CFC Debug]|r Combat lockdown active - aborting gear swap")
        end
        return false
    end

    -- Check if casting or channeling
    local castingSpell = UnitCastingInfo("player")
    local channelingSpell = UnitChannelInfo("player")

    if castingSpell or channelingSpell then
        local spellName = castingSpell or channelingSpell
        print("|cffff0000Classic Fishing Companion:|r Cannot swap gear while casting!")
        if self.debug then
            print("|cffff0000[CFC Debug]|r Currently casting/channeling: " .. tostring(spellName) .. " - aborting gear swap")
        end
        return false
    end

    if not self.db or not self.db.profile or not self.db.profile.gearSets then
        print("|cffff0000Classic Fishing Companion:|r No gear sets configured!")
        print("|cffffcc00Tip:|r Equip your combat gear, then type |cffff8800/cfc savecombat|r")
        print("|cffffcc00Then:|r Equip your fishing gear, then type |cffff8800/cfc savefishing|r")
        if self.debug then
            print("|cffff0000[CFC Debug]|r Gear sets not configured - database missing")
        end
        return false
    end

    local currentMode = self.db.profile.gearSets.currentMode or "combat"
    local newMode = (currentMode == "combat") and "fishing" or "combat"

    if self.debug then
        print("|cffff8800[CFC Debug]|r Current mode: " .. currentMode)
        print("|cffff8800[CFC Debug]|r Target mode: " .. newMode)
    end

    -- Check if both gear sets exist
    local hasCombat = self.db.profile.gearSets.combat and next(self.db.profile.gearSets.combat)
    local hasFishing = self.db.profile.gearSets.fishing and next(self.db.profile.gearSets.fishing)

    if self.debug then
        print("|cffff8800[CFC Debug]|r Has combat gear: " .. tostring(hasCombat))
        print("|cffff8800[CFC Debug]|r Has fishing gear: " .. tostring(hasFishing))
    end

    -- When swapping to fishing, verify the fishing pole is available
    if newMode == "fishing" and hasFishing then
        local fishingSet = self.db.profile.gearSets.fishing
        local poleLink = fishingSet[16] -- Main Hand slot
        if poleLink then
            local poleItemID = tonumber(string.match(poleLink, "item:(%d+)"))
            if poleItemID then
                -- Check if already equipped in main hand
                local equippedLink = GetInventoryItemLink("player", 16)
                local equippedID = equippedLink and tonumber(string.match(equippedLink, "item:(%d+)"))
                local hasPole = (equippedID == poleItemID)

                -- If not equipped, check bags
                if not hasPole then
                    hasPole = self:FindItemInBags(poleItemID) ~= nil
                end

                if not hasPole then
                    local poleName = string.match(poleLink, "%[(.-)%]") or "Fishing Pole"
                    print("|cffff0000Classic Fishing Companion:|r Cannot swap to fishing gear - " .. poleName .. " not found!")
                    if self.debug then
                        print("|cffff0000[CFC Debug]|r Fishing pole (item " .. poleItemID .. ") not in bags or equipped - aborting swap")
                    end
                    return false
                end
            end
        end
    end

    -- Load the other gear set
    if self.debug then
        print("|cffff8800[CFC Debug]|r Loading '" .. newMode .. "' gear set...")
    end

    if self:LoadGearSet(newMode) then
        print("|cff00ff00Classic Fishing Companion:|r Swapped to " .. newMode .. " gear!")
        if self.debug then
            print("|cff00ff00[CFC Debug]|r ===== GEAR SWAP COMPLETE =====")
        end
        return true
    else
        if self.debug then
            print("|cffff0000[CFC Debug]|r ===== GEAR SWAP FAILED =====")
        end
        return false
    end
end

-- Apply selected lure to fishing pole
function CFC:ApplySelectedLure()
    if self.debug then
        print("|cffff8800[CFC Debug]|r ===== APPLY LURE INITIATED =====")
    end

    -- Check if in combat
    if InCombatLockdown() then
        if self.debug then
            print("|cffff0000[CFC Debug]|r Cannot apply lure - IN COMBAT!")
        end
        print("|cffff0000Classic Fishing Companion:|r Cannot apply lure while in combat!")
        return
    end
    if self.debug then
        print("|cff00ff00[CFC Debug]|r Combat check passed - not in combat")
    end

    -- Check database
    if not self.db or not self.db.profile then
        if self.debug then
            print("|cffff0000[CFC Debug]|r Database not initialized!")
        end
        return
    end
    if self.debug then
        print("|cff00ff00[CFC Debug]|r Database check passed")
    end

    -- Check if lure is selected
    local selectedLureID = self.db.profile.selectedLure
    if self.debug then
        print("|cffff8800[CFC Debug]|r Selected lure ID from DB: " .. tostring(selectedLureID))
    end

    if not selectedLureID then
        if self.debug then
            print("|cffff0000[CFC Debug]|r No lure selected in database!")
        end
        print("|cffff0000Classic Fishing Companion:|r No lure selected!")
        print("|cffffcc00Tip:|r Open the Lure Manager tab to select a lure")
        return
    end
    if self.debug then
        print("|cff00ff00[CFC Debug]|r Lure selection check passed - ID: " .. selectedLureID)
    end

    -- Lure names mapping
    local lureNames = {
        [6529] = "Shiny Bauble",
        [6530] = "Nightcrawlers",
        [6811] = "Bright Baubles",
        [7307] = "Flesh Eating Worm",
        [6533] = "Aquadynamic Fish Attractor",
    }

    local lureName = lureNames[selectedLureID] or "Unknown Lure"
    if self.debug then
        print("|cffff8800[CFC Debug]|r Lure name: " .. lureName)
    end

    -- Check if player has the lure in bags
    if self.debug then
        print("|cffff8800[CFC Debug]|r Scanning bags for lure...")
    end
    local hasLure = false
    local lureBag, lureSlot = nil, nil

    -- Determine which bag API to use
    local GetNumSlots, GetItemInfo

    -- Try C_Container API first (Classic Anniversary / Retail)
    if C_Container and type(C_Container.GetContainerNumSlots) == "function" then
        GetNumSlots = function(bag) return C_Container.GetContainerNumSlots(bag) end
        GetItemInfo = function(bag, slot)
            return C_Container.GetContainerItemInfo(bag, slot)
        end
        if self.debug then
            print("|cffff8800[CFC Debug]|r Using C_Container API (Classic Anniversary)")
        end
    -- Fallback to old global API (Classic Era)
    elseif _G.GetContainerNumSlots and type(_G.GetContainerNumSlots) == "function" then
        GetNumSlots = _G.GetContainerNumSlots
        GetItemInfo = function(bag, slot)
            local texture, count, locked, quality, readable, lootable, itemLink = _G.GetContainerItemInfo(bag, slot)
            return { iconFileID = texture, stackCount = count, isLocked = locked, quality = quality, isReadable = readable, hasLoot = lootable, hyperlink = itemLink }
        end
        if self.debug then
            print("|cffff8800[CFC Debug]|r Using legacy bag API (Classic Era)")
        end
    else
        if self.debug then
            print("|cffff0000[CFC Debug]|r ERROR: No bag API available!")
        end
        print("|cffff0000Classic Fishing Companion:|r Cannot access bags - API not available")
        return
    end

    -- Use pcall to catch any errors during bag scanning
    local scanSuccess, scanError = pcall(function()
        for bag = CFC.CONSTANTS.BAGS.FIRST, CFC.CONSTANTS.BAGS.LAST do
            local numSlots = GetNumSlots(bag)
            if self.debug then
                print("|cffff8800[CFC Debug]|r Bag " .. bag .. " has " .. tostring(numSlots) .. " slots")
            end

            if numSlots and numSlots > 0 then
                for slot = 1, numSlots do
                    local itemInfo = GetItemInfo(bag, slot)

                    if itemInfo then
                        local itemLink = itemInfo.hyperlink or itemInfo.itemLink

                        if itemLink then
                            -- Parse item ID from itemLink string (format: "item:####")
                            local itemString = string.match(itemLink, "item:(%d+)")
                            local itemID = itemString and tonumber(itemString)

                            if itemID then
                                if self.debug then
                                    print("|cffff8800[CFC Debug]|r   Slot " .. slot .. ": ItemID = " .. itemID)
                                end
                                if itemID == selectedLureID then
                                    hasLure = true
                                    lureBag = bag
                                    lureSlot = slot
                                    if self.debug then
                                        print("|cff00ff00[CFC Debug]|r   FOUND LURE! Bag " .. bag .. " Slot " .. slot)
                                    end
                                    return  -- Exit the loop
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Check if scanning encountered an error
    if not scanSuccess then
        if self.debug then
            print("|cffff0000[CFC Debug]|r ERROR during bag scan: " .. tostring(scanError))
        end
        print("|cffff0000Classic Fishing Companion:|r Error scanning bags - please try again")
        return
    end

    if not hasLure then
        if self.debug then
            print("|cffff0000[CFC Debug]|r Lure not found in bags!")
        end
        print("|cffff0000Classic Fishing Companion:|r You don't have " .. lureName .. " in your bags!")
        return
    end

    if self.debug then
        print("|cff00ff00[CFC Debug]|r Lure found - Bag: " .. lureBag .. ", Slot: " .. lureSlot)
    end

    -- Check if fishing pole is equipped in main hand
    if self.debug then
        print("|cffff8800[CFC Debug]|r Checking main hand for fishing pole...")
    end
    local mainHandLink = GetInventoryItemLink("player", 16)
    if not mainHandLink then
        if self.debug then
            print("|cffff0000[CFC Debug]|r No item equipped in main hand!")
        end
        print("|cffff0000Classic Fishing Companion:|r No fishing pole equipped!")
        return
    end

    if self.debug then
        print("|cff00ff00[CFC Debug]|r Main hand item: " .. mainHandLink)
    end

    -- Determine which UseContainerItem API to use
    local UseItemFromBag
    if C_Container and type(C_Container.UseContainerItem) == "function" then
        UseItemFromBag = function(bag, slot)
            C_Container.UseContainerItem(bag, slot)
        end
        if self.debug then
            print("|cffff8800[CFC Debug]|r Using C_Container.UseContainerItem")
        end
    elseif _G.UseContainerItem and type(_G.UseContainerItem) == "function" then
        UseItemFromBag = _G.UseContainerItem
        if self.debug then
            print("|cffff8800[CFC Debug]|r Using legacy UseContainerItem")
        end
    else
        if self.debug then
            print("|cffff0000[CFC Debug]|r ERROR: No UseContainerItem API available!")
        end
        print("|cffff0000Classic Fishing Companion:|r Cannot use items from bags")
        return
    end

    -- Apply the lure: Use the lure item (picks it up on cursor), then click the fishing pole
    -- In Classic WoW, we need a small delay between these two actions
    if self.debug then
        print("|cffff8800[CFC Debug]|r Step 1: Using lure from bag " .. lureBag .. " slot " .. lureSlot)
    end
    UseItemFromBag(lureBag, lureSlot)
    if self.debug then
        print("|cffff8800[CFC Debug]|r Called UseItemFromBag - lure should now be on cursor")
    end

    -- Wait a short moment for the cursor to update, then apply to fishing pole
    if self.debug then
        print("|cffff8800[CFC Debug]|r Waiting 0.1 seconds before applying to fishing pole...")
    end
    C_Timer.After(0.1, function()
        if CFC.debug then
            print("|cffff8800[CFC Debug]|r Step 2: Checking cursor state...")
        end
        local cursorType, itemID = GetCursorInfo()
        if CFC.debug then
            print("|cffff8800[CFC Debug]|r Cursor type: " .. tostring(cursorType) .. ", ItemID: " .. tostring(itemID))
        end

        if cursorType == "item" and itemID == selectedLureID then
            if CFC.debug then
                print("|cff00ff00[CFC Debug]|r Cursor has lure! Applying to fishing pole...")
            end
            PickupInventoryItem(CFC.CONSTANTS.SLOTS.MAIN_HAND)  -- main hand weapon slot
            if CFC.debug then
                print("|cffff8800[CFC Debug]|r Called PickupInventoryItem(16)")
            end

            -- Check if successful
            C_Timer.After(0.1, function()
                local stillHasCursor = GetCursorInfo()
                if stillHasCursor then
                    if CFC.debug then
                        print("|cffff0000[CFC Debug]|r WARNING: Cursor still has item - application may have failed")
                    end
                    ClearCursor()  -- Clear cursor to prevent issues
                else
                    if CFC.debug then
                        print("|cff00ff00[CFC Debug]|r Success! Cursor cleared - lure applied")
                    end
                end
            end)

            print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " Applied " .. lureName .. " to fishing pole!")
        else
            if CFC.debug then
                print("|cffff0000[CFC Debug]|r ERROR: Cursor doesn't have lure! Type: " .. tostring(cursorType))
            end
            if cursorType then
                ClearCursor()  -- Clear whatever is on cursor
            end
            print(CFC.COLORS.ERROR .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " Failed to apply lure - please try again")
        end
    end)

    if self.debug then
        print("|cff00ff00[CFC Debug]|r ===== APPLY LURE INITIATED (waiting for completion) =====")
    end
end

-- Update lure macro (TBC only - API restrictions)
function CFC:UpdateLureMacro()
    -- Check if lure is selected
    local selectedLureID = self.db and self.db.profile and self.db.profile.selectedLure
    if not selectedLureID then
        print("|cffff0000Classic Fishing Companion:|r No lure selected! Go to Lure tab to select one.")
        return false
    end

    -- Get lure name and icon
    local lureData = {
        [6529] = { name = "Shiny Bauble", icon = "INV_Misc_Orb_03" },
        [6530] = { name = "Nightcrawlers", icon = "INV_Misc_MonsterTail_03" },
        [6532] = { name = "Bright Baubles", icon = "INV_Misc_Gem_Variety_02" },
        [7307] = { name = "Flesh Eating Worm", icon = "INV_Misc_MonsterTail_03" },
        [6533] = { name = "Aquadynamic Fish Attractor", icon = "INV_Misc_Food_26" },
        [6811] = { name = "Aquadynamic Fish Lens", icon = "INV_Misc_Spyglass_01" },
        [34861] = { name = "Sharpened Fish Hook", icon = "INV_Misc_Hook_01" },
    }
    local lure = lureData[selectedLureID]
    if not lure then
        print("|cffff0000Classic Fishing Companion:|r Unknown lure selected!")
        return false
    end

    local lureName = lure.name
    local lureIcon = lure.icon

    -- Build macro text
    local macroText = "#showtooltip\n/use " .. lureName .. "\n/use 16"
    local macroName = "CFC_ApplyLure"

    -- Check if macro exists
    local macroIndex = GetMacroIndexByName(macroName)

    if macroIndex and macroIndex > 0 then
        -- Macro exists, try to update it
        local success, err = pcall(function()
            EditMacro(macroIndex, macroName, lureIcon, macroText)
        end)

        if success then
            print("|cff00ff00Classic Fishing Companion:|r Macro updated with " .. lureName .. "!")
            return true
        else
            print("|cffff0000Classic Fishing Companion:|r Failed to update macro (protected by Blizzard)")
            print("|cffffcc00→|r Please update the macro manually with the text from the box above")
            return false
        end
    else
        -- Macro doesn't exist, try to create it
        local success, err = pcall(function()
            CreateMacro(macroName, lureIcon, macroText, nil)
        end)

        if success then
            print("|cff00ff00Classic Fishing Companion:|r Macro created with " .. lureName .. "!")
            return true
        else
            print("|cffff0000Classic Fishing Companion:|r Failed to create macro (protected by Blizzard)")
            print("|cffffcc00→|r Please create the macro manually with the text from the box above")
            return false
        end
    end
end

-- Check if gear sets are configured
function CFC:HasGearSets()
    if not self.db or not self.db.profile or not self.db.profile.gearSets then
        if self.debug then
            print("|cffff8800[CFC Debug]|r HasGearSets: No database")
        end
        return false
    end

    local fishing = self.db.profile.gearSets.fishing
    local combat = self.db.profile.gearSets.combat

    local hasFishing = fishing and next(fishing)
    local hasCombat = combat and next(combat)
    local hasGearSets = hasFishing and hasCombat

    return hasGearSets
end

-- Get current gear mode
function CFC:GetCurrentGearMode()
    if not self.db or not self.db.profile or not self.db.profile.gearSets then
        if self.debug then
            print("|cffff8800[CFC Debug]|r GetCurrentGearMode: No database, defaulting to 'combat'")
        end
        return "combat"
    end

    local mode = self.db.profile.gearSets.currentMode or "combat"
    return mode
end

-- ========================================
-- DATA IMPORT/EXPORT SYSTEM
-- ========================================

-- Serialize a table to a string (recursive)
local function SerializeTable(tbl, indent)
    indent = indent or 0
    local result = "{\n"
    local indentStr = string.rep("  ", indent + 1)

    for key, value in pairs(tbl) do
        -- Format the key
        local keyStr
        if type(key) == "string" then
            keyStr = string.format('[%q]', key)
        else
            keyStr = "[" .. tostring(key) .. "]"
        end

        -- Format the value
        local valueStr
        if type(value) == "table" then
            valueStr = SerializeTable(value, indent + 1)
        elseif type(value) == "string" then
            valueStr = string.format("%q", value)
        elseif type(value) == "boolean" then
            valueStr = tostring(value)
        elseif type(value) == "number" then
            valueStr = tostring(value)
        else
            valueStr = "nil"
        end

        result = result .. indentStr .. keyStr .. " = " .. valueStr .. ",\n"
    end

    result = result .. string.rep("  ", indent) .. "}"
    return result
end

-- Export all fishing data to a string
function CFC:ExportData()
    if not self.db or not self.db.profile then
        print("|cffff0000Classic Fishing Companion:|r No data to export!")
        return
    end

    -- Create export data structure (only fishing-related data)
    local exportData = {
        version = CFC.VERSION,
        catches = self.db.profile.catches,
        fishData = self.db.profile.fishData,
        statistics = self.db.profile.statistics,
        sessions = self.db.profile.sessions,
        buffUsage = self.db.profile.buffUsage,
        skillLevels = self.db.profile.skillLevels,
        poleUsage = self.db.profile.poleUsage,
    }

    -- Serialize to string
    local serialized = "return " .. SerializeTable(exportData)

    -- Show export dialog using the custom UI
    if CFC.UI and CFC.UI.ShowExportDialog then
        CFC.UI:ShowExportDialog(serialized)
    else
        print("|cffff0000Classic Fishing Companion:|r Export dialog not available!")
    end

    print("|cff00ff00Classic Fishing Companion:|r Data exported successfully!")
end

-- Purge a specific item from the database
function CFC:PurgeItem(itemName)
    if not itemName or itemName == "" then
        print("|cffff0000Classic Fishing Companion:|r No item name provided!")
        return false
    end

    local removedCount = 0
    local foundInFishData = false
    local foundInPoleUsage = false
    local foundInLureUsage = false
    local itemNameLower = string.lower(itemName)

    -- Remove from catches array (case-insensitive)
    local newCatches = {}
    for _, catch in ipairs(self.db.profile.catches) do
        if string.lower(catch.itemName) ~= itemNameLower then
            table.insert(newCatches, catch)
        else
            removedCount = removedCount + 1
        end
    end
    self.db.profile.catches = newCatches

    -- Remove from fishData (case-insensitive)
    for key, _ in pairs(self.db.profile.fishData) do
        if string.lower(key) == itemNameLower then
            self.db.profile.fishData[key] = nil
            foundInFishData = true
            break
        end
    end

    -- Remove from poleUsage (case-insensitive)
    for key, _ in pairs(self.db.profile.poleUsage) do
        if string.lower(key) == itemNameLower then
            self.db.profile.poleUsage[key] = nil
            foundInPoleUsage = true
            break
        end
    end

    -- Remove from buffUsage (lures/buffs used) (case-insensitive)
    if self.db.profile.buffUsage then
        for key, _ in pairs(self.db.profile.buffUsage) do
            if string.lower(key) == itemNameLower then
                self.db.profile.buffUsage[key] = nil
                foundInLureUsage = true
                break
            end
        end
    end

    -- Update total catches count
    if removedCount > 0 then
        self.db.profile.statistics.totalCatches = math.max(0, self.db.profile.statistics.totalCatches - removedCount)
    end

    -- Update UI if open
    if self.UpdateUI then
        self:UpdateUI()
    end

    -- Update HUD
    if self.HUD and self.HUD.Update then
        self.HUD:Update()
    end

    if removedCount > 0 or foundInFishData or foundInPoleUsage or foundInLureUsage then
        local message = "|cff00ff00Classic Fishing Companion:|r Removed '" .. itemName .. "' from database"
        if removedCount > 0 then
            message = message .. " (" .. removedCount .. " catches)"
        end
        if foundInPoleUsage then
            message = message .. " (pole usage)"
        end
        if foundInLureUsage then
            message = message .. " (lure usage)"
        end
        print(message)
        return true
    else
        print("|cffffcc00Classic Fishing Companion:|r Item '" .. itemName .. "' not found in database")
        return false
    end
end

-- Import fishing data from a string
function CFC:ImportData(importString)
    if not importString or importString == "" then
        print("|cffff0000Classic Fishing Companion:|r Import failed - no data provided!")
        return
    end

    -- Try to deserialize the data
    local loadFunc, loadError = loadstring(importString)

    if not loadFunc then
        print("|cffff0000Classic Fishing Companion:|r Import failed - invalid data format!")
        print("|cffff0000Error:|r " .. tostring(loadError))
        return
    end

    -- Execute the function to get the data
    local success, importData = pcall(loadFunc)

    if not success or type(importData) ~= "table" then
        print("|cffff0000Classic Fishing Companion:|r Import failed - could not load data!")
        return
    end

    -- Validate version (optional, just for info)
    if importData.version then
        print("|cff00ff00Classic Fishing Companion:|r Importing data from version " .. importData.version)
    end

    -- Import the data
    if importData.catches then
        self.db.profile.catches = importData.catches
    end

    if importData.fishData then
        self.db.profile.fishData = importData.fishData
    end

    if importData.statistics then
        -- Preserve current session info but import totals
        local currentSessionCatches = self.db.profile.statistics.sessionCatches
        local currentSessionStart = self.db.profile.statistics.sessionStartTime

        self.db.profile.statistics = importData.statistics

        -- Restore current session info
        self.db.profile.statistics.sessionCatches = currentSessionCatches
        self.db.profile.statistics.sessionStartTime = currentSessionStart
    end

    if importData.sessions then
        self.db.profile.sessions = importData.sessions
    end

    if importData.buffUsage then
        self.db.profile.buffUsage = importData.buffUsage
    end

    if importData.skillLevels then
        self.db.profile.skillLevels = importData.skillLevels
    end

    if importData.poleUsage then
        self.db.profile.poleUsage = importData.poleUsage
    end

    print("|cff00ff00Classic Fishing Companion:|r Data imported successfully!")

    -- Update UI if open
    if self.UpdateUI then
        self:UpdateUI()
    end

    -- Update HUD
    if self.HUD and self.HUD.Update then
        self.HUD:Update()
    end
end

-- Create an internal backup of fishing data
function CFC:CreateBackup()
    if not self.db or not self.db.profile then
        if self.debug then
            print("|cffff8800[CFC Debug]|r Cannot create backup - no data")
        end
        return false
    end

    -- Create backup snapshot (deep copy of fishing data only)
    local backupData = {
        version = CFC.VERSION,
        timestamp = time(),
        catches = self:DeepCopy(self.db.profile.catches),
        fishData = self:DeepCopy(self.db.profile.fishData),
        statistics = self:DeepCopy(self.db.profile.statistics),
        sessions = self:DeepCopy(self.db.profile.sessions),
        buffUsage = self:DeepCopy(self.db.profile.buffUsage),
        skillLevels = self:DeepCopy(self.db.profile.skillLevels),
        poleUsage = self:DeepCopy(self.db.profile.poleUsage),
    }

    -- Store backup
    self.db.profile.backup.data = backupData

    -- Update last backup timestamp (real-world time)
    self.db.profile.backup.lastBackupTime = time()

    if self.debug then
        print("|cffff8800[CFC Debug]|r Backup created successfully at " .. date("%Y-%m-%d %H:%M:%S", backupData.timestamp))
    end

    return true
end

-- Restore fishing data from internal backup
function CFC:RestoreFromBackup()
    if not self.db or not self.db.profile or not self.db.profile.backup.data then
        print("|cffff0000Classic Fishing Companion:|r No backup data available to restore!")
        return false
    end

    local backupData = self.db.profile.backup.data

    -- Restore fishing data from backup
    if backupData.catches then
        self.db.profile.catches = self:DeepCopy(backupData.catches)
    end

    if backupData.fishData then
        self.db.profile.fishData = self:DeepCopy(backupData.fishData)
    end

    if backupData.statistics then
        -- Preserve session data, restore everything else
        local sessionCatches = self.db.profile.statistics.sessionCatches
        local sessionStartTime = self.db.profile.statistics.sessionStartTime

        self.db.profile.statistics = self:DeepCopy(backupData.statistics)

        -- Restore current session data
        self.db.profile.statistics.sessionCatches = sessionCatches
        self.db.profile.statistics.sessionStartTime = sessionStartTime
    end

    if backupData.sessions then
        self.db.profile.sessions = self:DeepCopy(backupData.sessions)
    end

    if backupData.buffUsage then
        self.db.profile.buffUsage = self:DeepCopy(backupData.buffUsage)
    end

    if backupData.skillLevels then
        self.db.profile.skillLevels = self:DeepCopy(backupData.skillLevels)
    end

    if backupData.poleUsage then
        self.db.profile.poleUsage = self:DeepCopy(backupData.poleUsage)
    end

    local backupDate = date("%Y-%m-%d %H:%M:%S", backupData.timestamp)
    print("|cff00ff00Classic Fishing Companion:|r Data restored from backup created on " .. backupDate)

    -- Update UI if open
    if self.UpdateUI then
        self:UpdateUI()
    end

    -- Update HUD
    if self.HUD and self.HUD.Update then
        self.HUD:Update()
    end

    return true
end

-- Deep copy helper function
function CFC:DeepCopy(original)
    if type(original) ~= "table" then
        return original
    end

    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = self:DeepCopy(value)
        else
            copy[key] = value
        end
    end

    return copy
end

-- Slash command handler
SLASH_CFC1 = "/cfc"
SLASH_CFC2 = "/fishingcompanion"
SlashCmdList["CFC"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "reset" then
        if CFC.db and CFC.db.profile then
            CFC.db.profile.catches = {}
            CFC.db.profile.fishData = {}
            CFC.db.profile.statistics.totalCatches = 0
            CFC.db.profile.statistics.sessionCatches = 0
            print("|cff00ff00Classic Fishing Companion:|r All data has been reset.")
        end
    elseif msg == "stats" then
        CFC:PrintStats()
    elseif msg == "debug" then
        CFC.debug = not CFC.debug
        if CFC.debug then
            print("|cff00ff00Classic Fishing Companion:|r Debug mode |cff00ff00enabled|r")
        else
            print("|cff00ff00Classic Fishing Companion:|r Debug mode |cffff0000disabled|r")
        end
    elseif msg == "savefishing" then
        if CFC.debug then
            print("|cffff8800[CFC Debug]|r Slash command: savefishing")
        end
        CFC:SaveGearSet("fishing")
        print("|cff00ff00Classic Fishing Companion:|r Fishing gear set saved!")
    elseif msg == "savecombat" then
        if CFC.debug then
            print("|cffff8800[CFC Debug]|r Slash command: savecombat")
        end
        CFC:SaveGearSet("combat")
        print("|cff00ff00Classic Fishing Companion:|r Combat gear set saved!")
    elseif msg == "swap" or msg == "gear" then
        if CFC.debug then
            print("|cffff8800[CFC Debug]|r Slash command: swap/gear")
        end
        CFC:SwapGear()
    elseif msg == "minimap" then
        print("|cff00ff00[CFC Debug]|r CFC.Minimap exists: " .. tostring(CFC.Minimap ~= nil))
        print("|cff00ff00[CFC Debug]|r CFC.minimapButton exists: " .. tostring(CFC.minimapButton ~= nil))

        if CFC.Minimap and CFC.Minimap.ToggleButton then
            CFC.Minimap:ToggleButton()
        elseif CFC.minimapButton then
            -- Try to toggle directly
            if CFC.minimapButton:IsShown() then
                CFC.minimapButton:Hide()
                print("|cff00ff00Classic Fishing Companion:|r Minimap button hidden.")
            else
                CFC.minimapButton:Show()
                print("|cff00ff00Classic Fishing Companion:|r Minimap button shown.")
            end
        else
            print("|cffff0000Classic Fishing Companion:|r Minimap module not loaded or button not created.")
            print("|cffff0000[CFC Debug]|r Try /reload to reinitialize the addon.")
        end
    elseif msg == "testsound" then
        PlaySound(CFC.CONSTANTS.RARE_FISH_SOUND, "Master")
        print("|cff00ff00Classic Fishing Companion:|r Playing rare fish sound (ID: " .. CFC.CONSTANTS.RARE_FISH_SOUND .. ")")
    elseif msg == "testmilestone" then
        local message = "Milestone reached: 1000 fish caught!"
        print(CFC.COLORS.SUCCESS .. "Classic Fishing Companion:" .. CFC.COLORS.RESET .. " " .. CFC.COLORS.TIP .. message .. CFC.COLORS.RESET)
        RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"], 5)
        PlaySound(888)
        print("|cff00ff00Classic Fishing Companion:|r Testing milestone notification (sound ID: 888)")
    elseif msg == "hud" then
        if CFC.HUD and CFC.HUD.ToggleShow then
            local swapBlocked = false
            -- Auto-swap gear if enabled
            if CFC.db.profile.settings.autoSwapOnHUD then
                local gearSets = CFC.db.profile.gearSets
                local hasFishingGear = gearSets and gearSets.fishing and next(gearSets.fishing)
                local hasCombatGear = gearSets and gearSets.combat and next(gearSets.combat)

                if hasFishingGear and hasCombatGear then
                    local hudCurrentlyShown = CFC.db.profile.hud.show
                    local currentMode = gearSets.currentMode or "combat"

                    if hudCurrentlyShown then
                        if currentMode ~= "combat" and CFC.SwapGear then
                            if CFC:SwapGear() == false then
                                swapBlocked = true
                            end
                        end
                    else
                        if currentMode ~= "fishing" and CFC.SwapGear then
                            if CFC:SwapGear() == false then
                                swapBlocked = true
                            end
                        end
                    end
                else
                    print("|cffff8800[CFC]|r Auto-swap enabled but gear sets not configured. Please save both fishing and combat gear sets in the Gear Sets tab.")
                end
            end
            if not swapBlocked then
                CFC.HUD:ToggleShow()
            end
        else
            print("|cff00ff00Classic Fishing Companion:|r HUD module not loaded.")
        end
    else
        if CFC.ToggleUI then
            CFC:ToggleUI()
        end
    end
end

-- Print statistics to chat
function CFC:PrintStats()
    local fph = self:GetFishPerHour()
    local totalTime = self:GetTotalFishingTime()

    print("|cff00ff00=== Classic Fishing Companion Statistics ===|r")
    print("|cffffcc00Total Catches:|r " .. self.db.profile.statistics.totalCatches)
    print("|cffffcc00Session Catches:|r " .. self.db.profile.statistics.sessionCatches)
    print("|cffffcc00Fish Per Hour:|r " .. string.format("%.1f", fph))
    print("|cffffcc00Total Fishing Time:|r " .. string.format("%.1f hours", totalTime))
    print("|cffffcc00Unique Fish Types:|r " .. self:GetUniqueFishCount())
end

-- Get count of unique fish types
function CFC:GetUniqueFishCount()
    local count = 0
    for _ in pairs(self.db.profile.fishData) do
        count = count + 1
    end
    return count
end

-- Refresh fish icons by scanning bags
function CFC:RefreshFishIcons()
    print("|cff00ff00Classic Fishing Companion:|r Scanning bags for fish icons...")

    local iconsFound = 0
    local iconsUpdated = 0

    -- Determine which bag API to use
    local GetNumSlots, GetItemLink, GetItemInfo_Bag

    -- Try C_Container API first (Anniversary Classic)
    if C_Container and C_Container.GetContainerNumSlots then
        GetNumSlots = function(bag) return C_Container.GetContainerNumSlots(bag) end
        GetItemLink = function(bag, slot) return C_Container.GetContainerItemLink(bag, slot) end
        GetItemInfo_Bag = function(bag, slot)
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            return itemInfo and itemInfo.iconFileID
        end
    -- Fallback to old API (Classic Era)
    elseif GetContainerNumSlots then
        GetNumSlots = GetContainerNumSlots
        GetItemLink = GetContainerItemLink
        GetItemInfo_Bag = function(bag, slot)
            local texture = GetContainerItemInfo(bag, slot)
            return texture
        end
    else
        print("|cffff0000Classic Fishing Companion:|r Error: Bag API not available!")
        return
    end

    -- Scan all bags
    for bag = 0, 4 do
        local numSlots = GetNumSlots(bag) or 0

        for slot = 1, numSlots do
            local itemLink = GetItemLink(bag, slot)

            if itemLink then
                local itemName = GetItemInfo(itemLink)

                -- Check if this item is in our fish database
                if itemName and self.db.profile.fishData[itemName] then
                    -- Get the icon from the bag
                    local iconTexture = GetItemInfo_Bag(bag, slot)

                    if iconTexture then
                        -- Update the cached icon
                        local oldIcon = self.db.profile.fishData[itemName].icon
                        self.db.profile.fishData[itemName].icon = iconTexture
                        iconsFound = iconsFound + 1

                        if not oldIcon or oldIcon == "Interface\\Icons\\INV_Misc_Fish_02" then
                            iconsUpdated = iconsUpdated + 1
                        end

                        if self.debug then
                            print("|cffff8800[CFC Debug]|r Updated icon for: " .. itemName .. " -> " .. tostring(iconTexture))
                        end
                    end
                end
            end
        end
    end

    -- Update the UI if open
    if CFC.UI and CFC.UI.UpdateFishList then
        CFC.UI:UpdateFishList()
    end

    if iconsUpdated > 0 then
        print("|cff00ff00Classic Fishing Companion:|r Found " .. iconsFound .. " fish in bags, updated " .. iconsUpdated .. " icons!")
    else
        print("|cffffcc00Classic Fishing Companion:|r Found " .. iconsFound .. " fish in bags (all already had icons cached).")
    end
end

-- Background icon refresh (silent, runs every 5 minutes)
function CFC:RefreshFishIconsBackground()
    if not self.db or not self.db.profile or not self.db.profile.fishData then
        return
    end

    local iconsUpdated = 0

    -- Determine which bag API to use
    local GetNumSlots, GetItemLink, GetItemInfo_Bag

    -- Try C_Container API first (Anniversary Classic)
    if C_Container and C_Container.GetContainerNumSlots then
        GetNumSlots = function(bag) return C_Container.GetContainerNumSlots(bag) end
        GetItemLink = function(bag, slot) return C_Container.GetContainerItemLink(bag, slot) end
        GetItemInfo_Bag = function(bag, slot)
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            return itemInfo and itemInfo.iconFileID
        end
    -- Fallback to old API (Classic Era)
    elseif GetContainerNumSlots then
        GetNumSlots = GetContainerNumSlots
        GetItemLink = GetContainerItemLink
        GetItemInfo_Bag = function(bag, slot)
            local texture = GetContainerItemInfo(bag, slot)
            return texture
        end
    else
        return -- No bag API available
    end

    -- Scan all bags silently
    for bag = 0, 4 do
        local numSlots = GetNumSlots(bag) or 0

        for slot = 1, numSlots do
            local itemLink = GetItemLink(bag, slot)

            if itemLink then
                local itemName = GetItemInfo(itemLink)

                -- Check if this item is in our fish database and needs icon update
                if itemName and self.db.profile.fishData[itemName] then
                    local fishData = self.db.profile.fishData[itemName]

                    -- Only update if icon is missing or is the default
                    if not fishData.icon or fishData.icon == "Interface\\Icons\\INV_Misc_Fish_02" then
                        local iconTexture = GetItemInfo_Bag(bag, slot)

                        if iconTexture then
                            fishData.icon = iconTexture
                            iconsUpdated = iconsUpdated + 1

                            if self.debug then
                                print("|cffff8800[CFC Debug]|r Background refresh: Updated icon for " .. itemName)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Update UI if open (silent refresh)
    if CFC.UI and CFC.UI.UpdateFishList and iconsUpdated > 0 then
        CFC.UI:UpdateFishList()
    end
end

-- Schedule background icon refresh
function CFC:ScheduleBackgroundIconRefresh()
    -- Run first refresh after 60 seconds (gives WoW time to cache items)
    C_Timer.After(60, function()
        self:RefreshFishIconsBackground()

        -- Then schedule recurring refresh every 5 minutes (300 seconds)
        C_Timer.NewTicker(300, function()
            self:RefreshFishIconsBackground()
        end)
    end)
end

-- ========================================
-- EASY CAST SYSTEM
-- Double right-click to cast fishing
-- ========================================

local EASYCAST_BUTTON_NAME = "CFCEasyCastButton"
local EASYCAST_LURE_BUTTON_NAME = "CFCEasyCastLureButton"
local EASYCAST_DOUBLE_CLICK_WINDOW = 0.4  -- Max time between clicks
local EASYCAST_MAX_TAP_DURATION = 0.2     -- Max hold time to count as a "tap" (not camera movement)

-- Lure ID to name mapping (for Easy Cast lure application)
local EASYCAST_LURE_NAMES = {
    [6529] = "Shiny Bauble",
    [6530] = "Nightcrawlers",
    [6532] = "Bright Baubles",
    [7307] = "Flesh Eating Worm",
    [6533] = "Aquadynamic Fish Attractor",
    [6811] = "Aquadynamic Fish Lens",
    [34861] = "Sharpened Fish Hook",
}

-- Track state
CFC.easyCastBindingActive = false
CFC.easyCastBindingSetTime = 0
CFC.easyCastMouseDownTime = 0  -- When right mouse button was pressed
CFC.easyCastLastAction = nil   -- "fishing" or "lure" - tracks what the binding will do
CFC.easyCastLootClosedTime = 0 -- When loot window was last closed (for quick re-cast)

-- Get the fishing spell name (localized)
function CFC:GetFishingSpellName()
    -- Try to find by icon first (most reliable across locales)
    for i = 1, 500 do
        local name, _, icon = GetSpellInfo(i)
        if icon and string.find(icon, "Trade_Fishing") then
            return name
        end
    end
    -- Fallback to English name
    return "Fishing"
end

-- Check if cursor is over the fishing bobber
function CFC:IsOnFishingBobber()
    if GameTooltip:IsShown() then
        local tooltipText = GameTooltipTextLeft1:GetText()
        if tooltipText then
            -- Check for common bobber names (localized)
            local bobberNames = {"Fishing Bobber", "Bobber", "Schwimmer", "Bouchon", "Flotador"}
            for _, name in ipairs(bobberNames) do
                if string.find(tooltipText, name) then
                    return true
                end
            end
        end
    end
    return false
end

-- Check if cursor is over the minimap button
function CFC:IsOnMinimapButton()
    if GameTooltip:IsShown() then
        local tooltipText = GameTooltipTextLeft1:GetText()
        if tooltipText and string.find(tooltipText, "Classic Fishing") then
            return true
        end
    end
    return false
end

-- Check if cursor is over any interactable UI element
function CFC:IsOverUIElement()
    -- GetMouseFocus may not exist in Classic Era, use GetMouseFoci or fallback
    local focusFrame = nil
    if GetMouseFoci then
        local frames = GetMouseFoci()
        if frames and frames[1] then
            focusFrame = frames[1]
        end
    elseif GetMouseFocus then
        focusFrame = GetMouseFocus()
    end

    if focusFrame then
        local name = focusFrame:GetName() or ""
        -- Allow clicks on WorldFrame (the 3D world)
        if focusFrame == WorldFrame then
            return false
        end
        -- Block if over any named frame (UI element)
        if name ~= "" then
            return true
        end
    end
    return false
end

-- Create the secure action button for casting
function CFC:CreateEasyCastButton()
    if _G[EASYCAST_BUTTON_NAME] then
        return _G[EASYCAST_BUTTON_NAME]
    end

    local btn = CreateFrame("Button", EASYCAST_BUTTON_NAME, UIParent, "SecureActionButtonTemplate")
    btn:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    btn:SetSize(1, 1)
    btn:SetFrameStrata("LOW")
    btn:EnableMouse(false)
    btn:RegisterForClicks("AnyDown")
    btn:Show()

    -- Set up to cast fishing
    local fishingName = self:GetFishingSpellName()
    btn:SetAttribute("type", "spell")
    btn:SetAttribute("spell", fishingName)

    -- After the button is clicked (fishing cast), clear the binding
    btn:SetScript("PostClick", function()
        if not InCombatLockdown() then
            ClearOverrideBindings(btn)
        end
        CFC.easyCastBindingActive = false
        CFC.easyCastBindingSetTime = 0
        CFC.easyCastLastAction = nil
        if CFC.debug then
            print("|cff00ff00[CFC Debug]|r Easy Cast: Fishing cast, binding cleared")
        end
    end)

    return btn
end

-- Create the secure action button for applying lures
function CFC:CreateEasyCastLureButton()
    if _G[EASYCAST_LURE_BUTTON_NAME] then
        return _G[EASYCAST_LURE_BUTTON_NAME]
    end

    local btn = CreateFrame("Button", EASYCAST_LURE_BUTTON_NAME, UIParent, "SecureActionButtonTemplate")
    btn:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    btn:SetSize(1, 1)
    btn:SetFrameStrata("LOW")
    btn:EnableMouse(false)
    btn:RegisterForClicks("AnyDown")
    btn:Show()

    -- Set up as macro type (will be updated with lure macro)
    btn:SetAttribute("type", "macro")
    btn:SetAttribute("macrotext", "")  -- Will be set dynamically

    -- After the button is clicked (lure applied), clear the binding
    btn:SetScript("PostClick", function()
        if not InCombatLockdown() then
            ClearOverrideBindings(btn)
        end
        CFC.easyCastBindingActive = false
        CFC.easyCastBindingSetTime = 0
        CFC.easyCastLastAction = nil
        if CFC.debug then
            print("|cff00ff00[CFC Debug]|r Easy Cast: Lure applied, binding cleared")
        end
    end)

    return btn
end

-- Check if player has an active fishing lure
function CFC:HasActiveLure()
    local hasMainHandEnchant = GetWeaponEnchantInfo()
    return hasMainHandEnchant
end

-- Check if lure should be auto-applied
-- Returns: true if lure needed, false if should cast fishing
function CFC:ShouldApplyLure()
    -- If already have a lure active, don't apply another
    if self:HasActiveLure() then
        return false
    end

    -- Check if a lure is selected in settings
    local selectedLureID = self.db and self.db.profile and self.db.profile.selectedLure
    if not selectedLureID then
        return false  -- No lure selected, just cast fishing
    end

    -- Check if player has the selected lure in bags
    local lureCount = GetItemCount(selectedLureID)
    if lureCount == 0 then
        local now = GetTime()
        if now - (self.lastNoLureWarningTime or 0) >= 600 then
            local lureName = EASYCAST_LURE_NAMES[selectedLureID] or "selected lure"
            print("|cffff0000Classic Fishing Companion:|r Out of " .. lureName .. "! Casting without a lure.")
            self.lastNoLureWarningTime = now
        end
        return false  -- No lures in bags, just cast fishing
    end

    -- All conditions met - should apply lure
    return true
end

-- Get the selected lure name
function CFC:GetSelectedLureName()
    local selectedLureID = self.db and self.db.profile and self.db.profile.selectedLure
    if selectedLureID then
        return EASYCAST_LURE_NAMES[selectedLureID]
    end
    return nil
end

-- Clear the Easy Cast binding (both fishing and lure buttons)
function CFC:ClearEasyCastBinding()
    if not InCombatLockdown() then
        local fishBtn = _G[EASYCAST_BUTTON_NAME]
        if fishBtn then
            ClearOverrideBindings(fishBtn)
        end
        local lureBtn = _G[EASYCAST_LURE_BUTTON_NAME]
        if lureBtn then
            ClearOverrideBindings(lureBtn)
        end
    end
    self.easyCastBindingActive = false
    self.easyCastBindingSetTime = 0
    self.easyCastLastAction = nil
end

-- Set up binding for fishing cast
function CFC:SetupEasyCastFishingBinding()
    if InCombatLockdown() then
        return false
    end

    local btn = _G[EASYCAST_BUTTON_NAME]
    if not btn then
        btn = self:CreateEasyCastButton()
    end

    if btn then
        -- Update the spell name
        local fishingName = self:GetFishingSpellName()
        btn:SetAttribute("spell", fishingName)

        -- Set override binding - this redirects BUTTON2 (right-click) to our secure button
        SetOverrideBindingClick(btn, true, "BUTTON2", EASYCAST_BUTTON_NAME)
        self.easyCastBindingActive = true
        self.easyCastBindingSetTime = GetTime()
        self.easyCastLastAction = "fishing"

        if self.debug then
            print("|cff00ff00[CFC Debug]|r Easy Cast: Binding SET - next right-click will CAST " .. fishingName)
        end
        return true
    end
    return false
end

-- Set up binding for lure application
function CFC:SetupEasyCastLureBinding()
    if InCombatLockdown() then
        return false
    end

    local btn = _G[EASYCAST_LURE_BUTTON_NAME]
    if not btn then
        btn = self:CreateEasyCastLureButton()
    end

    local lureName = self:GetSelectedLureName()
    if not lureName then
        if self.debug then
            print("|cff00ff00[CFC Debug]|r Easy Cast: No lure selected, falling back to fishing")
        end
        return self:SetupEasyCastFishingBinding()
    end

    if btn then
        -- Set up macro to apply lure: /use [lure name] then /use 16 (mainhand slot)
        local macroText = "/use " .. lureName .. "\n/use 16"
        btn:SetAttribute("macrotext", macroText)

        -- Set override binding
        SetOverrideBindingClick(btn, true, "BUTTON2", EASYCAST_LURE_BUTTON_NAME)
        self.easyCastBindingActive = true
        self.easyCastBindingSetTime = GetTime()
        self.easyCastLastAction = "lure"

        if self.debug then
            print("|cff00ff00[CFC Debug]|r Easy Cast: Binding SET - next right-click will APPLY " .. lureName)
        end
        return true
    end
    return false
end

-- Set up binding after first click (catches second click)
-- Automatically chooses between lure application or fishing cast
function CFC:SetupEasyCastBinding()
    if InCombatLockdown() then
        return false
    end

    -- Check if we should apply a lure first
    if self:ShouldApplyLure() then
        return self:SetupEasyCastLureBinding()
    else
        return self:SetupEasyCastFishingBinding()
    end
end

-- Handle first right-click (sets up binding for second click)
function CFC:HandleFirstClick()
    if CFC.debug then
        print("|cff00ff00[CFC Debug]|r Easy Cast: HandleFirstClick called")
    end

    -- Check if feature is enabled
    if not self.db or not self.db.profile.settings.easyCast then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: Feature disabled, skipping") end
        return false
    end

    -- Only works when HUD is visible
    if not self.db.profile.hud.show then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: HUD not visible, skipping") end
        return false
    end

    -- Check if we just finished looting (within 2 seconds) - skip some checks for quick re-cast
    local justLooted = (GetTime() - self.easyCastLootClosedTime) < 2.0

    if CFC.debug and justLooted then
        print("|cff00ff00[CFC Debug]|r Easy Cast: Just looted, allowing quick re-cast")
    end

    -- Don't interfere if we're on the bobber (let normal click work)
    -- Skip this check briefly after looting to allow quick re-cast
    if not justLooted and self:IsOnFishingBobber() then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: On bobber, skipping") end
        self:ClearEasyCastBinding()
        return false
    end

    -- Don't interfere if we're on the minimap button
    if self:IsOnMinimapButton() then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: On minimap button, skipping") end
        self:ClearEasyCastBinding()
        return false
    end

    -- Don't cast if loot window is open or has items
    if GetNumLootItems() > 0 then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: Loot window has items, skipping") end
        self:ClearEasyCastBinding()
        return false
    end

    -- Don't cast if LootFrame is visible (catches BoP confirmation scenarios)
    if LootFrame and LootFrame:IsVisible() then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: Loot frame visible, skipping") end
        self:ClearEasyCastBinding()
        return false
    end

    -- Don't cast if a confirmation popup is open (e.g., BoP loot confirmation)
    for i = 1, STATICPOPUP_NUMDIALOGS or 4 do
        local popup = _G["StaticPopup" .. i]
        if popup and popup:IsVisible() then
            if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: Popup dialog open, skipping") end
            self:ClearEasyCastBinding()
            return false
        end
    end

    -- Don't do anything in combat
    if InCombatLockdown() then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: In combat, skipping") end
        return false
    end

    -- Don't set binding if over UI elements (skip this check briefly after looting)
    if not justLooted and self:IsOverUIElement() then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: Over UI element, skipping") end
        self:ClearEasyCastBinding()
        return false
    end

    -- If binding not already active, set it up now
    -- The NEXT right-click will trigger the fishing cast
    if not self.easyCastBindingActive then
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: Setting up binding...") end
        return self:SetupEasyCastBinding()
    else
        if CFC.debug then print("|cff00ff00[CFC Debug]|r Easy Cast: Binding already active") end
    end

    return false
end

-- Initialize Easy Cast system
function CFC:InitializeEasyCast()
    -- Create the secure buttons on load (fishing and lure)
    local fishBtn = self:CreateEasyCastButton()
    local lureBtn = self:CreateEasyCastLureButton()

    if self.debug then
        if fishBtn then
            print("|cff00ff00[CFC Debug]|r Easy Cast fishing button created")
        end
        if lureBtn then
            print("|cff00ff00[CFC Debug]|r Easy Cast lure button created")
        end
    end

    -- Create a frame to detect right-clicks and manage binding timeout
    if not self.easyCastFrame then
        self.easyCastFrame = CreateFrame("Frame", "CFCEasyCastFrame", UIParent)

        local wasRightDown = false
        self.easyCastFrame:SetScript("OnUpdate", function(frame, elapsed)
            -- If in combat, clear binding state and skip processing
            if InCombatLockdown() then
                if CFC.easyCastBindingActive then
                    if CFC.debug then
                        print("|cff00ff00[CFC Debug]|r Easy Cast: In combat, clearing binding state")
                    end
                    -- Can't clear actual binding during combat, but reset state
                    CFC.easyCastBindingActive = false
                    CFC.easyCastBindingSetTime = 0
                    CFC.easyCastLastAction = nil
                end
                return
            end

            -- Expire binding after timeout
            if CFC.easyCastBindingActive and CFC.easyCastBindingSetTime > 0 then
                local timeSinceSet = GetTime() - CFC.easyCastBindingSetTime
                if timeSinceSet > EASYCAST_DOUBLE_CLICK_WINDOW then
                    if CFC.debug then
                        print("|cff00ff00[CFC Debug]|r Easy Cast: Binding expired (timeout)")
                    end
                    CFC:ClearEasyCastBinding()
                end
            end

            -- Only process clicks if Easy Cast is enabled and HUD is visible
            if not CFC.db or not CFC.db.profile.settings.easyCast then
                return
            end
            if not CFC.db.profile.hud.show then
                return
            end

            -- Track right mouse button state
            local isRightDown = IsMouseButtonDown("RightButton")

            if isRightDown and not wasRightDown then
                -- Mouse button just pressed - record the time
                CFC.easyCastMouseDownTime = GetTime()
            elseif wasRightDown and not isRightDown then
                -- Mouse button just released - check if it was a quick tap
                local holdDuration = GetTime() - CFC.easyCastMouseDownTime
                if holdDuration <= EASYCAST_MAX_TAP_DURATION then
                    -- Quick tap detected (not camera movement)
                    if CFC.debug then
                        print("|cff00ff00[CFC Debug]|r Easy Cast: Quick tap detected (" .. string.format("%.2f", holdDuration) .. "s)")
                    end
                    CFC:HandleFirstClick()
                else
                    -- Long hold - was camera movement, clear any binding
                    if CFC.debug then
                        print("|cff00ff00[CFC Debug]|r Easy Cast: Long hold (" .. string.format("%.2f", holdDuration) .. "s) - camera movement, ignoring")
                    end
                    CFC:ClearEasyCastBinding()
                end
            end
            wasRightDown = isRightDown
        end)
    end

    if self.debug then
        print("|cff00ff00[CFC Debug]|r Easy Cast system initialized")
    end
end

