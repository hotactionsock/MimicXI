-----------------------------------
-- Module: casket_gold_chest_custom_items
--
-- Injects custom-designed equipment (IDs 29700-29908) into Gold Chest
-- rare pools for the appropriate zone tier.
--
-- Items designated as "Custom NM Drop" or "Boss FATE" in new_items_design.csv
-- are intentionally excluded; those are wired via LQS NM drops / FATE system.
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
-- Starter zone items  (lv10-14)
-- Zones: W/E Ronfaure, N/S Gustaberg, W/E Sarutabaruta
-----------------------------------
local starterCustomItems =
{
    -- Weapons (lv10-14)
    { itemId = 29782, weight = 255 }, -- Needlefang Knife      lv10  Dagger   THF/NIN/RDM/COR/DNC/BRD
    { itemId = 29851, weight = 265 }, -- Copperleaf Blade      lv14  Sword    WAR/MNK/THF/PLD/DRK/RDM/NIN/BLU/COR
    { itemId = 29883, weight = 265 }, -- Pilgrim's Mace        lv14  Club     WHM/PLD/RDM/SCH/GEO/BLU
    { itemId = 29892, weight = 265 }, -- Splinter Knife        lv14  Dagger   THF/NIN/RDM/COR/DNC/BRD

    -- Armour (lv10-12)
    { itemId = 29705, weight = 270 }, -- Brushwood Helm        lv10  HEAD     WAR/MNK/PLD/DRK/DRG/SAM/RUN
    { itemId = 29730, weight = 260 }, -- Fieldwarden Cap       lv12  HEAD     BST/RNG/THF/DNC/COR
    { itemId = 29740, weight = 260 }, -- Tanner's Gloves       lv12  HANDS    BST/RNG/THF/DNC/COR/SAM
    { itemId = 29745, weight = 260 }, -- Herdsman's Trousers   lv12  LEGS     BST/WHM/RDM/BRD
    { itemId = 29750, weight = 260 }, -- Wanderer's Sandals    lv12  FEET     WHM/BLM/RDM/SMN/SCH/GEO

    -- Accessories (lv10-12)
    { itemId = 29765, weight = 275 }, -- Copper Loop           lv10  EAR      All Jobs
    { itemId = 29770, weight = 275 }, -- Bronze Ring           lv10  RING     All Jobs
    { itemId = 29760, weight = 270 }, -- Cowhide Belt          lv12  WAIST    All Jobs
    { itemId = 29775, weight = 260 }, -- Roughspun Cloak       lv12  BACK     All Jobs
}

