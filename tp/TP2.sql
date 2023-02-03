-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : sam. 26 nov. 2022 à 11:15
-- Version du serveur :  5.7.31
-- Version de PHP : 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `entreprise`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `stock`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `stock` (IN `numcom` INT)  BEGIN
DECLARE stock FLOAT;

SET stock =(SELECT produit.qtestock - detail.qtecom FROM detail, produit
WHERE detail.numpro = produit.numpro AND detail.numcom=numcom);
IF stock<=0 
THEN 
SELECT 'Attention fin de stock';
END IF;

END$$

DROP PROCEDURE IF EXISTS `SupprimerCommande`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SupprimerCommande` (IN `nom` VARCHAR(32))  NO SQL
BEGIN
DECLARE stock FLOAT;
IF client.nom = nom
THEN
UPDATE produit
SET qtestock=(qtestock + (SELECT qtecom FROM detail, commande, client WHERE Detail.numcom=commande.numcom AND commande.numcli= client.numcli AND client.nom=nom));

DELETE FROM detail
WHERE Detail.numcom=commande.numcom AND commande.numcli= client.numcli AND client.nom=nom;

DELETE FROM commande WHERE Detail.numcom=commande.numcom AND commande.numcli= client.numcli AND client.nom=nom;
END IF;
END$$

--
-- Fonctions
--
DROP FUNCTION IF EXISTS `fnclient`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `fnclient` (`numcli` INT(10)) RETURNS FLOAT NO SQL
BEGIN
	DECLARE montant FLOAT;

if numcli is null 
then
return -1 ;
end if;

    set montant = (SELECT sum(detail.qtecom*produit.prix) FROM detail, produit, commande, client
    WHERE Client.numcli =commande.numcli AND
    Commande.numcom = detail.numcom AND
    Produit.numpro=detail.numpro
    and client.numcli=numcli ) ;
    RETURN montant;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

DROP TABLE IF EXISTS `client`;
CREATE TABLE IF NOT EXISTS `client` (
  `numcli` tinyint(4) NOT NULL,
  `nom` varchar(32) NOT NULL,
  `localite` varchar(30) NOT NULL,
  `cat` varchar(2) NOT NULL,
  `solde` float NOT NULL,
  PRIMARY KEY (`numcli`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`numcli`, `nom`, `localite`, `cat`, `solde`) VALUES
(1, 'Dupont', 'Madrid', 'C1', 4564560),
(2, 'Durant', 'Rennes', 'C2', 5498),
(3, 'Marsault', 'Toulouse', 'C2', 54545);

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

DROP TABLE IF EXISTS `commande`;
CREATE TABLE IF NOT EXISTS `commande` (
  `numcom` tinyint(4) NOT NULL,
  `numcli` tinyint(4) NOT NULL,
  `datecom` date NOT NULL,
  PRIMARY KEY (`numcom`),
  KEY `fk_commande_numcli` (`numcli`),
  KEY `numcom` (`numcom`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`numcom`, `numcli`, `datecom`) VALUES
(2, 3, '2019-10-08'),
(3, 3, '2019-11-06');

-- --------------------------------------------------------

--
-- Structure de la table `detail`
--

DROP TABLE IF EXISTS `detail`;
CREATE TABLE IF NOT EXISTS `detail` (
  `numcom` tinyint(4) NOT NULL,
  `numpro` tinyint(4) NOT NULL,
  `qtecom` int(11) NOT NULL,
  PRIMARY KEY (`numcom`,`numpro`),
  KEY `fk_detail_numpro` (`numpro`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `detail`
--

INSERT INTO `detail` (`numcom`, `numpro`, `qtecom`) VALUES
(2, 2, 127),
(3, 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

DROP TABLE IF EXISTS `produit`;
CREATE TABLE IF NOT EXISTS `produit` (
  `numpro` tinyint(4) NOT NULL,
  `designation` varchar(60) NOT NULL,
  `prix` float NOT NULL,
  `qtestock` int(11) NOT NULL,
  PRIMARY KEY (`numpro`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`numpro`, `designation`, `prix`, `qtestock`) VALUES
(1, 'tabouret', 35, 1099),
(2, 'chaise', 78, 106);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `fk-numcli` FOREIGN KEY (`numcli`) REFERENCES `client` (`numcli`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `detail`
--
ALTER TABLE `detail`
  ADD CONSTRAINT `fk_numcom` FOREIGN KEY (`numcom`) REFERENCES `commande` (`numcom`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
