-----------------------------------
-- FATE Zone: Al'Taieu
-- Zone ID: 33
-- Region pool: SKY_SEA_HIGHEND
-- Level range: 65-75
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.ALTAIEU] =
{
    zoneName    = "AlTaieu",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "SKY_SEA_HIGHEND",

    events =
    {
        -----------------------------------
        -- Phuabo Emergence
        -- Phuabo and Xzomit erupt from the
        -- crystalline sea in coordinated
        -- waves, assailing the sky platforms
        -- with relentless fury.
        -----------------------------------
        {
            id          = "AT_PHUABO_01",
            name        = "Phuabo Emergence",
            level       = 70,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 33

            mobs =
            {
                {
                    base        = { 33, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Taieu Phuabo",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                    },
                },
                {
                    base        = { 33, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Taieu Xzomit",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 5000 },
                    silver = { exp = 2500 },
                    bronze = { exp = 1250 },
                },
                fail =
                {
                    gold   = { exp = 1250 },
                    silver = { exp = 625  },
                    bronze = { exp = 310  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.ANGEL_SKIN,              150 } },
                    silver = { { xi.item.ANGEL_SKIN,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.ANGEL_SKIN,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.BONE_CHIP,               100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.ANGEL_SKIN,               50 } },
                    gold   = { { xi.item.ANGEL_SKIN,              100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,     50 } },
                },
            },
        },

        -----------------------------------
        -- The Ix'aern Arbiter
        -- An Ix'aern of terrible power
        -- descends from the upper tiers of
        -- Al'Taieu to pass judgement on
        -- all who dare set foot below.
        -----------------------------------
        {
            id          = "AT_BOSS_01",
            name        = "The Ix'aern Arbiter",
            level       = 75,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The crystalline sea of Al'Taieu resonates with a singular, piercing tone...",
                "A radiant figure descends from the upper tiers - an Ix'aern approaches...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 33

            mobs =
            {
                {
                    base         = { 33, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Ix'aern Judge",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                    },
                },
                {
                    base        = { 33, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Taieu Zphar",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 33
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
                    guaranteed = { xi.item.ANGEL_SKIN },
                    bronze = { { xi.item.ANGEL_SKIN,              240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    silver = { { xi.item.ANGEL_SKIN,              240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BONE_CHIP,               150 } },
                    gold   = { { xi.item.ANGEL_SKIN,              240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BONE_CHIP,               150 },
                               { xi.item.BROKEN_IRON_GIANT_GEAR,  100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.ANGEL_SKIN,               50 } },
                    gold   = { { xi.item.ANGEL_SKIN,              100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,     50 } },
                },
            },
        },
    },
}
