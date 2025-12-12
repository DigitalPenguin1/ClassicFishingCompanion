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
    UI:CreateGearSetsTab()
    UI:CreateLuresTab()
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
        { name = "gearsets", label = "Gear Sets" },
        { name = "lures", label = "Lure" },
        { name = "settings", label = "Settings" },
    }

    local buttonWidth = 80
    local spacing = 3
    local totalWidth = (#tabs * buttonWidth) + ((#tabs - 1) * spacing)
    local startX = (600 - totalWidth) / 2  -- Center buttons (600 is frame width)

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
    if mainFrame.gearsets then mainFrame.gearsets:Hide() end
    if mainFrame.luresFrame then mainFrame.luresFrame:Hide() end
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
    elseif tabName == "gearsets" then
        mainFrame.gearsets:Show()
        UI:UpdateGearSetsTab()
    elseif tabName == "lures" then
        mainFrame.luresFrame:Show()
        UI:UpdateLuresTab()
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
        local itemName = catch.itemName or "Unknown"
        local coloredName = CFC:GetColoredItemName(itemName)
        local location = catch.zone or "Unknown Zone"
        if catch.subzone and catch.subzone ~= "" then
            location = location .. " - " .. catch.subzone
        end
        recentText = recentText .. coloredName .. " - " .. location .. "\n"
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

    -- Add "Refresh Icons" button at the top
    local refreshButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    refreshButton:SetSize(120, 25)
    refreshButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -5)
    refreshButton:SetText("Refresh Icons")
    refreshButton:SetNormalFontObject("GameFontNormal")
    refreshButton:SetHighlightFontObject("GameFontHighlight")
    refreshButton:SetScript("OnClick", function()
        CFC:RefreshFishIcons()
    end)

    -- Tooltip for the button
    refreshButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Refresh Fish Icons", 1, 1, 1)
        GameTooltip:AddLine("Scans your bags for fish and updates their icons in the list.", nil, nil, nil, true)
        GameTooltip:AddLine("Works for fish currently in your bags.", 0.5, 0.5, 0.5, true)
        GameTooltip:Show()
    end)
    refreshButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    frame.refreshButton = refreshButton

    -- Scroll frame for fish list
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -35)
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

    -- Pre-query all items to trigger caching
    for _, fish in ipairs(fishList) do
        GetItemInfo(fish.name)
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

            -- Icon texture
            entry.icon = entry:CreateTexture(nil, "ARTWORK")
            entry.icon:SetSize(24, 24)
            entry.icon:SetPoint("LEFT", entry, "LEFT", 10, 0)

            entry.name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            entry.name:SetPoint("LEFT", entry.icon, "RIGHT", 8, 0)
            entry.name:SetJustifyH("LEFT")
            entry.name:SetWidth(280)

            entry.count = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            entry.count:SetPoint("RIGHT", entry, "RIGHT", -10, 0)

            -- Store fish name for later reference
            entry.fishName = nil

            frame.fishEntries[i] = entry
        end

        entry:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 10, yOffset)
        entry.fishName = fish.name

        -- Try to get icon from cached data first (saved when fish was caught)
        local itemTexture = nil
        if CFC.db.profile.fishData[fish.name] and CFC.db.profile.fishData[fish.name].icon then
            itemTexture = CFC.db.profile.fishData[fish.name].icon
            if CFC.debug then
                print("|cffff8800[CFC Debug]|r Fish List - Item: " .. fish.name)
                print("|cffff8800[CFC Debug]|r   Using cached icon: " .. tostring(itemTexture))
            end
        end

        -- If no cached icon, try GetItemInfo with item name
        if not itemTexture then
            local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, texture = GetItemInfo(fish.name)
            itemTexture = texture

            -- Debug logging for icon loading
            if CFC.debug then
                print("|cffff8800[CFC Debug]|r Fish List - Item: " .. fish.name)
                print("|cffff8800[CFC Debug]|r   GetItemInfo returned: " .. tostring(itemName ~= nil))
                print("|cffff8800[CFC Debug]|r   Texture from GetItemInfo: " .. tostring(itemTexture))
            end

            -- If GetItemInfo gave us an itemLink, try using that for better icon results
            if not itemTexture and itemLink then
                local _, _, _, _, _, _, _, _, _, linkTexture = GetItemInfo(itemLink)
                if linkTexture then
                    itemTexture = linkTexture
                    if CFC.debug then
                        print("|cffff8800[CFC Debug]|r   Got texture from itemLink: " .. tostring(linkTexture))
                    end
                end
            end

            -- Cache the icon if we got it
            if itemTexture and CFC.db.profile.fishData[fish.name] then
                CFC.db.profile.fishData[fish.name].icon = itemTexture
                if CFC.debug then
                    print("|cffff8800[CFC Debug]|r   Cached icon for future use")
                end
            end
        end

        -- If still no texture, try to find the item in bags
        if not itemTexture then
            if CFC.debug then
                print("|cffff8800[CFC Debug]|r   Searching bags for item...")
            end

            -- Try to find item in player's bags
            local success, err = pcall(function()
                for bag = 0, 4 do
                    -- Use C_Container API for Anniversary Classic
                    local numSlots = 0
                    if C_Container and C_Container.GetContainerNumSlots then
                        numSlots = C_Container.GetContainerNumSlots(bag) or 0
                    elseif GetContainerNumSlots then
                        numSlots = GetContainerNumSlots(bag) or 0
                    end

                    for slot = 1, numSlots do
                        -- Get container item link
                        local containerItemLink = nil
                        if C_Container and C_Container.GetContainerItemLink then
                            containerItemLink = C_Container.GetContainerItemLink(bag, slot)
                        elseif GetContainerItemLink then
                            containerItemLink = GetContainerItemLink(bag, slot)
                        end

                        if containerItemLink then
                            local bagItemName = GetItemInfo(containerItemLink)
                            if bagItemName == fish.name then
                                -- Found the item, get its texture from the bag slot
                                local bagItemTexture = nil
                                if C_Container and C_Container.GetContainerItemInfo then
                                    local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                                    if itemInfo and itemInfo.iconFileID then
                                        bagItemTexture = itemInfo.iconFileID
                                    end
                                elseif GetContainerItemInfo then
                                    bagItemTexture = GetContainerItemInfo(bag, slot)
                                end

                                if bagItemTexture then
                                    itemTexture = bagItemTexture

                                    -- Cache the icon for future use
                                    if CFC.db.profile.fishData[fish.name] then
                                        CFC.db.profile.fishData[fish.name].icon = bagItemTexture
                                    end

                                    if CFC.debug then
                                        print("|cffff8800[CFC Debug]|r   Found in bag " .. bag .. " slot " .. slot .. ", texture: " .. tostring(itemTexture))
                                        print("|cffff8800[CFC Debug]|r   Cached icon for future use")
                                    end
                                    return  -- Exit function early when found
                                end
                            end
                        end
                    end
                end
            end)

            if not success and CFC.debug then
                print("|cffff8800[CFC Debug]|r   Error scanning bags: " .. tostring(err))
            end

            -- If still no texture, use default fish icon
            if not itemTexture then
                itemTexture = "Interface\\Icons\\INV_Misc_Fish_02"
                if CFC.debug then
                    print("|cffff8800[CFC Debug]|r   Item not in bags, using default fish icon")
                end
            end
        end

        -- Set icon (itemTexture is guaranteed to exist at this point)
        entry.icon:SetTexture(itemTexture)
        if CFC.debug then
            print("|cffff8800[CFC Debug]|r   ✓ Icon set to: " .. tostring(itemTexture))
        end
        entry.icon:Show()

        local coloredName = CFC:GetColoredItemName(fish.name)
        entry.name:SetText(coloredName)
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
        local itemName = catch.itemName or "Unknown"
        local coloredName = CFC:GetColoredItemName(itemName)
        local location = catch.zone or "Unknown Zone"
        local date = catch.date or "Unknown Date"
        if catch.subzone and catch.subzone ~= "" then
            location = location .. " - " .. catch.subzone
        end

        text = text .. "|cffaaaaaa" .. date .. "|r\n"
        text = text .. "  " .. coloredName .. " in " .. location .. "\n\n"
    end

    if text == "" then
        text = "No catches recorded yet."
    end

    frame.historyText:SetText(text)

    -- Update scroll height
    local _, textHeight = frame.historyText:GetFont()
    frame.scrollChild:SetHeight(math.max(350, #catches * 50))
end

-- Create a horizontal bar for graphs
function UI:CreateBar(parent, index)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetSize(350, 18)

    -- Label (day name or week label)
    bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.label:SetPoint("LEFT", bar, "LEFT", 0, 0)
    bar.label:SetWidth(80)
    bar.label:SetJustifyH("LEFT")

    -- Bar background
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetPoint("LEFT", bar.label, "RIGHT", 5, 0)
    bar.bg:SetSize(200, 14)
    bar.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

    -- Bar fill
    bar.fill = bar:CreateTexture(nil, "ARTWORK")
    bar.fill:SetPoint("LEFT", bar.bg, "LEFT", 0, 0)
    bar.fill:SetHeight(14)
    bar.fill:SetColorTexture(0.0, 0.8, 0.4, 1.0)  -- Green fill

    -- Value text
    bar.value = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.value:SetPoint("LEFT", bar.bg, "RIGHT", 5, 0)
    bar.value:SetWidth(50)
    bar.value:SetJustifyH("LEFT")

    return bar
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

    -- Create bar graph containers
    frame.dailyBars = {}
    frame.weeklyBars = {}
    frame.hourlyBars = {}

    -- Hourly bars (top 5) with header
    frame.hourlyContainer = CreateFrame("Frame", nil, frame.scrollChild)
    frame.hourlyContainer:SetSize(400, 160)
    frame.hourlyHeader = frame.hourlyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hourlyHeader:SetPoint("TOPLEFT", frame.hourlyContainer, "TOPLEFT", 0, 0)
    frame.hourlyHeader:SetTextColor(1, 0.82, 0, 1)  -- Gold
    frame.hourlySubheader = frame.hourlyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.hourlySubheader:SetPoint("TOPLEFT", frame.hourlyHeader, "BOTTOMLEFT", 0, -2)
    for i = 1, 5 do
        local bar = UI:CreateBar(frame.hourlyContainer, i)
        bar:SetPoint("TOPLEFT", frame.hourlyContainer, "TOPLEFT", 0, -35 - ((i-1) * 20))
        bar.fill:SetColorTexture(1.0, 0.6, 0.0, 1.0)  -- Orange fill for hourly
        frame.hourlyBars[i] = bar
    end

    -- Daily bars (7 days) with header
    frame.dailyContainer = CreateFrame("Frame", nil, frame.scrollChild)
    frame.dailyContainer:SetSize(400, 200)
    frame.dailyHeader = frame.dailyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.dailyHeader:SetPoint("TOPLEFT", frame.dailyContainer, "TOPLEFT", 0, 0)
    frame.dailyHeader:SetTextColor(1, 0.82, 0, 1)  -- Gold
    frame.dailySubheader = frame.dailyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.dailySubheader:SetPoint("TOPLEFT", frame.dailyHeader, "BOTTOMLEFT", 0, -2)
    for i = 1, 7 do
        local bar = UI:CreateBar(frame.dailyContainer, i)
        bar:SetPoint("TOPLEFT", frame.dailyContainer, "TOPLEFT", 0, -35 - ((i-1) * 20))
        frame.dailyBars[i] = bar
    end

    -- Weekly bars (4 weeks) with header
    frame.weeklyContainer = CreateFrame("Frame", nil, frame.scrollChild)
    frame.weeklyContainer:SetSize(400, 140)
    frame.weeklyHeader = frame.weeklyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.weeklyHeader:SetPoint("TOPLEFT", frame.weeklyContainer, "TOPLEFT", 0, 0)
    frame.weeklyHeader:SetTextColor(1, 0.82, 0, 1)  -- Gold
    frame.weeklySubheader = frame.weeklyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.weeklySubheader:SetPoint("TOPLEFT", frame.weeklyHeader, "BOTTOMLEFT", 0, -2)
    for i = 1, 4 do
        local bar = UI:CreateBar(frame.weeklyContainer, i)
        bar:SetPoint("TOPLEFT", frame.weeklyContainer, "TOPLEFT", 0, -35 - ((i-1) * 20))
        bar.fill:SetColorTexture(0.2, 0.6, 1.0, 1.0)  -- Blue fill for weekly
        frame.weeklyBars[i] = bar
    end

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

    -- Get stats data
    local hourlyStats = CFC.Database:GetHourlyStats()
    local weeklyStats = CFC.Database:GetWeeklyStats()
    local monthlyStats = CFC.Database:GetMonthlyStats()

    -- Set up hourly header
    frame.hourlyHeader:SetText("Hourly Productivity (Top 5 Hours):")
    if hourlyStats.totalCatches > 0 then
        frame.hourlySubheader:SetText("Peak Period: |cff00ff00" .. hourlyStats.peakPeriod .. "|r")
    else
        frame.hourlySubheader:SetText("Peak Period: |cffaaaaaa-----|r")
    end

    -- Set up daily header
    frame.dailyHeader:SetText("Weekly Breakdown (Last 7 Days):")
    if weeklyStats.totalCatches > 0 then
        frame.dailySubheader:SetText("Total: |cff00ff00" .. weeklyStats.totalCatches .. "|r fish  |  Avg: |cff00ff00" .. string.format("%.1f", weeklyStats.averagePerDay) .. "|r/day")
    else
        frame.dailySubheader:SetText("No catches in the last 7 days")
    end

    -- Set up weekly header
    frame.weeklyHeader:SetText("Monthly Breakdown (Last 4 Weeks):")
    if monthlyStats.totalCatches > 0 then
        frame.weeklySubheader:SetText("Total: |cff00ff00" .. monthlyStats.totalCatches .. "|r fish  |  Avg: |cff00ff00" .. string.format("%.1f", monthlyStats.averagePerWeek) .. "|r/week")
    else
        frame.weeklySubheader:SetText("No catches in the last 4 weeks")
    end

    -- Update hourly bar graph
    local sortedHours = {}
    for h = 0, 23 do
        table.insert(sortedHours, hourlyStats.hours[h])
    end
    table.sort(sortedHours, function(a, b) return a.catches > b.catches end)

    local maxHourlyCatches = sortedHours[1] and sortedHours[1].catches or 1
    for i = 1, 5 do
        local bar = frame.hourlyBars[i]
        local hour = sortedHours[i]
        if hour and hour.catches > 0 then
            bar.label:SetText(hour.label)
            bar.value:SetText(hour.catches)
            local fillWidth = (hour.catches / math.max(maxHourlyCatches, 1)) * 200
            bar.fill:SetWidth(math.max(fillWidth, 1))
            bar:Show()
        else
            bar:Hide()
        end
    end

    -- Update daily bar graph
    local maxDailyCatches = weeklyStats.bestDayCount or 1
    for i, day in ipairs(weeklyStats.days) do
        local bar = frame.dailyBars[i]
        if bar then
            local dayLabel = day.daysAgo == 0 and "Today" or (day.daysAgo == 1 and "Yesterday" or day.name)
            bar.label:SetText(dayLabel)
            bar.value:SetText(day.catches)
            local fillWidth = (day.catches / math.max(maxDailyCatches, 1)) * 200
            bar.fill:SetWidth(math.max(fillWidth, 1))
            bar:Show()
        end
    end

    -- Update weekly bar graph
    local maxWeeklyCatches = monthlyStats.bestWeekCount or 1
    for i, week in ipairs(monthlyStats.weeks) do
        local bar = frame.weeklyBars[i]
        if bar then
            bar.label:SetText(week.label)
            bar.value:SetText(week.catches)
            local fillWidth = (week.catches / math.max(maxWeeklyCatches, 1)) * 200
            bar.fill:SetWidth(math.max(fillWidth, 1))
            bar:Show()
        end
    end

    -- Position the graph containers (clear previous points first)
    frame.hourlyContainer:ClearAllPoints()
    frame.dailyContainer:ClearAllPoints()
    frame.weeklyContainer:ClearAllPoints()

    frame.hourlyContainer:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 20, -150)
    frame.dailyContainer:SetPoint("TOPLEFT", frame.hourlyContainer, "BOTTOMLEFT", 0, -10)
    frame.weeklyContainer:SetPoint("TOPLEFT", frame.dailyContainer, "BOTTOMLEFT", 0, -10)

    -- Fishing Poles Used (positioned after all graph containers)
    text = text .. "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cffffd700Fishing Poles Used:|r\n"
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
                text = text .. pole.name .. ": |cff00ff00" .. pole.count .. " catches|r\n"
            end
        else
            text = text .. "No fishing poles tracked yet\n"
        end
    else
        text = text .. "No fishing poles tracked yet\n"
    end

    -- Fishing Lures Used
    text = text .. "\n\n|cffffd700Fishing Lures Used:|r\n"
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
            local coloredName = CFC:GetColoredItemName(fish.name)
            text = text .. i .. ". " .. coloredName .. " - |cff00ff00" .. fish.count .. "|r\n"
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

    -- Update scroll height (increased for new stats sections)
    frame.scrollChild:SetHeight(math.max(350, 1400))
end

-- Create Gear Sets Tab
function UI:CreateGearSetsTab()
    local frame = CreateFrame("Frame", nil, mainFrame.content)
    frame:SetAllPoints()
    frame:Hide()

    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    frame.title:SetText("Gear Sets Manager")

    -- Description
    frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
    frame.desc:SetWidth(560)
    frame.desc:SetJustifyH("LEFT")
    frame.desc:SetText("Save and manage your fishing and combat gear sets. Equip the gear you want to save, then click the Save button.")

    -- Combat Gear Section
    local combatY = -80
    frame.combatTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.combatTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, combatY)
    frame.combatTitle:SetText("|cffff8000Combat Gear Set|r")

    -- Combat gear display
    frame.combatGearText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.combatGearText:SetPoint("TOPLEFT", frame.combatTitle, "BOTTOMLEFT", 0, -10)
    frame.combatGearText:SetWidth(260)
    frame.combatGearText:SetHeight(150)
    frame.combatGearText:SetJustifyH("LEFT")
    frame.combatGearText:SetJustifyV("TOP")

    -- Combat button
    frame.saveCombatBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.saveCombatBtn:SetSize(150, 25)
    frame.saveCombatBtn:SetPoint("TOPLEFT", frame.combatGearText, "BOTTOMLEFT", 0, -10)
    frame.saveCombatBtn:SetText("Save Combat Gear")
    frame.saveCombatBtn:SetScript("OnClick", function()
        CFC:SaveGearSet("combat")
        UI:UpdateGearSetsTab()
        print("|cff00ff00Classic Fishing Companion:|r Combat gear set saved!")
    end)

    -- Fishing Gear Section
    frame.fishingTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.fishingTitle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, combatY)
    frame.fishingTitle:SetText("|cff00ccffFishing Gear Set|r")

    -- Fishing gear display
    frame.fishingGearText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.fishingGearText:SetPoint("TOPRIGHT", frame.fishingTitle, "BOTTOMRIGHT", 0, -10)
    frame.fishingGearText:SetWidth(260)
    frame.fishingGearText:SetHeight(150)
    frame.fishingGearText:SetJustifyH("RIGHT")
    frame.fishingGearText:SetJustifyV("TOP")

    -- Fishing button
    frame.saveFishingBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.saveFishingBtn:SetSize(150, 25)
    frame.saveFishingBtn:SetPoint("TOPRIGHT", frame.fishingGearText, "BOTTOMRIGHT", 0, -10)
    frame.saveFishingBtn:SetText("Save Fishing Gear")
    frame.saveFishingBtn:SetScript("OnClick", function()
        CFC:SaveGearSet("fishing")
        UI:UpdateGearSetsTab()
        print("|cff00ff00Classic Fishing Companion:|r Fishing gear set saved!")
    end)

    -- Swap Gear Button (big button at bottom)
    frame.swapGearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.swapGearBtn:SetSize(200, 35)
    frame.swapGearBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
    frame.swapGearBtn:SetText("|TInterface\\Icons\\INV_Sword_04:16|t Swap to Fishing Gear")

    local swapFont = frame.swapGearBtn:GetFontString()
    swapFont:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    frame.swapGearBtn:SetScript("OnClick", function()
        CFC:SwapGear()
        UI:UpdateGearSetsTab()
    end)

    -- Current Mode Display
    frame.currentModeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.currentModeText:SetPoint("BOTTOM", frame.swapGearBtn, "TOP", 0, 10)

    -- Clear All Gear Sets Button
    frame.clearSetsBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.clearSetsBtn:SetSize(140, 25)
    frame.clearSetsBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    frame.clearSetsBtn:SetText("Clear All Gear Sets")

    local clearFont = frame.clearSetsBtn:GetFontString()
    clearFont:SetFont("Fonts\\FRIZQT__.TTF", 10)

    frame.clearSetsBtn:SetScript("OnClick", function()
        StaticPopup_Show("CFC_CLEAR_GEAR_SETS")
    end)

    -- Store reference
    mainFrame.gearsets = frame

    -- Initial update
    UI:UpdateGearSetsTab()
