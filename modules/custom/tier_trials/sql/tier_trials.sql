-- =============================================================
-- Tier Trials — Database Setup
-- Zone: MAQUETTE_ABDHALJS_LEGION_A (183)
-- Instance IDs: 18301–18304 (Trials), 18310–18321 (Circuit)
--
-- Mob ID formula: 0x1000000 + zone_id * 0x1000 + entity_index
-- Zone 183 base:  17526784  (0x010B7000)
-- Entity range:   17526785–17527040 (256 slots allocated)
--
-- Poolid reference (reuse existing mob families):
--   Goblin Leecher       poolid 1683
--   Goblin Bouncer       poolid 1641
--   Orcish Grunt         poolid 3017
--   Orcish Cursemaker    poolid 3004
--   Brass Quadav         poolid 6240   (Stonecaster stand-in)
--   Copper Quadav        poolid 6241   (Sapper stand-in)
--   Gigas Fighter        poolid 1600
--   Gigas Wrestler       poolid 1600   (same family, different name)
--   Ghoul (WAR-type)     poolid 1517
--   Ghoul (BLM-type)     poolid 1518
--   Wight (BLM-type)     poolid 6570
--   Tonberry Tracker     poolid 3972
--   Tonberry Bedeviler   poolid 3948   (Elder stand-in)
--   Imp                  poolid 2065
--   Dark Elemental       poolid 913
--   Fire Elemental       poolid 1341
--   Ice Elemental        poolid 2043
--   Haunt                poolid 1900
--   Ahriman              poolid 65
-- =============================================================

-- =============================================================
-- SECTION 1: mob_groups for zone 183
-- All group IDs start at 1 (zone 183 is currently empty)
-- Format: (groupid, poolid, zoneid, name, respawntime, spawntype, dropid, HP, MP, allegiance, content_tag)
-- respawntime=0 for instance mobs (engine handles respawn)
-- spawntype=128 for instance-only mobs (not persistent world spawns)
-- dropid=0 (no standard drops — rewards handled in Lua)
-- =============================================================

