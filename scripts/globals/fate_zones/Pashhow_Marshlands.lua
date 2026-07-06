-----------------------------------
-- FATE Zone: Pashhow Marshlands
-- Zone ID: 109
-- Region pool: DERFLAND_ARAGONEU
-- Level range: 20-35
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.PASHHOW_MARSHLANDS] =
{
    zoneName    = "Pashhow_Marshlands",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "DERFLAND_ARAGONEU",

    events =
    {
        -----------------------------------
        -- Quadav Survey Party
        -- Quadav miners and scouts wade
        -- out of the swamp, surveying the
        -- marshland for ore deposits and
        -- testing Bastokan defences.
        -----------------------------------
        {
            id          = "PM_QUADAV_01",
            name        = "Quadav Survey Party",
            level       = 25,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "PM_QUADAV_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 109

            mobs =
            {
                {
                    base        = { 109, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Quadav Miner",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
                {
                    base        = { 109, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Purple Quadav",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
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
                    gold   = { exp = 375 },
                    silver = { exp = 185 },
                    bronze = { exp = 90  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BONE_CHIP,              150 } },
                    silver = { { xi.item.QUADAV_HELM,            100 },
                               { xi.item.BONE_CHIP,              150 } },
                    gold   = { { xi.item.QUADAV_HELM,            150 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.BONE_CHIP,              100 },
                               { xi.item.QUADAV_HELM,             50 } },
                },
            },
        },

        -----------------------------------
        -- Quadav Assault Force
        -- Chains from Quadav Survey Party.
        -- Emboldened by the scouts, Ruby
        -- Quadav push hard into the marsh,
        -- driving deep into Pashhow.
        -----------------------------------
        {
            id          = "PM_QUADAV_02",
            name        = "Quadav Assault Force",
            level       = 28,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 0, 0, 0, 65 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 109

            mobs =
            {
                {
                    base        = { 109, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Ruby Quadav",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
                {
                    base        = { 109, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Shield Quadav",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1700 },
                    silver = { exp = 850  },
                    bronze = { exp = 425  },
                },
                fail =
                {
                    gold   = { exp = 425 },
                    silver = { exp = 210 },
                    bronze = { exp = 105 },
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
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 },
                               { xi.item.BONE_CHIP,              100 } },
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
        -- The Bog Sovereign
        -- A colossal Clot rises from the
        -- deepest, most fetid bog in Pashhow,
        -- engulfing everything nearby in
        -- a tide of corrosive slime.
        -----------------------------------
        {
            id          = "PM_BOSS_01",
            name        = "The Bog Sovereign",
            level       = 32,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The marsh waters churn and bubble ominously across Pashhow...",
                "A foul stench rises from the deepest bog - something vast stirs beneath...",
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

            area = { 0, 0, 0, 81 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 109

            mobs =
            {
                {
                    base         = { 109, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Bog Sovereign",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
                {
                    base        = { 109, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Marsh Clot",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3000 },
                    silver = { exp = 1500 },
                    bronze = { exp = 750  },
                },
                fail =
                {
                    gold   = { exp = 750 },
                    silver = { exp = 375 },
                    bronze = { exp = 185 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.SLIME_OIL },
                    bronze = { { xi.item.SLIME_OIL,              240 },
                               { xi.item.BONE_CHIP,              150 } },
                    silver = { { xi.item.SLIME_OIL,              240 },
                               { xi.item.QUADAV_HELM,            150 },
                               { xi.item.BONE_CHIP,              150 } },
                    gold   = { { xi.item.SLIME_OIL,              240 },
                               { xi.item.QUADAV_HELM,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 },
                               { xi.item.BONE_CHIP,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.SLIME_OIL,               50 } },
                    gold   = { { xi.item.SLIME_OIL,              100 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- Leech Rising
        -- The waterlogged ground across
        -- Pashhow heaves as hundreds of
        -- marsh leeches breach the surface,
        -- drawn up by vibration and blood.
        -----------------------------------
        {
            id          = "PM_LEECH_01",
            name        = "Leech Rising",
            level       = 22,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 12 },

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 109

            mobs =
            {
                {
                    base        = { 109, 7 },  -- TODO: verify mob_groups (Marsh Leech)
                    name        = string.char(0xA6) .. "Marsh Leech",
                    count       = 12,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
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
                    bronze = { { xi.item.LEECH_SALIVA,            150 } },
                    silver = { { xi.item.LEECH_SALIVA,            200 },
                               { xi.item.BONE_CHIP,               100 } },
                    gold   = { { xi.item.LEECH_SALIVA,            200 },
                               { xi.item.BONE_CHIP,               150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LEECH_SALIVA,             50 } },
                    gold   = { { xi.item.LEECH_SALIVA,            100 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- Funguar Bloom
        -- An unusual seasonal bloom sends
        -- Pashhow Funguars into a frenzy.
        -- They swarm the open marshland,
        -- spreading toxic spores as they go.
        -----------------------------------
        {
            id          = "PM_FUNGUAR_01",
            name        = "Funguar Bloom",
            level       = 25,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "PM_FUNGUAR_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 109

            mobs =
            {
                {
                    base        = { 109, 8 },  -- TODO: verify mob_groups (Pashhow Funguar)
                    name        = string.char(0xA6) .. "Marsh Funguar",
                    count       = 7,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
                {
                    base        = { 109, 9 },  -- TODO: verify mob_groups (Spore Funguar)
                    name        = string.char(0xA6) .. "Spore Funguar",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1400 },
                    silver = { exp = 700  },
                    bronze = { exp = 350  },
                },
                fail =
                {
                    gold   = { exp = 350 },
                    silver = { exp = 175 },
                    bronze = { exp = 85  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.YELLOW_GLOBE,            150 } },
                    silver = { { xi.item.YELLOW_GLOBE,            200 },
                               { xi.item.BONE_CHIP,               100 } },
                    gold   = { { xi.item.YELLOW_GLOBE,            200 },
                               { xi.item.BONE_CHIP,               150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YELLOW_GLOBE,             50 } },
                    gold   = { { xi.item.YELLOW_GLOBE,            100 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- Spore Tide
        -- Chains from Funguar Bloom.
        -- Massive Elder Funguars lumber out
        -- of the deep marsh, releasing
        -- clouds of paralytic spores and
        -- driving smaller fungi before them.
        -----------------------------------
        {
            id          = "PM_FUNGUAR_02",
            name        = "Spore Tide",
            level       = 28,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 0, 0, 0, 65 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 109

            mobs =
            {
                {
                    base        = { 109, 10 },  -- TODO: verify mob_groups (Elder Funguar)
                    name        = string.char(0xA6) .. "Elder Funguar",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
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
                    gold   = { exp = 400 },
                    silver = { exp = 200 },
                    bronze = { exp = 100 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.YELLOW_GLOBE,            100 } },
                    silver = { { xi.item.YELLOW_GLOBE,            200 },
                               { xi.item.SLIME_OIL,               100 } },
                    gold   = { { xi.item.YELLOW_GLOBE,            200 },
                               { xi.item.SLIME_OIL,               150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.YELLOW_GLOBE,             50 } },
                    gold   = { { xi.item.YELLOW_GLOBE,            100 },
                               { xi.item.SLIME_OIL,                50 } },
                },
            },
        },

        -----------------------------------
        -- The Stenchmaster
        -- A grotesquely overgrown Malboro
        -- lurches from a hidden sinkhole
        -- in the Pashhow interior, drawing
        -- a retinue of smaller Malboros in
        -- its fetid wake.
        -----------------------------------
        {
            id          = "PM_BOSS_02",
            name        = "The Stenchmaster",
            level       = 30,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "An unbearable stench drifts across the marshland of Pashhow...",
                "The bog ripples - something vast and foul pulls itself toward the surface...",
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

            area = { 0, 0, 0, 81 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 109

            mobs =
            {
                {
                    base         = { 109, 11 },  -- TODO: verify mob_groups (Stenchmaster)
                    name         = string.char(0xA6) .. "Stenchmaster",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
                {
                    base        = { 109, 12 },  -- TODO: verify mob_groups (Pashhow Malboro)
                    name        = string.char(0xA6) .. "Marsh Malboro",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3000 },
                    silver = { exp = 1500 },
                    bronze = { exp = 750  },
                },
                fail =
                {
                    gold   = { exp = 750 },
                    silver = { exp = 375 },
                    bronze = { exp = 185 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.MALBORO_VINE },
                    bronze = { { xi.item.MALBORO_VINE,            240 },
                               { xi.item.SLIME_OIL,               150 } },
                    silver = { { xi.item.MALBORO_VINE,            240 },
                               { xi.item.SLIME_OIL,               200 },
                               { xi.item.YELLOW_GLOBE,            150 } },
                    gold   = { { xi.item.MALBORO_VINE,            240 },
                               { xi.item.SLIME_OIL,               200 },
                               { xi.item.YELLOW_GLOBE,            150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.MALBORO_VINE,             50 } },
                    gold   = { { xi.item.MALBORO_VINE,            100 },
                               { xi.item.SLIME_OIL,                50 } },
                },
            },
        },

        -----------------------------------
        -- The Fetid Empress
        -- A Malboro of vast antiquity, its
        -- vines thick as siege rope and its
        -- breath capable of wilting stone.
        -- It rises from the deepest sump
        -- in Pashhow once in a long while.
        -----------------------------------
        {
            id          = "PM_BOSS_03",
            name        = "The Fetid Empress",
            level       = 40,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The marsh water turns brackish and dark across the whole of Pashhow...",
                "Ancient vines rip through the bogwater - the Fetid Empress stirs from her sump...",
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

            area = { 0, 0, 0, 105 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 109

            mobs =
            {
                {
                    base         = { 109, 13 },  -- TODO: verify mob_groups (Fetid Empress)
                    name         = string.char(0xA6) .. "Fetid Empress",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 109
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
                    guaranteed = { xi.item.MALBORO_VINE },
                    bronze = { { xi.item.MALBORO_VINE,            240 },
                               { xi.item.SLIME_OIL,               150 } },
                    silver = { { xi.item.MALBORO_VINE,            240 },
                               { xi.item.SLIME_OIL,               200 },
                               { xi.item.QUADAV_HELM,             150 } },
                    gold   = { { xi.item.MALBORO_VINE,            240 },
                               { xi.item.SLIME_OIL,               200 },
                               { xi.item.QUADAV_HELM,             150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.MALBORO_VINE,             50 } },
                    gold   = { { xi.item.MALBORO_VINE,            100 },
                               { xi.item.SLIME_OIL,                50 } },
                },
            },
        },
    },
}
