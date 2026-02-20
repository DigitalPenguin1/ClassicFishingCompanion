-- Classic Fishing Companion - Minimap Button Module
-- Handles minimap button for easy access

local addonName, addon = ...

CFC.Minimap = {}
local MinimapModule = CFC.Minimap

local minimapButton = nil

-- Initialize minimap button
function CFC:InitializeMinimap()
    if minimapButton then
        return
    end

    -- Wrap in pcall to catch errors
    local success, err = pcall(function()
        -- Create minimap button
        minimapButton = CreateFrame("Button", "CFCMinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:SetMovable(true)
    minimapButton:EnableMouse(true)
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Background behind icon (matches logo background #36281F)
    minimapButton.bg = minimapButton:CreateTexture(nil, "BACKGROUND")
    minimapButton.bg:SetSize(20, 20)
    minimapButton.bg:SetPoint("CENTER", 0, 0)
    minimapButton.bg:SetColorTexture(0.212, 0.157, 0.122, 1)

    -- Button icon (custom addon icon)
    minimapButton.icon = minimapButton:CreateTexture(nil, "ARTWORK")
    minimapButton.icon:SetSize(20, 20)
    minimapButton.icon:SetPoint("CENTER", 0, 0)
    minimapButton.icon:SetTexture("Interface\\AddOns\\ClassicFishingCompanion\\Textures\\icon")
    minimapButton.icon:SetTexCoord(0, 1, 0, 1)

    -- Button border
    minimapButton.border = minimapButton:CreateTexture(nil, "OVERLAY")
    minimapButton.border:SetSize(53, 53)
    minimapButton.border:SetPoint("TOPLEFT")
    minimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    -- Highlight
    minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Click handler
    minimapButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            CFC:ToggleUI()
        elseif button == "RightButton" then
            -- Toggle HUD visibility on right-click
            if CFC.HUD and CFC.HUD.ToggleShow then
                local swapBlocked = false
                -- Check if auto-swap is enabled
                if CFC.db and CFC.db.profile and CFC.db.profile.settings and CFC.db.profile.settings.autoSwapOnHUD then
                    -- Check if gear sets are configured
                    local gearSets = CFC.db.profile.gearSets
                    local hasFishingGear = gearSets and gearSets.fishing and next(gearSets.fishing)
                    local hasCombatGear = gearSets and gearSets.combat and next(gearSets.combat)

                    if not hasFishingGear or not hasCombatGear then
                        -- Warn if gear sets not configured
                        print("|cffff8800[CFC]|r Auto-swap enabled but gear sets not configured. Please save both fishing and combat gear sets in the Gear Sets tab.")
                    else
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
                    end
                end
                if not swapBlocked then
                    CFC.HUD:ToggleShow()
                end
            end
        end
    end)

    -- Drag handler
    minimapButton:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self.dragging = true
    end)

    minimapButton:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self.dragging = false
        MinimapModule:SavePosition()
    end)

    -- Update position while dragging
    minimapButton:SetScript("OnUpdate", function(self)
        if self.dragging then
            MinimapModule:UpdatePosition()
        end
    end)

    -- Tooltip
    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Classic Fishing Companion", 1, 1, 1)
        GameTooltip:AddLine("Left-click to open", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Right-click to toggle HUD", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag to move", 0.8, 0.8, 0.8)

        -- Add quick stats
        if CFC.db and CFC.db.profile then
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine("Session: " .. CFC.db.profile.statistics.sessionCatches .. " fish", 0, 1, 0)
            local fph = CFC:GetFishPerHour()
            GameTooltip:AddLine("Fish/Hour: " .. string.format("%.1f", fph), 0, 1, 0)

            -- Show fishing skill if available
            if CFC.db.profile.statistics.currentSkill and CFC.db.profile.statistics.currentSkill > 0 then
                GameTooltip:AddLine("Skill: " .. CFC.db.profile.statistics.currentSkill .. "/" .. CFC.db.profile.statistics.maxSkill, 0.5, 0.8, 1)
            end
        end

        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Set initial position
    MinimapModule:LoadPosition()

        -- Make sure button is visible unless explicitly hidden
        if not CFC.db.profile.minimap.hide then
            minimapButton:Show()
        else
            minimapButton:Hide()
        end

        CFC.minimapButton = minimapButton
    end)

    if not success then
        print("|cffff0000[CFC Error]|r Failed to create minimap button: " .. tostring(err))
    end
