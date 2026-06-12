-----------------------------------
-- Tier Trial: Lv60 — "The Pso'Xja Ordeal"
--
-- Era: Pso'Xja / Sacrarium / Tavnazia
-- Enemies: Ahriman, Ghosts, Demons
-- Boss: Vraeth the Tetrachromic
--
-- NOTE: mob IDs and instanceId marked TODO — fill from DB after SQL is run
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
            { mobId = 17526824 }, -- Ahriman A
            { mobId = 17526825 }, -- Ahriman B
        },
        [2] =
        {
            { mobId = 17526826 }, -- Haunt A
            { mobId = 17526827 }, -- Haunt B
            { mobId = 17526828 }, -- Specter
        },
        [3] =
        {
            { mobId = 17526829 }, -- Demon Knight A
            { mobId = 17526830 }, -- Demon Knight B
            { mobId = 17526831 }, -- Demon Warlock
        },
        [4] =
        {
            { mobId = 17526832 }, -- Ahriman A
            { mobId = 17526833 }, -- Ahriman B
            { mobId = 17526834 }, -- Demon Knight A
            { mobId = 17526835 }, -- Demon Knight B
        },
        [5] =
        {
            { mobId = 17526836, isBoss = true }, -- Vraeth the Tetrachromic
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
    -- Each threshold cycles to the next weakness in the list
    bossWeaknessCycle = { xi.element.FIRE, xi.element.ICE, xi.element.WIND, xi.element.EARTH },
}
