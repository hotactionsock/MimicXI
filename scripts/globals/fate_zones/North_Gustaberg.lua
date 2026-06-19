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
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Hornet Swarm
        -- A colony of Huge Hornets and
        -- Maneating Hornets driven from
        -- their nest storms the cliffs
        -- near the Bastok Mines gate.
        -----------------------------------
        {
            id          = "NG_HORNET_01",
            name        = "Hornet Swarm",
            level       = 10,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = -58,
                y      = 2,
                z      = 100,
                radius = 75,
            },

            entryPos = { -58.000, 2.669, 100.000, 0 }, -- !pos -58.000 2.669 100.000 106

            mobs =
            {
                {
                    base        = { 106, 6 },
                    name        = string.char(0xA6) .. "Huge Hornet",
                    count       = 5,
                    spawnPoints =
                    {
                        { -43.265, 0.741, 110.945, 159 }, -- !pos -43.265 0.741 110.945 106
                        { -53.941, 0.908, 85.788, 196 }, -- !pos -53.941 0.908 85.788 106
                        { -38.938, 2.497, 99.957, 177 }, -- !pos -38.938 2.497 99.957 106
						{ -96.052, 2.291, 108.264, 6 }, -- !pos -96.052 2.291 108.264 106
						{ -63.092, 0.795, 114.065, 179 }, -- !pos -63.092 0.795 114.065 106
                    },
                },
                {
                    base        = { 106, 9 },
                    name        = string.char(0xA6) .. "Killer Hornet",
                    count       = 4,
                    spawnPoints =
                    {
                        { -64.262, -0.446, 90.487, 229 }, -- !pos -64.262 -0.446 90.487 106
                        { -84.762, 0.382, 113.471, 25 }, -- !pos -84.762 0.382 113.471 106
						{ -105.597, 2.025, 107.374, 80 }, -- !pos -105.597 2.025 107.374 106
						{ -99.118, 2.439, 81.160, 215 }, -- !pos -99.118 2.439 81.160 106
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 800 },
                    silver = { exp = 400 },
                    bronze = { exp = 150 },
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
                    bronze = { { xi.item.BEEHIVE_CHIP,          240 } },
                    silver = { { xi.item.BEEHIVE_CHIP,          240 },
                               { xi.item.INSECT_WING,           150 } },
                    gold   = { { xi.item.BEEHIVE_CHIP,          240 },
                               { xi.item.INSECT_WING,           150 },
                               { xi.item.GIANT_STINGER,         100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEEHIVE_CHIP,           50 } },
                    gold   = { { xi.item.BEEHIVE_CHIP,          100 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Survey
        -- Young Quadav scouts emerge from
        -- the foothills near Palborough to
        -- assess Bastokan defences.
        -----------------------------------
        {
            id          = "NG_QUADAV_01",
            name        = "Quadav Survey",
            level       = 12,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "NG_QUADAV_02",
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = -18,
                y      = 3,
                z      = 497,
                radius = 75,
            },

            entryPos = { -18.155, 2.959, 497.166, 69 }, -- !pos -18.155 2.959 497.166 106

            mobs =
            {
                {
                    base        = { 106, 22 },
                    name        = string.char(0xA6) .. "Young Quadav",
                    count       = 5,
                    spawnPoints =
                    {
                        { -15.623, 2.379, 513.587, 61 }, -- !pos -15.623 2.379 513.587 106
                        { -32.331, 0.623, 514.591, 78 }, -- !pos -32.331 0.623 514.591 106
                        { -20.633, 2.439, 523.927, 3 }, -- !pos -20.633 2.439 523.927 106
						{ 0.119, 0.485, 512.067, 2 }, -- !pos 0.119 0.485 512.067 106
						{ -37.693, 0.380, 512.897, 42 }, -- !pos -37.693 0.380 512.897 106
                    },
                },
                {
                    base        = { 106, 23 },
                    name        = string.char(0xA6) .. "Amber Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { -39.143, -0.000, 523.503, 74 }, -- !pos -39.143 -0.000 523.503 106
                        { -30.598, 0.977, 514.747, 45 }, -- !pos -30.598 0.977 514.747 106
						{ -8.326, -0.294, 528.869, 54 }, -- !pos -8.326 -0.294 528.869 106
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
                    bronze = { { xi.item.BONE_CHIP,             150 } },
                    silver = { { xi.item.BONE_CHIP,             150 },
                               { xi.item.QUADAV_HELM,           100 } },
                    gold   = { { xi.item.QUADAV_HELM,           150 },
                               { xi.item.BONE_CHIP,             150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,  100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,              50 } },
                    gold   = { { xi.item.BONE_CHIP,             100 },
                               { xi.item.QUADAV_HELM,            50 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Vanguard
        -- Chains from Quadav Survey.
        -- Emboldened by the scouts' report,
        -- Amethyst Quadav press the advance.
        -----------------------------------
        {
            id          = "NG_QUADAV_02",
            name        = "Quadav Vanguard",
            level       = 14,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 12,
                y      = 3,
                z      = 581,
                radius = 81,
            },

            entryPos = { 12.713, 3.144, 581.524, 101 }, -- !pos 12.713 3.144 581.524 106

            mobs =
            {
                {
                    base        = { 106, 24 },
                    name        = string.char(0xA6) .. "Purple Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { 16.752, -0.110, 601.735, 81 }, -- !pos 16.752 -0.110 601.735 106
                        { 37.392, 2.368, 577.745, 143 }, -- !pos 37.392 2.368 577.745 106
						{ 28.914, 1.190, 551.197, 202 }, -- !pos 28.914 1.190 551.197 106
                    },
                },
                {
                    base        = { 106, 23 },
                    name        = string.char(0xA6) .. "Amber Quadav",
                    count       = 2,
                    spawnPoints =
                    {
                        { 3.323, -0.300, 542.016, 150 }, -- !pos 3.323 -0.300 542.016 106
                        { -23.212, 2.344, 564.640, 235 }, -- !pos -23.212 2.344 564.640 106
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
                    bronze = { { xi.item.BONE_CHIP,             100 } },
                    silver = { { xi.item.QUADAV_HELM,           150 },
                               { xi.item.BONE_CHIP,             100 } },
                    gold   = { { xi.item.QUADAV_HELM,           200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,  150 },
                               { xi.item.BONE_CHIP,             100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,              50 } },
                    gold   = { { xi.item.QUADAV_HELM,            50 },
                               { xi.item.BONE_CHIP,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Crumbling Colossus
        -- A colossal Stone Eater, maddened
        -- by tremors in the Gustaberg rock,
        -- erupts from the earth and
        -- charges toward the mines gate.
        -----------------------------------
        {
            id          = "NG_BOSS_01",
            name        = "The Crumbling Colossus",
            level       = 18,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The ground trembles underfoot across North Gustaberg...",
                "Deep rumbling shakes the cliffs - something massive stirs below...",
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
                x      = 300,
                y      = -62,
                z      = 500,
                radius = 138,
            },

            entryPos = { 304.789, -59.900, 552.860, 197 }, -- !pos 304.789 -59.900 552.860 106

            mobs =
            {
                {
                    base         = { 174, 37 },
                    name         = string.char(0xA6) .. "Bedrock Titan",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
					size		 = 3,
                    spawnPoints  =
                    {
                        { 299.942, -61.300, 505.030, 186 }, -- !pos 299.942 -61.300 505.030 106
                    },
                },
                {
                    base        = { 106, 19 },
                    name        = string.char(0xA6) .. "Agitated Newt",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 288.346, -60.717, 526.312, 222 }, -- !pos 288.346 -60.717 526.312 106
                        { 323.920, -60.629, 509.125, 211 }, -- !pos 323.920 -60.629 509.125 106
                        { 324.930, -60.657, 532.076, 155 }, -- !pos 324.930 -60.657 532.076 106
						{ 282.543, -60.071, 547.722, 17 }, -- !pos 282.543 -60.071 547.722 106
						{ 265.638, -59.505, 526.422, 82 }, -- !pos 265.638 -59.505 526.422 106
						{ 278.962, -60.097, 492.403, 53 }, -- !pos 278.962 -60.097 492.403 106
						{ 323.398, -60.041, 487.379, 215 }, -- !pos 323.398 -60.041 487.379 106
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
                    guaranteed = { xi.item.LIZARD_TAIL },
                    bronze = { { xi.item.LIZARD_TAIL,           240 },
                               { xi.item.LIZARD_EGG,            150 } },
                    silver = { { xi.item.LIZARD_TAIL,           240 },
                               { xi.item.LIZARD_EGG,            200 },
                               { xi.item.CHUNK_OF_IRON_ORE,     150 } },
                    gold   = { { xi.item.LIZARD_TAIL,           240 },
                               { xi.item.LIZARD_EGG,            200 },
                               { xi.item.CHUNK_OF_IRON_ORE,     200 },
							   { xi.item.ASHGRAIN_VEST,         150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,  150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LIZARD_TAIL,            50 } },
                    gold   = { { xi.item.LIZARD_TAIL,           100 },
                               { xi.item.LIZARD_EGG,             50 } },
                },
            },
        },

        -----------------------------------
        -- Newt Frenzy
        -- Agitated Newts swarm from the
        -- rock pools east of the Bastok
        -- Mines gate, blocking the road.
        -----------------------------------
        {
            id          = "NG_NEWT_01",
            name        = "Newt Frenzy",
            level       = 10,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 65,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 106

            mobs =
            {
                {
                    base        = { 106, 19 },
                    name        = string.char(0xA6) .. "Agitated Newt",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                    },
                },
                {
                    base        = { 106, 20 },  -- TODO: verify mob_groups
                    name        = string.char(0xA6) .. "Hill Lizard",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
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
                    bronze = { { xi.item.LIZARD_TAIL,            150 } },
                    silver = { { xi.item.LIZARD_TAIL,            200 },
                               { xi.item.LIZARD_EGG,             100 } },
                    gold   = { { xi.item.LIZARD_TAIL,            200 },
                               { xi.item.LIZARD_EGG,             150 },
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
        -- Funguar Bloom
        -- A sudden bloom of Funguar draws
        -- Quadav foragers from the mines;
        -- both the fungi and the Quadav
        -- must be driven back.
        -----------------------------------
        {
            id          = "NG_FUNGUAR_01",
            name        = "Funguar Bloom",
            level       = 12,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "NG_FUNGUAR_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 106

            mobs =
            {
                {
                    base        = { 106, 21 },  -- TODO: verify mob_groups (Forest Funguar)
                    name        = string.char(0xA6) .. "Forest Funguar",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                    },
                },
                {
                    base        = { 106, 23 },
                    name        = string.char(0xA6) .. "Amber Quadav",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
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
                    bronze = { { xi.item.BONE_CHIP,              150 } },
                    silver = { { xi.item.BONE_CHIP,              200 },
                               { xi.item.QUADAV_HELM,            100 } },
                    gold   = { { xi.item.BONE_CHIP,              200 },
                               { xi.item.QUADAV_HELM,            150 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.BONE_CHIP,              100 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Spelunkers
        -- Chains from Funguar Bloom.
        -- Amethyst Quadav emerge from hidden
        -- tunnels beneath the bloom site,
        -- weapons drawn.
        -----------------------------------
        {
            id          = "NG_FUNGUAR_02",
            name        = "Quadav Spelunkers",
            level       = 14,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 55,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 106

            mobs =
            {
                {
                    base        = { 106, 24 },
                    name        = string.char(0xA6) .. "Purple Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                    },
                },
                {
                    base        = { 106, 25 },  -- TODO: verify mob_groups (Sapphire Quadav)
                    name        = string.char(0xA6) .. "Blue Quadav",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
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
                    bronze = { { xi.item.BONE_CHIP,              100 } },
                    silver = { { xi.item.QUADAV_HELM,            150 },
                               { xi.item.BONE_CHIP,              100 } },
                    gold   = { { xi.item.QUADAV_HELM,            200 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.QUADAV_HELM,             50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Hollow King
        -- A Stone Eater of extraordinary
        -- age rises near the Bastok Mines
        -- gate, its hide thick as castle
        -- walls from centuries underground.
        -----------------------------------
        {
            id          = "NG_BOSS_02",
            name        = "The Hollow King",
            level       = 15,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A subsidence crack opens along the northern road of Gustaberg...",
                "The crack widens and heaves - something ancient and enormous forces its way free...",
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
                radius = 80,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 106

            mobs =
            {
                {
                    base         = { 174, 37 },
                    name         = string.char(0xA6) .. "Hollow King",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                    },
                },
                {
                    base        = { 106, 19 },
                    name        = string.char(0xA6) .. "Agitated Newt",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
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
                    guaranteed = { xi.item.LIZARD_TAIL },
                    bronze = { { xi.item.LIZARD_TAIL,            240 },
                               { xi.item.LIZARD_EGG,             150 } },
                    silver = { { xi.item.LIZARD_TAIL,            240 },
                               { xi.item.LIZARD_EGG,             200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
                    gold   = { { xi.item.LIZARD_TAIL,            240 },
                               { xi.item.LIZARD_EGG,             200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 },
                               { xi.item.ASHGRAIN_VEST,          100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LIZARD_TAIL,             50 } },
                    gold   = { { xi.item.LIZARD_TAIL,            100 },
                               { xi.item.LIZARD_EGG,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Primordial Crusher
        -- A legendary Stone Eater said to
        -- have fed on Gustaberg's ore veins
        -- since before the Crystal War;
        -- its body is a mountain in miniature.
        -- Spawns rarely. A formidable threat.
        -----------------------------------
        {
            id          = "NG_BOSS_03",
            name        = "The Primordial Crusher",
            level       = 22,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The entire hillside of North Gustaberg begins to tremble...",
                "A catastrophic upheaval splits the rock face - something unimaginably vast emerges...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 106

            mobs =
            {
                {
                    base         = { 174, 37 },
                    name         = string.char(0xA6) .. "Primal Crusher",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                    },
                },
                {
                    base        = { 106, 24 },
                    name        = string.char(0xA6) .. "Purple Quadav",
                    count       = 5,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 106
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 4500 },
                    silver = { exp = 2250 },
                    bronze = { exp = 1125 },
                },
                fail =
                {
                    gold   = { exp = 1125 },
                    silver = { exp = 560  },
                    bronze = { exp = 280  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.CHUNK_OF_MYTHRIL_ORE },
                    bronze = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   240 },
                               { xi.item.LIZARD_TAIL,            200 } },
                    silver = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   240 },
                               { xi.item.LIZARD_TAIL,            200 },
                               { xi.item.LIZARD_EGG,             150 } },
                    gold   = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   240 },
                               { xi.item.LIZARD_TAIL,            200 },
                               { xi.item.LIZARD_EGG,             200 },
                               { xi.item.ASHGRAIN_VEST,          150 },
                               { xi.item.WAILING_RAM_HORN,       100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LIZARD_TAIL,             50 } },
                    gold   = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 },
                               { xi.item.LIZARD_TAIL,             50 } },
                },
            },
        },
    },
}
