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
            name        = "Goblin Grabbers",
            level       = 20,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    -- No dedicated poacher template in this zone's mobs.yaml;
                    -- Goblin_Ambusher matches the flavour text ("ambushing
                    -- any travellers they find").
                    templateName = "Goblin_Ambusher",
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
                    templateName = "Goblin_Tinkerer",
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

            area = { 0, 0, 0, 81 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    -- "A colossal Crawler queen" - Canyon_Crawler is this
                    -- zone's own crawler template, scaled up via hpMultiplier/size.
                    templateName = "Canyon_Crawler",
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
                    -- No dedicated crawlerling template; reuses the queen's
                    -- own Canyon_Crawler look for her brood, same treatment
                    -- as Hill Vulture/Carrion Crow in East_Sarutabaruta.lua.
                    templateName = "Canyon_Crawler",
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

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    templateName = "Wild_Dhalmel",
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
                    -- Cross-zone borrow: no reptile/lizard species exists in this zone's own
                    -- mobs.yaml. Konschtat Highlands (adjacent, similar tier) has Mist_Lizard.
                    templateName   = "Mist_Lizard",
                    templateZoneId = xi.zone.KONSCHTAT_HIGHLANDS,
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

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    templateName = "Pygmaioi", -- species: mandragora
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
                    -- No flytrap/funguar template in this zone; Strolling_Sapling
                    -- is the closest plant-type look available.
                    templateName = "Strolling_Sapling",
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

            area = { 0, 0, 0, 60 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    templateName = "Pygmaioi", -- species: mandragora
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
                    -- No funguar template in this zone; reuses the same
                    -- plant look as Flytrap above.
                    templateName = "Strolling_Sapling",
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

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    templateName = "Goblin_Tinkerer",
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
                    -- No gambler-type template; Goblin_Archaeologist gives a
                    -- non-warrior civilian goblin look distinct from the
                    -- Ambusher/Tinkerer already used in this zone's FATEs.
                    templateName = "Goblin_Archaeologist",
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

            area = { 0, 0, 0, 88 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    -- Allocamelus (species: dhalmel) gives the boss a distinct
                    -- named look from the regular Wild_Dhalmel trash mobs.
                    templateName = "Allocamelus",
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
                    -- Cross-zone borrow: no reptile/lizard species exists in this zone's own
                    -- mobs.yaml. Konschtat Highlands (adjacent, similar tier) has Mist_Lizard.
                    templateName   = "Mist_Lizard",
                    templateZoneId = xi.zone.KONSCHTAT_HIGHLANDS,
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

            area = { 0, 0, 0, 110 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 117

            mobs =
            {
                {
                    -- No stone eater/golem template in this zone; the flavour
                    -- text ("something geological rises from below") fits
                    -- Earth_Elemental, this zone's own earth-themed template.
                    templateName = "Earth_Elemental",
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
                    templateName = "Canyon_Crawler",
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
