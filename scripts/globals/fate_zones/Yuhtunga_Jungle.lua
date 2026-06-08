-----------------------------------
-- FATE Zone: Yuhtunga Jungle
-- Zone ID: 123
-- Region pool: KOLSHUSHU_ELSHIMO
-- Level range: 45-60
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.YUHTUNGA_JUNGLE] =
{
    zoneName    = "Yuhtunga_Jungle",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "KOLSHUSHU_ELSHIMO",

    events =
    {
        -----------------------------------
        -- Tonberry Procession
        -- Tonberry Initiates and Stalkers
        -- emerge from hidden lairs, moving
        -- in silent procession through the
        -- jungle toward inhabited outposts.
        -----------------------------------
        {
            id          = "YJ_TONBERRY_01",
            name        = "Tonberry Procession",
            level       = 50,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 123

            mobs =
            {
                {
                    base        = { 123, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Berry Initiate",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                    },
                },
                {
                    base        = { 123, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Berry Stalker",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
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
                    bronze = { { xi.item.TONBERRY_LANTERN,        150 } },
                    silver = { { xi.item.TONBERRY_LANTERN,        200 },
                               { xi.item.BEAST_HIDE,              150 } },
                    gold   = { { xi.item.TONBERRY_LANTERN,        200 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,               50 } },
                    gold   = { { xi.item.TONBERRY_LANTERN,         50 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Jungle Sovereign
        -- A massive Goobbue with vines and
        -- jungle flora growing from its body
        -- lumbers through Yuhtunga, destroying
        -- everything in its path.
        -----------------------------------
        {
            id          = "YJ_BOSS_01",
            name        = "The Jungle Sovereign",
            level       = 58,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The jungle canopy shakes with tremendous force deep in Yuhtunga...",
                "Trees splinter apart as a massive creature forces its way toward you...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 123

            mobs =
            {
                {
                    base         = { 123, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Jungle Tyrant",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                    },
                },
                {
                    base        = { 123, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Jungle Sapling",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 123
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
                    guaranteed = { xi.item.GOOBBUE_HAIR },
                    bronze = { { xi.item.GOOBBUE_HAIR,            240 },
                               { xi.item.BEAST_HIDE,              150 } },
                    silver = { { xi.item.GOOBBUE_HAIR,            240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.TONBERRY_LANTERN,        100 } },
                    gold   = { { xi.item.GOOBBUE_HAIR,            240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.TONBERRY_LANTERN,        150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.GOOBBUE_HAIR,             50 } },
                    gold   = { { xi.item.GOOBBUE_HAIR,            100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },
    },
}
