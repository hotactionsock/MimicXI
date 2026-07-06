-----------------------------------
-- FATE Zone: La Theine Plateau
-- Zone ID: 102
-- Region pool: STARTER_ZULKHEIM
-- Level range: 18-30
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.LA_THEINE_PLATEAU] =
{
    zoneName    = "La_Theine_Plateau",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events =
    {
        -----------------------------------
        -- Orcish War Band
        -- Orcish Stonemen and Fighters push
        -- east from Davoi, harrying travellers
        -- on the road to Jeuno.
        -----------------------------------
        {
            id          = "LT_ORC_01",
            name        = "Orcish War Band",
            level       = 22,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "LT_ORC_02",
            progressVal = 1,

            objective = { type = "kill", count = 10 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 102

            mobs =
            {
                {
                    base        = { 102, 1 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Golem",
                    count       = 6,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
                {
                    base        = { 102, 2 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Fighter",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1000 },
                    silver = { exp = 500  },
                    bronze = { exp = 250  },
                },
                fail =
                {
                    gold   = { exp = 250 },
                    silver = { exp = 125 },
                    bronze = { exp = 60  },
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
                               { xi.item.CHUNK_OF_IRON_ORE,      100 } },
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
        -- Orcish Rearguard
        -- Chains from Orcish War Band.
        -- Orcish Cursemakers and Mesmerizers
        -- arrive to cover the retreat,
        -- pressing deeper into the plateau.
        -----------------------------------
        {
            id          = "LT_ORC_02",
            name        = "Orcish Rearguard",
            level       = 25,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 5 },

            area = { 0, 0, 0, 65 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 102

            mobs =
            {
                {
                    base        = { 102, 3 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Curser",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
                {
                    base        = { 102, 4 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Orcish Hexer",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1100 },
                    silver = { exp = 550  },
                    bronze = { exp = 275  },
                },
                fail =
                {
                    gold   = { exp = 275 },
                    silver = { exp = 135 },
                    bronze = { exp = 65  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,     100 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              100 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     200 },
                               { xi.item.BONE_CHIP,              100 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 } },
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
        -- The Plateau Terror
        -- An enormous Coeurl prowls out of
        -- the highland crags, drawn by the
        -- scent of battle, and begins
        -- stalking anything that moves.
        -----------------------------------
        {
            id          = "LT_BOSS_01",
            name        = "The Plateau Terror",
            level       = 28,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "A low, rumbling growl rolls across La Theine Plateau...",
                "The growl shakes the earth itself - something huge prowls the highland...",
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

            area = { 0, 0, 0, 81 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 102

            mobs =
            {
                {
                    base         = { 102, 5 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name         = string.char(0xA6) .. "Plateau Coeurl",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
                {
                    base        = { 102, 6 },  -- TODO: verify mob_groups (zoneId, groupId)
                    name        = string.char(0xA6) .. "Highland Ram",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
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
                    guaranteed = { xi.item.COEURL_WHISKER },
                    bronze = { { xi.item.BEAST_HIDE,             240 },
                               { xi.item.COEURL_WHISKER,         150 } },
                    silver = { { xi.item.BEAST_HIDE,             240 },
                               { xi.item.COEURL_WHISKER,         200 },
                               { xi.item.CHUNK_OF_IRON_ORE,      150 } },
                    gold   = { { xi.item.COEURL_WHISKER,         200 },
                               { xi.item.BEAST_HIDE,             240 },
                               { xi.item.CHUNK_OF_IRON_ORE,      200 },
                               { xi.item.CLUMP_OF_SHEEP_WOOL,    150 } },
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
        -- Ram Rampage
        -- A herd of Highland Rams stampedes
        -- from the northern crags, driven
        -- south by unseen predators,
        -- scattering camps and blocking roads.
        -----------------------------------
        {
            id          = "LT_RAM_01",
            name        = "Ram Rampage",
            level       = 20,
            duration    = 600,
            chainOnly   = false,
            chainOnWin  = "LT_RAM_02",
            progressVal = 1,

            objective = { type = "kill", count = 9 },

            area = { 0, 0, 0, 70 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 102

            mobs =
            {
                {
                    base        = { 102, 6 },  -- TODO: verify mob_groups (Highland Ram)
                    name        = string.char(0xA6) .. "Highland Ram",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
                {
                    base        = { 102, 7 },  -- TODO: verify mob_groups (Wailing Ram)
                    name        = string.char(0xA6) .. "Wailing Ram",
                    count       = 4,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1000 },
                    silver = { exp = 500  },
                    bronze = { exp = 250  },
                },
                fail =
                {
                    gold   = { exp = 250 },
                    silver = { exp = 125 },
                    bronze = { exp = 60  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.CLUMP_OF_SHEEP_WOOL,     150 } },
                    silver = { { xi.item.CLUMP_OF_SHEEP_WOOL,     200 },
                               { xi.item.RAM_HORN,                100 } },
                    gold   = { { xi.item.CLUMP_OF_SHEEP_WOOL,     200 },
                               { xi.item.RAM_HORN,                150 },
                               { xi.item.WAILING_RAM_HORN,        100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.CLUMP_OF_SHEEP_WOOL,      50 } },
                    gold   = { { xi.item.CLUMP_OF_SHEEP_WOOL,     100 },
                               { xi.item.RAM_HORN,                 50 } },
                },
            },
        },

        -----------------------------------
        -- Ram Lead Stag
        -- Chains from Ram Rampage.
        -- The alpha of the herd turns back
        -- and charges directly at anything
        -- that harmed its kin.
        -----------------------------------
        {
            id          = "LT_RAM_02",
            name        = "Ram Lead Stag",
            level       = 23,
            duration    = 480,
            chainOnly   = true,
            progressVal = 1,

            objective = { type = "kill", count = 4 },

            area = { 0, 0, 0, 60 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 102

            mobs =
            {
                {
                    base        = { 102, 7 },  -- TODO: verify mob_groups (Wailing Ram)
                    name        = string.char(0xA6) .. "Wailing Ram",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
                {
                    base        = { 102, 8 },  -- TODO: verify mob_groups (Rampaging Ram)
                    name        = string.char(0xA6) .. "Rampaging Ram",
                    count       = 2,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1200 },
                    silver = { exp = 600  },
                    bronze = { exp = 300  },
                },
                fail =
                {
                    gold   = { exp = 300 },
                    silver = { exp = 150 },
                    bronze = { exp = 75  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.RAM_HORN,                100 } },
                    silver = { { xi.item.RAM_HORN,                200 },
                               { xi.item.WAILING_RAM_HORN,        100 } },
                    gold   = { { xi.item.RAM_HORN,                200 },
                               { xi.item.WAILING_RAM_HORN,        150 },
                               { xi.item.CLUMP_OF_SHEEP_WOOL,     100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.RAM_HORN,                 50 } },
                    gold   = { { xi.item.RAM_HORN,                100 },
                               { xi.item.WAILING_RAM_HORN,         50 } },
                },
            },
        },

        -----------------------------------
        -- Coeurl Hunt
        -- A pride of plateau Coeurls,
        -- more aggressive than normal,
        -- fans out across the highland
        -- claiming the plateau as their own.
        -----------------------------------
        {
            id          = "LT_COEURL_01",
            name        = "Coeurl Hunt",
            level       = 24,
            duration    = 600,
            chainOnly   = false,
            progressVal = 1,

            objective = { type = "kill", count = 8 },

            area = { 0, 0, 0, 75 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 102

            mobs =
            {
                {
                    base        = { 102, 5 },  -- TODO: verify mob_groups (Plateau Coeurl)
                    name        = string.char(0xA6) .. "Plateau Coeurl",
                    count       = 5,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
                {
                    base        = { 102, 9 },  -- TODO: verify mob_groups (Hill Sapling)
                    name        = string.char(0xA6) .. "Hill Funguar",
                    count       = 3,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 1300 },
                    silver = { exp = 650  },
                    bronze = { exp = 325  },
                },
                fail =
                {
                    gold   = { exp = 325 },
                    silver = { exp = 160 },
                    bronze = { exp = 80  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},
                    bronze = { { xi.item.BEAST_HIDE,              150 } },
                    silver = { { xi.item.BEAST_HIDE,              200 },
                               { xi.item.COEURL_WHISKER,          100 } },
                    gold   = { { xi.item.BEAST_HIDE,              200 },
                               { xi.item.COEURL_WHISKER,          150 },
                               { xi.item.CHUNK_OF_IRON_ORE,       100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,               50 } },
                    gold   = { { xi.item.BEAST_HIDE,              100 },
                               { xi.item.COEURL_WHISKER,           50 } },
                },
            },
        },

        -----------------------------------
        -- The Davoi Warmaster
        -- An elite Orcish Warmaster leads
        -- a crack force of Stonemen directly
        -- across the plateau in a bid to
        -- outflank San d'Oria's outer walls.
        -----------------------------------
        {
            id          = "LT_BOSS_02",
            name        = "The Davoi Warmaster",
            level       = 26,
            duration    = 900,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 5400,
            progressVal = 2,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "Orcish war drums pound a slow, steady beat from the direction of Davoi...",
                "The drumming crescendos and an armoured column bursts into view on the plateau...",
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

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 102

            mobs =
            {
                {
                    base         = { 102, 10 }, -- TODO: verify mob_groups (Orcish Warmaster)
                    name         = string.char(0xA6) .. "Davoi Master",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 8,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
                {
                    base        = { 102, 1 },  -- TODO: verify mob_groups (Orcish Stoneman)
                    name        = string.char(0xA6) .. "Orcish Golem",
                    count       = 4,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
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
                    guaranteed = { xi.item.ORCISH_MAIL_SCALES },
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,      240 },
                               { xi.item.BONE_CHIP,               150 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,      240 },
                               { xi.item.BONE_CHIP,               200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       150 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,      240 },
                               { xi.item.BONE_CHIP,               200 },
                               { xi.item.CHUNK_OF_IRON_ORE,       200 },
                               { xi.item.COEURL_WHISKER,          100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.ORCISH_MAIL_SCALES,       50 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,      100 },
                               { xi.item.BONE_CHIP,                50 } },
                },
            },
        },

        -----------------------------------
        -- The Ancient Stalker
        -- A Coeurl of such advanced age
        -- its fur has turned white as snow,
        -- said to have hunted these highlands
        -- since before the Crystal War.
        -- Spawns rarely. Expect a prolonged hunt.
        -----------------------------------
        {
            id          = "LT_BOSS_03",
            name        = "The Ancient Stalker",
            level       = 32,
            duration    = 1200,
            chainOnly   = false,
            isBoss      = true,
            minCooldown = 14400,
            progressVal = 3,

            objective = { type = "kill", count = 1 },

            bossWarnings =
            {
                "An eerie stillness descends on La Theine Plateau - all other creatures flee...",
                "A white shape moves between the highland stones, crossing the plateau in total silence...",
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

            area = { 0, 0, 0, 110 },

            entryPos = { 0, 0, 0, 0 }, -- TODO: !pos survey 102

            mobs =
            {
                {
                    base         = { 102, 5 },  -- TODO: verify mob_groups (Coeurl)
                    name         = string.char(0xA6) .. "Elder Stalker",
                    count        = 1,
                    isBoss       = true,
                    hpMultiplier = 15,
                    size         = 3,
                    spawnPoints  =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
                {
                    base        = { 102, 5 },  -- TODO: verify mob_groups (Coeurl cubs)
                    name        = string.char(0xA6) .. "Plateau Coeurl",
                    count       = 3,
                    noCount     = true,
                    spawnPoints =
                    {
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                        { 0, 0, 0, 0 }, -- TODO: !pos survey 102
                    },
                },
            },

            rewards =
            {
                victory =
                {
                    gold   = { exp = 5500 },
                    silver = { exp = 2750 },
                    bronze = { exp = 1375 },
                },
                fail =
                {
                    gold   = { exp = 1375 },
                    silver = { exp = 685  },
                    bronze = { exp = 340  },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = { xi.item.COEURL_WHISKER },
                    bronze = { { xi.item.COEURL_WHISKER,          240 },
                               { xi.item.BEAST_HIDE,              200 } },
                    silver = { { xi.item.COEURL_WHISKER,          240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.RAM_HORN,                150 } },
                    gold   = { { xi.item.COEURL_WHISKER,          240 },
                               { xi.item.BEAST_HIDE,              200 },
                               { xi.item.RAM_HORN,                150 },
                               { xi.item.WAILING_RAM_HORN,        150 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,    100 } },
                },
                fail =
                {
                    guaranteed = {},
                    bronze = {},
                    silver = { { xi.item.BEAST_HIDE,               50 } },
                    gold   = { { xi.item.COEURL_WHISKER,          100 },
                               { xi.item.BEAST_HIDE,               50 } },
                },
            },
        },
    },
}
