-----------------------------------
-- Module: casket_loot_starter_zones
--
-- Adds a Gold (rare) casket tier to the three starter-area zone pairs:
--   West/East Ronfaure     (San d'Oria, lv 1-12)
--   North/South Gustaberg  (Bastok,     lv 1-12)
--   West/East Sarutabaruta (Windurst,   lv 1-12)
--
-- Gold caskets spawn at a 5% rate (replacing nothing; the existing 85/15
-- blue/brown split is preserved for zones without a rarePools entry).
-- They contain level-appropriate HQ (+1/+2) gear, optionally augmented
-- once xi.caskets.augmentPools is populated.
--
-- Rare pools are registered in xi.caskets.rarePools at module load time so
-- they survive the lazy re-execution of casket_loot.lua that happens when
-- the first player enters a casket zone.
--
-- To disable this module: comment out its line in modules/init.txt.
-----------------------------------
require('modules/module_utils')

local m = Module:new('casket_loot_starter_zones')

-- Augment stat IDs from augments.sql (packet IDs, not dat IDs)
xi          = xi          or {}
xi.augments = xi.augments or {}
xi.augments.id = xi.augments.id or
{
    HP              =   1,
    MP              =   9,
    ACCURACY        =  23,
    ATTACK          =  25,
    RANGED_ACCURACY =  27,
    RANGED_ATTACK   =  29,
    EVASION         =  31,
    DEFENSE         =  33,
    MAG_ACCURACY    =  35,
    STORE_TP        =  44,
    STR             = 512,
    DEX             = 513,
    VIT             = 514,
    AGI             = 515,
    INT             = 516,
    MND             = 517,
    CHR             = 518,
}

-----------------------------------
-- Augment pool (populated later).
-- Format per item:
--   [itemId] = {
--       { id = augmentId, min = minValue, max = maxValue },
--       ...
--   }
-- Augment IDs reference the `augments` SQL table (see sql/augments.sql).
-- Example (not active):
--   [16623] = {  -- Bronze Sword +1
--       { id = 45, min = 1, max = 2 },  -- DMG:+1 to +2
--       { id = 44, min = 1, max = 1 },  -- Store TP+1
--   },
-----------------------------------
xi         = xi or {}
xi.caskets = xi.caskets or {}
xi.caskets.augmentPools = xi.caskets.augmentPools or {}

-----------------------------------
-- Rare item pools
-- All item IDs confirmed against item_equipment.sql / item_basic.sql.
-- Weights are relative; higher = more likely.
-----------------------------------

-- Shared across both Ronfaure zones (military/balanced focus)
local ronfaureRareItems =
{
    -- Bronze lv1 +1
    { itemId = 16623, weight = 350 }, -- bronze_sword_+1
    { itemId = 16646, weight = 320 }, -- bronze_axe_+1
    { itemId = 16492, weight = 300 }, -- bronze_dagger_+1
    { itemId = 16491, weight = 290 }, -- bronze_knife_+1
    { itemId = 12463, weight = 340 }, -- bronze_cap_+1
    { itemId = 12607, weight = 330 }, -- bronze_harness_+1
    { itemId = 12695, weight = 310 }, -- bronze_mittens_+1
    { itemId = 12951, weight = 310 }, -- brz._leggings_+1
    -- Leather lv7 +1
    { itemId = 12599, weight = 350 }, -- leather_vest_+1
    { itemId = 12784, weight = 320 }, -- leather_gloves_+1
    { itemId = 12971, weight = 300 }, -- lth._highboots_+1
    { itemId = 13069, weight = 280 }, -- leather_gorget_+1
    { itemId = 13210, weight = 270 }, -- leather_belt_+1
    { itemId = 16918, weight = 260 }, -- wakizashi_+1
    -- Mid lv8 +1
    { itemId = 12330, weight = 280 }, -- maple_shield_+1
    { itemId = 16661, weight = 270 }, -- brass_axe_+1
    { itemId = 12616, weight = 260 }, -- tunic_+1
    { itemId = 12898, weight = 250 }, -- slacks_+1
    -- Brass lv11 +1
    { itemId = 12528, weight = 280 }, -- brass_cap_+1
    { itemId = 12664, weight = 270 }, -- brass_harness_+1
    { itemId = 12770, weight = 250 }, -- brass_mittens_+1
    { itemId = 13027, weight = 240 }, -- brass_leggings_+1
    -- lv12 +1
    { itemId = 16736, weight = 200 }, -- dagger_+1
    { itemId = 17225, weight = 190 }, -- crossbow_+1
    { itemId = 17149, weight = 195 }, -- brass_hammer_+1
}

-- Shared across both Gustaberg zones (Bastok: mining/forging emphasis)
local gustabergRareItems =
{
    -- Bronze lv1 +1
    { itemId = 16623, weight = 350 }, -- bronze_sword_+1
    { itemId = 16646, weight = 330 }, -- bronze_axe_+1
    { itemId = 16492, weight = 300 }, -- bronze_dagger_+1
    { itemId = 16491, weight = 290 }, -- bronze_knife_+1
    { itemId = 12463, weight = 340 }, -- bronze_cap_+1
    { itemId = 12607, weight = 330 }, -- bronze_harness_+1
    { itemId = 12695, weight = 310 }, -- bronze_mittens_+1
    { itemId = 12951, weight = 310 }, -- brz._leggings_+1
    -- lv4-7 weapon +1
    { itemId = 17086, weight = 280 }, -- bronze_mace_+1
    { itemId = 17144, weight = 270 }, -- bronze_hammer_+1
    { itemId = 16859, weight = 260 }, -- bronze_spear_+1
    { itemId = 16716, weight = 250 }, -- butterfly_axe_+1
    -- Leather lv7 +1
    { itemId = 12599, weight = 310 }, -- leather_vest_+1
    { itemId = 12784, weight = 290 }, -- leather_gloves_+1
    { itemId = 13069, weight = 270 }, -- leather_gorget_+1
    { itemId = 13210, weight = 260 }, -- leather_belt_+1
    -- Mid lv8-9 +1
    { itemId = 16661, weight = 260 }, -- brass_axe_+1
    { itemId = 12616, weight = 250 }, -- tunic_+1
    { itemId = 16740, weight = 240 }, -- brass_dagger_+1
    -- Brass lv11 +1
    { itemId = 12528, weight = 280 }, -- brass_cap_+1
    { itemId = 12664, weight = 270 }, -- brass_harness_+1
    { itemId = 12770, weight = 260 }, -- brass_mittens_+1
    { itemId = 13027, weight = 250 }, -- brass_leggings_+1
    -- lv12 +1
    { itemId = 16736, weight = 200 }, -- dagger_+1
    { itemId = 16717, weight = 190 }, -- greataxe_+1
    { itemId = 17149, weight = 195 }, -- brass_hammer_+1
    { itemId = 17225, weight = 185 }, -- crossbow_+1
}

-- Shared across both Sarutabaruta zones (Windurst: magic/nature emphasis)
local sarutabarutaRareItems =
{
    -- Bronze lv1 +1 (lighter selection; Windurst favors magic)
    { itemId = 16492, weight = 300 }, -- bronze_dagger_+1
    { itemId = 16491, weight = 290 }, -- bronze_knife_+1
    { itemId = 12463, weight = 310 }, -- bronze_cap_+1
    { itemId = 12607, weight = 300 }, -- bronze_harness_+1
    { itemId = 12695, weight = 280 }, -- bronze_mittens_+1
    { itemId = 12951, weight = 280 }, -- brz._leggings_+1
    -- Magic/ranged lv1-5 +1 (Windurst theme)
    { itemId = 17137, weight = 330 }, -- ash_club_+1    (lv1)
    { itemId = 17111, weight = 300 }, -- bronze_rod_+1  (lv5)
    { itemId = 17122, weight = 310 }, -- ash_pole_+1    (lv5)
    { itemId = 17177, weight = 290 }, -- longbow_+1     (lv5)
    { itemId = 17144, weight = 260 }, -- bronze_hammer_+1 (lv5)
    -- Leather lv7 +1
    { itemId = 12599, weight = 310 }, -- leather_vest_+1
    { itemId = 12784, weight = 290 }, -- leather_gloves_+1
    { itemId = 13069, weight = 270 }, -- leather_gorget_+1
    { itemId = 13210, weight = 260 }, -- leather_belt_+1
    { itemId = 17176, weight = 280 }, -- self_bow_+1    (lv7)
    -- Mid lv9 +1
    { itemId = 17138, weight = 310 }, -- willow_wand_+1 (lv9)
    { itemId = 16740, weight = 240 }, -- brass_dagger_+1
    { itemId = 16689, weight = 230 }, -- brass_knuckles_+1
    -- Brass lv11 +1
    { itemId = 12528, weight = 270 }, -- brass_cap_+1
    { itemId = 12664, weight = 260 }, -- brass_harness_+1
    { itemId = 12770, weight = 250 }, -- brass_mittens_+1
    { itemId = 17125, weight = 290 }, -- holly_staff_+1 (lv11)
    -- Accessories lv10 +1
    { itemId = 12529, weight = 230 }, -- brass_hairpin_+1
    { itemId = 13285, weight = 210 }, -- eremites_ring_+1
    { itemId = 13283, weight = 210 }, -- saintly_ring_+1
    -- lv12 +1
    { itemId = 17148, weight = 200 }, -- brass_rod_+1
    { itemId = 16736, weight = 190 }, -- dagger_+1
}

-----------------------------------
-- Register rare pools directly into xi.caskets.rarePools at module load
-- time. Modules load after all scripts/globals (including zone enums), so
-- xi.zone.* constants are guaranteed to be defined here. Storing in
-- xi.caskets.rarePools instead of injecting into xi.casket_loot.casketItems
-- avoids being wiped by the lazy re-execution of casket_loot.lua that occurs
-- when the first player enters a casket zone.
-----------------------------------
xi.caskets.rarePools = xi.caskets.rarePools or {}

xi.caskets.rarePools[xi.zone.WEST_RONFAURE]     = ronfaureRareItems
xi.caskets.rarePools[xi.zone.EAST_RONFAURE]     = ronfaureRareItems
xi.caskets.rarePools[xi.zone.NORTH_GUSTABERG]   = gustabergRareItems
xi.caskets.rarePools[xi.zone.SOUTH_GUSTABERG]   = gustabergRareItems
xi.caskets.rarePools[xi.zone.WEST_SARUTABARUTA] = sarutabarutaRareItems
xi.caskets.rarePools[xi.zone.EAST_SARUTABARUTA] = sarutabarutaRareItems

-----------------------------------
-- Augment pools for Gold casket loot
--
-- When a Gold casket gives out an item that has an entry here, the casket
-- system randomly picks 1–2 of the listed augments (without repeating) and
-- applies them to the item before handing it to the player.
--
-- Format:
--   [itemId] = {
--       { id = xi.augments.id.STAT, min = minValue, max = maxValue },
--       ...
--   }
--
-- Augment IDs: see scripts/globals/augment.lua → xi.augments.id
-- To add more augment pools, append entries below using the same pattern.
-- Leave xi.caskets.augmentPools empty (or omit an item) for a plain HQ drop.
-----------------------------------
xi.caskets.augmentPools =
{
    ------------------------------------
    -- Bronze (lv1) weapons
    ------------------------------------

    -- Bronze Sword +1
    [16623] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
        { id = xi.augments.id.DEX,      min = 1, max = 1 },
    },

    -- Bronze Axe +1
    [16646] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
        { id = xi.augments.id.VIT,      min = 1, max = 1 },
    },

    -- Bronze Dagger +1
    [16492] =
    {
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.DEX,      min = 1, max = 1 },
        { id = xi.augments.id.STORE_TP, min = 1, max = 1 },
    },

    -- Bronze Knife +1
    [16491] =
    {
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.AGI,      min = 1, max = 1 },
        { id = xi.augments.id.EVASION,  min = 1, max = 2 },
    },

    -- Ash Club +1 (lv1 club — mage/WHM starter)
    [17137] =
    {
        { id = xi.augments.id.MP,           min = 3, max = 6 },
        { id = xi.augments.id.INT,          min = 1, max = 1 },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 2 },
    },

    ------------------------------------
    -- Bronze (lv1) armor
    ------------------------------------

    -- Bronze Cap +1
    [12463] =
    {
        { id = xi.augments.id.HP,      min = 3, max = 6 },
        { id = xi.augments.id.DEFENSE, min = 1, max = 2 },
        { id = xi.augments.id.VIT,     min = 1, max = 1 },
    },

    -- Bronze Harness +1
    [12607] =
    {
        { id = xi.augments.id.HP,      min = 5, max = 10 },
        { id = xi.augments.id.DEFENSE, min = 1, max = 2  },
        { id = xi.augments.id.STR,     min = 1, max = 1  },
    },

    -- Bronze Mittens +1
    [12695] =
    {
        { id = xi.augments.id.HP,      min = 2, max = 5 },
        { id = xi.augments.id.DEFENSE, min = 1, max = 2 },
        { id = xi.augments.id.DEX,     min = 1, max = 1 },
        { id = xi.augments.id.STR,     min = 1, max = 1 },
    },

    -- Bronze Leggings +1
    [12951] =
    {
        { id = xi.augments.id.HP,      min = 2, max = 5 },
        { id = xi.augments.id.DEFENSE, min = 1, max = 2 },
        { id = xi.augments.id.VIT,     min = 1, max = 1 },
    },

    ------------------------------------
    -- lv4–5 weapons
    ------------------------------------

    -- Bronze Mace +1 (lv4, often used by WHM/MNK)
    [17086] =
    {
        { id = xi.augments.id.ATTACK, min = 1, max = 2 },
        { id = xi.augments.id.MND,    min = 1, max = 1 },
        { id = xi.augments.id.STR,    min = 1, max = 1 },
    },

    -- Bronze Rod +1 (lv5 rod — BLM/RDM/WHM)
    [17111] =
    {
        { id = xi.augments.id.MP,           min = 3, max = 6 },
        { id = xi.augments.id.INT,          min = 1, max = 1 },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 2 },
    },

    -- Ash Pole +1 (lv5 polearm — RDM/BLM/WHM secondary)
    [17122] =
    {
        { id = xi.augments.id.INT,          min = 1, max = 1 },
        { id = xi.augments.id.MND,          min = 1, max = 1 },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 2 },
    },

    -- Bronze Hammer +1 (lv5 great katana / 2H)
    [17144] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 1 },
    },

    -- Longbow +1 (lv5 bow)
    [17177] =
    {
        { id = xi.augments.id.RANGED_ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.RANGED_ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.AGI,             min = 1, max = 1 },
    },

    ------------------------------------
    -- Leather (lv7) armor
    ------------------------------------

    -- Leather Vest +1
    [12599] =
    {
        { id = xi.augments.id.HP,       min = 5, max = 10 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2  },
        { id = xi.augments.id.DEX,      min = 1, max = 1  },
        { id = xi.augments.id.AGI,      min = 1, max = 1  },
    },

    -- Leather Gloves +1
    [12784] =
    {
        { id = xi.augments.id.DEX,      min = 1, max = 1 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.AGI,      min = 1, max = 1 },
        { id = xi.augments.id.STORE_TP, min = 1, max = 1 },
    },

    -- Leather Highboots +1
    [12971] =
    {
        { id = xi.augments.id.AGI,     min = 1, max = 1 },
        { id = xi.augments.id.EVASION, min = 1, max = 2 },
        { id = xi.augments.id.DEX,     min = 1, max = 1 },
    },

    -- Leather Gorget +1 (neck — balanced melee)
    [13069] =
    {
        { id = xi.augments.id.STR,      min = 1, max = 1 },
        { id = xi.augments.id.DEX,      min = 1, max = 1 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
    },

    -- Leather Belt +1 (waist)
    [13210] =
    {
        { id = xi.augments.id.STORE_TP, min = 1, max = 1 },
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
    },

    ------------------------------------
    -- lv7–8 weapons
    ------------------------------------

    -- Wakizashi +1 (lv7 katana — NIN)
    [16918] =
    {
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.DEX,      min = 1, max = 1 },
        { id = xi.augments.id.STORE_TP, min = 1, max = 1 },
    },

    -- Self Bow +1 (lv7 bow)
    [17176] =
    {
        { id = xi.augments.id.RANGED_ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.RANGED_ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.AGI,             min = 1, max = 1 },
    },

    -- Brass Axe +1 (lv8 axe)
    [16661] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
    },

    -- Butterfly Axe +1 (lv8 axe — WAR/DRK)
    [16716] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
    },

    -- Bronze Spear +1 (lv8 spear — DRG/WAR)
    [16859] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
    },

    ------------------------------------
    -- lv8–9 misc armor
    ------------------------------------

    -- Maple Shield +1 (lv8 shield)
    [12330] =
    {
        { id = xi.augments.id.HP,      min = 5, max = 10 },
        { id = xi.augments.id.DEFENSE, min = 1, max = 2  },
        { id = xi.augments.id.VIT,     min = 1, max = 1  },
    },

    -- Tunic +1 (lv8 body — light/mage)
    [12616] =
    {
        { id = xi.augments.id.HP,      min = 5, max = 10 },
        { id = xi.augments.id.DEFENSE, min = 1, max = 2  },
        { id = xi.augments.id.MND,     min = 1, max = 1  },
    },

    -- Slacks +1 (lv8 legs — light/mage)
    [12898] =
    {
        { id = xi.augments.id.HP,      min = 5, max = 10 },
        { id = xi.augments.id.DEFENSE, min = 1, max = 2  },
        { id = xi.augments.id.INT,     min = 1, max = 1  },
    },

    ------------------------------------
    -- lv9 weapons
    ------------------------------------

    -- Brass Dagger +1 (lv9)
    [16740] =
    {
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.DEX,      min = 1, max = 1 },
    },

    -- Willow Wand +1 (lv9 wand — WHM/BLM/RDM)
    [17138] =
    {
        { id = xi.augments.id.MP,           min = 5, max = 10 },
        { id = xi.augments.id.MND,          min = 1, max = 1  },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 2  },
    },

    -- Brass Knuckles +1 (lv9 H2H — MNK/PUP)
    [16689] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.DEX,      min = 1, max = 1 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
    },

    ------------------------------------
    -- lv10 accessories (Sarutabaruta)
    ------------------------------------

    -- Brass Hairpin +1 (lv10 head — mage)
    [12529] =
    {
        { id = xi.augments.id.MP,           min = 3, max = 8 },
        { id = xi.augments.id.INT,          min = 1, max = 1 },
        { id = xi.augments.id.MND,          min = 1, max = 1 },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 2 },
    },

    -- Eremite's Ring +1 (lv10 ring — BLM focus)
    [13285] =
    {
        { id = xi.augments.id.MP,           min = 3, max = 8 },
        { id = xi.augments.id.INT,          min = 1, max = 1 },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 2 },
    },

    -- Saintly Ring +1 (lv10 ring — WHM focus)
    [13283] =
    {
        { id = xi.augments.id.MP,           min = 3, max = 8 },
        { id = xi.augments.id.MND,          min = 1, max = 1 },
        { id = xi.augments.id.CHR,          min = 1, max = 1 },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 2 },
    },

    ------------------------------------
    -- Brass (lv11) armor
    ------------------------------------

    -- Brass Cap +1
    [12528] =
    {
        { id = xi.augments.id.HP,      min = 5,  max = 12 },
        { id = xi.augments.id.DEFENSE, min = 1,  max = 2  },
        { id = xi.augments.id.STR,     min = 1,  max = 1  },
        { id = xi.augments.id.VIT,     min = 1,  max = 1  },
    },

    -- Brass Harness +1
    [12664] =
    {
        { id = xi.augments.id.HP,      min = 8,  max = 15 },
        { id = xi.augments.id.DEFENSE, min = 1,  max = 3  },
        { id = xi.augments.id.STR,     min = 1,  max = 1  },
    },

    -- Brass Mittens +1
    [12770] =
    {
        { id = xi.augments.id.HP,      min = 5,  max = 12 },
        { id = xi.augments.id.DEFENSE, min = 1,  max = 2  },
        { id = xi.augments.id.STR,     min = 1,  max = 1  },
        { id = xi.augments.id.DEX,     min = 1,  max = 1  },
    },

    -- Brass Leggings +1
    [13027] =
    {
        { id = xi.augments.id.HP,      min = 5,  max = 12 },
        { id = xi.augments.id.DEFENSE, min = 1,  max = 2  },
        { id = xi.augments.id.VIT,     min = 1,  max = 1  },
        { id = xi.augments.id.STR,     min = 1,  max = 1  },
    },

    ------------------------------------
    -- lv11 weapons
    ------------------------------------

    -- Holly Staff +1 (lv11 staff — WHM/BLM/RDM)
    [17125] =
    {
        { id = xi.augments.id.MP,           min = 8, max = 15 },
        { id = xi.augments.id.INT,          min = 1, max = 1  },
        { id = xi.augments.id.MND,          min = 1, max = 1  },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 2  },
    },

    -- Brass Hammer +1 (lv11 great katana / 2H — WAR/MNK)
    [17149] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 3 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 1 },
        { id = xi.augments.id.VIT,      min = 1, max = 1 },
    },

    ------------------------------------
    -- lv12 weapons
    ------------------------------------

    -- Dagger +1 (lv12 — THF/NIN/RDM)
    [16736] =
    {
        { id = xi.augments.id.ACCURACY, min = 1, max = 3 },
        { id = xi.augments.id.ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.DEX,      min = 1, max = 1 },
        { id = xi.augments.id.STORE_TP, min = 1, max = 1 },
    },

    -- Greataxe +1 (lv12 — WAR/DRK)
    [16717] =
    {
        { id = xi.augments.id.ATTACK,   min = 1, max = 3 },
        { id = xi.augments.id.ACCURACY, min = 1, max = 2 },
        { id = xi.augments.id.STR,      min = 1, max = 2 },
    },

    -- Brass Rod +1 (lv12 rod — BLM/RDM/WHM)
    [17148] =
    {
        { id = xi.augments.id.MP,           min = 8, max = 15 },
        { id = xi.augments.id.INT,          min = 1, max = 1  },
        { id = xi.augments.id.MND,          min = 1, max = 1  },
        { id = xi.augments.id.MAG_ACCURACY, min = 1, max = 3  },
    },

    -- Crossbow +1 (lv12 — RNG/COR)
    [17225] =
    {
        { id = xi.augments.id.RANGED_ACCURACY, min = 1, max = 3 },
        { id = xi.augments.id.RANGED_ATTACK,   min = 1, max = 2 },
        { id = xi.augments.id.AGI,             min = 1, max = 1 },
    },
}

return m
