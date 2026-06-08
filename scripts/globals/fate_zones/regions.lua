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
                { 17168, 120 },     -- Needlefang Knife      Lv10
                { 23857, 120 },     -- Cowhide Belt          Lv12
            },
            silver =
            {
                { 23812, 100 },     -- Brushwood Helm        Lv10
                { 23896, 100 },     -- Mender's Gorget       Lv15
                { 23899, 100 },     -- Rough Sash            Lv15
                { 23902, 100 },     -- Scout's Earring       Lv18
                { 16402, 80  },     -- Tarnished Gladius     Lv15
                { 16462, 80  },     -- Ironwood Club         Lv18
            },
            gold =
            {
                -- { 29887, 50  },     -- Apprentice's Rod      Lv16  TODO: not in ShiningFantasia DB
                -- { 29901, 40  },     -- Thornwood Shortbow    Lv18  TODO: not in ShiningFantasia DB
                -- { 29875, 30  },     -- Foxfire Katana        Lv24  TODO: not in ShiningFantasia DB
                { 23828, 20  },     -- Scholar's Mortarboard Lv28
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
                { 23863, 80  },     -- Mage's Stud           Lv25
                { 23824, 80  },     -- Cinnabar Necklace     Lv30
            },
            silver =
            {
                { 23877, 100 },     -- Riveted Visor         Lv25
                { 23838, 100 },     -- Ember Mitts           Lv32
                { 23892, 100 },     -- Muddled Breeches      Lv32
                { 16464, 80  },     -- Vipersting Dagger     Lv25
                { 16415, 80  },     -- Gale Axe              Lv30
            },
            gold =
            {
                { 17084, 100 },     -- Reedwhisper Bow       Lv25
                { 16573, 100 },     -- Ironknuckle Cestus    Lv30
                -- { 29852, 100 },     -- Ashbane Foil          Lv28  TODO: not in ShiningFantasia DB
                -- { 29893, 100 },     -- Venom Fang            Lv32  TODO: not in ShiningFantasia DB
                { 17169, 80  },     -- Shadewhisper Blade    Lv35
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
                { 23904, 80  },     -- Toughened Ring        Lv28
                { 23848, 80  },     -- Grimwatcher Greaves   Lv30
            },
            silver =
            {
                { 23833, 100 },     -- Duskweave Robe        Lv30
                { 23873, 100 },     -- Tracker's Mantle      Lv30
                { 23869, 100 },     -- Soldier's Ring        Lv38
                -- { 29857, 80  },     -- Ironcleft Claymore    Lv22  TODO: not in ShiningFantasia DB
                { 16570, 80  },     -- Thornlance            Lv40
            },
            gold =
            {
                -- { 29888, 100 },     -- Embervein Staff       Lv35  TODO: not in ShiningFantasia DB
                { 17109, 100 },     -- Moonblade             Lv40
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
                { 23821, 80  },     -- Crestfallen Slacks    Lv45
                { 23844, 80  },     -- Ironweave Cuisses     Lv45
            },
            silver =
            {
                { 23874, 100 },     -- Ironguard Cape        Lv45
                { 23834, 100 },     -- Ironguard Hauberk     Lv48
                { 16474, 80  },     -- Dustcleave Greataxe   Lv35
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
                { 23865, 80  },     -- Keen Earring          Lv50
                { 23897, 80  },     -- Raider's Necklace     Lv48
            },
            silver =
            {
                { 23829, 100 },     -- Brigand's Bandana     Lv42
                { 23849, 100 },     -- Fleetfoot Sollerets   Lv50
                { 23900, 100 },     -- Warrior's Tassels     Lv48
                { 16574, 80  },     -- Cobaltedge Sword      Lv45
                -- { 29906, 80  },     -- Bronzelock Rifle      Lv48  TODO: not in ShiningFantasia DB
            },
            gold =
            {
                -- { 29876, 100 },     -- Bloodpetal Blade      Lv42  TODO: not in ShiningFantasia DB
                { 23879, 100 },     -- Tracker's Cap         Lv55
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
                { 23903, 80  },     -- Savant's Earring      Lv62
                { 23898, 80  },     -- Arcane Collar         Lv62
            },
            silver =
            {
                { 23860, 100 },     -- Hexweave Obi          Lv55
                { 23854, 100 },     -- Scholar's Collar      Lv45
                { 23855, 80  },     -- Duelist's Chain       Lv58
                { 23870, 80  },     -- Sorcerer's Band       Lv52
            },
            gold =
            {
                { 18179, 100 },     -- Elderwood Staff       Lv60
                { 18467, 100 },     -- Ironpaw Knuckles      Lv60
                { 23880, 100 },     -- Iron Sentinel Helm    Lv65
                { 23901, 80  },     -- Spellbinder's Belt    Lv62
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
                { 23905, 80  },     -- Battlemage Band       Lv62
                { 23908, 80  },     -- Soldier's Cloak       Lv62
            },
            silver =
            {
                { 23890, 100 },     -- Boneweave Kecks       Lv52
                { 23886, 100 },     -- Channeler's Cuffs     Lv55
                { 23891, 100 },     -- Dawnspun Slops        Lv65
                { 23895, 80  },     -- Ironveil Sabatons     Lv65
            },
            gold =
            {
                { 23884, 100 },     -- Tempered Coat         Lv65
                { 23887, 100 },     -- Ironveil Gauntlets    Lv65
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
                { 23898, 80  },     -- Arcane Collar         Lv62
                { 23855, 80  },     -- Duelist's Chain       Lv58
            },
            silver =
            {
                { 23878, 100 },     -- Silkweave Hood        Lv42
                { 23860, 100 },     -- Hexweave Obi          Lv55
                { 23883, 100 },     -- Ranger's Surcoat      Lv52
                { 23890, 80  },     -- Boneweave Kecks       Lv52
            },
            gold =
            {
                -- { 29880, 100 },     -- Dawnreach Tachi       Lv55  TODO: not in ShiningFantasia DB
                { 23887, 100 },     -- Ironveil Gauntlets    Lv65
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
                { 23859, 80  },     -- Mercenary's Sash      Lv40
                { 23825, 80  },     -- Burnished Sash        Lv40
            },
            silver =
            {
                { 16574, 100 },     -- Cobaltedge Sword      Lv45
                { 23854, 100 },     -- Scholar's Collar      Lv45
                { 23883, 80  },     -- Ranger's Surcoat      Lv52
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
