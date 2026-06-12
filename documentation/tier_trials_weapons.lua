-- =============================================================================
-- TIER TRIALS WEAPONS REFERENCE
-- =============================================================================
-- 44 items total: 4 shards (crafting materials) + 40 weapons (10 families × 4 tiers)
--
-- Tier naming:  Nascent (Lv28) → Tempered (Lv38) → Forged (Lv48) → Resolute (Lv58)
-- All weapons:  RARE / EX   (flags = 0x0C00)
-- Item ID range: 29840–29883
-- =============================================================================
--
-- WEAPON SKILL CODES:  H2H=0, Dagger=1, Sword=2, GreatSword=3, Axe=4,
--                      Scythe=6, GreatKatana=9, Club=10, Staff=11
-- DAMAGE TYPES:        Slashing=2, Piercing=3, Blunt=4
-- SLOT BITMASKS:       MAIN=1, SUB=2
--
-- JOB BITMASKS:
--   WAR=1      MNK=2      WHM=4      BLM=8      RDM=16     THF=32
--   PLD=64     DRK=128    BST=256    BRD=512    RNG=1024   SAM=2048
--   NIN=4096   DRG=8192   SMN=16384  BLU=32768  COR=65536  PUP=131072
--   DNC=262144 SCH=524288 GEO=1048576 RUN=2097152
--
-- CONFIRMED MOD IDS:
--   HP=2, MP=5, STR=8, DEX=9, VIT=10, AGI=11, INT=12, MND=13, CHR=14,
--   ATT=23, ACC=25, ENMITY=27, MACC=30, EVA=68, STORETP=73,
--   GSWORD_SKILL=83, GKATANA_SKILL=89, CLUB_SKILL=90, STAFF_SKILL=91,
--   DOUBLE_ATTACK=288, TRIPLE_ATTACK=302, COUNTER=291, SUBTLE_BLOW=289,
--   DUAL_WIELD=259, ZANSHIN=306, ENFEEBLE_SKILL=114, CONSERVE_MP=296,
--   WALTZ_POTENCY=491, SHIELDBLOCKRATE=518
--
-- UNCONFIRMED MOD IDS (string keys, resolve before implementation):
--   FASTCAST, GEOMANCY_SKILL, SHIELD_SKILL, BLU_SKILL, MAG_DEF_BONUS
-- =============================================================================

