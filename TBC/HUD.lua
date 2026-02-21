-- Classic Fishing Companion - HUD Module
-- Displays on-screen fishing statistics

local addonName, addon = ...

CFC.HUD = {}
local HUDModule = CFC.HUD

local hudFrame = nil

-- Lure bonus mapping (constant table to avoid recreation every update)
local lureBonus = {
    ["Aquadynamic Fish Attractor"] = 100,
    ["Sharpened Fish Hook"] = 100,
    ["Bright Baubles"] = 75,
    ["Flesh Eating Worm"] = 75,
    ["Nightcrawlers"] = 50,
    ["Aquadynamic Fish Lens"] = 50,
    ["Shiny Bauble"] = 25,
}

-- Lure ID to name mapping (constant table)
local lureNames = {
    [6529] = "Shiny Bauble",
    [6530] = "Nightcrawlers",
    [6532] = "Bright Baubles",
    [7307] = "Flesh Eating Worm",
    [6533] = "Aquadynamic Fish Attractor",
    [6811] = "Aquadynamic Fish Lens",
    [34861] = "Sharpened Fish Hook",
}

-- Lure ID to name with bonus (constant table)
local lureNamesWithBonus = {
    [6529] = "Shiny Bauble (+25)",
    [6530] = "Nightcrawlers (+50)",
    [6532] = "Bright Baubles (+75)",
    [7307] = "Flesh Eating Worm (+75)",
    [6533] = "Aquadynamic Fish Attractor (+100)",
    [6811] = "Aquadynamic Fish Lens (+50)",
    [34861] = "Sharpened Fish Hook (+100)",
}

-- Bonus amount to lure name mapping (constant table)
local bonusToLureName = {
    [100] = "Aquadynamic Fish Attractor",
    [75] = "Bright Baubles",
    [50] = "Nightcrawlers",
    [25] = "Shiny Bauble",
}

-- Lure ID to icon mapping (constant table)
local lureIcons = {
    [6529] = "INV_Misc_Orb_03",              -- Shiny Bauble
    [6530] = "INV_Misc_MonsterTail_03",      -- Nightcrawlers
    [6532] = "INV_Misc_Gem_Variety_02",      -- Bright Baubles
    [7307] = "INV_Misc_MonsterTail_03",      -- Flesh Eating Worm
    [6533] = "INV_Misc_Food_26",             -- Aquadynamic Fish Attractor
    [6811] = "INV_Misc_Spyglass_01",         -- Aquadynamic Fish Lens
    [34861] = "INV_Misc_Hook_01",             -- Sharpened Fish Hook
}

