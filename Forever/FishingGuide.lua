-- Classic Fishing Companion - Fishing Guide data (Forever only)
-- Where every fish comes from: zones, sub-zones, pools and special catches.
--
-- Sources (researched Nov 2026):
--   * Zone loot and chances: cMaNGOS classic-db 1.12.1, as tabulated by
--     forevermastery.com for Forever build 1.60.1. Forever kept the Classic
--     zone loot; percentages are approximate.
--   * Skill bands (skill to fish / skill for no escapes): same source, matches
--     wowforeverguides.com and the old Wowpedia zone table.
--   * Item IDs verified on Wowhead Classic.
--   * Forever additions: Whimsyfin (Redridge), Tip the Scales quests,
--     Extravaganza coin (icy-veins, foreverchanges.pro).

CFC.FishingGuide = {}
local Guide = CFC.FishingGuide

-- Item IDs, so icons and tooltips work for fish the player has never seen
Guide.itemIDs = {
    ["Raw Brilliant Smallfish"] = 6291,
    ["Raw Longjaw Mud Snapper"] = 6289,
    ["Raw Slitherskin Mackerel"] = 6303,
    ["Raw Rainbow Fin Albacore"] = 6361,
    ["Raw Bristle Whisker Catfish"] = 6308,
    ["Raw Loch Frenzy"] = 6317,
    ["Darkshore Grouper"] = 12238,
    ["Sickly Looking Fish"] = 6299,
    ["Oily Blackmouth"] = 6358,
    ["Firefin Snapper"] = 6359,
    ["Raw Sagefish"] = 21071,
    ["Raw Greater Sagefish"] = 21153,
    ["Deviate Fish"] = 6522,
    ["Raw Mithril Head Trout"] = 8365,
    ["Raw Rockscale Cod"] = 6362,
    ["Raw Spotted Yellowtail"] = 4603,
    ["Raw Redgill"] = 13758,
    ["Raw Nightfin Snapper"] = 13759,
    ["Raw Sunscale Salmon"] = 13760,
    ["Raw Glossy Mightfish"] = 13754,
    ["Raw Summer Bass"] = 13756,
    ["Winter Squid"] = 13755,
    ["Stonescale Eel"] = 13422,
    ["Raw Whitescale Salmon"] = 13889,
    ["Plated Armorfish"] = 13890,
    ["Darkclaw Lobster"] = 13888,
    ["Lightning Eel"] = 13757,
    ["Big-mouth Clam"] = 7973,
    ["Feralas Ahi"] = 16967,
    ["Sar'theris Striker"] = 16968,
    ["Savage Coast Blue Sailfin"] = 16969,
    ["Misty Reed Mahi Mahi"] = 16970,
    ["Brownell's Blue Striped Racer"] = 19803,
    ["Keefer's Angelfish"] = 19805,
    ["Dezian Queenfish"] = 19806,
    ["Speckled Tastyfish"] = 19807,
    ["Elemental Water"] = 7070,
    ["Stranglekelp"] = 3820,
    ["Mudskunk Lure"] = 19974,
}

-- Conditions that apply wherever the fish is caught
Guide.fishNotes = {
    ["Raw Nightfin Snapper"] = "Night (best 12-6 AM)",
    ["Raw Sunscale Salmon"] = "Day (best 12-6 PM)",
    ["Raw Summer Bass"] = "Spring & summer",
    ["Winter Squid"] = "Fall & winter",
}

