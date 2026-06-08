-----------------------------------
-- FATE Zone: Caedarva Mire
-- Zone ID: 79
-- Region pool: TOAU
-- Level range: 55-70
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.CAEDARVA_MIRE] =
{
    zoneName    = "Caedarva_Mire",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "TOAU",

    events =
    {
        -----------------------------------
        -- Lamia Hunting Party
        -- Lamia Dancers and Bowyers emerge
        -- from the mire's depths to hunt,
        -- driving prey before them and
        -- ensnaring anything that flees.
        -----------------------------------
        {
            id          = "CM_LAMIA_01",
            name        = "Lamia Ask You A Question",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 79

            mobs =
            {
                {
                    base        = { 79, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Lamia Dancer",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
                    },
                },
                {
                    base        = { 79, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Lamia Bowyer",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 79
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
                    bronze = { { xi.item.LAMIA_SCALE,             150 } },
                    silver = { { xi.item.LAMIA_SCALE,             200 },
                               { xi.item.BEAST_HIDE,              100 } },
                    gold   = { { xi.item.LAMIA_SCALE,             200 },
                               { xi.item.BEAST_HIDE,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LAMIA_SCALE,              50 } },
                    gold   = { { xi.item.LAMIA_SCALE,             100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Mire Colossus
        -- An ancient undead giant stirs from
        -- the deepest part of Caedarva Mire,
        -- dragging itself upright and laying
        -- waste to all within reach.
        -----------------------------------
        {
            id          = "CM_BOSS_01",
            name        = "The Mire Colossus",
            level       = 66,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The murky waters of Caedarva Mire churn and bubble violently...",
                "A wicked creature rises from the mire, shedding mud and metal as it stands...",
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
                x      = 142.4,   -- TODO: !pos survey
                y      = 0.5,   -- TODO: !pos survey
                z      = -717.4,   -- TODO: !pos survey
                radius = 80,
            },

            entryPos = { 132.698, 0.292, -686.350, 53 }, -- !pos 132.698 0.292 -686.350 79

            mobs =
            {
                {
                    base         = { 216, 53 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Mire Colossus",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 142.435, 0.500, -717.442, 182 }, -- !pos 142.435 0.500 -717.442 79
                    },
                },
                {
                    base        = { 289, 97 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Caedarva Lamia",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 156.275, 0.250, -707.810, 160 }, -- !pos 156.275 0.250 -707.810 79
                        { 149.366, 0.500, -707.903, 153 }, -- !pos 149.366 0.500 -707.903 79
                        { 123.644, 0.211, -712.591, 202 }, -- !pos 123.644 0.211 -712.591 79
                        { 117.525, 0.274, -707.583, 191 }, -- !pos 117.525 0.274 -707.583 79
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 9000 },
                    silver = { exp = 4500 },
                    bronze = { exp = 2250 },
                },
                fail =
                {
                    gold   = { exp = 2250 },
                    silver = { exp = 1125 },
                    bronze = { exp = 560  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.LAMIA_SCALE },
                    bronze = { { xi.item.LAMIA_SCALE,             240 },
                               { xi.item.BEAST_HIDE,              150 } },
                    silver = { { xi.item.LAMIA_SCALE,             240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.BONE_CHIP,               100 } },
                    gold   = { { xi.item.LAMIA_SCALE,             240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.BONE_CHIP,               150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LAMIA_SCALE,              50 } },
                    gold   = { { xi.item.LAMIA_SCALE,             100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },
    },
}
