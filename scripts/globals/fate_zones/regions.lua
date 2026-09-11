-----------------------------------
-- FATE Regional Loot Pools
--
-- Each pool defines loot appended to
-- every FATE in that region on top of
-- the per-event specific loot.
--
-- Weights are out of 1000 (same scale
-- as individual FATE loot tables).
-- Regional items appear on victory only.
--
-- Zone files reference a pool by name:
--   region = "STARTER_ZULKHEIM"
-- The engine merges pool.loot.victory
-- into each event's loot.victory tiers.
-----------------------------------
xi           = xi           or {}
xi.fate      = xi.fate      or {}
xi.fate.regions = xi.fate.regions or {}

-----------------------------------
-- Pool 1: Starter Regions + Zulkheim
-- Zones: Ronfaure, Gustaberg, Sarutabaruta,
--        La Theine, Valkurm Dunes, Konschtat
-- Level range: 1-28
-----------------------------------
xi.fate.regions.STARTER_ZULKHEIM =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29782, 120 },     -- Needlefang Knife      Lv10
                { 29760, 120 },     -- Cowhide Belt          Lv12
            },
            silver =
            {
                { 29705, 100 },     -- Brushwood Helm        Lv10
                { 29807, 100 },     -- Mender's Gorget       Lv15
                { 29810, 100 },     -- Rough Sash            Lv15
                { 29813, 100 },     -- Scout's Earring       Lv18
                { 29700, 80  },     -- Tarnished Gladius     Lv15
                { 29720, 80  },     -- Ironwood Club         Lv18
            },
            gold =
            {
                -- { 29887, 50  },     -- Apprentice's Rod      Lv16  TODO: not in ShiningFantasia DB
                -- { 29901, 40  },     -- Thornwood Shortbow    Lv18  TODO: not in ShiningFantasia DB
                -- { 29875, 30  },     -- Foxfire Katana        Lv24  TODO: not in ShiningFantasia DB
                { 29731, 20  },     -- Scholar's Mortarboard Lv28
            },
        },
    },
}

-----------------------------------
-- Pool 2: Derfland + Aragoneu
-- Zones: Pashhow, Rolanberry, Tahrongi,
--        Buburimu, Meriphataud
-- Level range: 15-40
-----------------------------------
xi.fate.regions.DERFLAND_ARAGONEU =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29766, 80  },     -- Mage's Stud           Lv25
                { 29717, 80  },     -- Cinnabar Necklace     Lv30
            },
            silver =
            {
                { 29788, 100 },     -- Riveted Visor         Lv25
                { 29741, 100 },     -- Ember Mitts           Lv32
                { 29803, 100 },     -- Muddled Breeches      Lv32
                { 29721, 80  },     -- Vipersting Dagger     Lv25
                { 29701, 80  },     -- Gale Axe              Lv30
            },
            gold =
            {
                { 29729, 100 },     -- Reedwhisper Bow       Lv25
                { 29725, 100 },     -- Ironknuckle Cestus    Lv30
                -- { 29852, 100 },     -- Ashbane Foil          Lv28  TODO: not in ShiningFantasia DB
                -- { 29893, 100 },     -- Venom Fang            Lv32  TODO: not in ShiningFantasia DB
                { 29783, 80  },     -- Shadewhisper Blade    Lv35
                -- { 29861, 80  },     -- Redrock Chopper       Lv38  TODO: not in ShiningFantasia DB
            },
        },
    },
}

-----------------------------------
-- Pool 3: Norvallen + Qufim
-- Zones: Jugner, Batallia, Qufim,
--        Sauromugue Champaign
-- Level range: 25-48
-----------------------------------
xi.fate.regions.NORVALLEN_QUFIM =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29815, 80  },     -- Toughened Ring        Lv28
                { 29751, 80  },     -- Grimwatcher Greaves   Lv30
            },
            silver =
            {
                { 29736, 100 },     -- Duskweave Robe        Lv30
                { 29776, 100 },     -- Tracker's Mantle      Lv30
                { 29772, 100 },     -- Soldier's Ring        Lv38
                -- { 29857, 80  },     -- Ironcleft Claymore    Lv22  TODO: not in ShiningFantasia DB
                { 29724, 80  },     -- Thornlance            Lv40
            },
            gold =
            {
                -- { 29888, 100 },     -- Embervein Staff       Lv35  TODO: not in ShiningFantasia DB
                { 29781, 100 },     -- Moonblade             Lv40
                -- { 29872, 100 },     -- Emberthorn Spear      Lv40  TODO: not in ShiningFantasia DB
                -- { 29898, 100 },     -- Temple Fists          Lv40  TODO: not in ShiningFantasia DB
            },
        },
    },
}

-----------------------------------
-- Pool 4: Northlands
-- Zones: Beaucedine Glacier, Xarcabard
-- Level range: 40-65
-----------------------------------
xi.fate.regions.NORTHLANDS =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29714, 80  },     -- Crestfallen Slacks    Lv45
                { 29747, 80  },     -- Ironweave Cuisses     Lv45
            },
            silver =
            {
                { 29777, 100 },     -- Ironguard Cape        Lv45
                { 29737, 100 },     -- Ironguard Hauberk     Lv48
                { 29722, 80  },     -- Dustcleave Greataxe   Lv35
                -- { 29864, 80  },     -- Colossus Axe          Lv45  TODO: not in ShiningFantasia DB
            },
            gold =
            {
                -- { 29853, 100 },     -- Verdant Saber         Lv48  TODO: not in ShiningFantasia DB
                -- { 29884, 100 },     -- Spellbinder's Cudgel  Lv45  TODO: not in ShiningFantasia DB
                -- { 29868, 100 },     -- Bloodmire Scythe      Lv50  TODO: not in ShiningFantasia DB
                -- { 29902, 100 },     -- Ironstring Longbow    Lv50  TODO: not in ShiningFantasia DB
            },
        },
    },
}

