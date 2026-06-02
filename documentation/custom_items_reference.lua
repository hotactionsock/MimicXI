--[[
  MIMICXI — CUSTOM ITEMS REFERENCE
  Branch: claude/design-new-items-hecdW   (design reference only — not loaded at runtime)

  PURPOSE
    Single source of truth for all 209 custom items (IDs 29700–29908).
    Provides complete mod wiring for SQL implementation.
    Hand to claude-code-local when generating item_basic.sql, item_equipment.sql,
    item_weapon.sql and item_mods.sql INSERT rows.

  SECTIONS
    1. CASKET / REGULAR DROPS   flags=0x0000   IDs: 29700–29819 (regular), 29851–29908 (casket)
    2. CUSTOM NM DROPS          flags=0x0C00   IDs: scattered across 29700–29850 (NM-sourced)
    3. BOSS FATE DROPS          flags=0x0000   IDs: scattered across 29854–29908 (FATE-sourced)
    4. PENDING ITEMS            flags=TBD       IDs: 29820–29839 (awaiting stat approval)

  SQL TABLES
    item_basic.sql      — id, name, sortname, type (5=WEAPON 4=ARMOR), flags, stackSize, aH, BaseSell
    item_equipment.sql  — id, level, ilevel, jobs, MId, slot
    item_weapon.sql     — id, skill, dmgType, hit, delay, dmg   (weapons only)
    item_mods.sql       — (itemId, modId, value)  one row per stat bonus

  SLOT BITMASKS
    MAIN=1  SUB=2  MAIN+SUB=3  RANGED=4
    HEAD=16  BODY=32  HANDS=64  LEGS=128  FEET=256
    NECK=512  WAIST=1024  EAR(both)=6144  RING(both)=24576  BACK=32768

  JOB BITMASKS
    WAR=1  MNK=2  WHM=4  BLM=8  RDM=16  THF=32  PLD=64  DRK=128
    BST=256  BRD=512  RNG=1024  SAM=2048  NIN=4096  DRG=8192  SMN=16384
    BLU=32768  COR=65536  PUP=131072  DNC=262144  SCH=524288  GEO=1048576  RUN=2097152
    ALL=4194303

  WEAPON SKILL CODES
    H2H=0  Dagger=1  Sword=2  GreatSword=3  Axe=4  GreatAxe=5  Scythe=6
    Polearm=7  Katana=8  GreatKatana=9  Club=10  Staff=11  Archery=12  Marksmanship=13

  DAMAGE TYPE CODES
    Slashing=2  Piercing=3  Blunt=4  Ranged=5

  CONFIRMED MOD IDs (from mods_by_id.txt)
    HP=2  MP=5  STR=8  DEX=9  VIT=10  AGI=11  INT=12  MND=13  CHR=14
    ATT=23  RATT=24  ACC=25  RACC=26  ENMITY=27  MACC=30  DEF_BONUS=31(VERIFY)
    EVA=68  STORETP=73
    HTH_SKILL=80  DAGGER_SKILL=81  SWORD_SKILL=82  GSWORD_SKILL=83
    AXE_SKILL=84  GAXE_SKILL=85  SCYTHE_SKILL=86  POLEARM_SKILL=87
    KATANA_SKILL=88  GKATANA_SKILL=89  CLUB_SKILL=90  STAFF_SKILL=91
    ARCHERY_SKILL=104  MARKSMAN_SKILL=105
    HEALING_SKILL=112  ENFEEBLE_SKILL=114  ELEM_SKILL=115  DARK_SKILL=116  NINJUTSU_SKILL=118
    SOULEATER_EFFECT=96  DOUBLE_ATTACK=288  TRIPLE_ATTACK=302  SUBTLE_BLOW=289
    COUNTER=291  KICK_ATTACK_RATE=292  CRITHITRATE=165  DUAL_WIELD=259  ZANSHIN=306
    SMITE=898(256-scale)  ENH_DRAIN_ASPIR=315  CURE_POTENCY=374  CONSERVE_MP=296
    MAG_BURST_BONUS=487  OCCULT_ACUMEN=902  SKILLCHAINDMG=175
    JUMP_ATT_BONUS=362  WYVERN_BREATH=402  NINJA_TOOL=308
    RAPID_SHOT=359  SNAPSHOT=365  BARRAGE_ACC=420  RANGED_CRIT_DMG_INCREASE=964
    SNEAK_ATK_DEX=830  WALTZ_POTENCY=491  FIRE_AFFINITY_DMG=347
    HASTE_GEAR=384(100=1% 200=2% 300=3%)
    BP_DAMAGE=126  BP_DELAY=357  PERPETUATION_REDUCTION=346
    PET_ATK_DEF=990  PET_ACC_EVA=991  PET_TP_BONUS=995  REWARD_HP_BONUS=364
    SONG_DURATION_BONUS=454  SHIELDBLOCKRATE=518
    FIRE_ELE_ACC=40(from B4 CSV — verify against mods_by_id.txt)
    ADD EFFECT: ITEM_ADDEFFECT_TYPE=431  ITEM_ADDEFFECT_ELEMENT=950
                ITEM_ADDEFFECT_DMG=500   ITEM_ADDEFFECT_CHANCE=501
                ITEM_ADDEFFECT_STATUS=951 ITEM_ADDEFFECT_POWER=952 ITEM_ADDEFFECT_DURATION=953

  UNCONFIRMED MOD IDs — stored as strings, MUST verify from mods_by_id.txt before SQL insert:
    "FASTCAST"          — Fast Cast (appears on 29706, 29742, 29797)
    "MOVE_SPEED"        — Movement Speed (appears on 29715, 29753, 29805)
    "PHALANX_BONUS"     — Phalanx effect bonus (appears on 29709)
    "WIND_ELE_ACC"      — Wind Elemental Magic Accuracy (appears on 29711)
    "DIVINE_SKILL"      — Divine Magic Skill (appears on 29708, 29738)
    "MAG_DMG_TAKEN"     — Magic Damage Taken% (negative, appears on 29841)
    "REFRESH_MOD"       — Passive Refresh ticks (appears on 29843)
    "SINGING_SKILL"     — Singing Skill (appears on 29848)
    "SHIELD_SKILL"      — Shield Skill (appears on 29744)

  HASTE NOTE: HASTE_GEAR=384. Values: 100=1% 200=2% 300=3%
  SMITE NOTE: SMITE=898, uses 256-scale (10,12,15,20 in value field)
  FIRE_AFFINITY_DMG NOTE: value 2 = +1 wiki level = approx +5% fire element damage
--]]

-- ============================================================
-- MOD WIRING HELPER (not used at runtime — documents format)
-- Each mod entry: {modId, value, "description"}
-- Unconfirmed IDs use string: {"MOD_NAME", value, "description — verify ID"}
-- ============================================================

