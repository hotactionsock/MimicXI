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
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Goblin Assault
        -- A band of goblins from Beadeaux
        -- pushes toward Bastok Outskirts.
        -----------------------------------
        {
            id                = "SG_GOBLIN_01",
            name              = "Goblin Assault",
            level             = 8,
            duration          = 600,
            chainOnly         = false,
            chainOnWin        = "SG_GOBLIN_02",
            progressVal       = 1,
            dynamicDifficulty = true,

            objective = { type = "kill", count = 8 },

            area = { -95, 10, -260, 75 },

            entryPos = { -91.489, 11.053, -260.794, 120 }, -- !pos -91.489 11.053 -260.794 107

            mobs =
            {
                {
                    base        = { 107, 13 },
                    name        = string.char(0xA6) .. "Goblin Thug",
                    count       = 6,
                    spawnPoints =
                    {
                        { -88,  10, -268, 143 }, -- !pos -88 10 -268 107
                        { -108, 10, -268, 143 }, -- !pos -108 10 -268 107
                    },
                },
                {
                    base        = { 107, 16 },
                    name        = string.char(0xA6) .. "Goblin Weaver",
                    count       = 2,
                    spawnPoints =
                    {
                        { -95, 10, -248, 143 }, -- !pos -95 10 -248 107
                        { -95, 10, -288, 143 }, -- !pos -95 10 -288 107
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 800 },
                    silver = { exp = 400  },
                    bronze = { exp = 150  },
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

            area = { -149, 10, -329, 63 },

            entryPos = { -149.675, 10.283, -329.442, 241 }, -- !pos -149.675 10.283 -329.442 107

            mobs =
            {
                {
                    base        = { 107, 31 },
                    name        = string.char(0xA6) .. "Goblin Digger",
                    count       = 2,
                    spawnPoints =
                    {
                        { -160.972, 11.226, -348.988, 249 }, -- !pos -160.972 11.226 -348.988 107
                        { -172.568, 10.929, -333.463, 172 }, -- !pos -172.568 10.929 -333.463 107
						{ -165.104, 9.338, -310.484, 202 }, -- !pos -165.104 9.338 -310.484 107
						{ -134.993, 12.134, -324.421, 15 }, -- !pos -134.993 12.134 -324.421 107
						{ -133.377, 11.038, -349.816, 60 }, -- !pos -133.377 11.038 -349.816 107
                    },
                },
                {
                    base        = { 107, 26 },
                    name        = string.char(0xA6) .. "Goblin Fisher",
                    count       = 2,
                    spawnPoints =
                    {
                        { -160.972, 11.226, -348.988, 249 }, -- !pos -160.972 11.226 -348.988 107
                        { -172.568, 10.929, -333.463, 172 }, -- !pos -172.568 10.929 -333.463 107
						{ -165.104, 9.338, -310.484, 202 }, -- !pos -165.104 9.338 -310.484 107
						{ -134.993, 12.134, -324.421, 15 }, -- !pos -134.993 12.134 -324.421 107
						{ -133.377, 11.038, -349.816, 60 }, -- !pos -133.377 11.038 -349.816 107
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 800 },
                    silver = { exp = 400  },
                    bronze = { exp = 200  },
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
            id                = "SG_QUADAV_01",
            name              = "Quadav Incursion",
            level             = 12,
            duration          = 720,
            chainOnly         = false,
            progressVal       = 1,
            dynamicDifficulty = true,

            objective = { type = "kill", count = 10 },

            area = { -420, 42, -377, 81 },

            entryPos = { -420.117, 42.682, -377.874, 12 }, -- !pos -420.117 42.682 -377.874 107

            mobs =
            {
                {
                    base        = { 107, 23 },
                    name        = string.char(0xA6) .. "Young Quadav",
                    count       = 6,
                    spawnPoints =
                    {
                        { -417.689, 42.347, -358.238, 86 }, -- !pos -417.689 42.347 -358.238 107
                        { -453.597, 39.654, -363.161, 46 }, -- !pos -453.597 39.654 -363.161 107
                        { -437.238, 39.719, -407.886, 250 }, -- !pos -437.238 39.719 -407.886 107
                        { -388.267, 39.331, -405.296, 149 }, -- !pos -388.267 39.331 -405.296 107
                        { -376.646, 37.609, -376.757, 142 }, -- !pos -376.646 37.609 -376.757 107
                        { -391.411, 40.475, -349.228, 85 }, -- !pos -391.411 40.475 -349.228 107
                    },
                },
                {
                    base        = { 107, 24 },
                    name        = string.char(0xA6) .. "Purple Quadav",
                    count       = 4,
                    spawnPoints =
                    {
                        { -368.840, 30.561, -391.576, 142 }, -- !pos -368.840 30.561 -391.576 107
                        { -450.385, 40.986, -423.131, 242 }, -- !pos -450.385 40.986 -423.131 107
                        { -444.810, 39.515, -372.189, 60 }, -- !pos -444.810 39.515 -372.189 107
                        { -409.509, 39.434, -386.735, 133 }, -- !pos -409.509 39.434 -386.735 107
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 800 },
                    silver = { exp = 400  },
                    bronze = { exp = 200  },
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
        -- Full Ram Ahead
        -- A massive Rampaging Ram driven
        -- from Konschtat Highlands tears
        -- through the zone. Requires a
        -- coordinated group to bring down.
        -----------------------------------
        {
            id          = "SG_BOSS_01",
            name        = "Full Ram Ahead",
            level       = 16,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "You hear the sound of distant thundering...",
                "The thundering echoes from the mountaintop...",
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

            area = { 203, -60, -424, 81 },

            entryPos = { 214.892, -59.589, -428.583, 75 }, -- !pos 214.892 -59.589 -428.583 107

            mobs =
            {
                {
                    base         = { 108, 29 },
                    name         = string.char(0xA6) .. "Rampaging Ram",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
					size		 = 3,
                    spawnPoints  =
                    {
                        { 200.868, -60.056, -403.514, 55 }, -- !pos 200.868 -60.056 -403.514 107
                    },
                },
                {
                    base        = { 107, 12 },
                    name        = string.char(0xA6) .. "Ornery Sheep",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 197.645, -60.040, -414.350, 48 }, -- !pos 197.645 -60.040 -414.350 107
                        { 204.970, -60.429, -413.873, 68 }, -- !pos 204.970 -60.429 -413.873 107
                        { 202.648, -60.187, -411.154, 59 }, -- !pos 202.648 -60.187 -411.154 107
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2000 },
                    silver = { exp = 1000 },
                    bronze = { exp = 500 },
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
                    guaranteed = { xi.item.RAM_HORN },
                    bronze = { { xi.item.CLUMP_OF_SHEEP_WOOL,    240 },
                               { xi.item.SHEEP_TOOTH,            150 } },
                    silver = { { xi.item.CLUMP_OF_SHEEP_WOOL,    240 },
                               { xi.item.SHEEP_TOOTH,            200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 } },
                    gold   = { { xi.item.WAILING_RAM_HORN,       200 },
                               { xi.item.CLUMP_OF_SHEEP_WOOL,    240 },
                               { xi.item.CHUNK_OF_IRON_ORE,      200 },
                               { xi.item.SHEEP_TOOTH,            200 },
							   { xi.item.COWHIDE_BELT,         150 } },
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
        -- Worm Eruption
        -- Tunnel Worms and Carrion Worms
        -- burst from the soil near the
        -- southern road, blocking the route
        -- between Bastok and the outskirts.
        -----------------------------------
        {
            id          = "SG_WORM_01",
            name        = "A Can of Worms",
            level       = 5,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area = { 400, 0, -411, 70 },

            entryPos = { 398.322, -0.053, -384.667, 192 }, -- !pos 398.322 -0.053 -384.667 107

            mobs =
            {
                {
                    base        = { 107, 8 },  -- TODO: verify mob_groups
                    name        = string.char(0xA6) .. "Tunnel Worm",
                    count       = 5,
                    spawnPoints =
                    {
                        { 403.720, -0.070, -432.927, 179 }, -- !pos 403.720 -0.070 -432.927 107
                        { 395.577, 0.055, -430.591, 200 }, -- !pos 395.577 0.055 -430.591 107
                        { 397.871, 0.090, -420.476, 196 }, -- !pos 397.871 0.090 -420.476 107
                        { 396.933, 0.000, -397.187, 191 }, -- !pos 396.933 0.000 -397.187 107
                        { 404.510, 0.030, -394.188, 229 }, -- !pos 404.510 0.030 -394.188 107
						{ 406.225, 0.135, -410.393, 31 }, -- !pos 406.225 0.135 -410.393 107
						{ 403.206, 0.100, -384.793, 186 }, -- !pos 403.206 0.100 -384.793 107
						{ 398.117, 0.000, -435.463, 56 }, -- !pos 398.117 0.000 -435.463 107
                    },
                },
                {
                    base        = { 107, 8 },  -- TODO: verify mob_groups
                    name        = string.char(0xA6) .. "Carrion Worm",
                    count       = 3,
                    spawnPoints =
                    {
                        { 403.720, -0.070, -432.927, 179 }, -- !pos 403.720 -0.070 -432.927 107
                        { 395.577, 0.055, -430.591, 200 }, -- !pos 395.577 0.055 -430.591 107
                        { 397.871, 0.090, -420.476, 196 }, -- !pos 397.871 0.090 -420.476 107
                        { 396.933, 0.000, -397.187, 191 }, -- !pos 396.933 0.000 -397.187 107
                        { 404.510, 0.030, -394.188, 229 }, -- !pos 404.510 0.030 -394.188 107
						{ 406.225, 0.135, -410.393, 31 }, -- !pos 406.225 0.135 -410.393 107
						{ 403.206, 0.100, -384.793, 186 }, -- !pos 403.206 0.100 -384.793 107
						{ 398.117, 0.000, -435.463, 56 }, -- !pos 398.117 0.000 -435.463 107
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 500 },
                    silver = { exp = 250 },
                    bronze = { exp = 125 },
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
                    bronze = { { xi.item.BRONZE_ORE,              240 } },
                    silver = { { xi.item.BRONZE_ORE,              240 },
                               { xi.item.ZINC_ORE,                150 } },
                    gold   = { { xi.item.BRONZE_ORE,              240 },
                               { xi.item.ZINC_ORE,                200 },
                               { xi.item.IRON_ORE,                100 } },
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
        -- Quadav Patrol
        -- A Quadav patrol from Palborough
        -- Mines sweeps the upper hills,
        -- targeting supply routes.
        -----------------------------------
        {
            id          = "SG_QUADAV_02",
            name        = "Quadav Patrol",
            level       = 11,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "SG_QUADAV_03",
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area = { -11, -1, -493, 70 },

            entryPos = { -11.004, -0.903, -493.384, 173 }, -- !pos -11.004 -0.903 -493.384 107

            mobs =
            {
                {
                    base        = { 107, 23 },
                    name        = string.char(0xA6) .. "Young Quadav",
                    count       = 5,
                    spawnPoints =
                    {
                        { -30.196, 8.734, -487.791, 151 }, -- !pos -30.196 8.734 -487.791 107
                        { -41.629, 9.579, -501.133, 117 }, -- !pos -41.629 9.579 -501.133 107
                        { -24.738, 7.668, -524.147, 9 }, -- !pos -24.738 7.668 -524.147 107
                        { -0.487, -0.083, -511.931, 254 }, -- !pos -0.487 -0.083 -511.931 107
                        { 4.693, -0.297, -488.798, 201 }, -- !pos 4.693 -0.297 -488.798 107
						{ -1.263, 1.506, -467.879, 191 }, -- !pos -1.263 1.506 -467.879 107
						{ 14.899, 3.110, -469.938, 6 }, -- !pos 14.899 3.110 -469.938 107
						{ -20.686, 4.369, -474.759, 110 }, -- !pos -20.686 4.369 -474.759 107
						{ -47.356, 9.061, -498.086, 87 }, -- !pos -47.356 9.061 -498.086 107
                    },
                },
                {
                    base        = { 107, 24 },
                    name        = string.char(0xA6) .. "Purple Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { -30.196, 8.734, -487.791, 151 }, -- !pos -30.196 8.734 -487.791 107
                        { -41.629, 9.579, -501.133, 117 }, -- !pos -41.629 9.579 -501.133 107
                        { -24.738, 7.668, -524.147, 9 }, -- !pos -24.738 7.668 -524.147 107
                        { -0.487, -0.083, -511.931, 254 }, -- !pos -0.487 -0.083 -511.931 107
                        { 4.693, -0.297, -488.798, 201 }, -- !pos 4.693 -0.297 -488.798 107
						{ -1.263, 1.506, -467.879, 191 }, -- !pos -1.263 1.506 -467.879 107
						{ 14.899, 3.110, -469.938, 6 }, -- !pos 14.899 3.110 -469.938 107
						{ -20.686, 4.369, -474.759, 110 }, -- !pos -20.686 4.369 -474.759 107
						{ -47.356, 9.061, -498.086, 87 }, -- !pos -47.356 9.061 -498.086 107
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
        -- Quadav War Column
        -- Chains from Quadav Patrol.
        -- Veterans answer the scouts'
        -- signal and advance in full armour.
        -----------------------------------
        {
            id          = "SG_QUADAV_03",
            name        = "Quadav War Column",
            level       = 13,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 2, 9.8, -345, 60 },

            entryPos = { 2.040, 9.897, -345.539, 73 }, -- !pos 2.040 9.897 -345.539 107

            mobs =
            {
                {
                    base        = { 107, 24 },
                    name        = string.char(0xA6) .. "Purple Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { 27.298, 1.466, -336.140, 138 }, -- !pos 27.298 1.466 -336.140 107
                        { 25.322, 2.458, -321.883, 177 }, -- !pos 25.322 2.458 -321.883 107
                        { 11.506, 8.930, -317.578, 134 }, -- !pos 11.506 8.930 -317.578 107
						{ -7.067, 9.070, -329.197, 68 }, -- !pos -7.067 9.070 -329.197 107
						{ 24.035, 2.815, -353.634, 147 }, -- !pos 24.035 2.815 -353.634 107
                    },
                },
                {
                    base        = { 107, 25 },  -- TODO: verify mob_groups (veteran Quadav)
                    name        = string.char(0xA6) .. "Sapphire Quadav",
                    count       = 2,
                    spawnPoints =
                    {
                        { 27.298, 1.466, -336.140, 138 }, -- !pos 27.298 1.466 -336.140 107
                        { 25.322, 2.458, -321.883, 177 }, -- !pos 25.322 2.458 -321.883 107
                        { 11.506, 8.930, -317.578, 134 }, -- !pos 11.506 8.930 -317.578 107
						{ -7.067, 9.070, -329.197, 68 }, -- !pos -7.067 9.070 -329.197 107
						{ 24.035, 2.815, -353.634, 147 }, -- !pos 24.035 2.815 -353.634 107
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
        -- The Iron Shell
        -- A massive Quadav Shieldwarrior
        -- — armoured to near-invulnerability
        -- — emerges from Palborough and
        -- holds the pass alone.
        -----------------------------------
        {
            id          = "SG_BOSS_02",
            name        = "The Iron Shell",
            level       = 12,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
			bossStars	= 2,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A steady metallic clanking echoes from the shoreline...",
                "The clanking grows deafening, something massive rounds the ridge...",
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

            area = { 447, 0, -672, 70 },

            entryPos = { 434.730, -1.039, -650.120, 187 }, -- !pos 434.730 -1.039 -650.120 107

            mobs =
            {
                {
                    base         = { 107, 25 },  -- TODO: verify mob_groups
                    name         = string.char(0xA6) .. "Ironshell",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 447.387, -0.376, -672.425, 172 }, -- !pos 447.387 -0.376 -672.425 107
                    },
                },
                {
                    base        = { 107, 24 },
                    name        = string.char(0xA6) .. "Purple Quadav",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 453.145, 0.485, -655.397, 176 }, -- !pos 453.145 0.485 -655.397 107
                        { 447.904, -0.359, -643.546, 93 }, -- !pos 447.904 -0.359 -643.546 107
                        { 457.091, -0.440, -668.257, 67 }, -- !pos 457.091 -0.440 -668.257 107
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
                    gold   = { exp = 400 },
                    silver = { exp = 200 },
                    bronze = { exp = 100 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.QUADAV_HELM },
                    bronze = { { xi.item.QUADAV_HELM,            240 },
                               { xi.item.BONE_CHIP,              150 } },
                    silver = { { xi.item.QUADAV_HELM,            240 },
                               { xi.item.BONE_CHIP,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                    gold   = { { xi.item.QUADAV_HELM,            240 },
                               { xi.item.BONE_CHIP,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 },
                               { xi.item.BRUSHWOOD_HELM,          100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.QUADAV_HELM,             50 } },
                    gold   = { { xi.item.QUADAV_HELM,            100 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- Hold the Line
        -- Defense FATE: three time-gated
        -- waves of goblins assault a Bastok
        -- supply post on the southern road.
        -- A new wave arrives every 90 seconds
        -- regardless of how many are left alive
        -- from the previous. Objective: kill
        -- all 10 goblins before the timer ends.
        -----------------------------------
        {
            id           = "SG_DEFEND_01",
            name         = "Hold the Line",
            level        = 10,
            duration     = 600,
            chainOnly    = false,
            progressVal  = 1,
            waveInterval = 90,  -- seconds between time-gated wave spawns

            objective = { type = "defend", count = 10 },

            area = { -95, 10, -260, 75 },  -- same area as Goblin Assault

            entryPos = { -91.489, 11.053, -260.794, 120 }, -- !pos -91.489 11.053 -260.794 107

            waves =
            {
                -----------------------------------
                -- Wave 1 (T+0): forward scouts
                -----------------------------------
                {
                    announcement = "Hold the Line — Wave 1: Goblin scouts close in on the supply post!",
                    mobs =
                    {
                        {
                            base        = { 107, 13 },
                            name        = string.char(0xA6) .. "Goblin Scout",
                            count       = 3,
                            spawnPoints =
                            {
                                { -88,  10, -268, 143 }, -- !pos -88 10 -268 107
                                { -108, 10, -268, 143 }, -- !pos -108 10 -268 107
                                { -95,  10, -288, 143 }, -- !pos -95 10 -288 107
                            },
                        },
                    },
                },
                -----------------------------------
                -- Wave 2 (T+90s): weavers lay traps
                -----------------------------------
                {
                    announcement = "Hold the Line — Wave 2: Goblin weavers approach, spreading traps!",
                    mobs =
                    {
                        {
                            base        = { 107, 16 },
                            name        = string.char(0xA6) .. "Goblin Saboteur",
                            count       = 3,
                            spawnPoints =
                            {
                                { -88,  10, -268, 143 }, -- !pos -88 10 -268 107
                                { -108, 10, -268, 143 }, -- !pos -108 10 -268 107
                                { -95,  10, -248, 143 }, -- !pos -95 10 -248 107
                            },
                        },
                    },
                },
                -----------------------------------
                -- Wave 3 (T+180s): main assault
                -----------------------------------
                {
                    announcement = "Hold the Line — Final wave: The main goblin assault arrives!",
                    mobs =
                    {
                        {
                            base        = { 107, 13 },
                            name        = string.char(0xA6) .. "Goblin Raider",
                            count       = 3,
                            spawnPoints =
                            {
                                { -88,  10, -268, 143 }, -- !pos -88 10 -268 107
                                { -108, 10, -268, 143 }, -- !pos -108 10 -268 107
                                { -95,  10, -288, 143 }, -- !pos -95 10 -288 107
                            },
                        },
                        {
                            base        = { 107, 31 },
                            name        = string.char(0xA6) .. "Goblin Warchief",
                            count       = 1,
                            isBoss      = true,
                            spawnPoints =
                            {
                                { -95, 10, -260, 120 }, -- !pos -95 10 -260 107
                            },
                        },
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
                    silver = { { xi.item.GOBLIN_ARMOR,         150 },
                               { xi.item.BONE_CHIP,            150 } },
                    gold   = { { xi.item.GOBLIN_MASK,          150 },
                               { xi.item.GOBLIN_ARMOR,         150 },
                               { xi.item.CHUNK_OF_COPPER_ORE,  100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,             50 } },
                    gold   = { { xi.item.BONE_CHIP,            100 } },
                },
            },
        },

        -----------------------------------
        -- Reclaim the Spoils
        -- Collection FATE: goblins dropped
        -- stolen goods while fleeing after
        -- the assault. Recover items scattered
        -- across the area before they double
        -- back to reclaim them.
        -----------------------------------
        {
            id          = "SG_COLLECT_01",
            name        = "Reclaim the Spoils",
            level       = 5,
            duration    = 300,
            chainOnly   = false,
            progressVal = 1,

            objective     = { type = "collect", count = 6 },
            collectName   = "Stolen Goods",

            area = { -95, 10, -260, 100 },

            entryPos = { -91.489, 11.053, -260.794, 120 }, -- !pos -91.489 11.053 -260.794 107

            collectPoints =
            {
                { -88,  10, -268, 143 }, -- !pos -88 10 -268 107   TODO: survey in-game
                { -108, 10, -268, 143 }, -- !pos -108 10 -268 107
                { -95,  10, -248, 143 }, -- !pos -95 10 -248 107
                { -95,  10, -288, 143 }, -- !pos -95 10 -288 107
                { -75,  10, -260, 143 }, -- !pos (approx)
                { -115, 10, -260, 143 }, -- !pos (approx)
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 400 },
                    silver = { exp = 200 },
                    bronze = { exp = 100 },
                },
                fail =
                {
                    gold   = { exp = 100 },
                    silver = { exp = 50  },
                    bronze = { exp = 25  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,           150 } },
                    silver = { { xi.item.BONE_CHIP,           150 },
                               { xi.item.BRONZE_ORE,          100 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,        100 },
                               { xi.item.BONE_CHIP,           150 },
                               { xi.item.BRONZE_ORE,          150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = {},
                    gold   = { { xi.item.BONE_CHIP,            50 } },
                },
            },
        },

        -----------------------------------
        -- The Adamantine Juggernaut
        -- A primordial Stone Eater of
        -- legendary size, last seen during
        -- the Crystal War, resurfaces from
        -- beneath South Gustaberg.
        -- Spawns rarely. Bring a full party.
        -----------------------------------
        {
            id          = "SG_BOSS_03",
            name        = "The Adamantine Juggernaut",
            level       = 20,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
			bossStars	= 3,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The earth of South Gustaberg heaves and cracks along a massive fault line...",
                "A catastrophic eruption splits the hillside; something enormous rises from below...",
				"A hulk of sentient earth has been spotted! It's presence blights the land!",
            },

            area = { 146, -19.7, -521, 100 },

            entryPos = { 146.202, -19.727, -521.774, 146 }, -- !pos 146.202 -19.727 -521.774 107

            mobs =
            {
                {
                    base         = { 111, 29 },  -- Golem family
                    name         = string.char(0xA6) .. "Iron Colossus",
                    count        = 1,
                    isBoss       = true,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 163.569, -20.000, -552.426, 231 }, -- !pos 163.569 -20.000 -552.426 107
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
                    guaranteed = { xi.item.CHUNK_OF_MYTHRIL_ORE },
                    bronze = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   240 },
                               { xi.item.IRON_ORE,               200 } },
                    silver = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   240 },
                               { xi.item.IRON_ORE,               200 },
                               { xi.item.LIZARD_TAIL,            150 } },
                    gold   = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   240 },
                               { xi.item.IRON_ORE,               200 },
                               { xi.item.LIZARD_TAIL,            150 },
                               { xi.item.ASHGRAIN_VEST,          150 },
                               { xi.item.WAILING_RAM_HORN,       100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.IRON_ORE,                50 } },
                    gold   = { { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 },
                               { xi.item.IRON_ORE,                50 } },
                },
            },
        },
    },
}
