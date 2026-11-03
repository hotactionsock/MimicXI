SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Structure de la table `world_bot_ah`
--
-- What each world bot remembers about selling on the Auction House: items
-- that went unsold (expired or taken down), how many times and when last.
-- Unsold items drop down its selling priority; a common drop that keeps
-- failing is vendored or tossed instead (scripts/globals/worldbots_ah.lua).
-- Cleared for an item when it sells.
--

DROP TABLE IF EXISTS `world_bot_ah`;
CREATE TABLE IF NOT EXISTS `world_bot_ah` (
  `charid`    int(10) unsigned     NOT NULL,
  `itemid`    smallint(5) unsigned NOT NULL,
  `fails`     tinyint(3) unsigned  NOT NULL DEFAULT 0,
  `last_fail` int(10) unsigned     NOT NULL DEFAULT 0,
  PRIMARY KEY (`charid`, `itemid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