end

-- Update Gear Sets Tab
function UI:UpdateGearSetsTab()
    local frame = mainFrame.gearsets
    if not frame or not frame:IsVisible() then
        return
    end

    -- Get gear sets
    local combatGear = CFC.db.profile.gearSets.combat or {}
    local fishingGear = CFC.db.profile.gearSets.fishing or {}
    local currentMode = CFC:GetCurrentGearMode()

    -- Update combat gear display
    local combatText = ""
    if next(combatGear) then
        combatText = "|cff00ff00|TInterface\\RaidFrame\\ReadyCheck-Ready:16|t Gear Set Saved|r\n\n"
        local slotNames = {
            [1] = "Head", [2] = "Neck", [3] = "Shoulder",
            [5] = "Chest", [6] = "Waist", [7] = "Legs", [8] = "Feet",
            [9] = "Wrist", [10] = "Hands", [15] = "Back",
            [16] = "Main Hand", [17] = "Off Hand",
        }
        local count = 0
        for slotID, itemLink in pairs(combatGear) do
            if slotNames[slotID] and count < 8 then
                local itemName = string.match(itemLink, "%[(.-)%]")
                combatText = combatText .. slotNames[slotID] .. ": " .. (itemName or "Unknown") .. "\n"
                count = count + 1
            end
        end
        if count >= 8 then
            combatText = combatText .. "... and more"
        end
    else
        combatText = "|cffff0000No combat gear saved|r\n\nEquip your combat gear,\nthen click Save Combat Gear."
    end
    frame.combatGearText:SetText(combatText)

    -- Update fishing gear display
    local fishingText = ""
    if next(fishingGear) then
        fishingText = "|cff00ff00|TInterface\\RaidFrame\\ReadyCheck-Ready:16|t Gear Set Saved|r\n\n"
        local slotNames = {
            [1] = "Head", [2] = "Neck", [3] = "Shoulder",
            [5] = "Chest", [6] = "Waist", [7] = "Legs", [8] = "Feet",
            [9] = "Wrist", [10] = "Hands", [15] = "Back",
            [16] = "Main Hand", [17] = "Off Hand",
        }
        local count = 0
        for slotID, itemLink in pairs(fishingGear) do
            if slotNames[slotID] and count < 8 then
                local itemName = string.match(itemLink, "%[(.-)%]")
                fishingText = fishingText .. slotNames[slotID] .. ": " .. (itemName or "Unknown") .. "\n"
                count = count + 1
            end
        end
        if count >= 8 then
            fishingText = fishingText .. "... and more"
        end
    else
        fishingText = "|cffff0000No fishing gear saved|r\n\nEquip your fishing gear,\nthen click Save Fishing Gear."
    end
    frame.fishingGearText:SetText(fishingText)

    -- Update current mode
    local modeIcon = (currentMode == "fishing") and "|TInterface\\Icons\\Trade_Fishing:16|t" or "|TInterface\\Icons\\INV_Sword_04:16|t"
    frame.currentModeText:SetText("Current Mode: " .. modeIcon .. " " .. currentMode:upper())

    -- Update swap button
    local targetMode = (currentMode == "combat") and "fishing" or "combat"
    local btnIcon = (currentMode == "combat") and "|TInterface\\Icons\\Trade_Fishing:16|t" or "|TInterface\\Icons\\INV_Sword_04:16|t"
    frame.swapGearBtn:SetText(btnIcon .. " Swap to " .. targetMode:sub(1,1):upper() .. targetMode:sub(2) .. " Gear")

    -- Disable swap if gear sets not configured
    if CFC:HasGearSets() then
        frame.swapGearBtn:Enable()
    else
        frame.swapGearBtn:Disable()
    end