local TierTrialsItems = {

    -- =========================================================================
    -- SHARDS  (crafting materials — type 1, not equippable)
    -- =========================================================================

    {
        id          = 29840,
        name        = "Nascent Shard",
        displayName = "Nascent Shard",
        type        = 1,
        flags       = 0x0000,
        source      = "Tier Trials T1 crafting material",
    },
    {
        id          = 29841,
        name        = "Tempered Shard",
        displayName = "Tempered Shard",
        type        = 1,
        flags       = 0x0000,
        source      = "Tier Trials T2 crafting material",
    },
    {
        id          = 29842,
        name        = "Forged Shard",
        displayName = "Forged Shard",
        type        = 1,
        flags       = 0x0000,
        source      = "Tier Trials T3 crafting material",
    },
    {
        id          = 29843,
        name        = "Resolute Shard",
        displayName = "Resolute Shard",
        type        = 1,
        flags       = 0x0000,
        source      = "Tier Trials T4 crafting material",
    },

    -- =========================================================================
    -- GREATSWORD FAMILY  —  WAR / DRK / DRG / RUN
    -- Defining secondary: Store TP (scales T3+)
    -- Skill: Great Sword (3) | Type: Slashing (2) | Delay: 450
    -- Jobs bitmask: 1+128+8192+2097152 = 2105473
    -- =========================================================================

    {
        id          = 29844,
        name        = "Nascent Greatsword",
        displayName = "Nascent Greatsword",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 2105473,
        level       = 28,
        model       = 0,
        dmg         = 52,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 3,
        mods = {
            { 8,  3, "STR+3" },
            { 23, 5, "Attack+5" },
        },
    },
    {
        id          = 29845,
        name        = "Tempered Greatsword",
        displayName = "Tempered Greatsword",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 2105473,
        level       = 38,
        model       = 0,
        dmg         = 68,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 3,
        mods = {
            { 8,  4, "STR+4" },
            { 23, 8, "Attack+8" },
        },
    },
    {
        id          = 29846,
        name        = "Forged Greatsword",
        displayName = "Forged Greatsword",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 2105473,
        level       = 48,
        model       = 0,
        dmg         = 85,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 3,
        mods = {
            { 8,  5,  "STR+5" },
            { 23, 10, "Attack+10" },
            { 73, 3,  "Store TP+3" },
        },
    },
    {
        id          = 29847,
        name        = "Resolute Greatsword",
        displayName = "Resolute Greatsword",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 2105473,
        level       = 58,
        model       = 0,
        dmg         = 103,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 3,
        mods = {
            { 8,  7,  "STR+7" },
            { 23, 14, "Attack+14" },
            { 73, 5,  "Store TP+5" },
        },
    },

    -- =========================================================================
    -- BLADE FAMILY  —  RDM / BRD / COR
    -- Defining secondary: Fast Cast
    -- Skill: Sword (2) | Type: Slashing (2) | Delay: 240
    -- Jobs bitmask: 16+512+65536 = 66064
    -- NOTE: FASTCAST mod ID unconfirmed
    -- =========================================================================

    {
        id          = 29848,
        name        = "Nascent Blade",
        displayName = "Nascent Blade",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 66064,
        level       = 28,
        model       = 0,
        dmg         = 34,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,          2, "INT+2" },
            { "FASTCAST",  3, "Fast Cast+3%" },
        },
    },
    {
        id          = 29849,
        name        = "Tempered Blade",
        displayName = "Tempered Blade",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 66064,
        level       = 38,
        model       = 0,
        dmg         = 44,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,         3, "INT+3" },
            { "FASTCAST", 5, "Fast Cast+5%" },
        },
    },
    {
        id          = 29850,
        name        = "Forged Blade",
        displayName = "Forged Blade",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 66064,
        level       = 48,
        model       = 0,
        dmg         = 54,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,         4, "INT+4" },
            { 13,         2, "MND+2" },
            { "FASTCAST", 7, "Fast Cast+7%" },
        },
    },
    {
        id          = 29851,
        name        = "Resolute Blade",
        displayName = "Resolute Blade",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 66064,
        level       = 58,
        model       = 0,
        dmg         = 65,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,          5,  "INT+5" },
            { 13,          3,  "MND+3" },
            { "FASTCAST",  10, "Fast Cast+10%" },
        },
    },

    -- =========================================================================
    -- NODACHI FAMILY  —  SAM / NIN
    -- Defining secondary: Store TP (T1/T2), Zanshin (T3/T4)
    -- Skill: Great Katana (9) | Type: Slashing (2) | Delay: 450
    -- Jobs bitmask: 2048+4096 = 6144
    -- =========================================================================

    {
        id          = 29852,
        name        = "Nascent Nodachi",
        displayName = "Nascent Nodachi",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 6144,
        level       = 28,
        model       = 0,
        dmg         = 50,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 9,
        mods = {
            { 8,  3, "STR+3" },
            { 73, 2, "Store TP+2" },
        },
    },
    {
        id          = 29853,
        name        = "Tempered Nodachi",
        displayName = "Tempered Nodachi",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 6144,
        level       = 38,
        model       = 0,
        dmg         = 65,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 9,
        mods = {
            { 8,  4, "STR+4" },
            { 73, 3, "Store TP+3" },
        },
    },
    {
        id          = 29854,
        name        = "Forged Nodachi",
        displayName = "Forged Nodachi",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 6144,
        level       = 48,
        model       = 0,
        dmg         = 82,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 9,
        mods = {
            { 8,   5, "STR+5" },
            { 73,  5, "Store TP+5" },
            { 306, 5, "Zanshin+5%" },
        },
    },
    {
        id          = 29855,
        name        = "Resolute Nodachi",
        displayName = "Resolute Nodachi",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 6144,
        level       = 58,
        model       = 0,
        dmg         = 100,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 9,
        mods = {
            { 8,   6, "STR+6" },
            { 73,  7, "Store TP+7" },
            { 306, 8, "Zanshin+8%" },
        },
    },

    -- =========================================================================
    -- KUKRI FAMILY  —  THF / NIN / RNG / DNC
    -- Defining secondary: Dual Wield (all tiers), Waltz Potency (T3/T4)
    -- Skill: Dagger (1) | Type: Slashing (2) | Delay: 200
    -- Jobs bitmask: 32+4096+1024+262144 = 267296
    -- =========================================================================

    {
        id          = 29856,
        name        = "Nascent Kukri",
        displayName = "Nascent Kukri",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 267296,
        level       = 28,
        model       = 0,
        dmg         = 24,
        delay       = 200,
        dmgType     = 2,
        weaponSkill = 1,
        mods = {
            { 9,   2, "DEX+2" },
            { 259, 2, "Dual Wield+2" },
        },
    },
    {
        id          = 29857,
        name        = "Tempered Kukri",
        displayName = "Tempered Kukri",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 267296,
        level       = 38,
        model       = 0,
        dmg         = 31,
        delay       = 200,
        dmgType     = 2,
        weaponSkill = 1,
        mods = {
            { 9,   3, "DEX+3" },
            { 259, 3, "Dual Wield+3" },
        },
    },
    {
        id          = 29858,
        name        = "Forged Kukri",
        displayName = "Forged Kukri",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 267296,
        level       = 48,
        model       = 0,
        dmg         = 39,
        delay       = 200,
        dmgType     = 2,
        weaponSkill = 1,
        mods = {
            { 9,   4, "DEX+4" },
            { 259, 4, "Dual Wield+4" },
            { 491, 5, "Waltz Potency+5%" },
        },
    },
    {
        id          = 29859,
        name        = "Resolute Kukri",
        displayName = "Resolute Kukri",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 267296,
        level       = 58,
        model       = 0,
        dmg         = 47,
        delay       = 200,
        dmgType     = 2,
        weaponSkill = 1,
        mods = {
            { 9,   5, "DEX+5" },
            { 259, 5, "Dual Wield+5" },
            { 491, 8, "Waltz Potency+8%" },
        },
    },

    -- =========================================================================
    -- CESTI FAMILY  —  MNK / BST / PUP
    -- Defining secondary: Triple Attack, Counter (T3/T4)
    -- Skill: H2H (0) | Type: Blunt (4) | Delay: 480
    -- Jobs bitmask: 2+256+131072 = 131330
    -- =========================================================================

    {
        id          = 29860,
        name        = "Nascent Cesti",
        displayName = "Nascent Cesti",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 131330,
        level       = 28,
        model       = 0,
        dmg         = 12,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 0,
        mods = {
            { 8,   2, "STR+2" },
            { 302, 1, "Triple Attack+1%" },
        },
    },
    {
        id          = 29861,
        name        = "Tempered Cesti",
        displayName = "Tempered Cesti",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 131330,
        level       = 38,
        model       = 0,
        dmg         = 17,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 0,
        mods = {
            { 8,   3, "STR+3" },
            { 302, 2, "Triple Attack+2%" },
        },
    },
    {
        id          = 29862,
        name        = "Forged Cesti",
        displayName = "Forged Cesti",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 131330,
        level       = 48,
        model       = 0,
        dmg         = 22,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 0,
        mods = {
            { 8,   4, "STR+4" },
            { 23,  8, "Attack+8" },
            { 302, 2, "Triple Attack+2%" },
            { 291, 3, "Counter+3%" },
        },
    },
    {
        id          = 29863,
        name        = "Resolute Cesti",
        displayName = "Resolute Cesti",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 131330,
        level       = 58,
        model       = 0,
        dmg         = 28,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 0,
        mods = {
            { 8,   5,  "STR+5" },
            { 23,  12, "Attack+12" },
            { 302, 3,  "Triple Attack+3%" },
            { 291, 5,  "Counter+5%" },
        },
    },

    -- =========================================================================
    -- ROD FAMILY  —  WHM / BLM / SMN / SCH
    -- Defining secondary: MP pool, Conserve MP (T3/T4)
    -- Skill: Staff (11) | Type: Blunt (4) | Delay: 480
    -- Jobs bitmask: 4+8+16384+524288 = 540684
    -- =========================================================================

    {
        id          = 29864,
        name        = "Nascent Rod",
        displayName = "Nascent Rod",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 540684,
        level       = 28,
        model       = 0,
        dmg         = 40,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 11,
        mods = {
            { 12, 2,  "INT+2" },
            { 13, 2,  "MND+2" },
            { 5,  20, "MP+20" },
        },
    },
    {
        id          = 29865,
        name        = "Tempered Rod",
        displayName = "Tempered Rod",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 540684,
        level       = 38,
        model       = 0,
        dmg         = 52,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 11,
        mods = {
            { 12, 3,  "INT+3" },
            { 13, 3,  "MND+3" },
            { 5,  35, "MP+35" },
        },
    },
    {
        id          = 29866,
        name        = "Forged Rod",
        displayName = "Forged Rod",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 540684,
        level       = 48,
        model       = 0,
        dmg         = 65,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 11,
        mods = {
            { 12,  4,  "INT+4" },
            { 13,  4,  "MND+4" },
            { 5,   50, "MP+50" },
            { 296, 3,  "Conserve MP+3" },
        },
    },
    {
        id          = 29867,
        name        = "Resolute Rod",
        displayName = "Resolute Rod",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 540684,
        level       = 58,
        model       = 0,
        dmg         = 78,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 11,
        mods = {
            { 12,  5,  "INT+5" },
            { 13,  5,  "MND+5" },
            { 5,   65, "MP+65" },
            { 296, 5,  "Conserve MP+5" },
        },
    },

    -- =========================================================================
    -- FALCHION FAMILY  —  BLU
    -- Defining secondary: Blue Magic Skill
    -- Skill: Sword (2) | Type: Slashing (2) | Delay: 240
    -- Jobs bitmask: 32768
    -- NOTE: BLU_SKILL mod ID unconfirmed
    -- =========================================================================

    {
        id          = 29868,
        name        = "Nascent Falchion",
        displayName = "Nascent Falchion",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 32768,
        level       = 28,
        model       = 0,
        dmg         = 34,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,          2, "INT+2" },
            { "BLU_SKILL", 3, "Blue Magic Skill+3" },
        },
    },
    {
        id          = 29869,
        name        = "Tempered Falchion",
        displayName = "Tempered Falchion",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 32768,
        level       = 38,
        model       = 0,
        dmg         = 44,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,          3, "INT+3" },
            { "BLU_SKILL", 5, "Blue Magic Skill+5" },
        },
    },
    {
        id          = 29870,
        name        = "Forged Falchion",
        displayName = "Forged Falchion",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 32768,
        level       = 48,
        model       = 0,
        dmg         = 54,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 8,           3, "STR+3" },
            { 12,          4, "INT+4" },
            { "BLU_SKILL", 6, "Blue Magic Skill+6" },
        },
    },
    {
        id          = 29871,
        name        = "Resolute Falchion",
        displayName = "Resolute Falchion",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 32768,
        level       = 58,
        model       = 0,
        dmg         = 65,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 8,           4, "STR+4" },
            { 12,          5, "INT+5" },
            { "BLU_SKILL", 8, "Blue Magic Skill+8" },
        },
    },

    -- =========================================================================
    -- SCEPTRE FAMILY  —  GEO
    -- Defining secondary: Geomancy Skill
    -- Skill: Club (10) | Type: Blunt (4) | Delay: 280
    -- Jobs bitmask: 1048576
    -- NOTE: GEOMANCY_SKILL mod ID unconfirmed
    -- =========================================================================

    {
        id          = 29872,
        name        = "Nascent Sceptre",
        displayName = "Nascent Sceptre",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 1048576,
        level       = 28,
        model       = 0,
        dmg         = 28,
        delay       = 280,
        dmgType     = 4,
        weaponSkill = 10,
        mods = {
            { 12,                2, "INT+2" },
            { 13,                2, "MND+2" },
            { "GEOMANCY_SKILL",  3, "Geomancy Skill+3" },
        },
    },
    {
        id          = 29873,
        name        = "Tempered Sceptre",
        displayName = "Tempered Sceptre",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 1048576,
        level       = 38,
        model       = 0,
        dmg         = 36,
        delay       = 280,
        dmgType     = 4,
        weaponSkill = 10,
        mods = {
            { 12,               3, "INT+3" },
            { 13,               3, "MND+3" },
            { "GEOMANCY_SKILL", 5, "Geomancy Skill+5" },
        },
    },
    {
        id          = 29874,
        name        = "Forged Sceptre",
        displayName = "Forged Sceptre",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 1048576,
        level       = 48,
        model       = 0,
        dmg         = 46,
        delay       = 280,
        dmgType     = 4,
        weaponSkill = 10,
        mods = {
            { 12,               4, "INT+4" },
            { 13,               4, "MND+4" },
            { "GEOMANCY_SKILL", 7, "Geomancy Skill+7" },
        },
    },
    {
        id          = 29875,
        name        = "Resolute Sceptre",
        displayName = "Resolute Sceptre",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 1048576,
        level       = 58,
        model       = 0,
        dmg         = 56,
        delay       = 280,
        dmgType     = 4,
        weaponSkill = 10,
        mods = {
            { 12,               5, "INT+5" },
            { 13,               5, "MND+5" },
            { "GEOMANCY_SKILL", 9, "Geomancy Skill+9" },
        },
    },

    -- =========================================================================
    -- SPATHA FAMILY  —  PLD / RDM
    -- Defining secondary: Enfeebling Magic Skill, Magic Def. Bonus (T3/T4)
    -- Skill: Sword (2) | Type: Slashing (2) | Delay: 240
    -- Jobs bitmask: 64+16 = 80
    -- NOTE: MAG_DEF_BONUS mod ID unconfirmed
    -- =========================================================================

    {
        id          = 29876,
        name        = "Nascent Spatha",
        displayName = "Nascent Spatha",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 80,
        level       = 28,
        model       = 0,
        dmg         = 34,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,  2, "INT+2" },
            { 114, 3, "Enfeebling Magic Skill+3" },
        },
    },
    {
        id          = 29877,
        name        = "Tempered Spatha",
        displayName = "Tempered Spatha",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 80,
        level       = 38,
        model       = 0,
        dmg         = 44,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,  3, "INT+3" },
            { 114, 5, "Enfeebling Magic Skill+5" },
        },
    },
    {
        id          = 29878,
        name        = "Forged Spatha",
        displayName = "Forged Spatha",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 80,
        level       = 48,
        model       = 0,
        dmg         = 54,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,              4, "INT+4" },
            { 114,             6, "Enfeebling Magic Skill+6" },
            { "MAG_DEF_BONUS", 3, "Magic Def. Bonus+3" },
        },
    },
    {
        id          = 29879,
        name        = "Resolute Spatha",
        displayName = "Resolute Spatha",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 80,
        level       = 58,
        model       = 0,
        dmg         = 65,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,              5, "INT+5" },
            { 114,             8, "Enfeebling Magic Skill+8" },
            { "MAG_DEF_BONUS", 5, "Magic Def. Bonus+5" },
        },
    },

    -- =========================================================================
    -- KITE FAMILY  —  PLD  (shield — SUB slot, type 4 ARMOR)
    -- Defining secondary: Shield Skill, Enmity
    -- Jobs bitmask: 64
    -- NOTE: SHIELD_SKILL mod ID unconfirmed
    -- =========================================================================

    {
        id          = 29880,
        name        = "Nascent Kite",
        displayName = "Nascent Kite",
        type        = 4,        -- ARMOR
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 2,        -- SUB
        jobs        = 64,
        level       = 28,
        model       = 0,
        def         = 5,
        mods = {
            { "SHIELD_SKILL", 3, "Shield Skill+3" },
            { 27,             2, "Enmity+2" },
        },
    },
    {
        id          = 29881,
        name        = "Tempered Kite",
        displayName = "Tempered Kite",
        type        = 4,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 2,
        jobs        = 64,
        level       = 38,
        model       = 0,
        def         = 8,
        mods = {
            { "SHIELD_SKILL", 5, "Shield Skill+5" },
            { 27,             3, "Enmity+3" },
        },
    },
    {
        id          = 29882,
        name        = "Forged Kite",
        displayName = "Forged Kite",
        type        = 4,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 2,
        jobs        = 64,
        level       = 48,
        model       = 0,
        def         = 11,
        mods = {
            { "SHIELD_SKILL", 7, "Shield Skill+7" },
            { 27,             5, "Enmity+5" },
        },
    },
    {
        id          = 29883,
        name        = "Resolute Kite",
        displayName = "Resolute Kite",
        type        = 4,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 2,
        jobs        = 64,
        level       = 58,
        model       = 0,
        def         = 14,
        mods = {
            { "SHIELD_SKILL", 9, "Shield Skill+9" },
            { 27,             7, "Enmity+7" },
        },
    },

    -- =========================================================================
    -- KATANA FAMILY  —  NIN
    -- Defining: Subtle Blow (T2), Ninjutsu Skill (T3), Daken (T4+)
    -- Skill: Katana (8) | Type: Slashing (2) | Delay: 240
    -- Jobs bitmask: 4096
    -- NOTE: DAKEN mod ID unconfirmed
    -- =========================================================================

    {
        id          = 29894,
        name        = "Nascent Katana",
        displayName = "Nascent Katana",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T1",
        slot        = 1,
        jobs        = 4096,
        level       = 28,
        model       = 0,
        dmg         = 26,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 8,
        mods = {
            { 11, 2, "AGI+2" },
        },
    },
    {
        id          = 29895,
        name        = "Tempered Katana",
        displayName = "Tempered Katana",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T2",
        slot        = 1,
        jobs        = 4096,
        level       = 38,
        model       = 0,
        dmg         = 33,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 8,
        mods = {
            { 11,  3, "AGI+3" },
            { 289, 3, "Subtle Blow+3" },
        },
    },
    {
        id          = 29896,
        name        = "Forged Katana",
        displayName = "Forged Katana",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T3",
        slot        = 1,
        jobs        = 4096,
        level       = 48,
        model       = 0,
        dmg         = 41,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 8,
        mods = {
            { 11,  4, "AGI+4" },
            { 289, 5, "Subtle Blow+5" },
            { 118, 5, "Ninjutsu Skill+5" },
        },
    },
    {
        id          = 29897,
        name        = "Resolute Katana",
        displayName = "Resolute Katana",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials T4",
        slot        = 1,
        jobs        = 4096,
        level       = 58,
        model       = 0,
        dmg         = 50,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 8,
        mods = {
            { 11,      5, "AGI+5" },
            { 289,     7, "Subtle Blow+7" },
            { 118,     8, "Ninjutsu Skill+8" },
            { "DAKEN", 3, "Daken+3%" },
        },
    },

    -- =========================================================================
    -- LV75 CAPSTONE WEAPONS  —  one per family, named under Latin Essences theme
    -- All: RARE/EX, Lv75
    -- =========================================================================

    -- Virtus — Greatsword capstone  (WAR/DRK/DRG/RUN)
    -- "valor, martial excellence"
    {
        id          = 29884,
        name        = "Virtus",
        displayName = "Virtus",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 2105473,
        level       = 75,
        model       = 0,
        dmg         = 118,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 3,
        mods = {
            { 8,  9,  "STR+9" },
            { 23, 18, "Attack+18" },
            { 73, 7,  "Store TP+7" },
            { 83, 5,  "Great Sword Skill+5" },
        },
    },

    -- Vox — Blade capstone  (RDM/BRD/COR)
    -- "voice, resonance"
    {
        id          = 29885,
        name        = "Vox",
        displayName = "Vox",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 66064,
        level       = 75,
        model       = 0,
        dmg         = 78,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,         7,  "INT+7" },
            { 13,         5,  "MND+5" },
            { "FASTCAST", 12, "Fast Cast+12%" },
        },
    },

    -- Umbra — Nodachi capstone  (SAM/NIN)
    -- "shadow"
    {
        id          = 29886,
        name        = "Umbra",
        displayName = "Umbra",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 6144,
        level       = 75,
        model       = 0,
        dmg         = 115,
        delay       = 450,
        dmgType     = 2,
        weaponSkill = 9,
        mods = {
            { 8,   8,  "STR+8" },
            { 73,  9,  "Store TP+9" },
            { 306, 10, "Zanshin+10%" },
        },
    },

    -- Fuga — Kukri capstone  (THF/NIN/RNG/DNC)
    -- "flight, swiftness"
    {
        id          = 29887,
        name        = "Fuga",
        displayName = "Fuga",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 267296,
        level       = 75,
        model       = 0,
        dmg         = 52,
        delay       = 200,
        dmgType     = 2,
        weaponSkill = 1,
        mods = {
            { 9,   7,  "DEX+7" },
            { 259, 6,  "Dual Wield+6" },
            { 491, 10, "Waltz Potency+10%" },
        },
    },

    -- Vis — Cesti capstone  (MNK/BST/PUP)
    -- "raw force"
    {
        id          = 29888,
        name        = "Vis",
        displayName = "Vis",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 131330,
        level       = 75,
        model       = 0,
        dmg         = 33,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 0,
        mods = {
            { 8,   7,  "STR+7" },
            { 23,  16, "Attack+16" },
            { 302, 4,  "Triple Attack+4%" },
            { 291, 6,  "Counter+6%" },
        },
    },

    -- Lux — Rod capstone  (WHM/BLM/SMN/SCH)
    -- "light"
    {
        id          = 29889,
        name        = "Lux",
        displayName = "Lux",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 540684,
        level       = 75,
        model       = 0,
        dmg         = 90,
        delay       = 480,
        dmgType     = 4,
        weaponSkill = 11,
        mods = {
            { 12,  7,  "INT+7" },
            { 13,  7,  "MND+7" },
            { 5,   80, "MP+80" },
            { 296, 7,  "Conserve MP+7" },
        },
    },

    -- Arcana — Falchion capstone  (BLU)
    -- "hidden mysteries"
    {
        id          = 29890,
        name        = "Arcana",
        displayName = "Arcana",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 32768,
        level       = 75,
        model       = 0,
        dmg         = 78,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 8,           6,  "STR+6" },
            { 12,          7,  "INT+7" },
            { "BLU_SKILL", 10, "Blue Magic Skill+10" },
        },
    },

    -- Tellus — Sceptre capstone  (GEO)
    -- "the earth"
    {
        id          = 29891,
        name        = "Tellus",
        displayName = "Tellus",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 1048576,
        level       = 75,
        model       = 0,
        dmg         = 65,
        delay       = 280,
        dmgType     = 4,
        weaponSkill = 10,
        mods = {
            { 12,               7,  "INT+7" },
            { 13,               7,  "MND+7" },
            { "GEOMANCY_SKILL", 12, "Geomancy Skill+12" },
        },
    },

    -- Lex — Spatha capstone  (PLD/RDM)
    -- "law, order"
    {
        id          = 29892,
        name        = "Lex",
        displayName = "Lex",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 80,
        level       = 75,
        model       = 0,
        dmg         = 78,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 2,
        mods = {
            { 12,              7, "INT+7" },
            { 114,             10, "Enfeebling Magic Skill+10" },
            { "MAG_DEF_BONUS", 7, "Magic Def. Bonus+7" },
        },
    },

    -- Tutela — Kite capstone  (PLD)  — shield, type 4 ARMOR, SUB slot
    -- "protection, guardianship"
    {
        id          = 29893,
        name        = "Tutela",
        displayName = "Tutela",
        type        = 4,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 2,
        jobs        = 64,
        level       = 75,
        model       = 0,
        def         = 20,
        mods = {
            { "SHIELD_SKILL", 12, "Shield Skill+12" },
            { 27,             9,  "Enmity+9" },
        },
    },

    -- Caligo — Katana capstone  (NIN)
    -- "mist, obscurity"
    {
        id          = 29898,
        name        = "Caligo",
        displayName = "Caligo",
        type        = 5,
        flags       = 0x0C00,
        source      = "Tier Trials Lv75 capstone",
        slot        = 1,
        jobs        = 4096,
        level       = 75,
        model       = 0,
        dmg         = 58,
        delay       = 240,
        dmgType     = 2,
        weaponSkill = 8,
        mods = {
            { 11,      9,  "AGI+9" },
            { 289,     10, "Subtle Blow+10" },
            { 118,     12, "Ninjutsu Skill+12" },
            { "DAKEN", 5,  "Daken+5%" },
        },
    },
}

