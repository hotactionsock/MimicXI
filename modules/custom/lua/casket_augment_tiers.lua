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

-----------------------------------
-- Zone → tier mapping (all 60 casket zones)
-- Tier 1 zones have rarePools set by casket_loot_starter_zones.lua;
-- this map ensures they still get tier-based augment chance rolling.
-----------------------------------
xi.caskets.zoneTier = xi.caskets.zoneTier or {}

-- Tier 1 (lv1-15) — starter zones
xi.caskets.zoneTier[xi.zone.WEST_RONFAURE]       = 1
xi.caskets.zoneTier[xi.zone.EAST_RONFAURE]       = 1
xi.caskets.zoneTier[xi.zone.NORTH_GUSTABERG]     = 1
xi.caskets.zoneTier[xi.zone.SOUTH_GUSTABERG]     = 1
xi.caskets.zoneTier[xi.zone.WEST_SARUTABARUTA]   = 1
xi.caskets.zoneTier[xi.zone.EAST_SARUTABARUTA]   = 1

-- Tier 2 (lv15-30)
xi.caskets.zoneTier[xi.zone.LA_THEINE_PLATEAU]   = 2
xi.caskets.zoneTier[xi.zone.KONSCHTAT_HIGHLANDS] = 2
xi.caskets.zoneTier[xi.zone.TAHRONGI_CANYON]     = 2
xi.caskets.zoneTier[xi.zone.VALKURM_DUNES]       = 2
xi.caskets.zoneTier[xi.zone.JUGNER_FOREST]       = 2
xi.caskets.zoneTier[xi.zone.PASHHOW_MARSHLANDS]  = 2
xi.caskets.zoneTier[xi.zone.MERIPHATAUD_MOUNTAINS] = 2
xi.caskets.zoneTier[xi.zone.BUBURIMU_PENINSULA]  = 2
xi.caskets.zoneTier[xi.zone.INNER_HORUTOTO_RUINS] = 2
xi.caskets.zoneTier[xi.zone.ZERUHN_MINES]        = 2
xi.caskets.zoneTier[xi.zone.OUTER_HORUTOTO_RUINS] = 2
xi.caskets.zoneTier[xi.zone.DANGRUF_WADI]        = 2

-- Tier 3 (lv30-45)
xi.caskets.zoneTier[xi.zone.QUFIM_ISLAND]        = 3
xi.caskets.zoneTier[xi.zone.BATALLIA_DOWNS]      = 3
xi.caskets.zoneTier[xi.zone.ROLANBERRY_FIELDS]   = 3
xi.caskets.zoneTier[xi.zone.SAUROMUGUE_CHAMPAIGN] = 3
xi.caskets.zoneTier[xi.zone.YUHTUNGA_JUNGLE]     = 3
xi.caskets.zoneTier[xi.zone.YHOATOR_JUNGLE]      = 3
xi.caskets.zoneTier[xi.zone.MAZE_OF_SHAKHRAMI]   = 3
xi.caskets.zoneTier[xi.zone.ORDELLES_CAVES]      = 3
xi.caskets.zoneTier[xi.zone.KING_RANPERRES_TOMB] = 3
xi.caskets.zoneTier[xi.zone.GUSGEN_MINES]        = 3
xi.caskets.zoneTier[xi.zone.KORROLOKA_TUNNEL]    = 3

-- Tier 4 (lv45-60)
xi.caskets.zoneTier[xi.zone.EASTERN_ALTEPA_DESERT]  = 4
xi.caskets.zoneTier[xi.zone.WESTERN_ALTEPA_DESERT]  = 4
xi.caskets.zoneTier[xi.zone.CRAWLERS_NEST]           = 4
xi.caskets.zoneTier[xi.zone.LABYRINTH_OF_ONZOZO]     = 4
xi.caskets.zoneTier[xi.zone.THE_SANCTUARY_OF_ZITAH]  = 4
xi.caskets.zoneTier[xi.zone.SEA_SERPENT_GROTTO]      = 4
xi.caskets.zoneTier[xi.zone.QUICKSAND_CAVES]         = 4
xi.caskets.zoneTier[xi.zone.GUSTAV_TUNNEL]           = 4
xi.caskets.zoneTier[xi.zone.CAPE_TERIGGAN]           = 4
xi.caskets.zoneTier[xi.zone.KUFTAL_TUNNEL]           = 4

-- Tier 5 (lv60-70)
xi.caskets.zoneTier[xi.zone.LOWER_DELKFUTTS_TOWER]  = 5
xi.caskets.zoneTier[xi.zone.MIDDLE_DELKFUTTS_TOWER] = 5
xi.caskets.zoneTier[xi.zone.UPPER_DELKFUTTS_TOWER]  = 5
xi.caskets.zoneTier[xi.zone.FEIYIN]                  = 5
xi.caskets.zoneTier[xi.zone.TORAIMARAI_CANAL]        = 5
xi.caskets.zoneTier[xi.zone.BOSTAUNIEUX_OUBLIETTE]   = 5
xi.caskets.zoneTier[xi.zone.TEMPLE_OF_UGGALEPIH]     = 5
xi.caskets.zoneTier[xi.zone.THE_ELDIEME_NECROPOLIS]  = 5
xi.caskets.zoneTier[xi.zone.DEN_OF_RANCOR]           = 5
xi.caskets.zoneTier[xi.zone.THE_BOYAHDA_TREE]        = 5

