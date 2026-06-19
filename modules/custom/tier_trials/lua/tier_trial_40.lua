-----------------------------------
-- Tier Trial: Lv40 — "The Qufim Crucible"
--
-- Era: Qufim Island / Beaucedine / Ranguemont Pass
-- Enemies: Gigas, Wights, Tonberries
-- Boss: Kalabaros the Unbroken
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
            { name = 'Gigas Fighter',  groupId = 12014, groupZoneId = 183, level = 38 },
            { name = 'Gigas Wrestler', groupId = 12015, groupZoneId = 183, level = 38 },
        },
        [2] =
        {
            { name = 'Ghoul', groupId = 12016, groupZoneId = 183, level = 38, count = 2 },
            { name = 'Wight', groupId = 12018, groupZoneId = 183, level = 39 },
        },
        [3] =
        {
            { name = 'Tonberry Tracker', groupId = 12019, groupZoneId = 183, level = 38 },
            { name = 'Tonberry Elder',   groupId = 12020, groupZoneId = 183, level = 39 },
        },
        [4] =
        {
            { name = 'Roc',           groupId = 12021, groupZoneId = 183, level = 39 },
            { name = 'Gigas Fighter', groupId = 12014, groupZoneId = 183, level = 40 },
            { name = 'Gigas Wrestler',groupId = 12015, groupZoneId = 183, level = 40 },
        },
        [5] =
        {
            { name = 'Kalabaros the Unbroken', groupId = 12024, groupZoneId = 183, level = 43, isBoss   = true },
            { name = 'Wight Summon',           groupId = 12025, groupZoneId = 183, level = 41, isSummon = true },
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

return {}
