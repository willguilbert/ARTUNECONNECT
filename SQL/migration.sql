-- Drop FK sur T,N et S
ALTER TABLE Utilisateur MODIFY mot_de_passe varchar(64);
ALTER TABLE `Transaction` DROP FOREIGN KEY Transaction_ibfk_2;
ALTER TABLE Noter DROP FOREIGN KEY Noter_ibfk_1;
ALTER TABLE Suivre DROP FOREIGN KEY Suivre_ibfk_1;
-- Alter user table
ALTER TABLE Utilisateur MODIFY id_utilisateur INTEGER AUTO_INCREMENT;

-- Re-add FKs
ALTER TABLE `Transaction` ADD CONSTRAINT `Transaction_ibfk_2` FOREIGN KEY (`id_utilisateur`) REFERENCES Utilisateur(id_utilisateur);
ALTER TABLE `Noter` ADD CONSTRAINT `Noter_ibfk_1` FOREIGN KEY (`id_utilisateur`) REFERENCES Utilisateur(id_utilisateur);
ALTER TABLE `Suivre` ADD CONSTRAINT `Suivre_ibfk_1` FOREIGN KEY (`id_utilisateur`) REFERENCES Utilisateur(id_utilisateur);