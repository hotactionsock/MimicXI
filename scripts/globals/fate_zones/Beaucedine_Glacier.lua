-----------------------------------
-- FATE Zone: Beaucedine Glacier
-- Zone ID: 111
-- Region pool: NORTHLANDS
-- Level range: 45-60
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BEAUCEDINE_GLACIER] =
{
    zoneName    = "Beaucedine_Glacier",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORTHLANDS",

    events =
    {
        -----------------------------------
        -- Gigas Hunting Pack
        -- Gigas Bhikkhu and Flagmen cross
        -- the glacier ice in hunting parties,
        -- pursuing prey toward the
        -- Ranguemont Pass.
        -----------------------------------
        {
            id          = "BG_GIGAS_01",
            name        = "Gigas Hunting Pack",
            level       = 52,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "BG_GIGAS_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area = { 0, 0, 0, 80 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 111

            mobs =
            {
                {
                    base        = { 111, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Bhikkhu",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                    },
                },
                {
                    base        = { 111, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Flagman",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
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
                    guaranteed = {},
                    bronze = { { xi.item.GIANT_EGG,              150 } },
                    silver = { { xi.item.GIANT_EGG,              200 },
                               { xi.item.BONE_CHIP,              150 } },
                    gold   = { { xi.item.GIANT_EGG,              200 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.GIANT_EGG,               50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- Glacial Vanguard
        -- Chains from Gigas Hunting Pack.
        -- Gigas Shamans and a Jarl answer
        -- the pack's war signal, crossing
        -- the glacier in battle-formation.
        -----------------------------------
        {
            id          = "BG_GIGAS_02",
            name        = "Glacial Vanguard",
            level       = 56,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 111

            mobs =
            {
                {
                    base        = { 111, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Shaman",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                    },
                },
                {
                    base        = { 111, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Jarl",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3300 },
                    silver = { exp = 1650 },
                    bronze = { exp = 825  },
                },
                fail =
                {
                    gold   = { exp = 825 },
                    silver = { exp = 410 },
                    bronze = { exp = 205 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.GIANT_EGG,              100 } },
                    silver = { { xi.item.GIANT_EGG,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                    gold   = { { xi.item.GIANT_EGG,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 },
                               { xi.item.BONE_CHIP,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.GIANT_EGG,               50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Glacier Titan
        -- A colossal ice-encrusted Gigas
        -- King - long thought frozen in the
        -- deepest ice - stirs and advances
        -- across the glacier under storm.
        -----------------------------------
        {
            id          = "BG_BOSS_01",
            name        = "The Glacier Titan",
            level       = 58,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "An ice storm gathers without warning over the Beaucedine Glacier...",
                "The blizzard parts and a titanic silhouette strides through the white...",
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

            area = { 0, 0, 0, 88 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 111

            mobs =
            {
                {
                    base         = { 111, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Glacier Titan",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                    },
                },
                {
                    base        = { 111, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Glacial Wolf",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 111
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 6500 },
                    silver = { exp = 3250 },
                    bronze = { exp = 1625 },
                },
                fail =
                {
                    gold   = { exp = 1625 },
                    silver = { exp = 810  },
                    bronze = { exp = 405  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.ICE_CRYSTAL },
                    bronze = { { xi.item.ICE_CRYSTAL,            240 },
                               { xi.item.GIANT_EGG,              150 } },
                    silver = { { xi.item.ICE_CRYSTAL,            240 },
                               { xi.item.GIANT_EGG,              200 },
                               { xi.item.WOLF_HIDE,              150 } },
                    gold   = { { xi.item.ICE_CRYSTAL,            240 },
                               { xi.item.GIANT_EGG,              200 },
                               { xi.item.WOLF_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.ICE_CRYSTAL,             50 } },
                    gold   = { { xi.item.ICE_CRYSTAL,            100 },
                               { xi.item.GIANT_EGG,               50 } },
                },
            },
        },
    },
}