-- Tier 6 (lv70-75)
xi.caskets.zoneTier[xi.zone.GARLAIGE_CITADEL]        = 6
xi.caskets.zoneTier[xi.zone.IFRITS_CAULDRON]         = 6
xi.caskets.zoneTier[xi.zone.ROMAEVE]                 = 6
xi.caskets.zoneTier[xi.zone.BEAUCEDINE_GLACIER]      = 6
xi.caskets.zoneTier[xi.zone.XARCABARD]               = 6
xi.caskets.zoneTier[xi.zone.VALLEY_OF_SORROWS]       = 6
xi.caskets.zoneTier[xi.zone.BEHEMOTHS_DOMINION]      = 6

-- Tier 7 (lv75+ endgame)
xi.caskets.zoneTier[xi.zone.RANGUEMONT_PASS]         = 7
xi.caskets.zoneTier[xi.zone.RUAUN_GARDENS]           = 7
xi.caskets.zoneTier[xi.zone.VELUGANNON_PALACE]       = 7
xi.caskets.zoneTier[xi.zone.THE_SHRINE_OF_RUAVITAU]  = 7

-----------------------------------
-- Tier 2 rare item pool (lv15-30 HQ gear)
-----------------------------------
xi.caskets.rarePools = xi.caskets.rarePools or {}

local tier2RareItems =
{
    -- Head
    { itemId = 12480, weight = 320 }, -- lizard_helm_+1       lv17
    { itemId = 12537, weight = 310 }, -- ctn._hachimaki_+1    lv18
    { itemId = 12524, weight = 280 }, -- iron_mask_+1         lv24
    { itemId = 12479, weight = 250 }, -- wool_hat_+1          lv28
    -- Body
    { itemId = 12624, weight = 320 }, -- cotton_dogi_+1       lv18
    { itemId = 12662, weight = 290 }, -- chainmail_+1         lv24
    { itemId = 12627, weight = 260 }, -- wool_robe_+1         lv28
    { itemId = 12665, weight = 250 }, -- brs._scale_mail_+1   lv27
    -- Hands
    { itemId = 12777, weight = 320 }, -- cotton_tekko_+1      lv18
    { itemId = 12789, weight = 290 }, -- beetle_mittens_+1    lv21
    { itemId = 12769, weight = 270 }, -- chain_mittens_+1     lv24
    { itemId = 12782, weight = 250 }, -- wool_cuffs_+1        lv28
    -- Legs
    { itemId = 12902, weight = 320 }, -- ctn._sitabaki_+1     lv18
    { itemId = 12913, weight = 290 }, -- beetle_subligar_+1   lv21
    { itemId = 12890, weight = 270 }, -- chain_hose_+1        lv24
    { itemId = 12906, weight = 250 }, -- wool_slops_+1        lv28
    -- Feet
    { itemId = 13033, weight = 320 }, -- cotton_kyahan_+1     lv18
    { itemId = 10648, weight = 300 }, -- areion_boots_+1      lv20
    { itemId = 13043, weight = 280 }, -- btl._leggings_+1     lv21
    { itemId = 13022, weight = 250 }, -- chs._sabots_+1       lv28
    -- Neck / waist / rings / earrings / cape
    { itemId = 13068, weight = 270 }, -- hemp_gorget_+1       lv23
    { itemId = 13070, weight = 240 }, -- wolf_gorget_+1       lv30
    { itemId = 13240, weight = 300 }, -- warriors_belt_+1     lv15
    { itemId = 13191, weight = 290 }, -- lizard_belt_+1       lv17
    { itemId = 13213, weight = 270 }, -- chain_belt_+1        lv24
    { itemId = 13500, weight = 290 }, -- bone_ring_+1         lv16
    { itemId = 13501, weight = 270 }, -- beetle_ring_+1       lv21
    { itemId = 13519, weight = 250 }, -- mythril_ring_+1      lv24
    { itemId = 13362, weight = 280 }, -- bone_earring_+1      lv16
    { itemId = 13371, weight = 260 }, -- mythril_earring_+1   lv24
    { itemId = 13600, weight = 270 }, -- dhalmel_mantle_+1    lv18
    { itemId = 13608, weight = 260 }, -- lizard_mantle_+1     lv17
    -- Shields
    { itemId = 12413, weight = 270 }, -- turtle_shield_+1     lv24
    { itemId = 12326, weight = 250 }, -- kite_shield_+1       lv28
    -- Weapons
    { itemId = 16626, weight = 300 }, -- iron_sword_+1        lv18
    { itemId = 16628, weight = 290 }, -- longsword_+1         lv18
    { itemId = 16663, weight = 280 }, -- battleaxe_+1         lv20
    { itemId = 17145, weight = 280 }, -- mace_+1              lv19
    { itemId = 16738, weight = 270 }, -- mythril_dagger_+1    lv23
    { itemId = 16781, weight = 270 }, -- scythe_+1            lv18
    { itemId = 16865, weight = 260 }, -- spear_+1             lv24
    { itemId = 17115, weight = 270 }, -- warhammer_+1         lv20
    { itemId = 17126, weight = 260 }, -- elm_staff_+1         lv23
    { itemId = 17140, weight = 270 }, -- yew_wand_+1          lv18
    { itemId = 17146, weight = 260 }, -- rod_+1               lv22
    { itemId = 17172, weight = 255 }, -- wrapped_bow_+1       lv24
    { itemId = 17442, weight = 240 }, -- eremites_wand_+1     lv28
}

