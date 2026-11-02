SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `world_bot_memory`
--
-- What each AI world bot has learned from experience (see
-- src/map/utils/botmemory.h): deaths and successes per thing it tried.
--   kind - 1 zone (was there), 2 route (on the way to this zone),
--          3 camp (zone << 16 | 40-yalm grid cell), 4 NM (mob id)
--   ref  - what it refers to, per kind
--   death_level - the bot's level at its last death there (old deaths fade
--          once the bot has outlevelled them)
--

DROP TABLE IF EXISTS `world_bot_memory`;
CREATE TABLE IF NOT EXISTS `world_bot_memory` (
  `charid`       int(10) unsigned     NOT NULL,
  `kind`         tinyint(3) unsigned  NOT NULL,
  `ref`          int(10) unsigned     NOT NULL,
  `deaths`       smallint(5) unsigned NOT NULL DEFAULT 0,
  `successes`    smallint(5) unsigned NOT NULL DEFAULT 0,
  `exp`          int(10) unsigned     NOT NULL DEFAULT 0,
  `last_death`   int(10) unsigned     NOT NULL DEFAULT 0,
  `last_success` int(10) unsigned     NOT NULL DEFAULT 0,
  `death_level`  tinyint(3) unsigned  NOT NULL DEFAULT 0,
  PRIMARY KEY (`charid`, `kind`, `ref`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