-- Loot sets shared by many waters: { fish name, approx. chance % }
local STARTER = { { "Raw Brilliant Smallfish", 59 }, { "Raw Longjaw Mud Snapper", 40 } }
local MACKEREL = { { "Raw Slitherskin Mackerel", 98 } }
local RIVER_LOW = { { "Raw Longjaw Mud Snapper", 50 }, { "Raw Bristle Whisker Catfish", 30 }, { "Raw Brilliant Smallfish", 18 } }
local COAST_LOW = { { "Raw Rainbow Fin Albacore", 50 }, { "Raw Slitherskin Mackerel", 34 }, { "Oily Blackmouth", 15 } }
local SICKLY = { { "Raw Longjaw Mud Snapper", 30 }, { "Sickly Looking Fish", 15 } }
local OASIS = { { "Raw Longjaw Mud Snapper", 40 }, { "Deviate Fish", 30 }, { "Raw Bristle Whisker Catfish", 15 }, { "Raw Brilliant Smallfish", 13 } }
local SLUDGE = { { "Raw Longjaw Mud Snapper", 36 }, { "Raw Bristle Whisker Catfish", 15 } }
local DARK_COAST = { { "Raw Rainbow Fin Albacore", 30 }, { "Darkshore Grouper", 30 }, { "Raw Slitherskin Mackerel", 19 }, { "Oily Blackmouth", 10 } }
local DARK_RIVER = { { "Raw Longjaw Mud Snapper", 35 }, { "Darkshore Grouper", 30 }, { "Raw Brilliant Smallfish", 18 }, { "Raw Bristle Whisker Catfish", 15 } }
local UNDERCITY = { { "Raw Longjaw Mud Snapper", 40 }, { "Sickly Looking Fish", 15 }, { "Raw Bristle Whisker Catfish", 15 }, { "Raw Brilliant Smallfish", 13 } }
local RIVER_MID = { { "Raw Bristle Whisker Catfish", 63 }, { "Raw Longjaw Mud Snapper", 35 } }
local COAST_MID = { { "Raw Rainbow Fin Albacore", 59 }, { "Oily Blackmouth", 25 }, { "Firefin Snapper", 15 } }
local RIVER_HIGH = { { "Raw Mithril Head Trout", 58 }, { "Raw Bristle Whisker Catfish", 40 } }
local COAST_HIGH = { { "Raw Rockscale Cod", 55 }, { "Raw Spotted Yellowtail", 20 }, { "Oily Blackmouth", 12 }, { "Firefin Snapper", 12 } }
local RIVER_EXPERT = { { "Raw Redgill", 35 }, { "Raw Nightfin Snapper", 18 }, { "Raw Sunscale Salmon", 18 }, { "Oily Blackmouth", 10 }, { "Raw Mithril Head Trout", 10 } }
local COAST_EXPERT = { { "Raw Spotted Yellowtail", 25 }, { "Stonescale Eel", 15 }, { "Raw Glossy Mightfish", 15 }, { "Raw Summer Bass", 15 }, { "Winter Squid", 15 }, { "Firefin Snapper", 10 } }
local ARTISAN = { { "Raw Whitescale Salmon", 31 }, { "Raw Nightfin Snapper", 17 }, { "Raw Sunscale Salmon", 17 }, { "Plated Armorfish", 17 }, { "Lightning Eel", 12 } }
local AZ_BAY = { { "Darkclaw Lobster", 40 }, { "Raw Summer Bass", 20 }, { "Winter Squid", 20 }, { "Stonescale Eel", 18 }, { "Big-mouth Clam", 10 }, { "Raw Spotted Yellowtail", 5 } }

local function Water(label, fish, extra)
    local group = { label = label, fish = fish }
    if extra then
        for k, v in pairs(extra) do group[k] = v end
    end
    return group
end

-- kind: "zone", "pool" or "special". skill = needed to fish there,
-- clean = skill at which nothing gets away.
local function Zone(name, continent, skill, clean, groups, notes)
    return { kind = "zone", name = name, continent = continent, skill = skill, clean = clean, groups = groups, notes = notes }
end

local EK, KAL = "Eastern Kingdoms", "Kalimdor"

