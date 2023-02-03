-- phpMyAdmin SQL Dump
-- version 4.9.7
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : ven. 02 déc. 2022 à 16:39
-- Version du serveur :  5.7.36
-- Version de PHP : 7.4.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
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
DECLARE nom VARCHAR(32);

UPDATE produit
SET qtestock=(qtestock + (SELECT qtecom FROM detail, commande, client WHERE detail.numcom=commande.numcom AND commande.numcli= client.numcli AND client.nom=nom))
                          WHERE nom IN (SELECT client.nom FROM client, commande, detail WHERE produit.numpro=detail.numpro AND detail.numcom=commande.numcom AND commande.numcli= client.numcli AND client.nom=nom);

DELETE FROM detail
WHERE detail.numcom IN (SELECT detail.numcom FROM detail, commande, client WHERE detail.numcom=commande.numcom AND commande.numcli= client.numcli AND client.nom=nom);

DELETE FROM commande WHERE commande.numcli IN(SELECT commande.numcli FROM commande, client WHERE commande.numcli=client.numcli AND client.nom=nom);
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
-- Doublure de structure pour la vue `comcli`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `comcli`;
CREATE TABLE IF NOT EXISTS `comcli` (
`numcli` tinyint(4)
,`datecom` date
,`numcom` tinyint(4)
,`montant` int(30)
);

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
  `montant` int(30) NOT NULL,
  PRIMARY KEY (`numcom`,`numpro`),
  KEY `fk_detail_numpro` (`numpro`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `detail`
--

INSERT INTO `detail` (`numcom`, `numpro`, `qtecom`, `montant`) VALUES
(2, 2, 127, 9906),
(3, 1, 1, 35);

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

-- --------------------------------------------------------

--
-- Structure de la vue `comcli`
--
DROP TABLE IF EXISTS `comcli`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `comcli`  AS SELECT `commande`.`numcli` AS `numcli`, `commande`.`datecom` AS `datecom`, `commande`.`numcom` AS `numcom`, `detail`.`montant` AS `montant` FROM ((`commande` join `client`) join `detail`) WHERE ((`commande`.`numcli` = `client`.`numcli`) AND (`commande`.`numcom` = `detail`.`numcom`)) ;

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

DELIMITER $$
--
-- Évènements
--
DROP EVENT `stock`$$
CREATE DEFINER=`root`@`localhost` EVENT `stock` ON SCHEDULE EVERY 1 MONTH STARTS '2022-12-02 17:03:43' ON COMPLETION NOT PRESERVE ENABLE DO SELECT numpro FROM produit WHERE qtestock <= 10$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
