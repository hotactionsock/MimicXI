-----------------------------------
-- FATE Zone: Sauromugue Champaign
-- Zone ID: 120
-- Region pool: NORVALLEN_QUFIM
-- Level range: 35-50
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.SAUROMUGUE_CHAMPAIGN] =
{
    zoneName    = "Sauromugue_Champaign",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORVALLEN_QUFIM",

    events =
    {
        -----------------------------------
        -- Orcish Field Operations
        -- Orcish Hexspinners and Troopers
        -- advance in force across the
        -- champaign as part of a coordinated
        -- push against the Jeuno perimeter.
        -----------------------------------
        {
            id          = "SC_ORC_01",
            name        = "Orcish Field Operations",
            level       = 40,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "SC_ORC_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area = { 0, 0, 0, 80 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 120

            mobs =
            {
                {
                    base        = { 120, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Hexer",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                    },
                },
                {
                    base        = { 120, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Trooper",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2500 },
                    silver = { exp = 1250 },
                    bronze = { exp = 625  },
                },
                fail =
                {
                    gold   = { exp = 625 },
                    silver = { exp = 310 },
                    bronze = { exp = 155 },
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
        -- Orcish Blitz Vanguard
        -- Chains from Orcish Field Operations.
        -- Orcish Constables and Captains
        -- exploit the breach, pushing
        -- heavy cavalry across the champaign.
        -----------------------------------
        {
            id          = "SC_ORC_02",
            name        = "Orcish Blitz Vanguard",
            level       = 44,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 120

            mobs =
            {
                {
                    base        = { 120, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Warden",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                    },
                },
                {
                    base        = { 120, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Captain",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2800 },
                    silver = { exp = 1400 },
                    bronze = { exp = 700  },
                },
                fail =
                {
                    gold   = { exp = 700 },
                    silver = { exp = 350 },
                    bronze = { exp = 175 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,     100 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 },
                               { xi.item.BONE_CHIP,              150 } },
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
        -- The Champaign Warlord
        -- A legendary Orcish Warlord,
        -- riding a colossal raptor mount,
        -- leads the push himself, arriving
        -- with a personal honour guard.
        -----------------------------------
        {
            id          = "SC_BOSS_01",
            name        = "The Champaign Warlord",
            level       = 48,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "War drums roll across the Sauromugue Champaign...",
                "A war banner appears on the horizon — the Orcish Warlord rides to battle...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 120

            mobs =
            {
                {
                    base         = { 120, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Plains Warlord",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                    },
                },
                {
                    base        = { 120, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Elite",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 120
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
                    guaranteed = { xi.item.ORCISH_MAIL_SCALES },
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,     240 },
                               { xi.item.BEAST_HIDE,             150 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,     240 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     240 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 },
                               { xi.item.BONE_CHIP,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.ORCISH_MAIL_SCALES,      50 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     100 },
                               { xi.item.BEAST_HIDE,              50 } },
                },
            },
        },
    },
}
