-----------------------------------
-- FATE Zone: East Sarutabaruta
-- Zone ID: 116
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.EAST_SARUTABARUTA] =
{
    zoneName    = "East_Sarutabaruta",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Yagudo Incursion
        -- Yagudo initiates press eastward
        -- from the Oztroja foothills.
        -----------------------------------
        {
            id          = "ES_YAGUDO_01",
            name        = "Yagudo Incursion",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "ES_YAGUDO_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 200,
                y      = 2,
                z      = 100,
                radius = 55,
            },

            entryPos = { x = 178, y = 2, z = 80, rot = 45 },

            mobs =
            {
                {
                    base        = { 116, 11 },
                    name        = "Yagudo Initiate",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = 205, y = 2, z = 108, rot = 200 },
                        { x = 188, y = 2, z = 95,  rot = 45  },
                        { x = 212, y = 2, z = 92,  rot = 127 },
                        { x = 195, y = 2, z = 115, rot = 90  },
                    },
                },
                {
                    base        = { 116, 12 },
                    name        = "Yagudo Acolyte",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 208, y = 2, z = 88,  rot = 225 },
                        { x = 192, y = 2, z = 105, rot = 143 },
                        { x = 218, y = 2, z = 102, rot = 45  },
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
        -- Yagudo Scripture
        -- Chains from Yagudo Incursion.
        -- Yagudo Scribes arrive to seal the
        -- advance with dark incantations.
        -----------------------------------
        {
            id          = "ES_YAGUDO_02",
            name        = "Holy Fowl",
            level       = 10,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 200,
                y      = 2,
                z      = 100,
                radius = 55,
            },

            entryPos = { x = 178, y = 2, z = 80, rot = 45 },

            mobs =
            {
                {
                    base        = { 116, 13 },
                    name        = "Yagudo Scribe",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 202, y = 2, z = 105, rot = 90  },
                        { x = 215, y = 2, z = 95,  rot = 225 },
                    },
                },
                {
                    base        = { 116, 12 },
                    name        = "Yagudo Acolyte",
                    count       = 2,
                    spawnPoints =
                    {
                        { x = 192, y = 2, z = 98,  rot = 45  },
                        { x = 208, y = 2, z = 110, rot = 143 },
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
        -- Crawler Colony
        -- Crawlers surge from underground
        -- nests, with giant bees in pursuit.
        -----------------------------------
        {
            id          = "ES_BEAST_01",
            name        = "Silk Road Shutdown",
            level       = 6,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = -150,
                y      = 1,
                z      = -100,
                radius = 55,
            },

            entryPos = { x = -130, y = 1, z = -78, rot = 225 },

            mobs =
            {
                {
                    base        = { 116, 9 },
                    name        = "Crawler",
                    count       = 6,
                    spawnPoints =
                    {
                        { x = -155, y = 1, z = -108, rot = 90  },
                        { x = -138, y = 1, z = -95,  rot = 200 },
                        { x = -162, y = 1, z = -95,  rot = 45  },
                        { x = -148, y = 1, z = -112, rot = 127 },
                    },
                },
                {
                    base        = { 116, 21 },
                    name        = "Giant Bee",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -142, y = 1, z = -88,  rot = 225 },
                        { x = -160, y = 1, z = -102, rot = 143 },
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
                    bronze = { { xi.item.PIECE_OF_CRAWLER_COCOON, 240 } },
                    silver = { { xi.item.PIECE_OF_CRAWLER_COCOON, 240 },
                               { xi.item.INSECT_WING,             150 } },
                    gold   = { { xi.item.PIECE_OF_CRAWLER_COCOON, 240 },
                               { xi.item.INSECT_WING,             150 },
                               { xi.item.SPOOL_OF_COTTON_THREAD,  100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.PIECE_OF_CRAWLER_COCOON,  50 } },
                    gold   = { { xi.item.PIECE_OF_CRAWLER_COCOON, 100 } },
                },
            },
        },

        -----------------------------------
        -- Mandragora Uprising
        -- Mandragora erupt from the earth
        -- across the eastern savannas.
        -----------------------------------
        {
            id          = "ES_BEAST_02",
            name        = "Uprooted",
            level       = 7,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 80,
                y      = 1,
                z      = -200,
                radius = 50,
            },

            entryPos = { x = 100, y = 1, z = -178, rot = 225 },

            mobs =
            {
                {
                    base        = { 116, 6 },
                    name        = "Tiny Mandragora",
                    count       = 5,
                    spawnPoints =
                    {
                        { x = 82,  y = 1, z = -205, rot = 90  },
                        { x = 95,  y = 1, z = -192, rot = 200 },
                        { x = 72,  y = 1, z = -195, rot = 45  },
                    },
                },
                {
                    base        = { 116, 20 },
                    name        = "Mandragora",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = 88,  y = 1, z = -210, rot = 143 },
                        { x = 75,  y = 1, z = -202, rot = 225 },
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
        -- Goblin Scouts
        -- Goblin scouts case the eastern
        -- roads near the Windurst border.
        -----------------------------------
        {
            id          = "ES_GOBLIN_01",
            name        = "Goblin Scouts",
            level       = 9,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 7 },

            area =
            {
                x      = -50,
                y      = 2,
                z      = 150,
                radius = 50,
            },

            entryPos = { x = -70, y = 2, z = 128, rot = 45 },

            mobs =
            {
                {
                    base        = { 116, 17 },
                    name        = "Goblin Thug",
                    count       = 4,
                    spawnPoints =
                    {
                        { x = -52, y = 2, z = 155, rot = 200 },
                        { x = -38, y = 2, z = 142, rot = 45  },
                        { x = -60, y = 2, z = 142, rot = 127 },
                    },
                },
                {
                    base        = { 116, 23 },
                    name        = "Goblin Fisher",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = -45, y = 2, z = 162, rot = 90  },
                        { x = -62, y = 2, z = 152, rot = 225 },
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
                               { xi.item.RARAB_TAIL,            150 } },
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
        -- Rarab Rampage
        -- Savanna rarabs and bees run amok
        -- across the eastern grasslands.
        -----------------------------------
        {
            id          = "ES_BEAST_03",
            name        = "Rarab Rampage",
            level       = 5,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 150,
                y      = 1,
                z      = -150,
                radius = 55,
            },

            entryPos = { x = 170, y = 1, z = -128, rot = 225 },

            mobs =
            {
                {
                    base        = { 116, 8 },
                    name        = "Savanna Rarab",
                    count       = 7,
                    spawnPoints =
                    {
                        { x = 152, y = 1, z = -158, rot = 90  },
                        { x = 165, y = 1, z = -142, rot = 200 },
                        { x = 140, y = 1, z = -148, rot = 45  },
                        { x = 158, y = 1, z = -162, rot = 127 },
                    },
                },
                {
                    base        = { 116, 7 },
                    name        = "Bumblebee",
                    count       = 3,
                    spawnPoints =
                    {
                        { x = 145, y = 1, z = -138, rot = 225 },
                        { x = 168, y = 1, z = -155, rot = 143 },
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
                               { xi.item.INSECT_WING,           100 } },
                    gold   = { { xi.item.RARAB_TAIL,            240 },
                               { xi.item.INSECT_WING,           150 },
                               { xi.item.PIECE_OF_CRAWLER_COCOON, 100 } },
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
