-----------------------------------
-- Tier Trial: Lv40 — "The Qufim Crucible"
--
-- Era: Qufim Island / Beaucedine / Ranguemont Pass
-- Enemies: Gigas, Wights, Tonberries
-- Boss: Kalabaros the Unbroken
--
-- NOTE: mob IDs and instanceId marked TODO — fill from DB after SQL is run
-----------------------------------

xi = xi or {}
xi.tierTrial = xi.tierTrial or {}
xi.tierTrial.TIERS = xi.tierTrial.TIERS or {}
xi.tierTrial.TIERS[40] =
{
    instanceId = 18302,
    levelCap   = 40,
    label      = 'The Qufim Crucible',

    markVar   = '[TierTrial]QufimMarks',
    shardItem = 3758, -- Tempered Shard

    -- Tier II (Tempered) weapon item IDs per job family
    weapons =
    {
        blade    = 20010, nodachi  = 20011,
        kukri    = 20012, cesti    = 20013,
        rod      = 20014, falchion = 20015,
        sceptre  = 20016, spatha   = 20017,
        kite     = 23937, caligo   = 20011,
    },

    waves =
    {
        [1] =
        {
            { mobId = 17526799 }, -- Gigas Fighter
            { mobId = 17526800 }, -- Gigas Wrestler
        },
        [2] =
        {
            { mobId = 17526801 }, -- Ghoul A
            { mobId = 17526802 }, -- Ghoul B
            { mobId = 17526803 }, -- Wight
        },
        [3] =
        {
            { mobId = 17526804 }, -- Tonberry Tracker
            { mobId = 17526805 }, -- Tonberry Elder
        },
        [4] =
        {
            { mobId = 17526806 }, -- Roc
            { mobId = 17526807 }, -- Gigas Fighter
            { mobId = 17526808 }, -- Gigas Wrestler
        },
        [5] =
        {
            { mobId = 17526809, isBoss    = true }, -- Kalabaros the Unbroken
            { mobId = 17526810, isSummon  = true, spawnAtPct = 33 }, -- Wight summon
        },
    },

    hardenedAura =
    {
        effect   = xi.effect.DEFENSE_DOWN,
        power    = 10,
        duration = 0,
    },

    bossPhaseThreshold = 50,
}
