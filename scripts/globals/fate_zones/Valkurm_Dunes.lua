-----------------------------------
-- FATE Zone: Valkurm Dunes
-- Zone ID: 103
-- Region pool: STARTER_ZULKHEIM
-- Level range: 15-28
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.VALKURM_DUNES] =
{
    zoneName    = "Valkurm_Dunes",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Lizard Stampede
        -- Dune Lizards and Sand Lizards
        -- surge out of the dunes in numbers,
        -- drawn by the heat and the scent
        -- of unwary adventurers.
        -----------------------------------
        {
            id          = "VD_LIZARD_01",
            name        = "Lizard Stampede",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 103

            mobs =
            {
                {
                    base        = { 103, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Dune Lizard",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                    },
                },
                {
                    base        = { 103, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Sand Lizard",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
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
                    bronze = { { xi.item.LIZARD_TAIL,            240 } },
                    silver = { { xi.item.LIZARD_TAIL,            240 },
                               { xi.item.LIZARD_EGG,             150 } },
                    gold   = { { xi.item.LIZARD_TAIL,            240 },
                               { xi.item.LIZARD_EGG,             200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LIZARD_TAIL,             50 } },
                    gold   = { { xi.item.LIZARD_TAIL,            100 } },
                },
            },
        },

        -----------------------------------
        -- The Dune Emperor
        -- The legendary Valkurm Emperor,
        -- a bee of monstrous proportions,
        -- descends on the dunes trailing
        -- a swarm of Dune Flies.
        -----------------------------------
        {
            id          = "VD_BOSS_01",
            name        = "The Dune Emperor",
            level       = 26,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A distant droning fills the air above the Valkurm Dunes...",
                "The droning becomes a roar - a shadow blots out the sun over the dunes...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 103

            mobs =
            {
                {
                    base         = { 103, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Dunes Emperor",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                    },
                },
                {
                    base        = { 103, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Dune Fly",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
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
                    guaranteed = { xi.item.BEEHIVE_CHIP },
                    bronze = { { xi.item.BEEHIVE_CHIP,           240 },
                               { xi.item.INSECT_WING,            150 } },
                    silver = { { xi.item.BEEHIVE_CHIP,           240 },
                               { xi.item.INSECT_WING,            200 },
                               { xi.item.GIANT_STINGER,          100 } },
                    gold   = { { xi.item.GIANT_STINGER,          150 },
                               { xi.item.BEEHIVE_CHIP,           240 },
                               { xi.item.INSECT_WING,            200 },
                               { xi.item.LIZARD_TAIL,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEEHIVE_CHIP,            50 } },
                    gold   = { { xi.item.BEEHIVE_CHIP,           100 },
                               { xi.item.INSECT_WING,             50 } },
                },
            },
        },

        -----------------------------------
        -- Goblin Beachhead
        -- Goblin Gamblers and Traders set
        -- up a fortified trading post on
        -- the beach, preying on travellers
        -- passing between the dunes.
        -----------------------------------
        {
            id          = "VD_GOBLIN_01",
            name        = "Goblin Beachhead",
            level       = 18,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "VD_GOBLIN_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 103

            mobs =
            {
                {
                    base        = { 103, 5 },  -- TODO: verify mob_groups (Goblin Gambler)
                    name        = string.char(0xA6) .. "Goblin Gambler",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                    },
                },
                {
                    base        = { 103, 6 },  -- TODO: verify mob_groups (Goblin Trader)
                    name        = string.char(0xA6) .. "Goblin Trader",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
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
                    gold   = { { xi.item.GOBLIN_ARMOR,            100 } },
                },
            },
        },

        -----------------------------------
        -- Goblin Strike Force
        -- Chains from Goblin Beachhead.
        -- Goblin Smithies and Muggers arrive
        -- to reinforce the beachhead and
        -- avenge their fallen comrades.
        -----------------------------------
        {
            id          = "VD_GOBLIN_02",
            name        = "Goblin Strike Force",
            level       = 21,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 103

            mobs =
            {
                {
                    base        = { 103, 7 },  -- TODO: verify mob_groups (Goblin Smithy)
                    name        = string.char(0xA6) .. "Goblin Smithy",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                    },
                },
                {
                    base        = { 103, 8 },  -- TODO: verify mob_groups (Goblin Mugger)
                    name        = string.char(0xA6) .. "Goblin Mugger",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
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
                    bronze = { { xi.item.GOBLIN_ARMOR,            100 } },
                    silver = { { xi.item.GOBLIN_ARMOR,            200 },
                               { xi.item.GOBLIN_MASK,             100 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,            200 },
                               { xi.item.GOBLIN_MASK,             150 },
                               { xi.item.CHUNK_OF_IRON_ORE,       150 } },
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
        -- Leech Tide
        -- A tide of Bog Leeches and Sea
        -- Leeches emerges from the coastal
        -- pools at high tide and begins
        -- swarming across the dunes.
        -----------------------------------
        {
            id          = "VD_LEECH_01",
            name        = "Leech Tide",
            level       = 19,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 103

            mobs =
            {
                {
                    base        = { 103, 9 },  -- TODO: verify mob_groups (Sea Leech)
                    name        = string.char(0xA6) .. "Sea Leech",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                    },
                },
                {
                    base        = { 103, 4 },  -- TODO: verify mob_groups (Dune Fly)
                    name        = string.char(0xA6) .. "Dune Fly",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 950 },
                    silver = { exp = 475 },
                    bronze = { exp = 235 },
                },
                fail =
                {
                    gold   = { exp = 235 },
                    silver = { exp = 115 },
                    bronze = { exp = 55  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.LEECH_SALIVA,            150 } },
                    silver = { { xi.item.LEECH_SALIVA,            200 },
                               { xi.item.INSECT_WING,             100 } },
                    gold   = { { xi.item.LEECH_SALIVA,            200 },
                               { xi.item.INSECT_WING,             150 },
                               { xi.item.GIANT_STINGER,           100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LEECH_SALIVA,             50 } },
                    gold   = { { xi.item.LEECH_SALIVA,            100 } },
                },
            },
        },

        -----------------------------------
        -- The Dune Scourge
        -- A giant Orobon hauls out of the
        -- sea and begins advancing across
        -- the dunes, devouring anything
        -- in its enormous mouth.
        -----------------------------------
        {
            id          = "VD_BOSS_02",
            name        = "The Dune Scourge",
            level       = 23,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The sea off the Valkurm Dunes froths and churns without cause...",
                "A colossal mouth breaks the surface and hauls itself toward the shore...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 103

            mobs =
            {
                {
                    base         = { 103, 10 }, -- TODO: verify mob_groups (Orobon)
                    name         = string.char(0xA6) .. "Dune Scourge",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                    },
                },
                {
                    base        = { 103, 9 },  -- TODO: verify mob_groups (Sea Leech)
                    name        = string.char(0xA6) .. "Sea Leech",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
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
                    guaranteed = { xi.item.LIZARD_TAIL },
                    bronze = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.LIZARD_TAIL,             150 } },
                    silver = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.LIZARD_TAIL,             200 },
                               { xi.item.INSECT_WING,             150 } },
                    gold   = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.LIZARD_TAIL,             200 },
                               { xi.item.INSECT_WING,             150 },
                               { xi.item.GIANT_STINGER,           100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LEECH_SALIVA,             50 } },
                    gold   = { { xi.item.LEECH_SALIVA,            100 },
                               { xi.item.INSECT_WING,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Eternal Hunger
        -- An Orobon of mythical proportions
        -- - said to have eaten a ship whole
        -- in the Crystal War - washes ashore
        -- during a violent tide.
        -- Spawns rarely. Escape or die trying.
        -----------------------------------
        {
            id          = "VD_BOSS_03",
            name        = "The Eternal Hunger",
            level       = 30,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A massive waterspout erupts off the Valkurm coast without warning...",
                "The spout crashes down and from the churning foam crawls something impossibly vast...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 103

            mobs =
            {
                {
                    base         = { 103, 10 }, -- TODO: verify mob_groups (Orobon family)
                    name         = string.char(0xA6) .. "Eternal Hunger",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                    },
                },
                {
                    base        = { 103, 2 },  -- TODO: verify mob_groups (Sand Lizard)
                    name        = string.char(0xA6) .. "Sand Lizard",
                    count       = 5,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 103
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
                    guaranteed = { xi.item.GIANT_STINGER },
                    bronze = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.GIANT_STINGER,           200 } },
                    silver = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.GIANT_STINGER,           200 },
                               { xi.item.BEEHIVE_CHIP,            150 } },
                    gold   = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.GIANT_STINGER,           200 },
                               { xi.item.BEEHIVE_CHIP,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.LIZARD_TAIL,             100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LEECH_SALIVA,             50 } },
                    gold   = { { xi.item.GIANT_STINGER,           100 },
                               { xi.item.LEECH_SALIVA,             50 } },
                },
            },
        },
    },
}
