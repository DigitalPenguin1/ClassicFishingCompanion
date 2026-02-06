-- Classic Fishing Companion - Database Module
-- Handles data management and queries

local addonName, addon = ...

-- Database functions
CFC.Database = {}

-- Get all catches sorted by timestamp (newest first)
function CFC.Database:GetRecentCatches(limit)
    limit = limit or 100
    local catches = {}

    for i = #CFC.db.profile.catches, math.max(1, #CFC.db.profile.catches - limit + 1), -1 do
        table.insert(catches, CFC.db.profile.catches[i])
    end

    return catches
end

-- Get catches by fish name
function CFC.Database:GetCatchesByFish(fishName)
    local catches = {}

    for _, catch in ipairs(CFC.db.profile.catches) do
        if catch.itemName == fishName then
            table.insert(catches, catch)
        end
    end

    return catches
end

-- Get catches by zone
function CFC.Database:GetCatchesByZone(zoneName)
    local catches = {}

    for _, catch in ipairs(CFC.db.profile.catches) do
        if catch.zone == zoneName then
            table.insert(catches, catch)
        end
    end

    return catches
end

-- Get all unique fish types sorted by count
function CFC.Database:GetFishList()
    local fishList = {}

    for fishName, data in pairs(CFC.db.profile.fishData) do
        table.insert(fishList, {
            name = fishName,
            count = data.count,
            firstCatch = data.firstCatch,
            lastCatch = data.lastCatch,
            locations = data.locations,
            itemType = data.itemType,
            itemSubType = data.itemSubType,
        })
    end

    -- Sort by count (descending)
    table.sort(fishList, function(a, b)
        return a.count > b.count
    end)

    return fishList
end

-- Get all unique zones where fishing occurred
function CFC.Database:GetZoneList()
    local zones = {}
    local zoneMap = {}

    for _, catch in ipairs(CFC.db.profile.catches) do
        if not zoneMap[catch.zone] then
            zoneMap[catch.zone] = {
                name = catch.zone,
                count = 0,
            }
        end
        zoneMap[catch.zone].count = zoneMap[catch.zone].count + 1
    end

    for _, data in pairs(zoneMap) do
        table.insert(zones, data)
    end

    -- Sort by count (descending)
    table.sort(zones, function(a, b)
        return a.count > b.count
    end)

    return zones
end

