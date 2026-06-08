-----------------------------------
-- FATE Zone: Buburimu Peninsula
-- Zone ID: 118
-- Region pool: DERFLAND_ARAGONEU
-- Level range: 30-45
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BUBURIMU_PENINSULA] =
{
    zoneName    = "Buburimu_Peninsula",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "DERFLAND_ARAGONEU",

    events =
    {
        -----------------------------------
        -- Goblin Shore Raid
        -- Goblin Leechers and Muggers
        -- land from rafts on the rocky
        -- coast and press inland to
        -- plunder anything of value.
        -----------------------------------
        {
            id          = "BP_GOBLIN_01",
            name        = "Goblin Shore Raid",
            level       = 35,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 118

            mobs =
            {
                {
                    base        = { 118, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Goblin Leecher",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                    },
                },
                {
                    base        = { 118, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Goblin Mugger",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2000 },
                    silver = { exp = 1000 },
                    bronze = { exp = 500  },
                },
                fail =
                {
                    gold   = { exp = 500 },
                    silver = { exp = 250 },
                    bronze = { exp = 125 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.GOBLIN_ARMOR,           150 } },
                    silver = { { xi.item.GOBLIN_ARMOR,           200 },
                               { xi.item.BONE_CHIP,              150 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,           200 },
                               { xi.item.GOBLIN_MASK,            100 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,               50 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,            50 },
                               { xi.item.BONE_CHIP,               50 } },
                },
            },
        },

        -----------------------------------
        -- Goblin Hecklers
        -- A gang of mouthy Goblin Hecklers
        -- has taken up position on the
        -- coastal path and won't shut up.
        -- They are also heavily armed.
        -- Both problems need addressing.
        -----------------------------------
        {
            id          = "BP_GOBLIN_02",
            name        = "Goblin Hecklers",
            level       = 33,
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 118

            mobs =
            {
                {
                    -- Script: scripts/zones/Buburimu_Peninsula/mobs/Goblin_Heckler.lua
                    -- Loaded automatically by the engine when mob name matches the script filename.
                    -- Ensure mob_groups entry name matches "Goblin Heckler" exactly.
                    base        = { 118, 5 },  -- TODO: verify mob_groups (Goblin Heckler)
                    name        = string.char(0xA6) .. "Goblin Heckler",
                    count       = 8,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2000 },
                    silver = { exp = 1000 },
                    bronze = { exp = 500  },
                },
                fail =
                {
                    gold   = { exp = 500 },
                    silver = { exp = 250 },
                    bronze = { exp = 125 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.GOBLIN_ARMOR,            150 } },
                    silver = { { xi.item.GOBLIN_ARMOR,            200 },
                               { xi.item.GOBLIN_MASK,             100 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,            200 },
                               { xi.item.GOBLIN_MASK,             150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.GOBLIN_ARMOR,             50 } },
                    gold   = { { xi.item.GOBLIN_ARMOR,            100 },
                               { xi.item.GOBLIN_MASK,              50 } },
                },
            },
        },

        -----------------------------------
        -- Peninsula Predator
        -- A massive Coeurl, the apex
        -- predator of Buburimu, emerges
        -- at dusk to hunt alongside
        -- its bonded Roc companion.
        -----------------------------------
        {
            id          = "BP_BOSS_01",
            name        = "Peninsula Predator",
            level       = 42,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A piercing shriek cuts through the sea breeze on the peninsula...",
                "Heavy wingbeats drum overhead — the peninsula's apex predator has stirred...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 118

            mobs =
            {
                {
                    base         = { 118, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Shore Coeurl",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                    },
                },
                {
                    base        = { 118, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Buburimu Roc",
                    count       = 2,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
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
                    guaranteed = { xi.item.COEURL_WHISKER },
                    bronze = { { xi.item.BEAST_HIDE,             240 },
                               { xi.item.COEURL_WHISKER,         150 } },
                    silver = { { xi.item.BEAST_HIDE,             240 },
                               { xi.item.COEURL_WHISKER,         200 },
                               { xi.item.GIANT_BIRD_FEATHER,     100 } },
                    gold   = { { xi.item.COEURL_WHISKER,         200 },
                               { xi.item.BEAST_HIDE,             240 },
                               { xi.item.GIANT_BIRD_FEATHER,     150 },
                               { xi.item.GOBLIN_ARMOR,           100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,              50 } },
                    gold   = { { xi.item.BEAST_HIDE,             100 },
                               { xi.item.COEURL_WHISKER,          50 } },
                },
            },
        },

        -----------------------------------
        -- Sea Leech Swarm
        -- A tide of Sea Leeches surges up
        -- from the shallows and spreads
        -- across the coastal path, drawn
        -- by the scent of blood and salt.
        -----------------------------------
        {
            id          = "BP_LEECH_01",
            name        = "Sea Leech Swarm",
            level       = 31,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 12 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 70,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 118

            mobs =
            {
                {
                    base        = { 118, 6 },  -- TODO: verify mob_groups (Sea Leech)
                    name        = string.char(0xA6) .. "Sea Leech",
                    count       = 12,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 2000 },
                    silver = { exp = 1000 },
                    bronze = { exp = 500  },
                },
                fail =
                {
                    gold   = { exp = 500 },
                    silver = { exp = 250 },
                    bronze = { exp = 125 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.LEECH_SALIVA,            150 } },
                    silver = { { xi.item.LEECH_SALIVA,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.LEECH_SALIVA,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.GOBLIN_ARMOR,            100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LEECH_SALIVA,             50 } },
                    gold   = { { xi.item.LEECH_SALIVA,            100 },
                               { xi.item.GOBLIN_ARMOR,             50 } },
                },
            },
        },

        -----------------------------------
        -- Snipper Skirmish
        -- A large pack of Snippers emerges
        -- from the rocks and surges inland,
        -- threatening to cut the coastal
        -- path in two. Drive them back.
        -----------------------------------
        {
            id          = "BP_SNIPPER_01",
            name        = "Snipper Skirmish",
            level       = 33,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "BP_SNIPPER_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 75,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 118

            mobs =
            {
                {
                    base        = { 118, 7 },  -- TODO: verify mob_groups (Snipper)
                    name        = string.char(0xA6) .. "Shore Snipper",
                    count       = 10,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
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
                    bronze = { { xi.item.CRAB_MEAT,               150 } },
                    silver = { { xi.item.CRAB_MEAT,               200 },
                               { xi.item.SHELL_POWDER,            100 } },
                    gold   = { { xi.item.CRAB_MEAT,               200 },
                               { xi.item.SHELL_POWDER,            150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CRAB_MEAT,                50 } },
                    gold   = { { xi.item.CRAB_MEAT,               100 },
                               { xi.item.SHELL_POWDER,             50 } },
                },
            },
        },

        -----------------------------------
        -- Giant Snipper Advance
        -- Chains from Snipper Skirmish.
        -- The retreat signal draws the
        -- largest Snippers from the deep
        -- tide pools — massive veterans
        -- with armour like ship timber.
        -----------------------------------
        {
            id          = "BP_SNIPPER_02",
            name        = "Giant Snipper Advance",
            level       = 36,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 65,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 118

            mobs =
            {
                {
                    base        = { 118, 8 },  -- TODO: verify mob_groups (Giant Snipper)
                    name        = string.char(0xA6) .. "Giant Snipper",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
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
                    bronze = { { xi.item.CRAB_MEAT,               100 } },
                    silver = { { xi.item.CRAB_MEAT,               200 },
                               { xi.item.SHELL_POWDER,            150 } },
                    gold   = { { xi.item.CRAB_MEAT,               200 },
                               { xi.item.SHELL_POWDER,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CRAB_MEAT,                50 } },
                    gold   = { { xi.item.CRAB_MEAT,               100 },
                               { xi.item.SHELL_POWDER,             50 } },
                },
            },
        },

        -----------------------------------
        -- The Tidal Crusher
        -- A colossal Snipper, its shell
        -- scarred by centuries of tide,
        -- emerges from the deep to claim
        -- the entire beach as territory.
        -- It brings an escort.
        -----------------------------------
        {
            id          = "BP_BOSS_02",
            name        = "The Tidal Crusher",
            level       = 38,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The tide pulls back unnaturally far along the Buburimu coast...",
                "A mountainous shape rises from the shallows, claws the size of rowboats...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 118

            mobs =
            {
                {
                    base         = { 118, 9 },  -- TODO: verify mob_groups (Tidal Crusher)
                    name         = string.char(0xA6) .. "Tidal Crusher",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                    },
                },
                {
                    base        = { 118, 10 },  -- TODO: verify mob_groups (Buburimu Crab)
                    name        = string.char(0xA6) .. "Buburimu Crab",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
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
                    guaranteed = { xi.item.CRAB_MEAT },
                    bronze = { { xi.item.CRAB_MEAT,               240 },
                               { xi.item.SHELL_POWDER,            150 } },
                    silver = { { xi.item.CRAB_MEAT,               240 },
                               { xi.item.SHELL_POWDER,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.CRAB_MEAT,               240 },
                               { xi.item.SHELL_POWDER,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.GOBLIN_ARMOR,            100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CRAB_MEAT,                50 } },
                    gold   = { { xi.item.CRAB_MEAT,               100 },
                               { xi.item.SHELL_POWDER,             50 } },
                },
            },
        },

        -----------------------------------
        -- The Devourer of Tides
        -- An ancient, vastly engorged Sea
        -- Leech pulls itself from a fissure
        -- in the seabed that only the oldest
        -- Goblin charts record. It surfaces
        -- in a state of tremendous hunger.
        -----------------------------------
        {
            id          = "BP_BOSS_03",
            name        = "The Devourer of Tides",
            level       = 50,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The sea turns black offshore from Buburimu — something ancient stirs below...",
                "A titanic wake crashes across the beach as the Devourer of Tides surfaces...",
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
                radius = 110,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 118

            mobs =
            {
                {
                    base         = { 118, 11 },  -- TODO: verify mob_groups (Devourer of Tides)
                    name         = string.char(0xA6) .. "Tide Devourer",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 118
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
                    guaranteed = { xi.item.LEECH_SALIVA },
                    bronze = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.CRAB_MEAT,               150 } },
                    silver = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.CRAB_MEAT,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.LEECH_SALIVA,            240 },
                               { xi.item.CRAB_MEAT,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.GOBLIN_ARMOR,            150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.LEECH_SALIVA,             50 } },
                    gold   = { { xi.item.LEECH_SALIVA,            100 },
                               { xi.item.CRAB_MEAT,                50 } },
                },
            },
        },
    },
}
