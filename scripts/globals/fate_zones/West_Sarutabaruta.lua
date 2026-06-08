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
        -- Mandragora March
        -- A cluster of Mandragora and
        -- Tiny Mandragora uproot themselves
        -- near the Horutoto Ruins and begin
        -- a rampaging advance on the road.
        -----------------------------------
        {
            id          = "WS_MANDRAGORA_01",
            name        = "Mandragora March",
            level       = 8,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = -110,
                y      = 5,
                z      = 210,
                radius = 65,
            },

            entryPos = { 131.860, -33.877, 294.434, 252 }, -- !pos 131.860 -33.877 294.434 115

            mobs =
            {
                {
                    base        = { 115, 15 },
                    name        = string.char(0xA6) .. "Mandragora",
                    count       = 6,
                    spawnPoints =
                    {
                        { 139.357, -36.318, 304.799, 21 }, -- !pos 139.357 -36.318 304.799 115
                        { 150.915, -34.594, 294.519, 46 }, -- !pos 150.915 -34.594 294.519 115
                        { 132.516, -32.511, 275.480, 95 }, -- !pos 132.516 -32.511 275.480 115
						{ 113.027, -32.643, 289.925, 142 }, -- !pos 113.027 -32.643 289.925 115
						{ 112.707, -35.484, 315.064, 185 }, -- !pos 112.707 -35.484 315.064 115
						{ 155.562, -39.952, 319.073, 248 }, -- !pos 155.562 -39.952 319.073 115
                    },
                },
                {
                    base        = { 115, 6 },
                    name        = string.char(0xA6) .. "Wee Mandragora",
                    count       = 4,
                    spawnPoints =
                    {
                        { 164.643, -39.624, 313.516, 71 }, -- !pos 164.643 -39.624 313.516 115
                        { 170.393, -31.485, 286.219, 52 }, -- !pos 170.393 -31.485 286.219 115
						{ 185.732, -29.799, 284.147, 255 }, -- !pos 185.732 -29.799 284.147 115
						{ 136.700, -32.685, 273.425, 122 }, -- !pos 136.700 -32.685 273.425 115
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
                    bronze = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 } },
                    silver = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 },
                               { xi.item.TWO_LEAF_MANDRAGORA_BUD,  150 } },
                    gold   = { { xi.item.THREE_LEAF_MANDRAGORA_BUD, 240 },
                               { xi.item.FOUR_LEAF_MANDRAGORA_BUD, 100 },
                               { xi.item.TWO_LEAF_MANDRAGORA_BUD,  150 } },
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
        -- Yagudo Advance
        -- Yagudo Initiates push east from
        -- the hills near Giddeus, scouting
        -- the route toward Windurst.
        -----------------------------------
        {
            id          = "WS_YAGUDO_01",
            name        = "Yagudo Advance",
            level       = 10,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "WS_YAGUDO_02",
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = -106,
                y      = -16,
                z      = 329,
                radius = 65,
            },

            entryPos = { -106.247, -16.892, 329.420, 248 }, -- !pos -106.247 -16.892 329.420 115

            mobs =
            {
                {
                    base        = { 115, 16 },
                    name        = string.char(0xA6) .. "Yagudo Novice",
                    count       = 5,
                    spawnPoints =
                    {
                        { -96.386, -16.641, 353.176, 250 }, -- !pos -96.386 -16.641 353.176 115
                        { -89.713, -16.816, 313.386, 42 }, -- !pos -89.713 -16.816 313.386 115
                        { -122.177, -17.566, 307.525, 111 }, -- !pos -122.177 -17.566 307.525 115
						{ -123.181, -16.841, 334.673, 186 }, -- !pos -123.181 -16.841 334.673 115
						{ -115.660, -16.048, 357.215, 172 }, -- !pos -115.660 -16.048 357.215 115
						{ -79.881, -16.773, 339.658, 34 }, -- !pos -79.881 -16.773 339.658 115
						{ -91.761, -16.487, 356.366, 62 }, -- !pos -91.761 -16.487 356.366 115
						{ -120.433, -17.603, 307.233, 229 }, -- !pos -120.433 -17.603 307.233 115
                    },
                },
                {
                    base        = { 115, 17 },
                    name        = string.char(0xA6) .. "Yagudo Acolyte",
                    count       = 3,
                    spawnPoints =
                    {
                        { -96.386, -16.641, 353.176, 250 }, -- !pos -96.386 -16.641 353.176 115
                        { -89.713, -16.816, 313.386, 42 }, -- !pos -89.713 -16.816 313.386 115
                        { -122.177, -17.566, 307.525, 111 }, -- !pos -122.177 -17.566 307.525 115
						{ -123.181, -16.841, 334.673, 186 }, -- !pos -123.181 -16.841 334.673 115
						{ -115.660, -16.048, 357.215, 172 }, -- !pos -115.660 -16.048 357.215 115
						{ -79.881, -16.773, 339.658, 34 }, -- !pos -79.881 -16.773 339.658 115
						{ -91.761, -16.487, 356.366, 62 }, -- !pos -91.761 -16.487 356.366 115
						{ -120.433, -17.603, 307.233, 229 }, -- !pos -120.433 -17.603 307.233 115
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
                    bronze = { { xi.item.YAGUDO_FEATHER,          150 } },
                    silver = { { xi.item.YAGUDO_FEATHER,          200 },
                               { xi.item.BIRD_FEATHER,            150 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          200 },
                               { xi.item.BIRD_FEATHER,            150 },
                               { xi.item.BEEHIVE_CHIP,            100 } },
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
        -- Yagudo Crusade
        -- Chains from Yagudo Advance.
        -- Yagudo Scribes join the flock,
        -- pressing the assault deeper
        -- into the grasslands.
        -----------------------------------
        {
            id          = "WS_YAGUDO_02",
            name        = "Yagudo Crusade",
            level       = 12,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,
			chainOnWin  = "WS_BOSS_02",

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = -170,
                y      = -4.7,
                z      = -204,
                radius = 65,
            },

            entryPos = { -170.174, -4.741, -204.607, 7 }, -- !pos -170.174 -4.741 -204.607 115

            mobs =
            {
                {
                    base        = { 115, 18 },
                    name        = string.char(0xA6) .. "Yagudo Scribe",
                    count       = 3,
                    spawnPoints =
                    {
                        { -158.472, -5.124, -182.045, 239 }, -- !pos -158.472 -5.124 -182.045 115
                        { -159.243, -5.003, -224.027, 14 }, -- !pos -159.243 -5.003 -224.027 115
						{ -197.009, -2.035, -219.774, 172 }, -- !pos -197.009 -2.035 -219.774 115
						{ -195.695, -4.330, -193.574, 196 }, -- !pos -195.695 -4.330 -193.574 115
						{ -180.842, -5.014, -186.850, 9 }, -- !pos -180.842 -5.014 -186.850 115
                    },
                },
                {
                    base        = { 115, 17 },
                    name        = string.char(0xA6) .. "Yagudo Acolyte",
                    count       = 2,
                    spawnPoints =
                    {
                        { -158.472, -5.124, -182.045, 239 }, -- !pos -158.472 -5.124 -182.045 115
                        { -159.243, -5.003, -224.027, 14 }, -- !pos -159.243 -5.003 -224.027 115
						{ -197.009, -2.035, -219.774, 172 }, -- !pos -197.009 -2.035 -219.774 115
						{ -195.695, -4.330, -193.574, 196 }, -- !pos -195.695 -4.330 -193.574 115
						{ -180.842, -5.014, -186.850, 9 }, -- !pos -180.842 -5.014 -186.850 115
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
                    bronze = { { xi.item.YAGUDO_FEATHER,          100 } },
                    silver = { { xi.item.YAGUDO_FEATHER,          200 },
                               { xi.item.BIRD_FEATHER,            100 } },
                    gold   = { { xi.item.YAGUDO_FEATHER,          200 },
                               { xi.item.BIRD_FEATHER,            150 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    100 } },
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
        -- Yagudo Asencdency
        -- Chains from Yagudo Crusade.
        -- Yagudo Scribes join the flock,
        -- pressing the assault deeper
        -- into the grasslands.
        -----------------------------------
        {
            id          = "WS_BOSS_02",
            name        = "Yagudo Ascendency",
            level       = 17,
            duration    = 480,
			minCooldown = 900,
            chainOnly   = true,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

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
                x      = -234,
                y      = -31,
                z      = 553,
                radius = 70,
            },

            entryPos = { -239.182, -28.000, 518.713, 71 }, -- !pos -239.182 -28.000 518.713 115


            mobs =
            {
                {
                    base        = { 115, 18 },
                    name        = string.char(0xA6) .. "Yagudo Deacon",
                    count       = 1,
					isBoss 		= true,
                    spawnPoints =
                    {
                        { -234.003, -31.614, 553.219, 67 }, -- !pos -234.003 -31.614 553.219 115

                    },
                },
                {
                    base        = { 115, 17 },
                    name        = string.char(0xA6) .. "Yagudo Acolyte",
                    count       = 2,
                    spawnPoints =
                    {
                        { -240.521, -30.542, 544.279, 59 }, -- !pos -240.521 -30.542 544.279 115
                        { -230.205, -30.139, 542.538, 61 }, -- !pos -230.205 -30.139 542.538 115
						{ -234.725, -30.380, 543.603, 63 }, -- !pos -234.725 -30.380 543.603 115
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1800 },
                    silver = { exp = 900 },
                    bronze = { exp = 450 },
                },
                fail =
                {
                    gold   = { exp = 500 },
                    silver = { exp = 250 },
                    bronze = { exp = 125  },
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
                               { xi.item.BIRD_FEATHER,            150 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,    100 } },
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
        -- The Beehive Siegemaster
        -- A Giant Bee of abnormal size,
        -- maddened by the fighting near its
        -- hive, descends on the grasslands
        -- flanked by its drone swarm.
        -----------------------------------
        {
            id          = "WS_BOSS_01",
            name        = "The Beehive Siegemaster",
            level       = 15,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A deafening buzz reverberates across the sarutabaruta grasslands...",
                "The droning grows closer — something enormous circles overhead...",
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
                x      = -177,
                y      = -18,
                z      = -112,
                radius = 70,
            },

            entryPos = { -168.784, -17.556, -99.939, 225 }, -- !pos -168.784 -17.556 -99.939 115

            mobs =
            {
                {
                    base         = { 115, 23 },
                    name         = string.char(0xA6) .. "Beehive Master",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
					size		 = 3,
                    spawnPoints  =
                    {
                        { -189.566, -19.201, -117.786, 247 }, -- !pos -189.566 -19.201 -117.786 115
                    },
                },
                {
                    base        = { 115, 7 },
                    name        = string.char(0xA6) .. "Drone Bee",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { -172.449, -17.564, -120.267, 215 }, -- !pos -172.449 -17.564 -120.267 115
                        { -176.330, -18.337, -106.625, 227 }, -- !pos -176.330 -18.337 -106.625 115
                        { -179.999, -18.072, -115.484, 243 }, -- !pos -179.999 -18.072 -115.484 115
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
                    guaranteed = { xi.item.BEEHIVE_CHIP },
                    bronze = { { xi.item.BEEHIVE_CHIP,          240 },
                               { xi.item.INSECT_WING,           150 } },
                    silver = { { xi.item.BEEHIVE_CHIP,          240 },
                               { xi.item.GIANT_STINGER,         200 },
                               { xi.item.INSECT_WING,           150 } },
                    gold   = { { xi.item.GIANT_STINGER,         200 },
                               { xi.item.BEEHIVE_CHIP,          240 },
                               { xi.item.INSECT_WING,           200 },
							   { xi.item.MUDSTRIDER_BOOTS,           100 },
                               { xi.item.YAGUDO_BEAD_NECKLACE,  100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEEHIVE_CHIP,           50 } },
                    gold   = { { xi.item.BEEHIVE_CHIP,          100 },
                               { xi.item.INSECT_WING,            50 } },
                },
            },
        },
    },
}
