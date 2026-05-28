-----------------------------------
-- FATE Zone: West Ronfaure
-- Zone ID: 100
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.WEST_RONFAURE] =
{
    zoneName    = "West_Ronfaure",
    spawnChance = 0.35,
    minCooldown = 600,

    events =
    {
        -----------------------------------
        -- Orcish Advance
        -- A band of Orcish Fodder pushes
        -- south through the Ronfaure forest.
        -----------------------------------
        {
            id          = "WR_ORC_01",
            name        = "Orcish Advance",
            level       = 7,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "WR_ORC_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = -150,
                y      = 3,
                z      = 100,
                radius = 55,
            },

            entryPos = { x = -130, y = 4, z = 75, rot = 180 },

            mobs =
            {
                {
                    base        = { 100, 12 },
                    name        = "Orcish Fodder",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = -155, y = 3, z = 108, rot = 200 },
                        { x = -138, y = 3, z = 95,  rot = 45  },
                        { x = -162, y = 3, z = 92,  rot = 127 },
                        { x = -145, y = 3, z = 115, rot = 90  },
                    },
                },
                {
                    base        = { 100, 13 },
                    name        = "Orcish Grappler",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -148, y = 3, z = 88,  rot = 225 },
                        { x = -165, y = 3, z = 105, rot = 143 },
                        { x = -135, y = 3, z = 112, rot = 45  },
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
                    gold   = { exp = 175 },
                    silver = { exp = 87  },
                    bronze = { exp = 43  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.WILD_RABBIT_TAIL,     240 } },
                    silver = { { xi.item.RABBIT_HIDE,          150 },
                               { xi.item.WILD_RABBIT_TAIL,     240 } },
                    gold   = { { xi.item.RABBIT_HIDE,          150 },
                               { xi.item.BAT_WING,             100 },
                               { xi.item.MAPLE_LOG,            100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.WILD_RABBIT_TAIL,      50 } },
                    gold   = { { xi.item.WILD_RABBIT_TAIL,     100 } },
                },
            },
        },

        -----------------------------------
        -- Orcish War Band
        -- Chains from Orcish Advance.
        -- A veteran unit led by an Orcish
        -- Mesmerizer closes the advance.
        -----------------------------------
        {
            id          = "WR_ORC_02",
            name        = "Orcish War Band",
            level       = 9,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 4 },

            area =
            {
                x      = -150,
                y      = 3,
                z      = 100,
                radius = 55,
            },

            entryPos = { x = -130, y = 4, z = 75, rot = 180 },

            mobs =
            {
                {
                    base        = { 100, 13 },
                    name        = "Orcish Grappler",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = -152, y = 3, z = 102, rot = 90  },
                        { x = -140, y = 3, z = 110, rot = 225 },
                    },
                },
                {
                    base        = { 100, 17 },
                    name        = "Orcish Mesmerizer",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = -160, y = 3, z = 95,  rot = 45  },
                        { x = -145, y = 3, z = 88,  rot = 143 },
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
                    bronze = { { xi.item.WILD_RABBIT_TAIL,     150 } },
                    silver = { { xi.item.RABBIT_HIDE,          100 },
                               { xi.item.WILD_RABBIT_TAIL,     150 } },
                    gold   = { { xi.item.RABBIT_HIDE,          150 },
                               { xi.item.BAT_WING,             150 },
                               { xi.item.MAPLE_LOG,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.WILD_RABBIT_TAIL,      50 } },
                    gold   = { { xi.item.RABBIT_HIDE,           50 } },
                },
            },
        },

        -----------------------------------
        -- Bat Swarm
        -- Colonies of bats descend from the
        -- forest canopy into the open paths.
        -----------------------------------
        {
            id          = "WR_BEAST_01",
            name        = "Batty Business",
            level       = 5,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 50,
                y      = 2,
                z      = -80,
                radius = 50,
            },

            entryPos = { x = 70, y = 2, z = -100, rot = 45 },

            mobs =
            {
                {
                    base        = { 100, 8 },
                    name        = "Ding Bats",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = 52,  y = 2, z = -85, rot = 90  },
                        { x = 65,  y = 2, z = -72, rot = 200 },
                        { x = 42,  y = 2, z = -75, rot = 45  },
                    },
                },
                {
                    base        = { 100, 14 },
                    name        = "Mouse Bat",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 58,  y = 2, z = -90, rot = 143 },
                        { x = 45,  y = 2, z = -82, rot = 225 },
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
                               { xi.item.WILD_RABBIT_TAIL,     100 } },
                    gold   = { { xi.item.BAT_WING,             240 },
                               { xi.item.RABBIT_HIDE,          100 },
                               { xi.item.MAPLE_LOG,            100 } },
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

        -----------------------------------
        -- Rabbit Stampede
        -- A herd of wild rabbits and forest
        -- hares overruns the trade road.
        -----------------------------------
        {
            id          = "WR_BEAST_02",
            name        = "Hare-Raising Havoc",
            level       = 4,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 12 },

            area =
            {
                x      = -80,
                y      = 1,
                z      = -150,
                radius = 55,
            },

            entryPos = { x = -60, y = 1, z = -130, rot = 225 },

            mobs =
            {
                {
                    base        = { 100, 6 },
                    name        = "Wild Rabbit",
                    count       = 8,
                    spawnPoints =
                    {
                        { x = -82,  y = 1, z = -155, rot = 90  },
                        { x = -68,  y = 1, z = -142, rot = 200 },
                        { x = -92,  y = 1, z = -145, rot = 45  },
                        { x = -75,  y = 1, z = -162, rot = 127 },
                    },
                },
                {
                    base        = { 100, 9 },
                    name        = "Forest Hare",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -88,  y = 1, z = -138, rot = 225 },
                        { x = -72,  y = 1, z = -158, rot = 143 },
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 800  },
                    silver = { exp = 400  },
                    bronze = { exp = 200  },
                },
                fail =
                {
                    gold   = { exp = 125 },
                    silver = { exp = 62  },
                    bronze = { exp = 31  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.WILD_RABBIT_TAIL,     240 } },
                    silver = { { xi.item.WILD_RABBIT_TAIL,     240 },
                               { xi.item.RABBIT_HIDE,          150 } },
                    gold   = { { xi.item.WILD_RABBIT_TAIL,     240 },
                               { xi.item.RABBIT_HIDE,          150 },
                               { xi.item.HIGH_QUALITY_RABBIT_HIDE, 50 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.WILD_RABBIT_TAIL,      50 } },
                    gold   = { { xi.item.WILD_RABBIT_TAIL,     100 } },
                },
            },
        },

        -----------------------------------
        -- Goblin Ambush
        -- Goblins lurking in the Ronfaure
        -- woods waylay passing travellers.
        -----------------------------------
        {
            id          = "WR_GOBLIN_01",
            name        = "Goblin Ambush",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 7 },

            area =
            {
                x      = 120,
                y      = 3,
                z      = 120,
                radius = 50,
            },

            entryPos = { x = 140, y = 3, z = 100, rot = 200 },

            mobs =
            {
                {
                    base        = { 100, 19 },
                    name        = "Goblin Thug",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 122, y = 3, z = 125, rot = 200 },
                        { x = 108, y = 3, z = 115, rot = 45  },
                        { x = 130, y = 3, z = 112, rot = 127 },
                    },
                },
                {
                    base        = { 100, 20 },
                    name        = "Goblin Weaver",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 115, y = 3, z = 128, rot = 90  },
                        { x = 128, y = 3, z = 108, rot = 225 },
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
                    gold   = { exp = 190 },
                    silver = { exp = 95  },
                    bronze = { exp = 47  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.WILD_RABBIT_TAIL,     150 } },
                    silver = { { xi.item.RABBIT_HIDE,          100 },
                               { xi.item.WILD_RABBIT_TAIL,     150 } },
                    gold   = { { xi.item.RABBIT_HIDE,          150 },
                               { xi.item.BAT_WING,             100 },
                               { xi.item.MAPLE_LOG,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.WILD_RABBIT_TAIL,      50 } },
                    gold   = { { xi.item.WILD_RABBIT_TAIL,     100 } },
                },
            },
        },

        -----------------------------------
        -- Worm Emergence
        -- Tunnel worms and carrion worms
        -- erupt from the forest floor.
        -----------------------------------
        {
            id          = "WR_BEAST_03",
            name        = "Can of Worms",
            level       = 5,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = -200,
                y      = 2,
                z      = -50,
                radius = 50,
            },

            entryPos = { x = -180, y = 2, z = -70, rot = 45 },

            mobs =
            {
                {
                    base        = { 100, 7 },
                    name        = "Tunnel Worm",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = -202, y = 2, z = -55, rot = 90  },
                        { x = -188, y = 2, z = -42, rot = 200 },
                        { x = -212, y = 2, z = -45, rot = 45  },
                    },
                },
                {
                    base        = { 100, 10 },
                    name        = "Carrion Worm",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -195, y = 2, z = -60, rot = 143 },
                        { x = -208, y = 2, z = -52, rot = 225 },
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
                    bronze = { { xi.item.WILD_RABBIT_TAIL,     150 } },
                    silver = { { xi.item.WILD_RABBIT_TAIL,     150 },
                               { xi.item.RABBIT_HIDE,          100 } },
                    gold   = { { xi.item.RABBIT_HIDE,          150 },
                               { xi.item.MAPLE_LOG,            150 },
                               { xi.item.BAT_WING,             100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.WILD_RABBIT_TAIL,      50 } },
                    gold   = { { xi.item.WILD_RABBIT_TAIL,     100 } },
                },
            },
        },
    },
}
