SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `account_bank`
--
-- Account-wide, uncapped item storage shared by every character on an account.
-- v1 scope: stackable, non-equipment items only (see bankutils::IsBankable) --
-- one row per (accid, itemid), quantity merges without any stack-size cap.
--

DROP TABLE IF EXISTS `account_bank`;
CREATE TABLE IF NOT EXISTS `account_bank` (
  `accid` int(10) unsigned NOT NULL,
  `itemid` smallint(5) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL DEFAULT '0',

  PRIMARY KEY (`accid`,`itemid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