-- Get zone-based fish summary (for Zones tab)
-- Returns zones sorted by total fish caught, each with a sorted fish list
-- Only includes fish items (no chests, lockboxes, gear, etc.)
function CFC.Database:GetZoneFishSummary()
    local zoneMap = {}

    -- Fish detection keywords (same logic as Catch List tab)
    local fishKeywords = {
        "fish", "salmon", "trout", "bass", "catfish", "snapper",
        "rockscale", "cod", "tuna", "mahi", "grouper", "sunfish",
        "perch", "carp", "eel", "mackerel", "herring", "squid",
        "lobster", "crab", "clam", "mussel", "shrimp", "blackmouth",
        "redgill", "whitescale", "bluegill", "stonescale", "yellowtail",
        "crawdad", "darter", "feltail", "crocolisk"
    }

    local miscKeywords = {
        "lockbox", "chest", "wreckage", "debris", "crate", "case",
        "strongbox", "footlocker", "trunk", "coffer", "shoulders",
        "helm", "gauntlets", "boots", "belt", "cloak", "ring",
        "trinket", "necklace", "amulet", "sword", "axe", "mace",
        "dagger", "staff", "wand", "bow", "gun", "buckler", "shield",
        "gem", "pearl", "note", "letter", "ore", "crystal",
        "essence", "shard", "gloves", "leggings", "bracers"
    }

    -- Helper: determine if an item is a fish
    local function IsFishItem(itemName)
        local nameLower = string.lower(itemName)
        local isFish = false

        -- Check fish keywords
        for _, keyword in ipairs(fishKeywords) do
            if string.find(nameLower, keyword) then
                isFish = true
                break
            end
        end

        -- Check item type if not matched by name
        if not isFish then
            local fishData = CFC.db.profile.fishData[itemName]
            local itemType = fishData and fishData.itemType
            local itemSubType = fishData and fishData.itemSubType

            if not itemType then
                local _, _, _, _, _, iType, iSubType = GetItemInfo(itemName)
                itemType = iType
                itemSubType = iSubType
            end

            if itemType and itemSubType then
                local typeLower = string.lower(itemType)
                local subTypeLower = string.lower(itemSubType)
                if typeLower == "consumable" and
                   (string.find(subTypeLower, "food") or string.find(subTypeLower, "drink")) and
                   not string.find(subTypeLower, "potion") and
                   not string.find(subTypeLower, "elixir") and
                   not string.find(nameLower, "potion") and
                   not string.find(nameLower, "elixir") and
                   not string.find(nameLower, "scroll") then
                    isFish = true
                end
            end
        end

        -- Override: misc keywords (unless name contains "fish")
        if isFish and not string.find(string.lower(itemName), "fish") then
            for _, keyword in ipairs(miscKeywords) do
                if string.find(string.lower(itemName), keyword) then
                    isFish = false
                    break
                end
            end
        end

        return isFish
    end

    -- Iterate all catches once, grouping by zone
    for _, catch in ipairs(CFC.db.profile.catches) do
        local itemName = catch.itemName or "Unknown"
        local zone = catch.zone or "Unknown Zone"
        local timestamp = catch.timestamp or 0

        -- Only include fish items
        if IsFishItem(itemName) then
            -- Initialize zone entry
            if not zoneMap[zone] then
                zoneMap[zone] = {
                    name = zone,
                    totalCatches = 0,
                    fishMap = {},
                    firstVisit = timestamp,
                    lastVisit = timestamp,
                }
            end

            local zoneData = zoneMap[zone]
            zoneData.totalCatches = zoneData.totalCatches + 1

            -- Track first/last visit
            if timestamp > 0 then
                if timestamp < zoneData.firstVisit or zoneData.firstVisit == 0 then
                    zoneData.firstVisit = timestamp
                end
                if timestamp > zoneData.lastVisit then
                    zoneData.lastVisit = timestamp
                end
            end

            -- Track fish within this zone
            if not zoneData.fishMap[itemName] then
                zoneData.fishMap[itemName] = {
                    name = itemName,
                    count = 0,
                    firstCatch = timestamp,
                    lastCatch = timestamp,
                }
            end

            local fishEntry = zoneData.fishMap[itemName]
            fishEntry.count = fishEntry.count + 1
            if timestamp > 0 then
                if timestamp < fishEntry.firstCatch or fishEntry.firstCatch == 0 then
                    fishEntry.firstCatch = timestamp
                end
                if timestamp > fishEntry.lastCatch then
                    fishEntry.lastCatch = timestamp
                end
            end
        end
    end

    -- Convert to sorted arrays
    local zones = {}
    for _, zoneData in pairs(zoneMap) do
        -- Convert fishMap to sorted fishList
        local fishList = {}
        for _, fishEntry in pairs(zoneData.fishMap) do
            table.insert(fishList, fishEntry)
        end
        table.sort(fishList, function(a, b) return a.count > b.count end)

        zoneData.fishList = fishList
        zoneData.uniqueFish = #fishList
        zoneData.fishMap = nil  -- Clean up temporary map

        table.insert(zones, zoneData)
    end

    -- Sort zones by total catches (descending)
    table.sort(zones, function(a, b) return a.totalCatches > b.totalCatches end)

    return zones
end

-- Get session statistics
function CFC.Database:GetSessionStats()
    local sessionTime = time() - CFC.db.profile.statistics.sessionStartTime
    local fph = 0

    if sessionTime > 0 then
        fph = (CFC.db.profile.statistics.sessionCatches / sessionTime) * 3600
    end

    return {
        catches = CFC.db.profile.statistics.sessionCatches,
        timeSeconds = sessionTime,
        fishPerHour = fph,
        startTime = CFC.db.profile.statistics.sessionStartTime,
    }
end

-- Get lifetime statistics
function CFC.Database:GetLifetimeStats()
    local sessionTime = time() - CFC.db.profile.statistics.sessionStartTime
    local totalTime = CFC.db.profile.statistics.totalFishingTime + sessionTime
    local avgFph = 0

    if totalTime > 0 then
        avgFph = (CFC.db.profile.statistics.totalCatches / totalTime) * 3600
    end

    return {
        totalCatches = CFC.db.profile.statistics.totalCatches,
        totalTimeSeconds = totalTime,
        averageFishPerHour = avgFph,
        uniqueFish = CFC:GetUniqueFishCount(),
        uniqueZones = #self:GetZoneList(),
    }
end

-- Get catches within a time period
function CFC.Database:GetCatchesInPeriod(startTime, endTime)
    local catches = {}
    endTime = endTime or time()

    for _, catch in ipairs(CFC.db.profile.catches) do
        if catch.timestamp and catch.timestamp >= startTime and catch.timestamp <= endTime then
            table.insert(catches, catch)
        end
    end

    return catches
end

