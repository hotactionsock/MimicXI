-----------------------------------
-- FATE Zone: North Gustaberg
-- Zone ID: 106
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.NORTH_GUSTABERG] =
{
    zoneName    = "North_Gustaberg",
    spawnChance = 0.35,
    minCooldown = 600,

    events =
    {
        -----------------------------------
        -- Goblin Scouts
        -- A scouting party of goblins probes
        -- the outskirts of North Gustaberg.
        -----------------------------------
        {
            id          = "NG_GOBLIN_01",
            name        = "Goblin Scouts",
            level       = 7,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "NG_GOBLIN_02",
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = 50,
                y      = 5,
                z      = -150,
                radius = 55,
            },

            entryPos = { x = 80, y = 6, z = -120, rot = 200 },

            mobs =
            {
                {
                    base        = { 106, 12 },
                    name        = "Goblin Thug",
                    count       = 5,
                    spawnPoints =
                    {
                        { x = 45,  y = 5, z = -158, rot = 143 },
                        { x = 62,  y = 5, z = -145, rot = 200 },
                        { x = 38,  y = 5, z = -140, rot = 90  },
                    },
                },
                {
                    base        = { 106, 15 },
                    name        = "Goblin Weaver",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 55,  y = 5, z = -162, rot = 45  },
                        { x = 30,  y = 5, z = -155, rot = 143 },
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
                    gold   = { exp = 180 },
                    silver = { exp = 90  },
                    bronze = { exp = 45  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,           240 } },
                    silver = { { xi.item.GOBLIN_ARMOR,        150 },
                               { xi.item.BONE_CHIP,           240 } },
                    gold   = { { xi.item.GOBLIN_MASK,         100 },
                               { xi.item.GOBLIN_ARMOR,        150 },
                               { xi.item.CHUNK_OF_COPPER_ORE, 150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,            50 } },
                    gold   = { { xi.item.BONE_CHIP,           100 } },
                },
            },
        },

        -----------------------------------
        -- Goblin Muggers
        -- Chains from Goblin Scouts.
        -- Emboldened rogues spring an ambush
        -- on travellers near the pass.
        -----------------------------------
        {
            id          = "NG_GOBLIN_02",
            name        = "Goblin Muggers",
            level       = 9,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 4 },

            area =
            {
                x      = 50,
                y      = 5,
                z      = -150,
                radius = 55,
            },

            entryPos = { x = 80, y = 6, z = -120, rot = 200 },

            mobs =
            {
                {
                    base        = { 106, 30 },
                    name        = "Goblin Mugger",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = 42, y = 5, z = -148, rot = 90  },
                        { x = 60, y = 5, z = -158, rot = 225 },
                    },
                },
                {
                    base        = { 106, 32 },
                    name        = "Goblin Gambler",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = 50, y = 5, z = -140, rot = 45  },
                        { x = 35, y = 5, z = -162, rot = 143 },
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
                    gold   = { exp = 240 },
                    silver = { exp = 120 },
                    bronze = { exp = 60  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,           150 } },
                    silver = { { xi.item.GOBLIN_ARMOR,        100 },
                               { xi.item.BONE_CHIP,           150 } },
                    gold   = { { xi.item.GOBLIN_MASK,         150 },
                               { xi.item.GOBLIN_ARMOR,        100 },
                               { xi.item.CHUNK_OF_ZINC_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,            50 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,         50 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Advance
        -- Young Quadav push out from the
        -- mines toward the surface roads.
        -----------------------------------
        {
            id          = "NG_QUADAV_01",
            name        = "Quadav Advance",
            level       = 12,
            duration    = 720,
            chainOnly   = false,
            chainOnWin  = "NG_QUADAV_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 220,
                y      = 3,
                z      = 180,
                radius = 60,
            },

            entryPos = { x = 200, y = 3, z = 155, rot = 0 },

            mobs =
            {
                {
                    base        = { 106, 22 },
                    name        = "Young Quadav",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = 225, y = 3, z = 188, rot = 200 },
                        { x = 208, y = 3, z = 172, rot = 45  },
                        { x = 238, y = 4, z = 178, rot = 127 },
                        { x = 215, y = 3, z = 195, rot = 90  },
                    },
                },
                {
                    base        = { 106, 23 },
                    name        = "Amber Quadav",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 230, y = 3, z = 170, rot = 127 },
                        { x = 210, y = 3, z = 185, rot = 225 },
                        { x = 242, y = 4, z = 190, rot = 45  },
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
                    gold   = { exp = 250 },
                    silver = { exp = 125 },
                    bronze = { exp = 62  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,            150 } },
                    silver = { { xi.item.QUADAV_HELM,          100 },
                               { xi.item.BONE_CHIP,            150 } },
                    gold   = { { xi.item.QUADAV_HELM,          150 },
                               { xi.item.CHUNK_OF_COPPER_ORE,  100 },
                               { xi.item.BONE_CHIP,            240 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,            100 } },
                    gold   = { { xi.item.QUADAV_HELM,           50 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Elite Guard
        -- Chains from Quadav Advance.
        -- Seasoned warriors move to reinforce
        -- the faltering advance.
        -----------------------------------
        {
            id          = "NG_QUADAV_02",
            name        = "Quadav Elite Guard",
            level       = 14,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 220,
                y      = 3,
                z      = 180,
                radius = 60,
            },

            entryPos = { x = 200, y = 3, z = 155, rot = 0 },

            mobs =
            {
                {
                    base        = { 106, 24 },
                    name        = "Amethyst Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 222, y = 3, z = 185, rot = 45  },
                        { x = 238, y = 3, z = 175, rot = 200 },
                    },
                },
                {
                    base        = { 106, 23 },
                    name        = "Amber Quadav",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = 212, y = 3, z = 178, rot = 127 },
                        { x = 228, y = 4, z = 192, rot = 90  },
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2000 },
                    silver = { exp = 1000 },
                    bronze = { exp = 500  },
                },
                fail =
                {
                    gold   = { exp = 300 },
                    silver = { exp = 150 },
                    bronze = { exp = 75  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,            150 } },
                    silver = { { xi.item.QUADAV_HELM,          150 },
                               { xi.item.BONE_CHIP,            150 } },
                    gold   = { { xi.item.QUADAV_HELM,          150 },
                               { xi.item.QUADAV_CHESTPLATE,    100 },
                               { xi.item.CHUNK_OF_ZINC_ORE,    150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,            100 } },
                    gold   = { { xi.item.QUADAV_HELM,           50 } },
                },
            },
        },

        -----------------------------------
        -- Hornet Swarm
        -- Disturbed hornets pour from the
        -- rocky crags in a fierce swarm.
        -----------------------------------
        {
            id          = "NG_BEAST_01",
            name        = "Hornet Swarm",
            level       = 6,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = -80,
                y      = 8,
                z      = 100,
                radius = 50,
            },

            entryPos = { x = -60, y = 9, z = 80, rot = 180 },

            mobs =
            {
                {
                    base        = { 106, 6 },
                    name        = "Huge Hornet",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = -85, y = 8, z = 105, rot = 90  },
                        { x = -68, y = 8, z = 95,  rot = 225 },
                        { x = -92, y = 8, z = 90,  rot = 45  },
                    },
                },
                {
                    base        = { 106, 9 },
                    name        = "Maneating Hornet",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -75, y = 8, z = 110, rot = 127 },
                        { x = -95, y = 9, z = 102, rot = 200 },
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
                    gold   = { exp = 160 },
                    silver = { exp = 80  },
                    bronze = { exp = 40  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.INSECT_WING,          240 } },
                    silver = { { xi.item.INSECT_WING,          240 },
                               { xi.item.BONE_CHIP,            100 } },
                    gold   = { { xi.item.INSECT_WING,          240 },
                               { xi.item.TRANSPARENT_INSECT_WING, 100 },
                               { xi.item.BONE_CHIP,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.INSECT_WING,           50 } },
                    gold   = { { xi.item.INSECT_WING,          100 } },
                },
            },
        },

        -----------------------------------
        -- Night Stalkers
        -- Bats and worms surface across the
        -- darkening crags of North Gustaberg.
        -----------------------------------
        {
            id          = "NG_BEAST_02",
            name        = "Night Stalkers",
            level       = 5,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 130,
                y      = 2,
                z      = -50,
                radius = 50,
            },

            entryPos = { x = 110, y = 3, z = -70, rot = 45 },

            mobs =
            {
                {
                    base        = { 106, 8 },
                    name        = "Ding Bats",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = 132, y = 2, z = -55, rot = 90  },
                        { x = 145, y = 2, z = -42, rot = 200 },
                        { x = 120, y = 2, z = -48, rot = 45  },
                    },
                },
                {
                    base        = { 106, 7 },
                    name        = "Tunnel Worm",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 128, y = 2, z = -60, rot = 143 },
                        { x = 142, y = 2, z = -52, rot = 225 },
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 900  },
                    silver = { exp = 450  },
                    bronze = { exp = 225  },
                },
                fail =
                {
                    gold   = { exp = 140 },
                    silver = { exp = 70  },
                    bronze = { exp = 35  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BAT_WING,             240 } },
                    silver = { { xi.item.BAT_WING,             240 },
                               { xi.item.BONE_CHIP,            100 } },
                    gold   = { { xi.item.BAT_WING,             240 },
                               { xi.item.CHUNK_OF_COPPER_ORE,  100 },
                               { xi.item.BONE_CHIP,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BAT_WING,              50 } },
                    gold   = { { xi.item.BAT_WING,             100 } },
                },
            },
        },
    },
}
