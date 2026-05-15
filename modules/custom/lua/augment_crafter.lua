-----------------------------------
-- Module: augment_crafter
--
-- Defines the augment pool for each catalyst stone used in the crafting
-- augmentation system.  Three stone families exist, each with four tiers:
--
--   Snow (Alchemy / Ice crystal) — defensive and support augments
--     T1  Snowslit Stone  (8931)  — Defense, HP
--     T2  Snowtip  Stone  (8940)  + Cure Potency
--     T3  Snowdim  Stone  (8949)  + Phys.Dmg.Taken
--     T4  Snoworb  Stone  (8958)  + Refresh, Fast Cast
--
--   Leaf (Clothcraft / Wind crystal) — melee accuracy and subtle-blow
--     T1  Leafslit Stone  (8934)  — Accuracy, Attack
--     T2  Leaftip  Stone  (8943)  + Subtle Blow
--     T3  Leafdim  Stone  (8952)  + INT+MND+CHR triple stat
--     T4  Leaforb  Stone  (8961)  (higher value caps)
--
--   Dusk (Goldsmithing / Dark crystal) — proc and WS augments
--     T1  Duskslit Stone  (8937)  — Counter
--     T2  Dusktip  Stone  (8946)  + Double Attack, Snapshot
--     T3  Duskdim  Stone  (8955)  + Triple Attack, WS Damage
--     T4  Duskorb  Stone  (8964)  (higher value caps)
--
-- xi.augments.catalystPools is keyed by stone item ID.
-- Each entry is a list of { id, min, max } augment candidates.
-- Phase 2 (C++) reads this table to roll one augment from the pool on a
-- successful synthesis and writes it to the target item via AugmentStandard.
--
-- Augment IDs reference the `augments` SQL table.
-- Notable IDs used here:
--   1=HP  33=Defense  54=Phys.Dmg.Taken  138=Refresh  140=Fast.Cast  329=Cure.Potency
--   23=Accuracy  25=Attack  195=Subtle.Blow  556=INT+MND+CHR
--   143=Dbl.Atk.  144=Triple.Atk.  145=Counter  211=Snapshot  327=WS.Damage
-----------------------------------
require('modules/module_utils')

local m = Module:new('augment_crafter')

xi              = xi or {}
xi.augments     = xi.augments or {}
xi.augments.id  = xi.augments.id or {}

xi.augments.catalystPools = xi.augments.catalystPools or {}

-----------------------------------
-- Snow Stones — defensive / support
-----------------------------------

-- T1: Defense and HP only
xi.augments.catalystPools[xi.item.SNOWSLIT_STONE_P1] =
{
    { id =  1, min =  5, max = 10 }, -- HP+5 to +10
    { id = 33, min =  1, max =  3 }, -- Defense+1 to +3
}

-- T2: adds Cure Potency
xi.augments.catalystPools[xi.item.SNOWTIP_STONE_P1] =
{
    { id =  1,   min =  8, max = 15 }, -- HP+8 to +15
    { id = 33,   min =  2, max =  4 }, -- Defense+2 to +4
    { id = 329,  min =  1, max =  2 }, -- Cure Potency+1% to +2%
}

-- T3: adds Phys.Dmg.Taken
xi.augments.catalystPools[xi.item.SNOWDIM_STONE_P1] =
{
    { id =  1,   min = 12, max = 20 }, -- HP+12 to +20
    { id = 33,   min =  3, max =  5 }, -- Defense+3 to +5
    { id = 329,  min =  2, max =  3 }, -- Cure Potency+2% to +3%
    { id = 54,   min =  1, max =  1 }, -- Phys.Dmg.Taken-1%
}

