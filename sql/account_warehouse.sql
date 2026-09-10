SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `account_warehouse`
--
-- An account-wide, effectively unlimited item stash (the mwarehouse addon).
-- One row per stack: stackable plain items merge into an existing row, while
-- augmented / signed / charged items always get their own row. Any character
-- on the account may deposit to or withdraw from it. Rows are ordered by rowid.
--

DROP TABLE IF EXISTS `account_warehouse`;
CREATE TABLE IF NOT EXISTS `account_warehouse` (
  `rowid`     int(10) unsigned    NOT NULL AUTO_INCREMENT,
  `accid`     int(10) unsigned    NOT NULL,
  `itemId`    smallint(5) unsigned NOT NULL DEFAULT 0,
  `quantity`  int(10) unsigned    NOT NULL DEFAULT 0,
  `signature` varchar(20)         NOT NULL DEFAULT '',
  `extra`     blob(24)            DEFAULT NULL,
  PRIMARY KEY (`rowid`),
  KEY `accid` (`accid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Structure de la table `account_warehouse_meta`
--
-- Per-account monotonic generation counter, bumped on every warehouse write so
-- a client can tell when another session changed the stash and repage.
--

DROP TABLE IF EXISTS `account_warehouse_meta`;
CREATE TABLE IF NOT EXISTS `account_warehouse_meta` (
  `accid`      int(10) unsigned NOT NULL,
  `generation` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`accid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