-- Get weekly statistics (last 7 days, broken down by day)
function CFC.Database:GetWeeklyStats()
    local now = time()
    local daySeconds = 86400  -- seconds in a day
    local stats = {
        days = {},
        totalCatches = 0,
        bestDay = nil,
        bestDayCount = 0,
    }

    -- Calculate stats for each of the last 7 days
    for i = 0, 6 do
        local dayEnd = now - (i * daySeconds)
        local dayStart = dayEnd - daySeconds

        -- Get day name
        local dayName = date("%A", dayEnd)  -- Full day name
        local dayDate = date("%m/%d", dayEnd)  -- Short date

        local dayCatches = self:GetCatchesInPeriod(dayStart, dayEnd)
        local dayCount = #dayCatches

        stats.days[i + 1] = {
            name = dayName,
            date = dayDate,
            catches = dayCount,
            daysAgo = i,
        }

        stats.totalCatches = stats.totalCatches + dayCount

        if dayCount > stats.bestDayCount then
            stats.bestDayCount = dayCount
            stats.bestDay = dayName .. " (" .. dayDate .. ")"
        end
    end

    stats.averagePerDay = stats.totalCatches / 7

    return stats
end

-- Get monthly statistics (last 30 days, broken down by week)
function CFC.Database:GetMonthlyStats()
    local now = time()
    local daySeconds = 86400
    local weekSeconds = daySeconds * 7
    local stats = {
        weeks = {},
        totalCatches = 0,
        bestWeek = nil,
        bestWeekCount = 0,
    }

    -- Calculate stats for each of the last 4 weeks
    for i = 0, 3 do
        local weekEnd = now - (i * weekSeconds)
        local weekStart = weekEnd - weekSeconds

        local weekLabel = "Week " .. (i + 1)
        if i == 0 then
            weekLabel = "This Week"
        elseif i == 1 then
            weekLabel = "Last Week"
        end

        local weekCatches = self:GetCatchesInPeriod(weekStart, weekEnd)
        local weekCount = #weekCatches

        stats.weeks[i + 1] = {
            label = weekLabel,
            catches = weekCount,
            weeksAgo = i,
        }

        stats.totalCatches = stats.totalCatches + weekCount

        if weekCount > stats.bestWeekCount then
            stats.bestWeekCount = weekCount
            stats.bestWeek = weekLabel
        end
    end

    stats.averagePerWeek = stats.totalCatches / 4

    return stats
end

-- Get hourly productivity analysis (which hours are most productive)
function CFC.Database:GetHourlyStats()
    local hourCounts = {}
    local totalCatches = 0

    -- Initialize all hours
    for h = 0, 23 do
        hourCounts[h] = 0
    end

    -- Count catches by hour
    for _, catch in ipairs(CFC.db.profile.catches) do
        if catch.timestamp then
            local hour = tonumber(date("%H", catch.timestamp))
            if hour then
                hourCounts[hour] = hourCounts[hour] + 1
                totalCatches = totalCatches + 1
            end
        end
    end

    -- Find best and worst hours
    local bestHour, bestCount = 0, 0
    local worstHour, worstCount = 0, totalCatches + 1

    local stats = {
        hours = {},
        bestHour = nil,
        bestHourCount = 0,
        peakPeriod = nil,
    }

    for h = 0, 23 do
        local count = hourCounts[h]
        local timeLabel = string.format("%d:00 - %d:59", h, h)

        -- Convert to 12-hour format for display
        local displayHour = h
        local ampm = "AM"
        if h == 0 then
            displayHour = 12
        elseif h == 12 then
            ampm = "PM"
        elseif h > 12 then
            displayHour = h - 12
            ampm = "PM"
        end
        local displayLabel = string.format("%d %s", displayHour, ampm)

        stats.hours[h] = {
            hour = h,
            label = displayLabel,
            catches = count,
            percentage = totalCatches > 0 and (count / totalCatches * 100) or 0,
        }

        if count > bestCount then
            bestCount = count
            bestHour = h
        end
    end

    -- Determine peak period (morning, afternoon, evening, night)
    local morning = 0   -- 6-11
    local afternoon = 0 -- 12-17
    local evening = 0   -- 18-23
    local night = 0     -- 0-5

    for h = 0, 5 do night = night + hourCounts[h] end
    for h = 6, 11 do morning = morning + hourCounts[h] end
    for h = 12, 17 do afternoon = afternoon + hourCounts[h] end
    for h = 18, 23 do evening = evening + hourCounts[h] end

    local peakCount = math.max(morning, afternoon, evening, night)
    if peakCount == morning then
        stats.peakPeriod = "Morning (6 AM - 12 PM)"
    elseif peakCount == afternoon then
        stats.peakPeriod = "Afternoon (12 PM - 6 PM)"
    elseif peakCount == evening then
        stats.peakPeriod = "Evening (6 PM - 12 AM)"
    else
        stats.peakPeriod = "Night (12 AM - 6 AM)"
    end

    stats.bestHour = stats.hours[bestHour].label
    stats.bestHourCount = bestCount
    stats.totalCatches = totalCatches

    return stats
end