-- T4: adds Refresh and Fast Cast
xi.augments.catalystPools[xi.item.SNOWORB_STONE_P1] =
{
    { id =  1,   min = 15, max = 30 }, -- HP+15 to +30
    { id = 33,   min =  4, max =  6 }, -- Defense+4 to +6
    { id = 329,  min =  2, max =  4 }, -- Cure Potency+2% to +4%
    { id = 54,   min =  1, max =  2 }, -- Phys.Dmg.Taken-1% to -2%
    { id = 138,  min =  1, max =  1 }, -- Refresh+1
    { id = 140,  min =  1, max =  3 }, -- Fast Cast+1% to +3%
}

-----------------------------------
-- Leaf Stones — melee accuracy / subtle-blow
-----------------------------------

-- T1: Accuracy and Attack
xi.augments.catalystPools[xi.item.LEAFSLIT_STONE_P1] =
{
    { id = 23,  min =  2, max =  4 }, -- Accuracy+2 to +4
    { id = 25,  min =  2, max =  4 }, -- Attack+2 to +4
}

-- T2: adds Subtle Blow
xi.augments.catalystPools[xi.item.LEAFTIP_STONE_P1] =
{
    { id = 23,  min =  3, max =  6 }, -- Accuracy+3 to +6
    { id = 25,  min =  3, max =  6 }, -- Attack+3 to +6
    { id = 195, min =  1, max =  2 }, -- Subtle Blow+1 to +2
}

-- T3: adds INT+MND+CHR triple stat
xi.augments.catalystPools[xi.item.LEAFDIM_STONE_P1] =
{
    { id = 23,  min =  5, max =  8 }, -- Accuracy+5 to +8
    { id = 25,  min =  5, max =  8 }, -- Attack+5 to +8
    { id = 195, min =  2, max =  4 }, -- Subtle Blow+2 to +4
    { id = 556, min =  1, max =  2 }, -- INT+MND+CHR+1 to +2
}

-- T4: higher value caps
xi.augments.catalystPools[xi.item.LEAFORB_STONE_P1] =
{
    { id = 23,  min =  6, max = 12 }, -- Accuracy+6 to +12
    { id = 25,  min =  6, max = 12 }, -- Attack+6 to +12
    { id = 195, min =  3, max =  6 }, -- Subtle Blow+3 to +6
    { id = 556, min =  2, max =  4 }, -- INT+MND+CHR+2 to +4
}

-----------------------------------
-- Dusk Stones — proc and WS augments
-----------------------------------

-- T1: Counter only
xi.augments.catalystPools[xi.item.DUSKSLIT_STONE_P1] =
{
    { id = 145, min =  1, max =  2 }, -- Counter+1 to +2
}

-- T2: adds Double Attack and Snapshot
xi.augments.catalystPools[xi.item.DUSKTIP_STONE_P1] =
{
    { id = 145, min =  2, max =  3 }, -- Counter+2 to +3
    { id = 143, min =  1, max =  2 }, -- Dbl.Atk.+1% to +2%
    { id = 211, min =  1, max =  2 }, -- Snapshot+1 to +2
}

-- T3: adds Triple Attack and WS Damage
xi.augments.catalystPools[xi.item.DUSKDIM_STONE_P1] =
{
    { id = 145, min =  3, max =  4 }, -- Counter+3 to +4
    { id = 143, min =  2, max =  3 }, -- Dbl.Atk.+2% to +3%
    { id = 211, min =  2, max =  3 }, -- Snapshot+2 to +3
    { id = 144, min =  1, max =  2 }, -- Triple Atk.+1% to +2%
    { id = 327, min =  1, max =  2 }, -- WS Damage+1% to +2%
}

-- T4: higher value caps across all dusk augments
xi.augments.catalystPools[xi.item.DUSKORB_STONE_P1] =
{
    { id = 145, min =  4, max =  6 }, -- Counter+4 to +6
    { id = 143, min =  3, max =  5 }, -- Dbl.Atk.+3% to +5%
    { id = 211, min =  3, max =  5 }, -- Snapshot+3 to +5
    { id = 144, min =  2, max =  4 }, -- Triple Atk.+2% to +4%
    { id = 327, min =  2, max =  4 }, -- WS Damage+2% to +4%
}

return m
