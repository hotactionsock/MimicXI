-----------------------------------
-- Module: casket_augment_tiers
--
-- Implements a 7-tier augment system for Gold (rare) caskets across all
-- 60 casket-active zones.  Tiers are determined by zone level bracket:
--
--   Tier 1  lv  1-15   (starter zones — pools set by casket_loot_starter_zones)
--   Tier 2  lv 15-30
--   Tier 3  lv 30-45
--   Tier 4  lv 45-60
--   Tier 5  lv 60-70
--   Tier 6  lv 70-75
--   Tier 7  lv 75+     (endgame)
--
-- Each tier defines:
--   augChances  – probability (%) that each augment slot fires, evaluated
--                 sequentially; once a slot misses, no further slots are
--                 attempted.  Maximum 4 augments per item.
--   pool        – eligible augment entries {id, min, max} built from
--                 augmentDefs at module-load time.
--
-- Per-item entries in xi.caskets.augmentPools (set by other modules) take
-- priority over the tier pool for augment selection, while the tier's
-- augChances always govern how many slots are rolled.
--
-- Rare item pools (HQ gear per tier) and zone assignments are added in
-- subsequent commits.
-----------------------------------
require('modules/module_utils')

local m = Module:new('casket_augment_tiers')

xi         = xi or {}
xi.caskets = xi.caskets or {}

