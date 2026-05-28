-----------------------------------
-- FATE Zone: East Ronfaure
-- Zone ID: 101
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.EAST_RONFAURE] =
{
    zoneName    = "East_Ronfaure",
    spawnChance = 0.35,
    minCooldown = 600,

    events =
    {
        -----------------------------------
        -- Orcish Patrol
        -- A roving patrol of Orcish Fodder
        -- sweeps the eastern forest roads.
        -----------------------------------
        {
            id          = "ER_ORC_01",
            name        = "Orcish Patrol",
            level       = 7,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "ER_ORC_02",
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = 150,
                y      = 2,
                z      = -100,
                radius = 55,
            },

            entryPos = { x = 130, y = 2, z = -75, rot = 180 },

            mobs =
            {
                {
                    base        = { 101, 13 },
                    name        = "Orcish Fodder",
                    count       = 5,
                    spawnPoints =
                    {
                        { x = 155, y = 2, z = -108, rot = 200 },
                        { x = 138, y = 2, z = -95,  rot = 45  },
                        { x = 162, y = 2, z = -92,  rot = 127 },
                    },
                },
                {
                    base        = { 101, 16 },
                    name        = "Orcish Grappler",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 148, y = 2, z = -88,  rot = 225 },
                        { x = 165, y = 2, z = -105, rot = 143 },
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
        -- Orcish Warmongers
        -- Chains from Orcish Patrol.
        -- A hardened unit commanded by an
        -- Orcish Mesmerizer moves to engage.
        -----------------------------------
        {
            id          = "ER_ORC_02",
            name        = "Orcish Warmongers",
            level       = 9,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 4 },

            area =
            {
                x      = 150,
                y      = 2,
                z      = -100,
                radius = 55,
            },

            entryPos = { x = 130, y = 2, z = -75, rot = 180 },

            mobs =
            {
                {
                    base        = { 101, 16 },
                    name        = "Orcish Grappler",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = 152, y = 2, z = -102, rot = 90  },
                        { x = 140, y = 2, z = -110, rot = 225 },
                    },
                },
                {
                    base        = { 101, 15 },
                    name        = "Orcish Mesmerizer",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = 160, y = 2, z = -95,  rot = 45  },
                        { x = 145, y = 2, z = -88,  rot = 143 },
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
        -- Pugil Feeding Frenzy
        -- Pugils thrash along the river banks,
        -- blocking the eastern crossing.
        -----------------------------------
        {
            id          = "ER_BEAST_01",
            name        = "Pugil Feeding Frenzy",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = -100,
                y      = 0,
                z      = 150,
                radius = 55,
            },

            entryPos = { x = -80, y = 0, z = 128, rot = 180 },

            mobs =
            {
                {
                    base        = { 101, 2 },
                    name        = "Cheval Pugil",
                    count       = 5,
                    spawnPoints =
                    {
                        { x = -105, y = 0, z = 158, rot = 90  },
                        { x = -88,  y = 0, z = 145, rot = 200 },
                        { x = -112, y = 0, z = 145, rot = 45  },
                    },
                },
                {
                    base        = { 101, 3 },
                    name        = "Mud Pugil",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -95,  y = 0, z = 162, rot = 127 },
                        { x = -115, y = 0, z = 152, rot = 225 },
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
                    bronze = { { xi.item.HANDFUL_OF_PUGIL_SCALES, 240 } },
                    silver = { { xi.item.HANDFUL_OF_PUGIL_SCALES, 240 },
                               { xi.item.RABBIT_HIDE,             100 } },
                    gold   = { { xi.item.HANDFUL_OF_PUGIL_SCALES, 240 },
                               { xi.item.HIGH_QUALITY_PUGIL_SCALES, 50 },
                               { xi.item.MAPLE_LOG,               150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.HANDFUL_OF_PUGIL_SCALES,  50 } },
                    gold   = { { xi.item.HANDFUL_OF_PUGIL_SCALES, 100 } },
                },
            },
        },

        -----------------------------------
        -- Bat Colony
        -- A colony of bats rouses from the
        -- ancient trees of East Ronfaure.
        -----------------------------------
        {
            id          = "ER_BEAST_02",
            name        = "Going Batty",
            level       = 5,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 80,
                y      = 2,
                z      = 80,
                radius = 50,
            },

            entryPos = { x = 100, y = 2, z = 60, rot = 225 },

            mobs =
            {
                {
                    base        = { 101, 8 },
                    name        = "Ding Bats",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = 82,  y = 2, z = 85, rot = 90  },
                        { x = 95,  y = 2, z = 72, rot = 200 },
                        { x = 72,  y = 2, z = 78, rot = 45  },
                    },
                },
                {
                    base        = { 101, 14 },
                    name        = "Mouse Bat",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 88,  y = 2, z = 90, rot = 143 },
                        { x = 75,  y = 2, z = 82, rot = 225 },
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
        -- Goblin Troublemakers
        -- Goblins harass travellers along
        -- the eastern road from San d'Oria.
        -----------------------------------
        {
            id          = "ER_GOBLIN_01",
            name        = "Goblin Troublemakers",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 7 },

            area =
            {
                x      = -150,
                y      = 3,
                z      = -100,
                radius = 50,
            },

            entryPos = { x = -130, y = 3, z = -120, rot = 45 },

            mobs =
            {
                {
                    base        = { 101, 21 },
                    name        = "Goblin Thug",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -152, y = 3, z = -105, rot = 200 },
                        { x = -138, y = 3, z = -95,  rot = 45  },
                        { x = -160, y = 3, z = -92,  rot = 127 },
                    },
                },
                {
                    base        = { 101, 17 },
                    name        = "Goblin Fisher",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = -145, y = 3, z = -112, rot = 90  },
                        { x = -162, y = 3, z = -102, rot = 225 },
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
        -- Scarab Infestation
        -- Scarab beetles and tunnel worms
        -- burrow up across the eastern paths.
        -----------------------------------
        {
            id          = "ER_BEAST_03",
            name        = "Scarab Scramble",
            level       = 6,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 200,
                y      = 1,
                z      = 100,
                radius = 50,
            },

            entryPos = { x = 180, y = 1, z = 80, rot = 45 },

            mobs =
            {
                {
                    base        = { 101, 12 },
                    name        = "Scarab Beetle",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = 202, y = 1, z = 105, rot = 90  },
                        { x = 215, y = 1, z = 92,  rot = 200 },
                        { x = 192, y = 1, z = 95,  rot = 45  },
                    },
                },
                {
                    base        = { 101, 7 },
                    name        = "Tunnel Worm",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 208, y = 1, z = 110, rot = 143 },
                        { x = 195, y = 1, z = 102, rot = 225 },
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
                               { xi.item.WILD_RABBIT_TAIL,     100 } },
                    gold   = { { xi.item.INSECT_WING,          240 },
                               { xi.item.RABBIT_HIDE,          100 },
                               { xi.item.MAPLE_LOG,            100 } },
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
    },
}
