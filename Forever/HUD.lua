-- Classic Fishing Companion - HUD Module
-- Displays on-screen fishing statistics

local addonName, addon = ...

-- Classic API names mapped to modern equivalents on Forever (see Compat.lua)
local GetItemCount = CFCCompat.GetItemCount
local GetItemIcon = CFCCompat.GetItemIcon
local UnitBuff = CFCCompat.UnitBuff

-- Gold/bronze styling for Forever (see Theme.lua)
local Theme = CFCTheme

CFC.HUD = {}
local HUDModule = CFC.HUD

local hudFrame = nil
local LURE_BAR_WIDTH = 130
local LURE_BAR_HEIGHT = 11

local CAST_BAR = Theme.CAST_BAR

-- Lure bonus mapping (constant table to avoid recreation every update)
local lureBonus = {
    ["Aquadynamic Fish Attractor"] = 100,
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
}

-- Lure ID to name with bonus (constant table)
local lureNamesWithBonus = {
    [6529] = "Shiny Bauble (+25)",
    [6530] = "Nightcrawlers (+50)",
    [6532] = "Bright Baubles (+75)",
    [7307] = "Flesh Eating Worm (+75)",
    [6533] = "Aquadynamic Fish Attractor (+100)",
    [6811] = "Aquadynamic Fish Lens (+50)",
}

