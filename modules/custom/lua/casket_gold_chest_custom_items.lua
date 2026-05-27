-----------------------------------
-- Module: casket_gold_chest_custom_items
--
-- Injects custom-designed equipment (IDs 29700-29819) into Gold Chest
-- rare pools for the appropriate zone tier.
--
-- Items designated as "Custom NM Drop" in new_items_design.csv are
-- intentionally excluded; those will be wired up via LQS NM drops.
--
-- Must load AFTER casket_loot_starter_zones and casket_augment_tiers
-- so that xi.caskets.rarePools is already populated before we append.
-- (See modules/init.txt load order.)
--
-- appendToZones() deduplicates on the underlying pool table so zones
-- that share a reference (the norm within a tier) are only modified
-- once, while every zone in the tier is explicitly listed.
-----------------------------------
require('modules/module_utils')

local m = Module:new('casket_gold_chest_custom_items')

xi         = xi or {}
xi.caskets = xi.caskets or {}
xi.caskets.rarePools = xi.caskets.rarePools or {}

-----------------------------------
-- Helper
-----------------------------------
local function appendToZones(zones, items)
    local seen = {}
    for _, zone in ipairs(zones) do
        local pool = xi.caskets.rarePools[zone]
        if pool and not seen[pool] then
            seen[pool] = true
            for _, entry in ipairs(items) do
                pool[#pool + 1] = entry
            end
        end
    end
end

-----------------------------------
-- Starter zone custom items  (lv10-15)
-- Batches 1-3 combined.
-----------------------------------
local starterCustomItems =
{
    -- Batch 1
    { itemId = 29705, weight = 270 }, -- Brushwood Helm        lv10  T1  WAR/MNK/PLD/DRK/DRG/SAM/RUN
    { itemId = 29730, weight = 260 }, -- Fieldwarden Cap       lv12  T1  BST/RNG/THF/DNC/COR
    { itemId = 29740, weight = 260 }, -- Tanner's Gloves       lv12  T1  BST/RNG/THF/DNC/COR/SAM
    { itemId = 29745, weight = 260 }, -- Herdsman's Trousers   lv12  T1  BST/WHM/RDM/BRD
    { itemId = 29750, weight = 260 }, -- Wanderer's Sandals    lv12  T1  WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29760, weight = 270 }, -- Cowhide Belt          lv12  T1  All Jobs
    { itemId = 29765, weight = 275 }, -- Copper Loop           lv10  T1  All Jobs
    { itemId = 29770, weight = 275 }, -- Bronze Ring           lv10  T1  All Jobs
    { itemId = 29775, weight = 260 }, -- Roughspun Cloak       lv12  T1  All Jobs
    -- Batch 3
    { itemId = 29782, weight = 255 }, -- Needlefang Knife      lv10  T1  THF/NIN/RDM/COR/DNC/BRD
}

-----------------------------------
-- Tier 2 custom items  (lv15-29)
-- Zone range: La Theine / Konschtat / Tahrongi / Valkurm / Jugner /
--             Pashhow / Meriphataud / Buburimu / Inner+Outer Horutoto /
--             Zeruhn Mines / Dangruf Wadi
-----------------------------------
local tier2CustomItems =
{
    -- Batch 1
    { itemId = 29700, weight = 255 }, -- Tarnished Gladius     lv15  T2  Sword   WAR/MNK/THF/PLD/DRK/RDM/NIN/BLU/COR
    { itemId = 29713, weight = 255 }, -- Dustwalker Subligar   lv15  T1  THF/RNG/NIN/DNC/BST/COR
    { itemId = 29735, weight = 255 }, -- Ashgrain Vest         lv15  T1  THF/RNG/NIN/DNC/BST/COR
    { itemId = 29720, weight = 250 }, -- Ironwood Club         lv18  T2  Club    WHM/RDM/PLD/SCH/GEO/BLU
    { itemId = 29708, weight = 250 }, -- Pilgrim's Coat        lv20  T1  WHM/RDM/SCH/GEO/PLD
    { itemId = 29715, weight = 250 }, -- Mudstrider Boots      lv20  T2  THF/NIN/DNC/BST/RNG/COR/BRD
    { itemId = 29755, weight = 255 }, -- Ranger's Gorget       lv20  T2  All Jobs
    { itemId = 29771, weight = 255 }, -- Apprentice's Ring     lv20  T1  All Jobs
    { itemId = 29721, weight = 245 }, -- Vipersting Dagger     lv25  T2  Dagger  THF/NIN/RDM/COR/DNC/BRD
    { itemId = 29711, weight = 245 }, -- Stormcaller Mitts     lv25  T2  RNG/COR/BRD/BLU
    { itemId = 29729, weight = 245 }, -- Reedwhisper Bow       lv25  T1  Bow     RNG/COR
    { itemId = 29761, weight = 250 }, -- Woven Cord            lv25  T1  All Jobs
    { itemId = 29766, weight = 250 }, -- Mage's Stud           lv25  T2  All Jobs
    { itemId = 29746, weight = 240 }, -- Pathfinder Slops      lv28  T2  RNG/COR/BST/DNC/THF
    { itemId = 29731, weight = 240 }, -- Scholar's Mortarboard lv28  T2  SCH/BLM/WHM/SMN/GEO
    -- Batch 3
    { itemId = 29780, weight = 250 }, -- Rustbite Greatsword   lv22  T2  Gr.Sword WAR/PLD/DRK/RUN
    { itemId = 29784, weight = 250 }, -- Bonereap Scythe       lv25  T1  Scythe  DRK
    { itemId = 29788, weight = 245 }, -- Riveted Visor         lv25  T2  WAR/PLD/DRK/DRG/SAM/RUN
    { itemId = 29792, weight = 245 }, -- Mudcloth Gi           lv25  T1  MNK/PUP/BST
    { itemId = 29796, weight = 250 }, -- Featherlight Wraps    lv18  T1  MNK/PUP/BST/DNC
    { itemId = 29800, weight = 250 }, -- Wanderer's Kecks      lv22  T2  WHM/BLM/RDM/SMN/SCH/GEO/BRD
    { itemId = 29804, weight = 250 }, -- Brass-Shod Boots      lv18  T1  WAR/MNK/PLD/DRK/DRG/SAM/RUN
    { itemId = 29807, weight = 250 }, -- Mender's Gorget       lv15  T1  All Jobs
    { itemId = 29810, weight = 250 }, -- Rough Sash            lv15  T1  All Jobs
    { itemId = 29813, weight = 245 }, -- Scout's Earring       lv18  T2  All Jobs
    { itemId = 29815, weight = 245 }, -- Toughened Ring        lv28  T2  All Jobs
    { itemId = 29817, weight = 245 }, -- Brigand's Cape        lv22  T2  THF/NIN/DNC/COR/BST/RNG/BRD
}

-----------------------------------
-- Tier 3 custom items  (lv30-44)
-- Zone range: Qufim / Batallia / Rolanberry / Sauromugue / Yuhtunga /
--             Yhoator / Maze of Shakhrami / Ordelle's / King Ranperre's /
--             Gusgen Mines / Korroloka Tunnel
-----------------------------------
local tier3CustomItems =
{
    -- Batch 1
    { itemId = 29701, weight = 255 }, -- Gale Axe              lv30  T2  Axe      WAR/DRK/BST/DRG
    { itemId = 29725, weight = 255 }, -- Ironknuckle Cestus    lv30  T2  H2H      MNK/PUP
    { itemId = 29736, weight = 255 }, -- Duskweave Robe        lv30  T2  BLM/SMN/SCH/GEO/RDM
    { itemId = 29751, weight = 255 }, -- Grimwatcher Greaves   lv30  T2  WAR/PLD/DRK/DRG/RUN
    { itemId = 29717, weight = 260 }, -- Cinnabar Necklace     lv30  T2  All Jobs
    { itemId = 29776, weight = 250 }, -- Tracker's Mantle      lv30  T2  RNG/BST/THF/COR/DNC
    { itemId = 29741, weight = 245 }, -- Ember Mitts           lv32  T2  WAR/PLD/DRG/RUN/DRK
    { itemId = 29706, weight = 245 }, -- Ashen Circlet         lv35  T2  WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29722, weight = 245 }, -- Dustcleave Greataxe   lv35  T2  Gr.Axe   WAR/DRK
    { itemId = 29756, weight = 250 }, -- Ironhide Choker       lv35  T2  All Jobs
    { itemId = 29767, weight = 250 }, -- Warrior's Loop        lv35  T2  All Jobs
    { itemId = 29772, weight = 245 }, -- Soldier's Ring        lv38  T2  All Jobs
    { itemId = 29724, weight = 240 }, -- Thornlance            lv40  T2  Polearm  DRG/WAR
    { itemId = 29762, weight = 245 }, -- Mercenary's Sash      lv40  T2  All Jobs
    { itemId = 29718, weight = 245 }, -- Burnished Sash        lv40  T2  WHM/BLM/RDM/SMN/SCH/GEO/BLU/PLD
    { itemId = 29732, weight = 235 }, -- Brigand's Bandana     lv42  T2  THF/NIN/DNC/COR/RNG
    -- Batch 3
    { itemId = 29781, weight = 245 }, -- Moonblade             lv40  T2  Sword    WAR/PLD/RDM/NIN/BLU
    { itemId = 29783, weight = 245 }, -- Shadewhisper Blade    lv35  T2  Katana   NIN/SAM
    { itemId = 29785, weight = 240 }, -- Copperlock Crossbow   lv35  T2  Xbow     RNG/COR
    { itemId = 29789, weight = 240 }, -- Silkweave Hood        lv42  T2  BLM/SMN/SCH/GEO/RDM
    { itemId = 29793, weight = 245 }, -- Verdant Robe          lv38  T2  SMN/WHM/SCH/GEO/RDM
    { itemId = 29799, weight = 245 }, -- Bonehide Knuckle-Guards lv38 T2 WAR/DRK/MNK/SAM
    { itemId = 29803, weight = 245 }, -- Muddled Breeches      lv32  T2  THF/NIN/DNC/BST/COR/RNG
    { itemId = 29805, weight = 240 }, -- Plodder's Clogs       lv38  T2  BST/RNG/THF/DNC/COR/BRD
    { itemId = 29818, weight = 240 }, -- Mender's Mantle       lv42  T2  WHM/BLM/RDM/SMN/SCH/GEO/BLU
}

