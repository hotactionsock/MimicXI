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
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Worm Eruption
        -- Tunnel Worms and Carrion Worms
        -- burst from the damp forest soil
        -- along the western road, cutting
        -- off the path to San d'Oria.
        -----------------------------------
        {
            id          = "WR_WORM_01",
            name        = "Worm Eruption",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,
			mapPos = "G-7",

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = -517,
                y      = -29,
                z      = 97,
                radius = 65,
            },

            entryPos = { -517.146, -29.919, 97.325, 237 }, -- !pos -517.146 -29.919 97.325 100

            sharedSpawnPoints =
            {
                { -511.227, -30.354, 111.820, 236 }, -- !pos -511.227 -30.354 111.820 100
                { -495.505, -30.000,  84.686,  19 }, -- !pos -495.505 -30.000 84.686 100
                { -516.929, -31.530,  72.142, 226 }, -- !pos -516.929 -31.530 72.142 100
                { -534.143, -32.147, 104.040, 239 }, -- !pos -534.143 -32.147 104.040 100
                { -522.736, -30.640, 131.061,  26 }, -- !pos -522.736 -30.640 131.061 100
                { -505.961, -32.713, 128.579,  41 }, -- !pos -505.961 -32.713 128.579 100
                { -514.194, -29.752,  88.572, 148 }, -- !pos -514.194 -29.752 88.572 100
                { -528.270, -30.636, 101.704, 200 }, -- !pos -528.270 -30.636 101.704 100
                { -494.837, -36.348, 112.155, 153 }, -- !pos -494.837 -36.348 112.155 100
                { -517.367, -34.776, 141.393, 130 }, -- !pos -517.367 -34.776 141.393 100
            },

            mobs =
            {
                {
                    base  = { 100, 7 },
                    name  = string.char(0xA6) .. "Tunnel Worm",
                    count = 6,
                },
                {
                    base  = { 100, 10 },
                    name  = string.char(0xA6) .. "Carrion Worm",
                    count = 4,
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
                    bronze = { { xi.item.BRONZE_ORE,              240 } },
                    silver = { { xi.item.BRONZE_ORE,              240 },
                               { xi.item.ZINC_ORE,  150 } },
                    gold   = { { xi.item.BRONZE_ORE,              240 },
                               { xi.item.ZINC_ORE,  200 },
                               { xi.item.IRON_ORE,              100 } },
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
        -- Orcish Hunting Band
        -- A roving band of Orcish Fodder
        -- and Grapplers hunts prey in the
        -- deep forest, pushing dangerously
        -- close to the San d'Orian road.
        -----------------------------------
        {
            id          = "WR_ORC_01",
            name        = "Orcish Hunting Band",
            level       = 10,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "WR_ORC_02",
            progressVal = 1,
			mapPos = "H-10",

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = -363,
                y      = -10,
                z      = -315,
                radius = 65,
            },

            entryPos = { -363.510, -9.899, -315.150, 174 }, -- !pos -363.510 -9.899 -315.150 100

            mobs =
            {
                {
                    base        = { 100, 12 },
                    name        = string.char(0xA6) .. "Orcish Fodder",
                    count       = 5,
                    spawnPoints =
                    {
                        { -348.746, -9.500, -322.196, 144 }, -- !pos -348.746 -9.500 -322.196 100
                        { -337.682, -7.325, -299.819, 156 }, -- !pos -337.682 -7.325 -299.819 100
                        { -333.832, -8.264, -272.798, 117 }, -- !pos -333.832 -8.264 -272.798 100
						{ -359.463, -9.500, -289.808, 99 }, -- !pos -359.463 -9.500 -289.808 100
						{ -362.049, -10.000, -318.308, 70 }, -- !pos -362.049 -10.000 -318.308 100
						{ -338.178, -13.401, -336.027, 220 }, -- !pos -338.178 -13.401 -336.027 100
						{ -322.520, -8.530, -310.650, 215 }, -- !pos -322.520 -8.530 -310.650 100
						{ -320.866, -9.777, -339.703, 62 }, -- !pos -320.866 -9.777 -339.703 100
						{ -351.066, -9.500, -318.139, 130 }, -- !pos -351.066 -9.500 -318.139 100
                    },
                },
                {
                    base        = { 100, 13 },
                    name        = string.char(0xA6) .. "Orcish Grappler",
                    count       = 3,
                    spawnPoints =
                    {
                        { -348.746, -9.500, -322.196, 144 }, -- !pos -348.746 -9.500 -322.196 100
                        { -337.682, -7.325, -299.819, 156 }, -- !pos -337.682 -7.325 -299.819 100
                        { -333.832, -8.264, -272.798, 117 }, -- !pos -333.832 -8.264 -272.798 100
						{ -359.463, -9.500, -289.808, 99 }, -- !pos -359.463 -9.500 -289.808 100
						{ -362.049, -10.000, -318.308, 70 }, -- !pos -362.049 -10.000 -318.308 100
						{ -338.178, -13.401, -336.027, 220 }, -- !pos -338.178 -13.401 -336.027 100
						{ -322.520, -8.530, -310.650, 215 }, -- !pos -322.520 -8.530 -310.650 100
						{ -320.866, -9.777, -339.703, 62 }, -- !pos -320.866 -9.777 -339.703 100
						{ -351.066, -9.500, -318.139, 130 }, -- !pos -351.066 -9.500 -318.139 100
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
        -- Orcish Warfront
        -- Chains from Orcish Hunting Band.
        -- Grapplers and Mesmerizers fall in
        -- behind the retreating survivors,
        -- pressing deep into the forest.
        -----------------------------------
        {
            id          = "WR_ORC_02",
            name        = "Orcish Warfront",
            level       = 13,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,
			mapPos = "I-10",

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = -195,
                y      = -10,
                z      = -398,
                radius = 55,
            },

            entryPos = { -195.941, -10.000, -398.401, 182 }, -- !pos -195.941 -10.000 -398.401 100

            mobs =
            {
                {
                    base        = { 100, 13 },
                    name        = string.char(0xA6) .. "Orcish Grappler",
                    count       = 3,
                    spawnPoints =
                    {
                        { -182.582, -10.157, -417.381, 172 }, -- !pos -182.582 -10.157 -417.381 100
                        { -191.383, -10.084, -378.467, 195 }, -- !pos -191.383 -10.084 -378.467 100
						{ -219.115, -11.501, -386.446, 118 }, -- !pos -219.115 -11.501 -386.446 100
						{ -217.628, -11.917, -419.735, 92 }, -- !pos -217.628 -11.917 -419.735 100
						{ -172.353, -9.840, -409.677, 223 }, -- !pos -172.353 -9.840 -409.677 100
                    },
                },
                {
                    base        = { 100, 17 },
                    name        = string.char(0xA6) .. "Orcish Mesmerizer",
                    count       = 2,
                    spawnPoints =
                    {
                        { -182.582, -10.157, -417.381, 172 }, -- !pos -182.582 -10.157 -417.381 100
                        { -191.383, -10.084, -378.467, 195 }, -- !pos -191.383 -10.084 -378.467 100
						{ -219.115, -11.501, -386.446, 118 }, -- !pos -219.115 -11.501 -386.446 100
						{ -217.628, -11.917, -419.735, 92 }, -- !pos -217.628 -11.917 -419.735 100
						{ -172.353, -9.840, -409.677, 223 }, -- !pos -172.353 -9.840 -409.677 100
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 950 },
                    silver = { exp = 475 },
                    bronze = { exp = 240 },
                },
                fail =
                {
                    gold   = { exp = 290 },
                    silver = { exp = 185 },
                    bronze = { exp = 95  },
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
        -- The Funguarlord of Ronfaure
        -- An enormous Forest Funguar blooms
        -- from a rotting oak in the darkest
        -- part of the forest, spewing toxic
        -- spores and rallying Scarab guards.
        -----------------------------------
        {
            id          = "WR_BOSS_01",
            name        = "The Funguarlord of Ronfaure",
            level       = 17,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,
			mapPos = "G-11",

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "An acrid stench drifts from the depths of the Ronfaure forest...",
                "The forest darkens and a sickly, glowing cloud billows between the trees...",
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
                x      = -424,
                y      = 0,
                z      = -502,
                radius = 70,
            },

            entryPos = { -424.662, -0.373, -502.952, 172 }, -- !pos -424.662 -0.373 -502.952 100

            mobs =
            {
                {
                    base         = { 100, 15 },
                    name         = string.char(0xA6) .. "Funguarlord",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
					size		 = 3,
                    spawnPoints  =
                    {
                        { -396.631, -0.000, -516.821, 193 }, -- !pos -396.631 -0.000 -516.821 100
                    },
                },
                {
                    base        = { 100, 15 },
                    name        = string.char(0xA6) .. "Sporemate",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { -395.396, -6.141, -495.904, 193 }, -- !pos -395.396 -6.141 -495.904 100
                        { -427.232, -1.317, -487.342, 142 }, -- !pos -427.232 -1.317 -487.342 100
                        { -450.734, -2.354, -508.145, 100 }, -- !pos -450.734 -2.354 -508.145 100
						{ -433.593, -0.302, -525.753, 9 }, -- !pos -433.593 -0.302 -525.753 100
						{ -432.245, -0.236, -481.674, 202 }, -- !pos -432.245 -0.236 -481.674 100
						{ -414.509, -6.428, -474.388, 232 }, -- !pos -414.509 -6.428 -474.388 100
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
                    guaranteed = {xi.item.SLEEPSHROOM},
                    bronze = { { xi.item.SLEEPSHROOM,            240 } },
                    silver = { { xi.item.SLEEPSHROOM,            240 },
                               { xi.item.BEETLE_JAW,            150 } },
                    gold   = { { xi.item.SLEEPSHROOM,            240 },
                               { xi.item.BEETLE_JAW,            150 },
							   { xi.item.HERDSMANS_TROUSERS,            100 },
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
        -- Funguar Colony
        -- A dense cluster of Forest Funguar
        -- blocks the southern road through
        -- Ronfaure, releasing clouds of
        -- paralysing spores.
        -----------------------------------
        {
            id          = "WR_FUNGUAR_01",
            name        = "Funguar Colony",
            level       = 9,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,
			mapPos = "H-9",

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = -239,   -- TODO: !pos survey
                y      = -19,   -- TODO: !pos survey
                z      = -175,   -- TODO: !pos survey
                radius = 65,
            },

            entryPos = { -239.173, -19.938, -175.446, 172 }, -- !pos -239.173 -19.938 -175.446 100

            mobs =
            {
                {
                    base        = { 100, 15 },  -- TODO: verify mob_groups (Forest Funguar)
                    name        = string.char(0xA6) .. "Forest Funguar",
                    count       = 5,
                    spawnPoints =
                    {
                        { -253.730, -20.723, -162.077, 159 }, -- !pos -253.730 -20.723 -162.077 100
                        { -231.858, -19.500, -158.905, 16 }, -- !pos -231.858 -19.500 -158.905 100
                        { -220.236, -21.916, -179.746, 83 }, -- !pos -220.236 -21.916 -179.746 100
                        { -245.788, -20.709, -212.437, 91 }, -- !pos -245.788 -20.709 -212.437 100
                        { -272.731, -20.650, -188.989, 135 }, -- !pos -272.731 -20.650 -188.989 100
                    },
                },
                {
                    base        = { 100, 7 },
                    name        = string.char(0xA6) .. "Tunnel Worm",
                    count       = 4,
                    spawnPoints =
                    {
                        { -275.185, -24.720, -172.563, 117 }, -- !pos -275.185 -24.720 -172.563 100
                        { -268.745, -24.319, -153.100, 132 }, -- !pos -268.745 -24.319 -153.100 100
                        { -234.366, -19.803, -160.418, 230 }, -- !pos -234.366 -19.803 -160.418 100
                        { -229.290, -20.474, -194.231, 27 }, -- !pos -229.290 -20.474 -194.231 100
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
                    bronze = { { xi.item.SLEEPSHROOM,            150 } },
                    silver = { { xi.item.SLEEPSHROOM,            200 },
                               { xi.item.BRONZE_ORE,             100 } },
                    gold   = { { xi.item.SLEEPSHROOM,            200 },
                               { xi.item.WOOZYSHROOM,            150 },
                               { xi.item.BRONZE_ORE,             100 } },
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
        -- Goblin Toll Collectors
        -- Goblins set up a crude blockade
        -- on the road to San d'Oria,
        -- extorting travellers at knifepoint.
        -----------------------------------
        {
            id          = "WR_GOBLIN_01",
            name        = "Goblin Toll Collectors",
            level       = 11,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "WR_GOBLIN_02",
            progressVal = 1,
			mapPos = "H-10",

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = -212,   -- TODO: !pos survey
                y      = -16,   -- TODO: !pos survey
                z      = -297,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { -233.207, -16.607, -304.711, 126 }, -- !pos -233.207 -16.607 -304.711 100

            mobs =
            {
                {
                    base        = { 100, 18 },  -- TODO: verify mob_groups (Goblin Thug)
                    name        = string.char(0xA6) .. "Goblin Thug",
                    count       = 5,
                    spawnPoints =
                    {
                        { -212.177, -15.976, -297.079, 120 }, -- !pos -212.177 -15.976 -297.079 100
                        { -197.996, -17.894, -308.878, 29 }, -- !pos -197.996 -17.894 -308.878 100
                        { -210.935, -19.500, -318.903, 113 }, -- !pos -210.935 -19.500 -318.903 100
                        { -228.646, -17.159, -291.201, 145 }, -- !pos -228.646 -17.159 -291.201 100
                        { -205.322, -19.095, -286.556, 239 }, -- !pos -205.322 -19.095 -286.556 100
                    },
                },
                {
                    base        = { 100, 19 },  -- TODO: verify mob_groups (Goblin Trader)
                    name        = string.char(0xA6) .. "Goblin Trader",
                    count       = 3,
                    spawnPoints =
                    {
                        { -203.401, -16.108, -302.121, 122 }, -- !pos -203.401 -16.108 -302.121 100
                        { -194.321, -15.132, -299.480, 244 }, -- !pos -194.321 -15.132 -299.480 100
                        { -184.645, -17.792, -306.043, 47 }, -- !pos -184.645 -17.792 -306.043 100
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
                    bronze = { { xi.item.GOBLIN_ARMOR,           150 } },
                    silver = { { xi.item.GOBLIN_ARMOR,           200 },
                               { xi.item.BONE_CHIP,              100 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,           200 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.GOBLIN_ARMOR,            50 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,           100 } },
                },
            },
        },

        -----------------------------------
        -- Goblin Ambush Crew
        -- Chains from Goblin Toll Collectors.
        -- Goblin Smithy and Mugger elites
        -- flood in to avenge the blockade.
        -----------------------------------
        {
            id          = "WR_GOBLIN_02",
            name        = "Goblin Ambush Crew",
            level       = 13,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,
			mapPos = "G-10",

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = -493,   -- TODO: !pos survey
                y      = -5,   -- TODO: !pos survey
                z      = -386,   -- TODO: !pos survey
                radius = 60,
            },

            entryPos = { -471.390, -6.256, -372.040, 230 }, -- !pos -471.390 -6.256 -372.040 100

            mobs =
            {
                {
                    base        = { 100, 26 },  -- TODO: verify mob_groups (Goblin Smithy)
                    name        = string.char(0xA6) .. "Goblin Smithy",
                    count       = 3,
                    spawnPoints =
                    {
                        { -493.968, -4.985, -386.361, 4 }, -- !pos -493.968 -4.985 -386.361 100
                        { -499.362, -7.691, -380.567, 15 }, -- !pos -499.362 -7.691 -380.567 100
                        { -487.303, -9.130, -397.683, 205 }, -- !pos -487.303 -9.130 -397.683 100
                    },
                },
                {
                    base        = { 100, 19 },  -- TODO: verify mob_groups (Goblin Mugger)
                    name        = string.char(0xA6) .. "Goblin Mugger",
                    count       = 2,
                    spawnPoints =
                    {
                        { -508.639, -8.160, -389.391, 241 }, -- !pos -508.639 -8.160 -389.391 100
                        { -500.977, -8.130, -374.130, 6 }, -- !pos -500.977 -8.130 -374.130 100
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
                    bronze = { { xi.item.GOBLIN_ARMOR,           100 } },
                    silver = { { xi.item.GOBLIN_ARMOR,           200 },
                               { xi.item.BONE_CHIP,              100 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,           200 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.GOBLIN_ARMOR,            50 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,           100 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Ronfaure Wolfking
        -- An alpha Hill Wolf of enormous
        -- stature leads its pack down from
        -- the northern ridgeline, terrorising
        -- the road between the two cities.
        -----------------------------------
        {
            id          = "WR_BOSS_02",
            name        = "The Ronfaure Wolfking",
            level       = 14,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
			bossStars = 2,
            minCooldown = 5400,
            progressVal = 2,
			mapPos = "F-11",

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A chilling howl echoes through the depths of Ronfaure forest...",
                "The howling grows to a roar and something crashes through the underbrush...",
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
                x      = -590,   -- TODO: !pos survey
                y      = 0.5,   -- TODO: !pos survey
                z      = -479,   -- TODO: !pos survey
                radius = 80,
            },

            entryPos = { -569.581, 0.500, -476.667, 243 }, -- !pos -569.581 0.500 -476.667 100

            mobs =
            {
                {
                    base         = { 100, 21 },  -- TODO: verify mob_groups (Hill Wolf)
                    name         = string.char(0xA6) .. "The Wolfking",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { -590.821, 0.500, -479.292, 245 }, -- !pos -590.821 0.500 -479.292 100
                    },
                },
                {
                    base        = { 100, 21 },  -- TODO: verify mob_groups
                    name        = string.char(0xA6) .. "Hill Wolf",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { -583.827, -0.723, -486.985, 197 }, -- !pos -583.827 -0.723 -486.985 100
                        { -582.771, -3.751, -464.584, 21 }, -- !pos -582.771 -3.751 -464.584 100
                        { -580.686, -2.312, -493.008, 180 }, -- !pos -580.686 -2.312 -493.008 100
                        { -591.127, -4.513, -466.694, 38 }, -- !pos -591.127 -4.513 -466.694 100
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
                    guaranteed = { xi.item.WOLF_HIDE },
                    bronze = { { xi.item.WOLF_HIDE,              240 },
                               { xi.item.BEAST_HIDE,             150 } },
                    silver = { { xi.item.WOLF_HIDE,              240 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                    gold   = { { xi.item.WOLF_HIDE,              240 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 },
                               { xi.item.HERDSMANS_TROUSERS,     100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.WOLF_HIDE,               50 } },
                    gold   = { { xi.item.WOLF_HIDE,              100 },
                               { xi.item.BEAST_HIDE,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Ancient Oak Dryad
        -- A primordial treant that has slept
        -- beneath the oldest part of Ronfaure
        -- for an age awakens, its roots
        -- erupting from the forest floor.
        -- Spawns rarely. A zone-defining event.
        -----------------------------------
        {
            id          = "WR_BOSS_03",
            name        = "The Ancient Oak Dryad",
            level       = 20,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
			bossStars = 3,
            minCooldown = 14400,
			mapPos = "I-9",
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The oldest trees of West Ronfaure creak and groan in unison...",
                "The forest floor heaves and a colossal figure of bark and root rises...",
				"A great figure has awoken! The forest hungers for vengeance!"
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
                x      = -95,   -- TODO: !pos survey
                y      = -19,   -- TODO: !pos survey
                z      = -158,   -- TODO: !pos survey
                radius = 100,
            },

            entryPos = { -116.492, -19.618, -152.886, 138 }, -- !pos -116.492 -19.618 -152.886 100

            mobs =
            {
                {
                    base         = { 105, 35 },  -- TODO: verify mob_groups (treant family)
                    name         = string.char(0xA6) .. "Ancient Dryad",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { -95.582, -19.934, -157.496, 141 }, -- !pos -95.582 -19.934 -157.496 100
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
                    guaranteed = { xi.item.BEETLE_JAW },
                    bronze = { { xi.item.BEETLE_JAW,             240 },
                               { xi.item.SLEEPSHROOM,            200 } },
                    silver = { { xi.item.BEETLE_JAW,             240 },
                               { xi.item.SLEEPSHROOM,            200 },
                               { xi.item.WOOZYSHROOM,            150 } },
                    gold   = { { xi.item.BEETLE_JAW,             240 },
                               { xi.item.SLEEPSHROOM,            200 },
                               { xi.item.WOOZYSHROOM,            200 },
                               { xi.item.GHOSTFLICKER,     150 },
                               { xi.item.WOLF_HIDE,              100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.SLEEPSHROOM,             50 } },
                    gold   = { { xi.item.BEETLE_JAW,             100 },
                               { xi.item.SLEEPSHROOM,             50 } },
                },
            },
        },
    },
}
