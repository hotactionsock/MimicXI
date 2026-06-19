-----------------------------------
-- FATE Zone: Tahrongi Canyon
-- Zone ID: 117
-- Region pool: STARTER_ZULKHEIM
-- Level range: 15-25
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.TAHRONGI_CANYON] =
{
    zoneName    = "Tahrongi_Canyon",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Goblin Poachers
        -- A band of Goblin Poachers and
        -- Tinkerers moves through the canyon
        -- trapping wildlife and ambushing
        -- any travellers they find.
        -----------------------------------
        {
            id          = "TC_GOBLIN_01",
            name        = "Goblin Poachers",
            level       = 20,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    base        = { 117, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Goblin Poacher",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
                {
                    base        = { 117, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Goblin Tinker",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
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
                    bronze = { { xi.item.GOBLIN_ARMOR,          150 } },
                    silver = { { xi.item.GOBLIN_ARMOR,          200 },
                               { xi.item.BONE_CHIP,             150 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,          200 },
                               { xi.item.GOBLIN_MASK,           100 },
                               { xi.item.BONE_CHIP,             150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,              50 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,           50 },
                               { xi.item.BONE_CHIP,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Canyon Tyrant
        -- A colossal Crawler queen, bloated
        -- from feasting on canyon fauna,
        -- descends from the upper cliffs
        -- trailing a brood of Crawlerlings.
        -----------------------------------
        {
            id          = "TC_BOSS_01",
            name        = "The Canyon Tyrant",
            level       = 24,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A faint chittering echoes from the upper cliffs of Tahrongi...",
                "The chittering grows deafening - something immense descends the canyon walls...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    base         = { 117, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Canyon Tyrant",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
                {
                    base        = { 117, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Crawlerling",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
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
                    guaranteed = { xi.item.CRAWLER_CALCULUS },
                    bronze = { { xi.item.CRAWLER_CALCULUS,     240 },
                               { xi.item.SILK_THREAD,          150 } },
                    silver = { { xi.item.CRAWLER_CALCULUS,     240 },
                               { xi.item.SILK_THREAD,          200 },
                               { xi.item.CHUNK_OF_IRON_ORE,    150 } },
                    gold   = { { xi.item.CRAWLER_CALCULUS,     240 },
                               { xi.item.SILK_THREAD,          200 },
                               { xi.item.CHUNK_OF_IRON_ORE,    200 },
                               { xi.item.GOBLIN_ARMOR,         100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CRAWLER_CALCULUS,      50 } },
                    gold   = { { xi.item.CRAWLER_CALCULUS,     100 },
                               { xi.item.SILK_THREAD,           50 } },
                },
            },
        },

        -----------------------------------
        -- Dhalmel Frenzy
        -- Dhalmels spooked by canyon echoes
        -- stampede through the lower gorge,
        -- trampling campsites and blocking
        -- the path between plateaus.
        -----------------------------------
        {
            id          = "TC_DHALMEL_01",
            name        = "Dhalmel Frenzy",
            level       = 18,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    base        = { 117, 5 },  -- TODO: verify mob_groups (Dhalmel)
                    name        = string.char(0xA6) .. "Canyon Dhalmel",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
                {
                    base        = { 117, 6 },  -- TODO: verify mob_groups (Canyon Lizard)
                    name        = string.char(0xA6) .. "Canyon Lizard",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 900 },
                    silver = { exp = 450 },
                    bronze = { exp = 225 },
                },
                fail =
                {
                    gold   = { exp = 225 },
                    silver = { exp = 115 },
                    bronze = { exp = 55  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.DHALMEL_HIDE,            150 } },
                    silver = { { xi.item.DHALMEL_HIDE,            200 },
                               { xi.item.LIZARD_TAIL,             100 } },
                    gold   = { { xi.item.DHALMEL_HIDE,            200 },
                               { xi.item.LIZARD_TAIL,             150 },
                               { xi.item.CHUNK_OF_IRON_ORE,       100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DHALMEL_HIDE,             50 } },
                    gold   = { { xi.item.DHALMEL_HIDE,            100 } },
                },
            },
        },

        -----------------------------------
        -- Mandragora Uprising
        -- Mandragoras burst from the canyon
        -- soil in unusually high numbers,
        -- shrieking to disorient anyone
        -- who comes near.
        -----------------------------------
        {
            id          = "TC_MANDRAGORA_01",
            name        = "Mandragora Uprising",
            level       = 20,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "TC_MANDRAGORA_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    base        = { 117, 7 },  -- TODO: verify mob_groups (Mandragora)
                    name        = string.char(0xA6) .. "Canyon Mandra",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
                {
                    base        = { 117, 8 },  -- TODO: verify mob_groups (Mousse/Flytrap)
                    name        = string.char(0xA6) .. "Flytrap",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
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
                    bronze = { { xi.item.TWO_LEAF_MANDRAGORA_BUD,  150 } },
                    silver = { { xi.item.TWO_LEAF_MANDRAGORA_BUD,  200 },
                               { xi.item.THREE_LEAF_MANDRAGORA_BUD, 100 } },
                    gold   = { { xi.item.TWO_LEAF_MANDRAGORA_BUD,  200 },
                               { xi.item.THREE_LEAF_MANDRAGORA_BUD, 150 },
                               { xi.item.CHUNK_OF_IRON_ORE,         100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TWO_LEAF_MANDRAGORA_BUD,   50 } },
                    gold   = { { xi.item.TWO_LEAF_MANDRAGORA_BUD,  100 } },
                },
            },
        },

        -----------------------------------
        -- Mandragora Elder Choir
        -- Chains from Mandragora Uprising.
        -- Larger, elder Mandragoras descend
        -- from the cliff shelves to drive
        -- off whatever disturbed the young.
        -----------------------------------
        {
            id          = "TC_MANDRAGORA_02",
            name        = "Mandragora Elder Choir",
            level       = 22,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    base        = { 117, 9 },  -- TODO: verify mob_groups (elder mandragora)
                    name        = string.char(0xA6) .. "Old Mandragora",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
                {
                    base        = { 117, 10 }, -- TODO: verify mob_groups (Canyon Funguar)
                    name        = string.char(0xA6) .. "Canyon Funguar",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
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
                    bronze = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 100 } },
                    silver = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 200 },
                               { xi.item.FOUR_LEAF_MANDRAGORA_BUD,  100 } },
                    gold   = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 200 },
                               { xi.item.FOUR_LEAF_MANDRAGORA_BUD,  150 },
                               { xi.item.CHUNK_OF_IRON_ORE,          100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TWO_LEAF_MANDRAGORA_BUD,   50 } },
                    gold   = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 100 } },
                },
            },
        },

        -----------------------------------
        -- Goblin Black Market
        -- A second Goblin crew sets up a
        -- fortified contraband post midway
        -- through the canyon, reinforced
        -- with traps and sentries.
        -----------------------------------
        {
            id          = "TC_GOBLIN_02",
            name        = "Goblin Black Market",
            level       = 22,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    base        = { 117, 2 },  -- TODO: verify mob_groups (Goblin Tinkerer)
                    name        = string.char(0xA6) .. "Goblin Tinker",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
                {
                    base        = { 117, 11 }, -- TODO: verify mob_groups (Goblin Gamblertype)
                    name        = string.char(0xA6) .. "Goblin Gambler",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
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
                    bronze = { { xi.item.GOBLIN_ARMOR,            150 } },
                    silver = { { xi.item.GOBLIN_ARMOR,            200 },
                               { xi.item.GOBLIN_MASK,             100 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,            200 },
                               { xi.item.GOBLIN_MASK,             150 },
                               { xi.item.CHUNK_OF_IRON_ORE,       100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.GOBLIN_ARMOR,             50 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,            100 },
                               { xi.item.GOBLIN_MASK,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Canyon Empress
        -- A second boss: a monstrous
        -- Canyon Dhalmel of legendary
        -- aggression stampedes through
        -- the main gorge, pursued by
        -- a pack of Canyon Lizards.
        -----------------------------------
        {
            id          = "TC_BOSS_02",
            name        = "The Canyon Empress",
            level       = 22,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "Thundering hoofbeats boom through the lower canyon of Tahrongi...",
                "Stones clatter off the cliff walls - something enormous is charging down the gorge...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    base         = { 117, 5 },  -- TODO: verify mob_groups (Dhalmel)
                    name         = string.char(0xA6) .. "Canyon Empress",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
                {
                    base        = { 117, 6 },  -- TODO: verify mob_groups
                    name        = string.char(0xA6) .. "Canyon Lizard",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
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
                    guaranteed = { xi.item.DHALMEL_HIDE },
                    bronze = { { xi.item.DHALMEL_HIDE,            240 },
                               { xi.item.LIZARD_TAIL,             150 } },
                    silver = { { xi.item.DHALMEL_HIDE,            240 },
                               { xi.item.LIZARD_TAIL,             200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       150 } },
                    gold   = { { xi.item.DHALMEL_HIDE,            240 },
                               { xi.item.LIZARD_TAIL,             200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       200 },
                               { xi.item.GOBLIN_ARMOR,            100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DHALMEL_HIDE,             50 } },
                    gold   = { { xi.item.DHALMEL_HIDE,            100 },
                               { xi.item.LIZARD_TAIL,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Eternal Sentinel
        -- A Stone Eater of primordial age
        -- that has occupied the canyon's
        -- deepest fault since before the
        -- founding of Windurst awakens.
        -- Spawns rarely. Its body is the canyon.
        -----------------------------------
        {
            id          = "TC_BOSS_03",
            name        = "The Eternal Sentinel",
            level       = 28,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The walls of Tahrongi Canyon begin to crack and groan with unnatural force...",
                "A massive fissure opens in the canyon floor - something geological rises from below...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    base         = { 117, 12 }, -- TODO: verify mob_groups (Stone Eater family)
                    name         = string.char(0xA6) .. "Stone Sentinel",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
                {
                    base        = { 117, 4 },  -- TODO: verify mob_groups (Crawlerling)
                    name        = string.char(0xA6) .. "Crawlerling",
                    count       = 5,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 117
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 5000 },
                    silver = { exp = 2500 },
                    bronze = { exp = 1250 },
                },
                fail =
                {
                    gold   = { exp = 1250 },
                    silver = { exp = 625  },
                    bronze = { exp = 310  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.CRAWLER_CALCULUS },
                    bronze = { { xi.item.CRAWLER_CALCULUS,        240 },
                               { xi.item.DHALMEL_HIDE,            200 } },
                    silver = { { xi.item.CRAWLER_CALCULUS,        240 },
                               { xi.item.DHALMEL_HIDE,            200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       150 } },
                    gold   = { { xi.item.CRAWLER_CALCULUS,        240 },
                               { xi.item.DHALMEL_HIDE,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.FOUR_LEAF_MANDRAGORA_BUD, 150 },
                               { xi.item.GOBLIN_ARMOR,            100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CRAWLER_CALCULUS,         50 } },
                    gold   = { { xi.item.CRAWLER_CALCULUS,        100 },
                               { xi.item.DHALMEL_HIDE,             50 } },
                },
            },
        },
    },
}