end

-- Create Lures Tab
function UI:CreateLuresTab()
    local frame = CreateFrame("Frame", nil, mainFrame.content)
    frame:SetAllPoints()
    frame:Hide()

    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    frame.title:SetText("Lure")

    -- Description
    frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
    frame.desc:SetWidth(560)
    frame.desc:SetJustifyH("LEFT")
    frame.desc:SetText("Select your preferred fishing lure to apply quickly with the HUD button.")

    -- Selected lure display
    frame.selectedLureLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.selectedLureLabel:SetPoint("TOPLEFT", frame.desc, "BOTTOMLEFT", 0, -20)
    frame.selectedLureLabel:SetText("Selected Lure:")

    frame.selectedLure = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.selectedLure:SetPoint("TOPLEFT", frame.selectedLureLabel, "BOTTOMLEFT", 0, -10)
    frame.selectedLure:SetText("|cffaaaaaa(None selected)|r")

    -- Clear selection button (positioned next to label)
    frame.clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.clearBtn:SetSize(100, 22)
    frame.clearBtn:SetPoint("LEFT", frame.selectedLureLabel, "RIGHT", 10, 0)
    frame.clearBtn:SetText("Clear")
    frame.clearBtn:SetScript("OnClick", function()
        CFC.db.profile.selectedLure = nil
        UI:UpdateLuresTab()

        -- Update the Apply Lure button macro on the HUD
        if CFC.hudFrame and CFC.hudFrame.UpdateApplyLureMacro then
            CFC.hudFrame.UpdateApplyLureMacro()
        end
    end)

    -- Lure selection buttons
    local lureData = {
        { name = "Shiny Bauble", id = 6529, bonus = 25, icon = "INV_Misc_Orb_03" },
        { name = "Nightcrawlers", id = 6530, bonus = 50, icon = "INV_Misc_MonsterTail_03" },
        { name = "Aquadynamic Fish Lens", id = 6811, bonus = 50, icon = "INV_Misc_Spyglass_01", faction = "Alliance" },
        { name = "Bright Baubles", id = 6532, bonus = 75, icon = "INV_Misc_Gem_Variety_02" },
        { name = "Flesh Eating Worm", id = 7307, bonus = 75, icon = "INV_Misc_MonsterTail_03" },
        { name = "Aquadynamic Fish Attractor", id = 6533, bonus = 100, icon = "INV_Misc_Food_26" },
    }

    local yOffset = -120
    for i, lure in ipairs(lureData) do
        local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        btn:SetSize(250, 30)
        btn:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)

        -- Add faction icon if specified
        local buttonText = "|TInterface\\Icons\\" .. lure.icon .. ":20|t " .. lure.name .. " (+" .. lure.bonus .. ")"
        if lure.faction == "Alliance" then
            buttonText = buttonText .. " |TInterface\\PVPFrame\\PVP-Currency-Alliance:16|t"
        end
        btn:SetText(buttonText)

        btn:SetScript("OnClick", function()
            CFC.db.profile.selectedLure = lure.id
            UI:UpdateLuresTab()

            -- Update the Apply Lure button macro on the HUD
            if CFC.hudFrame and CFC.hudFrame.UpdateApplyLureMacro then
                CFC.hudFrame.UpdateApplyLureMacro()
            end
        end)

        yOffset = yOffset - 40
    end

    -- Store reference
    mainFrame.luresFrame = frame
