-----------------------------------
-- FATE Zone: Bhaflau Thickets
-- Zone ID: 52
-- Region pool: TOAU
-- Level range: 55-70
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BHAFLAU_THICKETS] =
{
    zoneName    = "Bhaflau_Thickets",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "TOAU",

    events =
    {
        -----------------------------------
        -- Mamool Ja Incursion
        -- Mamool Ja Mimics and Executioners
        -- push deep into the thickets,
        -- scouting for weaknesses in the
        -- region's defences.
        -----------------------------------
        {
            id          = "BT_MAMOOL_01",
            name        = "Mamool Ja Incursion",
            level       = 60,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "BT_MAMOOL_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 80,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 52

            mobs =
            {
                {
                    base        = { 52, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Mamool Mimic",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                    },
                },
                {
                    base        = { 52, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Mamool Slayer",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
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
                    bronze = { { xi.item.LIZARD_SKIN,             150 } },
                    silver = { { xi.item.LIZARD_SKIN,             200 },
                               { xi.item.BEAST_HIDE,              100 } },
                    gold   = { { xi.item.LIZARD_SKIN,             200 },
                               { xi.item.BEAST_HIDE,              150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LIZARD_SKIN,              50 } },
                    gold   = { { xi.item.LIZARD_SKIN,             100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- Mamool Ja Taskforce
        -- Chains from Mamool Ja Incursion.
        -- Mamool Ja Sophists and a Warlord
        -- respond to the scouts' signal,
        -- arriving in battle formation.
        -----------------------------------
        {
            id          = "BT_MAMOOL_02",
            name        = "Mamool Ja Taskforce",
            level       = 64,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 52

            mobs =
            {
                {
                    base        = { 52, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Mamool Sophist",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                    },
                },
                {
                    base        = { 52, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Mamool Warlord",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
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
                    bronze = { { xi.item.LIZARD_SKIN,             100 } },
                    silver = { { xi.item.LIZARD_SKIN,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.LIZARD_SKIN,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.BEAST_HIDE,              150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LIZARD_SKIN,              50 } },
                    gold   = { { xi.item.LIZARD_SKIN,             100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },

        -----------------------------------
        -- The Thicket Monarch
        -- A legendary Mamool Ja elder of
        -- enormous size and ferocity erupts
        -- from the deep thickets, trailing
        -- a host of mounted Trolls.
        -----------------------------------
        {
            id          = "BT_BOSS_01",
            name        = "The Thicket Monarch",
            level       = 68,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "War cries echo through the Bhaflau Thickets, growing louder by the minute...",
                "The thickets part and a massive armoured form strides into the clearing...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 52

            mobs =
            {
                {
                    base         = { 52, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Thicket King",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                    },
                },
                {
                    base        = { 52, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Bhaflau Troll",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 52
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
                    guaranteed = { xi.item.LIZARD_SKIN },
                    bronze = { { xi.item.LIZARD_SKIN,             240 },
                               { xi.item.BEAST_HIDE,              150 } },
                    silver = { { xi.item.LIZARD_SKIN,             240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.LIZARD_SKIN,             240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.DEMON_SKULL,             100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LIZARD_SKIN,              50 } },
                    gold   = { { xi.item.LIZARD_SKIN,             100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },
    },
}
