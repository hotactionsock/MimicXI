-----------------------------------
-- FATE Zone: Bibiki Bay
-- Zone ID: 4
-- Region pool: KOLSHUSHU_ELSHIMO
-- Level range: 45-65
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BIBIKI_BAY] =
{
    zoneName    = "Bibiki_Bay",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "KOLSHUSHU_ELSHIMO",

    events =
    {
        -----------------------------------
        -- Sahagin Tidal Raid
        -- Sahagin Divers and Priests breach
        -- the bay's shallows in coordinated
        -- raids, threatening boats and the
        -- docks at Purgonorgo Isle.
        -----------------------------------
        {
            id          = "BB_SAHAGIN_01",
            name        = "Sahagin Tidal Raid",
            level       = 52,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "BB_SAHAGIN_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 4

            mobs =
            {
                {
                    base        = { 4, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Sahagin Diver",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                    },
                },
                {
                    base        = { 4, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Sahagin Priest",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3000 },
                    silver = { exp = 1500 },
                    bronze = { exp = 750  },
                },
                fail =
                {
                    gold   = { exp = 750 },
                    silver = { exp = 375 },
                    bronze = { exp = 185 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.FISH_SCALES,             150 } },
                    silver = { { xi.item.FISH_SCALES,             200 },
                               { xi.item.BONE_CHIP,               150 } },
                    gold   = { { xi.item.FISH_SCALES,             200 },
                               { xi.item.BONE_CHIP,               150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.FISH_SCALES,              50 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- Sahagin Strike Force
        -- Chains from Sahagin Tidal Raid.
        -- Sahagin Wavebreakers and a Sea
        -- Marshal answer the raid signal,
        -- emerging en masse from the deep.
        -----------------------------------
        {
            id          = "BB_SAHAGIN_02",
            name        = "Sahagin Strike Force",
            level       = 56,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 4

            mobs =
            {
                {
                    base        = { 4, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Sahagin Raider",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                    },
                },
                {
                    base        = { 4, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Bay Marshal",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 3400 },
                    silver = { exp = 1700 },
                    bronze = { exp = 850  },
                },
                fail =
                {
                    gold   = { exp = 850 },
                    silver = { exp = 425 },
                    bronze = { exp = 210 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.FISH_SCALES,             100 } },
                    silver = { { xi.item.FISH_SCALES,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                    gold   = { { xi.item.FISH_SCALES,             200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    150 },
                               { xi.item.BONE_CHIP,               150 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BONE_CHIP,                50 } },
                    gold   = { { xi.item.FISH_SCALES,              50 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- The Bay Kraken
        -- A monstrous Kraken surfaces in the
        -- centre of Bibiki Bay, its tentacles
        -- sweeping the coastlines and upending
        -- any vessel that comes near.
        -----------------------------------
        {
            id          = "BB_BOSS_01",
            name        = "The Bay Kraken",
            level       = 62,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "The waters of Bibiki Bay begin to spiral in a colossal whirlpool...",
                "Titanic tentacles erupt from the vortex - the Bay Kraken rises...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 4

            mobs =
            {
                {
                    base         = { 4, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Bay Kraken",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                    },
                },
                {
                    base        = { 4, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Bibiki Sahagin",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 4
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 7500 },
                    silver = { exp = 3750 },
                    bronze = { exp = 1875 },
                },
                fail =
                {
                    gold   = { exp = 1875 },
                    silver = { exp = 935  },
                    bronze = { exp = 465  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.TENTACLE },
                    bronze = { { xi.item.FISH_SCALES,             240 },
                               { xi.item.TENTACLE,               150 } },
                    silver = { { xi.item.FISH_SCALES,             240 },
                               { xi.item.TENTACLE,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 } },
                    gold   = { { xi.item.FISH_SCALES,             240 },
                               { xi.item.TENTACLE,               200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 },
                               { xi.item.BONE_CHIP,              200 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.FISH_SCALES,              50 } },
                    gold   = { { xi.item.FISH_SCALES,             100 },
                               { xi.item.TENTACLE,                50 } },
                },
            },
        },
    },
}
