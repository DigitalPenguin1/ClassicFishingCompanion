-- Classic Fishing Companion - HUD Module
-- Displays on-screen fishing statistics

local addonName, addon = ...

CFC.HUD = {}
local HUDModule = CFC.HUD

local hudFrame = nil

-- Initialize HUD
function CFC:InitializeHUD()
    if hudFrame then
        return
    end

    -- Create main HUD frame
    hudFrame = CreateFrame("Frame", "CFCHUDFrame", UIParent)
    hudFrame:SetSize(200, 140)
    hudFrame:SetFrameStrata("MEDIUM")
    hudFrame:SetFrameLevel(10)
    hudFrame:SetMovable(true)
    hudFrame:EnableMouse(true)
    hudFrame:RegisterForDrag("LeftButton")
    hudFrame:SetClampedToScreen(true)

    -- Background
    hudFrame.bg = hudFrame:CreateTexture(nil, "BACKGROUND")
    hudFrame.bg:SetAllPoints()
    hudFrame.bg:SetColorTexture(0, 0, 0, 0.7)

    -- Border
    hudFrame.border = CreateFrame("Frame", nil, hudFrame, "BackdropTemplate")
    hudFrame.border:SetAllPoints()
    hudFrame.border:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    -- Title
    hudFrame.title = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hudFrame.title:SetPoint("TOP", hudFrame, "TOP", 0, -8)
    hudFrame.title:SetText("Fishing Stats")
    hudFrame.title:SetTextColor(0.4, 0.8, 1)

    -- Session catches
    hudFrame.sessionText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hudFrame.sessionText:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 10, -25)
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

    -- Lock/unlock indicator
    hudFrame.lockIcon = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hudFrame.lockIcon:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -5, -5)
    hudFrame.lockIcon:SetTextColor(1, 1, 0)

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

    -- Show or hide based on settings
    if CFC.db.profile.hud.show then
        hudFrame:Show()
    else
        hudFrame:Hide()
    end

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

    -- Fishing skill
    if CFC.db.profile.statistics.currentSkill and CFC.db.profile.statistics.currentSkill > 0 then
        hudFrame.skillText:SetText("Skill: |cff00ff00" .. CFC.db.profile.statistics.currentSkill .. "/" .. CFC.db.profile.statistics.maxSkill .. "|r")
    else
        hudFrame.skillText:SetText("Skill: |cffaaaaaa--/--|r")
    end

    -- Current fishing buff (show most recent)
    local currentBuff = HUDModule:GetCurrentFishingBuff()
    if currentBuff then
        hudFrame.buffText:SetText("Buff: |cffffff00" .. currentBuff.name .. "|r")

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
        hudFrame.buffText:SetText("Buff: |cffaaaaaa None|r")
        hudFrame.buffTimerText:SetText("")
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

-- Get current fishing buff
-- Returns: { name = "Buff Name", expirationSeconds = 123 } or nil
function HUDModule:GetCurrentFishingBuff()
    -- Check for weapon enchant first (lures)
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantId = GetWeaponEnchantInfo()

    if hasMainHandEnchant then
        -- Try to detect lure from tooltip
        local fishingBonus = nil
        local tooltip = CreateFrame("GameTooltip", "CFCHUDBuffScanTooltip", nil, "GameTooltipTemplate")
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetInventoryItem("player", 16)

        for i = 1, tooltip:NumLines() do
            local line = _G["CFCHUDBuffScanTooltipTextLeft" .. i]
            if line then
                local text = line:GetText()
                if text then
                    local bonus = string.match(text, "Fishing Lure %+(%d+)")
                    if bonus then
                        fishingBonus = tonumber(bonus)
                        break
                    end
                end
            end
        end

        tooltip:Hide()

        if fishingBonus then
            -- Map common bonuses to lure names
            local lureNames = {
                [100] = "Aquadynamic Fish Attractor",
                [75] = "Bright Baubles",
                [50] = "Nightcrawlers",
                [25] = "Shiny Bauble",
            }

            local buffName = lureNames[fishingBonus] or ("Lure (+" .. fishingBonus .. ")")
            local expirationSeconds = math.floor(mainHandExpiration / 1000)  -- Convert milliseconds to seconds
            return { name = buffName, expirationSeconds = expirationSeconds }
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

-- Update lock state visual
function HUDModule:UpdateLockState()
    if not hudFrame or not CFC.db then
        return
    end

    if CFC.db.profile.hud.locked then
        hudFrame.lockIcon:SetText("[L]")
        hudFrame.lockIcon:SetTextColor(1, 0, 0)  -- Red for locked
        hudFrame:EnableMouse(false)  -- Disable mouse when locked
    else
        hudFrame.lockIcon:SetText("[U]")
        hudFrame.lockIcon:SetTextColor(0, 1, 0)  -- Green for unlocked
        hudFrame:EnableMouse(true)  -- Enable mouse when unlocked
    end
end
