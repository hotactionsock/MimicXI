-- =============================================================
-- The Circuit — Database Setup
-- Zone: MAQUETTE_ABDHALJS_LEGION_A (183) — shared with Tier Trials
-- Instance IDs: 18310–18321 (12 circuit instances)
-- Circuit mob entity IDs: 17526837–17527040
--
-- Circuit mobs are smaller in count than Trial mobs — the fights
-- are shorter and tuned for speed rather than attrition.
-- Each circuit uses 8–16 mob entities.
-- =============================================================

-- =============================================================
-- SECTION 1: Leaderboard table
-- =============================================================

CREATE TABLE IF NOT EXISTS `circuit_leaderboard` (
    `id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `char_id`       INT UNSIGNED NOT NULL,
    `char_name`     VARCHAR(15)  NOT NULL,
    `circuit_id`    TINYINT UNSIGNED NOT NULL,   -- 1–12 matching xi.circuit.CIRCUITS keys
    `clear_time_ms` INT UNSIGNED NOT NULL,
    `rank`          VARCHAR(8)   NOT NULL,        -- Platinum/Gold/Silver/Bronze/Clear
    `points_earned` TINYINT UNSIGNED NOT NULL,
    `cleared_at`    DATETIME DEFAULT NOW(),
    `week_number`   SMALLINT UNSIGNED NOT NULL,   -- YEARWEEK(NOW(), 1) at time of clear
    INDEX idx_circuit_week (`circuit_id`, `week_number`, `clear_time_ms`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================================
-- SECTION 2: mob_groups for Circuit mobs in zone 183
-- These mobs are tuned for speed: lower HP, faster respawn, more TP moves
-- Group IDs 60–120 (continuing from Tier Trial groups 1–56)
-- Same mob families as Trials, different tuning via HP/MP overrides
-- Circuits use HP=override values; 0 means use pool default
-- =============================================================

-- -----------------------------------------------------------
-- Circuit Lv30 mobs (groups 60–72)
-- Alpha: 2 rooms, 8 mobs. Beta: 3 rooms, 12 mobs. Gamma: 4 rooms, 16 mobs.
-- -----------------------------------------------------------
-- Alpha rooms
INSERT INTO `mob_groups` VALUES (60, 1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (61, 1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (62, 1641, 183, 'Goblin_Bouncer',    0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (63, 3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (64, 3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (65, 3004, 183, 'Orcish_Cursemaker', 0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (66, 6240, 183, 'Brass_Quadav',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (67, 6241, 183, 'Copper_Quadav',     0, 128, 0, 0, 0, 0, NULL);
-- Beta/Gamma extras
INSERT INTO `mob_groups` VALUES (68, 1683, 183, 'Goblin_Leecher',    0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (69, 3017, 183, 'Orcish_Grunt',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (70, 6240, 183, 'Brass_Quadav',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (71, 6240, 183, 'Brass_Quadav',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (72, 1683, 183, 'Circuit_Arbiter_30', 0, 128, 0, 0, 0, 0, NULL); -- Room boss (Goblin NM)

-- -----------------------------------------------------------
-- Circuit Lv40 mobs (groups 73–85)
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (73, 1600, 183, 'Gigas_Fighter',     0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (74, 1600, 183, 'Gigas_Wrestler',    0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (75, 1517, 183, 'Ghoul',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (76, 6570, 183, 'Wight',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (77, 3972, 183, 'Tonberry_Tracker',  0, 128, 0, 5000, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (78, 3948, 183, 'Tonberry_Elder',    0, 128, 0, 5000, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (79, 3376, 183, 'Roc',               0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (80, 1600, 183, 'Gigas_Fighter',     0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (81, 1517, 183, 'Ghoul',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (82, 1517, 183, 'Ghoul',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (83, 6570, 183, 'Wight',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (84, 1600, 183, 'Gigas_Wrestler',    0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (85, 1600, 183, 'Circuit_Arbiter_40', 0, 128, 0, 0, 0, 0, NULL); -- Room boss (Gigas NM)

-- -----------------------------------------------------------
-- Circuit Lv50 mobs (groups 86–98)
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (86,  2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (87,  2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (88,  3004, 183, 'Shadow_Orc',        0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (89,  3004, 183, 'Shadow_Orc',        0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (90,  1341, 183, 'Fire_Elemental',    0, 132, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (91,  2043, 183, 'Ice_Elemental',     0, 132, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (92,  1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (93,  1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (94,  2065, 183, 'Imp',               0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (95,  3004, 183, 'Shadow_Orc',        0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (96,  1341, 183, 'Fire_Elemental',    0, 132, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (97,  2043, 183, 'Ice_Elemental',     0, 132, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (98,  2065, 183, 'Circuit_Arbiter_50', 0, 128, 0, 0, 0, 0, NULL); -- Room boss (Demon NM)

-- -----------------------------------------------------------
-- Circuit Lv60 mobs (groups 99–111)
-- -----------------------------------------------------------
INSERT INTO `mob_groups` VALUES (99,  65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (100, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (101, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (102, 6570, 183, 'Specter',           0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (103, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (104, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (105, 2065, 183, 'Demon_Warlock',     0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (106, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (107, 1900, 183, 'Haunt',             0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (108, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (109, 65,   183, 'Ahriman',           0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (110, 3004, 183, 'Demon_Knight',      0, 128, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (111, 65,   183, 'Circuit_Arbiter_60', 0, 128, 0, 0, 0, 0, NULL); -- Room boss (Ahriman NM)

-- =============================================================
-- SECTION 3: mob_spawn_points for Circuit mobs
-- Entity IDs: 17526837–17526940
-- Levels slightly higher than wave mobs — Circuit enemies are tuned for speed
-- =============================================================

-- Lv30 Circuit mobs (17526837–17526849)
INSERT INTO `mob_spawn_points` VALUES (17526837, 0, 'Goblin_Leecher',     'Goblin Leecher',     60, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526838, 0, 'Goblin_Leecher',     'Goblin Leecher',     61, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526839, 0, 'Goblin_Bouncer',     'Goblin Bouncer',     62, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526840, 0, 'Orcish_Grunt',       'Orcish Grunt',       63, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526841, 0, 'Orcish_Grunt',       'Orcish Grunt',       64, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526842, 0, 'Orcish_Cursemaker',  'Orcish Cursemaker',  65, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526843, 0, 'Brass_Quadav',       'Brass Quadav',       66, 28, 30, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526844, 0, 'Copper_Quadav',      'Copper Quadav',      67, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526845, 0, 'Goblin_Leecher',     'Goblin Leecher',     68, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526846, 0, 'Orcish_Grunt',       'Orcish Grunt',       69, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526847, 0, 'Brass_Quadav',       'Brass Quadav',       70, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526848, 0, 'Brass_Quadav',       'Brass Quadav',       71, 29, 31, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526849, 0, 'Circuit_Arbiter_30', 'Circuit Arbiter',    72, 32, 32, 0.000, 0.000, 0.000, 0);

-- Lv40 Circuit mobs (17526850–17526862)
INSERT INTO `mob_spawn_points` VALUES (17526850, 0, 'Gigas_Fighter',      'Gigas Fighter',      73, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526851, 0, 'Gigas_Wrestler',     'Gigas Wrestler',     74, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526852, 0, 'Ghoul',              'Ghoul',              75, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526853, 0, 'Wight',              'Wight',              76, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526854, 0, 'Tonberry_Tracker',   'Tonberry Tracker',   77, 38, 40, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526855, 0, 'Tonberry_Elder',     'Tonberry Elder',     78, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526856, 0, 'Roc',                'Roc',                79, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526857, 0, 'Gigas_Fighter',      'Gigas Fighter',      80, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526858, 0, 'Ghoul',              'Ghoul',              81, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526859, 0, 'Ghoul',              'Ghoul',              82, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526860, 0, 'Wight',              'Wight',              83, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526861, 0, 'Gigas_Wrestler',     'Gigas Wrestler',     84, 39, 41, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526862, 0, 'Circuit_Arbiter_40', 'Circuit Arbiter',    85, 43, 43, 0.000, 0.000, 0.000, 0);

-- Lv50 Circuit mobs (17526863–17526875)
INSERT INTO `mob_spawn_points` VALUES (17526863, 0, 'Imp',                'Imp',                86, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526864, 0, 'Imp',                'Imp',                87, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526865, 0, 'Shadow_Orc',         'Shadow Orc',         88, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526866, 0, 'Shadow_Orc',         'Shadow Orc',         89, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526867, 0, 'Fire_Elemental',     'Fire Elemental',     90, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526868, 0, 'Ice_Elemental',      'Ice Elemental',      91, 48, 50, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526869, 0, 'Haunt',              'Haunt',              92, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526870, 0, 'Haunt',              'Haunt',              93, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526871, 0, 'Imp',                'Imp',                94, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526872, 0, 'Shadow_Orc',         'Shadow Orc',         95, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526873, 0, 'Fire_Elemental',     'Fire Elemental',     96, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526874, 0, 'Ice_Elemental',      'Ice Elemental',      97, 49, 51, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526875, 0, 'Circuit_Arbiter_50', 'Circuit Arbiter',    98, 54, 54, 0.000, 0.000, 0.000, 0);

-- Lv60 Circuit mobs (17526876–17526888)
INSERT INTO `mob_spawn_points` VALUES (17526876, 0, 'Ahriman',            'Ahriman',            99,  58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526877, 0, 'Ahriman',            'Ahriman',            100, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526878, 0, 'Haunt',              'Haunt',              101, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526879, 0, 'Specter',            'Specter',            102, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526880, 0, 'Demon_Knight',       'Demon Knight',       103, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526881, 0, 'Demon_Knight',       'Demon Knight',       104, 58, 60, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526882, 0, 'Demon_Warlock',      'Demon Warlock',      105, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526883, 0, 'Ahriman',            'Ahriman',            106, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526884, 0, 'Haunt',              'Haunt',              107, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526885, 0, 'Demon_Knight',       'Demon Knight',       108, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526886, 0, 'Ahriman',            'Ahriman',            109, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526887, 0, 'Demon_Knight',       'Demon Knight',       110, 59, 61, 0.000, 0.000, 0.000, 0);
INSERT INTO `mob_spawn_points` VALUES (17526888, 0, 'Circuit_Arbiter_60', 'Circuit Arbiter',    111, 64, 64, 0.000, 0.000, 0.000, 0);

-- =============================================================
-- SECTION 4: instance_entities for all 12 circuits
-- Each circuit gets the mobs it needs for its room layout.
-- Alpha uses 8 mobs, Beta uses 12, Gamma uses all 13.
-- =============================================================

-- Circuit 30 Alpha (instance 18310) — 2 rooms, 8 mobs
INSERT INTO `instance_entities` VALUES (18310, 17526837);
INSERT INTO `instance_entities` VALUES (18310, 17526838);
INSERT INTO `instance_entities` VALUES (18310, 17526839);
INSERT INTO `instance_entities` VALUES (18310, 17526840);
INSERT INTO `instance_entities` VALUES (18310, 17526841);
INSERT INTO `instance_entities` VALUES (18310, 17526842);
INSERT INTO `instance_entities` VALUES (18310, 17526843);
INSERT INTO `instance_entities` VALUES (18310, 17526849); -- Arbiter boss

-- Circuit 30 Beta (instance 18311) — 3 rooms, 12 mobs
INSERT INTO `instance_entities` VALUES (18311, 17526837);
INSERT INTO `instance_entities` VALUES (18311, 17526838);
INSERT INTO `instance_entities` VALUES (18311, 17526839);
INSERT INTO `instance_entities` VALUES (18311, 17526840);
INSERT INTO `instance_entities` VALUES (18311, 17526841);
INSERT INTO `instance_entities` VALUES (18311, 17526842);
INSERT INTO `instance_entities` VALUES (18311, 17526843);
INSERT INTO `instance_entities` VALUES (18311, 17526844);
INSERT INTO `instance_entities` VALUES (18311, 17526845);
INSERT INTO `instance_entities` VALUES (18311, 17526846);
INSERT INTO `instance_entities` VALUES (18311, 17526847);
INSERT INTO `instance_entities` VALUES (18311, 17526849); -- Arbiter boss

-- Circuit 30 Gamma (instance 18312) — 4 rooms, all 13
INSERT INTO `instance_entities` VALUES (18312, 17526837);
INSERT INTO `instance_entities` VALUES (18312, 17526838);
INSERT INTO `instance_entities` VALUES (18312, 17526839);
INSERT INTO `instance_entities` VALUES (18312, 17526840);
INSERT INTO `instance_entities` VALUES (18312, 17526841);
INSERT INTO `instance_entities` VALUES (18312, 17526842);
INSERT INTO `instance_entities` VALUES (18312, 17526843);
INSERT INTO `instance_entities` VALUES (18312, 17526844);
INSERT INTO `instance_entities` VALUES (18312, 17526845);
INSERT INTO `instance_entities` VALUES (18312, 17526846);
INSERT INTO `instance_entities` VALUES (18312, 17526847);
INSERT INTO `instance_entities` VALUES (18312, 17526848);
INSERT INTO `instance_entities` VALUES (18312, 17526849);

-- Circuit 40 Alpha (instance 18313)
INSERT INTO `instance_entities` VALUES (18313, 17526850);
INSERT INTO `instance_entities` VALUES (18313, 17526851);
INSERT INTO `instance_entities` VALUES (18313, 17526852);
INSERT INTO `instance_entities` VALUES (18313, 17526853);
INSERT INTO `instance_entities` VALUES (18313, 17526854);
INSERT INTO `instance_entities` VALUES (18313, 17526855);
INSERT INTO `instance_entities` VALUES (18313, 17526856);
INSERT INTO `instance_entities` VALUES (18313, 17526862); -- Arbiter

-- Circuit 40 Beta (instance 18314)
INSERT INTO `instance_entities` VALUES (18314, 17526850);
INSERT INTO `instance_entities` VALUES (18314, 17526851);
INSERT INTO `instance_entities` VALUES (18314, 17526852);
INSERT INTO `instance_entities` VALUES (18314, 17526853);
INSERT INTO `instance_entities` VALUES (18314, 17526854);
INSERT INTO `instance_entities` VALUES (18314, 17526855);
INSERT INTO `instance_entities` VALUES (18314, 17526856);
INSERT INTO `instance_entities` VALUES (18314, 17526857);
INSERT INTO `instance_entities` VALUES (18314, 17526858);
INSERT INTO `instance_entities` VALUES (18314, 17526859);
INSERT INTO `instance_entities` VALUES (18314, 17526860);
INSERT INTO `instance_entities` VALUES (18314, 17526862); -- Arbiter

-- Circuit 40 Gamma (instance 18315)
INSERT INTO `instance_entities` VALUES (18315, 17526850);
INSERT INTO `instance_entities` VALUES (18315, 17526851);
INSERT INTO `instance_entities` VALUES (18315, 17526852);
INSERT INTO `instance_entities` VALUES (18315, 17526853);
INSERT INTO `instance_entities` VALUES (18315, 17526854);
INSERT INTO `instance_entities` VALUES (18315, 17526855);
INSERT INTO `instance_entities` VALUES (18315, 17526856);
INSERT INTO `instance_entities` VALUES (18315, 17526857);
INSERT INTO `instance_entities` VALUES (18315, 17526858);
INSERT INTO `instance_entities` VALUES (18315, 17526859);
INSERT INTO `instance_entities` VALUES (18315, 17526860);
INSERT INTO `instance_entities` VALUES (18315, 17526861);
INSERT INTO `instance_entities` VALUES (18315, 17526862);

-- Circuit 50 Alpha (instance 18316)
INSERT INTO `instance_entities` VALUES (18316, 17526863);
INSERT INTO `instance_entities` VALUES (18316, 17526864);
INSERT INTO `instance_entities` VALUES (18316, 17526865);
INSERT INTO `instance_entities` VALUES (18316, 17526866);
INSERT INTO `instance_entities` VALUES (18316, 17526867);
INSERT INTO `instance_entities` VALUES (18316, 17526868);
INSERT INTO `instance_entities` VALUES (18316, 17526869);
INSERT INTO `instance_entities` VALUES (18316, 17526875); -- Arbiter

-- Circuit 50 Beta (instance 18317)
INSERT INTO `instance_entities` VALUES (18317, 17526863);
INSERT INTO `instance_entities` VALUES (18317, 17526864);
INSERT INTO `instance_entities` VALUES (18317, 17526865);
INSERT INTO `instance_entities` VALUES (18317, 17526866);
INSERT INTO `instance_entities` VALUES (18317, 17526867);
INSERT INTO `instance_entities` VALUES (18317, 17526868);
INSERT INTO `instance_entities` VALUES (18317, 17526869);
INSERT INTO `instance_entities` VALUES (18317, 17526870);
INSERT INTO `instance_entities` VALUES (18317, 17526871);
INSERT INTO `instance_entities` VALUES (18317, 17526872);
INSERT INTO `instance_entities` VALUES (18317, 17526873);
INSERT INTO `instance_entities` VALUES (18317, 17526875); -- Arbiter

-- Circuit 50 Gamma (instance 18318)
INSERT INTO `instance_entities` VALUES (18318, 17526863);
INSERT INTO `instance_entities` VALUES (18318, 17526864);
INSERT INTO `instance_entities` VALUES (18318, 17526865);
INSERT INTO `instance_entities` VALUES (18318, 17526866);
INSERT INTO `instance_entities` VALUES (18318, 17526867);
INSERT INTO `instance_entities` VALUES (18318, 17526868);
INSERT INTO `instance_entities` VALUES (18318, 17526869);
INSERT INTO `instance_entities` VALUES (18318, 17526870);
INSERT INTO `instance_entities` VALUES (18318, 17526871);
INSERT INTO `instance_entities` VALUES (18318, 17526872);
INSERT INTO `instance_entities` VALUES (18318, 17526873);
INSERT INTO `instance_entities` VALUES (18318, 17526874);
INSERT INTO `instance_entities` VALUES (18318, 17526875);

-- Circuit 60 Alpha (instance 18319)
INSERT INTO `instance_entities` VALUES (18319, 17526876);
INSERT INTO `instance_entities` VALUES (18319, 17526877);
INSERT INTO `instance_entities` VALUES (18319, 17526878);
INSERT INTO `instance_entities` VALUES (18319, 17526879);
INSERT INTO `instance_entities` VALUES (18319, 17526880);
INSERT INTO `instance_entities` VALUES (18319, 17526881);
INSERT INTO `instance_entities` VALUES (18319, 17526882);
INSERT INTO `instance_entities` VALUES (18319, 17526888); -- Arbiter

-- Circuit 60 Beta (instance 18320)
INSERT INTO `instance_entities` VALUES (18320, 17526876);
INSERT INTO `instance_entities` VALUES (18320, 17526877);
INSERT INTO `instance_entities` VALUES (18320, 17526878);
INSERT INTO `instance_entities` VALUES (18320, 17526879);
INSERT INTO `instance_entities` VALUES (18320, 17526880);
INSERT INTO `instance_entities` VALUES (18320, 17526881);
INSERT INTO `instance_entities` VALUES (18320, 17526882);
INSERT INTO `instance_entities` VALUES (18320, 17526883);
INSERT INTO `instance_entities` VALUES (18320, 17526884);
INSERT INTO `instance_entities` VALUES (18320, 17526885);
INSERT INTO `instance_entities` VALUES (18320, 17526886);
INSERT INTO `instance_entities` VALUES (18320, 17526888); -- Arbiter

-- Circuit 60 Gamma (instance 18321)
INSERT INTO `instance_entities` VALUES (18321, 17526876);
INSERT INTO `instance_entities` VALUES (18321, 17526877);
INSERT INTO `instance_entities` VALUES (18321, 17526878);
INSERT INTO `instance_entities` VALUES (18321, 17526879);
INSERT INTO `instance_entities` VALUES (18321, 17526880);
INSERT INTO `instance_entities` VALUES (18321, 17526881);
INSERT INTO `instance_entities` VALUES (18321, 17526882);
INSERT INTO `instance_entities` VALUES (18321, 17526883);
INSERT INTO `instance_entities` VALUES (18321, 17526884);
INSERT INTO `instance_entities` VALUES (18321, 17526885);
INSERT INTO `instance_entities` VALUES (18321, 17526886);
INSERT INTO `instance_entities` VALUES (18321, 17526887);
INSERT INTO `instance_entities` VALUES (18321, 17526888);
