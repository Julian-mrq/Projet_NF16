-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : dim. 11 déc. 2022 à 14:25
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
-- Base de données : `biblio2_utt`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `Pret`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Pret` (IN `num` INT(1), IN `code` INT(1))  BEGIN
DECLARE nb_jour INT;
DECLARE nb_ouvrage INT;
# en fonction de sa catégorie d’usager
# on trouve la durée possible d’emprunt en fonction de la catégorie de l’usager
SET nb_jour = (SELECT categorie.nb_jours_max FROM categorie, usager
			WHERE num = usager.num AND usager.categorie = categorie.categorie);
# on trouve le nombre d’emprunt possible en fonction de la catégorie de l’usager
SET nb_ouvrage = (SELECT categorie.nb_ouvrages_max FROM categorie, usager
			WHERE num = usager.num AND usager.categorie = categorie.categorie);
	
    #s'il n'y a pas de retard et que l'usager peut encore emprunter un ouvrage
IF nb_jour >= ALL (SELECT DATEDIFF (DATE(NOW()), emprunte.date_emprunt) FROM emprunte, usager WHERE num = usager.num AND usager.num = emprunte.num) AND nb_ouvrage > (SELECT count(*) FROM emprunte, usager WHERE num = usager.num AND usager.num = emprunte.num)
#on insère le tuple dans emprunte
               		 THEN  INSERT INTO emprunte (code_ouvrage_emprunte, date_emprunt, date_retour,num) VALUES (code, DATE(NOW()), DATE_ADD(DATE(NOW()), INTERVAL nb_jour  DAY),num); 
                     # on met à jour le nb d'exemplaires
        UPDATE ouvrage
		SET nb_exemplaire = nb_exemplaire -1
        WHERE code = ouvrage.code;
        #sinon, on affiche une erreur en fonction de la condition non respectée
                ELSEIF nb_jour < ALL (SELECT DATEDIFF (DATE(NOW()), emprunte.date_emprunt) FROM emprunte, usager WHERE num = usager.num AND usager.num = emprunte.num)
THEN 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "l’usager a au moins un retard";
ELSE 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "l’usager a atteint le nombre maximal d’ouvrages qu’il pouvait emprunter";
	
                END IF;
              

END$$

DROP PROCEDURE IF EXISTS `SelectClientsRetard`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SelectClientsRetard` (IN `X` INT)  BEGIN
#on affiche les usagers ayant une date de retour égale à la date actuelle + le nombre de jours choisi en paramètre
SELECT * FROM usager, emprunte WHERE usager.num = emprunte.num AND (SELECT DATE_ADD(DATE(NOW()), INTERVAL X DAY))  = emprunte.date_retour;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `biblio`
--

