-----------------------------------
-- FATE Zone: Ru'Aun Gardens
-- Zone ID: 130
-- Region pool: SKY_SEA_HIGHEND
-- Level range: 65-75
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.RUAUN_GARDENS] =
{
    zoneName    = "RuAun_Gardens",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "SKY_SEA_HIGHEND",

    events =
    {
        -----------------------------------
        -- Kindred Patrol
        -- Kindred Clerics and Beastmasters
        -- sweep the upper gardens, driving
        -- intruders from the domain they
        -- have claimed as their own.
        -----------------------------------
        {
            id          = "RG_KINDRED_01",
            name        = "Kindred Patrol",
            level       = 68,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "RG_KINDRED_02",
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 130

            mobs =
            {
                {
                    base        = { 130, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Kindred Cleric",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                    },
                },
                {
                    base        = { 130, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Kindred Tamer",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
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
                    bronze = { { xi.item.DEMON_SKULL,             150 } },
                    silver = { { xi.item.DEMON_SKULL,             200 },
                               { xi.item.DEMON_HIDE,              150 } },
                    gold   = { { xi.item.DEMON_SKULL,             200 },
                               { xi.item.DEMON_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DEMON_SKULL,              50 } },
                    gold   = { { xi.item.DEMON_SKULL,             100 },
                               { xi.item.DEMON_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- Kindred Vanguard
        -- Chains from Kindred Patrol.
        -- Kindred Sorcerers and a Shadowhand
        -- converge on the gardens in force,
        -- determined to reclaim the grounds.
        -----------------------------------
        {
            id          = "RG_KINDRED_02",
            name        = "Kindred Vanguard",
            level       = 72,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 130

            mobs =
            {
                {
                    base        = { 130, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Kindred Mage",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                    },
                },
                {
                    base        = { 130, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Kindred Shadow",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 5500 },
                    silver = { exp = 2750 },
                    bronze = { exp = 1375 },
                },
                fail =
                {
                    gold   = { exp = 1375 },
                    silver = { exp = 685  },
                    bronze = { exp = 340  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.DEMON_SKULL,             100 } },
                    silver = { { xi.item.DEMON_SKULL,             200 },
                               { xi.item.DEMON_HIDE,              150 } },
                    gold   = { { xi.item.DEMON_SKULL,             200 },
                               { xi.item.DEMON_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DEMON_SKULL,              50 } },
                    gold   = { { xi.item.DEMON_SKULL,             100 },
                               { xi.item.DEMON_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Garden Destroyer
        -- An ancient divine avatar — bound
        -- in the gardens for aeons — breaks
        -- free from its seal, tearing through
        -- the upper platforms in a blind rage.
        -----------------------------------
        {
            id          = "RG_BOSS_01",
            name        = "The Garden Destroyer",
            level       = 75,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The platforms of Ru'Aun Gardens tremble as something immense stirs below...",
                "A blinding light erupts across the upper gardens — an ancient force walks free...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 130

            mobs =
            {
                {
                    base         = { 130, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Sky Destroyer",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                    },
                },
                {
                    base        = { 130, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Kindred Elite",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 130
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
                    guaranteed = { xi.item.DEMON_SKULL },
                    bronze = { { xi.item.DEMON_SKULL,             240 },
                               { xi.item.DEMON_HIDE,              150 } },
                    silver = { { xi.item.DEMON_SKULL,             240 },
                               { xi.item.DEMON_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.DEMON_SKULL,             240 },
                               { xi.item.DEMON_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BROKEN_IRON_GIANT_GEAR,  100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DEMON_SKULL,              50 } },
                    gold   = { { xi.item.DEMON_SKULL,             100 },
                               { xi.item.DEMON_HIDE,               50 } },
                },
            },
        },
    },
}
