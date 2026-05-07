-----------------------------------
-- Module: casket_gold_chest_custom_items
--
-- Injects custom-designed equipment (IDs 29700-29779) into Gold Chest
-- rare pools for the appropriate zone tier.
--
-- Items designated as "Custom NM Drop" in new_items_design.csv are
-- intentionally excluded; those will be wired up via LQS NM drops.
--
-- Must load AFTER casket_loot_starter_zones and casket_augment_tiers
-- so that xi.caskets.rarePools is already populated before we append.
-- (See modules/init.txt load order.)
--
-- All zones within a tier share the same Lua table reference, so
-- appending via one representative zone per tier propagates to every
-- zone in that tier.  Starter-zone pairs each have their own table,
-- so we append once per nation pair.
-----------------------------------
require('modules/module_utils')

local m = Module:new('casket_gold_chest_custom_items')

xi         = xi or {}
xi.caskets = xi.caskets or {}
xi.caskets.rarePools = xi.caskets.rarePools or {}

-----------------------------------
-- Starter zone custom items  (lv10-12)
-- Added to all three nation starter area pairs.
-- Weights kept modest (260-280) so they feel like a pleasant surprise
-- rather than crowding out the early bronze/leather gear.
-----------------------------------
local starterCustomItems =
{
    { itemId = 29705, weight = 270 }, -- Brushwood Helm        lv10  T1  WAR/MNK/PLD/DRK/DRG/SAM/RUN
    { itemId = 29730, weight = 260 }, -- Fieldwarden Cap       lv12  T1  BST/RNG/THF/DNC/COR
    { itemId = 29740, weight = 260 }, -- Tanner's Gloves       lv12  T1  BST/RNG/THF/DNC/COR/SAM
    { itemId = 29745, weight = 260 }, -- Herdsman's Trousers   lv12  T1  BST/WHM/RDM/BRD
    { itemId = 29750, weight = 260 }, -- Wanderer's Sandals    lv12  T1  WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29760, weight = 270 }, -- Cowhide Belt          lv12  T1  All Jobs
    { itemId = 29765, weight = 275 }, -- Copper Loop           lv10  T1  All Jobs
    { itemId = 29770, weight = 275 }, -- Bronze Ring           lv10  T1  All Jobs
    { itemId = 29775, weight = 260 }, -- Roughspun Cloak       lv12  T1  All Jobs
}

-----------------------------------
-- Tier 2 custom items  (lv15-29)
-- Zone range: La Theine / Konschtat / Tahrongi / Valkurm / Jugner /
--             Pashhow / Meriphataud / Buburimu / Inner+Outer Horutoto /
--             Zeruhn Mines / Dangruf Wadi
-----------------------------------
local tier2CustomItems =
{
    -- Weapons
    { itemId = 29700, weight = 255 }, -- Tarnished Gladius     lv15  T2  Sword   WAR/MNK/THF/PLD/DRK/RDM/NIN/BLU/COR
    { itemId = 29720, weight = 250 }, -- Ironwood Club         lv18  T2  Club    WHM/RDM/PLD/SCH/GEO/BLU
    { itemId = 29729, weight = 245 }, -- Reedwhisper Bow       lv25  T1  Bow     RNG/COR
    { itemId = 29721, weight = 245 }, -- Vipersting Dagger     lv25  T2  Dagger  THF/NIN/RDM/COR/DNC/BRD
    -- Head
    { itemId = 29731, weight = 240 }, -- Scholar's Mortarboard lv28  T2  SCH/BLM/WHM/SMN/GEO
    -- Body
    { itemId = 29708, weight = 255 }, -- Pilgrim's Coat        lv20  T1  WHM/RDM/SCH/GEO/PLD
    { itemId = 29735, weight = 255 }, -- Ashgrain Vest         lv15  T1  THF/RNG/NIN/DNC/BST/COR
    -- Hands
    { itemId = 29711, weight = 245 }, -- Stormcaller Mitts     lv25  T2  RNG/COR/BRD/BLU
    -- Legs
    { itemId = 29713, weight = 255 }, -- Dustwalker Subligar   lv15  T1  THF/RNG/NIN/DNC/BST/COR
    { itemId = 29746, weight = 240 }, -- Pathfinder Slops      lv28  T2  RNG/COR/BST/DNC/THF
    -- Feet
    { itemId = 29715, weight = 250 }, -- Mudstrider Boots      lv20  T2  THF/NIN/DNC/BST/RNG/COR/BRD
    -- Neck / waist / earring / ring
    { itemId = 29755, weight = 255 }, -- Ranger's Gorget       lv20  T2  All Jobs
    { itemId = 29761, weight = 250 }, -- Woven Cord            lv25  T1  All Jobs
    { itemId = 29766, weight = 250 }, -- Mage's Stud           lv25  T2  All Jobs
    { itemId = 29771, weight = 255 }, -- Apprentice's Ring     lv20  T1  All Jobs
}

