SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `world_bots`
--
-- Registry of AI-driven world-population bot characters (see
-- src/map/utils/botutils.h). One row per bot character - the character
-- itself lives in the normal `chars`/`char_*` tables on a throwaway account.
--   active   - 1 = should be in the world: respawned automatically when the
--              map server starts. 0 = parked (despawned by a GM).
--   anchor_* - centre of the bot's loiter area, in its current zone.
--   career_job - the main job this bot is working towards for life (xi.job id;
--              0 = not chosen yet). It may level a basic job or a subjob first
--              (see scripts/globals/worldbots_jobs.lua).
--   logged_out_until - between play sessions: the bot is logged off until this
--              unix time, then logs back in where it left (0 = online / due).
--   ah_purse - gil the bot may spend on the Auction House: credited only by
--              its AH sales and vendor sales of loot (bots carry the gil cap
--              for vendors, so AH money is kept apart - see botauction.h).
--

DROP TABLE IF EXISTS `world_bots`;
CREATE TABLE IF NOT EXISTS `world_bots` (
  `charid`   int(10) unsigned    NOT NULL,
  `active`   tinyint(1) unsigned NOT NULL DEFAULT 0,
  `anchor_x` float(7,3)          NOT NULL DEFAULT 0,
  `anchor_y` float(7,3)          NOT NULL DEFAULT 0,
  `anchor_z` float(7,3)          NOT NULL DEFAULT 0,
  `career_job` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `logged_out_until` int(10) unsigned NOT NULL DEFAULT 0,
  `ah_purse` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`charid`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
