-----------------------------------
-- FATE Zone: Attohwa Chasm
-- Zone ID: 7
-- Region pool: SKY_SEA_HIGHEND
-- Level range: 65-75
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.ATTOHWA_CHASM] =
{
    zoneName    = "Attohwa_Chasm",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "SKY_SEA_HIGHEND",

    events =
    {
        -----------------------------------
        -- Bugard Stampede
        -- A herd of Bugards is driven into
        -- a frenzy by unseen forces in the
        -- chasm, stampeding across the main
        -- paths and trampling everything.
        -----------------------------------
        {
            id          = "AC_BUGARD_01",
            name        = "Bugard Stampede",
            level       = 68,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area = { 0, 0, 0, 80 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 7

            mobs =
            {
                {
                    base        = { 7, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Attohwa Bugard",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                    },
                },
                {
                    base        = { 7, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Chasm Antlion",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
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
                    bronze = { { xi.item.BUGARD_SKIN,             150 } },
                    silver = { { xi.item.BUGARD_SKIN,             200 },
                               { xi.item.ANTLION_TRAP,            100 } },
                    gold   = { { xi.item.BUGARD_SKIN,             200 },
                               { xi.item.ANTLION_TRAP,            150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BUGARD_SKIN,              50 } },
                    gold   = { { xi.item.BUGARD_SKIN,             100 },
                               { xi.item.ANTLION_TRAP,             50 } },
                },
            },
        },

        -----------------------------------
        -- The Chasm Sovereign
        -- A titanic Bugard elder - the source
        -- of the herd's panic - emerges from
        -- the deepest part of the chasm,
        -- intent on destroying all prey.
        -----------------------------------
        {
            id          = "AC_BOSS_01",
            name        = "The Chasm Sovereign",
            level       = 75,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A thunderous crash echoes up from the deepest part of Attohwa Chasm...",
                "The chasm walls crumble as something vast and ancient forces its way up...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 7

            mobs =
            {
                {
                    base         = { 7, 42 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Sovereign",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                    },
                },
                {
                    base        = { 7, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Dusk Antlion",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 7
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
                    guaranteed = { xi.item.BUGARD_SKIN },
                    bronze = { { xi.item.BUGARD_SKIN,             240 },
                               { xi.item.ANTLION_TRAP,            150 } },
                    silver = { { xi.item.BUGARD_SKIN,             240 },
                               { xi.item.ANTLION_TRAP,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 } },
                    gold   = { { xi.item.BUGARD_SKIN,             240 },
                               { xi.item.ANTLION_TRAP,            200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    200 },
                               { xi.item.BROKEN_IRON_GIANT_GEAR,  100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BUGARD_SKIN,              50 } },
                    gold   = { { xi.item.BUGARD_SKIN,             100 },
                               { xi.item.ANTLION_TRAP,             50 } },
                },
            },
        },
    },
}
