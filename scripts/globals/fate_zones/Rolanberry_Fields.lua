-----------------------------------
-- FATE Zone: Rolanberry Fields
-- Zone ID: 110
-- Region pool: DERFLAND_ARAGONEU
-- Level range: 28-38
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.ROLANBERRY_FIELDS] =
{
    zoneName    = "Rolanberry_Fields",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "DERFLAND_ARAGONEU",

    events =
    {
        -----------------------------------
        -- Quadav Work Party
        -- Gem Quadav and Sapphire Quadav
        -- march out of Beadeaux to plunder
        -- the rolanberry orchards and
        -- establish a forward supply camp.
        -----------------------------------
        {
            id          = "RF_QUADAV_01",
            name        = "Quadav Work Party",
            level       = 32,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 110

            mobs =
            {
                {
                    base        = { 110, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gem Quadav",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                    },
                },
                {
                    base        = { 110, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Blue Quadav",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
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
                    bronze = { { xi.item.QUADAV_HELM,            150 } },
                    silver = { { xi.item.QUADAV_HELM,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                    gold   = { { xi.item.QUADAV_HELM,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 },
                               { xi.item.BONE_CHIP,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.QUADAV_HELM,             50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Fieldcrawler Queen
        -- A massive Crawler queen, gorged
        -- on rolanberry harvest, emerges
        -- from a silk-choked grove trailing
        -- a swarm of Soldier Crawlers.
        -----------------------------------
        {
            id          = "RF_BOSS_01",
            name        = "The Fieldcrawler Queen",
            level       = 36,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "An eerie silence falls over the Rolanberry Fields...",
                "The fields rustle violently - enormous mandibles part the crops...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 110

            mobs =
            {
                {
                    base         = { 110, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Crawler Queen",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                    },
                },
                {
                    base        = { 110, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Guard Crawler",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
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
                    guaranteed = { xi.item.SILK_THREAD },
                    bronze = { { xi.item.SILK_THREAD,            240 },
                               { xi.item.CRAWLER_CALCULUS,       150 } },
                    silver = { { xi.item.SILK_THREAD,            240 },
                               { xi.item.CRAWLER_CALCULUS,       200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 } },
                    gold   = { { xi.item.SILK_THREAD,            240 },
                               { xi.item.CRAWLER_CALCULUS,       200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 },
                               { xi.item.QUADAV_HELM,            100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.SILK_THREAD,             50 } },
                    gold   = { { xi.item.SILK_THREAD,            100 },
                               { xi.item.CRAWLER_CALCULUS,        50 } },
                },
            },
        },

        -----------------------------------
        -- Beetle Blight
        -- A swarm of oversized Rolanberry
        -- Beetles descends on the orchards,
        -- devouring crops and attacking
        -- anyone who gets in the way.
        -----------------------------------
        {
            id          = "RF_BEETLE_01",
            name        = "Beetle Blight",
            level       = 29,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 12 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 110

            mobs =
            {
                {
                    base        = { 110, 5 },  -- TODO: verify mob_groups (Rolanberry Beetle)
                    name        = string.char(0xA6) .. "Field Beetle",
                    count       = 12,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
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
                    bronze = { { xi.item.BEETLE_SHELL,            150 } },
                    silver = { { xi.item.BEETLE_SHELL,            200 },
                               { xi.item.BONE_CHIP,               100 } },
                    gold   = { { xi.item.BEETLE_SHELL,            200 },
                               { xi.item.BONE_CHIP,               150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEETLE_SHELL,             50 } },
                    gold   = { { xi.item.BEETLE_SHELL,            100 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Supply Run
        -- Diamond Quadav and Quadav Snipers
        -- advance through the fields under
        -- heavy cover, escorting a supply
        -- column bound for Beadeaux.
        -----------------------------------
        {
            id          = "RF_QUADAV_02",
            name        = "Quadav Supply Run",
            level       = 31,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "RF_QUADAV_03",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 110

            mobs =
            {
                {
                    base        = { 110, 6 },  -- TODO: verify mob_groups (Diamond Quadav)
                    name        = string.char(0xA6) .. "Diamond Quadav",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                    },
                },
                {
                    base        = { 110, 7 },  -- TODO: verify mob_groups (Quadav Sniper)
                    name        = string.char(0xA6) .. "Quadav Sniper",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
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
                    bronze = { { xi.item.QUADAV_HELM,             150 } },
                    silver = { { xi.item.QUADAV_HELM,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.QUADAV_HELM,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.BONE_CHIP,               100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.QUADAV_HELM,              50 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Vanguard
        -- Chains from Quadav Supply Run.
        -- Elite Veteran Quadav and their
        -- Warlord escorts ride in to cover
        -- the broken supply column with
        -- overwhelming force.
        -----------------------------------
        {
            id          = "RF_QUADAV_03",
            name        = "Quadav Vanguard",
            level       = 34,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 110

            mobs =
            {
                {
                    base        = { 110, 8 },  -- TODO: verify mob_groups (Veteran Quadav)
                    name        = string.char(0xA6) .. "Veteran Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                    },
                },
                {
                    base        = { 110, 9 },  -- TODO: verify mob_groups (Quadav Warlord)
                    name        = string.char(0xA6) .. "Quadav Warlord",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2200 },
                    silver = { exp = 1100 },
                    bronze = { exp = 550  },
                },
                fail =
                {
                    gold   = { exp = 550 },
                    silver = { exp = 275 },
                    bronze = { exp = 135 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.QUADAV_HELM,             100 } },
                    silver = { { xi.item.QUADAV_HELM,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.QUADAV_HELM,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BONE_CHIP,               150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.QUADAV_HELM,              50 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- The Rolanberry Goobbue
        -- An enormous Goobbue, fattened on
        -- decades of rolanberry harvests,
        -- rampages through the orchards,
        -- smashing everything in its path.
        -----------------------------------
        {
            id          = "RF_BOSS_02",
            name        = "The Rolanberry Goobbue",
            level       = 35,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The ground shakes with heavy impacts deep in the Rolanberry Fields...",
                "Crops scatter in all directions - something immense tears through the orchard rows...",
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
                radius = 85,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 110

            mobs =
            {
                {
                    base         = { 110, 10 },  -- TODO: verify mob_groups (Rolanberry Goobbue)
                    name         = string.char(0xA6) .. "Berry Goobbue",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                    },
                },
                {
                    base        = { 110, 11 },  -- TODO: verify mob_groups (Field Goobbue)
                    name        = string.char(0xA6) .. "Field Goobbue",
                    count       = 2,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
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
                    guaranteed = { xi.item.BEAST_HIDE },
                    bronze = { { xi.item.BEAST_HIDE,              240 },
                               { xi.item.BEETLE_SHELL,            150 } },
                    silver = { { xi.item.BEAST_HIDE,              240 },
                               { xi.item.BEETLE_SHELL,            150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.BEAST_HIDE,              240 },
                               { xi.item.BEETLE_SHELL,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.QUADAV_HELM,             100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,               50 } },
                    gold   = { { xi.item.BEAST_HIDE,              100 },
                               { xi.item.BEETLE_SHELL,             50 } },
                },
            },
        },

        -----------------------------------
        -- The Ancient Cultivator
        -- Something vast has been growing
        -- under the Rolanberry Fields for
        -- a very long time. Today it decides
        -- it has grown large enough to leave.
        -----------------------------------
        {
            id          = "RF_BOSS_03",
            name        = "The Ancient Cultivator",
            level       = 44,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The Rolanberry Fields tremble - deep root systems writhe beneath the surface...",
                "The earth splits across the fields as the Ancient Cultivator tears free...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 110

            mobs =
            {
                {
                    base         = { 110, 12 },  -- TODO: verify mob_groups (Ancient Cultivator)
                    name         = string.char(0xA6) .. "Old Cultivator",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 110
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
                    guaranteed = { xi.item.SILK_THREAD },
                    bronze = { { xi.item.SILK_THREAD,             240 },
                               { xi.item.BEAST_HIDE,              150 } },
                    silver = { { xi.item.SILK_THREAD,             240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.CRAWLER_CALCULUS,        150 } },
                    gold   = { { xi.item.SILK_THREAD,             240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.CRAWLER_CALCULUS,        200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.SILK_THREAD,              50 } },
                    gold   = { { xi.item.SILK_THREAD,             100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },
    },
}