-- -----------------------------------------------------------
-- Tier 30: The Valkurm Proving
-- Group IDs 1–14
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (1,  1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot A
INSERT INTO `mob_groups` VALUES (2,  1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot B
INSERT INTO `mob_groups` VALUES (3,  1641, 183, 'Goblin_Bouncer',    0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot C
INSERT INTO `mob_groups` VALUES (4,  3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot A
INSERT INTO `mob_groups` VALUES (5,  3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot B
INSERT INTO `mob_groups` VALUES (6,  3004, 183, 'Orcish_Cursemaker', 0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot C
INSERT INTO `mob_groups` VALUES (7,  6240, 183, 'Brass_Quadav',      0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot A
INSERT INTO `mob_groups` VALUES (8,  6240, 183, 'Brass_Quadav',      0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot B
INSERT INTO `mob_groups` VALUES (9,  6241, 183, 'Copper_Quadav',     0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot C
INSERT INTO `mob_groups` VALUES (10, 1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot A
INSERT INTO `mob_groups` VALUES (11, 1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot B
INSERT INTO `mob_groups` VALUES (12, 3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot C
INSERT INTO `mob_groups` VALUES (13, 3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot D
INSERT INTO `mob_groups` VALUES (14, 1683, 183, 'Brakk_the_Lockjaw', 0, 128, 0, 0, 0, 0, NULL); -- Wave 5 boss

-- -----------------------------------------------------------
-- Tier 40: The Qufim Crucible
-- Group IDs 15–28
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (15, 1600, 183, 'Gigas_Fighter',     0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot A
INSERT INTO `mob_groups` VALUES (16, 1600, 183, 'Gigas_Wrestler',    0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot B
INSERT INTO `mob_groups` VALUES (17, 1517, 183, 'Ghoul',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot A
INSERT INTO `mob_groups` VALUES (18, 1517, 183, 'Ghoul',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot B
INSERT INTO `mob_groups` VALUES (19, 6570, 183, 'Wight',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot C
INSERT INTO `mob_groups` VALUES (20, 3972, 183, 'Tonberry_Tracker',  0, 128, 0, 5000, 0, 0, NULL); -- Wave 3, slot A
INSERT INTO `mob_groups` VALUES (21, 3948, 183, 'Tonberry_Elder',    0, 128, 0, 5000, 0, 0, NULL); -- Wave 3, slot B
INSERT INTO `mob_groups` VALUES (22, 3376, 183, 'Roc',               0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot A
INSERT INTO `mob_groups` VALUES (23, 1600, 183, 'Gigas_Fighter',     0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot B
INSERT INTO `mob_groups` VALUES (24, 1600, 183, 'Gigas_Wrestler',    0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot C
INSERT INTO `mob_groups` VALUES (25, 1600, 183, 'Kalabaros_the_Unbroken', 0, 128, 0, 0, 0, 0, NULL); -- Wave 5 boss
INSERT INTO `mob_groups` VALUES (26, 6570, 183, 'Wight_Summon',      0, 128, 0, 0, 0, 0, NULL); -- Wave 5 Kalabaros summon

-- -----------------------------------------------------------
-- Tier 50: The Fauregandi Trial
-- Group IDs 27–42
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (27, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot A
INSERT INTO `mob_groups` VALUES (28, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot B
INSERT INTO `mob_groups` VALUES (29, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot C
INSERT INTO `mob_groups` VALUES (30, 3004, 183, 'Shadow_Orc',        0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot A
INSERT INTO `mob_groups` VALUES (31, 3004, 183, 'Shadow_Orc',        0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot B
INSERT INTO `mob_groups` VALUES (32, 6240, 183, 'Undead_Quadav',     0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot C
INSERT INTO `mob_groups` VALUES (33, 1341, 183, 'Fire_Elemental',    0, 132, 0, 0, 0, 0, NULL); -- Wave 3, slot A
INSERT INTO `mob_groups` VALUES (34, 2043, 183, 'Ice_Elemental',     0, 132, 0, 0, 0, 0, NULL); -- Wave 3, slot B
INSERT INTO `mob_groups` VALUES (35, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot A
INSERT INTO `mob_groups` VALUES (36, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot B
INSERT INTO `mob_groups` VALUES (37, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot C
INSERT INTO `mob_groups` VALUES (38, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot D
INSERT INTO `mob_groups` VALUES (39, 2065, 183, 'Valdris_the_Hollowed', 0, 128, 0, 0, 0, 0, NULL); -- Wave 5 boss

-- -----------------------------------------------------------
-- Tier 60: The Pso'Xja Ordeal
-- Group IDs 40–56
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (40, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot A
INSERT INTO `mob_groups` VALUES (41, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot B
INSERT INTO `mob_groups` VALUES (42, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot A
INSERT INTO `mob_groups` VALUES (43, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot B
INSERT INTO `mob_groups` VALUES (44, 6570, 183, 'Specter',           0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot C
INSERT INTO `mob_groups` VALUES (45, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot A
INSERT INTO `mob_groups` VALUES (46, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot B
INSERT INTO `mob_groups` VALUES (47, 2065, 183, 'Demon_Warlock',     0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot C
INSERT INTO `mob_groups` VALUES (48, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot A
INSERT INTO `mob_groups` VALUES (49, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot B
INSERT INTO `mob_groups` VALUES (50, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot C
INSERT INTO `mob_groups` VALUES (51, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot D
INSERT INTO `mob_groups` VALUES (52, 65,   183, 'Vraeth_the_Tetrachromic', 0, 128, 0, 0, 0, 0, NULL); -- Wave 5 boss

-- =============================================================
-- SECTION 2: mob_spawn_points for zone 183
-- Entity IDs: 17526785–17526837 (Tier Trials)
-- All positions 0,0,0 — engine positions mobs in instance zone
-- Format: (mobid, spawnslotid, mobname, polutils_name, groupid, minLevel, maxLevel, pos_x, pos_y, pos_z, pos_rot)
-- Levels are approximate — tuned to be challenging at cap
-- =============================================================

-- -----------------------------------------------------------
-- Tier 30 mob entities (IDs 17526785–17526798)
-- -----------------------------------------------------------
-- Wave 1
INSERT INTO `mob_spawn_points` VALUES (17526785, 0, 'Goblin_Leecher',    'Goblin Leecher',    1,  28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526786, 0, 'Goblin_Leecher',    'Goblin Leecher',    2,  28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526787, 0, 'Goblin_Bouncer',    'Goblin Bouncer',    3,  29, 31, 0.000, 0.000, 0.000, 0);
-- Wave 2
INSERT INTO `mob_spawn_points` VALUES (17526788, 0, 'Orcish_Grunt',      'Orcish Grunt',      4,  28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526789, 0, 'Orcish_Grunt',      'Orcish Grunt',      5,  28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526790, 0, 'Orcish_Cursemaker', 'Orcish Cursemaker', 6,  29, 31, 0.000, 0.000, 0.000, 0);
-- Wave 3
INSERT INTO `mob_spawn_points` VALUES (17526791, 0, 'Brass_Quadav',      'Brass Quadav',      7,  28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526792, 0, 'Brass_Quadav',      'Brass Quadav',      8,  28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526793, 0, 'Copper_Quadav',     'Copper Quadav',     9,  29, 31, 0.000, 0.000, 0.000, 0);
-- Wave 4
INSERT INTO `mob_spawn_points` VALUES (17526794, 0, 'Goblin_Leecher',    'Goblin Leecher',    10, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526795, 0, 'Goblin_Leecher',    'Goblin Leecher',    11, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526796, 0, 'Orcish_Grunt',      'Orcish Grunt',      12, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526797, 0, 'Orcish_Grunt',      'Orcish Grunt',      13, 29, 31, 0.000, 0.000, 0.000, 0);
-- Wave 5 boss
INSERT INTO `mob_spawn_points` VALUES (17526798, 0, 'Brakk_the_Lockjaw', 'Brakk the Lockjaw', 14, 32, 32, 0.000, 0.000, 0.000, 0);

-- -----------------------------------------------------------
-- Tier 40 mob entities (IDs 17526799–17526812)
-- -----------------------------------------------------------
-- Wave 1
INSERT INTO `mob_spawn_points` VALUES (17526799, 0, 'Gigas_Fighter',     'Gigas Fighter',     15, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526800, 0, 'Gigas_Wrestler',    'Gigas Wrestler',    16, 38, 40, 0.000, 0.000, 0.000, 0);
-- Wave 2
INSERT INTO `mob_spawn_points` VALUES (17526801, 0, 'Ghoul',             'Ghoul',             17, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526802, 0, 'Ghoul',             'Ghoul',             18, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526803, 0, 'Wight',             'Wight',             19, 39, 41, 0.000, 0.000, 0.000, 0);
-- Wave 3
INSERT INTO `mob_spawn_points` VALUES (17526804, 0, 'Tonberry_Tracker',  'Tonberry Tracker',  20, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526805, 0, 'Tonberry_Elder',    'Tonberry Elder',    21, 39, 41, 0.000, 0.000, 0.000, 0);
-- Wave 4
INSERT INTO `mob_spawn_points` VALUES (17526806, 0, 'Roc',               'Roc',               22, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526807, 0, 'Gigas_Fighter',     'Gigas Fighter',     23, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526808, 0, 'Gigas_Wrestler',    'Gigas Wrestler',    24, 39, 41, 0.000, 0.000, 0.000, 0);
-- Wave 5 boss + summon
INSERT INTO `mob_spawn_points` VALUES (17526809, 0, 'Kalabaros_the_Unbroken', 'Kalabaros the Unbroken', 25, 43, 43, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526810, 0, 'Wight_Summon',      'Wight',             26, 41, 41, 0.000, 0.000, 0.000, 0);

-- -----------------------------------------------------------
-- Tier 50 mob entities (IDs 17526811–17526823)
-- -----------------------------------------------------------
-- Wave 1
INSERT INTO `mob_spawn_points` VALUES (17526811, 0, 'Imp',               'Imp',               27, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526812, 0, 'Imp',               'Imp',               28, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526813, 0, 'Imp',               'Imp',               29, 49, 51, 0.000, 0.000, 0.000, 0);
-- Wave 2
INSERT INTO `mob_spawn_points` VALUES (17526814, 0, 'Shadow_Orc',        'Shadow Orc',        30, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526815, 0, 'Shadow_Orc',        'Shadow Orc',        31, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526816, 0, 'Undead_Quadav',     'Undead Quadav',     32, 48, 50, 0.000, 0.000, 0.000, 0);
-- Wave 3
INSERT INTO `mob_spawn_points` VALUES (17526817, 0, 'Fire_Elemental',    'Fire Elemental',    33, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526818, 0, 'Ice_Elemental',     'Ice Elemental',     34, 48, 50, 0.000, 0.000, 0.000, 0);
-- Wave 4
INSERT INTO `mob_spawn_points` VALUES (17526819, 0, 'Haunt',             'Haunt',             35, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526820, 0, 'Haunt',             'Haunt',             36, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526821, 0, 'Imp',               'Imp',               37, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526822, 0, 'Imp',               'Imp',               38, 49, 51, 0.000, 0.000, 0.000, 0);
-- Wave 5 boss
INSERT INTO `mob_spawn_points` VALUES (17526823, 0, 'Valdris_the_Hollowed', 'Valdris the Hollowed', 39, 54, 54, 0.000, 0.000, 0.000, 0);

-- -----------------------------------------------------------
-- Tier 60 mob entities (IDs 17526824–17526837)
-- -----------------------------------------------------------
-- Wave 1
INSERT INTO `mob_spawn_points` VALUES (17526824, 0, 'Ahriman',           'Ahriman',           40, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526825, 0, 'Ahriman',           'Ahriman',           41, 58, 60, 0.000, 0.000, 0.000, 0);
-- Wave 2
INSERT INTO `mob_spawn_points` VALUES (17526826, 0, 'Haunt',             'Haunt',             42, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526827, 0, 'Haunt',             'Haunt',             43, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526828, 0, 'Specter',           'Specter',           44, 59, 61, 0.000, 0.000, 0.000, 0);
-- Wave 3
INSERT INTO `mob_spawn_points` VALUES (17526829, 0, 'Demon_Knight',      'Demon Knight',      45, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526830, 0, 'Demon_Knight',      'Demon Knight',      46, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526831, 0, 'Demon_Warlock',     'Demon Warlock',     47, 59, 61, 0.000, 0.000, 0.000, 0);
-- Wave 4
INSERT INTO `mob_spawn_points` VALUES (17526832, 0, 'Ahriman',           'Ahriman',           48, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526833, 0, 'Ahriman',           'Ahriman',           49, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526834, 0, 'Demon_Knight',      'Demon Knight',      50, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526835, 0, 'Demon_Knight',      'Demon Knight',      51, 59, 61, 0.000, 0.000, 0.000, 0);
-- Wave 5 boss
INSERT INTO `mob_spawn_points` VALUES (17526836, 0, 'Vraeth_the_Tetrachromic', 'Vraeth the Tetrachromic', 52, 64, 64, 0.000, 0.000, 0.000, 0);

-- =============================================================
-- SECTION 3: instance_list entries
-- Zone 183 (MAQUETTE_ABDHALJS_LEGION_A), entrance zones TBD
-- Start positions 0,0,0 — requires in-game coordinate testing
-- time_limit in minutes
-- =============================================================

INSERT INTO `instance_list` VALUES
    (18301, 'tier_trial_30', 183, 103, 30, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
    -- instance_zone=183, entrance_zone=103 (Valkurm Dunes, thematic entry)

INSERT INTO `instance_list` VALUES
    (18302, 'tier_trial_40', 183, 126, 30, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
    -- entrance_zone=126 (Qufim Island)

INSERT INTO `instance_list` VALUES
    (18303, 'tier_trial_50', 183, 111, 30, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
    -- entrance_zone=111 (Beaucedine Glacier)

INSERT INTO `instance_list` VALUES
    (18304, 'tier_trial_60', 183, 9,  30, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
    -- entrance_zone=9 (Pso'Xja)

-- Circuit instances share the same zone, entrance zones match their tier
-- Circuit Alpha = shortest, Gamma = longest (time_limit used as reference only — scoring by elapsed)
INSERT INTO `instance_list` VALUES (18310, 'circuit_30_alpha', 183, 103, 15, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18311, 'circuit_30_beta',  183, 103, 20, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18312, 'circuit_30_gamma', 183, 103, 25, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18313, 'circuit_40_alpha', 183, 126, 15, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18314, 'circuit_40_beta',  183, 126, 20, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18315, 'circuit_40_gamma', 183, 126, 25, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18316, 'circuit_50_alpha', 183, 111, 15, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18317, 'circuit_50_beta',  183, 111, 20, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18318, 'circuit_50_gamma', 183, 111, 25, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18319, 'circuit_60_alpha', 183, 9,  15, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18320, 'circuit_60_beta',  183, 9,  20, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);
INSERT INTO `instance_list` VALUES (18321, 'circuit_60_gamma', 183, 9,  25, 0.000, 0.000, 0.000, 0, NULL, NULL, NULL, NULL);

-- =============================================================
-- SECTION 4: instance_entities
-- Maps each instance to all mob entity IDs it may spawn
-- Every mob referenced in Lua (even if not spawned on all difficulties)
-- must have a row here
-- =============================================================

-- Tier Trial 30
INSERT INTO `instance_entities` VALUES (18301, 17526785);
INSERT INTO `instance_entities` VALUES (18301, 17526786);
INSERT INTO `instance_entities` VALUES (18301, 17526787);
INSERT INTO `instance_entities` VALUES (18301, 17526788);
INSERT INTO `instance_entities` VALUES (18301, 17526789);
INSERT INTO `instance_entities` VALUES (18301, 17526790);
INSERT INTO `instance_entities` VALUES (18301, 17526791);
INSERT INTO `instance_entities` VALUES (18301, 17526792);
INSERT INTO `instance_entities` VALUES (18301, 17526793);
INSERT INTO `instance_entities` VALUES (18301, 17526794);
INSERT INTO `instance_entities` VALUES (18301, 17526795);
INSERT INTO `instance_entities` VALUES (18301, 17526796);
INSERT INTO `instance_entities` VALUES (18301, 17526797);
INSERT INTO `instance_entities` VALUES (18301, 17526798);

-- Tier Trial 40
INSERT INTO `instance_entities` VALUES (18302, 17526799);
INSERT INTO `instance_entities` VALUES (18302, 17526800);
INSERT INTO `instance_entities` VALUES (18302, 17526801);
INSERT INTO `instance_entities` VALUES (18302, 17526802);
INSERT INTO `instance_entities` VALUES (18302, 17526803);
INSERT INTO `instance_entities` VALUES (18302, 17526804);
INSERT INTO `instance_entities` VALUES (18302, 17526805);
INSERT INTO `instance_entities` VALUES (18302, 17526806);
INSERT INTO `instance_entities` VALUES (18302, 17526807);
INSERT INTO `instance_entities` VALUES (18302, 17526808);
INSERT INTO `instance_entities` VALUES (18302, 17526809);
INSERT INTO `instance_entities` VALUES (18302, 17526810);

-- Tier Trial 50
INSERT INTO `instance_entities` VALUES (18303, 17526811);
INSERT INTO `instance_entities` VALUES (18303, 17526812);
INSERT INTO `instance_entities` VALUES (18303, 17526813);
INSERT INTO `instance_entities` VALUES (18303, 17526814);
INSERT INTO `instance_entities` VALUES (18303, 17526815);
INSERT INTO `instance_entities` VALUES (18303, 17526816);
INSERT INTO `instance_entities` VALUES (18303, 17526817);
INSERT INTO `instance_entities` VALUES (18303, 17526818);
INSERT INTO `instance_entities` VALUES (18303, 17526819);
INSERT INTO `instance_entities` VALUES (18303, 17526820);
INSERT INTO `instance_entities` VALUES (18303, 17526821);
INSERT INTO `instance_entities` VALUES (18303, 17526822);
INSERT INTO `instance_entities` VALUES (18303, 17526823);

-- Tier Trial 60
INSERT INTO `instance_entities` VALUES (18304, 17526824);
INSERT INTO `instance_entities` VALUES (18304, 17526825);
INSERT INTO `instance_entities` VALUES (18304, 17526826);
INSERT INTO `instance_entities` VALUES (18304, 17526827);
INSERT INTO `instance_entities` VALUES (18304, 17526828);
INSERT INTO `instance_entities` VALUES (18304, 17526829);
INSERT INTO `instance_entities` VALUES (18304, 17526830);
INSERT INTO `instance_entities` VALUES (18304, 17526831);
INSERT INTO `instance_entities` VALUES (18304, 17526832);
INSERT INTO `instance_entities` VALUES (18304, 17526833);
INSERT INTO `instance_entities` VALUES (18304, 17526834);
INSERT INTO `instance_entities` VALUES (18304, 17526835);
INSERT INTO `instance_entities` VALUES (18304, 17526836);

-- NOTE: Circuit instance_entities are defined in modules/custom/circuit/sql/circuit.sql
-- Circuit mobs share entity IDs 17526837–17527040 in zone 183
