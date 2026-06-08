-----------------------------------
-- FATE Zone: Cape Teriggan
-- Zone ID: 113
-- Region pool: KOLSHUSHU_ELSHIMO
-- Level range: 50-65
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.CAPE_TERIGGAN] =
{
    zoneName    = "Cape_Teriggan",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "KOLSHUSHU_ELSHIMO",

    events =
    {
        -----------------------------------
        -- Goblin Excavation Crew
        -- Goblin Bondmen and Shepherds
        -- set up an illegal dig on the cape,
        -- driving wildlife toward settlement
        -- areas and threatening travellers.
        -----------------------------------
        {
            id          = "CT_GOBLIN_01",
            name        = "Goblin Excavation Crew",
            level       = 55,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 80,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 113

            mobs =
            {
                {
                    base        = { 113, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Goblin Bondman",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                    },
                },
                {
                    base        = { 113, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Goblin Herder",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
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
                    bronze = { { xi.item.GOBLIN_ARMOR,           150 } },
                    silver = { { xi.item.GOBLIN_ARMOR,           200 },
                               { xi.item.BEAST_HIDE,             150 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,           200 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,              50 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,            50 },
                               { xi.item.BEAST_HIDE,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Cape Terror
        -- An ancient and enormous Tiger
        -- descends from the highland crags
        -- of Cape Teriggan, marking the
        -- entire coast as its territory.
        -----------------------------------
        {
            id          = "CT_BOSS_01",
            name        = "The Cape Terror",
            level       = 62,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A deep, rumbling growl carries across Cape Teriggan on the sea wind...",
                "The growl fills the cape — an immense shadow stalks the clifftops...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 113

            mobs =
            {
                {
                    base         = { 113, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Cape Terror",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                    },
                },
                {
                    base        = { 113, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Teriggan Tiger",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 113
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
                    guaranteed = { xi.item.TIGER_HIDE },
                    bronze = { { xi.item.TIGER_HIDE,             240 },
                               { xi.item.BEAST_HIDE,             150 } },
                    silver = { { xi.item.TIGER_HIDE,             240 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.COEURL_WHISKER,         100 } },
                    gold   = { { xi.item.TIGER_HIDE,             240 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.COEURL_WHISKER,         150 },
                               { xi.item.GOBLIN_ARMOR,           100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TIGER_HIDE,              50 } },
                    gold   = { { xi.item.TIGER_HIDE,             100 },
                               { xi.item.BEAST_HIDE,              50 } },
                },
            },
        },
    },
}