DROP TABLE IF EXISTS `biblio`;
CREATE TABLE IF NOT EXISTS `biblio` (
  `code_b` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(50) NOT NULL,
  PRIMARY KEY (`code_b`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `biblio`
--

INSERT INTO `biblio` (`code_b`, `nom`) VALUES
(1, 'utt');

-- --------------------------------------------------------

--
-- Structure de la table `categorie`
--

DROP TABLE IF EXISTS `categorie`;
CREATE TABLE IF NOT EXISTS `categorie` (
  `categorie` int(11) NOT NULL AUTO_INCREMENT,
  `nb_jours_max` int(11) NOT NULL,
  `nb_ouvrages_max` int(11) NOT NULL,
  PRIMARY KEY (`categorie`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `categorie`
--

INSERT INTO `categorie` (`categorie`, `nb_jours_max`, `nb_ouvrages_max`) VALUES
(1, 10, 3),
(2, 15, 5),
(3, 20, 6);

-- --------------------------------------------------------

--
-- Structure de la table `emprunte`
--

DROP TABLE IF EXISTS `emprunte`;
CREATE TABLE IF NOT EXISTS `emprunte` (
  `code_ouvrage_emprunte` int(20) NOT NULL,
  `date_emprunt` date NOT NULL,
  `date_retour` date NOT NULL,
  `num` int(20) NOT NULL,
  PRIMARY KEY (`code_ouvrage_emprunte`,`date_emprunt`,`num`),
  KEY `fk_num` (`num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `emprunte`
--

INSERT INTO `emprunte` (`code_ouvrage_emprunte`, `date_emprunt`, `date_retour`, `num`) VALUES
(1, '2022-12-02', '2022-12-17', 2),
(1, '2022-12-10', '2022-12-20', 4),
(1, '2022-12-10', '2022-12-25', 5),
(5, '2022-12-01', '2022-12-11', 4),
(11, '2022-12-03', '2022-12-23', 3),
(12, '2022-12-08', '2022-12-18', 1),
(22, '2022-12-08', '2022-12-18', 1);

--
-- Déclencheurs `emprunte`
--
DROP TRIGGER IF EXISTS `check_stock`;
DELIMITER $$
CREATE TRIGGER `check_stock` BEFORE INSERT ON `emprunte` FOR EACH ROW BEGIN

DECLARE nb INT;

SET nb = (SELECT nb_exemplaire FROM ouvrage WHERE code=ouvrage.code);
IF nb < 1 
THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT="Plus d'exemplaires en stock..."; 
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `enregistre`
--

DROP TABLE IF EXISTS `enregistre`;
CREATE TABLE IF NOT EXISTS `enregistre` (
  `code` int(20) NOT NULL,
  `id` int(20) NOT NULL,
  `code_b` int(20) NOT NULL,
  `recu_ok` tinyint(1) NOT NULL,
  PRIMARY KEY (`code`,`id`,`code_b`),
  KEY `fk_code_b` (`code_b`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `enregistre`
--

INSERT INTO `enregistre` (`code`, `id`, `code_b`, `recu_ok`) VALUES
(1, 1, 1, 1),
(2, 2, 1, 1),
(3, 3, 1, 1),
(4, 4, 1, 1),
(5, 5, 1, 1),
(6, 6, 1, 1),
(7, 7, 1, 1),
(8, 8, 1, 1),
(9, 9, 1, 1),
(10, 10, 1, 1),
(11, 11, 1, 1),
(12, 12, 1, 1),
(13, 13, 1, 1),
(14, 14, 1, 1),
(15, 15, 1, 1),
(16, 16, 1, 1),
(17, 17, 1, 1),
(18, 18, 1, 1),
(19, 19, 1, 1),
(20, 20, 1, 1),
(21, 21, 1, 1),
(22, 22, 1, 1),
(23, 23, 1, 1),
(24, 24, 1, 1),
(25, 25, 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `ouvrage`
--

DROP TABLE IF EXISTS `ouvrage`;
CREATE TABLE IF NOT EXISTS `ouvrage` (
  `code` int(20) NOT NULL AUTO_INCREMENT,
  `nb_exemplaire` int(20) NOT NULL,
  `date_reception` date NOT NULL,
  `code_b` int(20) NOT NULL,
  `titre` varchar(60) NOT NULL,
  `editeur` varchar(50) NOT NULL,
  `auteur` varchar(50) NOT NULL,
  PRIMARY KEY (`code`),
  KEY `code_b` (`code_b`,`titre`,`editeur`,`auteur`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `ouvrage`
--

INSERT INTO `ouvrage` (`code`, `nb_exemplaire`, `date_reception`, `code_b`, `titre`, `editeur`, `auteur`) VALUES
(1, 3, '2022-12-01', 1, 'Vivre vite', 'Editions Flammarion', 'Brigitte Giraud'),
(2, 5, '2021-09-05', 1, 'La plus secrète mémoire des hommes', 'Editions Philippe Rey et Jimsaan', 'Mohamed Mbougar Sarr'),
(3, 3, '2021-01-23', 1, 'L\'Anomalie', 'Editions Gallimard', 'Hervé Le Tellier'),
(4, 2, '2020-03-16', 1, 'Tous les hommes n\'habitent pas le monde de la même façon', 'Editions de l\'Olivier', 'Jean-Paul Dubois'),
(5, 10, '2018-11-26', 1, 'Leurs enfants après eux', 'Actes Sud', 'Nicolas Mathieu'),
(6, 8, '2017-10-17', 1, 'L\'ordre du jour', 'Actes Sud', 'Éric Vuillard'),
(7, 6, '2017-04-11', 1, 'Chanson douce', 'Editions Gallimard', 'Leïla Slimani'),
(8, 6, '2015-09-08', 1, 'Boussole', 'Actes Sud', 'Mathias Enard'),
(9, 7, '2014-12-02', 1, 'Pas pleurer', 'Editions du Seuil', 'Lydie Salvayre'),
(10, 6, '2014-05-26', 1, 'Au revoir là-haut', 'Editions Albin Michel', 'Pierre Lemaitre'),
(11, 8, '2012-11-06', 1, 'Le sermon sur la chute de Rome', 'Actes Sud', 'Jérôme Ferrari'),
(12, 8, '2011-12-16', 1, 'L\'Art Français de la Guerre', 'Editions Gallimard', 'Alexis Jenni'),
(13, 2, '2011-02-12', 1, 'La carte et le territoire', 'Editions Flammarion', 'Michel Houellebecq'),
(14, 6, '2009-12-14', 1, 'Trois femmes puissantes', 'Edtions Gallimard', 'Marie NDiaye'),
(15, 8, '2009-09-14', 1, 'Syngué Sabour : Pierre de patience', 'Editions Feryane', 'Atiq Rahimi'),
(16, 6, '2007-12-13', 1, 'Alabama Song', 'Edtions du Mercure de France', 'Gilles Leroy'),
(17, 8, '2006-11-23', 1, 'Les Bienveillantes', 'Editions Gallimard', 'Jonathan Littell'),
(18, 2, '2005-12-22', 1, 'Trois jours chez ma mère', 'Editions Grasset', 'François Weyergans'),
(19, 8, '2004-10-31', 1, 'Le Soleil des Scorta', 'Actes Sud', 'Laurent Gaudé'),
(20, 4, '2003-12-11', 1, 'La Maîtresse de Brecht', 'Editions Albin Michel', 'Jacques-Pierre Amette'),
(21, 1, '2002-12-28', 1, 'Les ombres errantes', 'Editions Grasset', 'Pascal Quignard'),
(22, 3, '2001-11-30', 1, 'Rouge Brésil', 'Editions Gallimard', 'Jean-Christophe Rufin'),
(23, 6, '2000-12-12', 1, 'Ingrid Caven', 'Editions Gallimard', 'Jean-Jacques Schuhl'),
(24, 8, '1999-12-09', 1, 'Je m\'en vais', 'Editions de Minuit', 'Jean Echenoz'),
(25, 7, '1998-11-26', 1, 'Confidence pour confidence', 'Editions Gallimard', 'Paule Constant');

-- --------------------------------------------------------

--
-- Structure de la table `suggestion`
--

DROP TABLE IF EXISTS `suggestion`;
CREATE TABLE IF NOT EXISTS `suggestion` (
  `id` int(20) NOT NULL AUTO_INCREMENT,
  `état` varchar(50) NOT NULL,
  `qte` int(20) NOT NULL,
  `num` int(20) NOT NULL,
  `titre` varchar(50) NOT NULL,
  `auteur` varchar(50) NOT NULL,
  `editeur` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `num` (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `suggestion`
--

INSERT INTO `suggestion` (`id`, `état`, `qte`, `num`, `titre`, `auteur`, `editeur`) VALUES
(26, 'en cours de traitement', 1, 2, 'La Bataille', 'Patrick Rambaud', 'Editions Grasset'),
(27, 'refusé', 2, 3, 'Le Chasseur zÃ©ro', 'Pascale Roze', 'Editions Albin Michel'),
(28, 'validé', 3, 4, 'Le testament français', 'Andreï Makine', 'Editions Gallimard'),
(29, 'commandé', 4, 5, 'Un aller simple', 'Didier Van Cauwelaert', 'Editions Albin Michel');

-- --------------------------------------------------------

--
-- Structure de la table `usager`
--

DROP TABLE IF EXISTS `usager`;
CREATE TABLE IF NOT EXISTS `usager` (
  `nss` int(20) NOT NULL,
  `num` int(20) NOT NULL AUTO_INCREMENT,
  `nom` varchar(20) NOT NULL,
  `categorie` int(20) NOT NULL,
  PRIMARY KEY (`num`),
  KEY `fk_categorie` (`categorie`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `usager`
--

INSERT INTO `usager` (`nss`, `num`, `nom`, `categorie`) VALUES
(123, 1, 'Bush', 1),
(456, 2, 'Smith', 2),
(789, 3, 'Orwell', 3),
(147, 4, 'Luna', 1),
(258, 5, 'Mcfee', 2);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `emprunte`
--
ALTER TABLE `emprunte`
  ADD CONSTRAINT `fk_code` FOREIGN KEY (`code_ouvrage_emprunte`) REFERENCES `ouvrage` (`code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_num` FOREIGN KEY (`num`) REFERENCES `usager` (`num`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `enregistre`
--
ALTER TABLE `enregistre`
  ADD CONSTRAINT `fk_code_b` FOREIGN KEY (`code_b`) REFERENCES `biblio` (`code_b`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_codeouvrage` FOREIGN KEY (`code`) REFERENCES `ouvrage` (`code`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `ouvrage`
--
ALTER TABLE `ouvrage`
  ADD CONSTRAINT `fk_biblio` FOREIGN KEY (`code_b`) REFERENCES `biblio` (`code_b`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `suggestion`
--
ALTER TABLE `suggestion`
  ADD CONSTRAINT `fk_num_usager` FOREIGN KEY (`num`) REFERENCES `usager` (`num`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `usager`
--
ALTER TABLE `usager`
  ADD CONSTRAINT `fk_categorie` FOREIGN KEY (`categorie`) REFERENCES `categorie` (`categorie`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