-----------------------------------
-- Tier 2 items  (lv15-29)
-- Zones: La Theine / Konschtat / Tahrongi / Valkurm / Jugner /
--        Pashhow / Meriphataud / Buburimu / Inner+Outer Horutoto /
--        Zeruhn Mines / Dangruf Wadi
-----------------------------------
local tier2CustomItems =
{
    -- Weapons (lv15-28, sorted by level)
    { itemId = 29700, weight = 255 }, -- Tarnished Gladius     lv15  Sword    WAR/MNK/THF/PLD/DRK/RDM/NIN/BLU/COR
    { itemId = 29860, weight = 250 }, -- Thornbite Hatchet     lv16  Axe      WAR/DRK/BST/DRG
    { itemId = 29887, weight = 250 }, -- Apprentice's Rod      lv16  Staff    WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29720, weight = 250 }, -- Ironwood Club         lv18  Club     WHM/RDM/PLD/SCH/GEO/BLU
    { itemId = 29867, weight = 250 }, -- Rustworn Scythe       lv18  Scythe   DRK
    { itemId = 29897, weight = 250 }, -- Ironhide Knuckles     lv18  H2H      MNK/PUP
    { itemId = 29901, weight = 250 }, -- Thornwood Shortbow    lv18  Archery  RNG/COR
    { itemId = 29871, weight = 250 }, -- Splithorn Lance       lv20  Polearm  DRG/WAR
    { itemId = 29780, weight = 250 }, -- Rustbite Greatsword   lv22  Gr.Sword WAR/PLD/DRK/RUN
    { itemId = 29857, weight = 250 }, -- Ironcleft Claymore    lv22  Gr.Sword WAR/PLD/DRK/RUN
    { itemId = 29905, weight = 250 }, -- Flintlock Pistol      lv22  Marks.   RNG/COR
    { itemId = 29875, weight = 250 }, -- Foxfire Katana        lv24  Katana   NIN/SAM
    { itemId = 29784, weight = 250 }, -- Bonereap Scythe       lv25  Scythe   DRK
    { itemId = 29729, weight = 245 }, -- Reedwhisper Bow       lv25  Archery  RNG/COR
    { itemId = 29721, weight = 245 }, -- Vipersting Dagger     lv25  Dagger   THF/NIN/RDM/COR/DNC/BRD
    { itemId = 29852, weight = 250 }, -- Ashbane Foil          lv28  Sword    RDM/NIN/BLU

    -- Armour (lv15-28, sorted by level)
    { itemId = 29735, weight = 255 }, -- Ashgrain Vest         lv15  BODY     THF/RNG/NIN/DNC/BST/COR
    { itemId = 29713, weight = 255 }, -- Dustwalker Subligar   lv15  LEGS     THF/RNG/NIN/DNC/BST/COR
    { itemId = 29708, weight = 250 }, -- Pilgrim's Coat        lv20  BODY     WHM/RDM/SCH/GEO/PLD
    { itemId = 29796, weight = 250 }, -- Featherlight Wraps    lv18  HANDS    MNK/PUP/BST/DNC
    { itemId = 29804, weight = 250 }, -- Brass-Shod Boots      lv18  FEET     WAR/MNK/PLD/DRK/DRG/SAM/RUN
    { itemId = 29800, weight = 250 }, -- Wanderer's Kecks      lv22  LEGS     WHM/BLM/RDM/SMN/SCH/GEO/BRD
    { itemId = 29788, weight = 245 }, -- Riveted Visor         lv25  HEAD     WAR/PLD/DRK/DRG/SAM/RUN
    { itemId = 29792, weight = 245 }, -- Mudcloth Gi           lv25  BODY     MNK/PUP/BST
    { itemId = 29711, weight = 245 }, -- Stormcaller Mitts     lv25  HANDS    RNG/COR/BRD/BLU
    { itemId = 29731, weight = 240 }, -- Scholar's Mortarboard lv28  HEAD     SCH/BLM/WHM/SMN/GEO
    { itemId = 29746, weight = 240 }, -- Pathfinder Slops      lv28  LEGS     RNG/COR/BST/DNC/THF

    -- Accessories (lv15-28, sorted by level)
    { itemId = 29807, weight = 250 }, -- Mender's Gorget       lv15  NECK     All Jobs
    { itemId = 29810, weight = 250 }, -- Rough Sash            lv15  WAIST    All Jobs
    { itemId = 29813, weight = 245 }, -- Scout's Earring       lv18  EAR      All Jobs
    { itemId = 29755, weight = 255 }, -- Ranger's Gorget       lv20  NECK     All Jobs
    { itemId = 29771, weight = 255 }, -- Apprentice's Ring     lv20  RING     All Jobs
    { itemId = 29817, weight = 245 }, -- Brigand's Cape        lv22  BACK     THF/NIN/DNC/COR/BST/RNG/BRD
    { itemId = 29761, weight = 250 }, -- Woven Cord            lv25  WAIST    All Jobs
    { itemId = 29766, weight = 250 }, -- Mage's Stud           lv25  EAR      All Jobs
    { itemId = 29815, weight = 245 }, -- Toughened Ring        lv28  RING     All Jobs
}

