SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Structure de la table `world_bot_ah_prices`
--
-- Manual Auction House prices for world bots - the server owner's say. Any
-- price here beats the bots' own estimate and the market's sale history.
--   price_single / price_stacks - the price to aim for (0 = no override: use
--                  the bots' estimate / the market)
--   allow        - 0 = bots never list this item
-- Set with `!worldbot ahprice`, or load an ffxiahbot-format CSV with
-- tools/worldbots_ah_prices.py. See src/map/utils/botauction.h.
--

CREATE TABLE IF NOT EXISTS `world_bot_ah_prices` (
  `itemid`       smallint(5) unsigned NOT NULL,
  `price_single` int(10) unsigned     NOT NULL DEFAULT 0,
  `price_stacks` int(10) unsigned     NOT NULL DEFAULT 0,
  `allow`        tinyint(1) unsigned  NOT NULL DEFAULT 1,
  `updated`      int(10) unsigned     NOT NULL DEFAULT 0,
  PRIMARY KEY (`itemid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
