-----------------------------------
-- FATE Zone: Ro'Maeve
-- Zone ID: 122
-- Region pool: LITEILOR
-- Level range: 55-70
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.ROMAEVE] =
{
    zoneName    = "RoMaeve",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "LITEILOR",

    events =
    {
        -----------------------------------
        -- Undead Convergence
        -- The restless dead of Ro'Maeve's
        -- ancient ruins — Skeletons and
        -- Ghosts — surge outward from the
        -- crumbling towers in alarming numbers.
        -----------------------------------
        {
            id          = "RM_UNDEAD_01",
            name        = "Undead Convergence",
            level       = 60,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "RM_UNDEAD_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 122

            mobs =
            {
                {
                    base        = { 122, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Maeve Skeleton",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                    },
                },
                {
                    base        = { 122, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Ro'Maeve Ghost",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
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
                    bronze = { { xi.item.BONE_CHIP,               150 } },
                    silver = { { xi.item.BONE_CHIP,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.BONE_CHIP,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.BEAST_HIDE,              100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.BONE_CHIP,               100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,     50 } },
                },
            },
        },

        -----------------------------------
        -- Ancient Guardian Host
        -- Chains from Undead Convergence.
        -- Ro'Maeve Wights and Spectres rise,
        -- serving the will of some deep
        -- presence within the tower ruins.
        -----------------------------------
        {
            id          = "RM_UNDEAD_02",
            name        = "Ancient Guardian Host",
            level       = 64,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 122

            mobs =
            {
                {
                    base        = { 122, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Ro'Maeve Wight",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                    },
                },
                {
                    base        = { 122, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Maeve Spectre",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
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
                    bronze = { { xi.item.BONE_CHIP,               100 } },
                    silver = { { xi.item.BONE_CHIP,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.BONE_CHIP,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BEAST_HIDE,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.BONE_CHIP,               100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,     50 } },
                },
            },
        },

        -----------------------------------
        -- The Eternal Sentry
        -- The tower's undying guardian —
        -- a massive Lich infused with the
        -- Water Crystal's power — manifests
        -- fully to destroy all trespassers.
        -----------------------------------
        {
            id          = "RM_BOSS_01",
            name        = "The Eternal Sentry",
            level       = 68,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The Water Crystal at the heart of Ro'Maeve pulses with dark energy...",
                "A towering figure of bone and shadow coalesces above the central tower...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 122

            mobs =
            {
                {
                    base         = { 122, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Eternal Sentry",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                    },
                },
                {
                    base        = { 122, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Stone Revenant",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 122
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
                    guaranteed = { xi.item.BONE_CHIP },
                    bronze = { { xi.item.BONE_CHIP,               240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    silver = { { xi.item.BONE_CHIP,               240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BEAST_HIDE,              100 } },
                    gold   = { { xi.item.BONE_CHIP,               240 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BEAST_HIDE,              150 },
                               { xi.item.DEMON_SKULL,             150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.BONE_CHIP,               100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,     50 } },
                },
            },
        },
    },
}