Guide.entries = {
    -- Apprentice: skill 1, no escapes at 25
    Zone("Dun Morogh", EK, 1, 25, { Water("Lakes and rivers", STARTER) }),
    Zone("Durotar", KAL, 1, 25, {
        Water("Coast", MACKEREL),
        Water("Sen'jin Village, Southfury River, Tor'kren Farm", STARTER),
    }),
    Zone("Elwynn Forest", EK, 1, 25, { Water("Lakes and rivers", STARTER) }),
    Zone("Mulgore", KAL, 1, 25, { Water("Lakes and rivers", STARTER) }),
    Zone("Teldrassil", KAL, 1, 25, {
        Water("Lakes and rivers", STARTER),
        Water("Rut'theran Village", MACKEREL),
    }),
    Zone("Tirisfal Glades", EK, 1, 25, {
        Water("Lakes and rivers", SICKLY),
        Water("The North Coast, Whispering Shore", MACKEREL),
    }),

    -- Skill 1, no escapes at 75
    Zone("Stormwind City", EK, 1, 75, { Water("Canals", RIVER_LOW) }),
    Zone("Ironforge", EK, 1, 75, { Water("Water", RIVER_LOW) }),
    Zone("Darnassus", KAL, 1, 75, { Water("Water", RIVER_LOW) }),
    Zone("Orgrimmar", KAL, 1, 75, { Water("Water", RIVER_LOW) }),
    Zone("Thunder Bluff", KAL, 1, 75, { Water("Pools", RIVER_LOW) }),
    Zone("Undercity", EK, 1, 75, { Water("Canals", UNDERCITY) }),
    Zone("The Deadmines", EK, 1, 75, { Water("Water", RIVER_LOW) }),
    Zone("Wailing Caverns", KAL, 1, 75, { Water("Water", OASIS) }),
    Zone("Blackfathom Deeps", KAL, 1, 75, { Water("Water", SICKLY) }),
    Zone("Darkshore", KAL, 1, 75, {
        Water("Coast", DARK_COAST),
        Water("Rivers: Cliffspring, Wildbend, Twilight Vale, Grove of the Ancients, Ruins of Mathystra", DARK_RIVER),
    }, { "Floating Debris and Oily Blackmouth Schools off the coast." }),
    Zone("Loch Modan", EK, 1, 75, { Water("The Loch", { { "Raw Loch Frenzy", 25 } }) },
        { "Floating Debris and Sagefish Schools on the loch." }),
    Zone("Silverpine Forest", EK, 1, 75, {
        Water("Lakes and rivers", SICKLY),
        Water("Coast: North and South Tide's Run, The Great Sea, The Skittering Dark", COAST_LOW),
    }, { "Floating Debris, Sagefish, Greater Sagefish and Oily Blackmouth Schools." }),
    Zone("The Barrens", KAL, 1, 75, {
        Water("Coast", COAST_LOW),
        Water("Oases: Lushwater, The Forgotten Pools, The Stagnant Oasis", OASIS),
        Water("Southfury River, Southern Barrens", RIVER_LOW),
        Water("The Sludge Fen", SLUDGE),
    }, { "Oases have Schools of Deviate Fish (Savory Deviate Delight)." }),
    Zone("Westfall", EK, 1, 75, {
        Water("Rivers", RIVER_LOW),
        Water("Longshore, Westfall Lighthouse", COAST_LOW),
    }, { "Floating Debris and Greater Sagefish Schools along the coast." }),

    -- Skill 55, no escapes at 150
    Zone("Ashenvale", KAL, 55, 150, {
        Water("Lakes and rivers", RIVER_MID),
        Water("The Zoram Strand", COAST_MID),
    }, { "Sagefish Schools in the lakes." }),
    Zone("Duskwood", EK, 55, 150, { Water("Rivers", RIVER_MID) }),
    Zone("Redridge Mountains", EK, 55, 150, {
        Water("Lake Everstill and rivers", RIVER_MID),
        Water("New in Forever", { { "Whimsyfin" } }),
    }, { "Whimsyfin cooks into Savory Whimsyfin Delight (recipe drops from Redridge mobs)." }),
    Zone("Hillsbrad Foothills", EK, 55, 150, {
        Water("Lakes and rivers", RIVER_MID),
        Water("Southshore, Eastern and Western Strand", COAST_MID),
    }, { "Sagefish Schools, plus Floating Wreckage and Firefin Snapper Schools on the coast." }),
    Zone("Stonetalon Mountains", KAL, 55, 150, {
        Water("Lakes and rivers", RIVER_MID),
        Water("Blackwolf River, Cragpool Lake (Venture Co. runoff)", SLUDGE),
    }, { "Oil Spills here are full of Firefin Snapper." }),
    Zone("Wetlands", EK, 55, 150, {
        Water("Lakes and rivers", RIVER_MID),
        Water("Menethil Harbor, Baradin Bay, The Lost Fleet", COAST_MID),
    }, { "Floating Wreckage and Firefin Snapper Schools in the bay." }),

    -- Skill 130, no escapes at 225
    Zone("Alterac Mountains", EK, 130, 225, { Water("Lakes and rivers", RIVER_HIGH) },
        { "Greater Sagefish Schools in the lakes." }),
    Zone("Arathi Highlands", EK, 130, 225, {
        Water("Lakes and rivers", RIVER_HIGH),
        Water("Faldir's Cove, The Drowned Reef", COAST_HIGH),
    }),
    Zone("Desolace", KAL, 130, 225, {
        Water("Lakes and rivers", RIVER_HIGH),
        Water("Coast: Ethel Rethor, Ranazjar Isle, Shadowprey Village, The Veiled Sea", COAST_HIGH),
    }, { "Sar'theris Strand: Sar'theris Striker for Nat Pagle's quest." }),
    Zone("Dustwallow Marsh", KAL, 130, 225, {
        Water("Swamp water", RIVER_HIGH),
        Water("Coast: Theramore Isle, Alcaz Island, Dreadmurk Shore, Tidefury Cove", COAST_HIGH),
    }, { "Nat Pagle fishes off Theramore. He teaches Artisan Fishing and sells Mudskunk Lures." }),
    Zone("Scarlet Monastery", EK, 130, 225, { Water("Water", RIVER_HIGH) }),
    Zone("Stranglethorn Vale", EK, 130, 225, {
        Water("Rivers and lakes", RIVER_HIGH),
        Water("Coast: Booty Bay, Grom'gol, Bloodsail Compound, Ruins of Aboraz, Crystal Shore, Cape of Stranglethorn", COAST_HIGH),
    }, {
        "The richest pool zone: Oily Blackmouth, Firefin Snapper, Stonescale Eel, Greater Sagefish and Floating Wreckage.",
        "Home of the Stranglethorn Fishing Extravaganza. Savage Coast: Blue Sailfin for Nat Pagle.",
    }),
    Zone("Swamp of Sorrows", EK, 130, 225, {
        Water("Swamp water", RIVER_HIGH),
        Water("Stagalbog, The Forbidding Sea", COAST_HIGH),
    }, { "Misty Reed Strand: Misty Reed Mahi Mahi for Nat Pagle's quest." }),
    Zone("Thousand Needles", KAL, 130, 225, { Water("Water", RIVER_HIGH) }),

    -- Skill 205, no escapes at 300
    Zone("Azshara", KAL, 205, 300, {
        Water("Lakes and rivers", RIVER_EXPERT),
        Water("Coast: Southridge Beach, Ruined Reaches, Shattered Strand, Jagged Reef", COAST_EXPERT),
        Water("Bay of Storms, Hetaera's Clutch, Scalebeard's Cave", AZ_BAY, { skill = 330, clean = 425 }),
    }, { "Patches of Elemental Water and Stonescale Eel Swarms along the coast." }),
    Zone("Felwood", KAL, 205, 300, { Water("Lakes and rivers", RIVER_EXPERT) }),
    Zone("Feralas", KAL, 205, 300, {
        Water("Lakes and rivers", RIVER_HIGH),
        Water("Jademir Lake", ARTISAN, { skill = 330, clean = 425 }),
    }, {
        "Floating Wreckage and Stonescale Eel Swarms on the coast.",
        "Verdantis River: Feralas Ahi for Nat Pagle's quest.",
    }),
    Zone("Maraudon", KAL, 205, 300, { Water("Water", RIVER_EXPERT) }),
    Zone("Moonglade", KAL, 205, 300, { Water("Lake Elune'ara", RIVER_EXPERT) }),
    Zone("Tanaris", KAL, 205, 300, { Water("Coast", COAST_EXPERT) },
        { "Stonescale Eel Swarms, Oily Blackmouth, Firefin and Floating Wreckage off Steamwheedle Port." }),
    Zone("The Hinterlands", EK, 205, 300, { Water("Lakes and rivers", RIVER_EXPERT) }),
    Zone("Un'Goro Crater", KAL, 205, 300, { Water("Lakes and rivers", RIVER_EXPERT) },
        { "Fire Plume Ridge lava only gives junk and Coal." }),
    Zone("Western Plaguelands", EK, 205, 300, { Water("Lakes and rivers", RIVER_EXPERT) }),

    -- Skill 330, no escapes at 425
    Zone("Burning Steppes", EK, 330, 425, { Water("Water", ARTISAN) }),
    Zone("Deadwind Pass", EK, 330, 425, { Water("Water", { { "Lightning Eel", 7 } }) }),
    Zone("Eastern Plaguelands", EK, 330, 425, { Water("Lakes and rivers", ARTISAN) }),
    Zone("Scholomance", EK, 330, 425, { Water("Water", ARTISAN) }),
    Zone("Silithus", KAL, 330, 425, { Water("Water", ARTISAN) }),
    Zone("Stratholme", EK, 330, 425, { Water("Water", ARTISAN) }),
    Zone("Winterspring", KAL, 330, 425, { Water("Lakes and rivers", ARTISAN) }),
    Zone("Zul'Gurub", EK, 330, 425, { Water("Water", ARTISAN) },
        { "Muddy Churning Waters: fish with a Mudskunk Lure to summon Gahz'ranka." }),

    -- Fishing pools: cast into the pool itself
    { kind = "pool", name = "Oily Blackmouth School",
      where = "Stranglethorn Vale, Darkshore, The Barrens, Silverpine Forest, Tanaris",
      groups = { Water("Catch", { { "Oily Blackmouth", 85 }, { "Stranglekelp", 5 } }) },
      notes = { "Also Tightly Sealed Trunk and Rumsey Rum Light." } },
    { kind = "pool", name = "Firefin Snapper School",
      where = "Stranglethorn Vale, Tanaris, Wetlands, Hillsbrad Foothills, Feralas",
      groups = { Water("Catch", { { "Firefin Snapper", 85 }, { "Stranglekelp", 5 } }) },
      notes = { "Also Iron Bound Trunk and Rumsey Rum Black Label." } },
    { kind = "pool", name = "Sagefish School",
      where = "Silverpine Forest, Loch Modan, Ashenvale, Hillsbrad Foothills, Stonetalon Mountains",
      groups = { Water("Catch", { { "Raw Sagefish", 85 }, { "Stranglekelp", 5 } }) } },
    { kind = "pool", name = "Greater Sagefish School",
      where = "Stranglethorn Vale, Alterac Mountains, Silverpine Forest, Westfall",
      groups = { Water("Catch", { { "Raw Greater Sagefish", 85 }, { "Stranglekelp", 5 } }) } },
    { kind = "pool", name = "Stonescale Eel Swarm",
      where = "Stranglethorn Vale, Tanaris, Feralas, Azshara",
      groups = { Water("Catch", { { "Stonescale Eel", 85 }, { "Stranglekelp", 5 } }) },
      notes = { "Also Mithril Bound Trunk and Rumsey Rum Black Label." } },
    { kind = "pool", name = "School of Deviate Fish",
      where = "The Barrens (oases)",
      groups = { Water("Catch", { { "Deviate Fish", 85 }, { "Stranglekelp", 5 } }) } },
    { kind = "pool", name = "Oil Spill",
      where = "Stonetalon Mountains",
      groups = { Water("Catch", { { "Firefin Snapper", 85 }, { "Stranglekelp", 5 } }) },
      notes = { "Also Watertight Trunk and Rumsey Rum Dark." } },
    { kind = "pool", name = "Floating Wreckage",
      where = "Stranglethorn Vale, Tanaris, Wetlands, Hillsbrad Foothills, Feralas",
      groups = { Water("Catch", { { "Stranglekelp", 20 } }) },
      notes = { "Mostly Iron Bound Trunks (60%) and Rumsey Rum Black Label." } },
    { kind = "pool", name = "Floating Debris",
      where = "Darkshore, Silverpine Forest, Loch Modan, The Barrens, Westfall",
      groups = { Water("Catch", { { "Stranglekelp", 20 } }) },
      notes = { "Mostly Tightly Sealed Trunks (60%) and Rumsey Rum Light." } },
    { kind = "pool", name = "Patch of Elemental Water",
      where = "Azshara",
      groups = { Water("Catch", { { "Elemental Water", 40 } }) },
      notes = { "Also Globes of Water and Essence of Water." } },
    { kind = "pool", name = "School of Tastyfish",
      where = "Stranglethorn Vale",
      groups = { Water("Catch", { { "Speckled Tastyfish", 85 }, { "Oily Blackmouth", 5 }, { "Firefin Snapper", 5 }, { "Stonescale Eel", 5 } }) } },

    -- Special catches
    { kind = "special", name = "Nat Pagle, Angler Extreme",
      where = "Quest from Nat Pagle, Dustwallow Marsh (level 35+)",
      groups = {
          Water("Feralas: Verdantis River", { { "Feralas Ahi" } }),
          Water("Desolace: Sar'theris Strand", { { "Sar'theris Striker" } }),
          Water("Swamp of Sorrows: Misty Reed Strand", { { "Misty Reed Mahi Mahi" } }),
          Water("Stranglethorn Vale: Savage Coast", { { "Savage Coast Blue Sailfin" } }),
      },
      notes = { "These fish only bite while you're on the quest." } },
    { kind = "special", name = "Stranglethorn Fishing Extravaganza",
      where = "Stranglethorn Vale coast, during the weekly contest",
      groups = {
          Water("Schools of Tastyfish", { { "Speckled Tastyfish" } }),
          Water("Rare fish (turn in to Fishbot 5000, Booty Bay)", {
              { "Brownell's Blue Striped Racer" }, { "Dezian Queenfish" }, { "Keefer's Angelfish" },
          }),
      },
      notes = {
          "First to bring 40 Speckled Tastyfish to Riggle Bassbait wins; Forever adds an Extravagant Extravaganza Coin.",
          "New in Forever: Tip the Scales quests from Flipfin trade a rare fish for 3 Speckled Tastyfish.",
      } },
    { kind = "special", name = "Seasons and time of day",
      where = "Applies everywhere these fish are caught",
      groups = {
          Water("Night (12-6 AM best, none 12-6 PM)", { { "Raw Nightfin Snapper" } }),
          Water("Day (12-6 PM best, none 12-6 AM)", { { "Raw Sunscale Salmon" } }),
          Water("Spring & summer, expert-level coasts", { { "Raw Summer Bass" } }),
          Water("Fall & winter, expert-level coasts", { { "Winter Squid" } }),
      },
      notes = { "Times follow the realm clock." } },
}

-- Item ID for a fish name, or nil
function Guide:GetItemID(name)
    return self.itemIDs[name]
end
