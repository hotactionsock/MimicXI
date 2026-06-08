-----------------------------------
-- FATE Zone: Mount Zhayolm
-- Zone ID: 61
-- Region pool: TOAU
-- Level range: 60-75
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.MOUNT_ZHAYOLM] =
{
    zoneName    = "Mount_Zhayolm",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "TOAU",

    events =
    {
        -----------------------------------
        -- Soulflayer Surge
        -- Soulflayers and Poroggo descend
        -- from the volcanic crags of Mount
        -- Zhayolm, preying on anything
        -- that crosses the lava fields.
        -----------------------------------
        {
            id          = "MZ_SOULFLAYER_01",
            name        = "Soulflayer Surge",
            level       = 65,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 80,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 61

            mobs =
            {
                {
                    base        = { 61, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Zhayolm Flayer",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                    },
                },
                {
                    base        = { 61, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Mount Poroggo",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
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
                    bronze = { { xi.item.DEMON_SKULL,             150 } },
                    silver = { { xi.item.DEMON_SKULL,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.DEMON_SKULL,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.BEAST_HIDE,              100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DEMON_SKULL,              50 } },
                    gold   = { { xi.item.DEMON_SKULL,             100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,     50 } },
                },
            },
        },

        -----------------------------------
        -- The Volcano Lord
        -- A Soulflayer of godlike power
        -- rises from the summit of Mount
        -- Zhayolm itself, commanding the
        -- mountain's very lava as its weapon.
        -----------------------------------
        {
            id          = "MZ_BOSS_01",
            name        = "The Volcano Lord",
            level       = 73,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "Mount Zhayolm erupts in a series of violent tremors...",
                "A pillar of fire bursts from the summit and an immense figure descends...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 61

            mobs =
            {
                {
                    base         = { 61, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Volcano Lord",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                    },
                },
                {
                    base        = { 61, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Zhayolm Troll",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 61
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
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    silver = { { xi.item.DEMON_SKULL,             240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BEAST_HIDE,              150 } },
                    gold   = { { xi.item.DEMON_SKULL,             240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.BROKEN_IRON_GIANT_GEAR,  100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DEMON_SKULL,              50 } },
                    gold   = { { xi.item.DEMON_SKULL,             100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,     50 } },
                },
            },
        },
    },
}
