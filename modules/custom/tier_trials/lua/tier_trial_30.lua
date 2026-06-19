-----------------------------------
-- Tier Trial: Lv30 — "The Valkurm Proving"
--
-- Era: Valkurm Dunes / Gustaberg / Konschtat
-- Enemies: Goblins, Orcs, Quadavs
-- Boss: Brakk the Lockjaw
--
-- groupId / groupZoneId reference mob_groups entries in zone 183.
-- instance_entities rows are NOT required; mobs are created dynamically
-- via instance:insertDynamicEntity in onInstanceCreated.
-----------------------------------

xi = xi or {}
xi.tierTrial = xi.tierTrial or {}
xi.tierTrial.TIERS = xi.tierTrial.TIERS or {}
xi.tierTrial.TIERS[30] =
{
    instanceId = 18301,
    levelCap   = 30,
    label      = 'The Valkurm Proving',

    markVar   = '[TierTrial]ValkurumMarks',
    shardItem = 3757, -- Nascent Shard

    -- Tier I (Nascent) weapon item IDs per job family
    weapons =
    {
        blade    = 20001, nodachi  = 20002,
        kukri    = 20003, cesti    = 20004,
        rod      = 20005, falchion = 20006,
        sceptre  = 20007, spatha   = 20008,
        kite     = 23936, caligo   = 20002,
    },

    -- Wave definitions using dynamic entity fields:
    --   name        : display name sent to client
    --   groupId     : mob_groups.groupid (zone 183)
    --   groupZoneId : mob_groups.zoneid (always 183 for tier trial templates)
    --   level       : spawned level (overrides group default)
    --   count       : number of this mob to create (default 1)
    --   isBoss      : true → onMobDeath calls instance:complete()
    waves =
    {
        [1] =
        {
            { name = 'Goblin Leecher',  groupId = 12000, groupZoneId = 183, level = 28, count = 2 },
            { name = 'Goblin Bouncer',  groupId = 12002, groupZoneId = 183, level = 29 },
        },
        [2] =
        {
            { name = 'Orcish Grunt',      groupId = 12003, groupZoneId = 183, level = 28, count = 2 },
            { name = 'Orcish Cursemaker', groupId = 12005, groupZoneId = 183, level = 29 },
        },
        [3] =
        {
            { name = 'Brass Quadav',  groupId = 12006, groupZoneId = 183, level = 28, count = 2 },
            { name = 'Copper Quadav', groupId = 12008, groupZoneId = 183, level = 29 },
        },
        [4] =
        {
            { name = 'Goblin Leecher', groupId = 12000, groupZoneId = 183, level = 29, count = 2 },
            { name = 'Orcish Grunt',   groupId = 12003, groupZoneId = 183, level = 29, count = 2 },
        },
        [5] =
        {
            { name = 'Brakk the Lockjaw', groupId = 12013, groupZoneId = 183, level = 32, isBoss = true, size = 3,},
        },
    },

    -- Hardened aura effect applied from wave 3 onwards
    hardenedAura =
    {
        effect   = xi.effect.ACCURACY_DOWN,
        power    = 10,
        duration = 0,
    },

    -- Transcendent mode: boss second phase threshold (% HP)
    bossPhaseThreshold = 50,
}

return {}
