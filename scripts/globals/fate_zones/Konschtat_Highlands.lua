-----------------------------------
-- FATE Zone: Konschtat Highlands
-- Zone ID: 108
-- Region pool: STARTER_ZULKHEIM
-- Level range: 18-30
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.KONSCHTAT_HIGHLANDS] =
{
    zoneName    = "Konschtat_Highlands",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Crawler Infestation
        -- Crawlers and Dew Gliders pour
        -- from the highland moors, stripping
        -- vegetation and attacking anything
        -- that crosses their path.
        -----------------------------------
        {
            id          = "KH_CRAWLER_01",
            name        = "Crawler Infestation",
            level       = 22,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "KH_CRAWLER_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 108

            mobs =
            {
                {
                    base        = { 108, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Hill Crawler",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
                {
                    base        = { 108, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Dew Glider",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1000 },
                    silver = { exp = 500  },
                    bronze = { exp = 250  },
                },
                fail =
                {
                    gold   = { exp = 250 },
                    silver = { exp = 125 },
                    bronze = { exp = 60  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.CRAWLER_CALCULUS,       150 } },
                    silver = { { xi.item.CRAWLER_CALCULUS,       200 },
                               { xi.item.SILK_THREAD,            150 } },
                    gold   = { { xi.item.CRAWLER_CALCULUS,       200 },
                               { xi.item.SILK_THREAD,            200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CRAWLER_CALCULUS,        50 } },
                    gold   = { { xi.item.CRAWLER_CALCULUS,       100 },
                               { xi.item.SILK_THREAD,             50 } },
                },
            },
        },

        -----------------------------------
        -- Crawler Surge
        -- Chains from Crawler Infestation.
        -- Larger Highland Crawlers and
        -- Gliding Lizards pursue the
        -- retreating defenders.
        -----------------------------------
        {
            id          = "KH_CRAWLER_02",
            name        = "Crawler Surge",
            level       = 25,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 108

            mobs =
            {
                {
                    base        = { 108, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gliding Lizard",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
                {
                    base        = { 108, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Giant Crawler",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1100 },
                    silver = { exp = 550  },
                    bronze = { exp = 275  },
                },
                fail =
                {
                    gold   = { exp = 275 },
                    silver = { exp = 135 },
                    bronze = { exp = 65  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.CRAWLER_CALCULUS,       100 } },
                    silver = { { xi.item.CRAWLER_CALCULUS,       200 },
                               { xi.item.SILK_THREAD,            100 } },
                    gold   = { { xi.item.CRAWLER_CALCULUS,       200 },
                               { xi.item.SILK_THREAD,            150 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CRAWLER_CALCULUS,        50 } },
                    gold   = { { xi.item.CRAWLER_CALCULUS,       100 },
                               { xi.item.SILK_THREAD,             50 } },
                },
            },
        },

        -----------------------------------
        -- Wandering Colossus
        -- A behemoth Stone Eater, drawn by
        -- the vibrations of battle, erupts
        -- from the highland bedrock trailing
        -- a cloud of Konschtat Bats.
        -----------------------------------
        {
            id          = "KH_BOSS_01",
            name        = "Wandering Colossus",
            level       = 28,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The ground shudders beneath the Konschtat Highlands...",
                "Deep cracks split the highland rock - something ancient rises from below...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 108

            mobs =
            {
                {
                    base         = { 108, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Stone Colossus",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
                {
                    base        = { 108, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Konschtat Bat",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2500 },
                    silver = { exp = 1250 },
                    bronze = { exp = 625  },
                },
                fail =
                {
                    gold   = { exp = 625 },
                    silver = { exp = 310 },
                    bronze = { exp = 155 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.CHUNK_OF_IRON_ORE },
                    bronze = { { xi.item.CHUNK_OF_IRON_ORE,      240 },
                               { xi.item.CRAWLER_CALCULUS,       150 } },
                    silver = { { xi.item.CHUNK_OF_IRON_ORE,      240 },
                               { xi.item.SILK_THREAD,            200 },
                               { xi.item.CRAWLER_CALCULUS,       150 } },
                    gold   = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 },
                               { xi.item.CHUNK_OF_IRON_ORE,      240 },
                               { xi.item.SILK_THREAD,            200 },
                               { xi.item.CRAWLER_CALCULUS,       150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CHUNK_OF_IRON_ORE,       50 } },
                    gold   = { { xi.item.CHUNK_OF_IRON_ORE,      100 },
                               { xi.item.CRAWLER_CALCULUS,        50 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Prospectors
        -- A Quadav prospecting team crosses
        -- from Beadeaux to stake new mineral
        -- claims in the highland bedrock,
        -- driving off anyone in the area.
        -----------------------------------
        {
            id          = "KH_QUADAV_01",
            name        = "Quadav Prospectors",
            level       = 22,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "KH_QUADAV_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 108

            mobs =
            {
                {
                    base        = { 108, 7 },  -- TODO: verify mob_groups (Quadav Miner)
                    name        = string.char(0xA6) .. "Quadav Miner",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
                {
                    base        = { 108, 8 },  -- TODO: verify mob_groups (Sapphire Quadav)
                    name        = string.char(0xA6) .. "Blue Quadav",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1000 },
                    silver = { exp = 500  },
                    bronze = { exp = 250  },
                },
                fail =
                {
                    gold   = { exp = 250 },
                    silver = { exp = 125 },
                    bronze = { exp = 60  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,               150 } },
                    silver = { { xi.item.QUADAV_HELM,             100 },
                               { xi.item.BONE_CHIP,               150 } },
                    gold   = { { xi.item.QUADAV_HELM,             150 },
                               { xi.item.BONE_CHIP,               150 },
                               { xi.item.CHUNK_OF_IRON_ORE,       100 } },
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
        -- Quadav Honour Guard
        -- Chains from Quadav Prospectors.
        -- Veteran Ruby Quadav are dispatched
        -- to protect the surveyors and drive
        -- off any interference.
        -----------------------------------
        {
            id          = "KH_QUADAV_02",
            name        = "Quadav Honour Guard",
            level       = 25,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 60,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 108

            mobs =
            {
                {
                    base        = { 108, 9 },  -- TODO: verify mob_groups (Ruby Quadav)
                    name        = string.char(0xA6) .. "Ruby Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
                {
                    base        = { 108, 10 }, -- TODO: verify mob_groups (Quadav Shieldbearer)
                    name        = string.char(0xA6) .. "Shield Quadav",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1100 },
                    silver = { exp = 550  },
                    bronze = { exp = 275  },
                },
                fail =
                {
                    gold   = { exp = 275 },
                    silver = { exp = 135 },
                    bronze = { exp = 65  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,               100 } },
                    silver = { { xi.item.QUADAV_HELM,             150 },
                               { xi.item.BONE_CHIP,               100 } },
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
        -- Ram Stampede
        -- A highland ram herd, panicked by
        -- Quadav activity in the area,
        -- breaks south and barrels through
        -- any camps in its path.
        -----------------------------------
        {
            id          = "KH_RAM_01",
            name        = "Ram Stampede",
            level       = 22,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 108

            mobs =
            {
                {
                    base        = { 108, 11 }, -- TODO: verify mob_groups (Highland Ram)
                    name        = string.char(0xA6) .. "Wailing Ram",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
                {
                    base        = { 108, 12 }, -- TODO: verify mob_groups (Ornery Sheep)
                    name        = string.char(0xA6) .. "Ornery Sheep",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1000 },
                    silver = { exp = 500  },
                    bronze = { exp = 250  },
                },
                fail =
                {
                    gold   = { exp = 250 },
                    silver = { exp = 125 },
                    bronze = { exp = 60  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.CLUMP_OF_SHEEP_WOOL,     150 } },
                    silver = { { xi.item.CLUMP_OF_SHEEP_WOOL,     200 },
                               { xi.item.RAM_HORN,                100 } },
                    gold   = { { xi.item.CLUMP_OF_SHEEP_WOOL,     200 },
                               { xi.item.RAM_HORN,                150 },
                               { xi.item.WAILING_RAM_HORN,        100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CLUMP_OF_SHEEP_WOOL,      50 } },
                    gold   = { { xi.item.CLUMP_OF_SHEEP_WOOL,     100 },
                               { xi.item.RAM_HORN,                 50 } },
                },
            },
        },

        -----------------------------------
        -- The Konschtat Warlord
        -- A decorated Quadav Shieldwarrior
        -- storms out of Beadeaux at the head
        -- of a shield wall, seeking to hold
        -- the highland approaches to Bastok.
        -----------------------------------
        {
            id          = "KH_BOSS_02",
            name        = "The Konschtat Warlord",
            level       = 26,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The clatter of Quadav armour rings across the Konschtat Highlands...",
                "A wall of shields crests the hill - a veteran Quadav commander leads the advance...",
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
                radius = 88,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 108

            mobs =
            {
                {
                    base         = { 108, 13 }, -- TODO: verify mob_groups (Quadav Warlord)
                    name         = string.char(0xA6) .. "Stone Warlord",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
                {
                    base        = { 108, 8 },  -- TODO: verify mob_groups (Sapphire Quadav)
                    name        = string.char(0xA6) .. "Blue Quadav",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2500 },
                    silver = { exp = 1250 },
                    bronze = { exp = 625  },
                },
                fail =
                {
                    gold   = { exp = 625 },
                    silver = { exp = 310 },
                    bronze = { exp = 155 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.QUADAV_HELM },
                    bronze = { { xi.item.QUADAV_HELM,             240 },
                               { xi.item.BONE_CHIP,               150 } },
                    silver = { { xi.item.QUADAV_HELM,             240 },
                               { xi.item.BONE_CHIP,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.QUADAV_HELM,             240 },
                               { xi.item.BONE_CHIP,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.WAILING_RAM_HORN,        100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.QUADAV_HELM,              50 } },
                    gold   = { { xi.item.QUADAV_HELM,             100 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- The Konschtat Behemoth
        -- A Stone Eater of record-breaking
        -- size that has been gnawing the
        -- iron ore veins beneath the highlands
        -- for centuries surfaces without
        -- warning. Spawns rarely. Move fast.
        -----------------------------------
        {
            id          = "KH_BOSS_03",
            name        = "The Konschtat Behemoth",
            level       = 32,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "Iron ore shards erupt from the highland floor as if fired from a cannon...",
                "The bedrock of the Konschtat Highlands splits open and something immense surges up...",
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
                radius = 110,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 108

            mobs =
            {
                {
                    base         = { 108, 5 },  -- TODO: verify mob_groups (Stone Eater / Colossus)
                    name         = string.char(0xA6) .. "Stone Behemoth",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
                {
                    base        = { 108, 6 },  -- TODO: verify mob_groups (Konschtat Bat)
                    name        = string.char(0xA6) .. "Konschtat Bat",
                    count       = 5,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 108
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 5500 },
                    silver = { exp = 2750 },
                    bronze = { exp = 1375 },
                },
                fail =
                {
                    gold   = { exp = 1375 },
                    silver = { exp = 685  },
                    bronze = { exp = 340  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.CHUNK_OF_MYTHRIL_ORE },
                    bronze = { { xi.item.CHUNK_OF_IRON_ORE,       240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 } },
                    silver = { { xi.item.CHUNK_OF_IRON_ORE,       240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.CRAWLER_CALCULUS,        150 } },
                    gold   = { { xi.item.CHUNK_OF_IRON_ORE,       240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.CRAWLER_CALCULUS,        200 },
                               { xi.item.QUADAV_HELM,             150 },
                               { xi.item.SILK_THREAD,             100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CHUNK_OF_IRON_ORE,        50 } },
                    gold   = { { xi.item.CHUNK_OF_IRON_ORE,       100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,     50 } },
                },
            },
        },
    },
}
