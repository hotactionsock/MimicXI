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
-- =============================================================
-- CLEANUP: remove any previous run's data before re-inserting
-- Safe to run multiple times.
-- =============================================================
DELETE FROM `instance_entities`  WHERE instanceid IN (18301, 18302, 18303, 18304);
DELETE FROM `instance_list`      WHERE instanceid IN (18301, 18302, 18303, 18304);
DELETE FROM `mob_spawn_points`   WHERE mobid BETWEEN 17526785 AND 17526836;
DELETE FROM `mob_groups`         WHERE groupid BETWEEN 12000 AND 12051;

-- SECTION 1: mob_groups for zone 183
-- Group IDs start at 12000 (base game uses up to 11354)
-- Format: (groupid, poolid, zoneid, name, respawntime, spawntype, dropid, HP, MP, allegiance, content_tag)
-- respawntime=0 for instance mobs (engine handles respawn)
-- spawntype=128 for instance-only mobs (not persistent world spawns)
-- dropid=0 (no standard drops — rewards handled in Lua)
-- =============================================================

-- -----------------------------------------------------------
-- Tier 30: The Valkurm Proving
-- Group IDs 12000–12013
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (12000,  1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot A
INSERT INTO `mob_groups` VALUES (12001,  1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot B
INSERT INTO `mob_groups` VALUES (12002,  1641, 183, 'Goblin_Bouncer',    0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot C
INSERT INTO `mob_groups` VALUES (12003,  3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot A
INSERT INTO `mob_groups` VALUES (12004,  3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot B
INSERT INTO `mob_groups` VALUES (12005,  3004, 183, 'Orcish_Cursemaker', 0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot C
INSERT INTO `mob_groups` VALUES (12006,  6240, 183, 'Brass_Quadav',      0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot A
INSERT INTO `mob_groups` VALUES (12007,  6240, 183, 'Brass_Quadav',      0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot B
INSERT INTO `mob_groups` VALUES (12008,  6241, 183, 'Copper_Quadav',     0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot C
INSERT INTO `mob_groups` VALUES (12009, 1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot A
INSERT INTO `mob_groups` VALUES (12010, 1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot B
INSERT INTO `mob_groups` VALUES (12011, 3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot C
INSERT INTO `mob_groups` VALUES (12012, 3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot D
INSERT INTO `mob_groups` VALUES (12013, 1683, 183, 'Brakk_the_Lockjaw', 0, 128, 0, 0, 0, 0, NULL); -- Wave 5 boss

-- -----------------------------------------------------------
-- Tier 40: The Qufim Crucible
-- Group IDs 12014–12025
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (12014, 1600, 183, 'Gigas_Fighter',     0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot A
INSERT INTO `mob_groups` VALUES (12015, 1600, 183, 'Gigas_Wrestler',    0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot B
INSERT INTO `mob_groups` VALUES (12016, 1517, 183, 'Ghoul',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot A
INSERT INTO `mob_groups` VALUES (12017, 1517, 183, 'Ghoul',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot B
INSERT INTO `mob_groups` VALUES (12018, 6570, 183, 'Wight',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot C
INSERT INTO `mob_groups` VALUES (12019, 3972, 183, 'Tonberry_Tracker',  0, 128, 0, 5000, 0, 0, NULL); -- Wave 3, slot A
INSERT INTO `mob_groups` VALUES (12020, 3948, 183, 'Tonberry_Elder',    0, 128, 0, 5000, 0, 0, NULL); -- Wave 3, slot B
INSERT INTO `mob_groups` VALUES (12021, 3376, 183, 'Roc',               0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot A
INSERT INTO `mob_groups` VALUES (12022, 1600, 183, 'Gigas_Fighter',     0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot B
INSERT INTO `mob_groups` VALUES (12023, 1600, 183, 'Gigas_Wrestler',    0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot C
INSERT INTO `mob_groups` VALUES (12024, 1600, 183, 'Kalabaros_the_Unbroken', 0, 128, 0, 0, 0, 0, NULL); -- Wave 5 boss
INSERT INTO `mob_groups` VALUES (12025, 6570, 183, 'Wight_Summon',      0, 128, 0, 0, 0, 0, NULL); -- Wave 5 Kalabaros summon

-- -----------------------------------------------------------
-- Tier 50: The Fauregandi Trial
-- Group IDs 12026–12038
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (12026, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot A
INSERT INTO `mob_groups` VALUES (12027, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot B
INSERT INTO `mob_groups` VALUES (12028, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot C
INSERT INTO `mob_groups` VALUES (12029, 3004, 183, 'Shadow_Orc',        0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot A
INSERT INTO `mob_groups` VALUES (12030, 3004, 183, 'Shadow_Orc',        0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot B
INSERT INTO `mob_groups` VALUES (12031, 6240, 183, 'Undead_Quadav',     0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot C
INSERT INTO `mob_groups` VALUES (12032, 1341, 183, 'Fire_Elemental',    0, 132, 0, 0, 0, 0, NULL); -- Wave 3, slot A
INSERT INTO `mob_groups` VALUES (12033, 2043, 183, 'Ice_Elemental',     0, 132, 0, 0, 0, 0, NULL); -- Wave 3, slot B
INSERT INTO `mob_groups` VALUES (12034, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot A
INSERT INTO `mob_groups` VALUES (12035, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot B
INSERT INTO `mob_groups` VALUES (12036, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot C
INSERT INTO `mob_groups` VALUES (12037, 2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot D
INSERT INTO `mob_groups` VALUES (12038, 2065, 183, 'Valdris_the_Hollowed', 0, 128, 0, 0, 0, 0, NULL); -- Wave 5 boss

-- -----------------------------------------------------------
-- Tier 60: The Pso'Xja Ordeal
-- Group IDs 12039–12051
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (12039, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot A
INSERT INTO `mob_groups` VALUES (12040, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL); -- Wave 1, slot B
INSERT INTO `mob_groups` VALUES (12041, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot A
INSERT INTO `mob_groups` VALUES (12042, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot B
INSERT INTO `mob_groups` VALUES (12043, 6570, 183, 'Specter',           0, 128, 0, 0, 0, 0, NULL); -- Wave 2, slot C
INSERT INTO `mob_groups` VALUES (12044, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot A
INSERT INTO `mob_groups` VALUES (12045, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot B
INSERT INTO `mob_groups` VALUES (12046, 2065, 183, 'Demon_Warlock',     0, 128, 0, 0, 0, 0, NULL); -- Wave 3, slot C
INSERT INTO `mob_groups` VALUES (12047, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot A
INSERT INTO `mob_groups` VALUES (12048, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot B
INSERT INTO `mob_groups` VALUES (12049, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot C
INSERT INTO `mob_groups` VALUES (12050, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL); -- Wave 4, slot D
INSERT INTO `mob_groups` VALUES (12051, 65,   183, 'Vraeth_the_Tetrachromic', 0, 128, 0, 0, 0, 0, NULL); -- Wave 5 boss

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
INSERT INTO `mob_spawn_points` VALUES (17526785, 0, 'Goblin_Leecher', 'Goblin Leecher', 12000, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526786, 0, 'Goblin_Leecher', 'Goblin Leecher', 12001, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526787, 0, 'Goblin_Bouncer', 'Goblin Bouncer', 12002, 29, 31, 0.000, 0.000, 0.000, 0);
-- Wave 2
INSERT INTO `mob_spawn_points` VALUES (17526788, 0, 'Orcish_Grunt', 'Orcish Grunt', 12003, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526789, 0, 'Orcish_Grunt', 'Orcish Grunt', 12004, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526790, 0, 'Orcish_Cursemaker', 'Orcish Cursemaker', 12005, 29, 31, 0.000, 0.000, 0.000, 0);
-- Wave 3
INSERT INTO `mob_spawn_points` VALUES (17526791, 0, 'Brass_Quadav', 'Brass Quadav', 12006, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526792, 0, 'Brass_Quadav', 'Brass Quadav', 12007, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526793, 0, 'Copper_Quadav', 'Copper Quadav', 12008, 29, 31, 0.000, 0.000, 0.000, 0);
-- Wave 4
INSERT INTO `mob_spawn_points` VALUES (17526794, 0, 'Goblin_Leecher', 'Goblin Leecher', 12009, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526795, 0, 'Goblin_Leecher', 'Goblin Leecher', 12010, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526796, 0, 'Orcish_Grunt', 'Orcish Grunt', 12011, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526797, 0, 'Orcish_Grunt', 'Orcish Grunt', 12012, 29, 31, 0.000, 0.000, 0.000, 0);
-- Wave 5 boss
INSERT INTO `mob_spawn_points` VALUES (17526798, 0, 'Brakk_the_Lockjaw', , 12013, 32, 32, 0.000, 0.000, 0.000, 0);

-- -----------------------------------------------------------
-- Tier 40 mob entities (IDs 17526799–17526812)
-- -----------------------------------------------------------
-- Wave 1
INSERT INTO `mob_spawn_points` VALUES (17526799, 0, 'Gigas_Fighter', 'Gigas Fighter', 12014, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526800, 0, 'Gigas_Wrestler', 'Gigas Wrestler', 12015, 38, 40, 0.000, 0.000, 0.000, 0);
-- Wave 2
INSERT INTO `mob_spawn_points` VALUES (17526801, 0, 'Ghoul', 'Ghoul', 12016, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526802, 0, 'Ghoul', 'Ghoul', 12017, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526803, 0, 'Wight', 'Wight', 12018, 39, 41, 0.000, 0.000, 0.000, 0);
-- Wave 3
INSERT INTO `mob_spawn_points` VALUES (17526804, 0, 'Tonberry_Tracker', 'Tonberry Tracker', 12019, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526805, 0, 'Tonberry_Elder', 'Tonberry Elder', 12020, 39, 41, 0.000, 0.000, 0.000, 0);
-- Wave 4
INSERT INTO `mob_spawn_points` VALUES (17526806, 0, 'Roc', 'Roc', 12021, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526807, 0, 'Gigas_Fighter', 'Gigas Fighter', 12022, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526808, 0, 'Gigas_Wrestler', 'Gigas Wrestler', 12023, 39, 41, 0.000, 0.000, 0.000, 0);
-- Wave 5 boss + summon
INSERT INTO `mob_spawn_points` VALUES (17526809, 0, 'Kalabaros_the_Unbroken', , 12024, 43, 43, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526810, 0, 'Wight_Summon', 'Wight', 12025, 41, 41, 0.000, 0.000, 0.000, 0);

-- -----------------------------------------------------------
-- Tier 50 mob entities (IDs 17526811–17526823)
-- -----------------------------------------------------------
-- Wave 1
INSERT INTO `mob_spawn_points` VALUES (17526811, 0, 'Imp', 'Imp', 12026, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526812, 0, 'Imp', 'Imp', 12027, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526813, 0, 'Imp', 'Imp', 12028, 49, 51, 0.000, 0.000, 0.000, 0);
-- Wave 2
INSERT INTO `mob_spawn_points` VALUES (17526814, 0, 'Shadow_Orc', 'Shadow Orc', 12029, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526815, 0, 'Shadow_Orc', 'Shadow Orc', 12030, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526816, 0, 'Undead_Quadav', 'Undead Quadav', 12031, 48, 50, 0.000, 0.000, 0.000, 0);
-- Wave 3
INSERT INTO `mob_spawn_points` VALUES (17526817, 0, 'Fire_Elemental', 'Fire Elemental', 12032, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526818, 0, 'Ice_Elemental', 'Ice Elemental', 12033, 48, 50, 0.000, 0.000, 0.000, 0);
-- Wave 4
INSERT INTO `mob_spawn_points` VALUES (17526819, 0, 'Haunt', 'Haunt', 12034, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526820, 0, 'Haunt', 'Haunt', 12035, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526821, 0, 'Imp', 'Imp', 12036, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526822, 0, 'Imp', 'Imp', 12037, 49, 51, 0.000, 0.000, 0.000, 0);
-- Wave 5 boss
INSERT INTO `mob_spawn_points` VALUES (17526823, 0, 'Valdris_the_Hollowed', , 12038, 54, 54, 0.000, 0.000, 0.000, 0);

-- -----------------------------------------------------------
-- Tier 60 mob entities (IDs 17526824–17526837)
-- -----------------------------------------------------------
-- Wave 1
INSERT INTO `mob_spawn_points` VALUES (17526824, 0, 'Ahriman', 'Ahriman', 12039, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526825, 0, 'Ahriman', 'Ahriman', 12040, 58, 60, 0.000, 0.000, 0.000, 0);
-- Wave 2
INSERT INTO `mob_spawn_points` VALUES (17526826, 0, 'Haunt', 'Haunt', 12041, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526827, 0, 'Haunt', 'Haunt', 12042, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526828, 0, 'Specter', 'Specter', 12043, 59, 61, 0.000, 0.000, 0.000, 0);
-- Wave 3
INSERT INTO `mob_spawn_points` VALUES (17526829, 0, 'Demon_Knight', 'Demon Knight', 12044, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526830, 0, 'Demon_Knight', 'Demon Knight', 12045, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526831, 0, 'Demon_Warlock', 'Demon Warlock', 12046, 59, 61, 0.000, 0.000, 0.000, 0);
-- Wave 4
INSERT INTO `mob_spawn_points` VALUES (17526832, 0, 'Ahriman', 'Ahriman', 12047, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526833, 0, 'Ahriman', 'Ahriman', 12048, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526834, 0, 'Demon_Knight', 'Demon Knight', 12049, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526835, 0, 'Demon_Knight', 'Demon Knight', 12050, 59, 61, 0.000, 0.000, 0.000, 0);
-- Wave 5 boss
INSERT INTO `mob_spawn_points` VALUES (17526836, 0, 'Vraeth_the_Tetrachromic', 'Vraeth the Tetrachromic', 12051, 64, 64, 0.000, 0.000, 0.000, 0);

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
