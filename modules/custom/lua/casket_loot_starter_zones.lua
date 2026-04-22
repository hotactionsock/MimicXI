-----------------------------------
-- Module: casket_loot_starter_zones
--
-- Adds a Gold (rare) casket tier to the three starter-area zone pairs:
--   West/East Ronfaure     (San d'Oria, lv 1-12)
--   North/South Gustaberg  (Bastok,     lv 1-12)
--   West/East Sarutabaruta (Windurst,   lv 1-12)
--
-- Gold caskets spawn at a 5% rate (replacing nothing; the existing 85/15
-- blue/brown split is preserved for zones without a rareItems pool).
-- They contain level-appropriate HQ (+1/+2) gear, optionally augmented
-- once xi.caskets.augmentPools is populated.
--
-- To disable this module: comment out its line in modules/init.txt.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/augment')

local m = Module:new('casket_loot_starter_zones')

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
-- Inject rareItems into existing zone loot tables on server start.
-- The temps/items/regionalItems in casket_loot.lua are left untouched.
-----------------------------------
m:addOverride('xi.server.onServerStart', function()
    super()

    local casketItems = xi.casket_loot.casketItems

    -- Ronfaure (both zones share the same rare pool)
    if casketItems[xi.zone.WEST_RONFAURE] then
        casketItems[xi.zone.WEST_RONFAURE].rareItems = ronfaureRareItems
    end
    if casketItems[xi.zone.EAST_RONFAURE] then
        casketItems[xi.zone.EAST_RONFAURE].rareItems = ronfaureRareItems
    end

    -- Gustaberg (both zones share the same rare pool)
    if casketItems[xi.zone.NORTH_GUSTABERG] then
        casketItems[xi.zone.NORTH_GUSTABERG].rareItems = gustabergRareItems
    end
    if casketItems[xi.zone.SOUTH_GUSTABERG] then
        casketItems[xi.zone.SOUTH_GUSTABERG].rareItems = gustabergRareItems
    end

    -- Sarutabaruta (both zones share the same rare pool)
    if casketItems[xi.zone.WEST_SARUTABARUTA] then
        casketItems[xi.zone.WEST_SARUTABARUTA].rareItems = sarutabarutaRareItems
    end
    if casketItems[xi.zone.EAST_SARUTABARUTA] then
        casketItems[xi.zone.EAST_SARUTABARUTA].rareItems = sarutabarutaRareItems
    end
end)

return m
