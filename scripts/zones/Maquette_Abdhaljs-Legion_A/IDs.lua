-----------------------------------
-- Area: Maquette_Abdhaljs-Legion_A
-----------------------------------
zones = zones or {}

zones[xi.zone.MAQUETTE_ABDHALJS_LEGION_A] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
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
    },
    npc =
    {
    },
}

return zones[xi.zone.MAQUETTE_ABDHALJS_LEGION_A]