-- Initialize HUD
function CFC:InitializeHUD()
    if hudFrame then
        return
    end

    -- Create main HUD frame
    hudFrame = CreateFrame("Frame", "CFCHUDFrame", UIParent)
    hudFrame:SetSize(200, 140)  -- Height will be adjusted by ApplyButtonVisibility
    hudFrame:SetFrameStrata("MEDIUM")
    hudFrame:SetFrameLevel(10)
    hudFrame:SetMovable(true)
    hudFrame:EnableMouse(true)
    hudFrame:RegisterForDrag("LeftButton")
    hudFrame:SetClampedToScreen(true)

    -- Minimal mode background (hidden by default)
    hudFrame.minimalBg = hudFrame:CreateTexture(nil, "BACKGROUND")
    hudFrame.minimalBg:SetAllPoints()
    hudFrame.minimalBg:SetColorTexture(0, 0, 0, 0.25)
    hudFrame.minimalBg:Hide()

    -- Background and Border combined
    hudFrame.border = CreateFrame("Frame", nil, hudFrame, "BackdropTemplate")
    hudFrame.border:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", -3, 3)
    hudFrame.border:SetPoint("BOTTOMRIGHT", hudFrame, "BOTTOMRIGHT", 3, -3)
    hudFrame.border:SetFrameLevel(hudFrame:GetFrameLevel() - 1)
    hudFrame.border:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    hudFrame.border:SetBackdropColor(0, 0, 0, 0.35)
    hudFrame.border:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    -- Title
    hudFrame.title = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hudFrame.title:SetPoint("TOP", hudFrame, "TOP", 0, -4)
    hudFrame.title:SetText("Fishing Stats")
    hudFrame.title:SetTextColor(0.4, 0.8, 1)

    -- Session catches
    hudFrame.sessionText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.sessionText:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 10, -18)
    hudFrame.sessionText:SetJustifyH("LEFT")

    -- Total catches
    hudFrame.totalText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.totalText:SetPoint("TOPLEFT", hudFrame.sessionText, "BOTTOMLEFT", 0, -3)
    hudFrame.totalText:SetJustifyH("LEFT")

    -- Fish per hour
    hudFrame.fphText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.fphText:SetPoint("TOPLEFT", hudFrame.totalText, "BOTTOMLEFT", 0, -3)
    hudFrame.fphText:SetJustifyH("LEFT")

    -- Fishing skill
    hudFrame.skillText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.skillText:SetPoint("TOPLEFT", hudFrame.fphText, "BOTTOMLEFT", 0, -3)
    hudFrame.skillText:SetJustifyH("LEFT")

    -- Current buff
    hudFrame.buffText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.buffText:SetPoint("TOPLEFT", hudFrame.skillText, "BOTTOMLEFT", 0, -3)
    hudFrame.buffText:SetJustifyH("LEFT")
    hudFrame.buffText:SetWidth(180)
    hudFrame.buffText:SetWordWrap(true)

    -- Buff timer
    hudFrame.buffTimerText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.buffTimerText:SetPoint("TOPLEFT", hudFrame.buffText, "BOTTOMLEFT", 0, -3)
    hudFrame.buffTimerText:SetJustifyH("LEFT")

    -- Goals display (up to 3 goals on HUD)
    hudFrame.goalsTitle = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.goalsTitle:SetPoint("TOPLEFT", hudFrame.buffTimerText, "BOTTOMLEFT", 0, -4)
    hudFrame.goalsTitle:SetJustifyH("LEFT")
    hudFrame.goalsTitle:SetText("|cffffd700Goals:|r")
    hudFrame.goalsTitle:Hide()

    hudFrame.goalTexts = {}
    for i = 1, 3 do
        local goalText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        if i == 1 then
            goalText:SetPoint("TOPLEFT", hudFrame.goalsTitle, "BOTTOMLEFT", 2, -2)
        else
            goalText:SetPoint("TOPLEFT", hudFrame.goalTexts[i - 1], "BOTTOMLEFT", 0, -1)
        end
        goalText:SetJustifyH("LEFT")
        goalText:SetWidth(180)
        goalText:Hide()
        hudFrame.goalTexts[i] = goalText
    end

    -- Release notification (shows briefly when catching a release-list fish)
    hudFrame.releaseText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.releaseText:SetPoint("BOTTOM", hudFrame, "TOP", 0, 4)
    hudFrame.releaseText:SetJustifyH("CENTER")
    hudFrame.releaseText:SetTextColor(1, 0.5, 0)  -- Orange
    hudFrame.releaseText:Hide()

    -- Lock/unlock button
    hudFrame.lockIcon = CreateFrame("Button", nil, hudFrame)
    hudFrame.lockIcon:SetSize(16, 16)
    hudFrame.lockIcon:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -5, -5)

    -- Create texture for the button
    hudFrame.lockIcon.texture = hudFrame.lockIcon:CreateTexture(nil, "OVERLAY")
    hudFrame.lockIcon.texture:SetAllPoints()

    -- Click handler to toggle lock
    hudFrame.lockIcon:SetScript("OnClick", function(self)
        HUDModule:ToggleLock()
    end)

    -- Tooltip on hover
    hudFrame.lockIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        if CFC.db.profile.hud.locked then
            GameTooltip:SetText("HUD Locked", 1, 1, 1)
            GameTooltip:AddLine("Click to unlock", 0.8, 0.8, 0.8)
        else
            GameTooltip:SetText("HUD Unlocked", 1, 1, 1)
            GameTooltip:AddLine("Click to lock", 0.8, 0.8, 0.8)
        end
        GameTooltip:Show()
    end)

    hudFrame.lockIcon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Lure button (opens Lure tab in UI)
    hudFrame.applyLureButton = CreateFrame("Button", "CFCLureButton", hudFrame, "UIPanelButtonTemplate")
    hudFrame.applyLureButton:SetSize(88, 22)
    hudFrame.applyLureButton:SetPoint("BOTTOMLEFT", hudFrame, "BOTTOMLEFT", 10, 5)
    hudFrame.applyLureButton:SetText("Lure |TInterface\\Icons\\INV_Misc_Food_26:16|t")

    -- Set button font
    local applyLureFont = hudFrame.applyLureButton:GetFontString()
    applyLureFont:SetFont("Fonts\\FRIZQT__.TTF", 10)

    -- Click handler to open Lure tab
    hudFrame.applyLureButton:SetScript("OnClick", function(self)
        -- Open main UI
        if CFC.ToggleUI then
            -- If UI is hidden, show it
            if not CFC.mainFrame or not CFC.mainFrame:IsShown() then
                CFC:ToggleUI()
            end
        end

        -- Switch to Lure tab
        if CFC.UI and CFC.UI.ShowTab then
            CFC.UI:ShowTab("lures")
        end
    end)

    -- Tooltip for lure button
    hudFrame.applyLureButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")

        local selectedLureID = CFC.db.profile.selectedLure
        if selectedLureID then
            local lureName = lureNamesWithBonus[selectedLureID] or "Unknown Lure"
            GameTooltip:SetText("Lure Manager", 1, 1, 1)
            GameTooltip:AddLine("Selected: " .. lureName, 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Click to open Lure tab", 0.6, 1, 0.6)
        else
            GameTooltip:SetText("Lure Manager", 1, 1, 1)
            GameTooltip:AddLine("No lure selected", 1, 0.5, 0.5)
            GameTooltip:AddLine("Click to open Lure tab", 0.6, 1, 0.6)
        end

        GameTooltip:Show()
    end)

    hudFrame.applyLureButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Gear swap button
    hudFrame.gearSwapButton = CreateFrame("Button", nil, hudFrame, "UIPanelButtonTemplate")
    hudFrame.gearSwapButton:SetSize(88, 22)
    hudFrame.gearSwapButton:SetPoint("LEFT", hudFrame.applyLureButton, "RIGHT", 4, 0)
    hudFrame.gearSwapButton:SetText("Swap Gear")

    -- Set button font
    local buttonFont = hudFrame.gearSwapButton:GetFontString()
    buttonFont:SetFont("Fonts\\FRIZQT__.TTF", 10)

    -- Click handler for gear swap
    hudFrame.gearSwapButton:SetScript("OnClick", function(self)
        CFC:SwapGear()
        HUDModule:Update()  -- Update to reflect new gear mode
    end)

    -- Tooltip for gear swap button
    hudFrame.gearSwapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")

        if CFC:HasGearSets() then
            local currentMode = CFC:GetCurrentGearMode()
            local targetMode = (currentMode == "combat") and "fishing" or "combat"

            GameTooltip:SetText("Swap Gear", 1, 1, 1)
            GameTooltip:AddLine("Current: " .. currentMode, 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Click to switch to " .. targetMode .. " gear", 0.6, 1, 0.6)
        else
            GameTooltip:SetText("Gear Swap Not Configured", 1, 0.5, 0.5)
            GameTooltip:AddLine("1. Equip combat gear", 1, 1, 1)
            GameTooltip:AddLine("2. Type: /cfc savecombat", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("3. Equip fishing gear", 1, 1, 1)
            GameTooltip:AddLine("4. Type: /cfc savefishing", 0.8, 0.8, 0.8)
        end

        GameTooltip:Show()
    end)

    hudFrame.gearSwapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Drag handlers
    hudFrame:SetScript("OnDragStart", function(self)
        if not CFC.db.profile.hud.locked then
            self:StartMoving()
        end
    end)

    hudFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        HUDModule:SavePosition()
    end)

    -- Tooltip on hover
    hudFrame:SetScript("OnEnter", function(self)
        if not CFC.db.profile.hud.locked then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetText("Fishing Stats HUD", 1, 1, 1)
            GameTooltip:AddLine("Drag to move", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Lock in settings to prevent moving", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end
    end)

    hudFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Load saved position
    HUDModule:LoadPosition()

    -- Update lock state
    HUDModule:UpdateLockState()

    -- Initial update
    HUDModule:Update()

    -- Update lure button icon
    HUDModule:UpdateLureButton()

    -- Show or hide based on settings
    if CFC.db.profile.hud.show then
        hudFrame:Show()
    else
        hudFrame:Hide()
    end

    -- Apply appearance settings
    HUDModule:ApplyMinimalMode()
    HUDModule:ApplyScale()
    HUDModule:ApplyButtonVisibility()

    -- Store reference
    CFC.hudFrame = hudFrame

    -- Set up auto-update
    hudFrame:SetScript("OnUpdate", function(self, elapsed)
        self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
        if self.timeSinceLastUpdate >= 1 then  -- Update every second
            HUDModule:Update()
            self.timeSinceLastUpdate = 0
        end
    end)
end

-- Update HUD display
function HUDModule:Update()
    if not hudFrame or not CFC.db then
        return
    end

    -- Session catches
    local sessionCatches = CFC.db.profile.statistics.sessionCatches or 0
    hudFrame.sessionText:SetText("Session: |cff00ff00" .. sessionCatches .. "|r fish")

    -- Total catches
    local totalCatches = CFC.db.profile.statistics.totalCatches or 0
    hudFrame.totalText:SetText("Total: |cff00ff00" .. totalCatches .. "|r fish")

    -- Fish per hour
    local fph = CFC:GetFishPerHour()
    hudFrame.fphText:SetText("Fish/Hour: |cff00ff00" .. string.format("%.1f", fph) .. "|r")

    -- Get current fishing buff once for both skill and buff displays
    local currentBuff = HUDModule:GetCurrentFishingBuff()

    -- Fishing skill (with pole and lure bonuses displayed separately with icons)
    if CFC.db.profile.statistics.currentSkill and CFC.db.profile.statistics.currentSkill > 0 then
        local skillText = "Skill: |cff00ff00" .. CFC.db.profile.statistics.currentSkill .. "/" .. CFC.db.profile.statistics.maxSkill .. "|r"

        -- Get fishing pole inherent bonus
        local poleBonus = HUDModule:GetFishingPoleBonus()
        if poleBonus and poleBonus > 0 then
            -- Get the actual fishing pole icon from equipped item
            local poleIcon = GetInventoryItemTexture("player", 16)
            if not poleIcon then
                poleIcon = "Interface\\Icons\\INV_Fishingpole_02"  -- Fallback icon
            end
            skillText = skillText .. " |cff00ff00+" .. poleBonus .. "|r |T" .. poleIcon .. ":14|t"
        end

        -- Check for active fishing lure buff and add to skill display
        if currentBuff then
            -- Extract buff amount from the lure name
            local buffAmount = string.match(currentBuff.name, "%+(%d+)")
            if not buffAmount then
                -- Try to map known lure names to their bonuses
                buffAmount = lureBonus[currentBuff.name]
            end

            if buffAmount then
                -- Get the actual lure icon from selected lure ID
                local lureIcon = "Interface\\Icons\\INV_Misc_Orb_03"  -- Fallback icon
                local selectedLureID = CFC.db and CFC.db.profile and CFC.db.profile.selectedLure
                if selectedLureID then
                    local lureTexture = GetItemIcon(selectedLureID)
                    if lureTexture then
                        lureIcon = lureTexture
                    end
                end

                skillText = skillText .. " |cffffff00+" .. buffAmount .. "|r |T" .. lureIcon .. ":14|t"
            end
        end

        hudFrame.skillText:SetText(skillText)
    else
        hudFrame.skillText:SetText("Skill: |cffaaaaaa--/--|r")
    end

    -- Current fishing buff (show most recent)
    if currentBuff then
        hudFrame.buffText:SetText("Lure: |cffffff00" .. currentBuff.name .. "|r")

        -- Display buff timer with color coding
        local timeRemaining = currentBuff.expirationSeconds
        local timeColor = "|cff00ff00"  -- Green by default

        -- Color code based on time remaining
        if timeRemaining < 60 then
            timeColor = "|cffff0000"  -- Red if less than 1 minute
        elseif timeRemaining < 120 then
            timeColor = "|cffffff00"  -- Yellow if less than 2 minutes
        end

        local timeText = HUDModule:FormatTime(timeRemaining)
        hudFrame.buffTimerText:SetText("Time Left: " .. timeColor .. timeText .. "|r")
    else
        hudFrame.buffText:SetText("Lure: |cffff0000None|r")
        hudFrame.buffTimerText:SetText("")
    end

    -- Update goals display
    local goalCount = 0
    if CFC.db.profile.goals and #CFC.db.profile.goals > 0 then
        for i, goal in ipairs(CFC.db.profile.goals) do
            if i > 3 then break end
            local current = math.min(goal.sessionCatches or 0, goal.targetCount)
            local icon = ""
            if CFC.db.profile.fishData and CFC.db.profile.fishData[goal.fishName] and CFC.db.profile.fishData[goal.fishName].icon then
                icon = "|T" .. CFC.db.profile.fishData[goal.fishName].icon .. ":12|t "
            end

            local text = icon .. goal.fishName .. ": " .. current .. "/" .. goal.targetCount
            if current >= goal.targetCount then
                text = "|cff00ff00" .. text .. "|r"
            elseif current / goal.targetCount >= 0.75 then
                text = "|cffffff00" .. text .. "|r"
            end

            hudFrame.goalTexts[i]:SetText(text)
            hudFrame.goalTexts[i]:Show()
            goalCount = goalCount + 1
        end
    end

    -- Hide unused goal slots
    for i = goalCount + 1, 3 do
        hudFrame.goalTexts[i]:Hide()
    end

    if goalCount > 0 then
        hudFrame.goalsTitle:Show()
    else
        hudFrame.goalsTitle:Hide()
    end

    -- Update gear swap button
    if hudFrame.gearSwapButton then
        local currentMode = CFC:GetCurrentGearMode()
        if CFC:HasGearSets() then
            -- Show icon of what we're swapping TO (opposite of current mode)
            local targetIcon = (currentMode == "combat") and "|TInterface\\Icons\\Trade_Fishing:16|t" or "|TInterface\\Icons\\INV_Sword_04:16|t"
            hudFrame.gearSwapButton:SetText("Swap to " .. targetIcon)
        else
            hudFrame.gearSwapButton:SetText("|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:16|t Setup")
        end
    end

    -- Recalculate HUD height based on goals + buttons
    local showLure = CFC.db.profile.settings.hudShowLureButton
    local showSwap = CFC.db.profile.settings.hudShowSwapButton
    local anyButtons = showLure or showSwap
    local baseHeight = anyButtons and 140 or 110

    local goalHeight = 0
    if goalCount > 0 then
        goalHeight = 14 + (goalCount * 13)
    end

    hudFrame:SetHeight(baseHeight + goalHeight)
end

-- Update lure button with selected lure icon
function HUDModule:UpdateLureButton()
    if not hudFrame or not hudFrame.applyLureButton or not CFC.db then
        return
    end

    local selectedLureID = CFC.db.profile.selectedLure
    if selectedLureID and lureIcons[selectedLureID] then
        local iconPath = lureIcons[selectedLureID]
        hudFrame.applyLureButton:SetText("Lure |TInterface\\Icons\\" .. iconPath .. ":16|t")
    else
        -- Default icon if no lure selected
        hudFrame.applyLureButton:SetText("Lure |TInterface\\Icons\\INV_Misc_Food_26:16|t")
    end
end

-- Format time in seconds to readable string (MM:SS)
function HUDModule:FormatTime(seconds)
    if seconds <= 0 then
        return "0:00"
    end

    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60

    return string.format("%d:%02d", minutes, secs)
end

-- Reusable tooltip for scanning fishing pole bonus (created once)
local poleBonusTooltip = nil
-- Cache pole bonus by item link to avoid repeated tooltip scans
local cachedPoleLink = nil
local cachedPoleBonus = nil

-- Get fishing pole inherent bonus
-- Returns: bonus amount (number) or nil
function HUDModule:GetFishingPoleBonus()
    local mainHandLink = GetInventoryItemLink("player", 16)
    if not mainHandLink then
        cachedPoleLink = nil
        cachedPoleBonus = nil
        return nil
    end

    -- Return cached value if same pole is equipped
    if mainHandLink == cachedPoleLink then
        return cachedPoleBonus
    end

    -- Different pole equipped — scan tooltip once and cache result
    if not poleBonusTooltip then
        poleBonusTooltip = CreateFrame("GameTooltip", "CFCHUDPoleScanTooltip", nil, "GameTooltipTemplate")
        poleBonusTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end

    poleBonusTooltip:Hide()
    poleBonusTooltip:ClearLines()
    poleBonusTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    poleBonusTooltip:SetInventoryItem("player", 16)
    poleBonusTooltip:Show()

    local result = nil
    local numLines = poleBonusTooltip:NumLines()

    for i = 1, numLines do
        local line = _G["CFCHUDPoleScanTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                local bonus = string.match(text, "Fishing %+(%d+)")
                if not bonus then
                    bonus = string.match(text, "increased by %+(%d+)")
                end
                if not bonus then
                    bonus = string.match(text, "Increases fishing by (%d+)")
                end

                if bonus then
                    result = tonumber(bonus)
                    break
                end
            end
        end
    end

    poleBonusTooltip:Hide()

    -- Only cache if we got a result (tooltip data may not be ready yet after gear swap)
    if result then
        cachedPoleLink = mainHandLink
        cachedPoleBonus = result
    end
    return result
end

-- Session cache for enchant IDs not in the static table (scanned once via tooltip, then cached)
local enchantIdCache = {}
local buffScanTooltip = nil

-- Get current fishing buff (lure)
-- Returns: { name = "Buff Name", expirationSeconds = 123 } or nil
function HUDModule:GetCurrentFishingBuff()
    -- Check for weapon enchant first (lures)
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantId = GetWeaponEnchantInfo()

    if hasMainHandEnchant then
        local expirationSeconds = math.floor(mainHandExpiration / 1000)

        -- First: try direct enchant ID lookup (instant, no tooltip)
        if mainHandEnchantId and CFC.CONSTANTS.LURE_ENCHANT_IDS[mainHandEnchantId] then
            return { name = CFC.CONSTANTS.LURE_ENCHANT_IDS[mainHandEnchantId], expirationSeconds = expirationSeconds }
        end

        -- Second: check session cache (previously scanned unknown enchant IDs)
        if mainHandEnchantId and enchantIdCache[mainHandEnchantId] ~= nil then
            if enchantIdCache[mainHandEnchantId] == false then
                -- Cached as not-a-lure, skip
            else
                return { name = enchantIdCache[mainHandEnchantId], expirationSeconds = expirationSeconds }
            end
        elseif mainHandEnchantId then
            -- Unknown enchant ID — do a ONE-TIME tooltip scan and cache the result
            if not buffScanTooltip then
                buffScanTooltip = CreateFrame("GameTooltip", "CFCHUDBuffScanTooltip", nil, "GameTooltipTemplate")
            end

            buffScanTooltip:Hide()
            buffScanTooltip:ClearLines()
            buffScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            buffScanTooltip:SetInventoryItem("player", 16)
            buffScanTooltip:Show()

            local fishingBonus = nil
            for i = 1, buffScanTooltip:NumLines() do
                local line = _G["CFCHUDBuffScanTooltipTextLeft" .. i]
                if line then
                    local text = line:GetText()
                    if text then
                        local bonus = string.match(text, "Lure.*%(%+(%d+)")
                        if not bonus then
                            bonus = string.match(text, "Fishing Lure %+(%d+)")
                        end
                        if bonus then
                            fishingBonus = tonumber(bonus)
                            break
                        end
                    end
                end
            end

            buffScanTooltip:Hide()

            if fishingBonus then
                -- Prefer selected lure name if bonus matches
                local selectedLureID = CFC.db and CFC.db.profile and CFC.db.profile.selectedLure
                local selectedLureName = selectedLureID and lureNames[selectedLureID]
                local selectedLureBonus = selectedLureID and (
                    selectedLureID == 34861 and 100 or
                    selectedLureID == 6533 and 100 or
                    selectedLureID == 6532 and 75 or
                    selectedLureID == 7307 and 75 or
                    selectedLureID == 6530 and 50 or
                    selectedLureID == 6811 and 50 or
                    selectedLureID == 6529 and 25
                )
                local buffName
                if selectedLureName and selectedLureBonus == fishingBonus then
                    buffName = selectedLureName
                else
                    buffName = bonusToLureName[fishingBonus] or ("Lure (+" .. fishingBonus .. ")")
                end
                enchantIdCache[mainHandEnchantId] = buffName
                if CFC.debug then
                    print("|cffff8800[CFC Debug]|r Cached enchant ID " .. mainHandEnchantId .. " as: " .. buffName)
                end
                return { name = buffName, expirationSeconds = expirationSeconds }
            else
                -- Not a fishing lure (e.g. sharpening stone) — cache as false so we never scan again
                enchantIdCache[mainHandEnchantId] = false
                if CFC.debug then
                    print("|cffff8800[CFC Debug]|r Cached enchant ID " .. mainHandEnchantId .. " as: not a lure")
                end
            end
        end
    end

    -- Check for fishing-related buffs
    local fishingBuffs = {
        "lure", "aquadynamic", "bright baubles", "nightcrawlers",
        "shiny bauble", "flesh eating worm", "attractor", "bait"
    }

    for i = 1, 40 do
        local buffName, _, _, _, _, expirationTime = UnitBuff("player", i)
        if buffName then
            local buffLower = string.lower(buffName)
            for _, buffPattern in ipairs(fishingBuffs) do
                if string.find(buffLower, buffPattern) then
                    -- Calculate remaining time (expirationTime is absolute time, GetTime() is current time)
                    local remainingSeconds = 0
                    if expirationTime and expirationTime > 0 then
                        remainingSeconds = math.floor(expirationTime - GetTime())
                    end
                    return { name = buffName, expirationSeconds = remainingSeconds }
                end
            end
        end
    end

    return nil
end

-- Show release notification on HUD (fades after 3 seconds)
function HUDModule:ShowReleaseNotification(fishName)
    if not hudFrame or not hudFrame:IsShown() then return end

    hudFrame.releaseText:SetText("|cffff8800Release:|r " .. fishName)
    hudFrame.releaseText:SetAlpha(1)
    hudFrame.releaseText:Show()

    -- Cancel any existing fade timer
    if hudFrame.releaseFadeTimer then
        hudFrame.releaseFadeTimer:Cancel()
    end

    -- Fade out after 3 seconds
    hudFrame.releaseFadeTimer = C_Timer.NewTimer(3, function()
        if hudFrame and hudFrame.releaseText then
            hudFrame.releaseText:Hide()
        end
    end)
end

-- Save HUD position
function HUDModule:SavePosition()
    if not hudFrame or not CFC.db then
        return
    end

    local point, relativeTo, relativePoint, xOffset, yOffset = hudFrame:GetPoint()

    CFC.db.profile.hud.point = point
    CFC.db.profile.hud.relativeTo = "UIParent"  -- Always save relative to UIParent
    CFC.db.profile.hud.relativePoint = relativePoint
    CFC.db.profile.hud.xOffset = xOffset
    CFC.db.profile.hud.yOffset = yOffset
end

-- Load HUD position
function HUDModule:LoadPosition()
    if not hudFrame or not CFC.db then
        return
    end

    local point = CFC.db.profile.hud.point or "CENTER"
    local relativePoint = CFC.db.profile.hud.relativePoint or "CENTER"
    local xOffset = CFC.db.profile.hud.xOffset or 0
    local yOffset = CFC.db.profile.hud.yOffset or 200

    hudFrame:ClearAllPoints()
    hudFrame:SetPoint(point, UIParent, relativePoint, xOffset, yOffset)
end

-- Toggle HUD visibility
function HUDModule:ToggleShow()
    if not CFC.db then
        return
    end

    CFC.db.profile.hud.show = not CFC.db.profile.hud.show

    if hudFrame then
        if CFC.db.profile.hud.show then
            hudFrame:Show()
            print("|cff00ff00Classic Fishing Companion:|r Stats HUD shown.")
        else
            hudFrame:Hide()
            print("|cff00ff00Classic Fishing Companion:|r Stats HUD hidden.")
        end
    end
end

-- Toggle HUD lock state
function HUDModule:ToggleLock()
    if not CFC.db then
        return
    end

    CFC.db.profile.hud.locked = not CFC.db.profile.hud.locked

    HUDModule:UpdateLockState()

    if CFC.db.profile.hud.locked then
        print("|cff00ff00Classic Fishing Companion:|r Stats HUD locked.")
    else
        print("|cff00ff00Classic Fishing Companion:|r Stats HUD unlocked. Drag to move.")
    end
end

-- Apply minimal mode (no border, translucent background)
function HUDModule:ApplyMinimalMode()
    if not hudFrame or not CFC.db then
        return
    end

    if CFC.db.profile.settings.minimalHUD then
        hudFrame.border:Hide()
        hudFrame.minimalBg:Show()
    else
        hudFrame.border:Show()
        hudFrame.minimalBg:Hide()
    end
end

-- Apply HUD scale
function HUDModule:ApplyScale()
    if not hudFrame or not CFC.db then
        return
    end

    local scale = CFC.db.profile.hud.scale or 1.0
    hudFrame:SetScale(scale)
end

-- Apply button visibility and resize HUD accordingly
function HUDModule:ApplyButtonVisibility()
    if not hudFrame or not CFC.db then
        return
    end

    local showLure = CFC.db.profile.settings.hudShowLureButton
    local showSwap = CFC.db.profile.settings.hudShowSwapButton
    local anyButtons = showLure or showSwap

    if hudFrame.applyLureButton then
        if showLure then
            hudFrame.applyLureButton:Show()
        else
            hudFrame.applyLureButton:Hide()
        end
    end

    if hudFrame.gearSwapButton then
        if showSwap then
            hudFrame.gearSwapButton:Show()
        else
            hudFrame.gearSwapButton:Hide()
        end
    end

    -- Calculate goal height
    local goalHeight = 0
    if CFC.db.profile.goals then
        local activeGoals = math.min(#CFC.db.profile.goals, 3)
        if activeGoals > 0 then
            goalHeight = 14 + (activeGoals * 13)  -- title + entries
        end
    end

    -- Resize HUD based on button visibility and goals
    local baseHeight = anyButtons and 140 or 110
    hudFrame:SetHeight(baseHeight + goalHeight)
end

-- Update lock state visual
function HUDModule:UpdateLockState()
    if not hudFrame or not CFC.db then
        return
    end

    if CFC.db.profile.hud.locked then
        -- Locked icon (red padlock)
        hudFrame.lockIcon.texture:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
        hudFrame:EnableMouse(false)  -- Disable mouse when locked
    else
        -- Unlocked icon (open padlock)
        hudFrame.lockIcon.texture:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
        hudFrame:EnableMouse(true)  -- Enable mouse when unlocked
    end
end