-- Assign T2 pool to all tier-2 zones
xi.caskets.rarePools[xi.zone.LA_THEINE_PLATEAU]    = xi.caskets.rarePools[xi.zone.LA_THEINE_PLATEAU]    or tier2RareItems
xi.caskets.rarePools[xi.zone.KONSCHTAT_HIGHLANDS]  = xi.caskets.rarePools[xi.zone.KONSCHTAT_HIGHLANDS]  or tier2RareItems
xi.caskets.rarePools[xi.zone.TAHRONGI_CANYON]      = xi.caskets.rarePools[xi.zone.TAHRONGI_CANYON]      or tier2RareItems
xi.caskets.rarePools[xi.zone.VALKURM_DUNES]        = xi.caskets.rarePools[xi.zone.VALKURM_DUNES]        or tier2RareItems
xi.caskets.rarePools[xi.zone.JUGNER_FOREST]        = xi.caskets.rarePools[xi.zone.JUGNER_FOREST]        or tier2RareItems
xi.caskets.rarePools[xi.zone.PASHHOW_MARSHLANDS]   = xi.caskets.rarePools[xi.zone.PASHHOW_MARSHLANDS]   or tier2RareItems
xi.caskets.rarePools[xi.zone.MERIPHATAUD_MOUNTAINS] = xi.caskets.rarePools[xi.zone.MERIPHATAUD_MOUNTAINS] or tier2RareItems
xi.caskets.rarePools[xi.zone.BUBURIMU_PENINSULA]   = xi.caskets.rarePools[xi.zone.BUBURIMU_PENINSULA]   or tier2RareItems
xi.caskets.rarePools[xi.zone.INNER_HORUTOTO_RUINS] = xi.caskets.rarePools[xi.zone.INNER_HORUTOTO_RUINS] or tier2RareItems
xi.caskets.rarePools[xi.zone.ZERUHN_MINES]         = xi.caskets.rarePools[xi.zone.ZERUHN_MINES]         or tier2RareItems
xi.caskets.rarePools[xi.zone.OUTER_HORUTOTO_RUINS] = xi.caskets.rarePools[xi.zone.OUTER_HORUTOTO_RUINS] or tier2RareItems
xi.caskets.rarePools[xi.zone.DANGRUF_WADI]         = xi.caskets.rarePools[xi.zone.DANGRUF_WADI]         or tier2RareItems

-----------------------------------
-- Tier 3 rare item pool (lv30-45 HQ gear)
-----------------------------------
local tier3RareItems =
{
    -- Head
    { itemId = 12538, weight = 320 }, -- red_cap_+1           lv36
    -- Body
    { itemId = 13797, weight = 310 }, -- bishops_robe_+1      lv35
    { itemId = 13784, weight = 290 }, -- iron_scale_mail_+1   lv37
    { itemId = 11348, weight = 260 }, -- salutary_robe_+1     lv40
    { itemId = 14358, weight = 240 }, -- ryl.sqr._robe_+1     lv43
    -- Hands
    { itemId = 12718, weight = 300 }, -- iron_mittens_+1      lv35
    { itemId = 14002, weight = 260 }, -- iron_fng._gnt._+1    lv37
    { itemId = 12790, weight = 230 }, -- cpc._mittens_+1      lv45
    -- Legs
    { itemId = 12891, weight = 300 }, -- iron_subligar_+1     lv35
    { itemId = 12903, weight = 280 }, -- hose_+1              lv36
    { itemId = 12916, weight = 260 }, -- cuisses_+1           lv40
    { itemId = 12914, weight = 230 }, -- cpc._subligar_+1     lv45
    -- Feet
    { itemId = 13026, weight = 300 }, -- leggings_+1          lv35
    { itemId = 13029, weight = 280 }, -- silver_greaves_+1    lv36
    { itemId = 13041, weight = 260 }, -- cuir_highboots_+1    lv38
    { itemId = 13044, weight = 230 }, -- cpc._leggings_+1     lv45
    -- Neck / waist / rings / earrings / cape
    { itemId = 13065, weight = 270 }, -- gorget_+1            lv40
    { itemId = 13214, weight = 280 }, -- waistbelt_+1         lv40
    { itemId = 13232, weight = 250 }, -- swordbelt_+1         lv43
    { itemId = 13281, weight = 260 }, -- snipers_ring_+1      lv40
    { itemId = 13502, weight = 280 }, -- horn_ring_+1         lv35
    { itemId = 14600, weight = 270 }, -- alacrity_ring_+1     lv36
    { itemId = 14601, weight = 270 }, -- puissance_ring_+1    lv36
    { itemId = 14602, weight = 270 }, -- wisdom_ring_+1       lv36
    { itemId = 14603, weight = 270 }, -- deft_ring_+1         lv36
    { itemId = 14696, weight = 270 }, -- alc._earring_+1      lv31
    { itemId = 14698, weight = 270 }, -- wisdom_earring_+1    lv31
    { itemId = 13363, weight = 240 }, -- tor._earring_+1      lv45
    { itemId = 13575, weight = 270 }, -- ram_mantle_+1        lv36
    { itemId = 13610, weight = 290 }, -- black_cape_+1        lv32
    { itemId = 13618, weight = 290 }, -- white_cape_+1        lv32
    { itemId = 13640, weight = 240 }, -- aurora_mantle_+1     lv44
    -- Shields
    { itemId = 12331, weight = 280 }, -- oak_shield_+1        lv36
    { itemId = 12328, weight = 250 }, -- heater_shield_+1     lv43
    -- Weapons
    { itemId = 16876, weight = 290 }, -- lance_+1             lv34
    { itemId = 17409, weight = 290 }, -- mythril_rod_+1       lv34
    { itemId = 16695, weight = 280 }, -- katars_+1            lv33
    { itemId = 16635, weight = 280 }, -- mythril_sword_+1     lv36
    { itemId = 16816, weight = 270 }, -- holy_sword_+1        lv36
    { itemId = 17147, weight = 270 }, -- mythril_mace_+1      lv35
    { itemId = 16665, weight = 270 }, -- mythril_axe_+1       lv37
    { itemId = 17127, weight = 260 }, -- oak_staff_+1         lv39
    { itemId = 17179, weight = 260 }, -- composite_bow_+1     lv36
    { itemId = 16782, weight = 255 }, -- mythril_scythe_+1    lv40
    { itemId = 17411, weight = 240 }, -- holy_mace_+1         lv43
}

