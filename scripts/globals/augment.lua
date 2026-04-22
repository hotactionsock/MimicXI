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
