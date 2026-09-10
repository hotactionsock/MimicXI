SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `char_mimic_active`
--

DROP TABLE IF EXISTS `char_mimic_active`;
CREATE TABLE IF NOT EXISTS `char_mimic_active` (
  `charid` int(10) unsigned NOT NULL,
  `master_charid` int(10) unsigned NOT NULL,
  `spawned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
