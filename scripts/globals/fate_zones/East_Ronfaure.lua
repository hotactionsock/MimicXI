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
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Scarab Emergence
        -- A mass of Scarab Beetles and
        -- Forest Fungi bursts from the
        -- damp forest floor east of the
        -- San d'Oria gate road.
        -----------------------------------
        {
            id          = "ER_SCARAB_01",
            name        = "Scarab Emergence",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,
			mapPos		= "I-8",

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 369,
                y      = -35,
                z      = -17,
                radius = 85,
            },

            entryPos = { 369.660, -35.351, -17.708, 66 }, -- !pos 369.660 -35.351 -17.708 101

            mobs =
            {
                {
                    base        = { 101, 12 },
                    name        = string.char(0xA6) .. "Scarab Beetle",
                    count       = 7,
                    spawnPoints =
                    {
                        { 369.283, -28.944, -35.300, 67 }, -- !pos 369.283 -28.944 -35.300 101
                        { 370.905, -27.628, -47.644, 21 }, -- !pos 370.905 -27.628 -47.644 101
                        { 384.807, -26.670, -50.511, 245 }, -- !pos 384.807 -26.670 -50.511 101
                        { 387.273, -28.906, -28.701, 169 }, -- !pos 387.273 -28.906 -28.701 101
						{ 379.443, -34.240, -12.716, 152 }, -- !pos 379.443 -34.240 -12.716 101
						{ 363.159, -40.000, -3.255, 110 }, -- !pos 363.159 -40.000 -3.255 101
						{ 347.438, -34.887, -22.540, 69 }, -- !pos 347.438 -34.887 -22.540 101
                    },
                },
                {
                    base        = { 101, 11 },
                    name        = string.char(0xA6) .. "Forest Funguar",
                    count       = 3,
                    spawnPoints =
                    {
                        { 380.448, -26.501, -30.521, 82 }, -- !pos 380.448 -26.501 -30.521 101
                        { 361.204, -29.528, -52.185, 136 }, -- !pos 361.204 -29.528 -52.185 101
						{ 398.747, -29.557, -52.400, 146 }, -- !pos 398.747 -29.557 -52.400 101
						
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 700 },
                    silver = { exp = 350 },
                    bronze = { exp = 120 },
                },
                fail =
                {
                    gold   = { exp = 175 },
                    silver = { exp = 90  },
                    bronze = { exp = 40  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.SLEEPSHROOM,            240 } },
                    silver = { { xi.item.SLEEPSHROOM,            240 },
                               { xi.item.BEETLE_JAW,            150 } },
                    gold   = { { xi.item.SLEEPSHROOM,            240 },
                               { xi.item.BEETLE_JAW,            150 },
                               { xi.item.WOOZYSHROOM,           100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.SLEEPSHROOM,             50 } },
                    gold   = { { xi.item.SLEEPSHROOM,            100 } },
                },
            },
        },

        -----------------------------------
        -- Orcish Raiding Party
        -- Orcish Fodder push east from
        -- the Ghelsba foothills, pillaging
        -- supply caches along the road.
        -----------------------------------
        {
            id          = "ER_ORC_01",
            name        = "Orcish Raiding Party",
            level       = 10,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "ER_ORC_02",
            progressVal = 1,
			mapPos = "H-9",

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = 298,
                y      = -15,
                z      = -260,
                radius = 65,
            },

            entryPos = { 298.027, -15.519, -260.961, 186 }, -- !pos 298.027 -15.519 -260.961 101

            mobs =
            {
                {
                    base        = { 101, 13 },
                    name        = string.char(0xA6) .. "Orcish Fodder",
                    count       = 5,
                    spawnPoints =
                    {
                        { 284.497, -19.297, -273.184, 160 }, -- !pos 284.497 -19.297 -273.184 101
                        { 310.927, -18.549, -276.792, 240 }, -- !pos 310.927 -18.549 -276.792 101
                        { 322.364, -19.368, -245.105, 204 }, -- !pos 322.364 -19.368 -245.105 101
						{ 304.336, -20.135, -235.183, 102 }, -- !pos 304.336 -20.135 -235.183 101
						{ 281.090, -20.882, -233.820, 91 }, -- !pos 281.090 -20.882 -233.820 101
						{ 266.425, -19.713, -275.702, 54 }, -- !pos 266.425 -19.713 -275.702 101
                        { 285.185, -19.359, -281.827, 217 }, -- !pos 285.185 -19.359 -281.827 101
						{ 327.792, -19.516, -271.302, 179 }, -- !pos 327.792 -19.516 -271.302 101
                    },
                },
                {
                    base        = { 101, 16 },
                    name        = string.char(0xA6) .. "Orcish Grappler",
                    count       = 3,
                    spawnPoints =
                    {
                        { 284.497, -19.297, -273.184, 160 }, -- !pos 284.497 -19.297 -273.184 101
                        { 310.927, -18.549, -276.792, 240 }, -- !pos 310.927 -18.549 -276.792 101
                        { 322.364, -19.368, -245.105, 204 }, -- !pos 322.364 -19.368 -245.105 101
						{ 304.336, -20.135, -235.183, 102 }, -- !pos 304.336 -20.135 -235.183 101
						{ 281.090, -20.882, -233.820, 91 }, -- !pos 281.090 -20.882 -233.820 101
						{ 266.425, -19.713, -275.702, 54 }, -- !pos 266.425 -19.713 -275.702 101
                        { 285.185, -19.359, -281.827, 217 }, -- !pos 285.185 -19.359 -281.827 101
						{ 327.792, -19.516, -271.302, 179 }, -- !pos 327.792 -19.516 -271.302 101
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 800 },
                    silver = { exp = 400 },
                    bronze = { exp = 200 },
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
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,     150 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              150 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,      50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- Orcish Advance Guard
        -- Chains from Orcish Raiding Party.
        -- Grapplers and Mesmerizers arrive
        -- to press the assault deeper
        -- into Ronfaure.
        -----------------------------------
        {
            id          = "ER_ORC_02",
            name        = "Orcish Advance Guard",
            level       = 12,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,
			mapPos = "I-6",

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 511,
                y      = -53,
                z      = 226,
                radius = 55,
            },

            entryPos = { 511.711, -53.284, 226.029, 75 }, -- !pos 511.711 -53.284 226.029 101

            mobs =
            {
                {
                    base        = { 101, 16 },
                    name        = string.char(0xA6) .. "Orcish Grappler",
                    count       = 3,
                    spawnPoints =
                    {
                        { 495.207, -50.907, 239.865, 53 }, -- !pos 495.207 -50.907 239.865 101
                        { 478.168, -50.000, 236.305, 70 }, -- !pos 478.168 -50.000 236.305 101
						{ 471.475, -51.727, 210.520, 46 }, -- !pos 471.475 -51.727 210.520 101
						{ 482.305, -49.745, 186.090, 33 }, -- !pos 482.305 -49.745 186.090 101
						{ 510.008, -49.500, 200.600, 111 }, -- !pos 510.008 -49.500 200.600 101
						{ 522.648, -51.399, 217.498, 149 }, -- !pos 522.648 -51.399 217.498 101
						{ 521.723, -55.635, 228.883, 96 }, -- !pos 521.723 -55.635 228.883 101
                    },
                },
                {
                    base        = { 101, 15 },
                    name        = string.char(0xA6) .. "Orcish Mesmerizer",
                    count       = 2,
                    spawnPoints =
                    {
                        { 495.207, -50.907, 239.865, 53 }, -- !pos 495.207 -50.907 239.865 101
                        { 478.168, -50.000, 236.305, 70 }, -- !pos 478.168 -50.000 236.305 101
						{ 471.475, -51.727, 210.520, 46 }, -- !pos 471.475 -51.727 210.520 101
						{ 482.305, -49.745, 186.090, 33 }, -- !pos 482.305 -49.745 186.090 101
						{ 510.008, -49.500, 200.600, 111 }, -- !pos 510.008 -49.500 200.600 101
						{ 522.648, -51.399, 217.498, 149 }, -- !pos 522.648 -51.399 217.498 101
						{ 521.723, -55.635, 228.883, 96 }, -- !pos 521.723 -55.635 228.883 101
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
                    gold   = { exp = 275 },
                    silver = { exp = 175 },
                    bronze = { exp = 90  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,     100 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              100 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              100 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,      50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Ronfaure Rampage
        -- A rogue Wild Sheep of staggering
        -- size, driven mad by Orcish war
        -- drums, charges through the forest
        -- path toward San d'Oria's gates.
        -----------------------------------
        {
            id          = "ER_BOSS_01",
            name        = "The Ronfaure Rampage",
            level       = 16,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,
			mapPos = "J-11",

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "You hear a distant war horn to the south...",
                "The horns grow louder! Something is approaching from the south!",
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
                x      = 631,
                y      = -9,
                z      = -513,
                radius = 70,
            },

            entryPos = { 631.451, -9.391, -513.307, 189 }, -- !pos 631.451 -9.391 -513.307 101

            mobs =
            {
                {
                    base         = { 150, 16 },
                    name         = string.char(0xA6) .. "Orcish Tyrant",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
					size		 = 3,
                    spawnPoints  =
                    {
                        { 655.842, -10.398, -512.637, 123 }, -- !pos 655.842 -10.398 -512.637 101
                    },
                },
                {
                    base        = { 150, 3 },
                    name        = string.char(0xA6) .. "Orcish Grunt",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 651.712, -12.911, -491.539, 130 }, -- !pos 651.712 -12.911 -491.539 101
                        { 630.032, -10.043, -527.020, 231 }, -- !pos 630.032 -10.043 -527.020 101
                        { 647.939, -9.994, -544.322, 215 }, -- !pos 647.939 -9.994 -544.322 101
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
                    gold   = { exp = 500 },
                    silver = { exp = 300 },
                    bronze = { exp = 150 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,     100 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              100 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              100 },
							   { xi.item.IRONBLOOD_GLADIUS,		 50 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,      50 },
                               { xi.item.BONE_CHIP,               50 } },
							   
                },
            },
        },

        -----------------------------------
        -- Beetle Emergence
        -- A wave of Stag Beetles drives
        -- Saplings from the undergrowth;
        -- both are now blocking the path
        -- through east Ronfaure.
        -----------------------------------
        {
            id          = "ER_BEETLE_01",
            name        = "Beetle Emergence",
            level       = 6,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,
			mapPos = "H-5",

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 241,   -- TODO: !pos survey
                y      = -56,   -- TODO: !pos survey
                z      = 422,   -- TODO: !pos survey
                radius = 65,
            },

            entryPos = { 215.388, -58.759, 418.344, 122 }, -- !pos 215.388 -58.759 418.344 101

            mobs =
            {
                {
                    base        = { 101, 12 },
                    name        = string.char(0xA6) .. "Scarab Beetle",
                    count       = 5,
                    spawnPoints =
                    {
                        { 227.012, -59.186, 407.301, 163 }, -- !pos 227.012 -59.186 407.301 101
                        { 237.398, -56.955, 414.285, 231 }, -- !pos 237.398 -56.955 414.285 101
                        { 237.462, -58.540, 430.601, 189 }, -- !pos 237.462 -58.540 430.601 101
                        { 227.932, -59.678, 435.243, 146 }, -- !pos 227.932 -59.678 435.243 101
                        { 247.406, -56.781, 425.091, 9 }, -- !pos 247.406 -56.781 425.091 101
                    },
                },
                {
                    base        = { 101, 12 },  -- TODO: verify mob_groups (Stag Beetle)
                    name        = string.char(0xA6) .. "Stag Beetle",
                    count       = 4,
                    spawnPoints =
                    {
                        { 247.515, -59.282, 405.198, 64 }, -- !pos 247.515 -59.282 405.198 101
                        { 237.328, -59.748, 403.123, 116 }, -- !pos 237.328 -59.748 403.123 101
                        { 246.689, -56.146, 423.274, 242 }, -- !pos 246.689 -56.146 423.274 101
                        { 248.276, -59.500, 437.724, 191 }, -- !pos 248.276 -59.500 437.724 101
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 750 },
                    silver = { exp = 375 },
                    bronze = { exp = 185 },
                },
                fail =
                {
                    gold   = { exp = 185 },
                    silver = { exp = 95  },
                    bronze = { exp = 45  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BEETLE_JAW,             150 } },
                    silver = { { xi.item.BEETLE_JAW,             200 },
                               { xi.item.BEETLE_EGG,             100 } },
                    gold   = { { xi.item.BEETLE_JAW,             200 },
                               { xi.item.BEETLE_EGG,             150 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEETLE_JAW,              50 } },
                    gold   = { { xi.item.BEETLE_JAW,             100 } },
                },
            },
        },

        -----------------------------------
        -- Worm Surge
        -- Tunnel Worms burrowing under the
        -- eastern road have broken through,
        -- disrupting traffic. Carrion Worms
        -- follow in their wake.
        -----------------------------------
        {
            id          = "ER_WORM_01",
            name        = "Worm Surge",
            level       = 10,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "ER_WORM_02",
            progressVal = 1,
			mapPos = "I-7",

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 441,   -- TODO: !pos survey
                y      = -50,   -- TODO: !pos survey
                z      = 117,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 441.344, -50.000, 117.165, 139 }, -- !pos 441.344 -50.000 117.165 101

            mobs =
            {
                {
                    base        = { 101, 14 },  -- TODO: verify mob_groups (Tunnel Worm)
                    name        = string.char(0xA6) .. "Tunnel Worm",
                    count       = 5,
                    spawnPoints =
                    {
                        { 452.620, -48.761, 130.616, 219 }, -- !pos 452.620 -48.761 130.616 101
                        { 452.620, -48.761, 130.616, 219 }, -- !pos 452.620 -48.761 130.616 101
                        { 426.571, -49.223, 133.602, 16 }, -- !pos 426.571 -49.223 133.602 101
                        { 433.241, -49.444, 114.154, 2 }, -- !pos 433.241 -49.444 114.154 101
                        { 448.581, -48.868, 103.233, 23 }, -- !pos 448.581 -48.868 103.233 101
                    },
                },
                {
                    base        = { 101, 14 },  -- TODO: verify mob_groups (Carrion Worm)
                    name        = string.char(0xA6) .. "Carrion Worm",
                    count       = 4,
                    spawnPoints =
                    {
                        { 461.314, -49.394, 111.624, 222 }, -- !pos 461.314 -49.394 111.624 101
                        { 449.663, -49.024, 112.394, 131 }, -- !pos 449.663 -49.024 112.394 101
                        { 445.469, -49.526, 126.067, 169 }, -- !pos 445.469 -49.526 126.067 101
                        { 445.469, -49.526, 126.067, 169 }, -- !pos 445.469 -49.526 126.067 101
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 800 },
                    silver = { exp = 400 },
                    bronze = { exp = 200 },
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
                    bronze = { { xi.item.BRONZE_ORE,              150 } },
                    silver = { { xi.item.BRONZE_ORE,              200 },
                               { xi.item.IRON_ORE,                100 } },
                    gold   = { { xi.item.BRONZE_ORE,              200 },
                               { xi.item.IRON_ORE,                150 },
                               { xi.item.CHUNK_OF_IRON_ORE,       100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BRONZE_ORE,               50 } },
                    gold   = { { xi.item.BRONZE_ORE,              100 } },
                },
            },
        },

        -----------------------------------
        -- Worm Brood Mother
        -- Chains from Worm Surge.
        -- A massive Tremor Worm burrows up
        -- from the sinkholes, trailing a
        -- brood of Carrion Worms.
        -----------------------------------
        {
            id          = "ER_WORM_02",
            name        = "Worm Brood Mother",
            level       = 12,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,
			mapPos 		= "I-7",

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 480,   -- TODO: !pos survey
                y      = -39,   -- TODO: !pos survey
                z      = 37.5,   -- TODO: !pos survey
                radius = 55,
            },

            entryPos = { 480.499, -39.916, 37.551, 164 }, -- !pos 480.499 -39.916 37.551 101

            mobs =
            {
                {
                    base        = { 101, 14 },  -- TODO: verify mob_groups (Tremor Worm)
                    name        = string.char(0xA6) .. "Tremor Worm",
                    count       = 2,
                    spawnPoints =
                    {
                        { 493.925, -36.917, 37.549, 159 }, -- !pos 493.925 -36.917 37.549 101
                        { 477.498, -36.277, 22.157, 142 }, -- !pos 477.498 -36.277 22.157 101
                    },
                },
                {
                    base        = { 101, 14 },  -- TODO: verify mob_groups
                    name        = string.char(0xA6) .. "Carrion Worm",
                    count       = 3,
                    spawnPoints =
                    {
                        { 466.591, -39.404, 32.050, 170 }, -- !pos 466.591 -39.404 32.050 101
                        { 466.852, -39.611, 44.720, 190 }, -- !pos 466.852 -39.611 44.720 101
                        { 476.562, -39.809, 54.411, 205 }, -- !pos 476.562 -39.809 54.411 101
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
                    bronze = { { xi.item.IRON_ORE,               100 } },
                    silver = { { xi.item.IRON_ORE,               200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                    gold   = { { xi.item.IRON_ORE,               200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 },
                               { xi.item.BEETLE_JAW,             100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.IRON_ORE,                50 } },
                    gold   = { { xi.item.IRON_ORE,               100 },
                               { xi.item.CHUNK_OF_IRON_ORE,       50 } },
                },
            },
        },

        -----------------------------------
        -- The Ronfaure Ironhide
        -- An abnormally large Wild Karakul
        -- covered in calloused iron-grey
        -- hide rampages out of the eastern
        -- hills, scattering all before it.
        -----------------------------------
        {
            id          = "ER_BOSS_02",
            name        = "The Ronfaure Ironhide",
            level       = 14,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
			bossStars = 2,
            minCooldown = 5400,
            progressVal = 2,
			mapPos = "H-11",

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "Thundering hoofbeats echo from the direction of the eastern hills...",
                "An enormous grey bulk crashes through the treeline at terrifying speed...",
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
                x      = 335,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = -547,   -- TODO: !pos survey
                radius = 80,
            },

            entryPos = { 355.837, 0.338, -526.764, 192 }, -- !pos 355.837 0.338 -526.764 101

            mobs =
            {
                {
                    base         = { 101, 18 },  -- TODO: verify mob_groups (Wild Karakul / Sheep family)
                    name         = string.char(0xA6) .. "Ronfaure Ironhide",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 355.587, 0.362, -547.581, 187 }, -- !pos 355.587 0.362 -547.581 101
                    },
                },
                {
                    base        = { 101, 18 },  -- TODO: verify mob_groups (Sheep family adds)
                    name        = string.char(0xA6) .. "Wild Karakul",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 364.841, -0.240, -541.085, 164 }, -- !pos 364.841 -0.240 -541.085 101
                        { 347.407, 0.049, -535.445, 135 }, -- !pos 347.407 0.049 -535.445 101
                        { 355.075, 0.092, -537.378, 204 }, -- !pos 355.075 0.092 -537.378 101
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1800 },
                    silver = { exp = 900  },
                    bronze = { exp = 450  },
                },
                fail =
                {
                    gold   = { exp = 450 },
                    silver = { exp = 270 },
                    bronze = { exp = 135 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.CLUMP_OF_SHEEP_WOOL },
                    bronze = { { xi.item.CLUMP_OF_SHEEP_WOOL,    240 },
                               { xi.item.SHEEP_TOOTH,            150 } },
                    silver = { { xi.item.CLUMP_OF_SHEEP_WOOL,    240 },
                               { xi.item.SHEEP_TOOTH,            200 },
                               { xi.item.RAM_HORN,               100 } },
                    gold   = { { xi.item.CLUMP_OF_SHEEP_WOOL,    240 },
                               { xi.item.SHEEP_TOOTH,            200 },
                               { xi.item.RAM_HORN,               150 },
                               { xi.item.COWHIDE_BELT,           100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CLUMP_OF_SHEEP_WOOL,     50 } },
                    gold   = { { xi.item.CLUMP_OF_SHEEP_WOOL,    100 },
                               { xi.item.SHEEP_TOOTH,             50 } },
                },
            },
        },

        -----------------------------------
        -- The Dread Champion
        -- An Orcish Overlord of enormous
        -- power and prestige marches at
        -- the head of a full warband,
        -- seeking to claim Ronfaure.
        -- Spawns rarely. Bring your finest.
        -----------------------------------
        {
            id          = "ER_BOSS_03",
            name        = "The Dread Scout",
            level       = 20,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
			bossStars = 3,
            minCooldown = 14400,
			mapPos = "K-5",
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The wildlife is fleeing from the North East!",
                "A miasma begins to spread from the north, a dark void approaches...",
				"A wicked creature has been spotted! Steel yourself for combat!",
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
                x      = 733,   -- TODO: !pos survey
                y      = -59,   -- TODO: !pos survey
                z      = 400,   -- TODO: !pos survey
                radius = 110,
            },

            entryPos = {{ 733.415, -59.684, 400.727, 129 }, -- !pos 733.415 -59.684 400.727 101

            mobs =
            {
                {
                    base         = { 150, 16 },
                    name         = string.char(0xA6) .. "Dread Champion",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 733.415, -59.684, 400.727, 129 }, -- !pos 733.415 -59.684 400.727 101
                    },
                },
                
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 4000 },
                    silver = { exp = 2000 },
                    bronze = { exp = 1000 },
                },
                fail =
                {
                    gold   = { exp = 1000 },
                    silver = { exp = 500  },
                    bronze = { exp = 250  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.AHRIMAN_TEARS },
                    bronze = { { xi.item.AHRIMAN_TEARS,     240 },
                               { xi.item.AHRIMAN_LENS,              200 } },
                    silver = { { xi.item.AHRIMAN_TEARS,     240 },
                               { xi.item.AHRIMAN_LENS,              200 },
                               { xi.item.AHRIMAN_WING,      150 } },
                    gold   = { { xi.item.AHRIMAN_TEARS,     240 },
                               { xi.item.AHRIMAN_LENS,              200 },
                               { xi.item.AHRIMAN_WING,      200 },
                               { xi.item.WHISPERCUT,               100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.ORCISH_MAIL_SCALES,      50 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     100 } },
                },
            },
        },
    },
	},
}
