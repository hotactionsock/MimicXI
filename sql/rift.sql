-- ===========================================================================
-- Rift System
-- Custom instanced content in Walk of Echoes, entered from Xarcabard.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- Instance definition
-- instance_zone = 182 (Walk of Echoes)  entrance_zone = 112 (Xarcabard)
-- Start position is the default WoE entry point; adjust with /pos if needed.
-- time_limit is in minutes.
-- ---------------------------------------------------------------------------
INSERT INTO `instance_list`
    (instanceid, instance_name, instance_zone, entrance_zone, time_limit,
     start_x, start_y, start_z, start_rot)
VALUES
    (18200, 'Rift', 182, 112, 30,
     -420.000, 14.000, -49.000, 192);

-- ---------------------------------------------------------------------------
-- Leaderboard
-- season increments on each monthly reset via GM command /riftseason.
-- Old records are preserved for history; leaderboard queries filter by season.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `rift_leaderboard` (
    `id`          INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    `char_id`     INT UNSIGNED      NOT NULL,
    `char_name`   VARCHAR(15)       NOT NULL,
    `tier`        TINYINT UNSIGNED  NOT NULL,
    `clear_time`  INT UNSIGNED      NOT NULL COMMENT 'elapsed seconds',
    `cleared_at`  DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `season`      SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `idx_season_tier_time` (`season`, `tier` DESC, `clear_time` ASC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Persistent season counter.
INSERT IGNORE INTO `server_variables` (`name`, `value`) VALUES ('RIFT_SEASON', 1);