-----------------------------------
-- Tier 4 custom items  (lv45-59)
-- Zone range: E/W Altepa / Crawler's Nest / Labyrinth of Onzozo /
--             Sanctuary of Zitah / Sea Serpent Grotto / Quicksand Caves /
--             Gustav Tunnel / Cape Teriggan / Kuftal Tunnel
-----------------------------------
local tier4CustomItems =
{
    -- Batch 1
    { itemId = 29726, weight = 250 }, -- Cobaltedge Sword      lv45  T2  Sword   WAR/PLD/RDM/NIN/BLU
    { itemId = 29737, weight = 245 }, -- Ironguard Hauberk     lv48  T2  WAR/DRK/DRG/SAM
    { itemId = 29742, weight = 245 }, -- Spellthread Gloves    lv48  T2  WHM/BLM/RDM/SCH/GEO/SMN
    { itemId = 29714, weight = 245 }, -- Crestfallen Slacks    lv45  T2  BLM/WHM/SMN/SCH/RDM/GEO
    { itemId = 29752, weight = 245 }, -- Fleetfoot Sollerets   lv50  T2  WAR/SAM/DRG/DRK/RUN
    { itemId = 29757, weight = 250 }, -- Scholar's Collar      lv45  T2  All Jobs
    { itemId = 29758, weight = 240 }, -- Duelist's Chain       lv58  T3  All Jobs
    { itemId = 29763, weight = 240 }, -- Hexweave Obi          lv55  T2  BLM/RDM/SCH/GEO/SMN/WHM
    { itemId = 29768, weight = 240 }, -- Keen Earring          lv50  T2  All Jobs
    { itemId = 29773, weight = 240 }, -- Sorcerer's Band       lv52  T2  All Jobs
    { itemId = 29777, weight = 245 }, -- Ironguard Cape        lv45  T2  WAR/PLD/DRG/DRK/RUN
    -- Batch 3
    { itemId = 29790, weight = 245 }, -- Tracker's Cap         lv55  T2  RNG/COR/BST/THF/DNC
    { itemId = 29794, weight = 245 }, -- Ranger's Surcoat      lv52  T2  RNG/COR/BST
    { itemId = 29797, weight = 245 }, -- Channeler's Cuffs     lv55  T2  WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29801, weight = 245 }, -- Boneweave Kecks       lv52  T2  WAR/DRK/MNK/SAM/RUN/DRG
    { itemId = 29808, weight = 245 }, -- Raider's Necklace     lv48  T2  All Jobs
    { itemId = 29811, weight = 245 }, -- Warrior's Tassels     lv48  T2  WAR/MNK/DRK/SAM/DRG/PLD/RUN
}

