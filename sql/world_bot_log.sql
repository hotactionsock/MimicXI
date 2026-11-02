SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `world_bot_log`
--
-- Activity log of AI world bots (see src/map/utils/botlog.h): one row per
-- thing a bot did, for showing each bot's life story on a website.
--   charid   - the bot (rows are kept after a bot is deleted, as history)
--   ts       - Unix time
--   zone_id  - where it was (0 = not in the world)
--   category - lifecycle, level, job, gear, item, magic, travel, party, combat, death
--   event    - stable key for the website (level_up, obtained, sold, ...)
--   message  - ready-to-show sentence ("Testbot learned Cure")
--   data     - the same facts as a JSON object (item ids, levels, zone ids...)
-- Pruned after map.WORLDBOTS_LOG_RETENTION_DAYS.
--

DROP TABLE IF EXISTS `world_bot_log`;
CREATE TABLE IF NOT EXISTS `world_bot_log` (
  `id`       bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `charid`   int(10) unsigned    NOT NULL,
  `ts`       int(10) unsigned    NOT NULL,
  `zone_id`  smallint(5) unsigned NOT NULL DEFAULT 0,
  `category` varchar(16)         NOT NULL,
  `event`    varchar(32)         NOT NULL,
  `message`  varchar(255)        NOT NULL,
  `data`     text                NOT NULL,
  PRIMARY KEY (`id`),
  KEY `charid_ts` (`charid`, `ts`),
  KEY `ts` (`ts`),
  KEY `category_ts` (`category`, `ts`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
