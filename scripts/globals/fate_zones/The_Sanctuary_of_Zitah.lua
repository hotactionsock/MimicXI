-----------------------------------
-- FATE Zone: The Sanctuary of Zi'Tah
-- Zone ID: 121
-- Region pool: LITEILOR
-- Level range: 55-70
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.THE_SANCTUARY_OF_ZITAH] =
{
    zoneName    = "The_Sanctuary_of_ZiTah",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "LITEILOR",

    events =
    {
        -----------------------------------
        -- Mandragora Uprising
        -- Mandragora and Saplings emerge in
        -- huge numbers throughout the
        -- Sanctuary, swarming the paths and
        -- overwhelming any who enter.
        -----------------------------------
        {
            id          = "SZ_MANDRAGORA_01",
            name        = "Mandragora Uprising",
            level       = 58,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 121

            mobs =
            {
                {
                    base        = { 121, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Grove Mandra",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                    },
                },
                {
                    base        = { 121, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Zi'Tah Sapling",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
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
                    guaranteed = {},
                    bronze = { { xi.item.GYSAHL_GREENS,           150 } },
                    silver = { { xi.item.GYSAHL_GREENS,           200 },
                               { xi.item.BEAST_HIDE,              150 } },
                    gold   = { { xi.item.GYSAHL_GREENS,           200 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,               50 } },
                    gold   = { { xi.item.GYSAHL_GREENS,            50 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Grove Devourer
        -- An ancient, corrupted Treant —
        -- the former spirit-guardian of the
        -- Sanctuary — awakens in fury and
        -- begins consuming the grove itself.
        -----------------------------------
        {
            id          = "SZ_BOSS_01",
            name        = "The Grove Devourer",
            level       = 66,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The ancient trees of the Sanctuary creak and groan in unison...",
                "The forest floor heaves and a massive form rises from the earth...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 121

            mobs =
            {
                {
                    base         = { 121, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Grove Devourer",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                    },
                },
                {
                    base        = { 121, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Grove Sapling",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 121
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 8000 },
                    silver = { exp = 4000 },
                    bronze = { exp = 2000 },
                },
                fail =
                {
                    gold   = { exp = 2000 },
                    silver = { exp = 1000 },
                    bronze = { exp = 500  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.TREANT_BULB },
                    bronze = { { xi.item.TREANT_BULB,             240 },
                               { xi.item.BEAST_HIDE,              150 } },
                    silver = { { xi.item.TREANT_BULB,             240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.GYSAHL_GREENS,           100 } },
                    gold   = { { xi.item.TREANT_BULB,             240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.GYSAHL_GREENS,           150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TREANT_BULB,              50 } },
                    gold   = { { xi.item.TREANT_BULB,             100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },
    },
}