-- =============================================================================
-- FAMILY SUMMARY
-- =============================================================================
--[[
  ID Range   Family        Slot  Jobs                 Skill         Defining
  ---------  ----------    ----  -------------------  ------------  -------------------------
  29840-43   Shards        —     —                    —             Crafting materials (T1–T4)
  29844-47   Greatsword    MAIN  WAR/DRK/DRG/RUN      Great Sword   STR/ATT, Store TP
  29848-51   Blade         MAIN  RDM/BRD/COR          Sword         INT, Fast Cast
  29852-55   Nodachi       MAIN  SAM/NIN              Great Katana  STR, Store TP, Zanshin
  29856-59   Kukri         MAIN  THF/NIN/RNG/DNC      Dagger        DEX, Dual Wield, Waltz Pot.
  29860-63   Cesti         MAIN  MNK/BST/PUP          H2H           STR/ATT, Triple Atk, Counter
  29864-67   Rod           MAIN  WHM/BLM/SMN/SCH      Staff         INT/MND, MP, Conserve MP
  29868-71   Falchion      MAIN  BLU                  Sword         INT/STR, Blue Magic Skill
  29872-75   Sceptre       MAIN  GEO                  Club          INT/MND, Geomancy Skill
  29876-79   Spatha        MAIN  PLD/RDM              Sword         INT, Enfeebling Skill, MagDef
  29880-83   Kite          SUB   PLD                  Shield        DEF, Shield Skill, Enmity
  29884      Virtus        MAIN  WAR/DRK/DRG/RUN      Great Sword   Lv75 capstone — Greatsword
  29885      Vox           MAIN  RDM/BRD/COR          Sword         Lv75 capstone — Blade
  29886      Umbra         MAIN  SAM/NIN              Great Katana  Lv75 capstone — Nodachi
  29887      Fuga          MAIN  THF/NIN/RNG/DNC      Dagger        Lv75 capstone — Kukri
  29888      Vis           MAIN  MNK/BST/PUP          H2H           Lv75 capstone — Cesti
  29889      Lux           MAIN  WHM/BLM/SMN/SCH      Staff         Lv75 capstone — Rod
  29890      Arcana        MAIN  BLU                  Sword         Lv75 capstone — Falchion
  29891      Tellus        MAIN  GEO                  Club          Lv75 capstone — Sceptre
  29892      Lex           MAIN  PLD/RDM              Sword         Lv75 capstone — Spatha
  29893      Tutela        SUB   PLD                  Shield        Lv75 capstone — Kite
  29894-97   Katana        MAIN  NIN                  Katana        AGI, Subtle Blow, Ninjutsu, Daken
  29898      Caligo        MAIN  NIN                  Katana        Lv75 capstone — Katana
]]

-- =============================================================================
-- UNCONFIRMED MOD IDS — resolve before SQL insertion
-- =============================================================================
--[[
  FASTCAST        — Fast Cast %          (Blade T1–T4, Vox)
  BLU_SKILL       — Blue Magic Skill     (Falchion T1–T4, Arcana)
  GEOMANCY_SKILL  — Geomancy Skill       (Sceptre T1–T4, Tellus)
  SHIELD_SKILL    — Shield Skill         (Kite T1–T4, Tutela)
  MAG_DEF_BONUS   — Magic Def. Bonus     (Spatha T3–T4, Lex)
  DAKEN           — Daken proc rate %    (Resolute Katana, Caligo)
]]

return TierTrialsItems
