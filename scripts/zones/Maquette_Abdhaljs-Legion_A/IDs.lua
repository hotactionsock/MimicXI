-----------------------------------
-- Area: Maquette_Abdhaljs-Legion_A
-----------------------------------
zones = zones or {}

zones[xi.zone.MAQUETTE_ABDHALJS_LEGION_A] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6387, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6395, -- Obtained: <item>.
        GIL_OBTAINED                  = 6396, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6398, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS           = 7006, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7007, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7008, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7028, -- Your party is unable to participate because certain members' levels are restricted.
        TIME_REMAINING_MINUTES        = 7428, -- Time remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS        = 7429, -- Time remaining: <number> [second/seconds] (Earth time).
        PARTY_FALLEN                  = 7431, -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].
    },
    mob =
    {
        -- -------------------------------------------------------
        -- Tier Trial 30: The Valkurm Proving (instance 18301)
        -- -------------------------------------------------------
        TT30 =
        {
            -- Wave 1
            GOBLIN_LEECHER_W1A  = 17526785,
            GOBLIN_LEECHER_W1B  = 17526786,
            GOBLIN_BOUNCER_W1   = 17526787,
            -- Wave 2
            ORCISH_GRUNT_W2A    = 17526788,
            ORCISH_GRUNT_W2B    = 17526789,
            ORCISH_CURSEMAKER   = 17526790,
            -- Wave 3
            BRASS_QUADAV_W3A    = 17526791,
            BRASS_QUADAV_W3B    = 17526792,
            COPPER_QUADAV       = 17526793,
            -- Wave 4
            GOBLIN_LEECHER_W4A  = 17526794,
            GOBLIN_LEECHER_W4B  = 17526795,
            ORCISH_GRUNT_W4A    = 17526796,
            ORCISH_GRUNT_W4B    = 17526797,
            -- Wave 5
            BRAKK_THE_LOCKJAW   = 17526798,
        },

        -- -------------------------------------------------------
        -- Tier Trial 40: The Qufim Crucible (instance 18302)
        -- -------------------------------------------------------
        TT40 =
        {
            -- Wave 1
            GIGAS_FIGHTER_W1    = 17526799,
            GIGAS_WRESTLER_W1   = 17526800,
            -- Wave 2
            GHOUL_W2A           = 17526801,
            GHOUL_W2B           = 17526802,
            WIGHT_W2            = 17526803,
            -- Wave 3
            TONBERRY_TRACKER    = 17526804,
            TONBERRY_ELDER      = 17526805,
            -- Wave 4
            ROC_W4              = 17526806,
            GIGAS_FIGHTER_W4    = 17526807,
            GIGAS_WRESTLER_W4   = 17526808,
            -- Wave 5
            KALABAROS           = 17526809,
            KALABAROS_SUMMON    = 17526810,
        },

        -- -------------------------------------------------------
        -- Tier Trial 50: The Fauregandi Trial (instance 18303)
        -- -------------------------------------------------------
        TT50 =
        {
            -- Wave 1
            IMP_W1A             = 17526811,
            IMP_W1B             = 17526812,
            IMP_W1C             = 17526813,
            -- Wave 2
            SHADOW_ORC_W2A      = 17526814,
            SHADOW_ORC_W2B      = 17526815,
            UNDEAD_QUADAV       = 17526816,
            -- Wave 3
            FIRE_ELEMENTAL      = 17526817,
            ICE_ELEMENTAL       = 17526818,
            -- Wave 4
            HAUNT_W4A           = 17526819,
            HAUNT_W4B           = 17526820,
            IMP_W4A             = 17526821,
            IMP_W4B             = 17526822,
            -- Wave 5
            VALDRIS             = 17526823,
        },

        -- -------------------------------------------------------
        -- Tier Trial 60: The Pso'Xja Ordeal (instance 18304)
        -- -------------------------------------------------------
        TT60 =
        {
            -- Wave 1
            AHRIMAN_W1A         = 17526824,
            AHRIMAN_W1B         = 17526825,
            -- Wave 2
            HAUNT_W2A           = 17526826,
            HAUNT_W2B           = 17526827,
            SPECTER_W2          = 17526828,
            -- Wave 3
            DEMON_KNIGHT_W3A    = 17526829,
            DEMON_KNIGHT_W3B    = 17526830,
            DEMON_WARLOCK_W3    = 17526831,
            -- Wave 4
            AHRIMAN_W4A         = 17526832,
            AHRIMAN_W4B         = 17526833,
            DEMON_KNIGHT_W4A    = 17526834,
            DEMON_KNIGHT_W4B    = 17526835,
            -- Wave 5
            VRAETH              = 17526836,
        },
        -- -------------------------------------------------------
        -- Circuit Lv30 mobs (circuits 18310/18311/18312)
        -- Ordered list — Alpha uses [1..8], Beta [1..12], Gamma all 13
        -- -------------------------------------------------------
        C30 =
        {
            17526837, -- Goblin Leecher A
            17526838, -- Goblin Leecher B
            17526839, -- Goblin Bouncer
            17526840, -- Orcish Grunt A
            17526841, -- Orcish Grunt B
            17526842, -- Orcish Cursemaker
            17526843, -- Brass Quadav A
            17526844, -- Copper Quadav     ← Alpha stops here (8)
            17526845, -- Goblin Leecher C
            17526846, -- Orcish Grunt C
            17526847, -- Brass Quadav B
            17526848, -- Brass Quadav C    ← Beta stops here (12)
            17526849, -- Circuit Arbiter   ← Gamma uses all 13
        },

        -- -------------------------------------------------------
        -- Circuit Lv40 mobs (circuits 18313/18314/18315)
        -- -------------------------------------------------------
        C40 =
        {
            17526850, -- Gigas Fighter A
            17526851, -- Gigas Wrestler A
            17526852, -- Ghoul A
            17526853, -- Wight A
            17526854, -- Tonberry Tracker
            17526855, -- Tonberry Elder
            17526856, -- Roc
            17526857, -- Gigas Fighter B   ← Alpha stops here (8)
            17526858, -- Ghoul B
            17526859, -- Ghoul C
            17526860, -- Wight B
            17526861, -- Gigas Wrestler B  ← Beta stops here (12)
            17526862, -- Circuit Arbiter   ← Gamma uses all 13
        },

        -- -------------------------------------------------------
        -- Circuit Lv50 mobs (circuits 18316/18317/18318)
        -- -------------------------------------------------------
        C50 =
        {
            17526863, -- Imp A
            17526864, -- Imp B
            17526865, -- Shadow Orc A
            17526866, -- Shadow Orc B
            17526867, -- Fire Elemental A
            17526868, -- Ice Elemental A
            17526869, -- Haunt A
            17526870, -- Haunt B           ← Alpha stops here (8)
            17526871, -- Imp C
            17526872, -- Shadow Orc C
            17526873, -- Fire Elemental B
            17526874, -- Ice Elemental B   ← Beta stops here (12)
            17526875, -- Circuit Arbiter   ← Gamma uses all 13
        },

        -- -------------------------------------------------------
        -- Circuit Lv60 mobs (circuits 18319/18320/18321)
        -- -------------------------------------------------------
        C60 =
        {
            17526876, -- Ahriman A
            17526877, -- Ahriman B
            17526878, -- Haunt A
            17526879, -- Specter
            17526880, -- Demon Knight A
            17526881, -- Demon Knight B
            17526882, -- Demon Warlock
            17526883, -- Ahriman C         ← Alpha stops here (8)
            17526884, -- Haunt B
            17526885, -- Demon Knight C
            17526886, -- Ahriman D
            17526887, -- Demon Knight D    ← Beta stops here (12)
            17526888, -- Circuit Arbiter   ← Gamma uses all 13
        },
    },
    npc =
    {
    },
}

return zones[xi.zone.MAQUETTE_ABDHALJS_LEGION_A]
