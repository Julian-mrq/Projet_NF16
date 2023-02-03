-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : lun. 14 nov. 2022 à 15:44
-- Version du serveur : 5.7.36
-- Version de PHP : 7.4.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `bati'troyes`
--

-- --------------------------------------------------------

--
-- Structure de la table `article`
--

DROP TABLE IF EXISTS `article`;
CREATE TABLE IF NOT EXISTS `article` (
  `numA` int(15) NOT NULL AUTO_INCREMENT,
  `Référence` varchar(20) NOT NULL,
  `prixUnit` int(15) NOT NULL,
  PRIMARY KEY (`numA`),
  KEY `Référence` (`Référence`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `article`
--

INSERT INTO `article` (`numA`, `Référence`, `prixUnit`) VALUES
(1, 'M240', 11),
(2, 'M330', 12),
(3, 'M818', 45),
(4, 'ERr5521', 40),
(5, 'ETr5524', 10),
(6, 'ETr2020', 8),
(7, 'ETr1281', 9),
(8, 'Sp1125', 68),
(9, 'Gil123200', 11),
(10, 'Gil752000', 44),
(11, 'Gil210300', 4),
(12, 'ETr1225', 13),
(13, 'ETr1000', 24),
(14, 'ETr5521', 78),
(15, 'ETr2112', 32),
(16, 'M331', 55),
(17, 'M114', 2),
(18, 'M550', 2),
(19, 'M810', 24),
(20, 'Gil220180', 16),
(21, 'Gil222000', 21),
(22, 'Gil222100', 25),
(23, 'Gil222200', 2);

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

DROP TABLE IF EXISTS `commande`;
CREATE TABLE IF NOT EXISTS `commande` (
  `numCommande` int(11) NOT NULL AUTO_INCREMENT,
  `Date` date NOT NULL,
  `Montant` float DEFAULT NULL,
  `Chantier` varchar(20) DEFAULT NULL,
  `numF` tinyint(5) NOT NULL,
  PRIMARY KEY (`numCommande`),
  KEY `clé étrangère numF` (`numF`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`numCommande`, `Date`, `Montant`, `Chantier`, `numF`) VALUES
(1, '2021-07-03', 12800, 'Beaugeron', 1),
(2, '2021-07-05', 13500, 'Gauguin', 2),
(3, '2021-07-05', 8700, 'Gauguin', 2),
(4, '2021-07-06', 1400, 'Lampion', 3),
(5, '2021-07-06', 200, 'Beaugeron', 3),
(6, '2021-07-09', 800, 'Lampion', 3),
(7, '2021-07-11', 3500, 'Beaugeron', 2),
(8, '2021-07-16', 7600, 'Beaugeron', 1),
(9, '2021-07-18', 2000, 'Gauguin', 2),
(10, '2021-10-19', 38200, 'Beaugeron', 1),
(11, '2021-07-20', 1500, 'Lampion', 3),
(12, '2021-07-24', 1200, 'Lampion', 3),
(13, '2021-09-05', 250, 'Lampion', 1);

-- --------------------------------------------------------

--
-- Structure de la table `fournisseur`
--

DROP TABLE IF EXISTS `fournisseur`;
CREATE TABLE IF NOT EXISTS `fournisseur` (
  `numF` tinyint(5) NOT NULL AUTO_INCREMENT,
  `nomF` varchar(20) NOT NULL,
  PRIMARY KEY (`numF`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `fournisseur`
--

INSERT INTO `fournisseur` (`numF`, `nomF`) VALUES
(1, 'Matelec10'),
(2, 'Elec Troyes'),
(3, 'Tuyau-Gil');

-- --------------------------------------------------------

--
-- Structure de la table `lignecommande`
--

DROP TABLE IF EXISTS `lignecommande`;
CREATE TABLE IF NOT EXISTS `lignecommande` (
  `numCommande` int(11) NOT NULL,
  `numLigne` int(11) NOT NULL,
  `article` varchar(20) NOT NULL,
  `quantite` int(11) NOT NULL,
  `fournisseur` varchar(20) NOT NULL,
  PRIMARY KEY (`numCommande`,`numLigne`),
  KEY `lignecommande.article = article.reference` (`article`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `lignecommande`
--

INSERT INTO `lignecommande` (`numCommande`, `numLigne`, `article`, `quantite`, `fournisseur`) VALUES
(1, 1, 'M240', 2, 'Matelec10'),
(1, 2, 'M330', 1, 'Matelec10'),
(1, 3, 'M818', 520, 'Matelec10'),
(2, 1, 'ERr5521', 12, 'Elec Troyes '),
(2, 2, 'ETr5524', 32, 'Elec Troyes '),
(2, 3, 'ETr2020', 1, 'Elec Troyes '),
(2, 4, 'ETr1281', 2, 'Elec Troyes '),
(3, 1, 'Sp1125', 1, 'Elec Troyes'),
(4, 1, 'Gil123200', 140, 'Tuyau-Gil'),
(5, 1, 'Gil123200', 20, 'Tuyau-Gil'),
(6, 1, 'Gil752000', 4, 'Tuyau-Gil'),
(6, 2, 'Gil210300', 3, 'Tuyau-Gil'),
(7, 1, 'ETr1225', 4, 'Elec Troyes'),
(7, 2, 'ETr1000', 1, 'Elec Troyes'),
(8, 1, 'M818', 240, 'Matelec10'),
(9, 1, 'ETr5521', 14, 'Elec Troyes'),
(9, 2, 'ETr2112', 2, 'Elec Troyes'),
(10, 1, 'M331', 4, 'Matelec10'),
(10, 2, 'M114', 22, 'Matelec10'),
(10, 3, 'M550', 1, 'Matelec10'),
(10, 4, 'M810', 3, 'Matelec10'),
(11, 1, 'Gil220180', 1, 'Tuyau-Gil'),
(11, 2, 'Gil123200', 128, 'Tuyau-Gil'),
(12, 1, 'Gil222000', 1, 'Tuyau-Gil'),
(12, 2, 'Gil222100', 14, 'Tuyau-Gil'),
(12, 3, 'Gil222200', 14, 'Tuyau-Gil'),
(13, 5, 'ETr2020', 3, 'Matelec10');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `clé étrangère numCommande` FOREIGN KEY (`numCommande`) REFERENCES `lignecommande` (`numCommande`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `clé étrangère numF` FOREIGN KEY (`numF`) REFERENCES `fournisseur` (`numF`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `lignecommande`
--
ALTER TABLE `lignecommande`
  ADD CONSTRAINT `fk_lignecommande_commande` FOREIGN KEY (`numCommande`) REFERENCES `commande` (`numCommande`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `lignecommande.article = article.reference` FOREIGN KEY (`article`) REFERENCES `article` (`Référence`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
