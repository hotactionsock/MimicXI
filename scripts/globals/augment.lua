-----------------------------------
-- Augment utility globals
--
-- Provides named constants for augment IDs (keyed from sql/augments.sql)
-- and documents the augment pool format used by xi.caskets.augmentPools.
--
-- AUGMENT POOL FORMAT
-- -------------------
-- xi.caskets.augmentPools is a table keyed by item ID.  Each entry is an
-- array of potential augments; the casket system picks 1–2 at random when
-- handing out a Gold-casket item:
--
--   xi.caskets.augmentPools[itemId] =
--   {
--       { id = xi.augments.id.STR,      min = 1, max = 2 },
--       { id = xi.augments.id.ACCURACY, min = 1, max = 3 },
--       ...
--   }
--
-- id  – augment ID from sql/augments.sql (use xi.augments.id.* constants)
-- min – minimum rolled value (inclusive)
-- max – maximum rolled value (inclusive)
--
-- The pool is applied inside giveRareItem() in scripts/globals/caskets.lua.
-- Modules that want to add augments to casket loot should populate
-- xi.caskets.augmentPools at module load time (not in a callback) so the
-- data survives lazy re-execution of casket_loot.lua.
-----------------------------------
xi         = xi or {}
xi.augments = xi.augments or {}

-----------------------------------
-- Named augment ID constants
-- Source: sql/augments.sql
-- Each ID corresponds to one row (or compound row) in the augments table.
-----------------------------------
xi.augments.id =
{
    -- Combat stats
    HP              =  1,  -- HP+1
    MP              =  9,  -- MP+1
    ACCURACY        = 23,  -- Accuracy+1
    ATTACK          = 25,  -- Attack+1
    RANGED_ACCURACY = 27,  -- Rng.Acc.+1
    RANGED_ATTACK   = 29,  -- Rng.Atk.+1
    EVASION         = 31,  -- Evasion+1
    DEFENSE         = 33,  -- DEF+1
    MAG_ACCURACY    = 35,  -- Mag.Acc.+1
    MAG_EVASION     = 37,  -- Mag.Evasion+1
    ENMITY          = 39,  -- Enmity+1
    CRIT_HIT_RATE   = 41,  -- Crit.hit rate+1%
    STORE_TP        = 44,  -- Store TP+1
    DMG             = 45,  -- DMG:+1  (weapons only; displays +1 higher than stored value)
    HASTE           = 49,  -- Haste+1%

    -- Base attributes
    STR             = 512, -- STR+1
    DEX             = 513, -- DEX+1
    VIT             = 514, -- VIT+1
    AGI             = 515, -- AGI+1
    INT             = 516, -- INT+1
    MND             = 517, -- MND+1
    CHR             = 518, -- CHR+1
}

