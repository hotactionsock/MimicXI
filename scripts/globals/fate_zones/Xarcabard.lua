-----------------------------------
-- FATE Zone: Xarcabard
-- Zone ID: 112
-- Region pool: NORTHLANDS
-- Level range: 50-65
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.XARCABARD] =
{
    zoneName    = "Xarcabard",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORTHLANDS",

    events =
    {
        -----------------------------------
        -- Shadow Infestation
        -- Shadows and Nightmare creatures
        -- boil out from the black depths
        -- near Castle Zvahl, stalking
        -- travellers across the dark plain.
        -----------------------------------
        {
            id          = "XC_SHADOW_01",
            name        = "Shadow Infestation",
            level       = 58,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area = { 0, 0, 0, 80 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 112

            mobs =
            {
                {
                    base        = { 112, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Xarc Shadow",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                    },
                },
                {
                    base        = { 112, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Dark Corse",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
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
                    bronze = { { xi.item.DEMON_SKULL,            150 } },
                    silver = { { xi.item.DEMON_SKULL,            200 },
                               { xi.item.BONE_CHIP,              150 } },
                    gold   = { { xi.item.DEMON_SKULL,            200 },
                               { xi.item.BONE_CHIP,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.DEMON_SKULL,             50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Chaos Shade
        -- A being of pure shadow takes form
        -- amid the darkness of Xarcabard,
        -- commanding a retinue of Nightmare
        -- creatures as its honour guard.
        -----------------------------------
        {
            id          = "XC_BOSS_01",
            name        = "The Chaos Shade",
            level       = 62,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The darkness over Xarcabard deepens beyond all natural measure...",
                "A cold void tears open in the sky - something vast and formless descends...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 112

            mobs =
            {
                {
                    base         = { 112, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Chaos Shade",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                    },
                },
                {
                    base        = { 112, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Shade Wraith",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 112
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
                    guaranteed = { xi.item.DEMON_SKULL },
                    bronze = { { xi.item.DEMON_SKULL,            240 },
                               { xi.item.BONE_CHIP,              150 } },
                    silver = { { xi.item.DEMON_SKULL,            240 },
                               { xi.item.BONE_CHIP,              200 },
                               { xi.item.ICE_CRYSTAL,            150 } },
                    gold   = { { xi.item.DEMON_SKULL,            240 },
                               { xi.item.BONE_CHIP,              200 },
                               { xi.item.ICE_CRYSTAL,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DEMON_SKULL,             50 } },
                    gold   = { { xi.item.DEMON_SKULL,            100 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },
    },
}
