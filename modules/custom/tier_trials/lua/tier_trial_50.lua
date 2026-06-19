-----------------------------------
-- Tier Trial: Lv50 — "The Fauregandi Trial"
--
-- Era: Beaucedine Glacier / Xarcabard / Shadow Lord territory
-- Enemies: Demons, Shadow Beastmen, Elementals, Undead
-- Boss: Valdris the Hollowed
-----------------------------------

xi = xi or {}
xi.tierTrial = xi.tierTrial or {}
xi.tierTrial.TIERS = xi.tierTrial.TIERS or {}
xi.tierTrial.TIERS[50] =
{
    instanceId = 18303,
    levelCap   = 50,
    label      = 'The Fauregandi Trial',

    markVar   = '[TierTrial]FauregandiMarks',
    shardItem = 3759, -- Forged Shard

    -- Tier III (Forged) weapon item IDs per job family
    weapons =
    {
        blade    = 20019, nodachi  = 20020,
        kukri    = 20021, cesti    = 20022,
        rod      = 20023, falchion = 20024,
        sceptre  = 20025, spatha   = 20026,
        kite     = 23938, caligo   = 20020,
    },

    waves =
    {
        [1] =
        {
            { name = 'Imp', groupId = 12026, groupZoneId = 183, level = 48, count = 3 },
        },
        [2] =
        {
            { name = 'Shadow Orc',    groupId = 12029, groupZoneId = 183, level = 48, count = 2 },
            { name = 'Undead Quadav', groupId = 12031, groupZoneId = 183, level = 48 },
        },
        [3] =
        {
            { name = 'Fire Elemental', groupId = 12032, groupZoneId = 183, level = 48 },
            { name = 'Ice Elemental',  groupId = 12033, groupZoneId = 183, level = 48 },
        },
        [4] =
        {
            { name = 'Haunt', groupId = 12034, groupZoneId = 183, level = 49, count = 2 },
            { name = 'Imp',   groupId = 12026, groupZoneId = 183, level = 49, count = 2 },
        },
        [5] =
        {
            { name = 'Valdris the Hollowed', groupId = 12038, groupZoneId = 183, level = 54, isBoss = true },
        },
    },

    hardenedAura =
    {
        effect   = xi.effect.MAGIC_ATK_DOWN,
        power    = 10,
        duration = 0,
    },

    bossPhaseThreshold = 25,

    -- Valdris absorbs a random element at fight start (cycled every 60s)
    bossAbsorbCycle = 60000,
}

return {}