-----------------------------------
-- Tier 5 custom items  (lv60-70)
-- Zone range: Lower/Middle/Upper Delkfutt's Tower / Feiyin /
--             Toraimarai Canal / Bostaunieux Oubliette /
--             Temple of Uggalepih / Eldieme Necropolis /
--             Den of Rancor / The Boyahda Tree
-- First batch to include T5 regular-drop items.
-----------------------------------
local tier5CustomItems =
{
    -- Batch 3
    { itemId = 29786, weight = 245 }, -- Elderwood Staff       lv60  T2  Staff   WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29787, weight = 245 }, -- Ironpaw Knuckles      lv60  T2  H2H     MNK/PUP
    { itemId = 29791, weight = 240 }, -- Iron Sentinel Helm    lv65  T2  WAR/PLD/DRK/DRG/SAM/RUN
    { itemId = 29795, weight = 240 }, -- Tempered Coat         lv65  T2  WAR/MNK/THF/DRK/SAM/NIN/DNC
    { itemId = 29798, weight = 240 }, -- Ironveil Gauntlets    lv65  T2  WAR/DRK/SAM/DRG/RUN
    { itemId = 29802, weight = 240 }, -- Dawnspun Slops        lv65  T2  WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29806, weight = 240 }, -- Ironveil Sabatons     lv65  T2  WAR/PLD/DRK/DRG/SAM/RUN
    { itemId = 29809, weight = 245 }, -- Arcane Collar         lv62  T2  All Jobs
    { itemId = 29812, weight = 245 }, -- Spellbinder's Belt    lv62  T2  WHM/BLM/RDM/SMN/SCH/GEO/BLU
    { itemId = 29814, weight = 245 }, -- Savant's Earring      lv62  T2  All Jobs
    { itemId = 29816, weight = 245 }, -- Battlemage Band       lv62  T2  All Jobs
    { itemId = 29819, weight = 245 }, -- Soldier's Cloak       lv62  T2  WAR/PLD/DRK/DRG/SAM/MNK/RUN
}

