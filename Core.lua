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

-- Default database structure
local defaults = {
    profile = {
        minimap = {
            hide = false,  -- Show by default
            minimapPos = 220,
        },
        settings = {
            announceBuffs = false,  -- Announce buff tracking in chat
            announceCatches = false,  -- Announce fish catches in chat
        },
        hud = {
            show = true,  -- Show stats HUD by default
            locked = false,  -- HUD is unlocked by default (can be dragged)
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
    }
}

-- Initialize database
function CFC:OnInitialize()
    -- Initialize saved variables
    if not ClassicFishingCompanionDB then
        ClassicFishingCompanionDB = {}
    end

    self.db = ClassicFishingCompanionDB

    -- Set defaults if not exist
    if not self.db.profile then
        self.db.profile = defaults.profile
    end

    -- Ensure all default structures exist
    for key, value in pairs(defaults.profile) do
        if self.db.profile[key] == nil then
            self.db.profile[key] = value
        end
    end

    -- Reset session statistics on login
    self.db.profile.statistics.sessionCatches = 0
    self.db.profile.statistics.sessionStartTime = time()

    print("|cff00ff00Classic Fishing Companion|r loaded! v1.0.0 by Relyk. Type |cffff8800/cfc|r to open or use the minimap button.")
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

    -- Register events
    self:RegisterEvent("CHAT_MSG_LOOT", "OnLootReceived")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEntering")
    self:RegisterEvent("PLAYER_LOGOUT", "OnLogout")
    self:RegisterEvent("CHAT_MSG_SKILL", "OnSkillUpdate")

    -- Use LOOT_OPENED which fires when you loot the bobber
    self:RegisterEvent("LOOT_OPENED", "OnLootOpened")
    self:RegisterEvent("LOOT_CLOSED", "OnLootClosed")

    -- Create frame for fishing bobber tracking
    self.fishingFrame = CreateFrame("Frame")
    self.fishingFrame:SetScript("OnUpdate", function(self, elapsed)
        CFC:CheckFishingState()
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
                print("|cff00ff00Classic Fishing Companion:|r Fishing skill increased to " .. skillLevel .. "!")
            end
            break
        end
    end
end

-- Handle skill updates
function CFC:OnSkillUpdate()
    self:UpdateFishingSkill()
end

-- Check if player has fishing pole equipped and is casting
function CFC:CheckFishingState()
    -- Check if player is channeling (fishing)
    local hasFishingBuff = false
    local channeling = UnitChannelInfo("player")

    if channeling and channeling == "Fishing" then
        hasFishingBuff = true
    end

    -- Also check buffs using texture-based detection (more reliable in Classic)
    if not hasFishingBuff then
        for i = 1, 40 do
            local _, _, texture = UnitBuff("player", i)
            -- Fishing buff texture ID
            if texture and (texture == 136245 or string.find(tostring(texture), "Trade_Fishing")) then
                hasFishingBuff = true
                break
            end
        end
    end

    -- If we have the buff and weren't fishing before, mark start time
    if hasFishingBuff and not self.isFishing then
        self.isFishing = true
        self.fishingStartTime = time()

        -- Detect and track fishing pole buffs (lures, bobbers, etc.)
        self:DetectFishingBuffs()

        if self.debug then
            print("|cffff8800[CFC Debug]|r Started fishing (buff detected)")
        end
    elseif not hasFishingBuff and self.isFishing then
        self.isFishing = false
        -- Update the lastSpellTime when fishing ends (this is when we caught something or it timed out)
        self.lastSpellTime = time()

        if self.debug then
            print("|cffff8800[CFC Debug]|r Stopped fishing (buff ended)")
        end
    end

    -- Periodically check fishing skill (every 30 seconds)
    if time() - self.lastSkillCheck > 30 then
        self:UpdateFishingSkill()
        self.lastSkillCheck = time()
    end
end

-- Detect and track fishing pole
function CFC:DetectFishingPole()
    -- Get the main hand item (fishing pole)
    local itemLink = GetInventoryItemLink("player", 16)

    if itemLink then
        local itemName = GetItemInfo(itemLink)

        if itemName and self.debug then
            print("|cffff8800[CFC Debug]|r Fishing pole detected: " .. itemName)
        end

        if itemName then
            -- Track this pole usage
            if not self.db.profile.poleUsage[itemName] then
                self.db.profile.poleUsage[itemName] = {
                    name = itemName,
                    count = 0,
                    firstUsed = time(),
                    lastUsed = time(),
                }
            end

            -- Only increment if we haven't tracked this pole in the last 2 seconds (avoid double counting)
            local lastTracked = self.db.profile.poleUsage[itemName].lastUsed or 0
            if time() - lastTracked > 2 then
                self.db.profile.poleUsage[itemName].count = self.db.profile.poleUsage[itemName].count + 1
                self.db.profile.poleUsage[itemName].lastUsed = time()

                if self.debug then
                    print("|cffff8800[CFC Debug]|r Tracked fishing pole: " .. itemName .. " (Total: " .. self.db.profile.poleUsage[itemName].count .. ")")
                end
            end

            return itemName
        end
    end

    return nil
end

-- Detect fishing pole buffs (lures, bobbers, etc.)
function CFC:DetectFishingBuffs()
    if self.debug then
        print("|cffff8800[CFC Debug]|r === Checking for fishing buffs ===")
    end

    -- Detect and track fishing pole
    self:DetectFishingPole()

    local buffCount = 0

    -- Check temporary weapon enchantments (lures applied to fishing pole)
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantId, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()

    if hasMainHandEnchant then
        -- Map fishing skill bonus to common lure names
        -- This is the most reliable way since the weapon tooltip doesn't show the item name
        local lureMap = {
            [100] = {
                [600] = "Aquadynamic Fish Attractor",  -- 10 min
                [480] = "Aquadynamic Fish Attractor",  -- 8 min (after some use)
            },
            [75] = {
                [600] = "Bright Baubles",  -- 10 min
                [480] = "Bright Baubles",  -- 8 min (after some use)
            },
            [50] = {
                [600] = "Nightcrawlers",  -- 10 min
                [480] = "Nightcrawlers",
            },
            [25] = {
                [600] = "Shiny Bauble",  -- 10 min
                [480] = "Shiny Bauble",
                [300] = "Shiny Bauble",  -- 5 min
            },
        }

        -- Try to get the fishing bonus from tooltip
        local fishingBonus = nil
        local duration = mainHandExpiration / 1000  -- Convert to seconds

        local tooltip = CreateFrame("GameTooltip", "CFCBuffScanTooltip", nil, "GameTooltipTemplate")
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetInventoryItem("player", 16)

        for i = 1, tooltip:NumLines() do
            local line = _G["CFCBuffScanTooltipTextLeft" .. i]
            if line then
                local text = line:GetText()
                if text then
                    -- Look for "Fishing Lure +XX" pattern
                    local bonus = string.match(text, "Fishing Lure %+(%d+)")
                    if bonus then
                        fishingBonus = tonumber(bonus)
                        break
                    end
                end
            end
        end

        tooltip:Hide()

        -- Determine lure name based on bonus and duration
        local enchantName = nil
        if fishingBonus and lureMap[fishingBonus] then
            -- Round duration to nearest common value
            local roundedDuration = 600  -- Default to 10 min
            if duration < 540 then
                roundedDuration = 480  -- 8 min
            elseif duration < 420 then
                roundedDuration = 300  -- 5 min
            end

            enchantName = lureMap[fishingBonus][roundedDuration] or lureMap[fishingBonus][600]
        end

        -- Fallback to generic name if we can't identify the specific lure
        if not enchantName and fishingBonus then
            enchantName = "Unknown Lure (+" .. fishingBonus .. ")"
        end

        if enchantName then
            if self.debug then
                print("|cffff8800[CFC Debug]|r Found weapon enchant: " .. enchantName .. " (bonus: " .. tostring(fishingBonus) .. ", duration: " .. string.format("%.0f", duration) .. "s)")
            end

            -- Track this buff usage
            if not self.db.profile.buffUsage[enchantName] then
                self.db.profile.buffUsage[enchantName] = {
                    name = enchantName,
                    count = 0,
                    firstUsed = time(),
                    lastUsed = time(),
                }
            end

            -- Only increment if we haven't tracked this buff in the last 2 seconds (avoid double counting)
            local lastTracked = self.db.profile.buffUsage[enchantName].lastUsed or 0
            if time() - lastTracked > 2 then
                self.db.profile.buffUsage[enchantName].count = self.db.profile.buffUsage[enchantName].count + 1
                self.db.profile.buffUsage[enchantName].lastUsed = time()

                -- Only announce if setting is enabled
                if self.db.profile.settings.announceBuffs then
                    print("|cff00ff00Classic Fishing Companion Announcements:|r Tracked fishing buff: " .. enchantName .. " (Total: " .. self.db.profile.buffUsage[enchantName].count .. ")")
                end
            end
        end
    end

    -- Also check player buffs (some items give actual buffs)
    local fishingBuffs = {
        ["lure"] = true,
        ["aquadynamic"] = true,
        ["bright baubles"] = true,
        ["nightcrawlers"] = true,
        ["shiny bauble"] = true,
        ["flesh eating worm"] = true,
        ["attractor"] = true,
        ["bait"] = true,
    }

    for i = 1, 40 do
        local buffName, _, icon, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        if buffName then
            buffCount = buffCount + 1
            local buffLower = string.lower(buffName)

            if self.debug then
                print("|cffff8800[CFC Debug]|r Player Buff " .. i .. ": " .. buffName)
            end

            -- Check if it's a fishing-related buff
            for buffPattern, _ in pairs(fishingBuffs) do
                if string.find(buffLower, buffPattern) then
                    -- Track this buff usage
                    if not self.db.profile.buffUsage[buffName] then
                        self.db.profile.buffUsage[buffName] = {
                            name = buffName,
                            count = 0,
                            firstUsed = time(),
                            lastUsed = time(),
                        }
                    end

                    local lastTracked = self.db.profile.buffUsage[buffName].lastUsed or 0
                    if time() - lastTracked > 2 then
                        self.db.profile.buffUsage[buffName].count = self.db.profile.buffUsage[buffName].count + 1
                        self.db.profile.buffUsage[buffName].lastUsed = time()

                        -- Only announce if setting is enabled
                        if self.db.profile.settings.announceBuffs then
                            print("|cff00ff00Classic Fishing Companion Announcements:|r Tracked fishing buff: " .. buffName .. " (Total: " .. self.db.profile.buffUsage[buffName].count .. ")")
                        end
                    end
                    break
                end
            end
        end
    end

    if self.debug then
        print("|cffff8800[CFC Debug]|r Total player buffs found: " .. buffCount)
        print("|cffff8800[CFC Debug]|r Main hand enchant: " .. tostring(hasMainHandEnchant))
    end
end

-- Handle loot window opening
function CFC:OnLootOpened()
    local timeSinceFishing = time() - self.lastSpellTime
    if self.isFishing or timeSinceFishing < 10 then
        self.lastLootWasFishing = true

        if self.debug then
            print("|cffff8800[CFC Debug]|r Loot opened while fishing (time since cast: " .. timeSinceFishing .. "s)")
        end
    else
        self.lastLootWasFishing = false
        if self.debug then
            print("|cffff8800[CFC Debug]|r Loot opened but NOT fishing (time since cast: " .. timeSinceFishing .. "s)")
        end
    end
end

-- Handle loot window closing
function CFC:OnLootClosed()
    -- Don't reset immediately - CHAT_MSG_LOOT may fire after loot window closes
    -- Just leave the flag set, it will be reset on next LOOT_OPENED or when fishing stops
end

-- Handle logout
function CFC:OnLogout()
    -- Save session data
    local sessionTime = time() - self.db.profile.statistics.sessionStartTime
    self.db.profile.statistics.totalFishingTime = self.db.profile.statistics.totalFishingTime + sessionTime
end

-- Check if an item is a fish (Trade Goods -> Fish subtype)
function CFC:IsItemFish(itemLink)
    if not itemLink then return false end

    -- Get item info
    local itemName, _, _, _, _, itemType, itemSubType = GetItemInfo(itemLink)

    if self.debug then
        print("|cffff8800[CFC Debug]|r Item type: " .. tostring(itemType) .. ", subtype: " .. tostring(itemSubType))
    end

    -- Check if it's a Trade Good with Fish subtype
    -- In Classic WoW, fish are categorized as "Trade Goods" with subtype "Trade Goods" or might have other indicators
    -- We'll use a simple name-based check as fallback
    if itemName then
        local nameLower = string.lower(itemName)
        -- Common fish keywords in Classic WoW
        if string.find(nameLower, "fish") or
           string.find(nameLower, "salmon") or
           string.find(nameLower, "bass") or
           string.find(nameLower, "grouper") or
           string.find(nameLower, "snapper") or
           string.find(nameLower, "rockscale") or
           string.find(nameLower, "trout") or
           string.find(nameLower, "catfish") or
           string.find(nameLower, "eel") or
           string.find(nameLower, "lobster") or
           string.find(nameLower, "clam") or
           string.find(nameLower, "murloc") or
           string.find(nameLower, "firefin") then
            return true
        end
    end

    return false
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
    -- Track all items if we were recently fishing (within last 10 seconds) or loot window opened while fishing
    local timeSinceFishing = time() - self.lastSpellTime
    local wasFishing = self.lastLootWasFishing or self.isFishing or timeSinceFishing < 10

    -- Debug output
    if self.debug then
        print("|cffff8800[CFC Debug]|r Found item: " .. itemName)
        print("|cffff8800[CFC Debug]|r Was fishing: " .. tostring(wasFishing))
        print("|cffff8800[CFC Debug]|r lastLootWasFishing: " .. tostring(self.lastLootWasFishing))
        print("|cffff8800[CFC Debug]|r isFishing: " .. tostring(self.isFishing))
        print("|cffff8800[CFC Debug]|r Time since last cast: " .. timeSinceFishing .. "s")
    end

    if wasFishing then
        self:RecordFishCatch(itemName)
    end
end

-- Record a fish catch
function CFC:RecordFishCatch(itemName)
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

    -- Update fish-specific data
    if not self.db.profile.fishData[itemName] then
        self.db.profile.fishData[itemName] = {
            count = 0,
            firstCatch = timestamp,
            lastCatch = timestamp,
            locations = {},
        }
    end

    local fishData = self.db.profile.fishData[itemName]
    fishData.count = fishData.count + 1
    fishData.lastCatch = timestamp

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

