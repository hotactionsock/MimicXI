-----------------------------------
-- FATE Zone: Qufim Island
-- Zone ID: 126
-- Region pool: NORVALLEN_QUFIM
-- Level range: 30-45
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.QUFIM_ISLAND] =
{
    zoneName    = "Qufim_Island",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORVALLEN_QUFIM",

    events =
    {
        -----------------------------------
        -- Gigas Shore Party
        -- Gigas Bhikkhu and Pickmen wade
        -- ashore from their longboats to
        -- raid the island's supply depot
        -- and scatter any adventurers.
        -----------------------------------
        {
            id          = "QI_GIGAS_01",
            name        = "Gigas Shore Party",
            level       = 35,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 126

            mobs =
            {
                {
                    base        = { 126, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Bhikkhu",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                    },
                },
                {
                    base        = { 126, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Gigas Pickman",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2200 },
                    silver = { exp = 1100 },
                    bronze = { exp = 550  },
                },
                fail =
                {
                    gold   = { exp = 550 },
                    silver = { exp = 275 },
                    bronze = { exp = 135 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.GIANT_EGG,              150 } },
                    silver = { { xi.item.GIANT_EGG,              200 },
                               { xi.item.BONE_CHIP,              150 } },
                    gold   = { { xi.item.GIANT_EGG,              200 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.GIANT_EGG,               50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Qufim Leviathan
        -- An enormous Sea Monk surfaces in
        -- Qufim's shallows, dragging itself
        -- ashore and assaulting the island
        -- with crushing tentacles.
        -----------------------------------
        {
            id          = "QI_BOSS_01",
            name        = "The Qufim Leviathan",
            level       = 42,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The waters around Qufim Island churn with unnatural violence...",
                "Enormous tentacles breach the surface and drag toward the shore...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 126

            mobs =
            {
                {
                    base         = { 126, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Sea Leviathan",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                    },
                },
                {
                    base        = { 126, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Island Wight",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 126
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
                    guaranteed = { xi.item.TENTACLE },
                    bronze = { { xi.item.TENTACLE,               240 },
                               { xi.item.GIANT_EGG,              150 } },
                    silver = { { xi.item.TENTACLE,               240 },
                               { xi.item.GIANT_EGG,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 } },
                    gold   = { { xi.item.TENTACLE,               240 },
                               { xi.item.GIANT_EGG,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 },
                               { xi.item.BONE_CHIP,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.TENTACLE,                50 } },
                    gold   = { { xi.item.TENTACLE,               100 },
                               { xi.item.GIANT_EGG,               50 } },
                },
            },
        },
    },
}
