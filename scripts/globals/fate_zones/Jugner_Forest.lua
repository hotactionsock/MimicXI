-----------------------------------
-- FATE Zone: Jugner Forest
-- Zone ID: 104
-- Region pool: NORVALLEN_QUFIM
-- Level range: 25-40
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.JUGNER_FOREST] =
{
    zoneName    = "Jugner_Forest",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORVALLEN_QUFIM",

    events =
    {
        -----------------------------------
        -- Orcish Forest Patrol
        -- Orcish Stonemen and Cursemakers
        -- range deep into Jugner Forest on
        -- patrol from Castle Oztroja,
        -- cutting off the road to Jeuno.
        -----------------------------------
        {
            id          = "JF_ORC_01",
            name        = "Orcish Forest Patrol",
            level       = 30,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 104

            mobs =
            {
                {
                    base        = { 104, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Golem",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                    },
                },
                {
                    base        = { 104, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Curser",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1800 },
                    silver = { exp = 900  },
                    bronze = { exp = 450  },
                },
                fail =
                {
                    gold   = { exp = 450 },
                    silver = { exp = 225 },
                    bronze = { exp = 110 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,     150 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              150 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,      50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Ancient Sapling
        -- A massive Forest Sapling, ancient
        -- beyond reckoning, animates and
        -- begins crushing the forest path,
        -- drawing smaller Saplings to serve.
        -----------------------------------
        {
            id          = "JF_BOSS_01",
            name        = "The Ancient Sapling",
            level       = 38,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A deep groan resonates through the ancient wood of Jugner Forest...",
                "The canopy shudders violently — the oldest tree in the forest has awakened...",
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
                radius = 81,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 104

            mobs =
            {
                {
                    base         = { 104, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Elder Sapling",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                    },
                },
                {
                    base        = { 104, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Forest Sapling",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 104
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
                    guaranteed = { xi.item.TREANT_BULB },
                    bronze = { { xi.item.TREANT_BULB,            240 },
                               { xi.item.ORCISH_MAIL_SCALES,     150 } },
                    silver = { { xi.item.TREANT_BULB,            240 },
                               { xi.item.ORCISH_MAIL_SCALES,     150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 } },
                    gold   = { { xi.item.TREANT_BULB,            240 },
                               { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 },
                               { xi.item.BONE_CHIP,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TREANT_BULB,             50 } },
                    gold   = { { xi.item.TREANT_BULB,            100 },
                               { xi.item.ORCISH_MAIL_SCALES,      50 } },
                },
            },
        },
    },
}
