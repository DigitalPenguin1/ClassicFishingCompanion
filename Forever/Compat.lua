-- Classic Fishing Companion - API Compatibility
-- WoW Forever runs on the modern (Midnight) API, where several Classic globals
-- were removed in favor of C_* namespaces. Each wrapper uses the Classic global
-- when it exists, so Classic Era and TBC behave exactly as before, and falls
-- back to the namespaced API on Forever. Files alias these as locals.

CFCCompat = {}
local Compat = CFCCompat

-- Forever reports WOW_PROJECT_MAINLINE, so the interface number is the only
-- reliable way to tell it apart from Retail
local interfaceVersion = select(4, GetBuildInfo())
Compat.IS_FOREVER = interfaceVersion >= 16000 and interfaceVersion < 20000

-- Aura fields can be secret values on modern clients (mostly in combat).
-- Secrets can't be compared or passed to string functions, so treat them as unknown.
local function IsSecret(value)
    return issecretvalue ~= nil and issecretvalue(value)
end

-- While auras are locked (in combat), reading one from addon code throws
-- instead of returning a secret, so check before asking.
local function AurasLocked()
    if not (C_Secrets and C_Secrets.ShouldAurasBeSecret) then
        return false
    end
    local ok, locked = pcall(C_Secrets.ShouldAurasBeSecret)
    return not ok or locked
end

Compat.GetItemInfo = _G.GetItemInfo or C_Item.GetItemInfo
Compat.GetItemCount = _G.GetItemCount or C_Item.GetItemCount
Compat.GetItemIcon = _G.GetItemIcon or C_Item.GetItemIconByID
Compat.GetItemInfoInstant = _G.GetItemInfoInstant or C_Item.GetItemInfoInstant

-- Returns the legacy GetSpellInfo tuple (name, rank, icon, ...)
Compat.GetSpellInfo = _G.GetSpellInfo or function(spell)
    local info = C_Spell.GetSpellInfo(spell)
    if info then
        return info.name, nil, info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID
    end
end

-- Returns the legacy UnitBuff tuple (name, icon, count, debuffType, duration, expirationTime, ...)
-- Returns nil while auras are locked, same as "no buff at this index".
Compat.UnitBuff = _G.UnitBuff or function(unit, index, filter)
    if AurasLocked() then
        return nil
    end
    local ok, aura = pcall(C_UnitAuras.GetBuffDataByIndex, unit, index, filter)
    if not ok or not aura or IsSecret(aura.name) or IsSecret(aura.expirationTime) then
        return nil
    end
    return aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration,
        aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId
end

-- Returns name, skillLevel, maxSkillLevel for Fishing, or nil if not learned
function Compat.GetFishingSkill()
    -- Classic: fishing is one of the skill lines on the character sheet
    if GetNumSkillLines then
        for i = 1, GetNumSkillLines() do
            local skillName, _, _, skillLevel, _, _, skillMaxLevel = GetSkillLineInfo(i)
            if skillName and string.find(skillName, "Fishing") then
                return skillName, skillLevel, skillMaxLevel
            end
        end
        return nil
    end

    -- Modern: fishing has a fixed profession slot (4th return of GetProfessions)
    local _, _, _, fishingIndex = GetProfessions()
    if fishingIndex then
        local name, _, skillLevel, maxSkillLevel = GetProfessionInfo(fishingIndex)
        return name, skillLevel, maxSkillLevel
    end
    return nil
end

-- EasyMenu was removed on modern clients, but the UIDropDownMenu functions it
-- wrapped are still there. Same body as Blizzard's Classic implementation.
local function EasyMenu_Initialize(frame, level, menuList)
    for index = 1, #menuList do
        local value = menuList[index]
        if value.text then
            value.index = index
            UIDropDownMenu_AddButton(value, level)
        end
    end
end

Compat.EasyMenu = _G.EasyMenu or function(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
    if displayMode == "MENU" then
        menuFrame.displayMode = displayMode
    end
    UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList)
    ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
end
