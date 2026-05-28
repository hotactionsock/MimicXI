-----------------------------------
-- FATE Zone: South Gustaberg
-- Zone ID: 107
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.SOUTH_GUSTABERG] =
{
    zoneName    = "South_Gustaberg",
    spawnChance = 0.35,
    minCooldown = 600,

    events =
    {
        -----------------------------------
        -- Goblin Assault
        -- A band of goblins from Beadeaux
        -- pushes toward Bastok Outskirts.
        -----------------------------------
        {
            id          = "SG_GOBLIN_01",
            name        = "Goblin Assault",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "SG_GOBLIN_02",
            progressVal = 1,

            objective = { type = "kill", count = 12 },

            area =
            {
                x      = -260,
                y      = -21,
                z      = -150,
                radius = 55,
            },

            entryPos = { x = -91.489, y = 11.053, z = -260.794, rot = 120 },

            mobs =
            {
                {
                    base        = { 107, 13 },
                    name        = "Goblin Thug",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = -88,  y = 10, z = -268, rot = 143 },
                        { x = -108, y = 10, z = -268, rot = 143 },
                    },
                },
                {
                    base        = { 107, 16 },
                    name        = "Goblin Weaver",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = -95, y = 10, z = -248, rot = 143 },
                        { x = -95, y = 10, z = -288, rot = 143 },
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1200 },
                    silver = { exp = 600  },
                    bronze = { exp = 300  },
                },
                fail =
                {
                    gold   = { exp = 200 },
                    silver = { exp = 100 },
                    bronze = { exp = 50  },
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
        -- Goblin War Party
        -- Chains from Goblin Assault.
        -- A more organised follow-up wave
        -- led by a Goblin Digger.
        -----------------------------------
        {
            id          = "SG_GOBLIN_02",
            name        = "Goblin War Party",
            level       = 10,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 4 },

            area =
            {
                x      = -260,
                y      = -21,
                z      = -150,
                radius = 55,
            },

            entryPos = { x = -245, y = -21, z = -140, rot = 128 },

            mobs =
            {
                {
                    base        = { 107, 31 },
                    name        = "Goblin Digger",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = -252, y = -21, z = -130, rot = 45  },
                        { x = -270, y = -21, z = -165, rot = 127 },
                    },
                },
                {
                    base        = { 107, 26 },
                    name        = "Goblin Fisher",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = -280, y = -21, z = -140, rot = 200 },
                        { x = -258, y = -21, z = -160, rot = 70  },
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
                    silver = { exp = 150 },
                    bronze = { exp = 75  },
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
                               { xi.item.CHUNK_OF_COPPER_ORE, 100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,           100 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,         50 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Incursion
        -- Young Quadav pushing out of
        -- Palborough Mines into the zone.
        -----------------------------------
        {
            id          = "SG_QUADAV_01",
            name        = "Quadav Incursion",
            level       = 12,
            duration    = 720,
            chainOnly   = false,
            chainOnWin  = "SG_QUADAV_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 210,
                y      = 1,
                z      = 260,
                radius = 60,
            },

            entryPos = { x = 225, y = 1, z = 250, rot = 0 },

            mobs =
            {
                {
                    base        = { 107, 23 },
                    name        = "Young Quadav",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = 255, y = 2, z = 262, rot = 127 },
                        { x = 199, y = 0, z = 270, rot = 64  },
                        { x = 176, y = 1, z = 259, rot = 190 },
                        { x = 185, y = 2, z = 254, rot = 45  },
                        { x = 220, y = 1, z = 275, rot = 100 },
                        { x = 235, y = 2, z = 245, rot = 220 },
                    },
                },
                {
                    base        = { 107, 24 },
                    name        = "Amethyst Quadav",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 210, y = 1, z = 268, rot = 0   },
                        { x = 195, y = 1, z = 255, rot = 127 },
                        { x = 225, y = 2, z = 252, rot = 64  },
                        { x = 202, y = 1, z = 280, rot = 200 },
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
                    silver = { { xi.item.QUADAV_HELM,          100 },
                               { xi.item.BONE_CHIP,            150 } },
                    gold   = { { xi.item.QUADAV_HELM,          150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE, 100 },
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
        -- Shell Shock
        -- Chains from Quadav Incursion.
        -- Veteran Quadav push hard to hold
        -- the ground their scouts secured.
        -----------------------------------
        {
            id          = "SG_QUADAV_02",
            name        = "Shell Shock",
            level       = 14,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 210,
                y      = 1,
                z      = 260,
                radius = 60,
            },

            entryPos = { x = 225, y = 1, z = 250, rot = 0 },

            mobs =
            {
                {
                    base        = { 107, 24 },
                    name        = "Amethyst Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 208, y = 1, z = 265, rot = 200 },
                        { x = 220, y = 1, z = 255, rot = 60  },
                        { x = 232, y = 2, z = 270, rot = 130 },
                    },
                },
                {
                    base        = { 107, 25 },
                    name        = "Amber Quadav",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = 215, y = 1, z = 248, rot = 40  },
                        { x = 200, y = 1, z = 272, rot = 170 },
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
                    silver = { exp = 175 },
                    bronze = { exp = 88  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,             150 } },
                    silver = { { xi.item.QUADAV_HELM,           150 },
                               { xi.item.BONE_CHIP,             150 } },
                    gold   = { { xi.item.QUADAV_HELM,           200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,  150 },
                               { xi.item.BONE_CHIP,             150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,             100 } },
                    gold   = { { xi.item.QUADAV_HELM,            75 } },
                },
            },
        },

        -----------------------------------
        -- Fledermaus Frenzy
        -- Bat colonies disturbed by Quadav
        -- digging flood the rocky gullies.
        -----------------------------------
        {
            id          = "SG_BEAST_01",
            name        = "Fledermaus Frenzy",
            level       = 6,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = -80,
                y      = 5,
                z      = 120,
                radius = 50,
            },

            entryPos = { x = -70, y = 5, z = 110, rot = 0 },

            mobs =
            {
                {
                    base        = { 107, 9 },
                    name        = "Ding Bats",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = -75,  y = 5, z = 125, rot = 90  },
                        { x = -90,  y = 5, z = 115, rot = 180 },
                        { x = -65,  y = 5, z = 130, rot = 270 },
                    },
                },
                {
                    base        = { 107, 14 },
                    name        = "Fledermaus",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -82,  y = 5, z = 108, rot = 45  },
                        { x = -95,  y = 5, z = 128, rot = 135 },
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
                    gold   = { exp = 150 },
                    silver = { exp = 75  },
                    bronze = { exp = 38  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BAT_WING,          240 } },
                    silver = { { xi.item.BAT_WING,          240 },
                               { xi.item.CHUNK_OF_ZINC_ORE, 100 } },
                    gold   = { { xi.item.BAT_WING,          240 },
                               { xi.item.CHUNK_OF_ZINC_ORE, 150 },
                               { xi.item.BONE_CHIP,         150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BAT_WING,           50 } },
                    gold   = { { xi.item.BAT_WING,          100 } },
                },
            },
        },

        -----------------------------------
        -- Lizard Landslide
        -- Rock lizards and carrion birds
        -- stir from the southern crags.
        -----------------------------------
        {
            id          = "SG_BEAST_02",
            name        = "Lizard Landslide",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 100,
                y      = -5,
                z      = -80,
                radius = 55,
            },

            entryPos = { x = 110, y = -5, z = -70, rot = 180 },

            mobs =
            {
                {
                    base        = { 107, 20 },
                    name        = "Rock Lizard",
                    count       = 7,
                    spawnPoints =
                    {
                        { x = 95,  y = -5, z = -85,  rot = 200 },
                        { x = 112, y = -5, z = -75,  rot = 45  },
                        { x = 88,  y = -5, z = -70,  rot = 130 },
                        { x = 105, y = -5, z = -95,  rot = 310 },
                    },
                },
                {
                    base        = { 107, 22 },
                    name        = "Vulture",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 100, y = -4, z = -65,  rot = 270 },
                        { x = 118, y = -4, z = -88,  rot = 90  },
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1200 },
                    silver = { exp = 600  },
                    bronze = { exp = 300  },
                },
                fail =
                {
                    gold   = { exp = 200 },
                    silver = { exp = 100 },
                    bronze = { exp = 50  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.LIZARD_SKIN,           240 } },
                    silver = { { xi.item.LIZARD_SKIN,           240 },
                               { xi.item.LIZARD_TAIL,           150 } },
                    gold   = { { xi.item.LIZARD_SKIN,           240 },
                               { xi.item.LIZARD_TAIL,           200 },
                               { xi.item.CHUNK_OF_IRON_ORE,     150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LIZARD_SKIN,            50 } },
                    gold   = { { xi.item.LIZARD_SKIN,           100 } },
                },
            },
        },
    },
}