end

-- Update Lures Tab
function UI:UpdateLuresTab()
    local frame = mainFrame.luresFrame
    if not frame or not frame:IsVisible() then
        return
    end

    local selectedLureID = CFC.db.profile.selectedLure
    if selectedLureID then
        local lureNames = {
            [6529] = "|TInterface\\Icons\\INV_Misc_Orb_03:20|t Shiny Bauble (+25)",
            [6530] = "|TInterface\\Icons\\INV_Misc_MonsterTail_03:20|t Nightcrawlers (+50)",
            [6532] = "|TInterface\\Icons\\INV_Misc_Gem_Variety_02:20|t Bright Baubles (+75)",
            [7307] = "|TInterface\\Icons\\INV_Misc_MonsterTail_03:20|t Flesh Eating Worm (+75)",
            [6533] = "|TInterface\\Icons\\INV_Misc_Food_26:20|t Aquadynamic Fish Attractor (+100)",
            [6811] = "|TInterface\\Icons\\INV_Misc_Spyglass_01:20|t Aquadynamic Fish Lens (+50) |TInterface\\PVPFrame\\PVP-Currency-Alliance:16|t",
        }
        frame.selectedLure:SetText(lureNames[selectedLureID] or "|cffaaaaaa(Unknown)|r")
    else
        frame.selectedLure:SetText("|cffaaaaaa(None selected)|r")
    end
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
    frame.scrollChild:SetSize(530, 700)
    frame.scrollFrame:SetScrollChild(frame.scrollChild)

    -- Settings title
    frame.title = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 5, -5)
    frame.title:SetText("Settings")

    -- About Button (top right)
    frame.aboutButton = CreateFrame("Button", "CFCAboutButton", frame.scrollChild, "UIPanelButtonTemplate")
    frame.aboutButton:SetSize(80, 25)
    frame.aboutButton:SetPoint("TOPRIGHT", frame.scrollChild, "TOPRIGHT", -10, -5)
    frame.aboutButton:SetText("About")
    frame.aboutButton:SetScript("OnClick", function(self)
        StaticPopup_Show("CFC_ABOUT_DIALOG")
    end)

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

    -- Announce Lures Checkbox
    frame.announceLuresCheck = CreateFrame("CheckButton", "CFCAnnounceLuresCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.announceLuresCheck:SetPoint("TOPLEFT", frame.announceCatchesDesc, "BOTTOMLEFT", -25, -20)
    frame.announceLuresCheck.text = frame.announceLuresCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.announceLuresCheck.text:SetPoint("LEFT", frame.announceLuresCheck, "RIGHT", 5, 0)
    frame.announceLuresCheck.text:SetText("Warn When Fishing Without Lure")

    frame.announceLuresCheck:SetScript("OnClick", function(self)
        CFC.db.profile.settings.announceLures = self:GetChecked()
        if CFC.db.profile.settings.announceLures then
            print("|cff00ff00Classic Fishing Companion:|r Missing lure warnings |cff00ff00enabled|r")
        else
            print("|cff00ff00Classic Fishing Companion:|r Missing lure warnings |cffff0000disabled|r")
        end
    end)

    -- Announce lures description
    frame.announceLuresDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.announceLuresDesc:SetPoint("TOPLEFT", frame.announceLuresCheck, "BOTTOMLEFT", 25, -5)
    frame.announceLuresDesc:SetJustifyH("LEFT")
    frame.announceLuresDesc:SetWidth(500)
    frame.announceLuresDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.announceLuresDesc:SetText("Show on-screen warning when fishing without a lure applied.")

    -- Lure Warning Interval Dropdown
    frame.lureIntervalLabel = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.lureIntervalLabel:SetPoint("TOPLEFT", frame.announceLuresDesc, "BOTTOMLEFT", 0, -15)
    frame.lureIntervalLabel:SetText("Warning Interval:")

    frame.lureIntervalDropdown = CreateFrame("Frame", "CFCLureIntervalDropdown", frame.scrollChild, "UIDropDownMenuTemplate")
    frame.lureIntervalDropdown:SetPoint("LEFT", frame.lureIntervalLabel, "RIGHT", -10, -2)
    UIDropDownMenu_SetWidth(frame.lureIntervalDropdown, 100)

    local function LureIntervalDropdown_Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        local intervals = {30, 60, 90}
        local labels = {"30 seconds", "60 seconds", "90 seconds"}

        for i, interval in ipairs(intervals) do
            info.text = labels[i]
            info.value = interval
            info.func = function()
                CFC.db.profile.settings.lureWarningInterval = interval
                UIDropDownMenu_SetSelectedValue(frame.lureIntervalDropdown, interval)
                UIDropDownMenu_SetText(frame.lureIntervalDropdown, labels[i])
                print("|cff00ff00Classic Fishing Companion:|r Lure warning interval set to |cffffff00" .. interval .. " seconds|r")
            end
            info.checked = (CFC.db.profile.settings.lureWarningInterval == interval)
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(frame.lureIntervalDropdown, LureIntervalDropdown_Initialize)

    -- Announce Skill Ups Checkbox
    frame.announceSkillUpsCheck = CreateFrame("CheckButton", "CFCAnnounceSkillUpsCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.announceSkillUpsCheck:SetPoint("TOPLEFT", frame.lureIntervalLabel, "BOTTOMLEFT", -25, -20)
    frame.announceSkillUpsCheck.text = frame.announceSkillUpsCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.announceSkillUpsCheck.text:SetPoint("LEFT", frame.announceSkillUpsCheck, "RIGHT", 5, 0)
    frame.announceSkillUpsCheck.text:SetText("Announce Fishing Skill Increases")

    frame.announceSkillUpsCheck:SetScript("OnClick", function(self)
        CFC.db.profile.settings.announceSkillUps = self:GetChecked()
        if CFC.db.profile.settings.announceSkillUps then
            print("|cff00ff00Classic Fishing Companion:|r Skill increase announcements |cff00ff00enabled|r")
        else
            print("|cff00ff00Classic Fishing Companion:|r Skill increase announcements |cffff0000disabled|r")
        end
    end)

    -- Announce skill ups description
    frame.announceSkillUpsDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.announceSkillUpsDesc:SetPoint("TOPLEFT", frame.announceSkillUpsCheck, "BOTTOMLEFT", 25, -5)
    frame.announceSkillUpsDesc:SetJustifyH("LEFT")
    frame.announceSkillUpsDesc:SetWidth(500)
    frame.announceSkillUpsDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.announceSkillUpsDesc:SetText("Display a chat message when your fishing skill increases.")

    -- Max Skill Announcement Checkbox
    frame.maxSkillCheck = CreateFrame("CheckButton", "CFCMaxSkillCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.maxSkillCheck:SetPoint("TOPLEFT", frame.announceSkillUpsDesc, "BOTTOMLEFT", -25, -30)
    frame.maxSkillCheck.text = frame.maxSkillCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.maxSkillCheck.text:SetPoint("LEFT", frame.maxSkillCheck, "RIGHT", 5, 0)
    frame.maxSkillCheck.text:SetText("Announce Max Skill (300)")

    frame.maxSkillCheck:SetScript("OnClick", function(self)
        local enabled = self:GetChecked()
        CFC.db.profile.settings.maxSkillAnnounceEnabled = enabled

        -- Enable/disable the dropdown
        if frame.maxSkillDropdown then
            UIDropDownMenu_EnableDropDown(frame.maxSkillDropdown)
            if not enabled then
                UIDropDownMenu_DisableDropDown(frame.maxSkillDropdown)
            end
        end

        if enabled then
            print("|cff00ff00Classic Fishing Companion:|r Max skill announcements |cff00ff00enabled|r")
        else
            print("|cff00ff00Classic Fishing Companion:|r Max skill announcements |cffff0000disabled|r")
        end
    end)

    -- Max Skill Announcement Channel Label
    frame.maxSkillLabel = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.maxSkillLabel:SetPoint("TOPLEFT", frame.maxSkillCheck, "BOTTOMLEFT", 25, -10)
    frame.maxSkillLabel:SetText("Announce to:")
    frame.maxSkillLabel:SetTextColor(0.7, 0.7, 0.7)

    frame.maxSkillDropdown = CreateFrame("Frame", "CFCMaxSkillDropdown", frame.scrollChild, "UIDropDownMenuTemplate")
    frame.maxSkillDropdown:SetPoint("LEFT", frame.maxSkillLabel, "RIGHT", -10, -2)

    local maxSkillChannels = {
        { text = "Say", value = "SAY" },
        { text = "Party", value = "PARTY" },
        { text = "Guild", value = "GUILD" },
        { text = "Emote", value = "EMOTE" },
    }

    UIDropDownMenu_SetWidth(frame.maxSkillDropdown, 150)
    UIDropDownMenu_Initialize(frame.maxSkillDropdown, function(self, level)
        for _, channel in ipairs(maxSkillChannels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel.text
            info.value = channel.value
            info.func = function(self)
                CFC.db.profile.settings.maxSkillAnnounce = self.value
                UIDropDownMenu_SetSelectedValue(frame.maxSkillDropdown, self.value)
                UIDropDownMenu_SetText(frame.maxSkillDropdown, self:GetText())
            end
            info.checked = (CFC.db.profile.settings.maxSkillAnnounce == channel.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    frame.maxSkillDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.maxSkillDesc:SetPoint("TOPLEFT", frame.maxSkillLabel, "BOTTOMLEFT", 10, -30)
    frame.maxSkillDesc:SetJustifyH("LEFT")
    frame.maxSkillDesc:SetWidth(500)
    frame.maxSkillDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.maxSkillDesc:SetText("Celebrate reaching max fishing skill by announcing to a chat channel.")

    -- Milestone Announcement Checkbox
    frame.milestonesCheck = CreateFrame("CheckButton", "CFCMilestonesCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.milestonesCheck:SetPoint("TOPLEFT", frame.maxSkillDesc, "BOTTOMLEFT", -25, -30)
    frame.milestonesCheck.text = frame.milestonesCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.milestonesCheck.text:SetPoint("LEFT", frame.milestonesCheck, "RIGHT", 5, 0)
    frame.milestonesCheck.text:SetText("Announce Milestones")

    frame.milestonesCheck:SetScript("OnClick", function(self)
        local enabled = self:GetChecked()
        CFC.db.profile.settings.milestonesAnnounceEnabled = enabled

        -- Enable/disable the dropdown
        if frame.milestonesDropdown then
            UIDropDownMenu_EnableDropDown(frame.milestonesDropdown)
            if not enabled then
                UIDropDownMenu_DisableDropDown(frame.milestonesDropdown)
            end
        end

        if enabled then
            print("|cff00ff00Classic Fishing Companion:|r Milestone announcements |cff00ff00enabled|r")
        else
            print("|cff00ff00Classic Fishing Companion:|r Milestone announcements |cffff0000disabled|r")
        end
    end)

    -- Milestone Announcement Channel Label
    frame.milestonesLabel = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.milestonesLabel:SetPoint("TOPLEFT", frame.milestonesCheck, "BOTTOMLEFT", 25, -10)
    frame.milestonesLabel:SetText("Announce to:")
    frame.milestonesLabel:SetTextColor(0.7, 0.7, 0.7)

    frame.milestonesDropdown = CreateFrame("Frame", "CFCMilestonesDropdown", frame.scrollChild, "UIDropDownMenuTemplate")
    frame.milestonesDropdown:SetPoint("LEFT", frame.milestonesLabel, "RIGHT", -10, -2)

    local milestonesChannels = {
        { text = "Say", value = "SAY" },
        { text = "Party", value = "PARTY" },
        { text = "Guild", value = "GUILD" },
        { text = "Emote", value = "EMOTE" },
    }

    UIDropDownMenu_SetWidth(frame.milestonesDropdown, 150)
    UIDropDownMenu_Initialize(frame.milestonesDropdown, function(self, level)
        for _, channel in ipairs(milestonesChannels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel.text
            info.value = channel.value
            info.func = function(self)
                CFC.db.profile.settings.milestonesAnnounce = self.value
                UIDropDownMenu_SetSelectedValue(frame.milestonesDropdown, self.value)
                UIDropDownMenu_SetText(frame.milestonesDropdown, self:GetText())
            end
            info.checked = (CFC.db.profile.settings.milestonesAnnounce == channel.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    frame.milestonesDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.milestonesDesc:SetPoint("TOPLEFT", frame.milestonesCheck, "BOTTOMLEFT", 25, -35)
    frame.milestonesDesc:SetJustifyH("LEFT")
    frame.milestonesDesc:SetWidth(500)
    frame.milestonesDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.milestonesDesc:SetText("Share your fishing achievements by announcing when you reach catch milestones (100, 250, 500, 1000, 2500, 5000, 10000, etc.).")

    -- Show Stats HUD Checkbox
    frame.showHUDCheck = CreateFrame("CheckButton", "CFCShowHUDCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.showHUDCheck:SetPoint("TOPLEFT", frame.milestonesDesc, "BOTTOMLEFT", -25, -20)
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

    -- Data Import/Export Section
    frame.dataManagementTitle = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.dataManagementTitle:SetPoint("TOPLEFT", frame.debugDesc, "BOTTOMLEFT", -25, -30)
    frame.dataManagementTitle:SetText("Data Management")

    -- Enable Automatic Backups Checkbox
    frame.autoBackupCheck = CreateFrame("CheckButton", "CFCAutoBackupCheck", frame.scrollChild, "UICheckButtonTemplate")
    frame.autoBackupCheck:SetPoint("TOPLEFT", frame.dataManagementTitle, "BOTTOMLEFT", 0, -15)
    frame.autoBackupCheck.text = frame.autoBackupCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.autoBackupCheck.text:SetPoint("LEFT", frame.autoBackupCheck, "RIGHT", 5, 0)
    frame.autoBackupCheck.text:SetText("Enable Automatic Backups")

    frame.autoBackupCheck:SetScript("OnClick", function(self)
        CFC.db.profile.backup.enabled = self:GetChecked()
        if CFC.db.profile.backup.enabled then
            print("|cff00ff00Classic Fishing Companion:|r Automatic backups |cff00ff00enabled|r")
            print("|cffffcc00Info:|r Backups are created every 24 hours and stored internally")
        else
            print("|cff00ff00Classic Fishing Companion:|r Automatic backups |cffff0000disabled|r")
        end
    end)

    -- Auto backup description
    frame.autoBackupDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.autoBackupDesc:SetPoint("TOPLEFT", frame.autoBackupCheck, "BOTTOMLEFT", 25, -5)
    frame.autoBackupDesc:SetJustifyH("LEFT")
    frame.autoBackupDesc:SetWidth(500)
    frame.autoBackupDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.autoBackupDesc:SetText("Automatically backs up your fishing data every 24 hours (stored in SavedVariables). Also shows export reminder every 7 days.")

    -- Export Data Button
    frame.exportButton = CreateFrame("Button", "CFCExportButton", frame.scrollChild, "UIPanelButtonTemplate")
    frame.exportButton:SetSize(200, 30)
    frame.exportButton:SetPoint("TOPLEFT", frame.autoBackupDesc, "BOTTOMLEFT", -25, -15)
    frame.exportButton:SetText("Export Data")

    frame.exportButton:SetScript("OnClick", function(self)
        if CFC.ExportData then
            CFC:ExportData()
        end
    end)

    -- Export description
    frame.exportDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.exportDesc:SetPoint("TOPLEFT", frame.exportButton, "BOTTOMLEFT", 25, -5)
    frame.exportDesc:SetJustifyH("LEFT")
    frame.exportDesc:SetWidth(500)
    frame.exportDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.exportDesc:SetText("Export all fishing data to a string that can be saved externally and imported later.")

    -- Import Data Button
    frame.importButton = CreateFrame("Button", "CFCImportButton", frame.scrollChild, "UIPanelButtonTemplate")
    frame.importButton:SetSize(200, 30)
    frame.importButton:SetPoint("TOPLEFT", frame.exportDesc, "BOTTOMLEFT", -25, -15)
    frame.importButton:SetText("Import Data")

    frame.importButton:SetScript("OnClick", function(self)
        if CFC.UI and CFC.UI.ShowImportDialog then
            CFC.UI:ShowImportDialog()
        end
    end)

    -- Import description
    frame.importDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.importDesc:SetPoint("TOPLEFT", frame.importButton, "BOTTOMLEFT", 25, -5)
    frame.importDesc:SetJustifyH("LEFT")
    frame.importDesc:SetWidth(500)
    frame.importDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.importDesc:SetText("Import fishing data from a previously exported string. This will replace your current data!")

    -- Restore from Backup Button
    frame.restoreBackupButton = CreateFrame("Button", "CFCRestoreBackupButton", frame.scrollChild, "UIPanelButtonTemplate")
    frame.restoreBackupButton:SetSize(200, 30)
    frame.restoreBackupButton:SetPoint("TOPLEFT", frame.importDesc, "BOTTOMLEFT", -25, -15)
    frame.restoreBackupButton:SetText("Restore from Backup")

    frame.restoreBackupButton:SetScript("OnClick", function(self)
        if CFC.RestoreFromBackup then
            StaticPopup_Show("CFC_RESTORE_BACKUP_CONFIRM")
        end
    end)

    -- Restore backup description with status
    frame.restoreBackupDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.restoreBackupDesc:SetPoint("TOPLEFT", frame.restoreBackupButton, "BOTTOMLEFT", 25, -5)
    frame.restoreBackupDesc:SetJustifyH("LEFT")
    frame.restoreBackupDesc:SetWidth(500)
    frame.restoreBackupDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.restoreBackupDesc:SetText("Restore fishing data from the last automatic backup.")

    -- Purge Item Button
    frame.purgeButton = CreateFrame("Button", "CFCPurgeButton", frame.scrollChild, "UIPanelButtonTemplate")
    frame.purgeButton:SetSize(200, 30)
    frame.purgeButton:SetPoint("TOPLEFT", frame.restoreBackupDesc, "BOTTOMLEFT", -25, -15)
    frame.purgeButton:SetText("Purge Item")

    frame.purgeButton:SetScript("OnClick", function(self)
        if CFC.UI and CFC.UI.ShowPurgeDialog then
            CFC.UI:ShowPurgeDialog()
        end
    end)

    -- Purge description
    frame.purgeDesc = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.purgeDesc:SetPoint("TOPLEFT", frame.purgeButton, "BOTTOMLEFT", 25, -5)
    frame.purgeDesc:SetJustifyH("LEFT")
    frame.purgeDesc:SetWidth(500)
    frame.purgeDesc:SetTextColor(0.7, 0.7, 0.7)
    frame.purgeDesc:SetText("Remove a specific item from your catches and statistics by name.")

    -- Clear Statistics Button
    frame.clearStatsButton = CreateFrame("Button", "CFCClearStatsButton", frame.scrollChild, "UIPanelButtonTemplate")
    frame.clearStatsButton:SetSize(200, 30)
    frame.clearStatsButton:SetPoint("TOPLEFT", frame.purgeDesc, "BOTTOMLEFT", -25, -20)
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
    frame.announceLuresCheck:SetChecked(CFC.db.profile.settings.announceLures)
    frame.announceSkillUpsCheck:SetChecked(CFC.db.profile.settings.announceSkillUps)

    -- Update lure warning interval dropdown
    local intervalLabels = {
        [30] = "30 seconds",
        [60] = "60 seconds",
        [90] = "90 seconds",
    }
    local currentInterval = CFC.db.profile.settings.lureWarningInterval or 30
    UIDropDownMenu_SetSelectedValue(frame.lureIntervalDropdown, currentInterval)
    UIDropDownMenu_SetText(frame.lureIntervalDropdown, intervalLabels[currentInterval] or "30 seconds")

    -- Update max skill checkbox and dropdown
    local maxSkillEnabled = CFC.db.profile.settings.maxSkillAnnounceEnabled
    if maxSkillEnabled == nil then
        maxSkillEnabled = (CFC.db.profile.settings.maxSkillAnnounce ~= nil and CFC.db.profile.settings.maxSkillAnnounce ~= "OFF")
        CFC.db.profile.settings.maxSkillAnnounceEnabled = maxSkillEnabled
    end
    frame.maxSkillCheck:SetChecked(maxSkillEnabled)

    local channelNames = {
        SAY = "Say",
        PARTY = "Party",
        GUILD = "Guild",
        EMOTE = "Emote",
    }
    local currentChannel = CFC.db.profile.settings.maxSkillAnnounce
    if currentChannel == "OFF" or currentChannel == nil then
        currentChannel = "GUILD"
        CFC.db.profile.settings.maxSkillAnnounce = currentChannel
    end
    UIDropDownMenu_SetSelectedValue(frame.maxSkillDropdown, currentChannel)
    UIDropDownMenu_SetText(frame.maxSkillDropdown, channelNames[currentChannel] or "Guild")

    -- Disable dropdown if checkbox is unchecked
    if not maxSkillEnabled then
        UIDropDownMenu_DisableDropDown(frame.maxSkillDropdown)
    end

    -- Update milestones checkbox and dropdown
    local milestonesEnabled = CFC.db.profile.settings.milestonesAnnounceEnabled or false
    frame.milestonesCheck:SetChecked(milestonesEnabled)

    local milestonesChannel = CFC.db.profile.settings.milestonesAnnounce or "GUILD"
    UIDropDownMenu_SetSelectedValue(frame.milestonesDropdown, milestonesChannel)
    UIDropDownMenu_SetText(frame.milestonesDropdown, channelNames[milestonesChannel] or "Guild")

    -- Disable dropdown if checkbox is unchecked
    if not milestonesEnabled then
        UIDropDownMenu_DisableDropDown(frame.milestonesDropdown)
    end

    -- Update HUD checkboxes
    frame.showHUDCheck:SetChecked(CFC.db.profile.hud.show)
    frame.lockHUDCheck:SetChecked(CFC.db.profile.hud.locked)
    -- Disable lock checkbox if HUD is hidden
    frame.lockHUDCheck:SetEnabled(CFC.db.profile.hud.show)

    -- Update backup checkbox
    frame.autoBackupCheck:SetChecked(CFC.db.profile.backup.enabled)

    -- Update restore backup button description with backup status
    if CFC.db.profile.backup.data and CFC.db.profile.backup.data.timestamp then
        local backupDate = date("%Y-%m-%d %H:%M:%S", CFC.db.profile.backup.data.timestamp)
        frame.restoreBackupDesc:SetText("Restore fishing data from the last automatic backup (Created: " .. backupDate .. ").")
        frame.restoreBackupButton:Enable()
    else
        frame.restoreBackupDesc:SetText("Restore fishing data from the last automatic backup. (No backup available yet)")
        frame.restoreBackupButton:Disable()
    end
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

        -- Show "What's New" dialog on first UI open after version update
        if CFC.db and CFC.db.profile then
            if not CFC.db.profile.whatsNewDismissed or CFC.db.profile.whatsNewDismissed ~= CFC.VERSION then
                -- Delay slightly so UI is fully visible first
                C_Timer.After(0.5, function()
                    StaticPopup_Show("CFC_WHATS_NEW")
                end)
            end
        end
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
    text = "Are you sure you want to clear ALL fishing statistics?\n\nThis will delete:\n• All fish catches\n• Fishing history\n• Lure usage tracking\n• Skill level records\n• Session statistics\n\nThis action CANNOT be undone!",
    button1 = "Yes, Clear Everything",
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

-- Confirmation dialog for restoring from backup
StaticPopupDialogs["CFC_RESTORE_BACKUP_CONFIRM"] = {
    text = "Restore fishing data from automatic backup?\n\nThis will replace your current data with the backup snapshot.\n\nYour current session progress will be preserved.",
    button1 = "Yes, Restore Backup",
    button2 = "Cancel",
    OnAccept = function()
        if CFC.RestoreFromBackup then
            CFC:RestoreFromBackup()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- About dialog
StaticPopupDialogs["CFC_ABOUT_DIALOG"] = {
    text = "|cff00ff00Classic Fishing Companion|r\n\nVersion: |cffffcc00" .. (CFC.VERSION or "1.0.6") .. "|r\n\nDeveloped by: |cff00ccffRelyk|r\n\n|cffffffffThank you for using Classic Fishing Companion!|r\n\nThis addon helps you track your fishing progress, manage gear, and optimize your fishing experience in Classic WoW.\n\n|cffffcc00If you enjoy this addon and want to support development:|r\n\n|cff00ff00Buy me a coffee at:|r\n|cff88ccffhttps://buymeacoffee.com/relyk22|r",
    button1 = "Close",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Version-specific What's New content
local whatsNewContent = {
    ["1.0.7"] = {
        features = {
            "Configurable lure warning interval (30, 60, or 90 seconds)",
            "New dropdown in Settings to choose warning frequency",
        },
        fixes = {
            "Fixed 'Unknown Lure (ID: XXX)' appearing in statistics",
            "Non-fishing enchants no longer tracked as lures",
            "Purge function now removes items from lure usage data",
            "Renamed 'Buff' to 'Lure' throughout the UI for clarity",
        },
        tip = "TIP: If you have 'Unknown Lure (ID: XXX)' in your statistics,\nuse Purge Item in Settings to remove it!"
    },
    ["1.0.6"] = {
        features = {
            "Refresh Icons button to update fish icons from bags",
            "Automatic background icon refresh (every 5 minutes)",
            "What's New dialog for version updates",
            "Automatic database migration system",
            "Centralized version management (CFC.VERSION)",
            "Statistics Tab: Hourly productivity analysis",
            "Statistics Tab: Weekly breakdown (last 7 days)",
            "Statistics Tab: Monthly breakdown (last 4 weeks)",
            "Visual bar graphs for statistics",
            "Fish rarity color coding (gray/white/green/blue/purple)",
            "Catch milestone notifications (10, 50, 100, 500, etc.)",
            "Max fishing skill announcement to chat channels",
            "Centralized color codes and constants"
        },
        fixes = {
            "Fixed lure statistics incrementing on /reload",
            "Improved Fish List icon loading reliability",
            "Better WoW API item data caching",
            "Fixed debug spam in Apply Lure function",
            "Added nil checks to catch history loops",
            "Improved gear swap error messages",
            "Locale-independent lure detection using enchant IDs"
        },
        tip = "Check out the new bar graphs in Statistics!\nSet your max skill announcement channel in Settings."
    }
}

-- Function to build What's New dialog text
local function GetWhatsNewText(version)
    local content = whatsNewContent[version]
    if not content then
        return "|cff00ff00What's New in v" .. version .. "|r\n\n|cffffffffNo release notes available for this version.|r"
    end

    local text = "|cff00ff00What's New in v" .. version .. "|r\n\n"

    -- Add features
    if content.features and #content.features > 0 then
        text = text .. "|cffffcc00New Features:|r\n"
        for _, feature in ipairs(content.features) do
            text = text .. "• " .. feature .. "\n"
        end
        text = text .. "\n"
    end

    -- Add fixes
    if content.fixes and #content.fixes > 0 then
        text = text .. "|cffffcc00Bug Fixes:|r\n"
        for _, fix in ipairs(content.fixes) do
            text = text .. "• " .. fix .. "\n"
        end
        text = text .. "\n"
    end

    -- Add tip
    if content.tip then
        text = text .. "|cff88ccff" .. content.tip .. "|r"
    end

    return text
end

-- What's New dialog (dynamic content)
StaticPopupDialogs["CFC_WHATS_NEW"] = {
    text = GetWhatsNewText(CFC.VERSION or "1.0.6"),
    button1 = "Got it!",
    button2 = "Don't show again",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnAccept = function()
        -- User acknowledged, do nothing (will show again next version)
    end,
    OnCancel = function()
        -- User clicked "Don't show again"
        if CFC and CFC.db and CFC.db.profile then
            CFC.db.profile.whatsNewDismissed = CFC.VERSION
        end
    end,
}

StaticPopupDialogs["CFC_CLEAR_GEAR_SETS"] = {
    text = "Are you sure you want to clear ALL gear sets?\n\nThis will delete:\n• Combat gear set\n• Fishing gear set\n\nYou will need to reconfigure your gear sets after this.\n\nThis action CANNOT be undone!",
    button1 = "Yes, Clear Gear Sets",
    button2 = "Cancel",
    OnAccept = function()
        if CFC.db and CFC.db.profile and CFC.db.profile.gearSets then
            -- Clear both gear sets
            CFC.db.profile.gearSets.combat = {}
            CFC.db.profile.gearSets.fishing = {}
            CFC.db.profile.gearSets.currentMode = "combat"

            print("|cff00ff00Classic Fishing Companion:|r All gear sets have been cleared.")

            -- Update UI if it's open
            if CFC.UI and CFC.UI.UpdateGearSetsTab then
                CFC.UI:UpdateGearSetsTab()
            end

            -- Update HUD
            if CFC.HUD and CFC.HUD.Update then
                CFC.HUD:Update()
            end
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Create custom export/import dialog
local exportImportFrame = nil

function UI:CreateExportImportDialog()
    if exportImportFrame then
        return exportImportFrame
    end

    -- Create frame
    local frame = CreateFrame("Frame", "CFCExportImportFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.title:SetText("Export/Import Data")

    -- Close button
    frame.CloseButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Instructions
    frame.instructions = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.instructions:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -30)
    frame.instructions:SetWidth(470)
    frame.instructions:SetJustifyH("LEFT")
    frame.instructions:SetText("Copy the data below (Ctrl+A, Ctrl+C) or paste imported data here:")

    -- Background container for visual background
    frame.bgContainer = CreateFrame("Frame", nil, frame)
    frame.bgContainer:SetPoint("TOPLEFT", frame.instructions, "BOTTOMLEFT", 5, -10)
    frame.bgContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 50)

    -- Create background texture
    frame.bg = frame.bgContainer:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints(frame.bgContainer)
    frame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.9)

    -- Scroll frame for the edit box
    frame.scrollFrame = CreateFrame("ScrollFrame", "CFCExportScrollFrame", frame.bgContainer, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", 5, -5)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

    -- Edit box
    frame.editBox = CreateFrame("EditBox", "CFCExportEditBox", frame.scrollFrame)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetMaxLetters(0)
    frame.editBox:SetFontObject(GameFontHighlightSmall)
    frame.editBox:SetWidth(420)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetEnabled(true)

    frame.editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    -- Enable Ctrl+A to select all
    frame.editBox:SetScript("OnChar", function(self, text)
        -- This allows text input
    end)

    frame.scrollFrame:SetScrollChild(frame.editBox)

    -- Copy All button
    frame.copyButton = CreateFrame("Button", "CFCCopyAllButton", frame, "UIPanelButtonTemplate")
    frame.copyButton:SetSize(120, 25)
    frame.copyButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 15)
    frame.copyButton:SetText("Select All")
    frame.copyButton:SetScript("OnClick", function()
        frame.editBox:HighlightText()
        frame.editBox:SetFocus()
    end)

    -- Import button
    frame.importButton = CreateFrame("Button", "CFCImportButton", frame, "UIPanelButtonTemplate")
    frame.importButton:SetSize(120, 25)
    frame.importButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
    frame.importButton:SetText("Import Data")
    frame.importButton:SetScript("OnClick", function()
        local importString = frame.editBox:GetText()
        if importString and importString ~= "" then
            if CFC.ImportData then
                CFC:ImportData(importString)
                frame:Hide()
            end
        else
            print("|cffff0000Classic Fishing Companion:|r No data to import!")
        end
    end)

    -- Close button
    frame.closeButton = CreateFrame("Button", "CFCCloseButton", frame, "UIPanelButtonTemplate")
    frame.closeButton:SetSize(120, 25)
    frame.closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.closeButton:SetText("Close")
    frame.closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    exportImportFrame = frame
    return frame
end

function UI:ShowExportDialog(data)
    local frame = self:CreateExportImportDialog()
    frame.title:SetText("Export Data")
    frame.instructions:SetText("Click 'Select All', then use |cff00ff00Ctrl+Insert|r to copy (or right-click and copy):")
    frame.editBox:SetText(data)
    frame.editBox:HighlightText()
    frame.editBox:SetFocus()
    frame.importButton:Hide()
    frame.copyButton:Show()
    frame:Show()
end

function UI:ShowImportDialog()
    local frame = self:CreateExportImportDialog()
    frame.title:SetText("Import Data")
    frame.instructions:SetText("|cffff0000WARNING:|r Paste data using |cff00ff00Shift+Insert|r or Ctrl+V. This will replace your current data!")
    frame.editBox:SetText("")
    frame.importButton:Show()
    frame.copyButton:Hide()
    frame:Show()

    -- Focus the edit box after a brief delay to ensure it's ready
    C_Timer.After(0.1, function()
        frame.editBox:SetFocus()
        frame.editBox:SetCursorPosition(0)
    end)
end

-- Create and show purge item dialog
function UI:ShowPurgeDialog()
    -- Create simple input dialog
    local dialog = CreateFrame("Frame", "CFCPurgeDialog", UIParent, "BasicFrameTemplateWithInset")
    dialog:SetSize(400, 150)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)

    -- Title
    dialog.title = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dialog.title:SetPoint("TOP", dialog, "TOP", 0, -5)
    dialog.title:SetText("Purge Item")

    -- Instructions
    dialog.instructions = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dialog.instructions:SetPoint("TOPLEFT", dialog, "TOPLEFT", 15, -30)
    dialog.instructions:SetWidth(370)
    dialog.instructions:SetJustifyH("LEFT")
    dialog.instructions:SetText("Enter the exact name of the item to remove from your database:")

    -- Input box
    dialog.inputBox = CreateFrame("EditBox", "CFCPurgeInputBox", dialog, "InputBoxTemplate")
    dialog.inputBox:SetSize(360, 30)
    dialog.inputBox:SetPoint("TOP", dialog.instructions, "BOTTOM", 0, -10)
    dialog.inputBox:SetAutoFocus(true)
    dialog.inputBox:SetMaxLetters(100)

    dialog.inputBox:SetScript("OnEscapePressed", function(self)
        dialog:Hide()
        dialog:SetParent(nil)
        dialog = nil
    end)

    dialog.inputBox:SetScript("OnEnterPressed", function(self)
        local itemName = self:GetText()
        if itemName and itemName ~= "" then
            if CFC.PurgeItem then
                CFC:PurgeItem(itemName)
            end
        end
        dialog:Hide()
        dialog:SetParent(nil)
        dialog = nil
    end)

    -- Purge button
    dialog.purgeButton = CreateFrame("Button", "CFCPurgeConfirmButton", dialog, "UIPanelButtonTemplate")
    dialog.purgeButton:SetSize(120, 25)
    dialog.purgeButton:SetPoint("BOTTOM", dialog, "BOTTOM", -65, 15)
    dialog.purgeButton:SetText("Purge Item")
    dialog.purgeButton:SetScript("OnClick", function()
        local itemName = dialog.inputBox:GetText()
        if itemName and itemName ~= "" then
            if CFC.PurgeItem then
                CFC:PurgeItem(itemName)
            end
        else
            print("|cffff0000Classic Fishing Companion:|r Please enter an item name!")
        end
        dialog:Hide()
        dialog:SetParent(nil)
        dialog = nil
    end)

    -- Cancel button
    dialog.cancelButton = CreateFrame("Button", "CFCPurgeCancelButton", dialog, "UIPanelButtonTemplate")
    dialog.cancelButton:SetSize(120, 25)
    dialog.cancelButton:SetPoint("BOTTOM", dialog, "BOTTOM", 65, 15)
    dialog.cancelButton:SetText("Cancel")
    dialog.cancelButton:SetScript("OnClick", function()
        dialog:Hide()
        dialog:SetParent(nil)
        dialog = nil
    end)

    -- Close button
    dialog.CloseButton:SetScript("OnClick", function()
        dialog:Hide()
        dialog:SetParent(nil)
        dialog = nil
    end)

    dialog:Show()

    -- Focus the input box after a brief delay
    C_Timer.After(0.1, function()
        if dialog and dialog.inputBox then
            dialog.inputBox:SetFocus()
        end
    end)
end
