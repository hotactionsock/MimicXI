-----------------------------------
-- Tier Trial: Lv30 — "The Valkurm Proving"
--
-- Era: Valkurm Dunes / Gustaberg / Konschtat
-- Enemies: Goblins, Orcs, Quadavs
-- Boss: Brakk the Lockjaw
--
-- NOTE: mob IDs and instanceId marked TODO — fill from DB after SQL is run
-----------------------------------

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

    -- Wave definitions — mob IDs match mob_spawn_points entries in tier_trials.sql
    waves =
    {
        [1] =
        {
            { mobId = 17526785 }, -- Goblin Leecher A
            { mobId = 17526786 }, -- Goblin Leecher B
            { mobId = 17526787 }, -- Goblin Bouncer
        },
        [2] =
        {
            { mobId = 17526788 }, -- Orcish Grunt A
            { mobId = 17526789 }, -- Orcish Grunt B
            { mobId = 17526790 }, -- Orcish Cursemaker
        },
        [3] =
        {
            { mobId = 17526791 }, -- Brass Quadav A
            { mobId = 17526792 }, -- Brass Quadav B
            { mobId = 17526793 }, -- Copper Quadav
        },
        [4] =
        {
            { mobId = 17526794 }, -- Goblin Leecher A
            { mobId = 17526795 }, -- Goblin Leecher B
            { mobId = 17526796 }, -- Orcish Grunt A
            { mobId = 17526797 }, -- Orcish Grunt B
        },
        [5] =
        {
            { mobId = 17526798, isBoss = true }, -- Brakk the Lockjaw
        },
    },

    -- Hardened aura effect applied from wave 3 onwards
    -- Applied to all players on wave start via player:addStatusEffect
    hardenedAura =
    {
        effect   = xi.effect.ACCURACY_DOWN,
        power    = 10,
        duration = 0, -- persistent while in wave, removed on wave end
    },

    -- Transcendent mode: boss second phase threshold (% HP)
    bossPhaseThreshold = 50,
}