local customItems = {

-- ============================================================
-- SECTION 1: CASKET / REGULAR DROPS  (flags=0x0000)
-- ============================================================

-- --------------------------------------------------------
-- BATCH 1 REGULAR WEAPONS (IDs 29700–29701)
-- --------------------------------------------------------

{id=29700, name="tarnished_gladius", displayName="Tarnished Gladius",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=102643, level=15, model=243,
 dmg=20, delay=240, dmgType=2, weaponSkill=2,  -- Slashing | Sword
 mods={{9,2,"DEX+2"},{25,5,"ACC+5"}}},

{id=29701, name="gale_axe", displayName="Gale Axe",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=8577, level=30, model=428,
 dmg=37, delay=288, dmgType=2, weaponSkill=4,  -- Slashing | Axe
 mods={{8,3,"STR+3"},{23,8,"ATT+8"}}},

-- --------------------------------------------------------
-- BATCH 2 REGULAR WEAPONS (IDs 29720–29729, excl. NM 29723/29727/29728)
-- --------------------------------------------------------

{id=29720, name="ironwood_club", displayName="Ironwood Club",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=1624276, level=18, model=413,
 dmg=25, delay=282, dmgType=4, weaponSkill=10,  -- Blunt | Club
 mods={{13,2,"MND+2"},{2,15,"HP+15"}}},

{id=29721, name="vipersting_dagger", displayName="Vipersting Dagger",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=329264, level=25, model=468,
 dmg=28, delay=210, dmgType=3, weaponSkill=1,  -- Piercing | Dagger
 mods={{9,3,"DEX+3"},{25,5,"ACC+5"},{11,2,"AGI+2"}}},

{id=29722, name="dustcleave_greataxe", displayName="Dustcleave Greataxe",
 type=5, flags=0x0000, source="Regular Drop",
 slot=1, jobs=129, level=35, model=487,
 dmg=60, delay=444, dmgType=2, weaponSkill=5,  -- Slashing | Great Axe
 mods={{8,4,"STR+4"},{23,10,"ATT+10"}}},

{id=29724, name="thornlance", displayName="Thornlance",
 type=5, flags=0x0000, source="Regular Drop",
 slot=1, jobs=8193, level=40, model=539,
 dmg=66, delay=396, dmgType=3, weaponSkill=7,  -- Piercing | Polearm
 mods={{8,3,"STR+3"},{10,2,"VIT+2"}}},

{id=29725, name="ironknuckle_cestus", displayName="Ironknuckle Cestus",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=131074, level=30, model=476,
 dmg=15, delay=96, dmgType=4, weaponSkill=0,  -- Blunt | H2H
 mods={{8,3,"STR+3"},{289,3,"Subtle Blow+3"}}},

{id=29726, name="cobaltedge_sword", displayName="Cobaltedge Sword",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=37010, level=45, model=543,
 dmg=40, delay=240, dmgType=2, weaponSkill=2,  -- Slashing | Sword
 mods={{8,3,"STR+3"},{9,2,"DEX+2"},{25,6,"ACC+6"}}},

{id=29729, name="reedwhisper_bow", displayName="Reedwhisper Bow",
 type=5, flags=0x0000, source="Regular Drop",
 slot=4, jobs=66560, level=25, model=440,
 dmg=28, delay=504, dmgType=5, weaponSkill=12,  -- Ranged | Archery
 mods={{11,2,"AGI+2"},{26,4,"RACC+4"}}},

-- --------------------------------------------------------
-- BATCH 3 REGULAR WEAPONS (IDs 29780–29787)
-- --------------------------------------------------------

{id=29780, name="rustbite_greatsword", displayName="Rustbite Greatsword",
 type=5, flags=0x0000, source="Regular Drop",
 slot=1, jobs=2097345, level=22, model=499,
 dmg=44, delay=396, dmgType=2, weaponSkill=3,  -- Slashing | Great Sword
 mods={{8,3,"STR+3"},{10,2,"VIT+2"}}},

{id=29781, name="moonblade", displayName="Moonblade",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=36945, level=40, model=527,
 dmg=38, delay=240, dmgType=2, weaponSkill=2,  -- Slashing | Sword
 mods={{13,3,"MND+3"},{25,5,"ACC+5"},{30,4,"MACC+4"}}},

{id=29782, name="needlefang_knife", displayName="Needlefang Knife",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=332336, level=10, model=415,
 dmg=12, delay=210, dmgType=3, weaponSkill=1,  -- Piercing | Dagger
 mods={{9,2,"DEX+2"},{68,3,"EVA+3"}}},

{id=29783, name="shadewhisper_blade", displayName="Shadewhisper Blade",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=6144, level=35, model=491,
 dmg=34, delay=245, dmgType=2, weaponSkill=8,  -- Slashing | Katana
 mods={{9,3,"DEX+3"},{25,5,"ACC+5"}}},

{id=29784, name="bonereap_scythe", displayName="Bonereap Scythe",
 type=5, flags=0x0000, source="Regular Drop",
 slot=1, jobs=128, level=25, model=460,
 dmg=35, delay=480, dmgType=2, weaponSkill=6,  -- Slashing | Scythe
 mods={{8,2,"STR+2"},{12,2,"INT+2"}}},

{id=29785, name="copperlock_crossbow", displayName="Copperlock Crossbow",
 type=5, flags=0x0000, source="Regular Drop",
 slot=4, jobs=66560, level=35, model=498,
 dmg=34, delay=528, dmgType=3, weaponSkill=13,  -- Piercing | Marksmanship
 mods={{11,2,"AGI+2"},{26,5,"RACC+5"}}},

{id=29786, name="elderwood_staff", displayName="Elderwood Staff",
 type=5, flags=0x0000, source="Regular Drop",
 slot=1, jobs=1589276, level=60, model=694,
 dmg=62, delay=366, dmgType=4, weaponSkill=11,  -- Blunt | Staff
 mods={{13,4,"MND+4"},{12,4,"INT+4"},{5,20,"MP+20"}}},

{id=29787, name="ironpaw_knuckles", displayName="Ironpaw Knuckles",
 type=5, flags=0x0000, source="Regular Drop",
 slot=3, jobs=131074, level=60, model=686,
 dmg=24, delay=96, dmgType=4, weaponSkill=0,  -- Blunt | H2H
 mods={{8,4,"STR+4"},{25,6,"ACC+6"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — SWORDS (29851–29853)
-- --------------------------------------------------------

{id=29851, name="copperleaf_blade", displayName="Copperleaf Blade",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=102643, level=14, model=401,
 dmg=15, delay=240, dmgType=2, weaponSkill=2,
 mods={{8,1,"STR+1"},{25,3,"ACC+3"}}},

{id=29852, name="ashbane_foil", displayName="Ashbane Foil",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=36880, level=28, model=433,
 dmg=26, delay=240, dmgType=2, weaponSkill=2,
 mods={{13,2,"MND+2"},{30,4,"MACC+4"},{114,4,"Enfeeble Skill+4"}}},

{id=29853, name="verdant_saber", displayName="Verdant Saber",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=36945, level=48, model=546,
 dmg=40, delay=240, dmgType=2, weaponSkill=2,
 mods={{8,3,"STR+3"},{25,6,"ACC+6"},{10,2,"VIT+2"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — GREAT SWORDS (29857)
-- --------------------------------------------------------

{id=29857, name="ironcleft_claymore", displayName="Ironcleft Claymore",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=2097345, level=22, model=471,
 dmg=42, delay=396, dmgType=2, weaponSkill=3,
 mods={{8,2,"STR+2"},{23,5,"ATT+5"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — AXES (29860–29861)
-- --------------------------------------------------------

{id=29860, name="thornbite_hatchet", displayName="Thornbite Hatchet",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=8577, level=16, model=414,
 dmg=20, delay=288, dmgType=2, weaponSkill=4,
 mods={{8,1,"STR+1"},{23,4,"ATT+4"}}},

{id=29861, name="redrock_chopper", displayName="Redrock Chopper",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=8577, level=38, model=454,
 dmg=40, delay=288, dmgType=2, weaponSkill=4,
 mods={{8,3,"STR+3"},{25,5,"ACC+5"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — GREAT AXES (29864)
-- --------------------------------------------------------

{id=29864, name="colossus_axe", displayName="Colossus Axe",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=129, level=45, model=534,
 dmg=65, delay=444, dmgType=2, weaponSkill=5,
 mods={{8,4,"STR+4"},{23,10,"ATT+10"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — SCYTHES (29867–29868)
-- --------------------------------------------------------

{id=29867, name="rustworn_scythe", displayName="Rustworn Scythe",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=128, level=18, model=461,
 dmg=24, delay=480, dmgType=2, weaponSkill=6,
 mods={{8,2,"STR+2"},{116,3,"Dark Magic Skill+3"}}},

{id=29868, name="bloodmire_scythe", displayName="Bloodmire Scythe",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=128, level=50, model=544,
 dmg=68, delay=480, dmgType=2, weaponSkill=6,
 mods={{8,4,"STR+4"},{12,2,"INT+2"},{116,5,"Dark Magic Skill+5"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — POLEARMS (29871–29872)
-- --------------------------------------------------------

{id=29871, name="splithorn_lance", displayName="Splithorn Lance",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=8193, level=20, model=483,
 dmg=30, delay=396, dmgType=3, weaponSkill=7,
 mods={{8,2,"STR+2"},{10,1,"VIT+1"}}},

{id=29872, name="emberthorn_spear", displayName="Emberthorn Spear",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=8193, level=40, model=545,
 dmg=55, delay=396, dmgType=3, weaponSkill=7,
 mods={{8,3,"STR+3"},{10,3,"VIT+3"},{40,4,"Fire Elemental Accuracy+4 — verify mod 40"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — KATANAS (29875–29876)
-- --------------------------------------------------------

{id=29875, name="foxfire_katana", displayName="Foxfire Katana",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=6144, level=24, model=463,
 dmg=22, delay=245, dmgType=2, weaponSkill=8,
 mods={{9,2,"DEX+2"},{73,2,"Store TP+2"}}},

{id=29876, name="bloodpetal_blade", displayName="Bloodpetal Blade",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=6144, level=42, model=521,
 dmg=36, delay=245, dmgType=2, weaponSkill=8,
 mods={{9,3,"DEX+3"},{25,5,"ACC+5"},{73,3,"Store TP+3"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — GREAT KATANAS (29880)
-- --------------------------------------------------------

{id=29880, name="dawnreach_tachi", displayName="Dawnreach Tachi",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=2048, level=55, model=494,
 dmg=72, delay=450, dmgType=2, weaponSkill=9,
 mods={{8,3,"STR+3"},{9,3,"DEX+3"},{73,4,"Store TP+4"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — CLUBS (29883–29884)
-- --------------------------------------------------------

{id=29883, name="pilgrims_mace", displayName="Pilgrim's Mace",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=1605716, level=14, model=409,
 dmg=12, delay=282, dmgType=4, weaponSkill=10,
 mods={{13,2,"MND+2"},{112,3,"Healing Magic Skill+3"}}},

{id=29884, name="spellbinders_cudgel", displayName="Spellbinder's Cudgel",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=1605652, level=45, model=541,
 dmg=44, delay=282, dmgType=4, weaponSkill=10,
 mods={{13,3,"MND+3"},{12,3,"INT+3"},{114,5,"Enfeeble Skill+5"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — STAVES (29887–29888)
-- --------------------------------------------------------

{id=29887, name="apprentices_rod", displayName="Apprentice's Rod",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=1589276, level=16, model=495,
 dmg=18, delay=366, dmgType=4, weaponSkill=11,
 mods={{12,2,"INT+2"},{5,15,"MP+15"}}},

{id=29888, name="embervein_staff", displayName="Embervein Staff",
 type=5, flags=0x0000, source="Casket",
 slot=1, jobs=524312, level=35, model=525,
 dmg=36, delay=366, dmgType=4, weaponSkill=11,
 mods={{12,3,"INT+3"},{115,5,"Elemental Magic Skill+5"},{347,2,"Fire Affinity Damage+1 (value 2 = +1 wiki level)"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — DAGGERS (29892–29893)
-- --------------------------------------------------------

{id=29892, name="splinter_knife", displayName="Splinter Knife",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=332336, level=14, model=438,
 dmg=10, delay=210, dmgType=3, weaponSkill=1,
 mods={{9,2,"DEX+2"},{14,1,"CHR+1 (DNC Waltz)"}}},

{id=29893, name="venom_fang", displayName="Venom Fang",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=331808, level=32, model=469,
 dmg=24, delay=210, dmgType=3, weaponSkill=1,
 mods={{9,3,"DEX+3"},{11,2,"AGI+2"},{14,2,"CHR+2 (DNC Waltz)"},
       {431,0,"ADD EFFECT TYPE — see additional_effects.lua"},
       {951,0,"ADD EFFECT STATUS — Poison status ID"},
       {501,15,"15% proc chance"},{952,2,"tick dmg=2"},{953,30,"30s duration"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — H2H (29897–29898)
-- --------------------------------------------------------

{id=29897, name="ironhide_knuckles", displayName="Ironhide Knuckles",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=131074, level=18, model=464,
 dmg=8, delay=96, dmgType=4, weaponSkill=0,
 mods={{8,2,"STR+2"},{289,2,"Subtle Blow+2"}}},

{id=29898, name="temple_fists", displayName="Temple Fists",
 type=5, flags=0x0000, source="Casket",
 slot=3, jobs=131074, level=40, model=520,
 dmg=18, delay=96, dmgType=4, weaponSkill=0,
 mods={{8,3,"STR+3"},{25,5,"ACC+5"},{289,3,"Subtle Blow+3"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — ARCHERY (29901–29902)
-- --------------------------------------------------------

{id=29901, name="thornwood_shortbow", displayName="Thornwood Shortbow",
 type=5, flags=0x0000, source="Casket",
 slot=4, jobs=66560, level=18, model=443,
 dmg=18, delay=504, dmgType=5, weaponSkill=12,
 mods={{11,2,"AGI+2"},{26,3,"RACC+3"}}},

{id=29902, name="ironstring_longbow", displayName="Ironstring Longbow",
 type=5, flags=0x0000, source="Casket",
 slot=4, jobs=66560, level=50, model=492,
 dmg=44, delay=504, dmgType=5, weaponSkill=12,
 mods={{11,4,"AGI+4"},{26,5,"RACC+5"},{24,6,"RATT+6"}}},

-- --------------------------------------------------------
-- BATCH 4 CASKET WEAPONS — MARKSMANSHIP (29905–29906)
-- --------------------------------------------------------

{id=29905, name="flintlock_pistol", displayName="Flintlock Pistol",
 type=5, flags=0x0000, source="Casket",
 slot=4, jobs=66560, level=22, model=465,
 dmg=26, delay=528, dmgType=3, weaponSkill=13,
 mods={{11,2,"AGI+2"},{26,3,"RACC+3"}}},

{id=29906, name="bronzelock_rifle", displayName="Bronzelock Rifle",
 type=5, flags=0x0000, source="Casket",
 slot=4, jobs=66560, level=48, model=540,
 dmg=50, delay=528, dmgType=3, weaponSkill=13,
 mods={{11,3,"AGI+3"},{26,5,"RACC+5"},{24,6,"RATT+6"},{365,3,"Snapshot+3%"}}},

-- --------------------------------------------------------
-- BATCH 1 REGULAR ARMOUR
-- --------------------------------------------------------

-- HEAD
{id=29705, name="brushwood_helm", displayName="Brushwood Helm",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=2107587, level=10, model=416, def=13,
 mods={{2,12,"HP+12"},{10,2,"VIT+2"}}},

{id=29706, name="ashen_circlet", displayName="Ashen Circlet",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=1589276, level=35, model=435, def=20,
 mods={{12,4,"INT+4"},{13,3,"MND+3"},{"FASTCAST",3,"Fast Cast+3 — verify mod ID"}}},

-- BODY
{id=29708, name="pilgrims_coat", displayName="Pilgrim's Coat",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32, jobs=1572948, level=20, model=408, def=25,
 mods={{13,3,"MND+3"},{5,25,"MP+25"},{"DIVINE_SKILL",5,"Divine Magic Skill+5 — verify mod ID"}}},

-- HANDS
{id=29711, name="stormcaller_mitts", displayName="Stormcaller Mitts",
 type=4, flags=0x0000, source="Regular Drop",
 slot=64, jobs=99840, level=25, model=421, def=16,
 mods={{11,3,"AGI+3"},{26,5,"RACC+5"},{"WIND_ELE_ACC",4,"Wind Elemental Magic Accuracy+4 — verify mod ID"}}},

-- LEGS
{id=29713, name="dustwalker_subligar", displayName="Dustwalker Subligar",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=333088, level=15, model=417, def=17,
 mods={{2,10,"HP+10"},{68,5,"EVA+5"}}},

{id=29714, name="crestfallen_slacks", displayName="Crestfallen Slacks",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=1589276, level=45, model=554, def=31,
 mods={{12,4,"INT+4"},{13,4,"MND+4"},{5,20,"MP+20"},{296,3,"Conserve MP+3%"}}},

-- FEET
{id=29715, name="mudstrider_boots", displayName="Mudstrider Boots",
 type=4, flags=0x0000, source="Regular Drop",
 slot=256, jobs=333600, level=20, model=432, def=12,
 mods={{11,2,"AGI+2"},{68,5,"EVA+5"},{"MOVE_SPEED",10,"Movement Speed+10% — verify mod ID"}}},

-- NECK
{id=29717, name="cinnabar_necklace", displayName="Cinnabar Necklace",
 type=4, flags=0x0000, source="Regular Drop",
 slot=512, jobs=4194303, level=30, model=0, def=0,
 mods={{2,20,"HP+20"},{8,3,"STR+3"},{10,2,"VIT+2"}}},

-- WAIST
{id=29718, name="burnished_sash", displayName="Burnished Sash",
 type=4, flags=0x0000, source="Regular Drop",
 slot=1024, jobs=1622108, level=40, model=0, def=0,
 mods={{5,25,"MP+25"},{12,3,"INT+3"},{13,3,"MND+3"}}},

-- --------------------------------------------------------
-- BATCH 2 REGULAR ARMOUR
-- --------------------------------------------------------

-- HEAD
{id=29730, name="fieldwarden_cap", displayName="Fieldwarden Cap",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=329008, level=12, model=418, def=12,
 mods={{11,2,"AGI+2"},{2,10,"HP+10"},{68,3,"EVA+3"}}},

{id=29731, name="scholars_mortarboard", displayName="Scholar's Mortarboard",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=1541140, level=28, model=436, def=17,
 mods={{12,4,"INT+4"},{13,3,"MND+3"},{5,20,"MP+20"}}},

{id=29732, name="brigands_bandana", displayName="Brigand's Bandana",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=333088, level=42, model=523, def=22,
 mods={{9,4,"DEX+4"},{25,5,"ACC+5"},{68,4,"EVA+4"}}},

-- BODY
{id=29735, name="ashgrain_vest", displayName="Ashgrain Vest",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32, jobs=333088, level=15, model=420, def=20,
 mods={{2,15,"HP+15"},{68,4,"EVA+4"}}},

{id=29736, name="duskweave_robe", displayName="Duskweave Robe",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32, jobs=1589272, level=30, model=480, def=28,
 mods={{12,4,"INT+4"},{5,30,"MP+30"},{115,5,"Elemental Magic Skill+5"}}},

{id=29737, name="ironguard_hauberk", displayName="Ironguard Hauberk",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32, jobs=10369, level=48, model=562, def=50,
 mods={{8,3,"STR+3"},{10,3,"VIT+3"},{25,6,"ACC+6"}}},

-- HANDS
{id=29740, name="tanners_gloves", displayName="Tanner's Gloves",
 type=4, flags=0x0000, source="Regular Drop",
 slot=64, jobs=331120, level=12, model=419, def=10,
 mods={{2,8,"HP+8"},{10,1,"VIT+1"}}},

{id=29741, name="ember_mitts", displayName="Ember Mitts",
 type=4, flags=0x0000, source="Regular Drop",
 slot=64, jobs=2105409, level=32, model=486, def=20,
 mods={{8,3,"STR+3"},{10,2,"VIT+2"},{40,4,"Fire Elemental Accuracy+4 — verify mod 40"}}},

{id=29742, name="spellthread_gloves", displayName="Spellthread Gloves",
 type=4, flags=0x0000, source="Regular Drop",
 slot=64, jobs=1589276, level=48, model=558, def=18,
 mods={{12,3,"INT+3"},{13,3,"MND+3"},{"FASTCAST",3,"Fast Cast+3 — verify mod ID"}}},

-- LEGS
{id=29745, name="herdsmans_trousers", displayName="Herdsman's Trousers",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=787, level=12, model=422, def=15,
 mods={{2,12,"HP+12"},{13,2,"MND+2"}}},

{id=29746, name="pathfinder_slops", displayName="Pathfinder Slops",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=329264, level=28, model=452, def=24,
 mods={{11,3,"AGI+3"},{68,6,"EVA+6"}}},

{id=29747, name="ironweave_cuisses", displayName="Ironweave Cuisses",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=2107585, level=45, model=536, def=38,
 mods={{8,3,"STR+3"},{10,3,"VIT+3"},{2,20,"HP+20"}}},

-- FEET
{id=29750, name="wanderers_sandals", displayName="Wanderer's Sandals",
 type=4, flags=0x0000, source="Regular Drop",
 slot=256, jobs=1589276, level=12, model=424, def=8,
 mods={{5,12,"MP+12"},{13,2,"MND+2"}}},

{id=29751, name="grimwatcher_greaves", displayName="Grimwatcher Greaves",
 type=4, flags=0x0000, source="Regular Drop",
 slot=256, jobs=2105409, level=30, model=481, def=16,
 mods={{10,3,"VIT+3"},{2,15,"HP+15"}}},

{id=29752, name="fleetfoot_sollerets", displayName="Fleetfoot Sollerets",
 type=4, flags=0x0000, source="Regular Drop",
 slot=256, jobs=2107521, level=50, model=576, def=22,
 mods={{25,5,"ACC+5"},{384,200,"Haste+2% (HASTE_GEAR value 200)"}}},

-- NECK
{id=29755, name="rangers_gorget", displayName="Ranger's Gorget",
 type=4, flags=0x0000, source="Regular Drop",
 slot=512, jobs=4194303, level=20, model=0, def=0,
 mods={{11,3,"AGI+3"},{26,5,"RACC+5"}}},

{id=29756, name="ironhide_choker", displayName="Ironhide Choker",
 type=4, flags=0x0000, source="Regular Drop",
 slot=512, jobs=4194303, level=35, model=0, def=0,
 mods={{2,25,"HP+25"},{10,3,"VIT+3"},{31,5,"DEF Bonus+5 — verify mod 31"}}},

{id=29757, name="scholars_collar", displayName="Scholar's Collar",
 type=4, flags=0x0000, source="Regular Drop",
 slot=512, jobs=4194303, level=45, model=0, def=0,
 mods={{5,30,"MP+30"},{12,3,"INT+3"},{13,3,"MND+3"}}},

{id=29758, name="duelists_chain", displayName="Duelist's Chain",
 type=4, flags=0x0000, source="Regular Drop",
 slot=512, jobs=4194303, level=58, model=0, def=0,
 mods={{8,3,"STR+3"},{9,3,"DEX+3"},{25,6,"ACC+6"}}},

-- WAIST
{id=29760, name="cowhide_belt", displayName="Cowhide Belt",
 type=4, flags=0x0000, source="Regular Drop",
 slot=1024, jobs=4194303, level=12, model=0, def=0,
 mods={{2,10,"HP+10"},{8,2,"STR+2"}}},

{id=29761, name="woven_cord", displayName="Woven Cord",
 type=4, flags=0x0000, source="Regular Drop",
 slot=1024, jobs=4194303, level=25, model=0, def=0,
 mods={{5,15,"MP+15"},{13,2,"MND+2"}}},

{id=29762, name="mercenaries_sash", displayName="Mercenary's Sash",
 type=4, flags=0x0000, source="Regular Drop",
 slot=1024, jobs=4194303, level=40, model=0, def=0,
 mods={{2,20,"HP+20"},{8,3,"STR+3"},{25,4,"ACC+4"}}},

{id=29763, name="hexweave_obi", displayName="Hexweave Obi",
 type=4, flags=0x0000, source="Regular Drop",
 slot=1024, jobs=1589276, level=55, model=0, def=0,
 mods={{5,30,"MP+30"},{12,4,"INT+4"},{296,4,"Conserve MP+4%"}}},

-- EARRINGS
{id=29765, name="copper_loop", displayName="Copper Loop",
 type=4, flags=0x0000, source="Regular Drop",
 slot=6144, jobs=4194303, level=10, model=0, def=0,
 mods={{2,8,"HP+8"}}},

{id=29766, name="mages_stud", displayName="Mage's Stud",
 type=4, flags=0x0000, source="Regular Drop",
 slot=6144, jobs=4194303, level=25, model=0, def=0,
 mods={{5,12,"MP+12"},{12,2,"INT+2"}}},

{id=29767, name="warriors_loop", displayName="Warrior's Loop",
 type=4, flags=0x0000, source="Regular Drop",
 slot=6144, jobs=4194303, level=35, model=0, def=0,
 mods={{8,3,"STR+3"},{25,3,"ACC+3"}}},

{id=29768, name="keen_earring", displayName="Keen Earring",
 type=4, flags=0x0000, source="Regular Drop",
 slot=6144, jobs=4194303, level=50, model=0, def=0,
 mods={{25,5,"ACC+5"},{23,4,"ATT+4"}}},

-- RINGS
{id=29770, name="bronze_ring", displayName="Bronze Ring",
 type=4, flags=0x0000, source="Regular Drop",
 slot=24576, jobs=4194303, level=10, model=0, def=0,
 mods={{2,8,"HP+8"},{10,1,"VIT+1"}}},

{id=29771, name="apprentices_ring", displayName="Apprentice's Ring",
 type=4, flags=0x0000, source="Regular Drop",
 slot=24576, jobs=4194303, level=20, model=0, def=0,
 mods={{5,10,"MP+10"},{13,2,"MND+2"}}},

{id=29772, name="soldiers_ring", displayName="Soldier's Ring",
 type=4, flags=0x0000, source="Regular Drop",
 slot=24576, jobs=4194303, level=38, model=0, def=0,
 mods={{8,3,"STR+3"},{2,15,"HP+15"}}},

{id=29773, name="sorcerers_band", displayName="Sorcerer's Band",
 type=4, flags=0x0000, source="Regular Drop",
 slot=24576, jobs=4194303, level=52, model=0, def=0,
 mods={{12,4,"INT+4"},{5,20,"MP+20"}}},

-- BACK
{id=29775, name="roughspun_cloak", displayName="Roughspun Cloak",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32768, jobs=4194303, level=12, model=0, def=5,
 mods={{2,10,"HP+10"},{13,1,"MND+1"}}},

{id=29776, name="trackers_mantle", displayName="Tracker's Mantle",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32768, jobs=333088, level=30, model=503, def=6,
 mods={{11,3,"AGI+3"},{26,4,"RACC+4"},{68,4,"EVA+4"}}},

{id=29777, name="ironguard_cape", displayName="Ironguard Cape",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32768, jobs=2105409, level=45, model=503, def=8,
 mods={{10,3,"VIT+3"},{2,20,"HP+20"},{27,2,"Enmity+2"}}},

-- --------------------------------------------------------
-- BATCH 3 REGULAR ARMOUR
-- --------------------------------------------------------

-- HEAD
{id=29788, name="riveted_visor", displayName="Riveted Visor",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=2107585, level=25, model=444, def=18,
 mods={{8,2,"STR+2"},{10,3,"VIT+3"},{2,12,"HP+12"}}},

{id=29789, name="silkweave_hood", displayName="Silkweave Hood",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=1589272, level=42, model=526, def=21,
 mods={{12,3,"INT+3"},{5,18,"MP+18"},{115,4,"Elemental Magic Skill+4"}}},

{id=29790, name="trackers_cap", displayName="Tracker's Cap",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=328992, level=55, model=630, def=28,
 mods={{11,4,"AGI+4"},{26,5,"RACC+5"},{68,4,"EVA+4"}}},

{id=29791, name="iron_sentinel_helm", displayName="Iron Sentinel Helm",
 type=4, flags=0x0000, source="Regular Drop",
 slot=16, jobs=2107585, level=65, model=726, def=38,
 mods={{10,4,"VIT+4"},{2,30,"HP+30"},{25,6,"ACC+6"}}},

-- BODY
{id=29792, name="mudcloth_gi", displayName="Mudcloth Gi",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32, jobs=131330, level=25, model=445, def=26,
 mods={{2,20,"HP+20"},{10,2,"VIT+2"},{289,2,"Subtle Blow+2"}}},

{id=29793, name="verdant_robe", displayName="Verdant Robe",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32, jobs=1589268, level=38, model=515, def=30,
 mods={{13,4,"MND+4"},{5,25,"MP+25"},{115,4,"Elemental Magic Skill+4"}}},

{id=29794, name="rangers_surcoat", displayName="Ranger's Surcoat",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32, jobs=66816, level=52, model=587, def=38,
 mods={{11,4,"AGI+4"},{26,5,"RACC+5"},{24,5,"RATT+5"}}},

{id=29795, name="tempered_coat", displayName="Tempered Coat",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32, jobs=268451, level=65, model=733, def=48,
 -- DNC edit: Waltz Potency+3% added (491)
 mods={{8,4,"STR+4"},{9,3,"DEX+3"},{25,8,"ACC+8"},{491,3,"Waltz Potency+3% (DNC edit)"}}},

-- HANDS
{id=29796, name="featherlight_wraps", displayName="Featherlight Wraps",
 type=4, flags=0x0000, source="Regular Drop",
 slot=64, jobs=393474, level=18, model=425, def=11,
 mods={{9,2,"DEX+2"},{2,8,"HP+8"},{289,2,"Subtle Blow+2"}}},

{id=29797, name="channelers_cuffs", displayName="Channeler's Cuffs",
 type=4, flags=0x0000, source="Regular Drop",
 slot=64, jobs=1589276, level=55, model=627, def=20,
 mods={{13,4,"MND+4"},{12,3,"INT+3"},{"FASTCAST",3,"Fast Cast+3 — verify mod ID"}}},

{id=29798, name="ironveil_gauntlets", displayName="Ironveil Gauntlets",
 type=4, flags=0x0000, source="Regular Drop",
 slot=64, jobs=2107521, level=65, model=744, def=30,
 mods={{8,4,"STR+4"},{23,10,"ATT+10"},{25,5,"ACC+5"}}},

{id=29799, name="bonehide_knuckle_guards", displayName="Bonehide Knuckle-Guards",
 type=4, flags=0x0000, source="Regular Drop",
 slot=64, jobs=2179, level=38, model=511, def=22,
 mods={{8,3,"STR+3"},{25,5,"ACC+5"}}},

-- LEGS
{id=29800, name="wanderers_kecks", displayName="Wanderer's Kecks",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=1589788, level=22, model=442, def=20,
 mods={{5,18,"MP+18"},{13,2,"MND+2"},{12,2,"INT+2"}}},

{id=29801, name="boneweave_kecks", displayName="Boneweave Kecks",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=2107523, level=52, model=577, def=36,
 mods={{8,3,"STR+3"},{10,3,"VIT+3"},{23,7,"ATT+7"}}},

{id=29802, name="dawnspun_slops", displayName="Dawnspun Slops",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=1589276, level=65, model=729, def=34,
 mods={{12,5,"INT+5"},{13,4,"MND+4"},{5,25,"MP+25"}}},

{id=29803, name="muddled_breeches", displayName="Muddled Breeches",
 type=4, flags=0x0000, source="Regular Drop",
 slot=128, jobs=333088, level=32, model=488, def=27,
 -- DNC edit: CHR+2 added (14)
 mods={{9,3,"DEX+3"},{11,3,"AGI+3"},{68,5,"EVA+5"},{14,2,"CHR+2 (DNC edit)"}}},

-- FEET
{id=29804, name="brass_shod_boots", displayName="Brass-Shod Boots",
 type=4, flags=0x0000, source="Regular Drop",
 slot=256, jobs=2107587, level=18, model=427, def=11,
 mods={{2,10,"HP+10"},{10,2,"VIT+2"}}},

{id=29805, name="plodders_clogs", displayName="Plodder's Clogs",
 type=4, flags=0x0000, source="Regular Drop",
 slot=256, jobs=329504, level=38, model=510, def=16,
 mods={{11,3,"AGI+3"},{"MOVE_SPEED",8,"Movement Speed+8% — verify mod ID"},{68,4,"EVA+4"}}},

{id=29806, name="ironveil_sabatons", displayName="Ironveil Sabatons",
 type=4, flags=0x0000, source="Regular Drop",
 slot=256, jobs=2107585, level=65, model=742, def=26,
 mods={{8,3,"STR+3"},{23,8,"ATT+8"},{384,200,"Haste+2% (HASTE_GEAR value 200)"}}},

-- NECK
{id=29807, name="menders_gorget", displayName="Mender's Gorget",
 type=4, flags=0x0000, source="Regular Drop",
 slot=512, jobs=4194303, level=15, model=0, def=0,
 mods={{5,12,"MP+12"},{13,2,"MND+2"}}},

{id=29808, name="raiders_necklace", displayName="Raider's Necklace",
 type=4, flags=0x0000, source="Regular Drop",
 slot=512, jobs=4194303, level=48, model=0, def=0,
 mods={{8,3,"STR+3"},{9,3,"DEX+3"},{23,5,"ATT+5"}}},

{id=29809, name="arcane_collar", displayName="Arcane Collar",
 type=4, flags=0x0000, source="Regular Drop",
 slot=512, jobs=4194303, level=62, model=0, def=0,
 mods={{12,4,"INT+4"},{13,3,"MND+3"},{30,6,"MACC+6"}}},

-- WAIST
{id=29810, name="rough_sash", displayName="Rough Sash",
 type=4, flags=0x0000, source="Regular Drop",
 slot=1024, jobs=4194303, level=15, model=0, def=0,
 mods={{2,12,"HP+12"},{8,2,"STR+2"}}},

{id=29811, name="warriors_tassels", displayName="Warrior's Tassels",
 type=4, flags=0x0000, source="Regular Drop",
 slot=1024, jobs=2107587, level=48, model=0, def=0,
 mods={{8,3,"STR+3"},{23,6,"ATT+6"},{25,4,"ACC+4"}}},

{id=29812, name="spellbinders_belt", displayName="Spellbinder's Belt",
 type=4, flags=0x0000, source="Regular Drop",
 slot=1024, jobs=1622044, level=62, model=0, def=0,
 mods={{5,25,"MP+25"},{12,4,"INT+4"},{296,3,"Conserve MP+3%"}}},

-- EARRINGS
{id=29813, name="scouts_earring", displayName="Scout's Earring",
 type=4, flags=0x0000, source="Regular Drop",
 slot=6144, jobs=4194303, level=18, model=0, def=0,
 mods={{11,2,"AGI+2"},{68,3,"EVA+3"}}},

{id=29814, name="savants_earring", displayName="Savant's Earring",
 type=4, flags=0x0000, source="Regular Drop",
 slot=6144, jobs=4194303, level=62, model=0, def=0,
 mods={{12,3,"INT+3"},{13,2,"MND+2"},{30,4,"MACC+4"}}},

-- RINGS
{id=29815, name="toughened_ring", displayName="Toughened Ring",
 type=4, flags=0x0000, source="Regular Drop",
 slot=24576, jobs=4194303, level=28, model=0, def=0,
 mods={{10,3,"VIT+3"},{2,12,"HP+12"}}},

{id=29816, name="battlemage_band", displayName="Battlemage Band",
 type=4, flags=0x0000, source="Regular Drop",
 slot=24576, jobs=4194303, level=62, model=0, def=0,
 mods={{8,2,"STR+2"},{12,2,"INT+2"},{25,4,"ACC+4"}}},

-- BACK
{id=29817, name="brigands_cape", displayName="Brigand's Cape",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32768, jobs=333600, level=22, model=503, def=5,
 mods={{11,2,"AGI+2"},{68,5,"EVA+5"}}},

{id=29818, name="menders_mantle", displayName="Mender's Mantle",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32768, jobs=1622044, level=42, model=503, def=6,
 mods={{13,3,"MND+3"},{5,20,"MP+20"}}},

{id=29819, name="soldiers_cloak", displayName="Soldier's Cloak",
 type=4, flags=0x0000, source="Regular Drop",
 slot=32768, jobs=2107587, level=62, model=503, def=9,
 mods={{8,3,"STR+3"},{10,3,"VIT+3"},{2,20,"HP+20"}}},

-- end Section 1

-- ============================================================
-- SECTION 2: CUSTOM NM DROPS  (flags=0x0C00  RARE+EX/No-trade)
-- ============================================================

-- --------------------------------------------------------
-- BATCH 1 NM WEAPONS
-- --------------------------------------------------------

{id=29702, name="thornwood_staff", displayName="Thornwood Staff",
 type=5, flags=0x0C00, source="Custom NM Drop — Grovekeeper Rootwall (Yuhtunga Jungle lv47, Diff A)",
 slot=1, jobs=1589276, level=45, model=516,
 dmg=52, delay=366, dmgType=4, weaponSkill=11,
 mods={{12,5,"INT+5"},{13,4,"MND+4"},{5,30,"MP+30"},{30,6,"MACC+6"}}},

{id=29703, name="rimehunters_bow", displayName="Rimehunter's Bow",
 type=5, flags=0x0C00, source="Custom NM Drop — Glacefang Velthar (Cape Teriggan lv57, Diff B)",
 slot=4, jobs=66560, level=55, model=623,
 dmg=51, delay=504, dmgType=5, weaponSkill=12,
 mods={{11,5,"AGI+5"},{26,7,"RACC+7"},{24,8,"RATT+8"}}},

{id=29704, name="ashveil_katana", displayName="Ashveil Katana",
 type=5, flags=0x0C00, source="Custom NM Drop — Ashveil Ryouken (Den of Rancor lv67, Diff C)",
 slot=3, jobs=6144, level=65, model=741,
 dmg=58, delay=245, dmgType=2, weaponSkill=8,
 mods={{8,4,"STR+4"},{9,5,"DEX+5"},{73,4,"Store TP+4"},{165,3,"Crit Hit Rate+3%"}}},

-- --------------------------------------------------------
-- BATCH 1 NM ARMOUR
-- --------------------------------------------------------

{id=29707, name="ironshroud_mask", displayName="Ironshroud Mask",
 type=4, flags=0x0C00, source="Custom NM Drop — Warbound Korvash (Gustav Tunnel lv62, Diff B-C)",
 slot=16, jobs=10369, level=60, model=643, def=35,
 mods={{8,5,"STR+5"},{23,12,"ATT+12"},{384,200,"Haste+2% (HASTE_GEAR value 200)"}}},

{id=29709, name="ember_plate", displayName="Ember Plate",
 type=4, flags=0x0C00, source="Custom NM Drop — Pyrecult Drayven (Garlaige Citadel lv42, Diff A)",
 slot=32, jobs=2105409, level=40, model=519, def=46,
 mods={{2,45,"HP+45"},{10,5,"VIT+5"},{"PHALANX_BONUS",3,"Phalanx+3 — verify mod ID"}}},

{id=29710, name="shadowweave_tunic", displayName="Shadowweave Tunic",
 type=4, flags=0x0C00, source="Custom NM Drop — Ebonveil Tachirak (Temple of Uggalepih lv65, Diff C)",
 slot=32, jobs=331808, level=62, model=672, def=40,
 -- DNC edit: CHR+2 added (mod 14); Haste+3% = HASTE_GEAR value 300
 mods={{9,6,"DEX+6"},{11,5,"AGI+5"},{384,300,"Haste+3% (HASTE_GEAR value 300)"},
       {302,1,"Triple Attack+1%"},{14,2,"CHR+2 (DNC edit)"}}},

{id=29712, name="hammerfist_gauntlets", displayName="Hammerfist Gauntlets",
 type=4, flags=0x0C00, source="Custom NM Drop — Ironmonk Kujazan (Crawlers Nest lv52, Diff A)",
 slot=64, jobs=131074, level=50, model=583, def=30,
 mods={{8,4,"STR+4"},{80,5,"H2H Skill+5"},{289,5,"Subtle Blow+5"}}},

{id=29716, name="gloamstone_sabots", displayName="Gloamstone Sabots",
 type=4, flags=0x0C00, source="Custom NM Drop — Blight Serafi Yzen (Sanctuary of Zi'Tah lv57, Diff B)",
 slot=256, jobs=1572888, level=55, model=612, def=24,
 mods={{12,5,"INT+5"},{114,8,"Enfeeble Skill+8"},{30,8,"MACC+8"}}},

{id=29719, name="wanderers_mantle", displayName="Wanderer's Mantle",
 type=4, flags=0x0C00, source="Custom NM Drop — Ashwind Yoichi (Batallia Downs lv52, Diff A)",
 slot=32768, jobs=4194303, level=50, model=503, def=8,
 mods={{11,4,"AGI+4"},{68,6,"EVA+6"},{26,6,"RACC+6"},{259,1,"Dual Wield+1"}}},

-- --------------------------------------------------------
-- BATCH 2 NM WEAPONS
-- --------------------------------------------------------

{id=29723, name="wraithreap_scythe", displayName="Wraithreap Scythe",
 type=5, flags=0x0C00, source="Custom NM Drop — Soulrend Hagalaz (Gusgen Mines lv52, Diff A)",
 slot=1, jobs=128, level=50, model=561,
 dmg=79, delay=480, dmgType=2, weaponSkill=6,
 mods={{8,4,"STR+4"},{12,3,"INT+3"},{116,5,"Dark Magic Skill+5"}}},

{id=29727, name="ashlock_musket", displayName="Ashlock Musket",
 type=5, flags=0x0C00, source="Custom NM Drop — Coldshot Meridia (Cape Teriggan lv62, Diff B-C)",
 slot=4, jobs=66560, level=60, model=673,
 dmg=60, delay=528, dmgType=3, weaponSkill=13,
 mods={{11,4,"AGI+4"},{26,7,"RACC+7"},{24,8,"RATT+8"}}},

{id=29728, name="ironbone_greataxe", displayName="Ironbone Greataxe",
 type=5, flags=0x0C00, source="Custom NM Drop — Marrowlord Calagor (Eldieme Necropolis lv67, Diff C)",
 slot=1, jobs=129, level=65, model=748,
 dmg=93, delay=444, dmgType=2, weaponSkill=5,
 mods={{8,6,"STR+6"},{23,14,"ATT+14"},{165,2,"Crit Hit Rate+2%"}}},

-- --------------------------------------------------------
-- BATCH 2 NM ARMOUR
-- --------------------------------------------------------

{id=29733, name="templar_crown", displayName="Templar Crown",
 type=4, flags=0x0C00, source="Custom NM Drop — Ironvow Godefret (Bostaunieux Oubliette lv57, Diff B)",
 slot=16, jobs=2097217, level=55, model=638, def=33,
 mods={{10,5,"VIT+5"},{2,30,"HP+30"},{27,3,"Enmity+3"}}},

{id=29734, name="phantom_visor", displayName="Phantom Visor",
 type=4, flags=0x0C00, source="Custom NM Drop — Voidface Halkyr (Middle Delkfutt Tower lv70, Diff C)",
 slot=16, jobs=327956, level=68, model=721, def=30,
 mods={{9,4,"DEX+4"},{12,3,"INT+3"},{30,6,"MACC+6"}}},

{id=29738, name="cloistered_surcoat", displayName="Cloistered Surcoat",
 type=4, flags=0x0C00, source="Custom NM Drop — Prior Elosenne (Bostaunieux Oubliette lv60, Diff B)",
 slot=32, jobs=524372, level=58, model=659, def=42,
 mods={{13,5,"MND+5"},{2,40,"HP+40"},{27,4,"Enmity+4"},
       {"DIVINE_SKILL",6,"Divine Magic Skill+6 — verify mod ID"}}},

{id=29739, name="reavers_coat", displayName="Reaver's Coat",
 type=4, flags=0x0C00, source="Custom NM Drop — Blackmantle Sorvath (Boyahda Tree lv72, Diff D)",
 slot=32, jobs=10369, level=70, model=756, def=52,
 mods={{8,5,"STR+5"},{23,14,"ATT+14"},{165,2,"Crit Hit Rate+2%"}}},

{id=29743, name="duelists_gages", displayName="Duelist's Gages",
 type=4, flags=0x0C00, source="Custom NM Drop — Argent Blade Veskan (Sea Serpent Grotto lv62, Diff C)",
 slot=64, jobs=98352, level=60, model=671, def=24,
 mods={{9,4,"DEX+4"},{12,4,"INT+4"},{30,7,"MACC+7"}}},

{id=29744, name="ironwill_gauntlets", displayName="Ironwill Gauntlets",
 type=4, flags=0x0C00, source="Custom NM Drop — Rampart Vaskorath (Upper Delkfutt Tower lv72, Diff D)",
 slot=64, jobs=2097217, level=70, model=752, def=32,
 mods={{10,5,"VIT+5"},{27,5,"Enmity+5"},{"SHIELD_SKILL",6,"Shield Skill+6 — verify mod ID"}}},

{id=29748, name="shadowstep_hakama", displayName="Shadowstep Hakama",
 type=4, flags=0x0C00, source="Custom NM Drop — Veilstep Manirak (Den of Rancor lv62, Diff C)",
 slot=128, jobs=268288, level=60, model=669, def=34,
 -- DNC edit: CHR+3 added (14); Waltz Potency+3% added (491)
 mods={{9,4,"DEX+4"},{11,4,"AGI+4"},{289,4,"Subtle Blow+4"},
       {14,3,"CHR+3 (DNC edit)"},{491,3,"Waltz Potency+3% (DNC edit)"}}},

{id=29749, name="warlords_cuisses", displayName="Warlord's Cuisses",
 type=4, flags=0x0C00, source="Custom NM Drop — Warscourge Orthek (Den of Rancor lv72, Diff D)",
 slot=128, jobs=10369, level=70, model=757, def=48,
 mods={{8,5,"STR+5"},{23,12,"ATT+12"},{288,1,"Double Attack+1%"}}},

{id=29753, name="thornwalker_boots", displayName="Thornwalker Boots",
 type=4, flags=0x0C00, source="Custom NM Drop — Stalkshroud Rektan (Yhoator Jungle lv65, Diff C)",
 slot=256, jobs=266496, level=62, model=689, def=20,
 mods={{11,4,"AGI+4"},{68,6,"EVA+6"},{"MOVE_SPEED",12,"Movement Speed+12% — verify mod ID"}}},

{id=29754, name="gravewarden_sabatons", displayName="Gravewarden Sabatons",
 type=4, flags=0x0C00, source="Custom NM Drop — Gravewatch Ardan (Eldieme Necropolis lv72, Diff D)",
 slot=256, jobs=10369, level=70, model=759, def=28,
 mods={{8,4,"STR+4"},{23,10,"ATT+10"},{73,3,"Store TP+3"}}},

{id=29759, name="wardens_torque", displayName="Warden's Torque",
 type=4, flags=0x0C00, source="Custom NM Drop — Ironpost Valdren (Kuftal Tunnel lv70, Diff C)",
 slot=512, jobs=4194303, level=68, model=0, def=0,
 mods={{2,40,"HP+40"},{10,4,"VIT+4"},{27,4,"Enmity+4"}}},

{id=29764, name="titans_girdle", displayName="Titan's Girdle",
 type=4, flags=0x0C00, source="Custom NM Drop — Iron-Knuckle Borvaag (Feiyin lv70, Diff C)",
 slot=1024, jobs=2105409, level=68, model=0, def=0,
 mods={{8,4,"STR+4"},{10,4,"VIT+4"},{2,35,"HP+35"}}},

{id=29769, name="hunters_earring", displayName="Hunter's Earring",
 type=4, flags=0x0C00, source="Custom NM Drop — Razorfang Kellath (Sanctuary of Zi'Tah lv62, Diff B-C)",
 slot=6144, jobs=4194303, level=60, model=0, def=0,
 mods={{11,3,"AGI+3"},{26,5,"RACC+5"},{24,4,"RATT+4"}}},

{id=29774, name="champions_ring", displayName="Champion's Ring",
 type=4, flags=0x0C00, source="Custom NM Drop — Bladeghost Arthek (Feiyin lv67, Diff C)",
 slot=24576, jobs=4194303, level=65, model=0, def=0,
 mods={{8,4,"STR+4"},{25,5,"ACC+5"},{23,6,"ATT+6"}}},

{id=29778, name="spellward_mantle", displayName="Spellward Mantle",
 type=4, flags=0x0C00, source="Custom NM Drop — Runeseeker Valdris (Toraimarai Canal lv57, Diff B)",
 slot=32768, jobs=1589276, level=55, model=503, def=7,
 mods={{12,4,"INT+4"},{13,4,"MND+4"},{5,25,"MP+25"}}},

{id=29779, name="galeshroud_cloak", displayName="Galeshroud Cloak",
 type=4, flags=0x0C00, source="Custom NM Drop — The Nameless Blade (Feiyin lv70, Diff C-D)",
 slot=32768, jobs=4194303, level=68, model=503, def=9,
 mods={{11,5,"AGI+5"},{68,8,"EVA+8"},{259,1,"Dual Wield+1"}}},

-- --------------------------------------------------------
-- TIER 6 NM WEAPONS (IDs 29843–29845)
-- --------------------------------------------------------

{id=29843, name="saintwood_staff", displayName="Saintwood Staff",
 type=5, flags=0x0C00, source="Custom NM Drop — Luminary Aethos (Ro'Maeve lv73, Diff D — Lightsday spawn)",
 slot=1, jobs=524292, level=72, model=760,
 dmg=69, delay=366, dmgType=4, weaponSkill=11,
 -- Refresh+1: "REFRESH_MOD" is unconfirmed — verify ID
 mods={{13,6,"MND+6"},{112,10,"Healing Magic Skill+10"},{374,10,"Cure Potency+10%"},
       {"REFRESH_MOD",1,"Refresh+1 — verify mod ID"}}},

{id=29844, name="eclipse_katana", displayName="Eclipse Katana",
 type=5, flags=0x0C00, source="Custom NM Drop — Duskblade Soraiken (Den of Rancor lv73, Diff D)",
 slot=3, jobs=6144, level=72, model=761,
 dmg=64, delay=245, dmgType=2, weaponSkill=8,
 mods={{9,6,"DEX+6"},{73,6,"Store TP+6"},{259,1,"Dual Wield+1"},{165,3,"Crit Hit Rate+3%"}}},

{id=29845, name="abyssal_tabar", displayName="Abyssal Tabar",
 type=5, flags=0x0C00, source="Custom NM Drop — Bonelord Galvrak (Valley of Sorrows lv72, Diff D)",
 slot=1, jobs=129, level=70, model=765,
 dmg=100, delay=444, dmgType=2, weaponSkill=5,
 mods={{8,6,"STR+6"},{25,8,"ACC+8"},{23,18,"ATT+18"},{288,1,"Double Attack+1%"},{898,20,"Smite+20 (256 scale)"}}},

-- --------------------------------------------------------
-- TIER 6 NM ARMOUR (IDs 29840–29842, 29846–29850)
-- --------------------------------------------------------

{id=29840, name="voidheart_haubergeon", displayName="Voidheart Haubergeon",
 type=4, flags=0x0C00, source="Custom NM Drop — The Hollow Warden (Ru'Aun Gardens lv74, Diff D — Sky access)",
 slot=32, jobs=14499, level=72, model=762, def=58,
 mods={{8,5,"STR+5"},{9,4,"DEX+4"},{25,10,"ACC+10"},{23,14,"ATT+14"},
       {384,300,"Haste+3% (HASTE_GEAR value 300)"},{288,1,"Double Attack+1%"}}},

{id=29841, name="covenant_plate", displayName="Covenant Plate",
 type=4, flags=0x0C00, source="Custom NM Drop — Ironvault Golem Ru'Savat (Shrine of Ru'Avitau lv74, Diff D — Sky access)",
 slot=32, jobs=2097217, level=70, model=763, def=65,
 -- MAG_DMG_TAKEN is unconfirmed; value -8 = -8% magic damage taken
 mods={{2,60,"HP+60"},{10,6,"VIT+6"},{27,8,"Enmity+8"},
       {"MAG_DMG_TAKEN",-8,"Magic Damage Taken-8% — verify mod ID and value scale"},
       {518,5,"Shield Block Rate+5%"}}},

{id=29842, name="starweavers_robe", displayName="Starweaver's Robe",
 type=4, flags=0x0C00, source="Custom NM Drop — Nullweave Sorcant (Garden of Ru'Hmet lv75, Diff D — CoP access)",
 slot=32, jobs=1589272, level=72, model=764, def=38,
 mods={{12,7,"INT+7"},{13,5,"MND+5"},{5,50,"MP+50"},
       {384,200,"Haste+2% (HASTE_GEAR value 200)"},{487,10,"Magic Burst Bonus+10%"}}},

{id=29846, name="vantage_crown", displayName="Vantage Crown",
 type=4, flags=0x0C00, source="Custom NM Drop — Stormwing Halcyren (Ru'Aun Gardens lv72, Diff D — Sky access)",
 slot=16, jobs=66560, level=70, model=767, def=32,
 mods={{11,5,"AGI+5"},{26,8,"RACC+8"},{365,7,"Snapshot+7%"},{964,5,"Ranged Crit Damage+5%"}}},

{id=29847, name="fateweaver_mantle", displayName="Fateweaver Mantle",
 type=4, flags=0x0C00, source="Custom NM Drop — Fatebound Summoner Arishai (Ro'Maeve lv73, Diff D)",
 slot=32768, jobs=16640, level=70, model=503, def=10,
 -- BP_DELAY is negative (reduces delay); PERPETUATION_REDUCTION reduces cost
 mods={{13,3,"MND+3"},{126,10,"Blood Pact Rage Damage+10%"},
       {357,-10,"Blood Pact Delay-10"},{346,2,"Avatar Perpetuation Cost-2"}}},

{id=29848, name="requiem_torque", displayName="Requiem Torque",
 type=4, flags=0x0C00, source="Custom NM Drop — The Last Songwright (Eldieme Necropolis lv73, Diff D)",
 slot=512, jobs=4194303, level=72, model=0, def=0,
 -- SINGING_SKILL is unconfirmed
 mods={{14,6,"CHR+6"},{"SINGING_SKILL",8,"Singing Skill+8 — verify mod ID"},
       {454,15,"Song Duration Bonus+15%"}}},

{id=29849, name="shadowstrike_ring", displayName="Shadowstrike Ring",
 type=4, flags=0x0C00, source="Custom NM Drop — Gutrender Thiask (Temple of Uggalepih lv73, Diff D)",
 slot=24576, jobs=4194303, level=70, model=0, def=0,
 -- DNC edit: Waltz Potency+2% already included in base design
 mods={{9,5,"DEX+5"},{11,4,"AGI+4"},{830,5,"Sneak Attack DEX Bonus+5%"},
       {302,1,"Triple Attack+1%"},{491,2,"Waltz Potency+2% (DNC)"}}},

{id=29850, name="feral_warders_cuirass", displayName="Feral Warder's Cuirass",
 type=4, flags=0x0C00, source="Custom NM Drop — Primalhide Varrakh (Sanctuary of Zi'Tah lv72, Diff D)",
 slot=32, jobs=256, level=70, model=768, def=55,
 -- PET_ATK_DEF/PET_ACC_EVA: value scale may differ — verify against pet mod docs
 mods={{8,4,"STR+4"},{990,20,"Pet ATK+20 (verify PET_ATK_DEF scale)"},
       {991,15,"Pet ACC+15 (verify PET_ACC_EVA scale)"},
       {364,15,"Reward HP Potency+15% (verify REWARD_HP_BONUS scale)"},
       {995,1000,"Pet TP Bonus+1000"}}},

-- end Section 2

-- ============================================================
-- SECTION 3: BOSS FATE DROPS  (flags=0x0000  tradeable rare open-world)
-- ============================================================

-- --------------------------------------------------------
-- SWORDS
-- --------------------------------------------------------

{id=29854, name="stormreavers_edge", displayName="Stormreaver's Edge",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=102481, level=58, model=569,
 dmg=50, delay=240, dmgType=2, weaponSkill=2,
 mods={{8,4,"STR+4"},{9,3,"DEX+3"},{25,8,"ACC+8"},
       {431,0,"ADD EFFECT TYPE — Thunder (see additional_effects.lua)"},
       {950,4,"Thunder element (4)"},{501,15,"15% proc"},{500,20,"base add dmg 20"}}},

{id=29855, name="ironblood_gladius", displayName="Ironblood Gladius",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=102643, level=18, model=429,
 dmg=20, delay=240, dmgType=2, weaponSkill=2,
 mods={{9,3,"DEX+3"},{25,7,"ACC+7"},{288,1,"Double Attack+1%"}}},

{id=29856, name="whitemantle_saber", displayName="Whitemantle Saber",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=524372, level=32, model=434,
 dmg=30, delay=240, dmgType=2, weaponSkill=2,
 mods={{13,4,"MND+4"},{25,6,"ACC+6"},{27,3,"Enmity+3"},{374,4,"Cure Potency+4%"}}},

-- --------------------------------------------------------
-- GREAT SWORDS
-- --------------------------------------------------------

{id=29858, name="soulcleave", displayName="Soulcleave",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=129, level=55, model=530,
 dmg=74, delay=396, dmgType=2, weaponSkill=3,
 mods={{8,5,"STR+5"},{23,12,"ATT+12"},{288,1,"Double Attack+1%"},{96,8,"Souleater Effect+8%"}}},

{id=29859, name="wrathcleft", displayName="Wrathcleft",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=2097345, level=20, model=447,
 dmg=36, delay=396, dmgType=2, weaponSkill=3,
 mods={{8,3,"STR+3"},{23,8,"ATT+8"},{898,10,"Smite+10 (256 scale)"}}},

-- --------------------------------------------------------
-- AXES
-- --------------------------------------------------------

{id=29862, name="ravagers_axe", displayName="Ravager's Axe",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=385, level=62, model=563,
 dmg=68, delay=288, dmgType=2, weaponSkill=4,
 mods={{8,5,"STR+5"},{23,14,"ATT+14"},{306,8,"Zanshin+8%"}}},

{id=29863, name="bonecleave_hatchet", displayName="Bonecleave Hatchet",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=8577, level=22, model=437,
 dmg=27, delay=288, dmgType=2, weaponSkill=4,
 mods={{8,3,"STR+3"},{23,7,"ATT+7"},{306,5,"Zanshin+5%"}}},

-- --------------------------------------------------------
-- GREAT AXES
-- --------------------------------------------------------

{id=29865, name="volcanic_tabar", displayName="Volcanic Tabar",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=129, level=62, model=564,
 dmg=84, delay=444, dmgType=2, weaponSkill=5,
 mods={{8,5,"STR+5"},{23,16,"ATT+16"},{898,15,"Smite+15 (256 scale)"},
       {431,0,"ADD EFFECT TYPE — Fire (see additional_effects.lua)"},
       {950,2,"Fire element (2)"},{501,20,"20% proc"},{500,30,"base add dmg 30"}}},

{id=29866, name="colossbreaker", displayName="Colossbreaker",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=129, level=28, model=472,
 dmg=48, delay=444, dmgType=2, weaponSkill=5,
 mods={{8,4,"STR+4"},{23,10,"ATT+10"},{898,12,"Smite+12 (256 scale)"}}},

-- --------------------------------------------------------
-- SCYTHES
-- --------------------------------------------------------

{id=29869, name="gravereap", displayName="Gravereap",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=128, level=72, model=565,
 dmg=92, delay=480, dmgType=2, weaponSkill=6,
 mods={{8,6,"STR+6"},{12,4,"INT+4"},{288,1,"Double Attack+1%"},{315,12,"Drain & Aspir Potency+12%"}}},

{id=29870, name="soulcrop", displayName="Soulcrop",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=128, level=22, model=462,
 dmg=32, delay=480, dmgType=2, weaponSkill=6,
 mods={{8,3,"STR+3"},{12,2,"INT+2"},{116,5,"Dark Magic Skill+5"},{96,5,"Souleater Effect+5%"}}},

-- --------------------------------------------------------
-- POLEARMS
-- --------------------------------------------------------

{id=29873, name="dragonthorn_bident", displayName="Dragonthorn Bident",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=8192, level=60, model=566,
 dmg=78, delay=396, dmgType=3, weaponSkill=7,
 mods={{8,5,"STR+5"},{10,4,"VIT+4"},{362,15,"Jump ATT Bonus+15%"},{402,5,"Wyvern Breath+5"}}},

{id=29874, name="fangbore_lance", displayName="Fangbore Lance",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=8193, level=24, model=484,
 dmg=40, delay=396, dmgType=3, weaponSkill=7,
 mods={{8,3,"STR+3"},{10,2,"VIT+2"},{362,10,"Jump ATT Bonus+10%"}}},

-- --------------------------------------------------------
-- KATANAS
-- --------------------------------------------------------

{id=29877, name="veilstrike", displayName="Veilstrike",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=4096, level=65, model=567,
 dmg=60, delay=245, dmgType=2, weaponSkill=8,
 mods={{9,5,"DEX+5"},{25,8,"ACC+8"},{259,1,"Dual Wield+1"},{308,4,"Ninja Tool Save+4%"}}},

{id=29878, name="ghostflicker", displayName="Ghostflicker",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=6144, level=18, model=441,
 dmg=18, delay=245, dmgType=2, weaponSkill=8,
 mods={{9,3,"DEX+3"},{73,4,"Store TP+4"}}},

{id=29879, name="emberpetal_blade", displayName="Emberpetal Blade",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=6144, level=36, model=489,
 dmg=32, delay=245, dmgType=2, weaponSkill=8,
 mods={{9,4,"DEX+4"},{25,6,"ACC+6"},{73,4,"Store TP+4"},{118,4,"Ninjutsu Skill+4"}}},

-- --------------------------------------------------------
-- GREAT KATANAS
-- --------------------------------------------------------

{id=29881, name="nightfalls_reach", displayName="Nightfall's Reach",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=2048, level=68, model=568,
 dmg=88, delay=450, dmgType=2, weaponSkill=9,
 mods={{8,5,"STR+5"},{9,4,"DEX+4"},{73,6,"Store TP+6"},{306,10,"Zanshin+10%"},{175,5,"Skillchain Damage+5%"}}},

{id=29882, name="duskfang_tachi", displayName="Duskfang Tachi",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=2048, level=30, model=475,
 dmg=50, delay=450, dmgType=2, weaponSkill=9,
 mods={{8,3,"STR+3"},{9,3,"DEX+3"},{73,5,"Store TP+5"},{175,4,"Skillchain Damage+4%"}}},

-- --------------------------------------------------------
-- CLUBS
-- --------------------------------------------------------

{id=29885, name="sanctum_mace", displayName="Sanctum Mace",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=524356, level=65, model=570,
 dmg=62, delay=282, dmgType=4, weaponSkill=10,
 mods={{13,5,"MND+5"},{112,8,"Healing Magic Skill+8"},{27,4,"Enmity+4"},{374,6,"Cure Potency+6%"}}},

{id=29886, name="brightvow_mace", displayName="Brightvow Mace",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=1605716, level=18, model=411,
 dmg=20, delay=282, dmgType=4, weaponSkill=10,
 mods={{13,4,"MND+4"},{112,5,"Healing Magic Skill+5"},{374,3,"Cure Potency+3%"}}},

-- --------------------------------------------------------
-- STAVES
-- --------------------------------------------------------

{id=29889, name="voidchannel_staff", displayName="Voidchannel Staff",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=524296, level=65, model=571,
 dmg=72, delay=366, dmgType=4, weaponSkill=11,
 mods={{12,6,"INT+6"},{115,8,"Elemental Magic Skill+8"},{487,8,"Magic Burst Bonus+8%"},{902,5,"Occult Acumen+5"}}},

{id=29890, name="voidmere_rod", displayName="Voidmere Rod",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=1589276, level=24, model=496,
 dmg=26, delay=366, dmgType=4, weaponSkill=11,
 mods={{12,4,"INT+4"},{5,20,"MP+20"},{487,5,"Magic Burst Bonus+5%"}}},

{id=29891, name="thornroot_stave", displayName="Thornroot Stave",
 type=5, flags=0x0000, source="Boss FATE",
 slot=1, jobs=1589276, level=38, model=528,
 dmg=40, delay=366, dmgType=4, weaponSkill=11,
 mods={{12,4,"INT+4"},{13,3,"MND+3"},{115,6,"Elemental Magic Skill+6"},{296,3,"Conserve MP+3%"}}},

-- --------------------------------------------------------
-- DAGGERS
-- --------------------------------------------------------

{id=29894, name="shadowsnap_blade", displayName="Shadowsnap Blade",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=266272, level=58, model=572,
 dmg=46, delay=210, dmgType=3, weaponSkill=1,
 mods={{9,5,"DEX+5"},{11,4,"AGI+4"},{14,3,"CHR+3 (DNC Waltz)"},
       {830,4,"Sneak Attack DEX Bonus+4%"},{165,2,"Crit Hit Rate+2%"}}},

{id=29895, name="whispercut", displayName="Whispercut",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=332336, level=16, model=439,
 dmg=15, delay=210, dmgType=3, weaponSkill=1,
 mods={{9,3,"DEX+3"},{14,2,"CHR+2 (DNC Waltz)"},{830,3,"Sneak Attack DEX Bonus+3%"}}},

{id=29896, name="blackscale_knife", displayName="Blackscale Knife",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=331808, level=36, model=485,
 dmg=30, delay=210, dmgType=3, weaponSkill=1,
 mods={{9,4,"DEX+4"},{11,3,"AGI+3"},{14,2,"CHR+2 (DNC Waltz)"},
       {165,2,"Crit Hit Rate+2%"},{68,5,"EVA+5"}}},

-- --------------------------------------------------------
-- H2H
-- --------------------------------------------------------

{id=29899, name="wrath_caestus", displayName="Wrath Caestus",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=2, level=68, model=573,
 dmg=28, delay=96, dmgType=4, weaponSkill=0,
 mods={{8,6,"STR+6"},{291,6,"Counter+6%"},{292,6,"Kick Attack Rate+6%"},{165,2,"Crit Hit Rate+2%"}}},

{id=29900, name="hammerfall_fists", displayName="Hammerfall Fists",
 type=5, flags=0x0000, source="Boss FATE",
 slot=3, jobs=131074, level=24, model=479,
 dmg=11, delay=96, dmgType=4, weaponSkill=0,
 mods={{8,3,"STR+3"},{291,4,"Counter+4%"},{289,3,"Subtle Blow+3"}}},

-- --------------------------------------------------------
-- ARCHERY
-- --------------------------------------------------------

{id=29903, name="stormstring_warbow", displayName="Stormstring Warbow",
 type=5, flags=0x0000, source="Boss FATE",
 slot=4, jobs=1024, level=70, model=574,
 dmg=62, delay=504, dmgType=5, weaponSkill=12,
 mods={{11,5,"AGI+5"},{26,7,"RACC+7"},{24,10,"RATT+10"},
       {359,5,"Rapid Shot+5%"},{964,4,"Ranged Crit Damage+4%"}}},

{id=29904, name="thornpull_bow", displayName="Thornpull Bow",
 type=5, flags=0x0000, source="Boss FATE",
 slot=4, jobs=66560, level=20, model=446,
 dmg=22, delay=504, dmgType=5, weaponSkill=12,
 mods={{11,3,"AGI+3"},{26,5,"RACC+5"},{359,3,"Rapid Shot+3%"}}},

-- --------------------------------------------------------
-- MARKSMANSHIP
-- --------------------------------------------------------

{id=29907, name="ironhail_cannon", displayName="Ironhail Cannon",
 type=5, flags=0x0000, source="Boss FATE",
 slot=4, jobs=66560, level=72, model=575,
 dmg=76, delay=528, dmgType=3, weaponSkill=13,
 mods={{11,5,"AGI+5"},{26,7,"RACC+7"},{24,12,"RATT+12"},
       {365,5,"Snapshot+5%"},{420,8,"Barrage Accuracy+8"}}},

{id=29908, name="ashbarrel_pistol", displayName="Ashbarrel Pistol",
 type=5, flags=0x0000, source="Boss FATE",
 slot=4, jobs=66560, level=22, model=466,
 dmg=28, delay=528, dmgType=3, weaponSkill=13,
 mods={{11,3,"AGI+3"},{26,5,"RACC+5"},{365,3,"Snapshot+3%"}}},

-- end Section 3

-- ============================================================
-- SECTION 4: PENDING ITEMS  (IDs 29820–29839)
-- Stats TBD — awaiting design approval before implementation.
-- Included here for reference; do NOT insert to SQL until approved.
-- ============================================================

-- WEAPONS (pending)
{id=29820, name="soulreaver_blade", displayName="Soulreaver Blade",
 type=5, flags=0x0C00, source="PENDING NM Drop",
 slot=3, jobs=0, level=40, model=0,
 dmg=0, delay=240, dmgType=2, weaponSkill=2,
 notes="Enspell-focused sword — RDM/BLU. NM lv40 C-diff. Stats PENDING.",
 mods={}},

{id=29821, name="dawnbringer_staff", displayName="Dawnbringer Staff",
 type=5, flags=0x0C00, source="PENDING NM Drop",
 slot=1, jobs=0, level=55, model=0,
 dmg=0, delay=366, dmgType=4, weaponSkill=11,
 notes="WHM healing staff with Cure Potency. NM lv55 C-diff. Stats PENDING.",
 mods={}},

{id=29822, name="bonebreaker", displayName="Bonebreaker",
 type=5, flags=0x0C00, source="PENDING NM Drop",
 slot=3, jobs=0, level=60, model=0,
 dmg=0, delay=96, dmgType=4, weaponSkill=0,
 notes="MNK H2H weapon with Smite. NM lv60 C-diff. Stats PENDING.",
 mods={}},

{id=29823, name="occultists_rod", displayName="Occultist's Rod",
 type=5, flags=0x0C00, source="PENDING NM Drop",
 slot=1, jobs=0, level=50, model=0,
 dmg=0, delay=366, dmgType=4, weaponSkill=11,
 notes="BLM magic burst staff. NM lv50 C-diff. Stats PENDING.",
 mods={}},

-- ARMOUR (pending)
{id=29824, name="phantoms_coif", displayName="Phantom's Coif",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=16, jobs=0, level=50, model=0, def=0,
 notes="NIN tool-save head. NM lv50 C-diff. Stats PENDING.",
 mods={}},

{id=29825, name="hexweave_tiara", displayName="Hexweave Tiara",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=16, jobs=0, level=60, model=0, def=0,
 notes="BLM Occult Acumen head. NM lv60 C-diff. Stats PENDING.",
 mods={}},

{id=29826, name="souleaters_cuirass", displayName="Souleater's Cuirass",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=32, jobs=0, level=55, model=0, def=0,
 notes="DRK Souleater body. NM lv55 C-diff. Stats PENDING.",
 mods={}},

{id=29827, name="wraithguard_cuirass", displayName="Wraithguard Cuirass",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=32, jobs=0, level=60, model=0, def=0,
 notes="PLD/RUN magic mitigation body. NM lv60 C-diff. Stats PENDING.",
 mods={}},

{id=29828, name="hexbinder_cuffs", displayName="Hexbinder Cuffs",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=64, jobs=0, level=45, model=0, def=0,
 notes="Spell interrupt resist hands. NM lv45 C-diff. Stats PENDING.",
 mods={}},

{id=29829, name="stormwarden_gages", displayName="Stormwarden Gages",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=64, jobs=0, level=55, model=0, def=0,
 notes="RNG Snapshot/Barrage hands. NM lv55 C-diff. Stats PENDING.",
 mods={}},

{id=29830, name="wardens_tassets", displayName="Warden's Tassets",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=128, jobs=0, level=40, model=0, def=0,
 notes="Shield block tank legs. NM lv40 B-diff. Stats PENDING.",
 mods={}},

{id=29831, name="resonance_hakama", displayName="Resonance Hakama",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=128, jobs=0, level=55, model=0, def=0,
 notes="SAM Store TP/Skillchain legs. NM lv55 C-diff. Stats PENDING.",
 mods={}},

{id=29832, name="counterfall_greaves", displayName="Counterfall Greaves",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=256, jobs=0, level=45, model=0, def=0,
 notes="MNK Counter/Kick feet. NM lv45 B-diff. Stats PENDING.",
 mods={}},

{id=29833, name="darksole_boots", displayName="Darksole Boots",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=256, jobs=0, level=60, model=0, def=0,
 notes="Regain feet for DRK/SAM. NM lv60 C-diff. Stats PENDING.",
 mods={}},

-- ACCESSORIES (pending)
{id=29834, name="trueshot_gorget", displayName="Trueshot Gorget",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=512, jobs=0, level=55, model=0, def=0,
 notes="RNG Barrage accuracy neck. NM lv55 C-diff. Stats PENDING.",
 mods={}},

{id=29835, name="arbiters_band", displayName="Arbiter's Band",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=24576, jobs=0, level=35, model=0, def=0,
 notes="RDM enfeeble ring. NM lv35 B-diff. Stats PENDING.",
 mods={}},

{id=29836, name="bloodfeast_earring", displayName="Bloodfeast Earring",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=6144, jobs=0, level=45, model=0, def=0,
 notes="DRK Drain/Aspir earring. NM lv45 B-diff. Stats PENDING.",
 mods={}},

{id=29837, name="bladedancers_sash", displayName="Bladedancer's Sash",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=1024, jobs=0, level=50, model=0, def=0,
 notes="SAM/NIN Store TP waist. NM lv50 C-diff. Stats PENDING.",
 mods={}},

{id=29838, name="vortex_cord", displayName="Vortex Cord",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=1024, jobs=0, level=55, model=0, def=0,
 notes="RNG Rapid Shot waist. NM lv55 C-diff. Stats PENDING.",
 mods={}},

{id=29839, name="tempest_mantle", displayName="Tempest Mantle",
 type=4, flags=0x0C00, source="PENDING NM Drop",
 slot=32768, jobs=0, level=65, model=503, def=0,
 notes="BRD Song Duration back. NM lv65 C-D diff. Stats PENDING.",
 mods={}},

-- end Section 4

} -- end customItems

return customItems

--[[
  DNC GEAR EDITS SUMMARY
  The following existing items need extra rows added to item_mods.sql for DNC support.
  Already included in the mod arrays above — listed here for cross-reference:

    29710 Shadowweave Tunic    → ADD (14, 2)   CHR+2 for DNC Waltz Potency
    29748 Shadowstep Hakama   → ADD (14, 3)   CHR+3 for DNC Waltz Potency
                               → ADD (491, 3)  Waltz Potency+3%
    29795 Tempered Coat       → ADD (491, 3)  Waltz Potency+3% for DNC
    29803 Muddled Breeches    → ADD (14, 2)   CHR+2 for DNC Waltz Potency
    29849 Shadowstrike Ring   → Already includes (491, 2) in base design

  UNCONFIRMED MOD IDs — resolve before generating SQL:
    "FASTCAST"        on 29706 / 29742 / 29797
    "MOVE_SPEED"      on 29715 / 29753 / 29805
    "PHALANX_BONUS"   on 29709
    "WIND_ELE_ACC"    on 29711
    "DIVINE_SKILL"    on 29708 / 29738
    "MAG_DMG_TAKEN"   on 29841  (value = -8, negative modifier)
    "REFRESH_MOD"     on 29843
    "SINGING_SKILL"   on 29848
    "SHIELD_SKILL"    on 29744

  FIRE_ELE_ACC (mod 40)  — used in B4 CSV for 29872 and implied for 29741.
  Verify mod 40 is correct against mods_by_id.txt.

  DEF_BONUS (mod 31)  — used for 29756 Ironhide Choker Defence+5.
  Verify mod 31 is the correct DEF bonus mod.

  BOSS FATE SYSTEM NOTE
  Boss FATE drop system not yet implemented. Items 29854–29908 (FATE-sourced)
  are designed and wired but need the FATE encounter scripting before they
  enter the loot pool. Coordinate with LQS local branch.
--]]