-----------------------------------
-- Tier 3 custom items  (lv30-44)
-- Zone range: Qufim / Batallia / Rolanberry / Sauromugue / Yuhtunga /
--             Yhoator / Maze of Shakhrami / Ordelle's / King Ranperre's /
--             Gusgen Mines / Korroloka Tunnel
-----------------------------------
local tier3CustomItems =
{
    -- Weapons
    { itemId = 29701, weight = 255 }, -- Gale Axe              lv30  T2  Axe      WAR/DRK/BST/DRG
    { itemId = 29725, weight = 255 }, -- Ironknuckle Cestus    lv30  T2  H2H      MNK/PUP
    { itemId = 29722, weight = 245 }, -- Dustcleave Greataxe   lv35  T2  Gr.Axe   WAR/DRK
    { itemId = 29724, weight = 240 }, -- Thornlance            lv40  T2  Polearm  DRG/WAR
    -- Head
    { itemId = 29706, weight = 245 }, -- Ashen Circlet         lv35  T2  WHM/BLM/RDM/SMN/SCH/GEO
    -- Body
    { itemId = 29736, weight = 250 }, -- Duskweave Robe        lv30  T2  BLM/SMN/SCH/GEO/RDM
    -- Hands
    { itemId = 29741, weight = 245 }, -- Ember Mitts           lv32  T2  WAR/PLD/DRG/RUN/DRK
    -- Legs
    { itemId = 29747, weight = 250 }, -- Ironweave Cuisses     lv45  T2  WAR/PLD/DRG/DRK/SAM/RUN  (early lv45 access)
    -- Feet
    { itemId = 29751, weight = 250 }, -- Grimwatcher Greaves   lv30  T2  WAR/PLD/DRK/DRG/RUN
    -- Neck / waist / earring / ring / back
    { itemId = 29717, weight = 260 }, -- Cinnabar Necklace     lv30  T2  All Jobs
    { itemId = 29756, weight = 250 }, -- Ironhide Choker       lv35  T2  All Jobs
    { itemId = 29718, weight = 245 }, -- Burnished Sash        lv40  T2  WHM/BLM/RDM/SMN/SCH/GEO/BLU/PLD
    { itemId = 29762, weight = 245 }, -- Mercenary's Sash      lv40  T2  All Jobs
    { itemId = 29767, weight = 245 }, -- Warrior's Loop        lv35  T2  All Jobs
    { itemId = 29772, weight = 245 }, -- Soldier's Ring        lv38  T2  All Jobs
    { itemId = 29776, weight = 245 }, -- Tracker's Mantle      lv30  T2  RNG/BST/THF/COR/DNC
    { itemId = 29732, weight = 235 }, -- Brigand's Bandana     lv42  T2  THF/NIN/DNC/COR/RNG
}

-----------------------------------
-- Tier 4 custom items  (lv45-59)
-- Zone range: E/W Altepa / Crawler's Nest / Labyrinth of Onzozo /
--             Sanctuary of Zitah / Sea Serpent Grotto / Quicksand Caves /
--             Gustav Tunnel / Cape Teriggan / Kuftal Tunnel
-----------------------------------
local tier4CustomItems =
{
    -- Weapons
    { itemId = 29726, weight = 250 }, -- Cobaltedge Sword      lv45  T2  Sword  WAR/PLD/RDM/NIN/BLU
    -- Head
    -- (all T4 head pieces are NM-only)
    -- Body
    { itemId = 29737, weight = 245 }, -- Ironguard Hauberk     lv48  T2  WAR/DRK/DRG/SAM
    -- Hands
    { itemId = 29742, weight = 245 }, -- Spellthread Gloves    lv48  T2  WHM/BLM/RDM/SCH/GEO/SMN
    -- Legs
    { itemId = 29714, weight = 245 }, -- Crestfallen Slacks    lv45  T2  BLM/WHM/SMN/SCH/RDM/GEO
    -- Feet
    { itemId = 29752, weight = 245 }, -- Fleetfoot Sollerets   lv50  T2  WAR/SAM/DRG/DRK/RUN
    -- Neck / waist / earring / ring / back
    { itemId = 29757, weight = 250 }, -- Scholar's Collar      lv45  T2  All Jobs
    { itemId = 29758, weight = 240 }, -- Duelist's Chain       lv58  T3  All Jobs
    { itemId = 29763, weight = 240 }, -- Hexweave Obi          lv55  T2  BLM/RDM/SCH/GEO/SMN/WHM
    { itemId = 29768, weight = 240 }, -- Keen Earring          lv50  T2  All Jobs
    { itemId = 29773, weight = 240 }, -- Sorcerer's Band       lv52  T2  All Jobs
    { itemId = 29777, weight = 245 }, -- Ironguard Cape        lv45  T2  WAR/PLD/DRG/DRK/RUN
}

-----------------------------------
-- Helper: append a list of item entries to an existing pool table.
-- Safe to call with a nil pool (no-ops silently).
-----------------------------------
local function appendToPool(zone, items)
    local pool = xi.caskets.rarePools[zone]
    if not pool then
        return
    end
    for _, entry in ipairs(items) do
        pool[#pool + 1] = entry
    end
end

-----------------------------------
-- Starter zones
-- Each nation pair shares one pool table, so we append via one zone
-- per pair to avoid duplicate entries.
-----------------------------------
appendToPool(xi.zone.WEST_RONFAURE,     starterCustomItems) -- covers EAST_RONFAURE
appendToPool(xi.zone.NORTH_GUSTABERG,   starterCustomItems) -- covers SOUTH_GUSTABERG
appendToPool(xi.zone.WEST_SARUTABARUTA, starterCustomItems) -- covers EAST_SARUTABARUTA

-----------------------------------
-- Tiered zones
-- All zones within a tier share one pool table, so one representative
-- zone per tier is sufficient.
-----------------------------------
appendToPool(xi.zone.LA_THEINE_PLATEAU,     tier2CustomItems) -- all T2 zones
appendToPool(xi.zone.QUFIM_ISLAND,          tier3CustomItems) -- all T3 zones
appendToPool(xi.zone.EASTERN_ALTEPA_DESERT, tier4CustomItems) -- all T4 zones

return m
