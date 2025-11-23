-- Classic Fishing Companion - UI Module
-- Handles the main interface window and displays

local addonName, addon = ...

CFC.UI = {}
local UI = CFC.UI

-- UI State
local mainFrame = nil
local currentTab = "overview"

-- Initialize UI
function CFC:InitializeUI()
    if mainFrame then
        return
    end

    -- Create main frame
    mainFrame = CreateFrame("Frame", "CFCMainFrame", UIParent, "BasicFrameTemplateWithInset")
    mainFrame:SetSize(600, 450)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:Hide()

    -- Title
    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mainFrame.title:SetPoint("TOP", mainFrame, "TOP", 0, -5)
    mainFrame.title:SetText("Classic Fishing Companion")

    -- Close button (use built-in from template)
    mainFrame.CloseButton:SetScript("OnClick", function()
        mainFrame:Hide()
    end)

    -- Create tab buttons
    UI:CreateTabs()

    -- Create content area
    mainFrame.content = CreateFrame("Frame", nil, mainFrame)
    mainFrame.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -70)
    mainFrame.content:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -10, 10)

    -- Create tab content
    UI:CreateOverviewTab()
    UI:CreateFishListTab()
    UI:CreateHistoryTab()
    UI:CreateStatsTab()
    UI:CreateSettingsTab()

    -- Show default tab
    UI:ShowTab("overview")

    CFC.mainFrame = mainFrame
end

-- Create tab buttons
function UI:CreateTabs()
    local tabs = {
        { name = "overview", label = "Overview" },
        { name = "fishlist", label = "Fish List" },
        { name = "history", label = "History" },
        { name = "stats", label = "Statistics" },
        { name = "settings", label = "Settings" },
    }

    local buttonWidth = 110
    local spacing = 3
    local startX = 15

    for i, tab in ipairs(tabs) do
        local button = CreateFrame("Button", "CFCTab" .. i, mainFrame, "UIPanelButtonTemplate")
        button:SetSize(buttonWidth, 25)
        button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", startX + (i - 1) * (buttonWidth + spacing), -35)
        button:SetText(tab.label)

        button:SetScript("OnClick", function()
            UI:ShowTab(tab.name)
        end)

        tab.button = button
        mainFrame["tab" .. tab.name] = button
    end

    mainFrame.tabs = tabs
end

-- Show specific tab
function UI:ShowTab(tabName)
    currentTab = tabName

    -- Update button states
    for _, tab in ipairs(mainFrame.tabs) do
        if tab.name == tabName then
            tab.button:LockHighlight()
        else
            tab.button:UnlockHighlight()
        end
    end

    -- Hide all content frames
    if mainFrame.overviewFrame then mainFrame.overviewFrame:Hide() end
    if mainFrame.fishListFrame then mainFrame.fishListFrame:Hide() end
    if mainFrame.historyFrame then mainFrame.historyFrame:Hide() end
    if mainFrame.statsFrame then mainFrame.statsFrame:Hide() end
    if mainFrame.settingsFrame then mainFrame.settingsFrame:Hide() end

    -- Show selected content
    if tabName == "overview" then
        mainFrame.overviewFrame:Show()
        UI:UpdateOverview()
    elseif tabName == "fishlist" then
        mainFrame.fishListFrame:Show()
        UI:UpdateFishList()
    elseif tabName == "history" then
        mainFrame.historyFrame:Show()
        UI:UpdateHistory()
    elseif tabName == "stats" then
        mainFrame.statsFrame:Show()
        UI:UpdateStats()
    elseif tabName == "settings" then
        mainFrame.settingsFrame:Show()
        UI:UpdateSettings()
    end
end