xi.caskets.rarePools[xi.zone.QUFIM_ISLAND]         = xi.caskets.rarePools[xi.zone.QUFIM_ISLAND]         or tier3RareItems
xi.caskets.rarePools[xi.zone.BATALLIA_DOWNS]       = xi.caskets.rarePools[xi.zone.BATALLIA_DOWNS]       or tier3RareItems
xi.caskets.rarePools[xi.zone.ROLANBERRY_FIELDS]    = xi.caskets.rarePools[xi.zone.ROLANBERRY_FIELDS]    or tier3RareItems
xi.caskets.rarePools[xi.zone.SAUROMUGUE_CHAMPAIGN] = xi.caskets.rarePools[xi.zone.SAUROMUGUE_CHAMPAIGN] or tier3RareItems
xi.caskets.rarePools[xi.zone.YUHTUNGA_JUNGLE]      = xi.caskets.rarePools[xi.zone.YUHTUNGA_JUNGLE]      or tier3RareItems
xi.caskets.rarePools[xi.zone.YHOATOR_JUNGLE]       = xi.caskets.rarePools[xi.zone.YHOATOR_JUNGLE]       or tier3RareItems
xi.caskets.rarePools[xi.zone.MAZE_OF_SHAKHRAMI]    = xi.caskets.rarePools[xi.zone.MAZE_OF_SHAKHRAMI]    or tier3RareItems
xi.caskets.rarePools[xi.zone.ORDELLES_CAVES]       = xi.caskets.rarePools[xi.zone.ORDELLES_CAVES]       or tier3RareItems
xi.caskets.rarePools[xi.zone.KING_RANPERRES_TOMB]  = xi.caskets.rarePools[xi.zone.KING_RANPERRES_TOMB]  or tier3RareItems
xi.caskets.rarePools[xi.zone.GUSGEN_MINES]         = xi.caskets.rarePools[xi.zone.GUSGEN_MINES]         or tier3RareItems
xi.caskets.rarePools[xi.zone.KORROLOKA_TUNNEL]     = xi.caskets.rarePools[xi.zone.KORROLOKA_TUNNEL]     or tier3RareItems

-----------------------------------
-- Tier 4 rare item pool (lv45-60 HQ gear)
-----------------------------------
local tier4RareItems =
{
    -- Head
    { itemId = 12541, weight = 310 }, -- wool_cap_+1          lv48
    { itemId = 13701, weight = 270 }, -- beak_helm_+1         lv58
    { itemId = 12482, weight = 250 }, -- scorpion_mask_+1     lv57
    { itemId = 12439, weight = 240 }, -- bascinet_+1          lv59
    -- Body
    { itemId = 12667, weight = 300 }, -- banded_mail_+1       lv46
    { itemId = 12651, weight = 280 }, -- white_cloak_+1       lv50
    { itemId = 12652, weight = 270 }, -- silk_coat_+1         lv53
    { itemId = 13734, weight = 260 }, -- scp._harness_+1      lv57
    { itemId = 13745, weight = 250 }, -- justaucorps_+1       lv58
    { itemId = 13735, weight = 240 }, -- haubergeon_+1        lv59
    { itemId = 13741, weight = 230 }, -- byrnie_+1            lv60
    { itemId = 13743, weight = 230 }, -- aketon_+1            lv60
    -- Hands
    { itemId = 12792, weight = 300 }, -- mufflers_+1          lv46
    { itemId = 12783, weight = 280 }, -- wool_bracers_+1      lv48
    -- Legs
    { itemId = 12895, weight = 300 }, -- breeches_+1          lv46
    { itemId = 12907, weight = 280 }, -- wool_hose_+1         lv48
    { itemId = 12925, weight = 265 }, -- shn._hakama_+1       lv49
    { itemId = 12926, weight = 255 }, -- white_slacks_+1      lv50
    { itemId = 12927, weight = 240 }, -- silk_slops_+1        lv53
    -- Feet
    { itemId = 13047, weight = 300 }, -- sollerets_+1         lv46
    { itemId = 13036, weight = 280 }, -- wool_socks_+1        lv48
    { itemId = 13050, weight = 260 }, -- moccasins_+1         lv50
    -- Neck / waist / rings / earrings / cape
    { itemId = 13124, weight = 270 }, -- nodowa_+1            lv49
    { itemId = 13126, weight = 250 }, -- torque_+1            lv58
    { itemId = 13234, weight = 280 }, -- brocade_obi_+1       lv46
    { itemId = 13274, weight = 260 }, -- twinthread_obi_+1    lv52
    { itemId = 13277, weight = 250 }, -- r.k._belt_+1         lv52
    { itemId = 13513, weight = 270 }, -- scorpion_ring_+1     lv55
    { itemId = 13545, weight = 240 }, -- demons_ring_+1       lv60
    { itemId = 13498, weight = 240 }, -- platinum_ring_+1     lv60
    { itemId = 13418, weight = 260 }, -- eris_earring_+1      lv54
    { itemId = 13397, weight = 240 }, -- ptm._earring_+1      lv60
    { itemId = 13638, weight = 270 }, -- gaia_mantle_+1       lv51
    { itemId = 13620, weight = 260 }, -- jesters_cape_+1      lv54
    { itemId = 13621, weight = 250 }, -- beak_mantle_+1       lv58
    { itemId = 13604, weight = 240 }, -- behem._mantle_+1     lv60
    -- Shields
    { itemId = 12329, weight = 290 }, -- leather_shield_+1    lv48
    { itemId = 12339, weight = 260 }, -- scutum_+1            lv54
    { itemId = 12346, weight = 240 }, -- dst._shield_+1       lv60
    -- Weapons
    { itemId = 16877, weight = 290 }, -- mythril_lance_+1     lv48
    { itemId = 17446, weight = 280 }, -- t.m._wand_+1         lv52
    { itemId = 16880, weight = 275 }, -- holy_lance_+1        lv53
    { itemId = 16811, weight = 270 }, -- dst._sword_+1        lv51
    { itemId = 16751, weight = 265 }, -- dst._knife_+1        lv53
    { itemId = 16795, weight = 260 }, -- bone_scythe_+1       lv53
    { itemId = 16612, weight = 255 }, -- saber_+1             lv56
    { itemId = 17173, weight = 260 }, -- war_bow_+1           lv50
    { itemId = 16677, weight = 255 }, -- darksteel_axe_+1     lv56
    { itemId = 17428, weight = 250 }, -- darksteel_mace_+1    lv57
    { itemId = 16878, weight = 245 }, -- dst._lance_+1        lv58
    { itemId = 17189, weight = 240 }, -- rapid_bow_+1         lv58
    { itemId = 17427, weight = 235 }, -- ebony_wand_+1        lv60
    { itemId = 16828, weight = 230 }, -- bastard_sword_+1     lv60
}

