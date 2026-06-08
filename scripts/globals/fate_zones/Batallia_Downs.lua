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

            area = { 0, 0, 0, 80 },

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

            area = { 0, 0, 0, 88 },

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
        -----------------------------------
        -- The Eternal Warlord
        -- An ancient Orcish commander sealed
        -- beneath Batallia Downs rises when
        -- enough blood has been spilled on the
        -- field above. Only a coordinated
        -- force of seasoned adventurers can
        -- end the threat before enrage.
        -----------------------------------
        {
            id             = "BD_SUPER_01",
            name           = "The Eternal Warlord",
            superboss      = true,
            noSync         = true,     -- level 75 tuned; no restriction applied
            level          = 75,
            duration       = 3600,     -- 1-hour hard cap
            chainOnly      = false,
            progressVal    = 5,

            globalCooldown = 259200,   -- 3-day server-wide cooldown after kill
            killCooldown   = 259200,   -- 3-day personal loot lockout per character
            prereqs        = { "BD_ORC_01", "BD_BOSS_01" },
            prereqWindow   = 172800,   -- both must have been cleared within 48 hours

            ragePerDeath   = 3,        -- each registered player death = +3% boss damage
            rageCap        = 60,       -- caps at +60% (20 deaths)
            enrageTime     = 1800,     -- 30 min from first pull before enrage

            worldBroadcast = "An ancient evil stirs in Batallia Downs — the Eternal Warlord rises once more! Adventurers are called to arms!",

            bossWarnings =
            {
                "The distant sound of war drums echoes across Batallia Downs...",
                "The war drums grow deafening. Something vast stirs beneath the hills...",
                "The Eternal Warlord has broken free of his tomb! Muster at once!",
            },

            area     = { 0, 0, 0, 200 }, -- TODO: !pos survey 105 (large radius for 30-40 player fight)
            entryPos = { 0, 0, 0, 0 },   -- TODO: !pos survey 105

            phases =
            {
                {
                    hpPct     = 75,
                    onTrigger = function(mob, zoneID, eventIdx)
                        local zone = GetZone(zoneID)
                        if not zone then return end
                        for _, p in pairs(zone:getPlayers()) do
                            p:printToPlayer("[FATE] The Eternal Warlord bellows — reinforcements pour onto the field!", xi.msg.channel.SYSTEM_3)
                        end
                    end,
                },
                {
                    hpPct     = 50,
                    onTrigger = function(mob, zoneID, eventIdx)
                        local zone = GetZone(zoneID)
                        if not zone then return end
                        for _, p in pairs(zone:getPlayers()) do
                            p:printToPlayer("[FATE] Bloodied but unbroken — the Warlord's attacks grow reckless and savage!", xi.msg.channel.SYSTEM_3)
                        end
                    end,
                },
                {
                    hpPct     = 25,
                    onTrigger = function(mob, zoneID, eventIdx)
                        -- Sudden rage spike at the brink of death.
                        xi.fate.addRage(zoneID, eventIdx, 5)
                        local zone = GetZone(zoneID)
                        if not zone then return end
                        for _, p in pairs(zone:getPlayers()) do
                            p:printToPlayer("[FATE] The Eternal Warlord burns with desperate fury — finish him now!", xi.msg.channel.SYSTEM_3)
                        end
                    end,
                },
            },

            waves =
            {
                -----------------------------------
                -- Wave 1 — Orcish Vanguard
                -- Fast shock troops that swarm
                -- before the main force arrives.
                -----------------------------------
                {
                    announcement = "Orcish Vanguard — the advance guard charges!",
                    mobs =
                    {
                        {
                            base        = { 105, 1 },  -- TODO: verify mob_groups
                            name        = string.char(0xA6) .. "Orcish Vanguard",
                            count       = 12,
                            targetHP    = 12000,
                            targetDmg   = 180,
                            spawnPoints =
                            {
                                { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                            },
                        },
                    },
                },
                -----------------------------------
                -- Wave 2 — Warlord's Elite Guard
                -- Veteran champions; tougher and
                -- more organised than the rabble.
                -----------------------------------
                {
                    announcement = "Elite Guard — the Warlord's champions take the field!",
                    mobs =
                    {
                        {
                            base        = { 105, 2 },  -- TODO: verify mob_groups
                            name        = string.char(0xA6) .. "Orcish Veteran Guard",
                            count       = 6,
                            targetHP    = 35000,
                            targetDmg   = 220,
                            spawnPoints =
                            {
                                { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                                { 0, 0, 0, 0 },
                            },
                        },
                    },
                },
                -----------------------------------
                -- Wave 3 — The Eternal Warlord
                -- The boss himself. All prior
                -- waves must be cleared first.
                -----------------------------------
                {
                    announcement = "The Eternal Warlord himself descends upon you!",
                    mobs =
                    {
                        {
                            base        = { 105, 3 },  -- TODO: verify mob_groups
                            name        = string.char(0xA6) .. "The Eternal Warlord",
                            count       = 1,
                            isBoss      = true,
                            targetHP    = 800000,
                            targetDmg   = 350,
                            size        = 3,
                            spawnPoints =
                            {
                                { 0, 0, 0, 0 }, -- TODO: !pos survey 105
                            },
                        },
                    },
                },
            },

            tombstone        = true,
            participationItem = xi.item.ORCISH_MAIL_SCALES,  -- TODO: replace with unique superboss item

            onVictory = function(zoneID)
                -- Victory ripple: boost nearby regular FATEs for 4 hours.
                SetServerVariable(string.format("[SBOSS][%d]VictoryBonus", zoneID), GetSystemTime() + 14400)
                local zone = GetZone(zoneID)
                if not zone then return end
                for _, p in pairs(zone:getPlayers()) do
                    p:printToPlayer("[FATE] The Eternal Warlord has been slain! A boon descends upon Batallia Downs.", xi.msg.channel.SYSTEM_3)
                end
            end,

            onFailure = function(zoneID)
                -- Failure penalty: suppress regular FATE bonuses for 2 hours.
                SetServerVariable(string.format("[SBOSS][%d]FailurePenalty", zoneID), GetSystemTime() + 7200)
                local zone = GetZone(zoneID)
                if not zone then return end
                for _, p in pairs(zone:getPlayers()) do
                    p:printToPlayer("[FATE] The Eternal Warlord vanishes into the hills, leaving devastation in its wake...", xi.msg.channel.SYSTEM_3)
                end
            end,

            rewards =
            {
                victory =
                {
                    gold   = { exp = 20000 },
                    silver = { exp = 10000 },
                    bronze = { exp =  5000 },
                },
                fail =
                {
                    gold   = { exp = 5000 },
                    silver = { exp = 2500 },
                    bronze = { exp = 1250 },
                },
            },

            loot =
            {
                victory =
                {
                    guaranteed = {},  -- TODO: add unique superboss drop
                    bronze = { { xi.item.ORCISH_MAIL_SCALES,     240 },
                               { xi.item.BONE_CHIP,              150 } },
                    silver = { { xi.item.ORCISH_MAIL_SCALES,     240 },
                               { xi.item.BONE_CHIP,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   150 } },
                    gold   = { { xi.item.ORCISH_MAIL_SCALES,     240 },
                               { xi.item.BONE_CHIP,              200 },
                               { xi.item.CHUNK_OF_MYTHRIL_ORE,   200 },
                               { xi.item.DHALMEL_HIDE,           150 } },
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
    },
}
