-----------------------------------
-- FATE Zone: Yhoator Jungle
-- Zone ID: 124
-- Region pool: KOLSHUSHU_ELSHIMO
-- Level range: 50-65
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.YHOATOR_JUNGLE] =
{
    zoneName    = "Yhoator_Jungle",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "KOLSHUSHU_ELSHIMO",

    events =
    {
        -----------------------------------
        -- Tonberry Elder Conclave
        -- Tonberry Elders and Assassins
        -- gather in the deep jungle for a
        -- ritual that draws them outward to
        -- prey on intruders.
        -----------------------------------
        {
            id          = "YHO_TONBERRY_01",
            name        = "Tonberry Elder Conclave",
            level       = 55,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "YHO_TONBERRY_02",
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 124

            mobs =
            {
                {
                    base        = { 124, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Tonberry Elder",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                    },
                },
                {
                    base        = { 124, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Berry Assassin",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
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
                    bronze = { { xi.item.TONBERRY_LANTERN,        150 } },
                    silver = { { xi.item.TONBERRY_LANTERN,        200 },
                               { xi.item.BONE_CHIP,               150 } },
                    gold   = { { xi.item.TONBERRY_LANTERN,        200 },
                               { xi.item.BONE_CHIP,               150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.TONBERRY_LANTERN,         50 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- Tonberry High Council
        -- Chains from Tonberry Elder Conclave.
        -- Tonberry High Priests and Tonberry
        -- Kings emerge in response, conducting
        -- their murderous rite.
        -----------------------------------
        {
            id          = "YHO_TONBERRY_02",
            name        = "Tonberry High Council",
            level       = 59,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 124

            mobs =
            {
                {
                    base        = { 124, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Berry Priest",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                    },
                },
                {
                    base        = { 124, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Tonberry King",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
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
                    bronze = { { xi.item.TONBERRY_LANTERN,        100 } },
                    silver = { { xi.item.TONBERRY_LANTERN,        200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.TONBERRY_LANTERN,        200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.BONE_CHIP,               150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.TONBERRY_LANTERN,         50 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- The Yhoator Deathbringer
        -- A legendary Tonberry Deathbringer
        -- emerges from the deepest ruins,
        -- leading a retinue of devoted
        -- Tonberry Warlocks into battle.
        -----------------------------------
        {
            id          = "YHO_BOSS_01",
            name        = "The Yhoator Deathbringer",
            level       = 63,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A chill falls over Yhoator Jungle and lanterns flicker in the dark...",
                "Something ancient and patient moves toward you through the undergrowth...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 124

            mobs =
            {
                {
                    base         = { 124, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Yhoator Slayer",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                    },
                },
                {
                    base        = { 124, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Berry Warlock",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 124
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 7500 },
                    silver = { exp = 3750 },
                    bronze = { exp = 1875 },
                },
                fail =
                {
                    gold   = { exp = 1875 },
                    silver = { exp = 935  },
                    bronze = { exp = 465  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.TONBERRY_LANTERN },
                    bronze = { { xi.item.TONBERRY_LANTERN,        240 },
                               { xi.item.BONE_CHIP,               150 } },
                    silver = { { xi.item.TONBERRY_LANTERN,        240 },
                               { xi.item.BONE_CHIP,               200 },
                               { xi.item.BEAST_HIDE,              100 } },
                    gold   = { { xi.item.TONBERRY_LANTERN,        240 },
                               { xi.item.BONE_CHIP,               200 },
                               { xi.item.BEAST_HIDE,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TONBERRY_LANTERN,         50 } },
                    gold   = { { xi.item.TONBERRY_LANTERN,        100 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },
    },
}
