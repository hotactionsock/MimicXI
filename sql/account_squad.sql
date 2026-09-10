SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `account_squad`
--
-- Persistent mimic-trust roster, one per account. Each row assigns one of the
-- account's own characters to a squad slot (1..N); `!squad call` summons the
-- rostered characters as mimic trusts.
--

DROP TABLE IF EXISTS `account_squad`;
CREATE TABLE IF NOT EXISTS `account_squad` (
  `accid`  int(10) unsigned    NOT NULL,
  `slot`   tinyint(1) unsigned NOT NULL,
  `charid` int(10) unsigned    NOT NULL,
  PRIMARY KEY (`accid`, `slot`),
  KEY `charid` (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
