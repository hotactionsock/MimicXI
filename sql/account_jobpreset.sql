SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `account_jobpreset`
--
-- Named squad job lineups, one set of rows per (account, preset name). Each row
-- is "when this preset is used, this character's main/sub become mjob/sjob".
--

DROP TABLE IF EXISTS `account_jobpreset`;
CREATE TABLE IF NOT EXISTS `account_jobpreset` (
  `accid`  int(10) unsigned    NOT NULL,
  `name`   varchar(24)         NOT NULL,
  `charid` int(10) unsigned    NOT NULL,
  `mjob`   tinyint(2) unsigned NOT NULL DEFAULT 0,
  `sjob`   tinyint(2) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`accid`, `name`, `charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
