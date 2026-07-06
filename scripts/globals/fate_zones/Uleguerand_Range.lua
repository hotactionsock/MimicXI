-----------------------------------
-- FATE Zone: Uleguerand Range
-- Zone ID: 5
-- Region pool: SKY_SEA_HIGHEND
-- Level range: 60-75
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.ULEGUERAND_RANGE] =
{
    zoneName    = "Uleguerand_Range",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "SKY_SEA_HIGHEND",

    events =
    {
        -----------------------------------
        -- Icedrake Rampage
        -- Icedrakes and Wyverns sweep down
        -- from the high peaks in a territorial
        -- frenzy, harrying travellers across
        -- the frozen range.
        -----------------------------------
        {
            id          = "UR_DRAKE_01",
            name        = "Icedrake Rampage",
            level       = 65,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area = { 0, 0, 0, 80 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 5

            mobs =
            {
                {
                    base        = { 5, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Range Icedrake",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                    },
                },
                {
                    base        = { 5, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Range Wyvern",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
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
                    guaranteed = {},
                    bronze = { { xi.item.WYVERN_SCALES,           150 } },
                    silver = { { xi.item.WYVERN_SCALES,           200 },
                               { xi.item.ICE_CRYSTAL,             100 } },
                    gold   = { { xi.item.WYVERN_SCALES,           200 },
                               { xi.item.ICE_CRYSTAL,             150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.ICE_CRYSTAL,              50 } },
                    gold   = { { xi.item.WYVERN_SCALES,            50 },
                               { xi.item.ICE_CRYSTAL,              50 } },
                },
            },
        },

        -----------------------------------
        -- The Range Leviathan
        -- An enormous Icedrake of legendary
        -- size, driven mad by the bitter cold,
        -- descends from the highest peaks to
        -- claim the entire range as its lair.
        -----------------------------------
        {
            id          = "UR_BOSS_01",
            name        = "The Range Leviathan",
            level       = 72,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The peaks of Uleguerand Range echo with a bone-chilling roar...",
                "The sky darkens with vast wings as a colossal drake descends...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 5

            mobs =
            {
                {
                    base         = { 5, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Ice Leviathan",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                    },
                },
                {
                    base        = { 5, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Range Buffalo",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 5
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 10000 },
                    silver = { exp = 5000  },
                    bronze = { exp = 2500  },
                },
                fail =
                {
                    gold   = { exp = 2500 },
                    silver = { exp = 1250 },
                    bronze = { exp = 625  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.WYVERN_SCALES },
                    bronze = { { xi.item.WYVERN_SCALES,           240 },
                               { xi.item.ICE_CRYSTAL,             150 } },
                    silver = { { xi.item.WYVERN_SCALES,           240 },
                               { xi.item.ICE_CRYSTAL,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.WYVERN_SCALES,           240 },
                               { xi.item.ICE_CRYSTAL,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BUFFALO_HIDE,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.WYVERN_SCALES,            50 } },
                    gold   = { { xi.item.WYVERN_SCALES,           100 },
                               { xi.item.ICE_CRYSTAL,              50 } },
                },
            },
        },
    },
}
