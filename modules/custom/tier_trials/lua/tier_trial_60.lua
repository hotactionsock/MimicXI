-----------------------------------
-- Tier Trial: Lv60 — "The Pso'Xja Ordeal"
--
-- Era: Pso'Xja / Sacrarium / Tavnazia
-- Enemies: Ahriman, Ghosts, Demons
-- Boss: Vraeth the Tetrachromic
-----------------------------------

xi = xi or {}
xi.tierTrial = xi.tierTrial or {}
xi.tierTrial.TIERS = xi.tierTrial.TIERS or {}
xi.tierTrial.TIERS[60] =
{
    instanceId = 18304,
    levelCap   = 60,
    label      = "The Pso'Xja Ordeal",

    markVar   = '[TierTrial]PsoxjaMarks',
    shardItem = 3760, -- Resolute Shard

    -- Tier IV (Resolute) weapon item IDs per job family
    weapons =
    {
        blade    = 20028, nodachi  = 20029,
        kukri    = 20030, cesti    = 20031,
        rod      = 20032, falchion = 20033,
        sceptre  = 20034, spatha   = 20035,
        kite     = 23939, caligo   = 20029,
    },

    waves =
    {
        [1] =
        {
            { name = 'Ahriman', groupId = 12039, groupZoneId = 183, level = 58, count = 2 },
        },
        [2] =
        {
            { name = 'Haunt',   groupId = 12041, groupZoneId = 183, level = 58, count = 2 },
            { name = 'Specter', groupId = 12043, groupZoneId = 183, level = 59 },
        },
        [3] =
        {
            { name = 'Demon Knight',   groupId = 12044, groupZoneId = 183, level = 58, count = 2 },
            { name = 'Demon Warlock',  groupId = 12046, groupZoneId = 183, level = 59 },
        },
        [4] =
        {
            { name = 'Ahriman',      groupId = 12039, groupZoneId = 183, level = 59, count = 2 },
            { name = 'Demon Knight', groupId = 12044, groupZoneId = 183, level = 59, count = 2 },
        },
        [5] =
        {
            { name = 'Vraeth the Tetrachromic', groupId = 12051, groupZoneId = 183, level = 64, isBoss = true },
        },
    },

    hardenedAura =
    {
        effect   = xi.effect.MAGIC_DEF_DOWN,
        power    = 10,
        duration = 0,
    },

    bossPhaseThreshold = 20,

    -- Vraeth weakness changes at these HP% thresholds: 80 / 60 / 40 / 20
    bossWeaknessCycle = { xi.element.FIRE, xi.element.ICE, xi.element.WIND, xi.element.EARTH },
}

return {}
