-----------------------------------
-- FATE Zone: West Sarutabaruta
-- Zone ID: 115
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.WEST_SARUTABARUTA] =
{
    zoneName    = "West_Sarutabaruta",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Yagudo Patrol
        -- A Yagudo patrol sweeps out from
        -- Castle Oztroja toward the plains.
        -----------------------------------
        {
            id          = "WS_YAGUDO_01",
            name        = "Yagudo Patrol",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "WS_YAGUDO_02",
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = -100,
                y      = 2,
                z      = 200,
                radius = 55,
            },

            entryPos = { x = -80, y = 2, z = 178, rot = 180 },

            mobs =
            {
                {
                    base        = { 115, 16 },
                    name        = "Yagudo Initiate",
                    count       = 5,
                    spawnPoints =
                    {
                        { x = -105, y = 2, z = 208, rot = 200 },
                        { x = -88,  y = 2, z = 195, rot = 45  },
                        { x = -112, y = 2, z = 192, rot = 127 },
                    },
                },
                {
                    base        = { 115, 17 },
                    name        = "Yagudo Acolyte",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = -98,  y = 2, z = 212, rot = 90  },
                        { x = -115, y = 2, z = 202, rot = 225 },
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
                    bronze = { { xi.item.YAGUDO_FEATHER,        240 } },
                    silver = { { xi.item.YAGUDO_FEATHER,        240 },
                               { xi.item.RARAB_TAIL,            150 } },
                    gold   = { { xi.item.YAGUDO_BEAD_NECKLACE,  100 },
                               { xi.item.YAGUDO_FEATHER,        240 },
                               { xi.item.RARAB_TAIL,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,         50 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,        100 } },
                },
            },
        },

        -----------------------------------
        -- Yagudo War Council
        -- Chains from Yagudo Patrol.
        -- Senior Yagudo scribes arrive to
        -- reinforce the patrol's position.
        -----------------------------------
        {
            id          = "WS_YAGUDO_02",
            name        = "Fowl Play",
            level       = 10,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = -100,
                y      = 2,
                z      = 200,
                radius = 55,
            },

            entryPos = { x = -80, y = 2, z = 178, rot = 180 },

            mobs =
            {
                {
                    base        = { 115, 18 },
                    name        = "Yagudo Scribe",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = -102, y = 2, z = 205, rot = 90  },
                        { x = -115, y = 2, z = 195, rot = 225 },
                    },
                },
                {
                    base        = { 115, 17 },
                    name        = "Yagudo Acolyte",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = -92,  y = 2, z = 198, rot = 45  },
                        { x = -108, y = 2, z = 210, rot = 143 },
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
                    bronze = { { xi.item.YAGUDO_FEATHER,        150 } },
                    silver = { { xi.item.YAGUDO_BEAD_NECKLACE,  100 },
                               { xi.item.YAGUDO_FEATHER,        150 } },
                    gold   = { { xi.item.YAGUDO_BEAD_NECKLACE,  150 },
                               { xi.item.YAGUDO_FEATHER,        150 },
                               { xi.item.SPOOL_OF_COTTON_THREAD, 100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,         50 } },
                    gold   = { { xi.item.YAGUDO_BEAD_NECKLACE,   50 } },
                },
            },
        },

        -----------------------------------
        -- Mandragora Rampage
        -- Mandragora uproot themselves and
        -- surge across the western savanna.
        -----------------------------------
        {
            id          = "WS_BEAST_01",
            name        = "Root of All Evil",
            level       = 7,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 50,
                y      = 1,
                z      = -150,
                radius = 55,
            },

            entryPos = { x = 70, y = 1, z = -128, rot = 225 },

            mobs =
            {
                {
                    base        = { 115, 6 },
                    name        = "Tiny Mandragora",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = 52,  y = 1, z = -158, rot = 90  },
                        { x = 65,  y = 1, z = -142, rot = 200 },
                        { x = 40,  y = 1, z = -148, rot = 45  },
                        { x = 58,  y = 1, z = -162, rot = 127 },
                    },
                },
                {
                    base        = { 115, 15 },
                    name        = "Mandragora",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 45,  y = 1, z = -138, rot = 225 },
                        { x = 68,  y = 1, z = -155, rot = 143 },
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
                    bronze = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 } },
                    silver = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 },
                               { xi.item.RARAB_TAIL,                150 } },
                    gold   = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 },
                               { xi.item.MANDRAGORA_DEWDROP,        100 },
                               { xi.item.RARAB_TAIL,                150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.THREE_LEAF_MANDRAGORA_BUD,  50 } },
                    gold   = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 100 } },
                },
            },
        },

        -----------------------------------
        -- Bee Hive Assault
        -- Giant bees swarm from disturbed
        -- hives hidden in the savanna grass.
        -----------------------------------
        {
            id          = "WS_BEAST_02",
            name        = "Hive Minded",
            level       = 6,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = -200,
                y      = 1,
                z      = -80,
                radius = 50,
            },

            entryPos = { x = -180, y = 1, z = -100, rot = 45 },

            mobs =
            {
                {
                    base        = { 115, 7 },
                    name        = "Bumblebee",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = -202, y = 1, z = -85, rot = 90  },
                        { x = -188, y = 1, z = -72, rot = 200 },
                        { x = -212, y = 1, z = -75, rot = 45  },
                    },
                },
                {
                    base        = { 115, 23 },
                    name        = "Giant Bee",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -195, y = 1, z = -90, rot = 143 },
                        { x = -208, y = 1, z = -82, rot = 225 },
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
                    bronze = { { xi.item.INSECT_WING,           240 } },
                    silver = { { xi.item.INSECT_WING,           240 },
                               { xi.item.RARAB_TAIL,            100 } },
                    gold   = { { xi.item.INSECT_WING,           240 },
                               { xi.item.TRANSPARENT_INSECT_WING, 100 },
                               { xi.item.PIECE_OF_CRAWLER_COCOON, 100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.INSECT_WING,            50 } },
                    gold   = { { xi.item.INSECT_WING,           100 } },
                },
            },
        },

        -----------------------------------
        -- Rarab Infestation
        -- Savanna rarabs overrun the plains,
        -- trailing crawlers in their wake.
        -----------------------------------
        {
            id          = "WS_BEAST_03",
            name        = "Rarab Roundup",
            level       = 5,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 150,
                y      = 2,
                z      = 150,
                radius = 55,
            },

            entryPos = { x = 170, y = 2, z = 128, rot = 200 },

            mobs =
            {
                {
                    base        = { 115, 8 },
                    name        = "Savanna Rarab",
                    count       = 7,
                    spawnPoints =
                    {
                        { x = 152, y = 2, z = 158, rot = 90  },
                        { x = 165, y = 2, z = 142, rot = 200 },
                        { x = 140, y = 2, z = 148, rot = 45  },
                        { x = 158, y = 2, z = 162, rot = 127 },
                    },
                },
                {
                    base        = { 115, 10 },
                    name        = "Crawler",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 145, y = 2, z = 138, rot = 225 },
                        { x = 168, y = 2, z = 155, rot = 143 },
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
                    bronze = { { xi.item.RARAB_TAIL,            240 } },
                    silver = { { xi.item.RARAB_TAIL,            240 },
                               { xi.item.PIECE_OF_CRAWLER_COCOON, 150 } },
                    gold   = { { xi.item.RARAB_TAIL,            240 },
                               { xi.item.PIECE_OF_CRAWLER_COCOON, 150 },
                               { xi.item.SPOOL_OF_COTTON_THREAD, 100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.RARAB_TAIL,             50 } },
                    gold   = { { xi.item.RARAB_TAIL,            100 } },
                },
            },
        },

        -----------------------------------
        -- Goblin Wanderers
        -- A goblin trading party strays far
        -- off the road into the savanna.
        -----------------------------------
        {
            id          = "WS_GOBLIN_01",
            name        = "Goblin Wanderers",
            level       = 9,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 7 },

            area =
            {
                x      = 200,
                y      = 2,
                z      = -50,
                radius = 50,
            },

            entryPos = { x = 220, y = 2, z = -70, rot = 45 },

            mobs =
            {
                {
                    base        = { 115, 12 },
                    name        = "Goblin Thug",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 202, y = 2, z = -55, rot = 200 },
                        { x = 188, y = 2, z = -42, rot = 45  },
                        { x = 210, y = 2, z = -45, rot = 127 },
                    },
                },
                {
                    base        = { 115, 14 },
                    name        = "Goblin Fisher",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 195, y = 2, z = -60, rot = 90  },
                        { x = 208, y = 2, z = -52, rot = 225 },
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1300 },
                    silver = { exp = 650  },
                    bronze = { exp = 325  },
                },
                fail =
                {
                    gold   = { exp = 205 },
                    silver = { exp = 102 },
                    bronze = { exp = 51  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.RARAB_TAIL,            150 } },
                    silver = { { xi.item.YAGUDO_FEATHER,        100 },
                               { xi.item.RARAB_TAIL,            150 } },
                    gold   = { { xi.item.YAGUDO_BEAD_NECKLACE,  100 },
                               { xi.item.YAGUDO_FEATHER,        150 },
                               { xi.item.SPOOL_OF_COTTON_THREAD, 100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.RARAB_TAIL,             50 } },
                    gold   = { { xi.item.RARAB_TAIL,            100 } },
                },
            },
        },
    },
}