-----------------------------------
-- Augment master definitions
--
-- Format: { id = N, min = M, maxes = { T1, T2, T3, T4, T5, T6, T7 } }
-- A value of 0 means the augment is not available at that tier.
-- Values are intended display values; giveRareItem subtracts 1 before
-- passing to player:addItem (addItem value field = display - 1).
-----------------------------------
local augmentDefs =
{
    -----------------------------------
    -- Basic combat stats (Tier 1+)
    -----------------------------------
    { id = 23,  min = 1, maxes = {  2,  3,  4,  5,  7,  9, 10 } }, -- Accuracy+1
    { id = 25,  min = 1, maxes = {  2,  3,  4,  5,  7,  9, 10 } }, -- Attack+1
    { id = 31,  min = 1, maxes = {  2,  3,  4,  5,  7,  9, 10 } }, -- Evasion+1
    { id = 35,  min = 1, maxes = {  2,  3,  4,  5,  7,  9, 10 } }, -- Mag.Acc.+1
    { id = 41,  min = 1, maxes = {  2,  3,  4,  5,  6,  8, 10 } }, -- Crit.hit rate+1%
    { id = 44,  min = 1, maxes = {  1,  2,  3,  4,  5,  6,  7 } }, -- Store TP+1 / Subtle Blow+1

    -----------------------------------
    -- Base attributes (Tier 1+)
    -----------------------------------
    { id = 512, min = 1, maxes = {  1,  2,  3,  4,  5,  6,  7 } }, -- STR+1
    { id = 513, min = 1, maxes = {  1,  2,  3,  4,  5,  6,  7 } }, -- DEX+1
    { id = 514, min = 1, maxes = {  1,  2,  3,  4,  5,  6,  7 } }, -- VIT+1
    { id = 515, min = 1, maxes = {  1,  2,  3,  4,  5,  6,  7 } }, -- AGI+1
    { id = 516, min = 1, maxes = {  1,  2,  3,  4,  5,  6,  7 } }, -- INT+1
    { id = 517, min = 1, maxes = {  1,  2,  3,  4,  5,  6,  7 } }, -- MND+1

    -----------------------------------
    -- HP/MP, ranged and combo stats (Tier 2+)
    -----------------------------------
    { id = 17,  min = 1, maxes = {  0,  3,  5,  7, 10, 13, 15 } }, -- HP+1 MP+1
    { id = 19,  min = 1, maxes = {  0,  3,  5,  7, 10, 13, 15 } }, -- HP+1 MP-1
    { id = 21,  min = 1, maxes = {  0,  3,  5,  7, 10, 13, 15 } }, -- HP-1 MP+1
    { id = 27,  min = 1, maxes = {  0,  2,  3,  4,  6,  8, 10 } }, -- Rng.Acc.+1
    { id = 29,  min = 1, maxes = {  0,  2,  3,  4,  6,  8, 10 } }, -- Rng.Atk.+1
    { id = 37,  min = 1, maxes = {  0,  2,  3,  4,  6,  8, 10 } }, -- Mag.Evasion+1
    { id = 68,  min = 1, maxes = {  0,  2,  3,  4,  6,  8,  9 } }, -- Acc+1 Atk+1
    { id = 69,  min = 1, maxes = {  0,  2,  3,  4,  6,  8,  9 } }, -- Rng.Acc.+1 Rng.Atk.+1
    { id = 78,  min = 1, maxes = {  0,  3,  5,  7, 10, 13, 15 } }, -- HP+2 per unit
    { id = 82,  min = 1, maxes = {  0,  3,  5,  7, 10, 13, 15 } }, -- MP+2 per unit
    { id = 129, min = 1, maxes = {  0,  2,  3,  4,  6,  8,  9 } }, -- Acc+1 Rng.Acc.+1
    { id = 130, min = 1, maxes = {  0,  2,  3,  4,  6,  8,  9 } }, -- Atk+1 Rng.Atk.+1
    { id = 131, min = 1, maxes = {  0,  2,  3,  4,  6,  8,  9 } }, -- Mag.Acc.+1 Mag.Atk.Bns.+1
    { id = 195, min = 1, maxes = {  0,  2,  3,  4,  5,  6,  7 } }, -- Subtle Blow+1

    -----------------------------------
    -- Defensive and magic utilities (Tier 3+)
    -----------------------------------
    { id = 54,  min = 1, maxes = {  0,  0,  3,  4,  5,  6,  7 } }, -- Phys. dmg. taken -1%
    { id = 55,  min = 1, maxes = {  0,  0,  3,  4,  5,  6,  7 } }, -- Magic dmg. taken -1%
    { id = 79,  min = 1, maxes = {  0,  0,  3,  5,  8, 11, 15 } }, -- HP+3 per unit
    { id = 80,  min = 1, maxes = {  0,  0,  3,  4,  6,  8,  9 } }, -- Mag.Acc.+1 Mag.Dmg+1
    { id = 83,  min = 1, maxes = {  0,  0,  3,  5,  8, 11, 15 } }, -- MP+3 per unit
    { id = 132, min = 1, maxes = {  0,  0,  2,  3,  4,  5,  6 } }, -- Dbl.Atk.+1% Crit.hit rate+1%
    { id = 133, min = 1, maxes = {  0,  0,  3,  4,  6,  8,  9 } }, -- Mag.Atk.Bns.+1
    { id = 134, min = 1, maxes = {  0,  0,  3,  4,  6,  8,  9 } }, -- Mag.Def.Bns.+1
    { id = 137, min = 1, maxes = {  0,  0,  2,  3,  4,  5,  5 } }, -- Regen+1
    { id = 138, min = 1, maxes = {  0,  0,  1,  1,  2,  2,  2 } }, -- Refresh+1
    { id = 140, min = 1, maxes = {  0,  0,  3,  4,  5,  7, 10 } }, -- Fast Cast+1%
    { id = 141, min = 1, maxes = {  0,  0,  3,  4,  5,  7,  9 } }, -- Conserve MP+1
    { id = 142, min = 1, maxes = {  0,  0,  2,  3,  4,  5,  6 } }, -- Store TP+1
    { id = 143, min = 1, maxes = {  0,  0,  2,  3,  4,  5,  6 } }, -- Dbl.Atk.+1%

    -----------------------------------
    -- Tier 4+ augments
    -----------------------------------
    { id = 49,  min = 1, maxes = {  0,  0,  0,  2,  2,  3,  3 } }, -- Haste+1%
    { id = 144, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- Triple Atk.+1%
    { id = 146, min = 1, maxes = {  0,  0,  0,  3,  4,  5,  6 } }, -- Dual Wield+1
    { id = 147, min = 1, maxes = {  0,  0,  0,  1,  1,  2,  2 } }, -- Treasure Hunter+1
    { id = 211, min = 1, maxes = {  0,  0,  0,  3,  5,  7, 10 } }, -- Snapshot+1
    { id = 327, min = 1, maxes = {  0,  0,  0,  3,  5,  7,  9 } }, -- Weapon skill damage+1%
    { id = 328, min = 1, maxes = {  0,  0,  0,  3,  5,  7,  9 } }, -- Crit. hit damage+1%
    { id = 329, min = 1, maxes = {  0,  0,  0,  3,  5,  7,  9 } }, -- Cure potency+1%
    { id = 333, min = 1, maxes = {  0,  0,  0,  3,  4,  5,  6 } }, -- Conserve TP+1
    -- Dual stat combos
    { id = 550, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- STR+1 DEX+1
    { id = 551, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- STR+1 VIT+1
    { id = 552, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- STR+1 AGI+1
    { id = 553, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- DEX+1 AGI+1
    { id = 554, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- INT+1 MND+1
    { id = 555, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- MND+1 CHR+1
    { id = 556, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- INT+1 MND+1 CHR+1
    { id = 557, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- STR+1 CHR+1
    { id = 558, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- STR+1 INT+1
    { id = 559, min = 1, maxes = {  0,  0,  0,  2,  3,  4,  5 } }, -- STR+1 MND+1

    -----------------------------------
    -- Tier 5+ augments
    -----------------------------------
    { id = 145, min = 1, maxes = {  0,  0,  0,  0,  4,  6,  8 } }, -- Counter+1
    { id = 354, min = 1, maxes = {  0,  0,  0,  0,  2,  3,  3 } }, -- Quadruple Attack+1%
    { id = 362, min = 1, maxes = {  0,  0,  0,  0,  5,  7,  9 } }, -- Magic Damage+1
    -- Stat tradeoffs: one stat +N, two stats -N
    { id = 526, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR+1 DEX-1 VIT-1
    { id = 527, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR+1 DEX-1 AGI-1
    { id = 528, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR+1 VIT-1 AGI-1
    { id = 529, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR-1 DEX+1 VIT-1
    { id = 530, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR-1 DEX+1 AGI-1
    { id = 531, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- DEX+1 VIT-1 AGI-1
    { id = 532, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR-1 DEX-1 VIT+1
    { id = 533, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR-1 VIT+1 AGI-1
    { id = 534, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- DEX-1 VIT+1 AGI-1
    { id = 535, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR-1 DEX-1 AGI+1
    { id = 536, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- STR-1 VIT-1 AGI+1
    { id = 537, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- DEX-1 VIT-1 AGI+1
    { id = 538, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI+1 INT-1 MND-1
    { id = 539, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI+1 INT-1 CHR-1
    { id = 540, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI+1 MND-1 CHR-1
    { id = 541, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI-1 INT+1 MND-1
    { id = 542, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI-1 INT+1 CHR-1
    { id = 543, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- INT+1 MND-1 CHR-1
    { id = 544, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI-1 INT-1 MND+1
    { id = 545, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI-1 MND+1 CHR-1
    { id = 546, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- INT-1 MND+1 CHR-1
    { id = 547, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI-1 INT-1 CHR+1
    { id = 548, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- AGI-1 MND-1 CHR+1
    { id = 549, min = 1, maxes = {  0,  0,  0,  0,  3,  4,  5 } }, -- INT-1 MND-1 CHR+1

    -----------------------------------
    -- Tier 6+ augments (advanced/SMN)
    -----------------------------------
    { id = 320, min = 1, maxes = {  0,  0,  0,  0,  0,  4,  6 } }, -- Blood Pact ability delay -1
    { id = 321, min = 1, maxes = {  0,  0,  0,  0,  0,  4,  6 } }, -- Avatar perpetuation cost -1
}

-----------------------------------
-- Augment count probabilities per tier
-- Four values: % chance for aug slots 1, 2, 3, 4 (sequential — misses stop the chain)
-----------------------------------
local augChancesPerTier =
{
    [1] = {  50,   5,   0,   0 }, -- T1 lv1-15:  50% aug1, 5% aug2
    [2] = {  75,  15,   5,   0 }, -- T2 lv15-30: guaranteed-ish aug1, small aug2/3
    [3] = {  90,  25,  10,   3 }, -- T3 lv30-45
    [4] = { 100,  35,  20,   8 }, -- T4 lv45-60: always aug1
    [5] = { 100,  50,  30,  15 }, -- T5 lv60-70
    [6] = { 100,  65,  40,  20 }, -- T6 lv70-75
    [7] = { 100,  75,  50,  25 }, -- T7 lv75+:   always aug1+2, coin-flip aug3
}

-----------------------------------
-- Build xi.caskets.augmentTiers[1..7] from augmentDefs + augChancesPerTier
-----------------------------------
xi.caskets.augmentTiers = {}
for tier = 1, 7 do
    local pool = {}
    for _, def in ipairs(augmentDefs) do
        local maxVal = def.maxes[tier]
        if maxVal and maxVal > 0 then
            pool[#pool + 1] = { id = def.id, min = def.min, max = maxVal }
        end
    end
    xi.caskets.augmentTiers[tier] =
    {
        augChances = augChancesPerTier[tier],
        pool       = pool,
    }
end

return m