-- Reverse lookup: augment ID → display name used in Gold Casket preview messages.
-- Plain names (no embedded +/-) display as 'Name+N' (e.g. STR+3).
-- Compound names (containing + or -) display as 'Name ×N' when N > 1.
xi.augments.name =
{
    -- Single-stat augments (plain name → 'Name+N' format)
    [1]   = 'HP',
    [9]   = 'MP',
    [23]  = 'Accuracy',
    [25]  = 'Attack',
    [27]  = 'Rng.Acc.',
    [29]  = 'Rng.Atk.',
    [31]  = 'Evasion',
    [33]  = 'DEF',
    [35]  = 'Mag.Acc.',
    [37]  = 'Mag.Evasion',
    [39]  = 'Enmity',
    [41]  = 'Crit.hit rate',
    [44]  = 'Store TP',
    [45]  = 'DMG',
    [49]  = 'Haste',
    [78]  = 'HP',
    [79]  = 'HP',
    [82]  = 'MP',
    [83]  = 'MP',
    [133] = 'Mag.Atk.Bns.',
    [134] = 'Mag.Def.Bns.',
    [137] = 'Regen',
    [138] = 'Refresh',
    [140] = 'Fast Cast',
    [141] = 'Conserve MP',
    [142] = 'Store TP',
    [143] = 'Dbl.Atk.',
    [144] = 'Triple Atk.',
    [145] = 'Counter',
    [146] = 'Dual Wield',
    [147] = 'Treasure Hunter',
    [195] = 'Subtle Blow',
    [211] = 'Snapshot',
    [327] = 'WS damage',
    [328] = 'Crit.hit damage',
    [329] = 'Cure potency',
    [333] = 'Conserve TP',
    [354] = 'Quad.Atk.',
    [362] = 'Magic Damage',
    [512] = 'STR',
    [513] = 'DEX',
    [514] = 'VIT',
    [515] = 'AGI',
    [516] = 'INT',
    [517] = 'MND',
    [518] = 'CHR',

    -- Directional/compound augments (name contains +/- → 'Name ×N' format)
    [17]  = 'HP+1 MP+1',
    [19]  = 'HP+1 MP-1',
    [21]  = 'HP-1 MP+1',
    [54]  = 'Phys.dmg.taken-1%',
    [55]  = 'Magic dmg.taken-1%',
    [68]  = 'Acc+1 Atk+1',
    [69]  = 'Rng.Acc.+1 Rng.Atk.+1',
    [80]  = 'Mag.Acc.+1 Mag.Dmg.+1',
    [129] = 'Acc+1 Rng.Acc.+1',
    [130] = 'Atk+1 Rng.Atk.+1',
    [131] = 'Mag.Acc.+1 Mag.Atk.Bns.+1',
    [132] = 'Dbl.Atk.+1% Crit.+1%',
    [320] = 'BP delay-1',
    [321] = 'Avatar perp.cost-1',
    -- Dual stat bonuses
    [550] = 'STR+1 DEX+1',
    [551] = 'STR+1 VIT+1',
    [552] = 'STR+1 AGI+1',
    [553] = 'DEX+1 AGI+1',
    [554] = 'INT+1 MND+1',
    [555] = 'MND+1 CHR+1',
    [556] = 'INT+1 MND+1 CHR+1',
    [557] = 'STR+1 CHR+1',
    [558] = 'STR+1 INT+1',
    [559] = 'STR+1 MND+1',
    -- Stat trade-offs (one stat up, two down)
    [526] = 'STR+1 DEX-1 VIT-1',
    [527] = 'STR+1 DEX-1 AGI-1',
    [528] = 'STR+1 VIT-1 AGI-1',
    [529] = 'STR-1 DEX+1 VIT-1',
    [530] = 'STR-1 DEX+1 AGI-1',
    [531] = 'DEX+1 VIT-1 AGI-1',
    [532] = 'STR-1 DEX-1 VIT+1',
    [533] = 'STR-1 VIT+1 AGI-1',
    [534] = 'DEX-1 VIT+1 AGI-1',
    [535] = 'STR-1 DEX-1 AGI+1',
    [536] = 'STR-1 VIT-1 AGI+1',
    [537] = 'DEX-1 VIT-1 AGI+1',
    [538] = 'AGI+1 INT-1 MND-1',
    [539] = 'AGI+1 INT-1 CHR-1',
    [540] = 'AGI+1 MND-1 CHR-1',
    [541] = 'AGI-1 INT+1 MND-1',
    [542] = 'AGI-1 INT+1 CHR-1',
    [543] = 'INT+1 MND-1 CHR-1',
    [544] = 'AGI-1 INT-1 MND+1',
    [545] = 'AGI-1 MND+1 CHR-1',
    [546] = 'INT-1 MND+1 CHR-1',
    [547] = 'AGI-1 INT-1 CHR+1',
    [548] = 'AGI-1 MND-1 CHR+1',
    [549] = 'INT-1 MND-1 CHR+1',
}