-- Create Overview Tab
function UI:CreateOverviewTab()
    local frame = CreateFrame("Frame", nil, mainFrame.content)
    frame:SetAllPoints()
    frame:Hide()

    -- Session Stats
    frame.sessionTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.sessionTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    frame.sessionTitle:SetText("Current Session")

    frame.sessionCatches = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.sessionCatches:SetPoint("TOPLEFT", frame.sessionTitle, "BOTTOMLEFT", 0, -10)

    frame.sessionFPH = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.sessionFPH:SetPoint("TOPLEFT", frame.sessionCatches, "BOTTOMLEFT", 0, -5)

    frame.sessionTime = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.sessionTime:SetPoint("TOPLEFT", frame.sessionFPH, "BOTTOMLEFT", 0, -5)

    -- Lifetime Stats
    frame.lifetimeTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.lifetimeTitle:SetPoint("TOPLEFT", frame.sessionTime, "BOTTOMLEFT", 0, -20)
    frame.lifetimeTitle:SetText("Lifetime Statistics")

    frame.totalCatches = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.totalCatches:SetPoint("TOPLEFT", frame.lifetimeTitle, "BOTTOMLEFT", 0, -10)

    frame.uniqueFish = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.uniqueFish:SetPoint("TOPLEFT", frame.totalCatches, "BOTTOMLEFT", 0, -5)

    frame.avgFPH = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.avgFPH:SetPoint("TOPLEFT", frame.uniqueFish, "BOTTOMLEFT", 0, -5)

    frame.totalTime = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.totalTime:SetPoint("TOPLEFT", frame.avgFPH, "BOTTOMLEFT", 0, -5)

    frame.fishingSkill = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.fishingSkill:SetPoint("TOPLEFT", frame.totalTime, "BOTTOMLEFT", 0, -5)

    -- Recent catches
    frame.recentTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.recentTitle:SetPoint("TOPLEFT", frame.fishingSkill, "BOTTOMLEFT", 0, -20)
    frame.recentTitle:SetText("Recent Catches")

    frame.recentList = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.recentList:SetPoint("TOPLEFT", frame.recentTitle, "BOTTOMLEFT", 5, -10)
    frame.recentList:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 10)

    frame.recentContent = CreateFrame("Frame", nil, frame.recentList)
    frame.recentContent:SetSize(530, 1)
    frame.recentList:SetScrollChild(frame.recentContent)

    frame.recentText = frame.recentContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.recentText:SetPoint("TOPLEFT", frame.recentContent, "TOPLEFT", 5, -5)
    frame.recentText:SetJustifyH("LEFT")
    frame.recentText:SetJustifyV("TOP")
    frame.recentText:SetWidth(510)
    frame.recentText:SetNonSpaceWrap(false)
    frame.recentText:SetWordWrap(true)

    mainFrame.overviewFrame = frame
end

-- Update Overview Tab
function UI:UpdateOverview()
    local frame = mainFrame.overviewFrame
    local sessionStats = CFC.Database:GetSessionStats()
    local lifetimeStats = CFC.Database:GetLifetimeStats()

    -- Session stats
    frame.sessionCatches:SetText("Catches: |cff00ff00" .. sessionStats.catches .. "|r")
    frame.sessionFPH:SetText("Fish/Hour: |cff00ff00" .. string.format("%.1f", sessionStats.fishPerHour) .. "|r")
    frame.sessionTime:SetText("Time: |cff00ff00" .. UI:FormatTime(sessionStats.timeSeconds) .. "|r")

    -- Lifetime stats
    frame.totalCatches:SetText("Total Catches: |cff00ff00" .. lifetimeStats.totalCatches .. "|r")
    frame.uniqueFish:SetText("Unique Fish: |cff00ff00" .. lifetimeStats.uniqueFish .. "|r")
    frame.avgFPH:SetText("Avg Fish/Hour: |cff00ff00" .. string.format("%.1f", lifetimeStats.averageFishPerHour) .. "|r")
    frame.totalTime:SetText("Total Time: |cff00ff00" .. UI:FormatTime(lifetimeStats.totalTimeSeconds) .. "|r")

    -- Fishing skill
    if CFC.db.profile.statistics.currentSkill and CFC.db.profile.statistics.currentSkill > 0 then
        frame.fishingSkill:SetText("Fishing Skill: |cff00ff00" .. CFC.db.profile.statistics.currentSkill .. " / " .. CFC.db.profile.statistics.maxSkill .. "|r")
    else
        frame.fishingSkill:SetText("Fishing Skill: |cffaaaaaa--/--|r")
    end

    -- Recent catches
    local recent = CFC.Database:GetRecentCatches(10)
    local recentText = ""

    for _, catch in ipairs(recent) do
        local location = catch.zone
        if catch.subzone and catch.subzone ~= "" then
            location = location .. " - " .. catch.subzone
        end
        recentText = recentText .. catch.itemName .. " - " .. location .. "\n"
    end

    if recentText == "" then
        recentText = "No catches yet. Go fishing!"
    end

    frame.recentText:SetText(recentText)

    -- Update scroll child height based on text content
    local textHeight = frame.recentText:GetStringHeight()
    frame.recentContent:SetHeight(math.max(150, textHeight + 10))
