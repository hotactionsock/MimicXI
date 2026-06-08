-----------------------------------
-- FATE Zone: Meriphataud Mountains
-- Zone ID: 119
-- Region pool: DERFLAND_ARAGONEU
-- Level range: 25-38
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.MERIPHATAUD_MOUNTAINS] =
{
    zoneName    = "Meriphataud_Mountains",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "DERFLAND_ARAGONEU",

    events =
    {
        -----------------------------------
        -- Yagudo Pilgrimage Guard
        -- Yagudo Zealots and Priests fan
        -- out from Oztroja to escort a
        -- religious pilgrimage, turning
        -- aggressive toward all outsiders.
        -----------------------------------
        {
            id          = "MM_YAGUDO_01",
            name        = "Yagudo Pilgrimage Guard",
            level       = 28,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "MM_YAGUDO_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 119

            mobs =
            {
                {
                    base        = { 119, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Yagudo Zealot",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
                {
                    base        = { 119, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Yagudo Priest",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1500 },
                    silver = { exp = 750  },
                    bronze = { exp = 375  },
                },
                fail =
                {
                    gold   = { exp = 375 },
                    silver = { exp = 185 },
                    bronze = { exp = 90  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.YAGUDO_FEATHER,         150 } },
                    silver = { { xi.item.YAGUDO_FEATHER,         200 },
                               { xi.item.BIRD_FEATHER,           150 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,         200 },
                               { xi.item.BIRD_FEATHER,           150 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    50 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,          50 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,         100 },
                               { xi.item.BIRD_FEATHER,            50 } },
                },
            },
        },

        -----------------------------------
        -- Yagudo Choir of Wrath
        -- Chains from Yagudo Pilgrimage Guard.
        -- Yagudo Scribes chant battle hymns
        -- and Votaries advance in a
        -- disciplined, murderous formation.
        -----------------------------------
        {
            id          = "MM_YAGUDO_02",
            name        = "Yagudo Choir of Wrath",
            level       = 32,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 65,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 119

            mobs =
            {
                {
                    base        = { 119, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Yagudo Votary",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
                {
                    base        = { 119, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Yagudo Scribe",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1700 },
                    silver = { exp = 850  },
                    bronze = { exp = 425  },
                },
                fail =
                {
                    gold   = { exp = 425 },
                    silver = { exp = 210 },
                    bronze = { exp = 105 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.YAGUDO_FEATHER,         100 } },
                    silver = { { xi.item.YAGUDO_FEATHER,         200 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    50 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,         200 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,   100 },
                               { xi.item.BIRD_FEATHER,           100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,          50 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,         100 },
                               { xi.item.BIRD_FEATHER,            50 } },
                },
            },
        },

        -----------------------------------
        -- The Mountain Detonator
        -- A rogue Bomb, swollen beyond all
        -- natural proportion by volcanic
        -- heat, rolls down the mountain
        -- trails chased by lesser Bombs.
        -----------------------------------
        {
            id          = "MM_BOSS_01",
            name        = "The Mountain Detonator",
            level       = 35,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A deep, rhythmic rumbling echoes from the Meriphataud passes...",
                "The mountain shakes — a blazing shape rolls down the high road...",
            },

            onMobEngage = function(mob, target, zoneID, eventIdx)
                if not target:isPC() then return end
                local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
                if not entries then return end
                for _, entry in ipairs(entries) do
                    if entry.entity:getID() == mob:getID() and entry.isBoss then
                        for _, other in ipairs(entries) do
                            if not other.isBoss and other.entity:isSpawned() then
                                other.entity:updateClaim(target)
                                other.entity:addEnmity(target, 2, 1000)
                            end
                        end
                        return
                    end
                end
            end,

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 81,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 119

            mobs =
            {
                {
                    base         = { 119, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Peak Detonator",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
                {
                    base        = { 119, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Mountain Bomb",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3500 },
                    silver = { exp = 1750 },
                    bronze = { exp = 875  },
                },
                fail =
                {
                    gold   = { exp = 875 },
                    silver = { exp = 435 },
                    bronze = { exp = 215 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.BOMB_COAL },
                    bronze = { { xi.item.BOMB_COAL,              240 },
                               { xi.item.YAGUDO_FEATHER,         150 } },
                    silver = { { xi.item.BOMB_COAL,              240 },
                               { xi.item.YAGUDO_FEATHER,         200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 } },
                    gold   = { { xi.item.BOMB_COAL,              240 },
                               { xi.item.YAGUDO_FEATHER,         200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BOMB_COAL,               50 } },
                    gold   = { { xi.item.BOMB_COAL,              100 },
                               { xi.item.YAGUDO_FEATHER,          50 } },
                },
            },
        },

        -----------------------------------
        -- Raptor Pack
        -- A large pack of Raptors, driven
        -- down from the high passes by
        -- hunger, fans across the mountain
        -- road and attacks everything.
        -----------------------------------
        {
            id          = "MM_RAPTOR_01",
            name        = "Raptor Pack",
            level       = 27,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 119

            mobs =
            {
                {
                    base        = { 119, 7 },  -- TODO: verify mob_groups (Mountain Raptor)
                    name        = string.char(0xA6) .. "Mount Raptor",
                    count       = 7,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
                {
                    base        = { 119, 8 },  -- TODO: verify mob_groups (Meriphataud Raptor)
                    name        = string.char(0xA6) .. "Peak Raptor",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1500 },
                    silver = { exp = 750  },
                    bronze = { exp = 375  },
                },
                fail =
                {
                    gold   = { exp = 375 },
                    silver = { exp = 185 },
                    bronze = { exp = 90  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.RAPTOR_SKIN,             150 } },
                    silver = { { xi.item.RAPTOR_SKIN,             200 },
                               { xi.item.BIRD_FEATHER,            100 } },
                    gold   = { { xi.item.RAPTOR_SKIN,             200 },
                               { xi.item.BIRD_FEATHER,            150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.RAPTOR_SKIN,              50 } },
                    gold   = { { xi.item.RAPTOR_SKIN,             100 },
                               { xi.item.BIRD_FEATHER,             50 } },
                },
            },
        },

        -----------------------------------
        -- Bomb Uprising
        -- The volcanic heat on the mountain
        -- trails surges, causing a cluster
        -- of Bombs to enlarge and become
        -- territorial. They need to be put out.
        -----------------------------------
        {
            id          = "MM_BOMB_01",
            name        = "Bomb Uprising",
            level       = 29,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "MM_BOMB_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 119

            mobs =
            {
                {
                    base        = { 119, 9 },  -- TODO: verify mob_groups (Trail Bomb)
                    name        = string.char(0xA6) .. "Trail Bomb",
                    count       = 7,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
                {
                    base        = { 119, 10 },  -- TODO: verify mob_groups (Magma Bomb)
                    name        = string.char(0xA6) .. "Magma Bomb",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1600 },
                    silver = { exp = 800  },
                    bronze = { exp = 400  },
                },
                fail =
                {
                    gold   = { exp = 400 },
                    silver = { exp = 200 },
                    bronze = { exp = 100 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BOMB_COAL,               150 } },
                    silver = { { xi.item.BOMB_COAL,               200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       100 } },
                    gold   = { { xi.item.BOMB_COAL,               200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BOMB_COAL,                50 } },
                    gold   = { { xi.item.BOMB_COAL,               100 },
                               { xi.item.CHUNK_OF_IRON_ORE,        50 } },
                },
            },
        },

        -----------------------------------
        -- Inferno Wave
        -- Chains from Bomb Uprising.
        -- The extermination agitates a
        -- deeper cluster of huge Volcanic
        -- Bombs that surge onto the road
        -- in a wave of rolling fire.
        -----------------------------------
        {
            id          = "MM_BOMB_02",
            name        = "Inferno Wave",
            level       = 32,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 65,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 119

            mobs =
            {
                {
                    base        = { 119, 11 },  -- TODO: verify mob_groups (Volcanic Bomb)
                    name        = string.char(0xA6) .. "Volcanic Bomb",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1800 },
                    silver = { exp = 900  },
                    bronze = { exp = 450  },
                },
                fail =
                {
                    gold   = { exp = 450 },
                    silver = { exp = 225 },
                    bronze = { exp = 110 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BOMB_COAL,               100 } },
                    silver = { { xi.item.BOMB_COAL,               200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       150 } },
                    gold   = { { xi.item.BOMB_COAL,               200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BOMB_COAL,                50 } },
                    gold   = { { xi.item.BOMB_COAL,               100 },
                               { xi.item.CHUNK_OF_IRON_ORE,        50 } },
                },
            },
        },

        -----------------------------------
        -- The Talon of Oztroja
        -- The Yagudo High Priest's personal
        -- enforcer, a towering Yagudo
        -- Theomilrist of fearsome repute,
        -- descends the mountain road with
        -- a choir of devoted fanatics.
        -----------------------------------
        {
            id          = "MM_BOSS_02",
            name        = "The Talon of Oztroja",
            level       = 34,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "Chanting echoes down from the high passes of Meriphataud...",
                "A towering Yagudo descends the mountain road, flanked by armed zealots...",
            },

            onMobEngage = function(mob, target, zoneID, eventIdx)
                if not target:isPC() then return end
                local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
                if not entries then return end
                for _, entry in ipairs(entries) do
                    if entry.entity:getID() == mob:getID() and entry.isBoss then
                        for _, other in ipairs(entries) do
                            if not other.isBoss and other.entity:isSpawned() then
                                other.entity:updateClaim(target)
                                other.entity:addEnmity(target, 2, 1000)
                            end
                        end
                        return
                    end
                end
            end,

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 81,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 119

            mobs =
            {
                {
                    base         = { 119, 12 },  -- TODO: verify mob_groups (Talon of Oztroja)
                    name         = string.char(0xA6) .. "Oztroja Talon",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
                {
                    base        = { 119, 13 },  -- TODO: verify mob_groups (Oztroja Devotee)
                    name        = string.char(0xA6) .. "Yagudo Devotee",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3500 },
                    silver = { exp = 1750 },
                    bronze = { exp = 875  },
                },
                fail =
                {
                    gold   = { exp = 875 },
                    silver = { exp = 435 },
                    bronze = { exp = 215 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.YAGUDO_FEATHER },
                    bronze = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.BIRD_FEATHER,            150 } },
                    silver = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.BIRD_FEATHER,            200 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    150 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.BIRD_FEATHER,            200 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,           50 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          100 },
                               { xi.item.BIRD_FEATHER,             50 } },
                },
            },
        },

        -----------------------------------
        -- The Summit Predator
        -- A colossal Hippogryph, centuries
        -- old and scarred by a thousand
        -- territorial battles, descends
        -- from the highest crags of
        -- Meriphataud to hunt the passes.
        -----------------------------------
        {
            id          = "MM_BOSS_03",
            name        = "The Summit Predator",
            level       = 44,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A shadow crosses the sun above the Meriphataud passes — impossibly large wings...",
                "The Summit Predator banks into a dive above the mountain road...",
            },

            onMobEngage = function(mob, target, zoneID, eventIdx)
                if not target:isPC() then return end
                local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
                if not entries then return end
                for _, entry in ipairs(entries) do
                    if entry.entity:getID() == mob:getID() and entry.isBoss then
                        for _, other in ipairs(entries) do
                            if not other.isBoss and other.entity:isSpawned() then
                                other.entity:updateClaim(target)
                                other.entity:addEnmity(target, 2, 1000)
                            end
                        end
                        return
                    end
                end
            end,

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 105,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 119

            mobs =
            {
                {
                    base         = { 119, 14 },  -- TODO: verify mob_groups (Summit Predator)
                    name         = string.char(0xA6) .. "Peak Predator",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 119
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 4500 },
                    silver = { exp = 2250 },
                    bronze = { exp = 1125 },
                },
                fail =
                {
                    gold   = { exp = 1125 },
                    silver = { exp = 560  },
                    bronze = { exp = 280  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.BIRD_FEATHER },
                    bronze = { { xi.item.BIRD_FEATHER,            240 },
                               { xi.item.RAPTOR_SKIN,             150 } },
                    silver = { { xi.item.BIRD_FEATHER,            240 },
                               { xi.item.RAPTOR_SKIN,             200 },
                               { xi.item.YAGUDO_FEATHER,          150 } },
                    gold   = { { xi.item.BIRD_FEATHER,            240 },
                               { xi.item.RAPTOR_SKIN,             200 },
                               { xi.item.YAGUDO_FEATHER,          150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BIRD_FEATHER,             50 } },
                    gold   = { { xi.item.BIRD_FEATHER,            100 },
                               { xi.item.RAPTOR_SKIN,              50 } },
                },
            },
        },
    },
}