xi.caskets.rarePools[xi.zone.EASTERN_ALTEPA_DESERT]  = xi.caskets.rarePools[xi.zone.EASTERN_ALTEPA_DESERT]  or tier4RareItems
xi.caskets.rarePools[xi.zone.WESTERN_ALTEPA_DESERT]  = xi.caskets.rarePools[xi.zone.WESTERN_ALTEPA_DESERT]  or tier4RareItems
xi.caskets.rarePools[xi.zone.CRAWLERS_NEST]           = xi.caskets.rarePools[xi.zone.CRAWLERS_NEST]           or tier4RareItems
xi.caskets.rarePools[xi.zone.LABYRINTH_OF_ONZOZO]     = xi.caskets.rarePools[xi.zone.LABYRINTH_OF_ONZOZO]     or tier4RareItems
xi.caskets.rarePools[xi.zone.THE_SANCTUARY_OF_ZITAH]  = xi.caskets.rarePools[xi.zone.THE_SANCTUARY_OF_ZITAH]  or tier4RareItems
xi.caskets.rarePools[xi.zone.SEA_SERPENT_GROTTO]      = xi.caskets.rarePools[xi.zone.SEA_SERPENT_GROTTO]      or tier4RareItems
xi.caskets.rarePools[xi.zone.QUICKSAND_CAVES]         = xi.caskets.rarePools[xi.zone.QUICKSAND_CAVES]         or tier4RareItems
xi.caskets.rarePools[xi.zone.GUSTAV_TUNNEL]           = xi.caskets.rarePools[xi.zone.GUSTAV_TUNNEL]           or tier4RareItems
xi.caskets.rarePools[xi.zone.CAPE_TERIGGAN]           = xi.caskets.rarePools[xi.zone.CAPE_TERIGGAN]           or tier4RareItems
xi.caskets.rarePools[xi.zone.KUFTAL_TUNNEL]           = xi.caskets.rarePools[xi.zone.KUFTAL_TUNNEL]           or tier4RareItems

-----------------------------------
-- Tier 5 rare item pool (lv60-70 HQ gear)
-----------------------------------
local tier5RareItems =
{
    -- Head
    { itemId = 12423, weight = 290 }, -- dst._armet_+1        lv65
    { itemId = 12461, weight = 270 }, -- scorpion_helm_+1     lv66
    { itemId = 13845, weight = 250 }, -- celata_+1            lv68
    -- Body
    { itemId = 11350, weight = 290 }, -- styrne_byrnie_+1     lv62
    { itemId = 13761, weight = 280 }, -- cor._scale_mail_+1   lv65
    { itemId = 13765, weight = 275 }, -- dst._harness_+1      lv65
    { itemId = 12628, weight = 270 }, -- battle_jupon_+1      lv65
    { itemId = 12589, weight = 265 }, -- scp._brstplate_+1    lv66
    { itemId = 13756, weight = 260 }, -- dst._cuirass_+1      lv66
    { itemId = 13793, weight = 245 }, -- hauberk_+1           lv69
    { itemId = 13768, weight = 240 }, -- dmn._harness_+1      lv70
    { itemId = 13770, weight = 235 }, -- war_shinobi_gi_+1    lv70
    -- Neck / waist / rings / cape
    { itemId = 13133, weight = 280 }, -- dst._nodowa_+1       lv63
    { itemId = 13131, weight = 265 }, -- dst._gorget_+1       lv67
    { itemId = 13130, weight = 240 }, -- jeweled_collar_+1    lv70
    { itemId = 13250, weight = 270 }, -- sonic_belt_+1        lv65
    { itemId = 13276, weight = 260 }, -- arachne_obi_+1       lv66
    { itemId = 13279, weight = 255 }, -- muscle_belt_+1       lv67
    { itemId = 13556, weight = 240 }, -- behemoth_ring_+1     lv70
    { itemId = 13646, weight = 280 }, -- amemet_mantle_+1     lv61
    { itemId = 13650, weight = 265 }, -- taffeta_cape_+1      lv65
    { itemId = 13626, weight = 255 }, -- blue_cape_+1         lv68
    { itemId = 13634, weight = 250 }, -- empwr._mantle_+1     lv67
    -- Shields
    { itemId = 12352, weight = 280 }, -- round_shield_+1      lv61
    { itemId = 12354, weight = 260 }, -- tower_shield_+1      lv65
    -- Weapons
    { itemId = 17641, weight = 290 }, -- gold_sword_+1        lv62
    { itemId = 17633, weight = 280 }, -- rapier_+1            lv64
    { itemId = 16731, weight = 275 }, -- colossal_axe_+1      lv64
    { itemId = 17600, weight = 275 }, -- stun_knife_+1        lv65
    { itemId = 16875, weight = 270 }, -- golden_spear_+1      lv65
    { itemId = 17433, weight = 270 }, -- mythic_wand_+1       lv65
    { itemId = 17525, weight = 265 }, -- ebony_pole_+1        lv65
    { itemId = 16790, weight = 265 }, -- dst._scythe_+1       lv65
    { itemId = 16879, weight = 260 }, -- cermet_lance_+1      lv66
    { itemId = 17485, weight = 255 }, -- dragon_claws_+1      lv68
    { itemId = 17431, weight = 255 }, -- platinum_mace_+1     lv67
    { itemId = 17637, weight = 250 }, -- wing_sword_+1        lv69
    { itemId = 18860, weight = 245 }, -- flanged_mace_+1      lv69
    { itemId = 17436, weight = 240 }, -- platinum_rod_+1      lv70
    { itemId = 17526, weight = 235 }, -- mythic_pole_+1       lv70
}