end

-- Create Fish List Tab
function UI:CreateFishListTab()
    local frame = CreateFrame("Frame", nil, mainFrame.content)
    frame:SetAllPoints()
    frame:Hide()

    -- Scroll frame for fish list
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 5)

    frame.scrollChild = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.scrollChild:SetSize(550, 1)
    frame.scrollFrame:SetScrollChild(frame.scrollChild)

    frame.fishEntries = {}

    mainFrame.fishListFrame = frame
end

-- Update Fish List Tab
function UI:UpdateFishList()
    local frame = mainFrame.fishListFrame
    local fishList = CFC.Database:GetFishList()

    -- Clear existing entries
    for _, entry in ipairs(frame.fishEntries) do
        entry:Hide()
    end

    -- Create or update entries
    local yOffset = -5

    for i, fish in ipairs(fishList) do
        local entry = frame.fishEntries[i]

        if not entry then
            entry = CreateFrame("Frame", nil, frame.scrollChild)
            entry:SetSize(530, 30)

            entry.bg = entry:CreateTexture(nil, "BACKGROUND")
            entry.bg:SetAllPoints()
            entry.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)

            entry.name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            entry.name:SetPoint("LEFT", entry, "LEFT", 10, 0)
            entry.name:SetJustifyH("LEFT")
            entry.name:SetWidth(300)

            entry.count = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            entry.count:SetPoint("RIGHT", entry, "RIGHT", -10, 0)

            frame.fishEntries[i] = entry
        end

        entry:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 10, yOffset)
        entry.name:SetText(fish.name)
        entry.count:SetText("|cff00ff00" .. fish.count .. "|r caught")
        entry:Show()

        yOffset = yOffset - 35
    end

    frame.scrollChild:SetHeight(math.abs(yOffset))
end

-- Create History Tab
function UI:CreateHistoryTab()
    local frame = CreateFrame("Frame", nil, mainFrame.content)
    frame:SetAllPoints()
    frame:Hide()

    -- Scroll frame for history
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 5)

    frame.scrollChild = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.scrollChild:SetSize(550, 1)
    frame.scrollFrame:SetScrollChild(frame.scrollChild)

    frame.historyText = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.historyText:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 10, -10)
    frame.historyText:SetJustifyH("LEFT")
    frame.historyText:SetWidth(530)

    mainFrame.historyFrame = frame
end

-- Update History Tab
function UI:UpdateHistory()
    local frame = mainFrame.historyFrame
    local catches = CFC.Database:GetRecentCatches(50)

    local text = ""

    for _, catch in ipairs(catches) do
        local location = catch.zone
        if catch.subzone and catch.subzone ~= "" then
            location = location .. " - " .. catch.subzone
        end

        text = text .. "|cffaaaaaa" .. catch.date .. "|r\n"
        text = text .. "  " .. catch.itemName .. " in " .. location .. "\n\n"
    end

    if text == "" then
        text = "No catches recorded yet."
    end

    frame.historyText:SetText(text)

    -- Update scroll height
    local _, textHeight = frame.historyText:GetFont()
    frame.scrollChild:SetHeight(math.max(350, #catches * 50))
end

-- Create Stats Tab
function UI:CreateStatsTab()
    local frame = CreateFrame("Frame", nil, mainFrame.content)
    frame:SetAllPoints()
    frame:Hide()

    -- Scroll frame for stats
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 5)

    frame.scrollChild = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.scrollChild:SetSize(550, 1)
    frame.scrollFrame:SetScrollChild(frame.scrollChild)

    frame.statsText = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statsText:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 10, -10)
    frame.statsText:SetJustifyH("LEFT")
    frame.statsText:SetWidth(530)

    mainFrame.statsFrame = frame