-----------------------------------
-- Pool 5: Kolshushu + Elshimo
-- Zones: Cape Teriggan, Bibiki Bay,
--        Yuhtunga Jungle, Yhoator Jungle
-- Level range: 40-70
-----------------------------------
xi.fate.regions.KOLSHUSHU_ELSHIMO =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29768, 80  },     -- Keen Earring          Lv50
                { 29808, 80  },     -- Raider's Necklace     Lv48
            },
            silver =
            {
                { 29732, 100 },     -- Brigand's Bandana     Lv42
                { 29752, 100 },     -- Fleetfoot Sollerets   Lv50
                { 29811, 100 },     -- Warrior's Tassels     Lv48
                { 29726, 80  },     -- Cobaltedge Sword      Lv45
                -- { 29906, 80  },     -- Bronzelock Rifle      Lv48  TODO: not in ShiningFantasia DB
            },
            gold =
            {
                -- { 29876, 100 },     -- Bloodpetal Blade      Lv42  TODO: not in ShiningFantasia DB
                { 29790, 100 },     -- Tracker's Cap         Lv55
                -- { 29880, 100 },     -- Dawnreach Tachi       Lv55  TODO: not in ShiningFantasia DB
            },
        },
    },
}

-----------------------------------
-- Pool 6: Li'Telor
-- Zones: Sanctuary of Zi'Tah, Ro'Maeve
-- Level range: 55-75
-----------------------------------
xi.fate.regions.LITEILOR =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29814, 80  },     -- Savant's Earring      Lv62
                { 29809, 80  },     -- Arcane Collar         Lv62
            },
            silver =
            {
                { 29763, 100 },     -- Hexweave Obi          Lv55
                { 29757, 100 },     -- Scholar's Collar      Lv45
                { 29758, 80  },     -- Duelist's Chain       Lv58
                { 29773, 80  },     -- Sorcerer's Band       Lv52
            },
            gold =
            {
                { 29786, 100 },     -- Elderwood Staff       Lv60
                { 29787, 100 },     -- Ironpaw Knuckles      Lv60
                { 29791, 100 },     -- Iron Sentinel Helm    Lv65
                { 29812, 80  },     -- Spellbinder's Belt    Lv62
            },
        },
    },
}

-----------------------------------
-- Pool 7: Sky / Sea / High-end
-- Zones: Ru'Aun Gardens, Al'Taieu,
--        Uleguerand Range, Attohwa Chasm
-- Level range: 65-75
-----------------------------------
xi.fate.regions.SKY_SEA_HIGHEND =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29816, 80  },     -- Battlemage Band       Lv62
                { 29819, 80  },     -- Soldier's Cloak       Lv62
            },
            silver =
            {
                { 29801, 100 },     -- Boneweave Kecks       Lv52
                { 29797, 100 },     -- Channeler's Cuffs     Lv55
                { 29802, 100 },     -- Dawnspun Slops        Lv65
                { 29806, 80  },     -- Ironveil Sabatons     Lv65
            },
            gold =
            {
                { 29795, 100 },     -- Tempered Coat         Lv65
                { 29798, 100 },     -- Ironveil Gauntlets    Lv65
            },
        },
    },
}

-----------------------------------
-- Pool 8: Treasures of Aht Urhgan
-- Zones: Bhaflau Thickets, Caedarva Mire,
--        Mount Zhayolm
-- Level range: 55-75
-----------------------------------
xi.fate.regions.TOAU =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29809, 80  },     -- Arcane Collar         Lv62
                { 29758, 80  },     -- Duelist's Chain       Lv58
            },
            silver =
            {
                { 29789, 100 },     -- Silkweave Hood        Lv42
                { 29763, 100 },     -- Hexweave Obi          Lv55
                { 29794, 100 },     -- Ranger's Surcoat      Lv52
                { 29801, 80  },     -- Boneweave Kecks       Lv52
            },
            gold =
            {
                -- { 29880, 100 },     -- Dawnreach Tachi       Lv55  TODO: not in ShiningFantasia DB
                { 29798, 100 },     -- Ironveil Gauntlets    Lv65
            },
        },
    },
}

-----------------------------------
-- Pool 9: Lufaise / Misareaux
-- Zones: Lufaise Meadows, Misareaux Coast
-- Level range: 35-58
-----------------------------------
xi.fate.regions.LUFAISE_MISAREAUX =
{
    loot =
    {
        victory =
        {
            bronze =
            {
                { 29762, 80  },     -- Mercenary's Sash      Lv40
                { 29718, 80  },     -- Burnished Sash        Lv40
            },
            silver =
            {
                { 29726, 100 },     -- Cobaltedge Sword      Lv45
                { 29757, 100 },     -- Scholar's Collar      Lv45
                { 29794, 80  },     -- Ranger's Surcoat      Lv52
                -- { 29864, 80  },     -- Colossus Axe          Lv45  TODO: not in ShiningFantasia DB
            },
            gold =
            {
                -- { 29853, 100 },     -- Verdant Saber         Lv48  TODO: not in ShiningFantasia DB
                -- { 29884, 100 },     -- Spellbinder's Cudgel  Lv45  TODO: not in ShiningFantasia DB
            },
        },
    },
}