-----------------------------------
-- Zone assignments
-----------------------------------

appendToZones(
{
    xi.zone.WEST_RONFAURE,
    xi.zone.EAST_RONFAURE,
    xi.zone.NORTH_GUSTABERG,
    xi.zone.SOUTH_GUSTABERG,
    xi.zone.WEST_SARUTABARUTA,
    xi.zone.EAST_SARUTABARUTA,
},
starterCustomItems)

appendToZones(
{
    xi.zone.LA_THEINE_PLATEAU,
    xi.zone.KONSCHTAT_HIGHLANDS,
    xi.zone.TAHRONGI_CANYON,
    xi.zone.VALKURM_DUNES,
    xi.zone.JUGNER_FOREST,
    xi.zone.PASHHOW_MARSHLANDS,
    xi.zone.MERIPHATAUD_MOUNTAINS,
    xi.zone.BUBURIMU_PENINSULA,
    xi.zone.INNER_HORUTOTO_RUINS,
    xi.zone.ZERUHN_MINES,
    xi.zone.OUTER_HORUTOTO_RUINS,
    xi.zone.DANGRUF_WADI,
},
tier2CustomItems)

appendToZones(
{
    xi.zone.QUFIM_ISLAND,
    xi.zone.BATALLIA_DOWNS,
    xi.zone.ROLANBERRY_FIELDS,
    xi.zone.SAUROMUGUE_CHAMPAIGN,
    xi.zone.YUHTUNGA_JUNGLE,
    xi.zone.YHOATOR_JUNGLE,
    xi.zone.MAZE_OF_SHAKHRAMI,
    xi.zone.ORDELLES_CAVES,
    xi.zone.KING_RANPERRES_TOMB,
    xi.zone.GUSGEN_MINES,
    xi.zone.KORROLOKA_TUNNEL,
},
tier3CustomItems)

appendToZones(
{
    xi.zone.EASTERN_ALTEPA_DESERT,
    xi.zone.WESTERN_ALTEPA_DESERT,
    xi.zone.CRAWLERS_NEST,
    xi.zone.LABYRINTH_OF_ONZOZO,
    xi.zone.THE_SANCTUARY_OF_ZITAH,
    xi.zone.SEA_SERPENT_GROTTO,
    xi.zone.QUICKSAND_CAVES,
    xi.zone.GUSTAV_TUNNEL,
    xi.zone.CAPE_TERIGGAN,
    xi.zone.KUFTAL_TUNNEL,
},
tier4CustomItems)

appendToZones(
{
    xi.zone.LOWER_DELKFUTTS_TOWER,
    xi.zone.MIDDLE_DELKFUTTS_TOWER,
    xi.zone.UPPER_DELKFUTTS_TOWER,
    xi.zone.FEIYIN,
    xi.zone.TORAIMARAI_CANAL,
    xi.zone.BOSTAUNIEUX_OUBLIETTE,
    xi.zone.TEMPLE_OF_UGGALEPIH,
    xi.zone.THE_ELDIEME_NECROPOLIS,
    xi.zone.DEN_OF_RANCOR,
    xi.zone.THE_BOYAHDA_TREE,
},
tier5CustomItems)

return m