end

-- Update Stats Tab
function UI:UpdateStats()
    local frame = mainFrame.statsFrame
    local text = ""

    -- Fishing Skill
    text = text .. "|cffffd700Fishing Skill:|r\n"
    if CFC.db.profile.statistics.currentSkill and CFC.db.profile.statistics.currentSkill > 0 then
        text = text .. "Current: |cff00ff00" .. CFC.db.profile.statistics.currentSkill .. " / " .. CFC.db.profile.statistics.maxSkill .. "|r\n"

        -- Recent skill ups
        if CFC.db.profile.skillLevels and #CFC.db.profile.skillLevels > 0 then
            text = text .. "\nRecent Skill Increases:\n"
            local count = 0
            for i = #CFC.db.profile.skillLevels, 1, -1 do
                if count >= 5 then break end
                local skillUp = CFC.db.profile.skillLevels[i]
                text = text .. "  " .. skillUp.oldLevel .. " -> " .. skillUp.newLevel .. " (" .. skillUp.date .. ")\n"
                count = count + 1
            end
        end
    else
        text = text .. "Fishing skill not detected yet\n"
    end

    -- Fishing Poles Used
    text = text .. "\n\n|cffffd700Fishing Poles Used:|r\n"
    if CFC.db.profile.poleUsage then
        local poleList = {}
        for poleName, data in pairs(CFC.db.profile.poleUsage) do
            table.insert(poleList, data)
        end

        -- Sort by usage count
        table.sort(poleList, function(a, b) return a.count > b.count end)

        if #poleList > 0 then
            text = text .. "\n"
            for _, pole in ipairs(poleList) do
                text = text .. pole.name .. ": |cff00ff00" .. pole.count .. " casts|r\n"
            end
        else
            text = text .. "No fishing poles tracked yet\n"
        end
    else
        text = text .. "No fishing poles tracked yet\n"
    end

    -- Fishing Buffs Used
    text = text .. "\n\n|cffffd700Fishing Buffs Used:|r\n"
    if CFC.db.profile.buffUsage then
        local buffList = {}
        for buffName, data in pairs(CFC.db.profile.buffUsage) do
            table.insert(buffList, data)
        end

        -- Sort by usage count
        table.sort(buffList, function(a, b) return a.count > b.count end)

        if #buffList > 0 then
            text = text .. "\n"
            for _, buff in ipairs(buffList) do
                text = text .. buff.name .. ": |cff00ff00" .. buff.count .. " times|r\n"
            end
        else
            text = text .. "No fishing buffs tracked yet\n"
        end
    else
        text = text .. "No fishing buffs tracked yet\n"
    end

    -- Top fish
    text = text .. "\n\n|cffffd700Top 10 Most Caught Fish:|r\n\n"
    local fishList = CFC.Database:GetFishList()

    if #fishList > 0 then
        for i = 1, math.min(10, #fishList) do
            local fish = fishList[i]
            text = text .. i .. ". " .. fish.name .. " - |cff00ff00" .. fish.count .. "|r\n"
        end
    else
        text = text .. "No fish caught yet\n"
    end

    -- Top zones
    text = text .. "\n\n|cffffd700Fishing Zones:|r\n\n"
    local zones = CFC.Database:GetZoneList()

    if #zones > 0 then
        for i = 1, math.min(10, #zones) do
            local zone = zones[i]
            text = text .. i .. ". " .. zone.name .. " - |cff00ff00" .. zone.count .. "|r\n"
        end
    else
        text = text .. "No zones recorded yet\n"
    end

    frame.statsText:SetText(text)

    -- Update scroll height
    frame.scrollChild:SetHeight(math.max(350, 800))
end

-- Create Settings Tab
function UI:CreateSettingsTab()
    local frame = CreateFrame("Frame", nil, mainFrame.content)
    frame:SetAllPoints()
    frame:Hide()

    -- Scroll frame for settings
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 5)

    frame.scrollChild = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.scrollChild:SetSize(530, 500)
    frame.scrollFrame:SetScrollChild(frame.scrollChild)

    -- Settings title
    frame.title = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 5, -5)
    frame.title:SetText("Settings")

    -- Minimap Icon Checkbox
    frame.minimapCheck = CreateFrame("CheckButton", "CFCMinimapCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.minimapCheck:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -20)
    frame.minimapCheck.text = frame.minimapCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.minimapCheck.text:SetPoint("LEFT", frame.minimapCheck, "RIGHT", 5, 0)
    frame.minimapCheck.text:SetText("Show Minimap Icon")

    frame.minimapCheck:SetScript("OnClick", function(self)
        local shouldShow = self:GetChecked()
        CFC.db.profile.minimap.hide = not shouldShow

        if CFC.minimapButton then
            if shouldShow then
                CFC.minimapButton:Show()
                print("|cff00ff00Classic Fishing Companion:|r Minimap button shown.")
            else
                CFC.minimapButton:Hide()
                print("|cff00ff00Classic Fishing Companion:|r Minimap button hidden.")
            end
        end
    end)

    -- Minimap description
    frame.minimapDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.minimapDesc:SetPoint("TOPLEFT", frame.minimapCheck, "BOTTOMLEFT", 25, -5)
    frame.minimapDesc:SetJustifyH("LEFT")
    frame.minimapDesc:SetWidth(500)
    frame.minimapDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.minimapDesc:SetText("Display the fishing companion icon on the minimap for quick access.")

    -- Announce Catches Checkbox
    frame.announceCatchesCheck = CreateFrame("CheckButton", "CFCAnnounceCatchesCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.announceCatchesCheck:SetPoint("TOPLEFT", frame.minimapDesc, "BOTTOMLEFT", -25, -20)
    frame.announceCatchesCheck.text = frame.announceCatchesCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.announceCatchesCheck.text:SetPoint("LEFT", frame.announceCatchesCheck, "RIGHT", 5, 0)
    frame.announceCatchesCheck.text:SetText("Announce Fish Catches")

    frame.announceCatchesCheck:SetScript("OnClick", function(self)
        CFC.db.profile.settings.announceCatches = self:GetChecked()
        if CFC.db.profile.settings.announceCatches then
            print("|cff00ff00Classic Fishing Companion Announcements:|r Fish catch announcements |cff00ff00enabled|r")
        else
            print("|cff00ff00Classic Fishing Companion Announcements:|r Fish catch announcements |cffff0000disabled|r")
        end
    end)

    -- Announce catches description
    frame.announceCatchesDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.announceCatchesDesc:SetPoint("TOPLEFT", frame.announceCatchesCheck, "BOTTOMLEFT", 25, -5)
    frame.announceCatchesDesc:SetJustifyH("LEFT")
    frame.announceCatchesDesc:SetWidth(500)
    frame.announceCatchesDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.announceCatchesDesc:SetText("Display chat messages when you catch fish.")

    -- Announce Buffs Checkbox
    frame.announceBuffsCheck = CreateFrame("CheckButton", "CFCAnnounceBuffsCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.announceBuffsCheck:SetPoint("TOPLEFT", frame.announceCatchesDesc, "BOTTOMLEFT", -25, -20)
    frame.announceBuffsCheck.text = frame.announceBuffsCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.announceBuffsCheck.text:SetPoint("LEFT", frame.announceBuffsCheck, "RIGHT", 5, 0)
    frame.announceBuffsCheck.text:SetText("Warn When Fishing Without Buff")

    frame.announceBuffsCheck:SetScript("OnClick", function(self)
        CFC.db.profile.settings.announceBuffs = self:GetChecked()
        if CFC.db.profile.settings.announceBuffs then
            print("|cff00ff00Classic Fishing Companion:|r Missing buff warnings |cff00ff00enabled|r")
        else
            print("|cff00ff00Classic Fishing Companion:|r Missing buff warnings |cffff0000disabled|r")
        end
    end)

    -- Announce buffs description
    frame.announceBuffsDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.announceBuffsDesc:SetPoint("TOPLEFT", frame.announceBuffsCheck, "BOTTOMLEFT", 25, -5)
    frame.announceBuffsDesc:SetJustifyH("LEFT")
    frame.announceBuffsDesc:SetWidth(500)
    frame.announceBuffsDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.announceBuffsDesc:SetText("Show on-screen warning every 60 seconds when fishing without a lure/buff applied.")

    -- Show Stats HUD Checkbox
    frame.showHUDCheck = CreateFrame("CheckButton", "CFCShowHUDCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.showHUDCheck:SetPoint("TOPLEFT", frame.announceBuffsDesc, "BOTTOMLEFT", -25, -20)
    frame.showHUDCheck.text = frame.showHUDCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.showHUDCheck.text:SetPoint("LEFT", frame.showHUDCheck, "RIGHT", 5, 0)
    frame.showHUDCheck.text:SetText("Show Stats HUD")

    frame.showHUDCheck:SetScript("OnClick", function(self)
        if CFC.HUD and CFC.HUD.ToggleShow then
            CFC.HUD:ToggleShow()
        end
        -- Update lock checkbox state
        if mainFrame.settingsFrame.lockHUDCheck then
            mainFrame.settingsFrame.lockHUDCheck:SetEnabled(self:GetChecked())
        end
    end)

    -- Show HUD description
    frame.showHUDDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.showHUDDesc:SetPoint("TOPLEFT", frame.showHUDCheck, "BOTTOMLEFT", 25, -5)
    frame.showHUDDesc:SetJustifyH("LEFT")
    frame.showHUDDesc:SetWidth(500)
    frame.showHUDDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.showHUDDesc:SetText("Display an on-screen stats window showing session catches, total catches, fish/hour, skill, and current buff.")

    -- Lock Stats HUD Checkbox
    frame.lockHUDCheck = CreateFrame("CheckButton", "CFCLockHUDCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.lockHUDCheck:SetPoint("TOPLEFT", frame.showHUDDesc, "BOTTOMLEFT", -25, -20)
    frame.lockHUDCheck.text = frame.lockHUDCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.lockHUDCheck.text:SetPoint("LEFT", frame.lockHUDCheck, "RIGHT", 5, 0)
    frame.lockHUDCheck.text:SetText("Lock Stats HUD")

    frame.lockHUDCheck:SetScript("OnClick", function(self)
        if CFC.HUD and CFC.HUD.ToggleLock then
            CFC.HUD:ToggleLock()
        end
    end)

    -- Lock HUD description
    frame.lockHUDDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.lockHUDDesc:SetPoint("TOPLEFT", frame.lockHUDCheck, "BOTTOMLEFT", 25, -5)
    frame.lockHUDDesc:SetJustifyH("LEFT")
    frame.lockHUDDesc:SetWidth(500)
    frame.lockHUDDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.lockHUDDesc:SetText("Lock the stats HUD in place to prevent accidental dragging. Unlock to reposition.")

    -- Debug Mode Checkbox
    frame.debugCheck = CreateFrame("CheckButton", "CFCDebugCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.debugCheck:SetPoint("TOPLEFT", frame.lockHUDDesc, "BOTTOMLEFT", -25, -20)
    frame.debugCheck.text = frame.debugCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.debugCheck.text:SetPoint("LEFT", frame.debugCheck, "RIGHT", 5, 0)
    frame.debugCheck.text:SetText("Enable Debug Mode")

    frame.debugCheck:SetScript("OnClick", function(self)
        CFC.debug = self:GetChecked()
        if CFC.debug then
            print("|cff00ff00Classic Fishing Companion:|r Debug mode |cff00ff00enabled|r")
        else
            print("|cff00ff00Classic Fishing Companion:|r Debug mode |cffff0000disabled|r")
        end
    end)

    -- Debug description
    frame.debugDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.debugDesc:SetPoint("TOPLEFT", frame.debugCheck, "BOTTOMLEFT", 25, -5)
    frame.debugDesc:SetJustifyH("LEFT")
    frame.debugDesc:SetWidth(500)
    frame.debugDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.debugDesc:SetText("Shows detailed debug messages in chat for troubleshooting.")

    -- Clear Statistics Button
    frame.clearStatsButton = CreateFrame("Button", "CFCClearStatsButton", frame.scrollChild, "UIPanelButtonTemplate")
    frame.clearStatsButton:SetSize(200, 30)
    frame.clearStatsButton:SetPoint("TOPLEFT", frame.debugDesc, "BOTTOMLEFT", -25, -20)
    frame.clearStatsButton:SetText("Clear All Statistics")

    frame.clearStatsButton:SetScript("OnClick", function(self)
        StaticPopup_Show("CFC_CLEAR_STATS_CONFIRM")
    end)

    -- Clear stats description
    frame.clearStatsDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.clearStatsDesc:SetPoint("TOPLEFT", frame.clearStatsButton, "BOTTOMLEFT", 25, -5)
    frame.clearStatsDesc:SetJustifyH("LEFT")
    frame.clearStatsDesc:SetWidth(500)
    frame.clearStatsDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.clearStatsDesc:SetText("Permanently delete all tracked fishing data including catches, statistics, buff usage, and skill levels. This action cannot be undone!")

    mainFrame.settingsFrame = frame
end

-- Update Settings Tab
function UI:UpdateSettings()
    local frame = mainFrame.settingsFrame

    -- Update debug checkbox
    frame.debugCheck:SetChecked(CFC.debug or false)

    -- Update minimap checkbox (inverted because db stores "hide")
    frame.minimapCheck:SetChecked(not CFC.db.profile.minimap.hide)

    -- Update announcement checkboxes
    frame.announceCatchesCheck:SetChecked(CFC.db.profile.settings.announceCatches)
    frame.announceBuffsCheck:SetChecked(CFC.db.profile.settings.announceBuffs)

    -- Update HUD checkboxes
    frame.showHUDCheck:SetChecked(CFC.db.profile.hud.show)
    frame.lockHUDCheck:SetChecked(CFC.db.profile.hud.locked)
    -- Disable lock checkbox if HUD is hidden
    frame.lockHUDCheck:SetEnabled(CFC.db.profile.hud.show)
end

-- Format time in seconds to readable string
function UI:FormatTime(seconds)
    if seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
    else
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        return string.format("%dh %dm", hours, mins)
    end
end

-- Toggle UI
function CFC:ToggleUI()
    if not mainFrame then
        self:InitializeUI()
    end

    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        UI:ShowTab(currentTab)
    end
end

-- Update UI
function CFC:UpdateUI()
    if not mainFrame or not mainFrame:IsShown() then
        return
    end

    -- Update current tab
    if currentTab == "overview" then
        UI:UpdateOverview()
    elseif currentTab == "fishlist" then
        UI:UpdateFishList()
    elseif currentTab == "history" then
        UI:UpdateHistory()
    elseif currentTab == "stats" then
        UI:UpdateStats()
    elseif currentTab == "settings" then
        UI:UpdateSettings()
    end
end

-- Confirmation dialog for clearing all statistics
StaticPopupDialogs["CFC_CLEAR_STATS_CONFIRM"] = {
    text = "Are you sure you want to clear ALL fishing statistics?\n\nThis will delete:\n• All fish catches\n• Fishing history\n• Buff usage tracking\n• Skill level records\n• Session statistics\n\nThis action CANNOT be undone!",
    button1 = "Yes, Clear Everything",
    button2 = "Cancel",
    OnAccept = function()
        if CFC.db and CFC.db.profile then
            -- Clear all data
            CFC.db.profile.catches = {}
            CFC.db.profile.fishData = {}
            CFC.db.profile.buffUsage = {}
            CFC.db.profile.skillLevels = {}
            CFC.db.profile.statistics.totalCatches = 0
            CFC.db.profile.statistics.sessionCatches = 0
            CFC.db.profile.statistics.totalFishingTime = 0
            CFC.db.profile.statistics.sessionStartTime = time()

            print("|cff00ff00Classic Fishing Companion:|r All statistics have been cleared.")

            -- Update UI if it's open
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
