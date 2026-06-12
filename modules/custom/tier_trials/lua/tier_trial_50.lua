-----------------------------------
-- Tier Trial: Lv50 — "The Fauregandi Trial"
--
-- Era: Beaucedine Glacier / Xarcabard / Shadow Lord territory
-- Enemies: Demons, Shadow Beastmen, Elementals, Undead
-- Boss: Valdris the Hollowed
--
-- NOTE: mob IDs and instanceId marked TODO — fill from DB after SQL is run
-----------------------------------

xi.tierTrial.TIERS[50] =
{
    instanceId = 18303,
    levelCap   = 50,
    label      = 'The Fauregandi Trial',

    markVar   = '[TierTrial]FauregandiMarks',
    shardItem = 3759, -- Forged Shard

    weapons =
    {
        greatsword    = 0,
        handtohand    = 0,
        staff_healing = 0,
        staff_magic   = 0,
        sword         = 0,
        dagger        = 0,
        ranged        = 0,
        sword_shield  = 0,
        greatkatana   = 0,
        axe           = 0,
    },

    waves =
    {
        [1] =
        {
            { mobId = 17526811 }, -- Imp A
            { mobId = 17526812 }, -- Imp B
            { mobId = 17526813 }, -- Imp C
        },
        [2] =
        {
            { mobId = 17526814 }, -- Shadow Orc A
            { mobId = 17526815 }, -- Shadow Orc B
            { mobId = 17526816 }, -- Undead Quadav
        },
        [3] =
        {
            { mobId = 17526817 }, -- Fire Elemental
            { mobId = 17526818 }, -- Ice Elemental
        },
        [4] =
        {
            { mobId = 17526819 }, -- Haunt A
            { mobId = 17526820 }, -- Haunt B
            { mobId = 17526821 }, -- Imp A
            { mobId = 17526822 }, -- Imp B
        },
        [5] =
        {
            { mobId = 17526823, isBoss = true }, -- Valdris the Hollowed
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
    -- Instance script reads this and sets appropriate absorb effect on boss
    bossAbsorbCycle = 60000, -- ms between element absorption changes
}