end

-- Update button position around minimap
function MinimapModule:UpdatePosition()
    if not minimapButton then
        return
    end

    local mx, my = GetCursorPosition()
    local px, py = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()

    mx, my = mx / scale, my / scale

    local angle = math.atan2(my - py, mx - px)
    local x, y = math.cos(angle), math.sin(angle)
    local dist = ((Minimap:GetWidth() / 2) + 10)

    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x * dist, y * dist)

    -- Store angle for saving
    CFC.db.profile.minimap.minimapPos = math.deg(angle)
end

-- Save button position
function MinimapModule:SavePosition()
    if not CFC.db or not CFC.db.profile then
        return
    end

    -- Position is saved in UpdatePosition
end

-- Load button position
function MinimapModule:LoadPosition()
    if not minimapButton or not CFC.db or not CFC.db.profile then
        return
    end

    local angle = math.rad(CFC.db.profile.minimap.minimapPos or 220)
    local x = math.cos(angle)
    local y = math.sin(angle)
    local dist = ((Minimap:GetWidth() / 2) + 10)

    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x * dist, y * dist)
end

-- Show context menu
function MinimapModule:ShowMenu()
    local menu = {
        {
            text = "Classic Fishing Companion",
            isTitle = true,
            notCheckable = true,
        },
        {
            text = "Open",
            func = function()
                CFC:ToggleUI()
            end,
            notCheckable = true,
        },
        {
            text = "Show Stats",
            func = function()
                CFC:PrintStats()
            end,
            notCheckable = true,
        },
        {
            text = "Show Stats HUD",
            func = function()
                if CFC.HUD and CFC.HUD.ToggleShow then
                    CFC.HUD:ToggleShow()
                end
            end,
            checked = CFC.db.profile.hud.show,
        },
        {
            text = "Hide Minimap Button",
            func = function()
                MinimapModule:ToggleButton()
            end,
            checked = CFC.db.profile.minimap.hide,
        },
        {
            text = "Reset Data",
            func = function()
                StaticPopup_Show("CFC_RESET_CONFIRM")
            end,
            notCheckable = true,
        },
        {
            text = "Cancel",
            func = function() end,
            notCheckable = true,
        },
    }

    -- Use EasyMenu if available
    if EasyMenu then
        EasyMenu(menu, CreateFrame("Frame", "CFCMinimapMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0, "MENU")
    end
end

-- Toggle minimap button visibility
function MinimapModule:ToggleButton()
    if not CFC.db or not CFC.db.profile then
        return
    end

    CFC.db.profile.minimap.hide = not CFC.db.profile.minimap.hide

    if CFC.db.profile.minimap.hide then
        minimapButton:Hide()
        print("|cff00ff00Classic Fishing Companion:|r Minimap button hidden. Use /cfc to open.")
    else
        minimapButton:Show()
        print("|cff00ff00Classic Fishing Companion:|r Minimap button shown.")
    end
end

-- Confirmation dialog for reset
StaticPopupDialogs["CFC_RESET_CONFIRM"] = {
    text = "Are you sure you want to reset all Classic Fishing Companion data? This cannot be undone!",
    button1 = "Yes, Reset",
    button2 = "Cancel",
    OnAccept = function()
        if CFC.db and CFC.db.profile then
            -- Clear all fishing data
            CFC.db.profile.catches = {}
            CFC.db.profile.fishData = {}
            CFC.db.profile.sessions = {}
            CFC.db.profile.buffUsage = {}  -- Clear lure usage statistics
            CFC.db.profile.poleUsage = {}  -- Clear fishing pole statistics
            CFC.db.profile.skillLevels = {}  -- Clear skill level history

            -- Reset statistics (but keep current fishing skill levels)
            CFC.db.profile.statistics.totalCatches = 0
            CFC.db.profile.statistics.sessionCatches = 0
            CFC.db.profile.statistics.totalFishingTime = 0
            CFC.db.profile.statistics.sessionStartTime = time()

            print("|cff00ff00Classic Fishing Companion:|r All data has been reset.")

            if CFC.UpdateUI then
                CFC:UpdateUI()
            end
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