-----------------------------------
-- Tier 3 items  (lv30-44)
-- Zones: Qufim / Batallia / Rolanberry / Sauromugue / Yuhtunga /
--        Yhoator / Maze of Shakhrami / Ordelle's / King Ranperre's /
--        Gusgen Mines / Korroloka Tunnel
-----------------------------------
local tier3CustomItems =
{
    -- Weapons (lv30-42, sorted by level)
    { itemId = 29701, weight = 255 }, -- Gale Axe              lv30  Axe      WAR/DRK/BST/DRG
    { itemId = 29725, weight = 255 }, -- Ironknuckle Cestus    lv30  H2H      MNK/PUP
    { itemId = 29893, weight = 245 }, -- Venom Fang            lv32  Dagger   THF/NIN/DNC/COR
    { itemId = 29722, weight = 245 }, -- Dustcleave Greataxe   lv35  Gr.Axe   WAR/DRK
    { itemId = 29783, weight = 245 }, -- Shadewhisper Blade    lv35  Katana   NIN/SAM
    { itemId = 29888, weight = 245 }, -- Embervein Staff       lv35  Staff    BLM/RDM/SCH
    { itemId = 29785, weight = 240 }, -- Copperlock Crossbow   lv35  Marks.   RNG/COR
    { itemId = 29861, weight = 245 }, -- Redrock Chopper       lv38  Axe      WAR/DRK/BST/DRG
    { itemId = 29724, weight = 245 }, -- Thornlance            lv40  Polearm  DRG/WAR
    { itemId = 29781, weight = 245 }, -- Moonblade             lv40  Sword    WAR/PLD/RDM/NIN/BLU
    { itemId = 29872, weight = 245 }, -- Emberthorn Spear      lv40  Polearm  DRG/WAR
    { itemId = 29898, weight = 245 }, -- Temple Fists          lv40  H2H      MNK/PUP
    { itemId = 29876, weight = 240 }, -- Bloodpetal Blade      lv42  Katana   NIN/SAM

    -- Armour (lv30-42, sorted by level)
    { itemId = 29736, weight = 255 }, -- Duskweave Robe        lv30  BODY     BLM/SMN/SCH/GEO/RDM
    { itemId = 29751, weight = 255 }, -- Grimwatcher Greaves   lv30  FEET     WAR/PLD/DRK/DRG/RUN
    { itemId = 29741, weight = 245 }, -- Ember Mitts           lv32  HANDS    WAR/PLD/DRG/RUN/DRK
    { itemId = 29803, weight = 245 }, -- Muddled Breeches      lv32  LEGS     THF/NIN/DNC/BST/COR/RNG
    { itemId = 29706, weight = 245 }, -- Ashen Circlet         lv35  HEAD     WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29793, weight = 245 }, -- Verdant Robe          lv38  BODY     SMN/WHM/SCH/GEO/RDM
    { itemId = 29799, weight = 245 }, -- Bonehide Knuckle-Guards lv38 HANDS   WAR/DRK/MNK/SAM
    { itemId = 29805, weight = 240 }, -- Plodder's Clogs       lv38  FEET     BST/RNG/THF/DNC/COR/BRD
    { itemId = 29732, weight = 235 }, -- Brigand's Bandana     lv42  HEAD     THF/NIN/DNC/COR/RNG
    { itemId = 29789, weight = 240 }, -- Silkweave Hood        lv42  HEAD     BLM/SMN/SCH/GEO/RDM

    -- Accessories (lv30-42, sorted by level)
    { itemId = 29717, weight = 260 }, -- Cinnabar Necklace     lv30  NECK     All Jobs
    { itemId = 29776, weight = 250 }, -- Tracker's Mantle      lv30  BACK     RNG/BST/THF/COR/DNC
    { itemId = 29756, weight = 250 }, -- Ironhide Choker       lv35  NECK     All Jobs
    { itemId = 29767, weight = 250 }, -- Warrior's Loop        lv35  EAR      All Jobs
    { itemId = 29772, weight = 245 }, -- Soldier's Ring        lv38  RING     All Jobs
    { itemId = 29718, weight = 245 }, -- Burnished Sash        lv40  WAIST    WHM/BLM/RDM/SMN/SCH/GEO/BLU/PLD
    { itemId = 29762, weight = 245 }, -- Mercenary's Sash      lv40  WAIST    All Jobs
    { itemId = 29818, weight = 240 }, -- Mender's Mantle       lv42  BACK     WHM/BLM/RDM/SMN/SCH/GEO/BLU
}

