-----------------------------------
-- FATE Zone: Batallia Downs
-- Zone ID: 105
-- Region pool: NORVALLEN_QUFIM
-- Level range: 30-40
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BATALLIA_DOWNS] =
{
    zoneName    = "Batallia_Downs",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORVALLEN_QUFIM",

    events =
    {
        -----------------------------------
        -- Orcish Skirmish Line
        -- Orcish Warriors and Serjeants
        -- advance across the open downs
        -- in a disciplined battle formation,
        -- pressing toward Jeuno.
        -----------------------------------
        {
            id          = "BD_ORC_01",
            name        = "Orcish Skirmish Line",
            level       = 34,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area =
            {
                x      = 0,   -- TODO: !pos survey
                y      = 0,   -- TODO: !pos survey
                z      = 0,   -- TODO: !pos survey
                radius = 80,
            },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 105

            mobs =
            {
                {
                    base        = { 105, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Warrior",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                    },
                },
                {
                    base        = { 105, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Veteran",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
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
        -- The Downs Ravager
        -- A wild Dhalmel of extraordinary
        -- size stampedes across the open
        -- downs, its territorial charge
        -- trampling everything in its path.
        -----------------------------------
        {
            id          = "BD_BOSS_01",
            name        = "The Downs Ravager",
            level       = 38,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The ground shakes with heavy, rhythmic impacts on the Batallia Downs...",
                "A monstrous silhouette crests the hills — the downs themselves seem to flee before it...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 105

            mobs =
            {
                {
                    base         = { 105, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Downs Ravager",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                    },
                },
                {
                    base        = { 105, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Downs Raptor",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3800 },
                    silver = { exp = 1900 },
                    bronze = { exp = 950  },
                },
                fail =
                {
                    gold   = { exp = 950 },
                    silver = { exp = 475 },
                    bronze = { exp = 235 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.DHALMEL_HIDE },
                    bronze = { { xi.item.DHALMEL_HIDE,           240 },
                               { xi.item.BEAST_HIDE,             150 } },
                    silver = { { xi.item.DHALMEL_HIDE,           240 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 } },
                    gold   = { { xi.item.DHALMEL_HIDE,           240 },
                               { xi.item.BEAST_HIDE,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 },
                               { xi.item.ORCISH_MAIL_SCALES,     100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.DHALMEL_HIDE,            50 } },
                    gold   = { { xi.item.DHALMEL_HIDE,           100 },
                               { xi.item.BEAST_HIDE,              50 } },
                },
            },
        },
    },
}
