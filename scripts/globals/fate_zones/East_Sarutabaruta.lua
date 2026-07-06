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
        -- Crow Conspiracy
        -- A murder of Carrion Crows, driven
        -- from their nesting grounds, swoops
        -- down on travellers alongside a
        -- startled Savanna Rarab stampede.
        -----------------------------------
        {
            id          = "ES_CROW_01",
            name        = "Crow Conspiracy",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
			mapPos = "H-8",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area = { -3.6, -0.8, -61, 65 },

            entryPos = { -3.670, -0.811, -60.948, 249 }, -- !pos -3.670 -0.811 -60.948 116

            mobs =
            {
                {
                    base        = { 116, 10 },
                    name        = string.char(0xA6) .. "Carrion Crow",
                    count       = 6,
                    spawnPoints =
                    {
                        { -5.093, -0.382, -47.502, 45 }, -- !pos -5.093 -0.382 -47.502 116
                        { 7.631, -0.460, -46.624, 240 }, -- !pos 7.631 -0.460 -46.624 116
                        { 8.195, -1.249, -63.094, 16 }, -- !pos 8.195 -1.249 -63.094 116
                        { -4.079, -0.598, -67.275, 100 }, -- !pos -4.079 -0.598 -67.275 116
						{ 3.267, -0.000, -77.256, 4 }, -- !pos 3.267 -0.000 -77.256 116
						{ 21.070, -1.715, -55.655, 248 }, -- !pos 21.070 -1.715 -55.655 116
                    },
                },
                {
                    base        = { 116, 8 },
                    name        = string.char(0xA6) .. "Savanna Rarab",
                    count       = 4,
                    spawnPoints =
                    {
                        { 23.552, -2.451, -77.033, 251 }, -- !pos 23.552 -2.451 -77.033 116
                        { -0.466, -0.000, -38.626, 159 }, -- !pos -0.466 -0.000 -38.626 116
						{ -22.624, -1.815, -54.315, 251 }, -- !pos -22.624 -1.815 -54.315 116
						{ -9.999, 0.306, -44.699, 255 }, -- !pos -9.999 0.306 -44.699 116
						
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
                    bronze = { { xi.item.BIRD_FEATHER,            240 } },
                    silver = { { xi.item.BIRD_FEATHER,            240 },
                               { xi.item.BIRD_EGG,               150 } },
                    gold   = { { xi.item.BIRD_FEATHER,            240 },
                               { xi.item.BIRD_EGG,               200 },
                               { xi.item.GIANT_BIRD_FEATHER,      100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BIRD_FEATHER,             50 } },
                    gold   = { { xi.item.BIRD_FEATHER,            100 } },
                },
            },
        },

        -----------------------------------
        -- Yagudo War Flock
        -- A war flock of Yagudo Initiates
        -- and Acolytes sweeps out of the
        -- eastern hills toward the
        -- Horutoto Ruins path.
        -----------------------------------
        {
            id          = "ES_YAGUDO_01",
            name        = "Yagudo War Flock",
            level       = 11,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "ES_YAGUDO_02",
            progressVal = 1,
			mapPos = "I-8",

            objective = { type = "kill", count = 8 },

            area = { 96, -9, 44, 65 },

            entryPos = { 96.256, -9.014, 44.424, 41 }, -- !pos 96.256 -9.014 44.424 116

            mobs =
            {
                {
                    base        = { 116, 11 },
                    name        = string.char(0xA6) .. "Yagudo Initiate",
                    count       = 5,
                    spawnPoints =
                    {
                        { 106.876, -7.688, 45.461, 47 }, -- !pos 106.876 -7.688 45.461 116
                        { 120.134, -7.943, 35.489, 156 }, -- !pos 120.134 -7.943 35.489 116
                        { 82.080, -8.000, 36.446, 162 }, -- !pos 82.080 -8.000 36.446 116
						{ 99.654, -10.359, 58.207, 195 }, -- !pos 99.654 -10.359 58.207 116
						{ 120.299, -9.608, 52.807, 49 }, -- !pos 120.299 -9.608 52.807 116
                    },
                },
                {
                    base        = { 116, 12 },
                    name        = string.char(0xA6) .. "Yagudo Acolyte",
                    count       = 3,
                    spawnPoints =
                    {
                        { 120.252, -10.827, 66.565, 236 }, -- !pos 120.252 -10.827 66.565 116
                        { 107.964, -7.663, 45.239, 115 }, -- !pos 107.964 -7.663 45.239 116
						{ 106.431, -9.827, 61.664, 245 }, -- !pos 106.431 -9.827 61.664 116
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 850 },
                    silver = { exp = 425 },
                    bronze = { exp = 210 },
                },
                fail =
                {
                    gold   = { exp = 265 },
                    silver = { exp = 160 },
                    bronze = { exp = 80  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.YAGUDO_FEATHER,          150 } },
                    silver = { { xi.item.YAGUDO_FEATHER,          200 },
                               { xi.item.BIRD_FEATHER,            150 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          200 },
                               { xi.item.BIRD_FEATHER,            150 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,     50 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,           50 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          100 } },
                },
            },
        },

        -----------------------------------
        -- Yagudo Storm Front
        -- Chains from Yagudo War Flock.
        -- Yagudo Scribes arrive to bolster
        -- the flock with dark prayers and
        -- cutting talons.
        -----------------------------------
        {
            id          = "ES_YAGUDO_02",
            name        = "Yagudo Storm Front",
            level       = 13,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,
			mapPos = "G-9",

            objective = { type = "kill", count = 5 },

            area = { -242, 0, -111, 55 },

            entryPos = { -242.535, -0.301, -111.213, 8 }, -- !pos -242.535 -0.301 -111.213 116

            mobs =
            {
                {
                    base        = { 116, 13 },
                    name        = string.char(0xA6) .. "Yagudo Scribe",
                    count       = 3,
                    spawnPoints =
                    {
                        { -224.768, -1.661, -97.211, 239 }, -- !pos -224.768 -1.661 -97.211 116
                        { -221.503, -1.251, -127.059, 10 }, -- !pos -221.503 -1.251 -127.059 116
						{ -261.369, -2.142, -87.164, 150 }, -- !pos -261.369 -2.142 -87.164 116
						{ -210.942, -3.509, -95.844, 244 }, -- !pos -210.942 -3.509 -95.844 116
						{ -220.265, -2.549, -112.721, 125 }, -- !pos -220.265 -2.549 -112.721 116
                    },
                },
                {
                    base        = { 116, 12 },
                    name        = string.char(0xA6) .. "Yagudo Acolyte",
                    count       = 2,
                    spawnPoints =
                    {
                        { -224.768, -1.661, -97.211, 239 }, -- !pos -224.768 -1.661 -97.211 116
                        { -221.503, -1.251, -127.059, 10 }, -- !pos -221.503 -1.251 -127.059 116
						{ -261.369, -2.142, -87.164, 150 }, -- !pos -261.369 -2.142 -87.164 116
						{ -210.942, -3.509, -95.844, 244 }, -- !pos -210.942 -3.509 -95.844 116
						{ -220.265, -2.549, -112.721, 125 }, -- !pos -220.265 -2.549 -112.721 116
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
                    bronze = { { xi.item.YAGUDO_FEATHER,          100 } },
                    silver = { { xi.item.YAGUDO_FEATHER,          200 },
                               { xi.item.BIRD_FEATHER,            100 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          200 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    150 },
                               { xi.item.BIRD_FEATHER,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,           50 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          100 },
                               { xi.item.BIRD_FEATHER,             50 } },
                },
            },
        },

        -----------------------------------
        -- Savanna Matriarch
        -- An ancient Mandragora of immense
        -- size tears free of the earth in
        -- a frenzy, uprooting a swarm of
        -- Tiny Mandragora in its wake.
        -----------------------------------
        {
            id          = "ES_BOSS_01",
            name        = "Savanna Matriarch",
            level       = 16,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,
			mapPos = "G-4",

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A blood-curdling shriek echoes across the eastern sarutabaruta...",
                "The wailing grows louder and the earth itself seems to writhe...",
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

            area = { -234, -24, 635, 70 },

            entryPos = { -234.053, -23.910, 635.551, 63 }, -- !pos -234.053 -23.910 635.551 116

            mobs =
            {
                {
                    base         = { 116, 16 },
                    name         = string.char(0xA6) .. "The Matriarch",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
					size         = 3,
                    spawnPoints  =
                    {
                        { -237.597, -23.591, 670.057, 50 }, -- !pos -237.597 -23.591 670.057 116
                    },
                },
                {
                    base        = { 116, 6 },
                    name        = string.char(0xA6) .. "Tiny Mandragora",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { -232.069, -23.598, 650.966, 64 }, -- !pos -232.069 -23.598 650.966 116
                        { -242.327, -23.750, 648.436, 106 }, -- !pos -242.327 -23.750 648.436 116
                        { -242.327, -23.750, 648.436, 106 }, -- !pos -242.327 -23.750 648.436 116
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
                    guaranteed = { xi.item.THREE_LEAF_MANDRAGORA_BUD },
                    bronze = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 },
                               { xi.item.TWO_LEAF_MANDRAGORA_BUD,  150 } },
                    silver = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 },
                               { xi.item.FOUR_LEAF_MANDRAGORA_BUD, 150 },
                               { xi.item.TWO_LEAF_MANDRAGORA_BUD,  200 } },
                    gold   = { { xi.item.FOUR_LEAF_MANDRAGORA_BUD, 200 },
                               { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 },
                               { xi.item.TWO_LEAF_MANDRAGORA_BUD,  200 },
							   { xi.item.FIELDWARDEN_CAP,  100 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,     100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TWO_LEAF_MANDRAGORA_BUD,   50 } },
                    gold   = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 100 },
                               { xi.item.TWO_LEAF_MANDRAGORA_BUD,   50 } },
                },
            },
        },

        -----------------------------------
        -- Rarab Stampede
        -- A panicked herd of Savanna Rarabs
        -- thunders across the eastern plains,
        -- scattering travellers and causing
        -- widespread disruption.
        -----------------------------------
        {
            id          = "ES_RARAB_01",
            name        = "Rarab Stampede",
            level       = 9,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,
			mapPos = "I-9",

            objective = { type = "kill", count = 9 },

            area = { 75, 0, -168, 65 },

            entryPos = { 74.923, 0.256, -168.749, 60 }, -- !pos 74.923 0.256 -168.749 116

            mobs =
            {
                {
                    base        = { 116, 8 },
                    name        = string.char(0xA6) .. "Savanna Rarab",
                    count       = 6,
                    spawnPoints =
                    {
                        { 65.252, -0.233, -166.202, 38 }, -- !pos 65.252 -0.233 -166.202 116
                        { 59.341, -1.211, -157.737, 179 }, -- !pos 59.341 -1.211 -157.737 116
                        { 69.902, -1.007, -154.721, 253 }, -- !pos 69.902 -1.007 -154.721 116
                        { 87.005, -0.439, -153.011, 3 }, -- !pos 87.005 -0.439 -153.011 116
                        { 97.798, -0.753, -163.623, 27 }, -- !pos 97.798 -0.753 -163.623 116
                        { 92.675, 1.149, -185.119, 67 }, -- !pos 92.675 1.149 -185.119 116
                    },
                },
                {
                    base        = { 116, 10 },  -- TODO: verify mob_groups (Hill Sapling)
                    name        = string.char(0xA6) .. "Hill Vulture",
                    count       = 3,
                    spawnPoints =
                    {
                        { 59.975, 0.272, -186.402, 121 }, -- !pos 59.975 0.272 -186.402 116
                        { 50.965, 0.384, -167.181, 147 }, -- !pos 50.965 0.384 -167.181 116
                        { 80.966, 0.000, -160.545, 232 }, -- !pos 80.966 0.000 -160.545 116
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 700 },
                    silver = { exp = 350 },
                    bronze = { exp = 175 },
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
                    bronze = { { xi.item.RARAB_TAIL,              150 } },
                    silver = { { xi.item.RARAB_TAIL,              200 },
                               { xi.item.BIRD_FEATHER,            100 } },
                    gold   = { { xi.item.RARAB_TAIL,              200 },
                               { xi.item.BIRD_FEATHER,            150 },
                               { xi.item.BEAST_HIDE,              100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.RARAB_TAIL,               50 } },
                    gold   = { { xi.item.RARAB_TAIL,              100 } },
                },
            },
        },

        -----------------------------------
        -- Mandragora Rising
        -- A patch of Tiny Mandragora erupts
        -- from the soil near the Horutoto
        -- Ruins, pulling travellers' legs
        -- as they pass.
        -----------------------------------
        {
            id          = "ES_MANDRAGORA_01",
            name        = "Mandragora Rising",
            level       = 4,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "ES_MANDRAGORA_02",
            progressVal = 1,
			mapPos = "H-10",

            objective = { type = "kill", count = 9 },

            area = { -84, -5, -378, 65 },

            entryPos = { -84.557, -5.169, -378.680, 42 }, -- !pos -84.557 -5.169 -378.680 116

            mobs =
            {
                {
                    base        = { 116, 6 },
                    name        = string.char(0xA6) .. "Tiny Mandragora",
                    count       = 6,
                    spawnPoints =
                    {
                        { -100.432, -5.527, -382.234, 100 }, -- !pos -100.432 -5.527 -382.234 116
                        { -122.557, -5.211, -380.647, 123 }, -- !pos -122.557 -5.211 -380.647 116
                        { -107.293, -3.500, -360.438, 217 }, -- !pos -107.293 -3.500 -360.438 116
                        { -89.560, -4.500, -371.750, 27 }, -- !pos -89.560 -4.500 -371.750 116
                        { -75.282, -4.500, -387.738, 33 }, -- !pos -75.282 -4.500 -387.738 116
                        { -83.638, -3.500, -412.529, 67 }, -- !pos -83.638 -3.500 -412.529 116
                    },
                },
                {
                    base        = { 116, 6 },  -- TODO: verify mob_groups (Savanna Mandragora)
                    name        = string.char(0xA6) .. "Wild Mandragora",
                    count       = 3,
                    spawnPoints =
                    {
                        { -93.706, -3.794, -410.090, 118 }, -- !pos -93.706 -3.794 -410.090 116
                        { -85.079, -4.069, -397.931, 202 }, -- !pos -85.079 -4.069 -397.931 116
                        { -70.270, -4.360, -396.268, 251 }, -- !pos -70.270 -4.360 -396.268 116
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
                    bronze = { { xi.item.TWO_LEAF_MANDRAGORA_BUD, 150 } },
                    silver = { { xi.item.TWO_LEAF_MANDRAGORA_BUD, 200 },
                               { xi.item.YAGUDO_FEATHER,          100 } },
                    gold   = { { xi.item.TWO_LEAF_MANDRAGORA_BUD, 200 },
                               { xi.item.YAGUDO_FEATHER,          150 },
                               { xi.item.THREE_LEAF_MANDRAGORA_BUD, 100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TWO_LEAF_MANDRAGORA_BUD,  50 } },
                    gold   = { { xi.item.TWO_LEAF_MANDRAGORA_BUD, 100 } },
                },
            },
        },

        -----------------------------------
        -- Mandragora Elder Brood
        -- Chains from Mandragora Rising.
        -- Three-Leaf Mandragora elders answer
        -- the distress shriek of the smaller
        -- plants and converge on the zone.
        -----------------------------------
        {
            id          = "ES_MANDRAGORA_02",
            name        = "Mandragora Madness",
            level       = 9,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,
			mapPos = "H-9",

            objective = { type = "kill", count = 5 },

            area = { -47, -4, -201, 55 },

            entryPos = { -47.536, -4.449, -201.267, 63 }, -- !pos -47.536 -4.449 -201.267 116

            mobs =
            {
                {
                    base        = { 116, 6 },  -- TODO: verify mob_groups (Mandragora elder)
                    name        = string.char(0xA6) .. "Mad Mandragora",
                    count       = 5,
                    spawnPoints =
                    {
                        { -56.929, -3.746, -195.204, 144 }, -- !pos -56.929 -3.746 -195.204 116
                        { -52.533, -0.925, -176.849, 206 }, -- !pos -52.533 -0.925 -176.849 116
						{ -30.630, -0.999, -181.698, 16 }, -- !pos -30.630 -0.999 -181.698 116
						{ -17.508, -2.000, -203.794, 54 }, -- !pos -17.508 -2.000 -203.794 116
						{ -39.595, -2.768, -213.916, 103 }, -- !pos -39.595 -2.768 -213.916 116
						{ -64.823, -4.425, -207.895, 139 }, -- !pos -64.823 -4.425 -207.895 116
						{ -69.451, -3.085, -186.036, 179 }, -- !pos -69.451 -3.085 -186.036 116
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
                    bronze = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 100 } },
                    silver = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 200 },
                               { xi.item.YAGUDO_FEATHER,            100 } },
                    gold   = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 },
                               { xi.item.FOUR_LEAF_MANDRAGORA_BUD,  150 },
                               { xi.item.YAGUDO_FEATHER,            100 } },
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
        -- The Flock Father
        -- A Yagudo High Priest of enormous
        -- power descends from the eastern
        -- sky, supported by Yagudo monks,
        -- seeking to cleanse the savanna.
        -----------------------------------
        {
            id          = "ES_BOSS_02",
            name        = "The Flock Father",
            level       = 14,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
			bossStars = 2,
            minCooldown = 5400,
            progressVal = 2,
			mapPos = "F-9",

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "Yagudo battle hymns drift in from the east of Sarutabaruta...",
                "The hymns crescendo into a war chant and a huge winged form swoops into view...",
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

            area = { -359, -4, -118, 80 },

            entryPos = { -348.867, -1.705, -98.666, 204 }, -- !pos -348.867 -1.705 -98.666 116

            mobs =
            {
                {
                    base         = { 116, 11 },  -- TODO: verify mob_groups (Yagudo Prelate / Priest)
                    name         = string.char(0xA6) .. "Flock Father",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { -359.385, -4.000, -118.014, 214 }, -- !pos -359.385 -4.000 -118.014 116
                    },
                },
                {
                    base        = { 116, 13 },
                    name        = string.char(0xA6) .. "Yagudo Scribe",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { -366.849, -2.936, -134.347, 66 }, -- !pos -366.849 -2.936 -134.347 116
                        { -359.173, -2.161, -101.224, 200 }, -- !pos -359.173 -2.161 -101.224 116
                        { -354.324, -3.797, -115.057, 26 }, -- !pos -354.324 -3.797 -115.057 116
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
                    guaranteed = { xi.item.YAGUDO_FEATHER },
                    bronze = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.BIRD_FEATHER,            150 } },
                    silver = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.BIRD_FEATHER,            200 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    100 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.BIRD_FEATHER,            200 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    150 },
                               { xi.item.FIELDWARDEN_CAP,         100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,           50 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          100 },
                               { xi.item.BIRD_FEATHER,             50 } },
                },
            },
        },

        -----------------------------------
        -- The Savanna Doomsayer
        -- A legendary Yagudo Prophet whose
        -- cry alone can shatter stone descends
        -- upon East Sarutabaruta at dawn,
        -- leading the full Temple Guard.
        -- Spawns rarely. Pray for cloudless skies.
        -----------------------------------
        {
            id          = "ES_BOSS_03",
            name        = "The Savanna Doomsayer",
            level       = 20,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,
			bossStars = 3,
			mapPos = "K-6",

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A bone-chilling wail rolls across the eastern savanna...",
                "The horizon darkens with beating wings! The Doomseer is here!",
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

            area = { 433, -2.5, 298, 110 },

            entryPos = { 412.131, -3.711, 310.072, 128 }, -- !pos 412.131 -3.711 310.072 116

            mobs =
            {
                {
                    base         = { 134, 102 },  -- TODO: verify mob_groups (high-tier Yagudo)
                    name         = string.char(0xA6) .. "Exile Doomseer",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 433.866, -2.500, 298.323, 134 }, -- !pos 433.866 -2.500 298.323 116
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
                    guaranteed = { xi.item.YAGUDO_BEAD_NECKLACE },
                    bronze = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    200 } },
                    silver = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    200 },
                               { xi.item.FOUR_LEAF_MANDRAGORA_BUD, 150 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          240 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    200 },
                               { xi.item.FOUR_LEAF_MANDRAGORA_BUD, 200 },
                               { xi.item.FIELDWARDEN_CAP,         150 },
                               { xi.item.GIANT_BIRD_FEATHER,      100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YAGUDO_FEATHER,           50 } },
                    gold   = { { xi.item.YAGUDO_BEAD_NECKLACE,    100 },
                               { xi.item.YAGUDO_FEATHER,           50 } },
                },
            },
        },
    },
}
