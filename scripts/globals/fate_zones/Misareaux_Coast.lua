-----------------------------------
-- FATE Zone: Misareaux Coast
-- Zone ID: 25
-- Region pool: LUFAISE_MISAREAUX
-- Level range: 45-58
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.MISAREAUX_COAST] =
{
    zoneName    = "Misareaux_Coast",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "LUFAISE_MISAREAUX",

    events =
    {
        -----------------------------------
        -- Gigas Coastal Landing
        -- Gigas Bhikkhus and Reavers beach
        -- their longships on the coast,
        -- raiding inland settlements and
        -- scattering native wildlife.
        -----------------------------------
        {
            id          = "MC_GIGAS_01",
            name        = "Gigas Coastal Landing",
            level       = 48,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "MC_GIGAS_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 80,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 25

            mobs =
            {
                {
                    base        = { 25, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Bhikkhu",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                    },
                },
                {
                    base        = { 25, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Reaver",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
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
                    bronze = { { xi.item.GIANT_EGG,               150 } },
                    silver = { { xi.item.GIANT_EGG,               200 },
                               { xi.item.BEAST_HIDE,              100 } },
                    gold   = { { xi.item.GIANT_EGG,               200 },
                               { xi.item.BEAST_HIDE,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.GIANT_EGG,                50 } },
                    gold   = { { xi.item.GIANT_EGG,               100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- Gigas Warband
        -- Chains from Gigas Coastal Landing.
        -- Gigas Shamans and a Jarl lead the
        -- inland push in organised warband
        -- formation.
        -----------------------------------
        {
            id          = "MC_GIGAS_02",
            name        = "Gigas Warband",
            level       = 52,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 25

            mobs =
            {
                {
                    base        = { 25, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Shaman",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                    },
                },
                {
                    base        = { 25, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Jarl",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3500 },
                    silver = { exp = 1750 },
                    bronze = { exp = 875  },
                },
                fail =
                {
                    gold   = { exp = 875 },
                    silver = { exp = 435 },
                    bronze = { exp = 215 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.GIANT_EGG,               100 } },
                    silver = { { xi.item.GIANT_EGG,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.GIANT_EGG,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.BEAST_HIDE,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,               50 } },
                    gold   = { { xi.item.GIANT_EGG,                50 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Coastal Ravager
        -- A colossal sea-worn Adamantoise
        -- hauls itself ashore from the
        -- deep water, crushing cliffs and
        -- everything else in its path.
        -----------------------------------
        {
            id          = "MC_BOSS_01",
            name        = "The Coastal Ravager",
            level       = 56,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The seas off Misareaux Coast surge and recede in an unnatural rhythm...",
                "An enormous domed shape breaks the surface and crawls toward the shore...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 25

            mobs =
            {
                {
                    base         = { 25, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Shore Ravager",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                    },
                },
                {
                    base        = { 25, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Coast Bugard",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 25
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 7000 },
                    silver = { exp = 3500 },
                    bronze = { exp = 1750 },
                },
                fail =
                {
                    gold   = { exp = 1750 },
                    silver = { exp = 875  },
                    bronze = { exp = 435  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.ADAMANTOISE_EGG },
                    bronze = { { xi.item.ADAMANTOISE_EGG,         240 },
                               { xi.item.BEAST_HIDE,              150 } },
                    silver = { { xi.item.ADAMANTOISE_EGG,         240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.GIANT_EGG,               100 } },
                    gold   = { { xi.item.ADAMANTOISE_EGG,         240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.GIANT_EGG,               150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.ADAMANTOISE_EGG,          50 } },
                    gold   = { { xi.item.ADAMANTOISE_EGG,         100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },
    },
}