-----------------------------------
-- Tier 4 items  (lv45-59)
-- Zones: E/W Altepa / Crawler's Nest / Labyrinth of Onzozo /
--        Sanctuary of Zi'Tah / Sea Serpent Grotto / Quicksand Caves /
--        Gustav Tunnel / Cape Teriggan / Kuftal Tunnel
-----------------------------------
local tier4CustomItems =
{
    -- Weapons (lv45-55, sorted by level)
    { itemId = 29726, weight = 250 }, -- Cobaltedge Sword      lv45  Sword    WAR/PLD/RDM/NIN/BLU
    { itemId = 29864, weight = 245 }, -- Colossus Axe          lv45  Gr.Axe   WAR/DRK
    { itemId = 29884, weight = 245 }, -- Spellbinder's Cudgel  lv45  Club     WHM/RDM/SCH/GEO/BLU
    { itemId = 29853, weight = 245 }, -- Verdant Saber         lv48  Sword    WAR/PLD/RDM/NIN/BLU
    { itemId = 29906, weight = 245 }, -- Bronzelock Rifle      lv48  Marks.   RNG/COR
    { itemId = 29868, weight = 240 }, -- Bloodmire Scythe      lv50  Scythe   DRK
    { itemId = 29902, weight = 240 }, -- Ironstring Longbow    lv50  Archery  RNG/COR
    { itemId = 29880, weight = 240 }, -- Dawnreach Tachi       lv55  Gr.Katana SAM

    -- Armour (lv45-55, sorted by level)
    { itemId = 29714, weight = 245 }, -- Crestfallen Slacks    lv45  LEGS     BLM/WHM/SMN/SCH/RDM/GEO
    { itemId = 29737, weight = 245 }, -- Ironguard Hauberk     lv48  BODY     WAR/DRK/DRG/SAM
    { itemId = 29742, weight = 245 }, -- Spellthread Gloves    lv48  HANDS    WHM/BLM/RDM/SCH/GEO/SMN
    { itemId = 29752, weight = 245 }, -- Fleetfoot Sollerets   lv50  FEET     WAR/SAM/DRG/DRK/RUN
    { itemId = 29794, weight = 245 }, -- Ranger's Surcoat      lv52  BODY     RNG/COR/BST
    { itemId = 29801, weight = 245 }, -- Boneweave Kecks       lv52  LEGS     WAR/DRK/MNK/SAM/RUN/DRG
    { itemId = 29790, weight = 240 }, -- Tracker's Cap         lv55  HEAD     RNG/COR/BST/THF/DNC
    { itemId = 29797, weight = 245 }, -- Channeler's Cuffs     lv55  HANDS    WHM/BLM/RDM/SMN/SCH/GEO

    -- Accessories (lv45-58, sorted by level)
    { itemId = 29757, weight = 250 }, -- Scholar's Collar      lv45  NECK     All Jobs
    { itemId = 29777, weight = 245 }, -- Ironguard Cape        lv45  BACK     WAR/PLD/DRG/DRK/RUN
    { itemId = 29808, weight = 245 }, -- Raider's Necklace     lv48  NECK     All Jobs
    { itemId = 29811, weight = 245 }, -- Warrior's Tassels     lv48  WAIST    WAR/MNK/DRK/SAM/DRG/PLD/RUN
    { itemId = 29768, weight = 240 }, -- Keen Earring          lv50  EAR      All Jobs
    { itemId = 29773, weight = 240 }, -- Sorcerer's Band       lv52  RING     All Jobs
    { itemId = 29763, weight = 240 }, -- Hexweave Obi          lv55  WAIST    BLM/RDM/SCH/GEO/SMN/WHM
    { itemId = 29758, weight = 240 }, -- Duelist's Chain       lv58  NECK     All Jobs
}

-----------------------------------
-- Tier 5 items  (lv60-70)
-- Zones: Lower/Middle/Upper Delkfutt's Tower / Feiyin /
--        Toraimarai Canal / Bostaunieux Oubliette /
--        Temple of Uggalepih / Eldieme Necropolis /
--        Den of Rancor / The Boyahda Tree
-----------------------------------
local tier5CustomItems =
{
    -- Weapons (lv60-65)
    { itemId = 29786, weight = 245 }, -- Elderwood Staff       lv60  Staff    WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29787, weight = 245 }, -- Ironpaw Knuckles      lv60  H2H      MNK/PUP

    -- Armour (lv65, sorted by slot)
    { itemId = 29791, weight = 240 }, -- Iron Sentinel Helm    lv65  HEAD     WAR/PLD/DRK/DRG/SAM/RUN
    { itemId = 29795, weight = 240 }, -- Tempered Coat         lv65  BODY     WAR/MNK/THF/DRK/SAM/NIN/DNC
    { itemId = 29798, weight = 240 }, -- Ironveil Gauntlets    lv65  HANDS    WAR/DRK/SAM/DRG/RUN
    { itemId = 29802, weight = 240 }, -- Dawnspun Slops        lv65  LEGS     WHM/BLM/RDM/SMN/SCH/GEO
    { itemId = 29806, weight = 240 }, -- Ironveil Sabatons     lv65  FEET     WAR/PLD/DRK/DRG/SAM/RUN

    -- Accessories (lv62, sorted by slot)
    { itemId = 29809, weight = 245 }, -- Arcane Collar         lv62  NECK     All Jobs
    { itemId = 29812, weight = 245 }, -- Spellbinder's Belt    lv62  WAIST    WHM/BLM/RDM/SMN/SCH/GEO/BLU
    { itemId = 29814, weight = 245 }, -- Savant's Earring      lv62  EAR      All Jobs
    { itemId = 29816, weight = 245 }, -- Battlemage Band       lv62  RING     All Jobs
    { itemId = 29819, weight = 245 }, -- Soldier's Cloak       lv62  BACK     WAR/PLD/DRK/DRG/SAM/MNK/RUN
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