-- Bonus amount to lure name mapping (constant table)
local bonusToLureName = {
    [100] = "Aquadynamic Fish Attractor",
    [75] = "Bright Baubles",
    [50] = "Nightcrawlers",
    [25] = "Shiny Bauble",
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
    hudFrame.border:SetBackdropColor(Theme.Color(Theme.BRONZE_DARK, Theme.HUD_ALPHA))
    hudFrame.border:SetBackdropBorderColor(Theme.Color(Theme.GOLD))

    -- Title
    hudFrame.title = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hudFrame.title:SetPoint("TOP", hudFrame, "TOP", 0, -4)
    hudFrame.title:SetText("Fishing Stats")
    Theme.StyleTitle(hudFrame.title)

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
    -- Seed the single-line baseline used by GetBuffLineExtraHeight (measured on a short,
    -- guaranteed one-line string; recalibrated later from real single-line renders).
    hudFrame.buffText:SetText("Lure")
    hudFrame.buffSingleLineHeight = hudFrame.buffText:GetStringHeight()
    hudFrame.buffText:SetText("")

    -- Buff timer
    hudFrame.buffTimerText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.buffTimerText:SetPoint("TOPLEFT", hudFrame.buffText, "BOTTOMLEFT", 0, -3)
    hudFrame.buffTimerText:SetJustifyH("LEFT")

    -- Lure countdown bar behind the Time Left line, drawn with the game's own
    -- cast bar art. Textures on the HUD itself: a StatusBar child frame would
    -- render on top of the text.
    hudFrame.lureBarBg = hudFrame:CreateTexture(nil, "ARTWORK", nil, 0)
    hudFrame.lureBarBg:SetPoint("LEFT", hudFrame.buffTimerText, "LEFT", -3, 0)
    hudFrame.lureBarBg:SetSize(LURE_BAR_WIDTH, LURE_BAR_HEIGHT)
    hudFrame.lureBarFill = hudFrame:CreateTexture(nil, "ARTWORK", nil, 1)
    hudFrame.lureBarFill:SetPoint("TOPLEFT", hudFrame.lureBarBg, "TOPLEFT")
    hudFrame.lureBarFill:SetPoint("BOTTOMLEFT", hudFrame.lureBarBg, "BOTTOMLEFT")
    hudFrame.lureBarSpark = hudFrame:CreateTexture(nil, "ARTWORK", nil, 2)
    hudFrame.lureBarSpark:SetPoint("CENTER", hudFrame.lureBarFill, "RIGHT")
    hudFrame.lureBarSpark:SetBlendMode("ADD")
    hudFrame.useCastBarArt = Theme.HasCastBarArt()
    if hudFrame.useCastBarArt then
        hudFrame.lureBarBg:SetAtlas(CAST_BAR.background)
        -- The cast bar's own frame art is drawn for a much larger bar and
        -- looks heavy at HUD size; a thin dark edge reads closer to the game's
        hudFrame.lureBarBorder = Theme.AddBorder(hudFrame, hudFrame.lureBarBg, { 0, 0, 0 }, 0.8)
        if Theme.HasAtlas(CAST_BAR.spark) then
            hudFrame.lureBarSpark:SetAtlas(CAST_BAR.spark)
            hudFrame.lureBarSpark:SetSize(3, LURE_BAR_HEIGHT + 2)
            hudFrame.lureBarSpark:SetAlpha(0.8)
        end
    else
        hudFrame.lureBarBg:SetColorTexture(Theme.Color(Theme.BRONZE_DARK, 0.6))
        hudFrame.lureBarBorder = Theme.AddBorder(hudFrame, hudFrame.lureBarBg, Theme.GOLD, 0.5)
    end
    HUDModule:SetLureBar(nil)

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
        HUDModule:ShowTextOnlyHover()
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
        HUDModule:HideTextOnlyHover()
        GameTooltip:Hide()
    end)

    -- Apply lure button (using SecureActionButton for macro execution)
    hudFrame.applyLureButton = CreateFrame("Button", "CFCApplyLureButton", hudFrame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
    Theme.SkinButton(hudFrame.applyLureButton)
    hudFrame.applyLureButton:SetSize(88, 22)
    hudFrame.applyLureButton:SetPoint("BOTTOMLEFT", hudFrame, "BOTTOMLEFT", 10, 5)
    hudFrame.applyLureButton:SetText("Apply Lure")

    -- Set button font
    local applyLureFont = hudFrame.applyLureButton:GetFontString()
    applyLureFont:SetFont("Fonts\\FRIZQT__.TTF", 10)

    -- Set up secure button to execute a macro
    hudFrame.applyLureButton:SetAttribute("type", "macro")

    -- Modern clients only run a secure action on the press that matches the
    -- ActionButtonUseKeyDown CVar (on by default), so listen for both halves
    hudFrame.applyLureButton:RegisterForClicks("AnyUp", "AnyDown")

    -- Function to update the macro based on selected lure
    hudFrame.UpdateApplyLureMacro = function()
        if InCombatLockdown() then
            -- Cannot update secure buttons during combat
            return
        end

        local selectedLureID = CFC.db and CFC.db.profile and CFC.db.profile.selectedLure
        if not selectedLureID then
            hudFrame.applyLureButton:SetAttribute("macrotext", "/print You haven't selected a lure yet!")
            return
        end

        local lureName = lureNames[selectedLureID]
        if lureName then
            -- Create macro text that uses the lure by name
            local macroText = "/use " .. lureName .. "\n/use 16"
            hudFrame.applyLureButton:SetAttribute("macrotext", macroText)
        end
    end

    -- Initial macro setup
    hudFrame.UpdateApplyLureMacro()

    -- PreClick handler to check gear mode and lure availability
    hudFrame.applyLureButton:SetScript("PreClick", function(self, button, down)
        -- Both press halves arrive here; only warn on the one that runs the macro
        if (down and true or false) ~= GetCVarBool("ActionButtonUseKeyDown") then
            return
        end

        local selectedLureID = CFC.db and CFC.db.profile and CFC.db.profile.selectedLure

        -- Check if a lure is selected
        if not selectedLureID then
            print("|cffff0000Classic Fishing Companion:|r No lure selected!")
            print("|cff00ff00Tip:|r Open the Lure tab to select a lure first.")
            return
        end

        -- Check if the lure is in the player's bags
        local lureCount = GetItemCount(selectedLureID)
        if lureCount == 0 then
            local lureName = lureNames[selectedLureID] or "Unknown Lure"
            print("|cffff0000Classic Fishing Companion:|r You don't have any " .. lureName .. " in your bags!")
            return
        end

        -- Check if user has gear sets configured and is in current mode
        if CFC:HasGearSets() then
            local currentMode = CFC:GetCurrentGearMode()
            if currentMode == "current" then
                print("|cffff0000Classic Fishing Companion:|r You're not in fishing gear! Swap to fishing gear first.")
                print("|cff00ff00Tip:|r Click the 'Swap to' button or use /cfc swap")
            end
        end
    end)

    -- Tooltip for apply lure button
    hudFrame.applyLureButton:SetScript("OnEnter", function(self)
        HUDModule:ShowTextOnlyHover()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")

        local selectedLureID = CFC.db.profile.selectedLure
        if selectedLureID then
            local lureName = lureNamesWithBonus[selectedLureID] or "Unknown Lure"
            GameTooltip:SetText("Apply Lure", 1, 1, 1)
            GameTooltip:AddLine("Selected: " .. lureName, 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Click to apply lure to fishing pole", 0.6, 1, 0.6)
        else
            GameTooltip:SetText("No Lure Selected", 1, 0.5, 0.5)
            GameTooltip:AddLine("Open Lure Manager tab to select a lure", 0.8, 0.8, 0.8)
        end

        GameTooltip:Show()
    end)

    hudFrame.applyLureButton:SetScript("OnLeave", function(self)
        HUDModule:HideTextOnlyHover()
        GameTooltip:Hide()
    end)

    -- Gear swap button
    hudFrame.gearSwapButton = CreateFrame("Button", nil, hudFrame, "UIPanelButtonTemplate")
    Theme.SkinButton(hudFrame.gearSwapButton)
    hudFrame.gearSwapButton:SetSize(88, 22)
    hudFrame.gearSwapButton:SetPoint("LEFT", hudFrame.applyLureButton, "RIGHT", 4, 0)
    hudFrame.gearSwapButton:SetText("Swap Gear")

    -- Set button font
    local buttonFont = hudFrame.gearSwapButton:GetFontString()
    buttonFont:SetFont("Fonts\\FRIZQT__.TTF", 10)

    -- Click handler for gear swap
    hudFrame.gearSwapButton:SetScript("OnClick", function(self)
        if not CFC:HasGearSets() then
            CFC:OpenUITab("gearsets")
            return
        end
        CFC:SwapGear()
        HUDModule:Update()  -- Update to reflect new gear mode
    end)

    -- Tooltip for gear swap button
    hudFrame.gearSwapButton:SetScript("OnEnter", function(self)
        HUDModule:ShowTextOnlyHover()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")

        if CFC:HasGearSets() then
            local currentMode = CFC:GetCurrentGearMode()
            local targetMode = (currentMode == "current") and "fishing" or "current"

            GameTooltip:SetText("Swap Gear", 1, 1, 1)
            GameTooltip:AddLine("Current: " .. currentMode, 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Click to switch to " .. targetMode .. " gear", 0.6, 1, 0.6)
        else
            GameTooltip:SetText("Gear Swap Not Configured", 1, 0.5, 0.5)
            GameTooltip:AddLine("Click to open the Gear Sets tab", 1, 1, 1)
            GameTooltip:AddLine("Equip your fishing gear, then click Save Fishing Set", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Normal gear saves to '" .. CFC.NORMAL_SET_NAME .. "' on swap", 0.6, 1, 0.6)
        end

        GameTooltip:Show()
    end)

    hudFrame.gearSwapButton:SetScript("OnLeave", function(self)
        HUDModule:HideTextOnlyHover()
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
        HUDModule:ShowTextOnlyHover()
        if not CFC.db.profile.hud.locked then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetText("Fishing Stats HUD", 1, 1, 1)
            GameTooltip:AddLine("Drag to move", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("Lock in settings to prevent moving", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end
    end)

    hudFrame:SetScript("OnLeave", function(self)
        HUDModule:HideTextOnlyHover()
        GameTooltip:Hide()
    end)

    -- Load saved position
    HUDModule:LoadPosition()

    -- Update lock state
    HUDModule:UpdateLockState()

    -- Initial update
    HUDModule:Update()

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
    HUDModule:UpdateLockState()

    -- Store reference
    CFC.hudFrame = hudFrame

    -- Button visibility changes made during combat wait for it to end
    hudFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" and HUDModule.pendingButtonVisibility then
            HUDModule:ApplyButtonVisibility()
        end
    end)

    -- Set up auto-update
    hudFrame:SetScript("OnUpdate", function(self, elapsed)
        self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
        if self.timeSinceLastUpdate >= 1 then  -- Update every second
            HUDModule:Update()
            self.timeSinceLastUpdate = 0
        end
    end)
end

-- Extra frame height needed when a long lure name (e.g. "Aquadynamic Fish Attractor")
-- wraps the fixed-width buff line onto a second row. buffText auto-grows so the timer,
-- goals and buttons below it shift down, but the frame height formulas assume a single
-- line -- without this the lower rows spill past the border. buffSingleLineHeight is
-- seeded at init and recalibrated only from genuine single-line renders (never from a
-- wrapped one), so the baseline stays correct even if a long lure is active all session.
function HUDModule:GetBuffLineExtraHeight()
    if not hudFrame or not hudFrame.buffText then return 0 end
    local fs = hudFrame.buffText
    local h = fs:GetStringHeight() or 0
    if h <= 0 then return 0 end
    local lines = (fs.GetNumLines and fs:GetNumLines()) or 0
    if lines == 1 then
        hudFrame.buffSingleLineHeight = h  -- true single-line height
    end
    local oneLine = hudFrame.buffSingleLineHeight
    if not oneLine or oneLine <= 0 then oneLine = 12 end
    -- Detect wrap by line count (counts word-wrapped lines) OR by rendered height,
    -- whichever fires -- guards against either signal being stale on a given tick.
    local extraFromLines = (lines and lines > 1) and ((lines - 1) * oneLine) or 0
    local extraFromHeight = (h > oneLine * 1.5) and (h - oneLine) or 0
    return math.max(extraFromLines, extraFromHeight)
end

-- The skill line has no width cap and can exceed the 200px default -- e.g. when the
-- Captain Rumsey +10 badge is appended -- spilling past the right border. Return a width
-- that fits the widest unwrapped line (never below the 200px default). Inline icon
-- textures are included in GetStringWidth, so the badges are accounted for.
function HUDModule:GetRequiredWidth()
    local minWidth = 200
    if not hudFrame or not hudFrame.skillText then return minWidth end
    local skillWidth = hudFrame.skillText:GetStringWidth() or 0
    -- content is inset 10px from the left; leave a matching right margin
    return math.max(minWidth, math.ceil(skillWidth) + 20)
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
        local lureAmount = 0
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
                lureAmount = tonumber(buffAmount) or 0
            end
        end

        -- Other fishing gear (hat, boots, glove enchant): the game's total bonus
        -- minus what the pole and lure badges already show
        local _, _, _, skillModifier = CFCCompat.GetFishingSkill()
        local gearBonus = (skillModifier or 0) - (poleBonus or 0) - lureAmount
        if gearBonus > 0 then
            skillText = skillText .. " |cff00ff00+" .. gearBonus .. "|r |T" .. GEAR_BONUS_ICON .. ":14|t"
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

        -- Over the cast bar art the bar color carries the warning; colored
        -- time text would vanish into the green fill
        if hudFrame.useCastBarArt and not CFC.db.profile.settings.textOnlyHUD then
            timeColor = "|cffffffff"
        end

        local timeText = HUDModule:FormatTime(timeRemaining)
        hudFrame.buffTimerText:SetText("Time Left: " .. timeColor .. timeText .. "|r")
        HUDModule:SetLureBar(currentBuff)
    else
        hudFrame.buffText:SetText("Lure: |cffff0000None|r")
        hudFrame.buffTimerText:SetText("")
        HUDModule:SetLureBar(nil)
    end

    -- Goals sit under the Time Left line, or under the Lure line when there's no lure
    hudFrame.goalsTitle:ClearAllPoints()
    hudFrame.goalsTitle:SetPoint("TOPLEFT", currentBuff and hudFrame.buffTimerText or hudFrame.buffText, "BOTTOMLEFT", 0, -4)

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
            local targetIcon = (currentMode == "current") and "|TInterface\\Icons\\Trade_Fishing:16|t" or "|TInterface\\Icons\\INV_Gauntlets_19:16|t"
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

    -- The base height includes the Time Left line, which only shows with a lure
    if not currentBuff then
        baseHeight = baseHeight - ((hudFrame.buffSingleLineHeight or 12) + 3)
    end

    local goalHeight = 0
    if goalCount > 0 then
        goalHeight = 14 + (goalCount * 13)
    end

    HUDModule:SetHUDSize(baseHeight + goalHeight + HUDModule:GetBuffLineExtraHeight())
end

-- The HUD holds the secure Apply Lure button, so the game blocks resizing it
-- in combat ("Interface action failed because of an AddOn"). Skip it then;
-- the next update after combat applies the size.
function HUDModule:SetHUDSize(height)
    if InCombatLockdown() then
        return
    end
    hudFrame:SetHeight(height)
    hudFrame:SetWidth(HUDModule:GetRequiredWidth())
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

-- Fill the lure countdown bar. The full duration is taken from the largest
-- remaining time seen for this lure, so a fresh application starts it full.
function HUDModule:SetLureBar(buff)
    if not hudFrame or not hudFrame.lureBarBg then
        return
    end

    local show = buff ~= nil and not (CFC.db and CFC.db.profile.settings.textOnlyHUD)
    hudFrame.lureBarBg:SetShown(show)
    hudFrame.lureBarFill:SetShown(show)
    hudFrame.lureBarBorder:SetShown(show)
    hudFrame.lureBarSpark:SetShown(show)
    if not buff then
        hudFrame.lureDuration = nil
        hudFrame.lureName = nil
        return
    end

    local remaining = buff.expirationSeconds or 0
    if buff.name ~= hudFrame.lureName or not hudFrame.lureDuration or remaining > hudFrame.lureDuration then
        hudFrame.lureName = buff.name
        hudFrame.lureDuration = math.max(remaining, 1)
    end
    if not show then
        return
    end

    local pct = math.min(1, remaining / hudFrame.lureDuration)
    local fillWidth = math.max(1, pct * LURE_BAR_WIDTH)
    hudFrame.lureBarFill:SetWidth(fillWidth)

    if not hudFrame.useCastBarArt then
        hudFrame.lureBarSpark:Hide()
        if remaining < 60 then
            Theme.SetBarFill(hudFrame.lureBarFill, 0.8, 0.1, 0.1, 0.55)  -- Red in the last minute
        else
            Theme.SetBarFill(hudFrame.lureBarFill, Theme.Color(Theme.GOLD, 0.55))
        end
        return
    end

    -- Green, then the yellow cast fill under 2 minutes, then red in the last
    -- minute (tinted green if the client has no red cast bar art)
    local atlas = CAST_BAR.channel
    local r, g, b = 1, 1, 1
    if remaining < 60 then
        if Theme.HasAtlas(CAST_BAR.interrupted) then
            atlas = CAST_BAR.interrupted
        else
            r, g, b = 1, 0.25, 0.25
        end
    elseif remaining < 120 and Theme.HasAtlas(CAST_BAR.standard) then
        atlas = CAST_BAR.standard
    end
    Theme.SetCastBarFill(hudFrame.lureBarFill, atlas, fillWidth / LURE_BAR_WIDTH)
    hudFrame.lureBarFill:SetVertexColor(r, g, b, 1)
    hudFrame.lureBarSpark:SetShown(pct > 0 and pct < 1)
end

-- Get current fishing buff (lure)
-- Returns: { name = "Buff Name", expirationSeconds = 123 } or nil
function HUDModule:GetCurrentFishingBuff()
    -- Check for weapon enchant first (lures)
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantId = GetWeaponEnchantInfo()

    if hasMainHandEnchant then
        local expirationSeconds = math.floor(mainHandExpiration / 1000)

        -- Use direct enchant ID lookup (no tooltip scan needed, avoids tooltip flashing)
        if mainHandEnchantId and CFC.CONSTANTS.LURE_ENCHANT_IDS[mainHandEnchantId] then
            return { name = CFC.CONSTANTS.LURE_ENCHANT_IDS[mainHandEnchantId], expirationSeconds = expirationSeconds }
        end

        -- Unknown enchant ID — not a fishing lure (e.g. sharpening stone), skip it
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

    -- The HUD holds a secure button, so the game blocks showing or hiding it in combat
    if InCombatLockdown() then
        CFC:Print("|cffff0000Classic Fishing Companion:|r Can't show or hide the HUD in combat.")
        return
    end

    CFC.db.profile.hud.show = not CFC.db.profile.hud.show

    if hudFrame then
        if CFC.db.profile.hud.show then
            hudFrame:Show()
            CFC:Print("|cff00ff00Classic Fishing Companion:|r Stats HUD shown.")
        else
            hudFrame:Hide()
            CFC:Print("|cff00ff00Classic Fishing Companion:|r Stats HUD hidden.")
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
        CFC:Print("|cff00ff00Classic Fishing Companion:|r Stats HUD locked.")
    else
        CFC:Print("|cff00ff00Classic Fishing Companion:|r Stats HUD unlocked. Drag to move.")
    end
end

-- Apply minimal mode (no border, translucent background)
local function IsTextOnlyMode()
    return CFC.db and CFC.db.profile.settings.textOnlyHUD
end

function HUDModule:ApplyMinimalMode()
    if not hudFrame or not CFC.db then
        return
    end

    if CFC.db.profile.settings.textOnlyHUD then
        hudFrame.border:Hide()
        hudFrame.minimalBg:Hide()
    elseif CFC.db.profile.settings.minimalHUD then
        hudFrame.border:Hide()
        hudFrame.minimalBg:Show()
    else
        hudFrame.border:Show()
        hudFrame.minimalBg:Hide()
    end
end

function HUDModule:ShowTextOnlyHover()
    if IsTextOnlyMode() and hudFrame then
        hudFrame.minimalBg:Show()
        if hudFrame.lockIcon then hudFrame.lockIcon:Show() end
        if CFC.db.profile.settings.hudShowLureButton and hudFrame.applyLureButton and not InCombatLockdown() then
            hudFrame.applyLureButton:Show()
        end
        if CFC.db.profile.settings.hudShowSwapButton and hudFrame.gearSwapButton then
            hudFrame.gearSwapButton:Show()
        end
    end
end

function HUDModule:HideTextOnlyHover()
    if IsTextOnlyMode() and hudFrame then
        C_Timer.After(0, function()
            if hudFrame:IsMouseOver() then return end
            hudFrame.minimalBg:Hide()
            if hudFrame.lockIcon then hudFrame.lockIcon:Hide() end
            if hudFrame.applyLureButton and not InCombatLockdown() then hudFrame.applyLureButton:Hide() end
            if hudFrame.gearSwapButton then hudFrame.gearSwapButton:Hide() end
        end)
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

    -- Showing or hiding the secure Apply Lure button is blocked in combat
    if InCombatLockdown() then
        HUDModule.pendingButtonVisibility = true
        return
    end
    HUDModule.pendingButtonVisibility = false

    local showLure = CFC.db.profile.settings.hudShowLureButton
    local showSwap = CFC.db.profile.settings.hudShowSwapButton

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

    -- In text-only mode, hide buttons and lock icon (shown on hover)
    if IsTextOnlyMode() then
        if hudFrame.lockIcon then hudFrame.lockIcon:Hide() end
        if hudFrame.applyLureButton then hudFrame.applyLureButton:Hide() end
        if hudFrame.gearSwapButton then hudFrame.gearSwapButton:Hide() end
    end

    -- Resize to fit (Update knows about goals and the lure lines)
    HUDModule:Update()
end

-- Update lock state visual
function HUDModule:UpdateLockState()
    if not hudFrame or not CFC.db then
        return
    end

    if CFC.db.profile.hud.locked then
        hudFrame.lockIcon.texture:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
        -- In text-only mode, keep mouse enabled for hover-reveal (drag is still blocked)
        if IsTextOnlyMode() then
            hudFrame:EnableMouse(true)
        else
            hudFrame:EnableMouse(false)
        end
    else
        hudFrame.lockIcon.texture:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
        hudFrame:EnableMouse(true)
    end
end
