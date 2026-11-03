SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Live view of world bots for the website (tools/web_creator watch.html),
-- see src/map/utils/botwatch.h.
--
-- world_bot_watch - bots someone is watching: the website refreshes until_ts
--                   every few seconds while the page is open.
-- world_bot_live  - the latest snapshot of each watched bot, written every
--                   couple of seconds by the map engine (JSON: position,
--                   HP/MP/TP, state, target, mobs and characters nearby, zone
--                   lines). Rows go stale once nobody watches.
--

CREATE TABLE IF NOT EXISTS `world_bot_watch` (
  `charid`   int(10) unsigned NOT NULL,
  `until_ts` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `world_bot_live` (
  `charid`  int(10) unsigned     NOT NULL,
  `ts`      int(10) unsigned     NOT NULL DEFAULT 0,
  `zone_id` smallint(5) unsigned NOT NULL DEFAULT 0,
  `data`    mediumtext           NOT NULL,
  PRIMARY KEY (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