xi.caskets.rarePools[xi.zone.LOWER_DELKFUTTS_TOWER]  = xi.caskets.rarePools[xi.zone.LOWER_DELKFUTTS_TOWER]  or tier5RareItems
xi.caskets.rarePools[xi.zone.MIDDLE_DELKFUTTS_TOWER] = xi.caskets.rarePools[xi.zone.MIDDLE_DELKFUTTS_TOWER] or tier5RareItems
xi.caskets.rarePools[xi.zone.UPPER_DELKFUTTS_TOWER]  = xi.caskets.rarePools[xi.zone.UPPER_DELKFUTTS_TOWER]  or tier5RareItems
xi.caskets.rarePools[xi.zone.FEIYIN]                  = xi.caskets.rarePools[xi.zone.FEIYIN]                  or tier5RareItems
xi.caskets.rarePools[xi.zone.TORAIMARAI_CANAL]        = xi.caskets.rarePools[xi.zone.TORAIMARAI_CANAL]        or tier5RareItems
xi.caskets.rarePools[xi.zone.BOSTAUNIEUX_OUBLIETTE]   = xi.caskets.rarePools[xi.zone.BOSTAUNIEUX_OUBLIETTE]   or tier5RareItems
xi.caskets.rarePools[xi.zone.TEMPLE_OF_UGGALEPIH]     = xi.caskets.rarePools[xi.zone.TEMPLE_OF_UGGALEPIH]     or tier5RareItems
xi.caskets.rarePools[xi.zone.THE_ELDIEME_NECROPOLIS]  = xi.caskets.rarePools[xi.zone.THE_ELDIEME_NECROPOLIS]  or tier5RareItems
xi.caskets.rarePools[xi.zone.DEN_OF_RANCOR]           = xi.caskets.rarePools[xi.zone.DEN_OF_RANCOR]           or tier5RareItems
xi.caskets.rarePools[xi.zone.THE_BOYAHDA_TREE]        = xi.caskets.rarePools[xi.zone.THE_BOYAHDA_TREE]        or tier5RareItems

-----------------------------------
-- Tier 6 rare item pool (lv70-75 HQ gear)
-----------------------------------
local tier6RareItems =
{
    -- Head (job-specific AF2-style)
    { itemId = 11464, weight = 270 }, -- magus_keffiyeh_+1    lv74
    { itemId = 11466, weight = 265 }, -- mirage_keffiyeh_+1   lv75
    { itemId = 11467, weight = 265 }, -- cor._tricorne_+1     lv74
    { itemId = 11469, weight = 260 }, -- comm._tricorne_+1    lv75
    { itemId = 11470, weight = 260 }, -- puppetry_taj_+1      lv74
    { itemId = 11472, weight = 255 }, -- pantin_taj_+1        lv75
    -- Body
    { itemId = 14538, weight = 280 }, -- hydra_mail_+1        lv72
    { itemId = 14379, weight = 275 }, -- hct._harness_+1      lv73
    { itemId = 11291, weight = 270 }, -- magus_jubbah_+1      lv74
    { itemId = 14449, weight = 265 }, -- ucn._harness_+1      lv74
    { itemId = 14476, weight = 265 }, -- wzd._coat_+1         lv74
    { itemId = 14479, weight = 260 }, -- glt._surcoat_+1      lv74
    { itemId = 14480, weight = 260 }, -- chs._cuirass_+1      lv74
    { itemId = 14485, weight = 260 }, -- nin._chainmail_+1    lv74
    { itemId = 14486, weight = 260 }, -- drn._mail_+1         lv74
    { itemId = 11293, weight = 255 }, -- mirage_jubbah_+1     lv75
    { itemId = 11294, weight = 255 }, -- corsairs_frac_+1     lv74
    { itemId = 11296, weight = 250 }, -- comm._frac_+1        lv75
    { itemId = 14503, weight = 250 }, -- src._coat_+1         lv75
    -- Legs / feet
    { itemId = 14181, weight = 265 }, -- hct._leggings_+1     lv73
    { itemId = 15346, weight = 260 }, -- ucn._leggings_+1     lv74
    { itemId = 11381, weight = 265 }, -- magus_charuqs_+1     lv74
    { itemId = 11383, weight = 260 }, -- mirage_charuqs_+1    lv75
    { itemId = 11384, weight = 260 }, -- cor._bottes_+1       lv74
    { itemId = 11386, weight = 255 }, -- comm._bottes_+1      lv75
    -- Neck / rings
    { itemId = 10919, weight = 260 }, -- tndm._necklace_+1    lv75
    { itemId = 11580, weight = 255 }, -- fylgja_torque_+1     lv75
    { itemId = 11582, weight = 255 }, -- ire_torque_+1        lv75
    { itemId = 14617, weight = 265 }, -- nimble_ring_+1       lv72
    { itemId = 14618, weight = 265 }, -- triumph_ring_+1      lv72
    { itemId = 14619, weight = 265 }, -- omn._ring_+1         lv72
    { itemId = 14620, weight = 260 }, -- adroit_ring_+1       lv72
    { itemId = 14622, weight = 260 }, -- robust_ring_+1       lv72
    -- Shields
    { itemId = 12358, weight = 270 }, -- ritter_shield_+1     lv71
    { itemId = 12357, weight = 260 }, -- ice_shield_+1        lv72
    -- Weapons
    { itemId = 18143, weight = 275 }, -- shigeto_bow_+1       lv71
    { itemId = 16791, weight = 270 }, -- death_scythe_+1      lv73
    { itemId = 16873, weight = 270 }, -- wyvern_spear_+1      lv73
    { itemId = 17591, weight = 265 }, -- primate_staff_+1     lv73
    { itemId = 18432, weight = 265 }, -- butachi_+1           lv73
    { itemId = 16895, weight = 260 }, -- ice_lance_+1         lv74
    { itemId = 17214, weight = 255 }, -- staurobow_+1         lv74
    { itemId = 17263, weight = 250 }, -- corsairs_gun_+1      lv75
    { itemId = 18701, weight = 245 }, -- cerberus_bow_+1      lv75
    { itemId = 20784, weight = 240 }, -- uruz_blade_+1        lv75
}

