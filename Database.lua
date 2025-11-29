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

-- Get statistics for a specific fish
function CFC.Database:GetFishStats(fishName)
    local fishData = CFC.db.profile.fishData[fishName]

    if not fishData then
        return nil
    end

    -- Calculate location breakdown
    local locationList = {}
    for _, locationData in pairs(fishData.locations) do
        table.insert(locationList, locationData)
    end

    -- Sort by count
    table.sort(locationList, function(a, b)
        return a.count > b.count
    end)

    return {
        name = fishName,
        totalCount = fishData.count,
        firstCatch = fishData.firstCatch,
        lastCatch = fishData.lastCatch,
        locations = locationList,
    }
end

-- Get catches within a time range
function CFC.Database:GetCatchesInTimeRange(startTime, endTime)
    local catches = {}

    for _, catch in ipairs(CFC.db.profile.catches) do
        if catch.timestamp >= startTime and catch.timestamp <= endTime then
            table.insert(catches, catch)
        end
    end

    return catches
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

-- Export data to string (for sharing or backup)
function CFC.Database:ExportData()
    local export = {
        version = "1.0.0",
        exportDate = date("%Y-%m-%d %H:%M:%S"),
        statistics = CFC.db.profile.statistics,
        fishData = CFC.db.profile.fishData,
        totalCatches = #CFC.db.profile.catches,
    }

    -- Convert to string (simple serialization)
    local str = "Classic Fishing Companion Export\n"
    str = str .. "Version: " .. export.version .. "\n"
    str = str .. "Date: " .. export.exportDate .. "\n"
    str = str .. "Total Catches: " .. export.totalCatches .. "\n"
    str = str .. "Unique Fish: " .. CFC:GetUniqueFishCount() .. "\n"

    return str
end

-- Clear old catches (keep only last N)
function CFC.Database:PruneOldCatches(keepCount)
    keepCount = keepCount or 1000

    if #CFC.db.profile.catches > keepCount then
        local newCatches = {}
        local startIndex = #CFC.db.profile.catches - keepCount + 1

        for i = startIndex, #CFC.db.profile.catches do
            table.insert(newCatches, CFC.db.profile.catches[i])
        end

        CFC.db.profile.catches = newCatches
        print("|cff00ff00Classic Fishing Companion:|r Pruned old catches, kept " .. keepCount .. " most recent.")
    end
end
