-----------------------------------
-- FATE Zone: Lufaise Meadows
-- Zone ID: 24
-- Region pool: LUFAISE_MISAREAUX
-- Level range: 40-55
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.LUFAISE_MEADOWS] =
{
    zoneName    = "Lufaise_Meadows",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "LUFAISE_MISAREAUX",

    events =
    {
        -----------------------------------
        -- Opo-opo Troop Assault
        -- A large troop of Opo-opo descends
        -- from the highland trees, looting
        -- campsites and harassing travellers
        -- across the meadows.
        -----------------------------------
        {
            id          = "LM_OPOPO_01",
            name        = "Opo-opo Troop Assault",
            level       = 45,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 24

            mobs =
            {
                {
                    base        = { 24, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Meadow Opo-opo",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                    },
                },
                {
                    base        = { 24, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Meadows Ram",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2800 },
                    silver = { exp = 1400 },
                    bronze = { exp = 700  },
                },
                fail =
                {
                    gold   = { exp = 700 },
                    silver = { exp = 350 },
                    bronze = { exp = 175 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BEAST_HIDE,              150 } },
                    silver = { { xi.item.BEAST_HIDE,              200 },
                               { xi.item.GRASS_THREAD,            100 } },
                    gold   = { { xi.item.BEAST_HIDE,              200 },
                               { xi.item.GRASS_THREAD,            150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,               50 } },
                    gold   = { { xi.item.BEAST_HIDE,              100 },
                               { xi.item.GRASS_THREAD,             50 } },
                },
            },
        },

        -----------------------------------
        -- The Meadow Titan
        -- An enormous battle-scarred Ram —
        -- ancient patriarch of the Lufaise
        -- herds — descends from the crags,
        -- laying waste to all in its path.
        -----------------------------------
        {
            id          = "LM_BOSS_01",
            name        = "The Meadow Titan",
            level       = 52,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The ground of Lufaise Meadows trembles under thunderous hoofbeats...",
                "A massive horned shape crests the hill — the Meadow Titan descends...",
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
                radius = 88,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 24

            mobs =
            {
                {
                    base         = { 24, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Meadow Titan",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                    },
                },
                {
                    base        = { 24, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Lufaise Ram",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 24
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 6000 },
                    silver = { exp = 3000 },
                    bronze = { exp = 1500 },
                },
                fail =
                {
                    gold   = { exp = 1500 },
                    silver = { exp = 750  },
                    bronze = { exp = 375  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.BEAST_HIDE },
                    bronze = { { xi.item.BEAST_HIDE,              240 },
                               { xi.item.GRASS_THREAD,            150 } },
                    silver = { { xi.item.BEAST_HIDE,              240 },
                               { xi.item.GRASS_THREAD,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.BEAST_HIDE,              240 },
                               { xi.item.GRASS_THREAD,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BONE_CHIP,               100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,               50 } },
                    gold   = { { xi.item.BEAST_HIDE,              100 },
                               { xi.item.GRASS_THREAD,             50 } },
                },
            },
        },
    },
}