xi.caskets.rarePools[xi.zone.GARLAIGE_CITADEL]   = xi.caskets.rarePools[xi.zone.GARLAIGE_CITADEL]   or tier6RareItems
xi.caskets.rarePools[xi.zone.IFRITS_CAULDRON]    = xi.caskets.rarePools[xi.zone.IFRITS_CAULDRON]    or tier6RareItems
xi.caskets.rarePools[xi.zone.ROMAEVE]            = xi.caskets.rarePools[xi.zone.ROMAEVE]            or tier6RareItems
xi.caskets.rarePools[xi.zone.BEAUCEDINE_GLACIER] = xi.caskets.rarePools[xi.zone.BEAUCEDINE_GLACIER] or tier6RareItems
xi.caskets.rarePools[xi.zone.XARCABARD]          = xi.caskets.rarePools[xi.zone.XARCABARD]          or tier6RareItems
xi.caskets.rarePools[xi.zone.VALLEY_OF_SORROWS]  = xi.caskets.rarePools[xi.zone.VALLEY_OF_SORROWS]  or tier6RareItems
xi.caskets.rarePools[xi.zone.BEHEMOTHS_DOMINION] = xi.caskets.rarePools[xi.zone.BEHEMOTHS_DOMINION] or tier6RareItems

-----------------------------------
-- Tier 7 rare item pool (lv75 endgame HQ gear)
-----------------------------------
local tier7RareItems =
{
    -- Head (AF+1 job pieces lv75)
    { itemId = 15245, weight = 260 }, -- war._mask_+1          lv75
    { itemId = 15246, weight = 260 }, -- mnk._crown_+1         lv75
    { itemId = 15247, weight = 260 }, -- whm._coif_+1          lv75
    { itemId = 15248, weight = 260 }, -- blm._hat_+1           lv75
    { itemId = 15249, weight = 260 }, -- rdm._chapeau_+1       lv75
    { itemId = 15250, weight = 260 }, -- thf._mask_+1          lv75
    { itemId = 15251, weight = 260 }, -- pld._armet_+1         lv75
    { itemId = 15252, weight = 260 }, -- drk._helm_+1          lv75
    { itemId = 15253, weight = 260 }, -- bst._helm_+1          lv75
    { itemId = 15254, weight = 260 }, -- brd._chapeau_+1       lv75
    { itemId = 15255, weight = 260 }, -- rng._beret_+1         lv75
    { itemId = 15256, weight = 260 }, -- sam._kabuto_+1        lv75
    { itemId = 15257, weight = 260 }, -- nin._hatsuburi_+1     lv75
    -- Body (AF+1 job pieces lv75)
    { itemId = 14500, weight = 260 }, -- war._lorica_+1        lv75
    { itemId = 14501, weight = 260 }, -- mnk._gi_+1            lv75
    { itemId = 14502, weight = 260 }, -- whm._cloak_+1         lv75
    { itemId = 14503, weight = 260 }, -- blm._coat_+1          lv75
    { itemId = 14504, weight = 260 }, -- rdm._coat_+1          lv75
    { itemId = 14505, weight = 260 }, -- thf._harness_+1       lv75
    { itemId = 14506, weight = 260 }, -- pld._cuirass_+1       lv75
    { itemId = 14507, weight = 260 }, -- drk._cuirass_+1       lv75
    { itemId = 14508, weight = 260 }, -- bst._jackcoat_+1      lv75
    { itemId = 14509, weight = 260 }, -- brd._justaucorps_+1   lv75
    { itemId = 14510, weight = 260 }, -- rng._jackcoat_+1      lv75
    { itemId = 14511, weight = 260 }, -- sam._haramaki_+1      lv75
    { itemId = 14512, weight = 260 }, -- nin._chainmail_+1     lv75
    { itemId = 14513, weight = 260 }, -- drg._mail_+1          lv75
    { itemId = 14514, weight = 260 }, -- smn._doublet_+1       lv75
    -- Hands (AF+1 job pieces lv75)
    { itemId = 14909, weight = 255 }, -- war._mufflers_+1      lv75
    { itemId = 14910, weight = 255 }, -- mnk._gloves_+1        lv75
    { itemId = 14911, weight = 255 }, -- whm._mitts_+1         lv75
    { itemId = 14912, weight = 255 }, -- blm._gloves_+1        lv75
    { itemId = 14913, weight = 255 }, -- rdm._gloves_+1        lv75
    { itemId = 14914, weight = 255 }, -- thf._armlets_+1       lv75
    { itemId = 14915, weight = 255 }, -- pld._mufflers_+1      lv75
    { itemId = 14916, weight = 255 }, -- drk._mufflers_+1      lv75
    { itemId = 14917, weight = 255 }, -- bst._gloves_+1        lv75
    { itemId = 14918, weight = 255 }, -- brd._cuffs_+1         lv75
    { itemId = 14919, weight = 255 }, -- rng._gloves_+1        lv75
    { itemId = 14920, weight = 255 }, -- sam._kote_+1          lv75
    { itemId = 14921, weight = 255 }, -- nin._tekko_+1         lv75
    { itemId = 14922, weight = 255 }, -- drg._gauntlets_+1     lv75
    { itemId = 14923, weight = 255 }, -- smn._bracers_+1       lv75
    -- Legs (AF+1 job pieces lv75)
    { itemId = 15580, weight = 255 }, -- war._cuisses_+1       lv75
    { itemId = 15581, weight = 255 }, -- mnk._slacks_+1        lv75
    { itemId = 15582, weight = 255 }, -- whm._slops_+1         lv75
    { itemId = 15583, weight = 255 }, -- blm._slops_+1         lv75
    { itemId = 15584, weight = 255 }, -- rdm._slops_+1         lv75
    { itemId = 15585, weight = 255 }, -- thf._culottes_+1      lv75
    { itemId = 15586, weight = 255 }, -- pld._cuisses_+1       lv75
    { itemId = 15587, weight = 255 }, -- drk._cuisses_+1       lv75
    { itemId = 15588, weight = 255 }, -- bst._trousers_+1      lv75
    { itemId = 15589, weight = 255 }, -- brd._cannions_+1      lv75
    { itemId = 15590, weight = 255 }, -- rng._trousers_+1      lv75
    { itemId = 15591, weight = 255 }, -- sam._hakama_+1        lv75
    { itemId = 15592, weight = 255 }, -- nin._hakama_+1        lv75
    -- Feet (AF+1 job pieces lv75)
    { itemId = 15669, weight = 250 }, -- war._greaves_+1       lv75
    { itemId = 15670, weight = 250 }, -- mnk._boots_+1         lv75
    { itemId = 15671, weight = 250 }, -- whm._duckbills_+1     lv75
    { itemId = 15672, weight = 250 }, -- blm._sabots_+1        lv75
    { itemId = 15673, weight = 250 }, -- rdm._boots_+1         lv75
    { itemId = 15674, weight = 250 }, -- thf._boots_+1         lv75
    { itemId = 15675, weight = 250 }, -- pld._leggings_+1      lv75
    { itemId = 15676, weight = 250 }, -- drk._sabatons_+1      lv75
    { itemId = 15677, weight = 250 }, -- bst._gaiters_+1       lv75
    { itemId = 15678, weight = 250 }, -- brd._pigaches_+1      lv75
    -- Neck / accessories
    { itemId = 10919, weight = 255 }, -- tndm._necklace_+1     lv75
    { itemId = 11580, weight = 250 }, -- fylgja_torque_+1      lv75
    { itemId = 11582, weight = 250 }, -- ire_torque_+1         lv75
    { itemId = 11584, weight = 250 }, -- loquac._earring_+1    lv75
    { itemId = 15781, weight = 245 }, -- toreador_ring_+1      lv75
    { itemId = 15950, weight = 250 }, -- warwolf_belt_+1       lv75
    { itemId = 15952, weight = 250 }, -- life_belt_+1          lv75
    { itemId = 16053, weight = 245 }, -- suppanomimi_+1        lv75
    { itemId = 16216, weight = 245 }, -- amemet_mantle_+1      lv75
    { itemId = 27599, weight = 240 }, -- cheviot_cape_+1       lv75
    -- Shield
    { itemId = 12386, weight = 245 }, -- koenig_schaller_+1    lv75
    -- Weapons (job relic-adjacent lv75)
    { itemId = 17263, weight = 240 }, -- corsairs_gun_+1       lv75
    { itemId = 17568, weight = 240 }, -- joyeuse_+1            lv75
    { itemId = 18701, weight = 235 }, -- cerberus_bow_+1       lv75
    { itemId = 20784, weight = 230 }, -- uruz_blade_+1         lv75
}

xi.caskets.rarePools[xi.zone.RANGUEMONT_PASS]    = xi.caskets.rarePools[xi.zone.RANGUEMONT_PASS]    or tier7RareItems
xi.caskets.rarePools[xi.zone.RUAUN_GARDENS]      = xi.caskets.rarePools[xi.zone.RUAUN_GARDENS]      or tier7RareItems
xi.caskets.rarePools[xi.zone.VELUGANNON_PALACE]  = xi.caskets.rarePools[xi.zone.VELUGANNON_PALACE]  or tier7RareItems
xi.caskets.rarePools[xi.zone.THE_SHRINE_OF_RUAVITAU] = xi.caskets.rarePools[xi.zone.THE_SHRINE_OF_RUAVITAU] or tier7RareItems

return m
