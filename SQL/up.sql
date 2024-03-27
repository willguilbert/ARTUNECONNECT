/*-------------------------------------------SELECTS--------------------------------------------------*/

-- SELECT * FROM Album;
-- SELECT * FROM Artiste;
-- SELECT * FROM Chanson;
-- SELECT * FROM Merch;
-- SELECT * FROM Noter;
-- SELECT * FROM Produit;
-- SELECT * FROM Region;
-- SELECT * FROM Styles;
-- SELECT * FROM Suivre;
-- SELECT * FROM Tramsaction;
-- SELECT * FROM Universite;
-- SELECT * FROM Utilisateur;

/*-------------------------------------------DATABASE-------------------------------------------------*/


CREATE DATABASE IF NOT EXISTS ARTUNECONNECT;

USE ARTUNECONNECT;

/*-------------------------------------------CREATES--------------------------------------------------*/

-- Region
CREATE TABLE Region (
    id_region INTEGER AUTO_INCREMENT,
    nom VARCHAR(64),

    PRIMARY KEY (id_region)
);

-- Universite
CREATE TABLE Universite (
    id_universite INTEGER AUTO_INCREMENT,
    nom VARCHAR(64),
    id_region INTEGER,
    nombre_artistes INTEGER DEFAULT 0,
    photo_universite VARCHAR(256),

    PRIMARY KEY (id_universite),
    FOREIGN KEY (id_region) REFERENCES Region (id_region) ON DELETE SET NULL,
    CONSTRAINT CHK_nombreArtistes CHECK (nombre_artistes >= 0)
);

-- Utilisateur
CREATE TABLE Utilisateur (
    id_utilisateur INTEGER AUTO_INCREMENT,
    nom VARCHAR(32),
    prenom VARCHAR(32),
    email VARCHAR(64),
    mot_de_passe VARCHAR(64),
    age INTEGER,
    bio varchar(1024),
    liens_reseaux_sociaux VARCHAR(256),
    id_region INTEGER,

    PRIMARY KEY (id_utilisateur),
    FOREIGN KEY (id_region) REFERENCES Region (id_region) ON DELETE SET NULL,
    UNIQUE (email)
);

-- Artiste
CREATE TABLE Artiste (
    id_artiste INTEGER AUTO_INCREMENT,
    nom_artiste VARCHAR(32),
    email_artiste VARCHAR(64),
    biographie_artiste VARCHAR(1024),
    origine VARCHAR(32),
    id_universite INTEGER,
    nombre_followers INTEGER DEFAULT 0,
    photo_artiste VARCHAR(256),

    PRIMARY KEY (id_artiste),
    FOREIGN KEY (id_universite) REFERENCES Universite (id_universite) ON DELETE SET NULL,
    CONSTRAINT CHK_nombreFollowers CHECK (nombre_followers >= 0)
);

-- Styles
CREATE TABLE Styles (
    id_style INTEGER AUTO_INCREMENT,
    nom VARCHAR(32),

    PRIMARY KEY (id_style)
);

-- Produit
CREATE TABLE Produit (
    id_produit INTEGER AUTO_INCREMENT,
    prix REAL,

    PRIMARY KEY (id_produit)
);

-- Merch
CREATE TABLE Merch (
    id_merch INTEGER AUTO_INCREMENT,
    id_produit INTEGER DEFAULT NULL, -- null, changé apres le trigger
    nom_article VARCHAR(64),
    couleur CHAR(6), -- hexa
    taille ENUM ('XS', 'S', 'M', 'L', 'XL', 'XXL', 'Standard'),
    typeArticle ENUM ('T-Shirt', 'Beanie', 'Hoodie'),
    id_artiste INTEGER NOT NULL,
    photo_merch VARCHAR(256),

    PRIMARY KEY (id_merch),
    FOREIGN KEY (id_produit) REFERENCES Produit (id_produit) ON DELETE CASCADE,
    FOREIGN KEY (id_artiste) REFERENCES Artiste (id_artiste) ON DELETE CASCADE
);

-- Album
CREATE TABLE Album (
    id_album INTEGER AUTO_INCREMENT,
    titre VARCHAR(32) NOT NULL,
    id_artiste INTEGER NOT NULL,
    id_style INTEGER NOT NULL,
    id_produit INTEGER DEFAULT NULL, -- null, changé apres le trigger
    format ENUM ('Numerique', 'Disque', 'Cassette', 'Vinyl'), -- a voir
    noteglobal REAL DEFAULT NULL,
    annee_parution INTEGER,
    duree REAL DEFAULT 0.0,
    photo_album VARCHAR(256),

    PRIMARY KEY(id_album),
    FOREIGN KEY(id_artiste) REFERENCES Artiste (id_artiste),
    FOREIGN KEY(id_style) REFERENCES Styles (id_style),
    FOREIGN KEY(id_produit) REFERENCES Produit (id_produit),
    CONSTRAINT CHK_noteGlobal CHECK (noteglobal >= 1 AND noteglobal <=5),
    CONSTRAINT CHK_duree CHECK (duree >= 0.0)
);

-- Chanson
CREATE TABLE Chanson (
    id_chanson INTEGER AUTO_INCREMENT,
    id_album INTEGER NOT NULL,
    titre VARCHAR(32) NOT NULL,
    duree REAL,

    PRIMARY KEY (id_chanson),
    FOREIGN KEY (id_album) REFERENCES Album (id_album)
);

-- Transaction
CREATE TABLE Transaction (
    id_transaction INTEGER AUTO_INCREMENT,
    id_produit INTEGER NOT NULL,
    id_utilisateur INTEGER NOT  NULL,
    date_transaction DATE DEFAULT (CURRENT_DATE),

    PRIMARY KEY(id_transaction),
    FOREIGN KEY(id_produit) REFERENCES Produit (id_produit),
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur (id_utilisateur)
);

-- Noter
CREATE TABLE Noter (
    id_utilisateur INTEGER,
    id_album INTEGER,
    note INTEGER,
    review VARCHAR(2056),

    PRIMARY KEY (id_utilisateur, id_album),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur (id_utilisateur),
    FOREIGN KEY (id_album) REFERENCES Album (id_album),
    CONSTRAINT CHK_NoterNote CHECK (note >= 1 AND note <=5)
);

-- Suivre
CREATE TABLE Suivre (
    id_utilisateur INTEGER NOT NULL,
    id_artiste INTEGER NOT NULL,

    PRIMARY KEY (id_utilisateur, id_artiste),
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur (id_utilisateur),
    FOREIGN KEY(id_artiste) REFERENCES Artiste (id_artiste)
);

/*------------------------------------------TRIGGERS--------------------------------------------------*/

-- Trigger 1: Ajoute les items de merch à la table produit
DELIMITER //
CREATE TRIGGER ajout_merch_a_produit BEFORE INSERT ON Merch FOR EACH ROW

    BEGIN
        -- ajoute le produit, avec le prix en fonction de l'item
        INSERT INTO Produit (prix) VALUES (
            CASE
                WHEN NEW.typeArticle = 'T-Shirt' THEN 19.99
                WHEN NEW.typeArticle = 'Beanie' THEN 14.99
                WHEN NEW.typeArticle = 'Hoodie' THEN 29.99
            END );

        -- ajoute le id_produit dans la table merch
        SET NEW.id_produit = LAST_INSERT_ID();

    END //
DELIMITER ;


-- Trigger 2: Ajoute les items d'album à la table produit
DELIMITER //
CREATE TRIGGER ajout_album_a_produit BEFORE INSERT ON Album FOR EACH ROW

    BEGIN
        -- ajoute le produit avec le prix pour un album
        INSERT INTO Produit (prix) VALUES
            (5.99);

        -- ajoute le id_produit dans la table album
        SET NEW.id_produit = LAST_INSERT_ID();

    END //
DELIMITER ;


-- Trigger 3: Modifie la note globale d'un album (une note ne peut pas etre modifiee une fois qu'elle est donnee)
DELIMITER //
CREATE TRIGGER note_globale_album AFTER INSERT ON Noter FOR EACH ROW

    BEGIN
        DECLARE total_note INTEGER;
        DECLARE total_votes INTEGER;

        SELECT SUM(note), COUNT(*) INTO total_note, total_votes
        FROM Noter N WHERE N.id_album = NEW.id_album;

        IF total_votes > 0 THEN
            UPDATE Album A SET noteglobal = total_note / total_votes
            WHERE A.id_album = NEW.id_album;
        ELSE
            UPDATE Album A SET noteglobal = NULL
            WHERE A.id_album = NEW.id_album;
        END IF;

    END //
DELIMITER ;
-- revoir le trigger note global si album a 0 notes


-- Trigger 4: Modifie la duree totale d'un album
DELIMITER //
CREATE TRIGGER duree_album_insert AFTER INSERT ON Chanson FOR EACH ROW

    BEGIN
        UPDATE Album A SET A.duree = (A.duree + NEW.duree)
        WHERE NEW.id_album = A.id_album;
    END //
DELIMITER ;

-- Delete (une chanson se fait retirer de l'album
DELIMITER //
CREATE TRIGGER duree_album_delete AFTER DELETE ON Chanson FOR EACH ROW

    BEGIN
        UPDATE Album A SET A.duree = (A.duree - OLD.duree)
        WHERE OLD.id_album = A.id_album;
    END //
DELIMITER ;


-- Trigger 5: Nombre d'artistes dans une université
DELIMITER //
CREATE TRIGGER nombre_artistes_insert AFTER INSERT ON Artiste FOR EACH ROW

    BEGIN
        IF NEW.id_universite IS NOT NULL THEN
            UPDATE UNIVERSITE U SET U.nombre_artistes = U.nombre_artistes + 1
            WHERE U.id_universite = NEW.id_universite;
        END IF;
    end //
DELIMITER ;

-- Update (changement d'universite d'un artiste)
DELIMITER //
CREATE TRIGGER nombre_artistes_update AFTER UPDATE ON Artiste FOR EACH ROW

    BEGIN
        IF OLD.id_universite IS NOT NULL THEN
            UPDATE UNIVERSITE U SET U.nombre_artistes = U.nombre_artistes - 1
            WHERE U.id_universite = OLD.id_universite;
        END IF;

        IF NEW.id_universite IS NOT NULL THEN
            UPDATE UNIVERSITE U SET U.nombre_artistes = U.nombre_artistes + 1
            WHERE U.id_universite = NEW.id_universite;
        END IF;
    end //
DELIMITER ;



-- Trigger 6: Nombre de followers d'un artiste
DELIMITER //
CREATE TRIGGER nombre_followers_insert AFTER INSERT ON Suivre FOR EACH ROW

    BEGIN
        UPDATE ARTISTE A SET A.nombre_followers = A.nombre_followers + 1
        WHERE A.id_artiste = NEW.id_artiste;
    end //
DELIMITER ;

-- Delete (unfollow d'un artiste)
DELIMITER //
CREATE TRIGGER nombre_followers_delete AFTER DELETE ON Suivre FOR EACH ROW

    BEGIN
        UPDATE ARTISTE A SET A.nombre_followers = A.nombre_followers - 1
        WHERE A.id_artiste = OLD.id_artiste;
    end //
DELIMITER ;

/*-------------------------------------------INSERTS--------------------------------------------------*/

-- Region
INSERT INTO Region (nom) VALUES
    ('Abitibi-Témiscamingue'),
    ('Bas-Saint-Laurent'),
    ('Capitale-Nationale'),
    ('Estrie'),
    ('Mauricie'),
    ('Montréal'),
    ('Outaouais'),
    ('Saguenay – Lac-Saint-Jean');

-- Universite
INSERT INTO Universite (nom, id_region, photo_universite) VALUES
    ('Université du Québec en Abitibi-Témiscamingue', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteAbitibi.jpg'),
    ('Université du Québec à Rimouski', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteRimouski.jpg'),
    ('École nationale d’administration publique', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/administrationPublique.jpg'),
    ('Institut national de la recherche scientifique', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/rechercheScientifique.jpg'),
    ('Université Laval', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteLaval.jpg'),
    ('Université Bishop’s', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/bishupUniversity.jpg'),
    ('Université de Sherbrooke', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteSherbrooke.jpg'),
    ('Université du Québec à Trois-Rivières', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteTroisRiviere.jpg'),
    ('École des hautes études commerciales de Montréal', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/hecMontreal.jpg'),
    ('École de technologie supérieure', 6, 'https://artuneconnectimgs.s3.us-east2.amazonaws.com/UniImgs/universiteTechnologieSuperieure.jpg'),
    ('Polytechnique Montréal', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/polytechniqueMontreal.jpg'),
    ('Université Concordia', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/concordiaUniversity.jpg'),
    ('Université de Montréal', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteMontreal.jpg'),
    ('Université McGill', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/mcgillUniversity.jpg'),
    ('Université du Québec à Montréal', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteUQAM.jpg'),
    ('Université du Québec en Outaouais', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteOutaouais.jpg'),
    ('Université du Québec à Chicoutimi', 8, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/UniImgs/universiteChicoutimi.jpg');

-- Utilisateur (aucunes données initiales)

-- Artiste
INSERT INTO Artiste (nom_artiste, email_artiste, biographie_artiste, origine, id_universite, photo_artiste) VALUES
    ('Emily Serenade', 'emily.serenade@gmail.com', 'Crafting enchanting serenades that linger in the heart like a sweet melody.', 'Fredericton', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi10.webp'),
    ('Marcus Melody', 'marcus.melody@outlook.com', 'Embarking on a musical journey, weaving diverse melodies into a harmonious symphony.', 'Montreal', 9, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi100.webp'),
    ('Olivia Echo', 'olivia.echo@gmail.com', 'Creating echoes of emotion through every note, a reflection of the soul in music.', 'Saguenay', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi11.webp'),
    ('Dylan Harmony', 'dylan.harmony@videotron.ca', 'Harmony in every chord, crafting musical pieces that resonate with the heart.', 'Halifax', 9, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi12.webp'),
    ('Ava Rhythm', 'ava.rhythm@gmail.com', 'Exploring the rhythmic landscapes of sound, creating vibrant and dynamic compositions.', 'Charlottetown', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi13.webp'),
    ('Ethan Songstress', 'ethan.songstress@outlook.com', 'A songstress in the realm of emotions, translating feelings into beautiful melodies.', 'Rimouski', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi14.webp'),
    ('Lily Composer', 'lily.composer@gmail.com', 'Composing musical tales that unfold like a story, each note a chapter of emotions.', 'Hamilton', 11, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi15.webp'),
    ('Noah Lullaby', 'noah.lullaby@videotron.ca', 'Crafting lullabies that cradle the soul, creating a serene musical sanctuary.', 'Ottawa', 9, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi16.webp'),
    ('Sophia Harmony', 'sophia.harmony@gmail.com', 'Harmony as a language, conveying emotions and stories through musical unity.', 'Kingston', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi17.webp'),
    ('Benjamin Melodies', 'benjamin.melodies@outlook.com', 'Melodies that dance through the air, each one telling a unique musical story.', 'Bathurst', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi18.webp'),
    ('Grace Harmony', 'grace.harmony@gmail.com', 'Harmony as the canvas, painting emotions with the vibrant colors of musical notes.', 'Trois-Rivières', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi19.webp'),
    ('Jack Serenader', 'jack.serenader@videotron.ca', 'A serenader at heart, enchanting audiences with soulful and melodious performances.', 'Quebec City', 9, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi2.webp'),
    ('Chloe Rhythms', 'chloe.rhythms@gmail.com', 'Exploring rhythmic landscapes, creating intricate patterns that resonate with the heartbeat.', 'Toronto', 9, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi20.webp'),
    ('Lucas Sonata', 'lucas.sonata@outlook.com', 'Crafting musical sonatas that weave a tapestry of emotions, each movement a journey.', 'London', 17, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi21.webp'),
    ('Mia Melodic', 'mia.melodic@videotron.ca', 'Diving into the world of melody, creating tunes that evoke a myriad of emotions.', 'Windsor', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi22.webp'),
    ('Owen Crescendo', 'owen.crescendo@gmail.com', 'Building crescendos that rise and fall, capturing the essence of musical expression.', 'Sherbrooke', 8, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi23.webp'),
    ('Zoe Harmony', 'zoe.harmony@outlook.com', 'Harmony as a guiding light, leading listeners through a melodic journey of emotions.', 'Kingston', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi24.webp'),
    ('Caleb Muse', 'caleb.muse@videotron.ca', 'Drawing inspiration from the muses, creating music that transcends artistic boundaries.', 'Montreal', 15, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi25.webp'),
    ('Harper Serenade', 'harper.serenade@gmail.com', 'Serenading the soul with gentle tunes, creating a harmonious connection with emotions.', 'Ottawa', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi26.webp'),
    ('Isaac Harmonizer', 'isaac.harmonizer@outlook.com', 'Harmonizing sounds with precision, creating a musical blend that resonates with the spirit.', 'Quebec City', 8, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi27.webp'),
    ('Amelia Cadence', 'amelia.cadence@gmail.com', 'Weaving intricate cadences that dance through the air like poetry set to music.', 'Halifax', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi28.webp'),
    ('Logan Harmony', 'logan.harmony@outlook.com', 'Exploring the harmonious realms of sound, creating melodies that resonate with the heart.', 'Charlottetown', 13, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi29.webp'),
    ('Isabella Melody', 'isabella.melody@gmail.com', 'Crafting enchanting melodies that linger in the soul, like a timeless and sweet melody.', 'Saguenay', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi3.webp'),
    ('Aiden Serenade', 'aiden.serenade@videotron.ca', 'A serenader at heart, creating musical tales that captivate and enchant the listener.', 'Sherbrooke', 14, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi30.webp'),
    ('Emma Rhythms', 'emma.rhythms@gmail.com', 'Exploring rhythmic landscapes, creating vibrant and dynamic compositions that echo with emotion.', 'Ottawa', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi31.webp'),
    ('Oliver Lyricist', 'oliver.lyricist@outlook.com', 'Crafting poetic lyrics that intertwine with melodies, creating a symphony of emotions.', 'Kingston', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi32.webp'),
    ('Ava Harmonics', 'ava.harmonics@gmail.com', 'Exploring the intricate harmonics of sound, creating a musical tapestry that resonates.', 'Toronto', 11, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi33.webp'),
    ('Elijah Melodic', 'elijah.melodic@videotron.ca', 'Diving into the world of melody, creating tunes that evoke a myriad of emotions.', 'Montreal', 15, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi34.webp'),
    ('Sophia Sonnet', 'sophia.sonnet@outlook.com', 'Crafting musical sonnets that tell stories through notes, each one a poetic expression.', 'Quebec City', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi35.webp'),
    ('Mason Harmony', 'mason.harmony@gmail.com', 'Harmony as a guiding light, leading listeners through a melodic journey of emotions.', 'Trois-Rivières', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi36.webp'),
    ('Abigail Composer', 'abigail.composer@videotron.ca', 'Composing musical tales that unfold like a story, each note a chapter of emotions.', 'Halifax', 8, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi37.webp'),
    ('Jackson Lullaby', 'jackson.lullaby@gmail.com', 'Crafting lullabies that cradle the soul, creating a serene musical sanctuary.', 'Windsor', 13, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi38.webp'),
    ('Harper Melodies', 'harper.melodies@outlook.com', 'Melodies that dance through the air, each one telling a unique musical story.', 'Montreal', 14, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi39.webp'),
    ('Ethan Harmony', 'ethan.harmony@gmail.com', 'Harmony as the canvas, painting emotions with the vibrant colors of musical notes.', 'London', 17, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi4.webp'),
    ('Addison Crescendo', 'addison.crescendo@videotron.ca', 'Building crescendos that rise and fall, capturing the essence of musical expression.', 'Sherbrooke', 17, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi40.webp'),
    ('Liam Serenader', 'liam.serenader@gmail.com', 'A serenader at heart, enchanting audiences with soulful and melodious performances.', 'Kingston', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi41.webp'),
    ('Grace Aria', 'grace.aria@outlook.com', 'Crafting arias that soar through the air, a lyrical journey through the soul of music.', 'Ottawa', 15, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi42.webp'),
    ('Noah Muse', 'noah.muse@gmail.com', 'Drawing inspiration from the muses, creating music that transcends artistic boundaries.', 'Montreal', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi43.webp'),
    ('Lily Serenade', 'lily.serenade@videotron.ca', 'Serenading the soul with gentle tunes, creating a harmonious connection with emotions.', 'Quebec City', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi44.webp'),
    ('Lucas Melody', 'lucas.melody@outlook.com', 'Crafting enchanting melodies that linger in the heart like a sweet melody.', 'Halifax', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi45.webp'),
    ('Mia Harmony', 'mia.harmony@gmail.com', 'Harmony that resonates with the soul, creating a musical landscape of tranquility and emotion.', 'Ottawa', 8, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi46.webp'),
    ('Benjamin Crescendo', 'benjamin.crescendo@outlook.com', 'Building crescendos that echo with emotion, a journey through the heights of musical expression.', 'Quebec City', 13, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi47.webp'),
    ('Stella Serenade', 'stella.serenade@gmail.com', 'Serenading the heart with melodies that shimmer like starlight, a musical journey through the cosmos.', 'Montreal', 15, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi48.webp'),
    ('Henry Melodic', 'henry.melodic@videotron.ca', 'Exploring the melodic nuances of sound, crafting tunes that resonate with the essence of emotion.', 'Kingston', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi49.webp'),
    ('Aurora Lullaby', 'aurora.lullaby@gmail.com', 'Crafting lullabies that cradle the soul, creating a serene and enchanting musical dreamscape.', 'Windsor', 11, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi5.webp'),
    ('Elijah Cadence', 'elijah.cadence@outlook.com', 'Weaving intricate cadences that dance through the air like poetry set to the rhythm of life.', 'Saguenay', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi50.webp'),
    ('Chloe Composer', 'chloe.composer@videotron.ca', 'Composing musical stories that unfold like a tapestry, each note a stroke in the canvas of emotion.', 'London', 14, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi51.webp'),
    ('Samuel Lyricist', 'samuel.lyricist@gmail.com', 'Crafting poetic lyrics that resonate with the soul, a lyrical journey through the heart of music.', 'Montreal', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi52.webp'),
    ('Scarlett Rhythms', 'scarlett.rhythms@outlook.com', 'Exploring rhythmic landscapes, creating vibrant and dynamic compositions that echo with life.', 'Toronto', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi53.webp'),
    ('Wyatt Serenader', 'wyatt.serenader@videotron.ca', 'A serenader at heart, enchanting listeners with soulful melodies that paint emotions in the air.', 'Sherbrooke', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi54.webp'),
    ('Penelope Harmonics', 'penelope.harmonics@gmail.com', 'Exploring the intricate harmonics of sound, creating a symphony that resonates with the heart.', 'Halifax', 13, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi55.webp'),
    ('Leo Muse', 'leo.muse@outlook.com', 'Drawing inspiration from the muses, creating music that transcends boundaries and sparks creativity.', 'Rimouski', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi56.webp'),
    ('Layla Sonnet', 'layla.sonnet@videotron.ca', 'Crafting musical sonnets that weave tales of love and emotion, creating a lyrical dreamscape.', 'Trois-Rivières', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi57.webp'),
    ('Jack Melodies', 'jack.melodies@gmail.com', 'Melodies that dance through the air, each note telling a unique story and painting emotions.', 'Montreal', 15, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi58.webp'),
    ('Zoey Harmony', 'zoey.harmony@outlook.com', 'Harmony that resonates with the essence of life, creating a musical journey through emotions.', 'Quebec City', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi1.webp'),
    ('Caleb Serenade', 'caleb.serenade@videotron.ca', 'Serenading the soul with gentle tunes, creating a harmonious connection with emotions.', 'Trois-Rivières', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi6.webp'),
    ('Nora Aria', 'nora.aria@gmail.com', 'Crafting arias that soar through the air, each one a lyrical journey through the heart of music.', 'Windsor', 16, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi60.webp'),
    ('Logan Melody', 'logan.melody@outlook.com', 'Crafting enchanting melodies that linger in the heart, a sweet and melodic journey through sound.', 'Sherbrooke', 16, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi61.webp'),
    ('Riley Harmonizer', 'riley.harmonizer@gmail.com', 'Harmonizing the soul with rhythmic precision, creating a symphony of emotional expression.', 'London', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi62.webp'),
    ('Lucy Serenada', 'lucy.serenada@videotron.ca', 'Serenading the senses with melodies that dance through the air like whispers of musical enchantment.', 'Montreal', 11, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi63.webp'),
    ('Mason Melodique', 'mason.melodique@gmail.com', 'Exploring melodies with a unique twist, creating a harmonious journey through a tapestry of sound.', 'Montreal', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi64.webp'),
    ('Ava Harmonique', 'ava.harmonique@outlook.com', 'Harmonizing the soul with enchanting tunes, creating a symphony of emotions through musical expression.', 'Quebec City', 13, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi65.webp'),
    ('Oliver Crescendo', 'oliver.crescendo@videotron.ca', 'Building crescendos that rise like waves, crafting a musical journey through the heights of emotion.', 'Ottawa', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi66.webp'),
    ('Sophia Sonore', 'sophia.sonore@gmail.com', 'Exploring the sonorous realm of sound, creating melodies that resonate with the essence of life.', 'Toronto', 11, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi67.webp'),
    ('Liam Rhapsody', 'liam.rhapsody@outlook.com', 'Embarking on a rhapsodic journey through sound, crafting vibrant and expressive musical compositions.', 'Halifax', 16, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi68.webp'),
    ('Amelia Vibrato', 'amelia.vibrato@gmail.com', 'Creating vibrato-rich melodies that add a touch of emotion and depth to the musical canvas.', 'St. John', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi69.webp'),
    ('Jackson Harmonie', 'jackson.harmonie@videotron.ca', 'Crafting a harmonious blend of melodies, creating a symphony that resonates with the soul.', 'Hamilton', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi7.webp'),
    ('Aria Symphonique', 'aria.symphonique@outlook.com', 'Embarking on a symphonic journey through musical expression, creating an aria of emotional resonance.', 'Kingston', 16, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi70.webp'),
    ('Noah Serenissimo', 'noah.serenissimo@gmail.com', 'Serenading the senses with tranquility, creating music that unfolds with serenity and grace.', 'London', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi71.webp'),
    ('Grace Allegro', 'grace.allegro@videotron.ca', 'Crafting allegros that dance with lively rhythms, creating a symphony that pulses with energy.', 'Windsor', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi72.webp'),
    ('Elijah Cadansa', 'elijah.cadansa@gmail.com', 'Dancing through musical landscapes with cadence, creating compositions that enthrall and captivate.', 'Sherbrooke', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi73.webp'),
    ('Lily Cantabile', 'lily.cantabile@outlook.com', 'Exploring the cantabile style, crafting melodies that flow with smooth and graceful expression.', 'Trois-Rivières', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi74.webp'),
    ('Benjamin Sonata', 'benjamin.sonata@gmail.com', 'Crafting sonatas that unfold like musical stories, each movement a journey through emotion and expression.', 'Saguenay', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi75.webp'),
    ('Mia Lyrique', 'mia.lyrique@videotron.ca', 'Expressing through lyrical compositions, crafting melodies that tell tales of love and emotion.', 'Rimouski', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi76.webp'),
    ('Lucas Melodista', 'lucas.melodista@gmail.com', 'Channeling a melodista approach, creating music that resonates with a melodic and expressive touch.', 'Bathurst', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi77.webp'),
    ('Harper Vivace', 'harper.vivace@outlook.com', 'Crafting vivace compositions that burst with life, creating a symphony of vibrant and lively sounds.', 'Montreal', 16, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi78.webp'),
    ('Ethan Harmonioso', 'ethan.harmonioso@videotron.ca', 'Exploring the harmonioso style, creating harmonious compositions that resonate with tranquility.', 'Quebec City', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi79.webp'),
    ('Isabella Adagio', 'isabella.adagio@gmail.com', 'Crafting adagios that unfold with grace and elegance, creating a musical journey through the soul.', 'Montreal', 12, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi8.webp'),
    ('Alexander Forte', 'alexander.forte@outlook.com', 'Expressing through forte compositions, crafting powerful melodies that resonate with strength and intensity.', 'Sherbrooke', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi80.webp'),
    ('Emma Dolce', 'emma.dolce@videotron.ca', 'Exploring the dolce style, creating melodies that unfold with sweetness and gentle expression.', 'Rimouski', 12, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi81.webp'),
    ('Sebastian Crescendo', 'sebastian.crescendo@gmail.com', 'Crafting crescendos that rise with intensity, creating a symphony of dynamic and powerful melodies.', 'Montreal', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi82.webp'),
    ('Scarlett Melodia', 'scarlett.melodia@outlook.com', 'Expressing through melodic compositions, crafting tunes that resonate with the heart and soul.', 'Quebec City', 12, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi83.webp'),
    ('Henry Serenade', 'henry.serenade@videotron.ca', 'Serenading the senses with melodic charm, creating compositions that evoke emotion and enchantment.', 'Ottawa', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi84.webp'),
    ('Stella Vibrante', 'stella.vibrante@gmail.com', 'Crafting vibrant compositions that resonate with energy, creating a symphony of lively and animated melodies.', 'Toronto', 11, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi85.webp'),
    ('Samuel Sonique', 'samuel.sonique@outlook.com', 'Exploring the sonique style, crafting compositions that resonate with unique and expressive sonic elements.', 'Halifax', 14, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi86.webp'),
    ('Aurora Cantabile', 'aurora.cantabile@gmail.com', 'Expressing through the cantabile style, creating melodies that flow with graceful and lyrical expression.', 'Montreal', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi87.webp'),
    ('Leo Lyrique', 'leo.lyrique@videotron.ca', 'Embarking on a lyrique journey, crafting compositions that tell tales of emotion and poetic expression.', 'St. John', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi88.webp'),
    ('Penelope Harmonique', 'penelope.harmonique@outlook.com', 'Crafting harmonique compositions that resonate with elegance, creating a symphony of refined and graceful melodies.', 'Hamilton', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi89.webp'),
    ('Maxime Rhapsode', 'maxime.rhapsode@gmail.com', 'Diving into the rhapsodic realm, crafting compositions that ebb and flow with expressive and dynamic melodies.', 'Kingston', 12, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi9.webp'),
    ('Violet Harmonia', 'violet.harmonia@videotron.ca', 'Expressing through harmonia compositions, crafting melodies that resonate with balance and unity.', 'London', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi90.webp'),
    ('Daniel Allegretto', 'daniel.allegretto@gmail.com', 'Crafting allegretto compositions that dance with lively and brisk rhythms, creating a symphony of spirited melodies.', 'Windsor', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi91.webp'),
    ('Emily Adagietto', 'emily.adagietto@outlook.com', 'Exploring the adagietto style, creating compositions that unfold with gentle and unhurried expression.', 'Sherbrooke', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi92.webp'),
    ('Oliver Ritornello', 'oliver.ritornello@gmail.com', 'Crafting ritornello compositions that repeat with recurring themes, creating a musical journey through familiar and comforting melodies.', 'Trois-Rivières', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi93.webp'),
    ('Ava Fortissimo', 'ava.fortissimo@videotron.ca', 'Expressing through fortissimo compositions, crafting powerful and intense melodies that resonate with strength and grandeur.', 'Saguenay', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi94.webp'),
    ('Ethan Crescendo', 'ethan.crescendo@outlook.com', 'Crafting crescendos that build with intensity, creating a symphony of powerful and dynamic musical expressions.', 'Rimouski', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi95.webp'),
    ('Sofia Lyrical', 'sofia.lyrical@gmail.com', 'Exploring the lyrical style, crafting compositions that unfold with expressive and poetic melodies.', 'Montreal', 12, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi96.webp'),
    ('Noah Dolce', 'noah.dolce@videotron.ca', 'Expressing through the dolce style, creating melodies that unfold with sweetness and gentle expression.', 'Quebec City', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi97.webp'),
    ('Mia Virtuoso', 'mia.virtuoso@outlook.com', 'Embarking on a virtuoso journey, crafting compositions that showcase technical mastery and expressive brilliance.', 'Montreal', 15, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi98.webp'),
    ('Liam Serenata', 'liam.serenata@gmail.com', 'Serenading the soul with tranquil melodies, creating compositions that evoke feelings of serenity and peace.', 'Sherbrooke', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi99.webp'),
    ('Grace Sonante', 'grace.sonante@videotron.ca', 'Crafting sonante compositions that resonate with sound, creating a symphony of harmonious and resonant melodies.', 'Rimouski', 12, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/ArtistImgs/avi59.webp');

-- Styles
INSERT INTO Styles (nom) VALUES
    ('Pop'),
    ('Rock'),
    ('Hip Hop'),
    ('Jazz'),
    ('Country'),
    ('Electronique'),
    ('Classique'),
    ('Blues'),
    ('R&B'),
    ('Reggae');

-- Produit (aucunes données initiales)

-- Merch
INSERT INTO Merch (nom_article, couleur, taille, typeArticle, id_artiste, photo_merch) VALUES
    -- 2 items par artiste
    ('Emily Serenade White beanie', 'FFFFFF', 'Standard', 'beanie', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Marcus Melody Black t-shirt', '000000', 'S', 't-shirt', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Olivia Echo Gray hoodie', '333333', 'M', 'hoodie', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Dylan Harmony Gray beanie', '999999', 'Standard', 'beanie', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Ava Rhythm Dark Gray t-shirt', '666666', 'XL', 't-shirt', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Ethan Songstress Light Gray hoodie', 'CCCCCC', 'S', 'hoodie', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Lily Composer Dark Blue beanie', '003366', 'Standard', 'beanie', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Noah Lullaby Dark Red t-shirt', '993333', 'L', 't-shirt', 8, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Sophia Harmony Brown hoodie', '663300', 'XL', 'hoodie', 9, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Benjamin Melodies Dark Purple beanie', '330099', 'Standard', 'beanie', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Grace Harmony Dark Pink t-shirt', '990066', 'S', 't-shirt', 11, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Jack Serenader Dark Green hoodie', '006633', 'M', 'hoodie', 12, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Chloe Rhythms Dark Violet beanie', '663399', 'Standard', 'beanie', 13, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Lucas Sonata Dark Orange t-shirt', '996633', 'XL', 't-shirt', 14, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Mia Melodic Dark Aqua hoodie', '336699', 'Standard', 'hoodie', 15, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Owen Crescendo Dark Teal beanie', '663333', 'Standard', 'beanie', 16, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Zoe Harmony Dark Yellow t-shirt', '996600', 'M', 't-shirt', 17, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Caleb Muse Dark Violet hoodie', '330066', 'L', 'hoodie', 18, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Emily Serenade Pink Hoodie', 'FFC0CB', 'M', 'hoodie', 1, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Marcus Melody Blue T-Shirt', '0000FF', 'XL', 't-shirt', 2, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Olivia Echo Purple Beanie', '800080', 'Standard', 'beanie', 3, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Dylan Harmony Green Hoodie', '008000', 'L', 'hoodie', 4, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Ava Rhythm Yellow T-Shirt', 'FFFF00', 'S', 't-shirt', 5, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Ethan Songstress Red Beanie', 'FF0000', 'Standard', 'beanie', 6, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Lily Composer Orange Hoodie', 'FFA500', 'XL', 'hoodie', 7, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Noah Lullaby Blue T-Shirt', '0000FF', 'M', 't-shirt', 8, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Sophia Harmony Green Beanie', '008000', 'Standard', 'beanie', 9, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Benjamin Melodies Pink Hoodie', 'FFC0CB', 'L', 'hoodie', 10, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Grace Harmony Yellow T-Shirt', 'FFFF00', 'S', 't-shirt', 11, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Jack Serenader Blue Beanie', '0000FF', 'Standard', 'beanie', 12, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Chloe Rhythms Purple Hoodie', '800080', 'XL', 'hoodie', 13, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Lucas Sonata Red T-Shirt', 'FF0000', 'M', 't-shirt', 14, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Mia Melodic Green Beanie', '008000', 'Standard', 'beanie', 15, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Owen Crescendo Pink Hoodie', 'FFC0CB', 'S', 'hoodie', 16, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Zoe Harmony Blue T-Shirt', '0000FF', 'L', 't-shirt', 17, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Caleb Muse Yellow Beanie', 'FFFF00', 'Standard', 'beanie', 18, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Harper Serenade Black Beanie', '000000', 'Standard', 'beanie', 19, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Isaac Harmonizer Gray T-Shirt', '808080', 'XL', 't-shirt', 20, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Amelia Cadence White Hoodie', 'FFFFFF', 'M', 'hoodie', 21, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Logan Harmony Black Beanie', '000000', 'Standard', 'beanie', 22, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Isabella Melody Gray T-Shirt', '808080', 'S', 't-shirt', 23, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Aiden Serenade White Hoodie', 'FFFFFF', 'XL', 'hoodie', 24, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Emma Rhythms Black Beanie', '000000', 'Standard', 'beanie', 25, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Oliver Lyricist Gray T-Shirt', '808080', 'L', 't-shirt', 26, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Ava Harmonics White Hoodie', 'FFFFFF', 'M', 'hoodie', 27, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Elijah Melodic Black Beanie', '000000', 'Standard', 'beanie', 28, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Sophia Sonnet Gray T-Shirt', '808080', 'XL', 't-shirt', 29, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Mason Harmony White Hoodie', 'FFFFFF', 'S', 'hoodie', 30, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Abigail Composer Black Beanie', '000000', 'Standard', 'beanie', 31, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Jackson Lullaby Gray T-Shirt', '808080', 'M', 't-shirt', 32, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Harper Melodies White Hoodie', 'FFFFFF', 'L', 'hoodie', 33, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Ethan Harmony Black Beanie', '000000', 'Standard', 'beanie', 34, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Addison Crescendo Gray T-Shirt', '808080', 'XL', 't-shirt', 35, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Liam Serenader White Hoodie', 'FFFFFF', 'M', 'hoodie', 36, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Harper Serenade Black Beanie', '000000', 'Standard', 'beanie', 19, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Isaac Harmonizer Gray T-Shirt', '808080', 'XL', 't-shirt', 20, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Amelia Cadence White Hoodie', 'FFFFFF', 'M', 'hoodie', 21, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Logan Harmony Black Beanie', '000000', 'Standard', 'beanie', 22, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Isabella Melody Gray T-Shirt', '808080', 'S', 't-shirt', 23, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Aiden Serenade White Hoodie', 'FFFFFF', 'XL', 'hoodie', 24, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Emma Rhythms Black Beanie', '000000', 'Standard', 'beanie', 25, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Oliver Lyricist Gray T-Shirt', '808080', 'L', 't-shirt', 26, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Ava Harmonics White Hoodie', 'FFFFFF', 'M', 'hoodie', 27, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Elijah Melodic Black Beanie', '000000', 'Standard', 'beanie', 28, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Sophia Sonnet Gray T-Shirt', '808080', 'XL', 't-shirt', 29, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Mason Harmony White Hoodie', 'FFFFFF', 'S', 'hoodie', 30, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Abigail Composer Black Beanie', '000000', 'Standard', 'beanie', 31, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Jackson Lullaby Gray T-Shirt', '808080', 'M', 't-shirt', 32, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Harper Melodies White Hoodie', 'FFFFFF', 'L', 'hoodie', 33, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Ethan Harmony Black Beanie', '000000', 'Standard', 'beanie', 34, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Addison Crescendo Gray T-Shirt', '808080', 'XL', 't-shirt', 35, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Liam Serenader White Hoodie', 'FFFFFF', 'M', 'hoodie', 36, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    -- 1 item par artiste
    ('Grace Aria Black Beanie', '000000', 'Standard', 'beanie', 37, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Noah Muse Gray T-Shirt', '808080', 'M', 't-shirt', 38, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Lily Serenade White Hoodie', 'FFFFFF', 'XL', 'hoodie', 39, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Lucas Melody Black Beanie', '000000', 'Standard', 'beanie', 40, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Mia Harmony Gray T-Shirt', '808080', 'S', 't-shirt', 41, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Benjamin Crescendo White Hoodie', 'FFFFFF', 'M', 'hoodie', 42, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Stella Serenade Black Beanie', '000000', 'Standard', 'beanie', 43, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Henry Melodic Gray T-Shirt', '808080', 'L', 't-shirt', 44, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Aurora Lullaby White Hoodie', 'FFFFFF', 'XL', 'hoodie', 45, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Elijah Cadence Black Beanie', '000000', 'Standard', 'beanie', 46, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Chloe Composer Gray T-Shirt', '808080', 'M', 't-shirt', 47, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Samuel Lyricist White Hoodie', 'FFFFFF', 'S', 'hoodie', 48, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Scarlett Rhythms Black Beanie', '000000', 'Standard', 'beanie', 49, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Wyatt Serenader Gray T-Shirt', '808080', 'XL', 't-shirt', 50, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Penelope Harmonics White Hoodie', 'FFFFFF', 'M', 'hoodie', 51, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Leo Muse Black Beanie', '000000', 'Standard', 'beanie', 52, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Layla Sonnet Gray T-Shirt', '808080', 'L', 't-shirt', 53, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Jack Melodies White Hoodie', 'FFFFFF', 'S', 'hoodie', 54, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Zoey Harmony Black Beanie', '000000', 'Standard', 'beanie', 55, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Caleb Serenade Gray T-Shirt', '808080', 'S', 't-shirt', 56, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Nora Aria Dark Gray Hoodie', '333333', 'M', 'hoodie', 57, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Logan Melody Black Beanie', '000000', 'Standard', 'beanie', 58, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Riley Harmonizer Gray T-Shirt', '808080', 'L', 't-shirt', 59, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Lucy Serenada Dark Gray Hoodie', '333333', 'XL', 'hoodie', 60, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Mason Melodique Black Beanie', '000000', 'Standard', 'beanie', 61, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Ava Harmonique Dark Gray Hoodie', '333333', 'M', 'hoodie', 62, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Oliver Crescendo Black Beanie', '000000', 'Standard', 'beanie', 63, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Sophia Sonore Dark Gray Hoodie', '333333', 'S', 'hoodie', 64, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Liam Rhapsody Black Beanie', '000000', 'Standard', 'beanie', 65, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Amelia Vibrato Dark Gray Hoodie', '333333', 'L', 'hoodie', 66, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Jackson Harmonie Black Beanie', '000000', 'Standard', 'beanie', 67, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Aria Symphonique Dark Gray Hoodie', '333333', 'M', 'hoodie', 68, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp'),
    ('Noah Serenissimo Black Beanie', '000000', 'Standard', 'beanie', 69, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Grace Allegro Gray T-Shirt', '808080', 'XL', 't-shirt', 70, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blacktshirt.jpg'),
    ('Elijah Cadansa Black Beanie', '000000', 'Standard', 'beanie', 71, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackbeannie.webp'),
    ('Lily Cantabile Dark Gray Hoodie', '333333', 'S', 'hoodie', 72, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/MerchImgs/blackhoodie.webp');

-- Album
INSERT INTO Album (titre, id_artiste, id_style, format, annee_parution, photo_album) VALUES
    -- 3 albums par artiste
    ('Pop Sensations', 83, 1, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a1.webp'),
    ('Rock Revolution', 84, 2, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a10.webp'),
    ('Hip Hop Harmony', 85, 3, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a100.webp'),
    ('Jazzy Journeys', 86, 4, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a101.webp'),
    ('Country Charm', 87, 5, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a102.webp'),
    ('Electronic Echoes', 88, 6, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a103.webp'),
    ('Classical Cadence', 89, 7, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a104.webp'),
    ('Bluesy Beats', 90, 8, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a105.webp'),
    ('R&B Rhythms', 91, 9, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a106.webp'),
    ('Reggae Grooves', 92, 10, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a107.webp'),
    ('Electro Euphoria', 93, 6, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a108.webp'),
    ('Classical Serenity', 94, 7, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a109.webp'),
    ('Bluesy Bliss', 95, 8, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a11.webp'),
    ('R&B Reverie', 96, 9, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a110.webp'),
    ('Reggae Reflections', 97, 10, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a111.webp'),
    ('Electro Energy', 98, 6, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a112.webp'),
    ('Classical Crescendo', 99, 7, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a113.webp'),
    ('Symphony of Sound', 100, 4, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a114.webp'),
    ('Melodic Reflections', 83, 2, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a115.webp'),
    ('Vibrant Symphony', 84, 7, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a116.webp'),
    ('Sonic Explorations', 85, 3, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a117.webp'),
    ('Cantabile Dreams', 86, 6, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a118.webp'),
    ('Lyrique Tales', 87, 5, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a119.webp'),
    ('Harmonique Harmony', 88, 8, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a12.webp'),
    ('Rhapsodic Journeys', 89, 4, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a124.webp'),
    ('Harmonious Reverie', 90, 6, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a125.webp'),
    ('Allegretto Adventures', 91, 5, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a126.webp'),
    ('Adagietto Unfolding', 92, 10, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a127.webp'),
    ('Ritornello Memories', 93, 6, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a128.webp'),
    ('Fortissimo Power', 94, 6, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a129.webp'),
    ('Crescendo Mastery', 95, 6, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a13.webp'),
    ('Lyrical Expressions', 96, 7, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a130.webp'),
    ('Dolce Melodies', 97, 9, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a131.webp'),
    ('Virtuoso Showcase', 98, 1, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a132.webp'),
    ('Serenata Moments', 99, 2, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a133.webp'),
    ('Sonante Harmonies', 100, 10, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a134.webp'),
    ('Melodic Dreams', 83, 1, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a83.webp'),
    ('Harmonic Harmony', 84, 2, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a84.webp'),
    ('Serenade Sonata', 85, 3, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a85.webp'),
    ('Lyrical Landscapes', 86, 4, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a86.webp'),
    ('Rhythmic Reverie', 87, 5, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a87.webp'),
    ('Harmony Hues', 88, 6, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a88.webp'),
    ('Melodic Musings', 89, 7, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a9.webp'),
    ('Sonic Serenity', 90, 8, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a90.webp'),
    ('Serenade Symphony', 91, 9, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a91.webp'),
    ('Harmonic Hues', 92, 10, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a92.webp'),
    ('Melodic Mastery', 93, 1, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a93.webp'),
    ('Serenity Symphony', 94, 2, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a94.webp'),
    ('Melodic Meditations', 95, 3, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a95.webp'),
    ('Harmony Haven', 96, 4, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a96.webp'),
    ('Sonic Serenity', 97, 5, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a97.webp'),
    ('Serenade Sonata', 98, 6, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a98.webp'),
    ('Melodic Musings', 99, 7, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a99.webp'),
    ('Harmony Hues', 100, 8, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a100.webp'),
    -- 2 albums par artiste
    ('Rhapsodic Reverie', 65, 4, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a135.webp'),
    ('Vibrato Emotions', 66, 1, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a136.webp'),
    ('Harmonic Symphony', 67, 8, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a137.webp'),
    ('Symphonic Aria', 68, 7, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a138.webp'),
    ('Serenissimo Serenade', 69, 2, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a139.webp'),
    ('Allegro Spirit', 70, 3, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a14.webp'),
    ('Cadansa Rhythms', 71, 9, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a140.webp'),
    ('Cantabile Melodies', 72, 6, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a141.webp'),
    ('Sonata Stories', 73, 10, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a142.webp'),
    ('Lyrique Love', 74, 5, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a143.webp'),
    ('Melodista Moments', 75, 1, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a144.webp'),
    ('Vivace Vibrance', 76, 3, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a145.webp'),
    ('Harmonioso Harmony', 77, 8, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a146.webp'),
    ('Adagio Elegance', 78, 10, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a15.webp'),
    ('Forte Power', 79, 1, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a16.webp'),
    ('Dolce Serenade', 80, 9, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a17.webp'),
    ('Melodia Heartstrings', 81, 4, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a18.webp'),
    ('Rhapsody Reflections', 82, 6, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a19.webp'),
    ('Rhapsody Reverie', 65, 6, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a2.webp'),
    ('Vibrato Serenade', 66, 5, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a20.webp'),
    ('Harmonie Symphony', 67, 6, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a21.webp'),
    ('Symphonique Dreams', 68, 5, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a22.webp'),
    ('Serenissimo Sonata', 69, 6, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a23.webp'),
    ('Allegro Adventures', 70, 5, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a24.webp'),
    ('Cadansa Chronicles', 71, 1, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a25.webp'),
    ('Cantabile Journey', 72, 2, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a26.webp'),
    ('Sonata Stories', 73, 3, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a27.webp'),
    ('Lyrique Ballads', 74, 4, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a28.webp'),
    ('Melodista Medleys', 75, 5, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a29.webp'),
    ('Vivace Variations', 76, 6, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a3.webp'),
    ('Harmonioso Harmony', 77, 7, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a30.webp'),
    ('Adagio Reverence', 78, 8, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a31.webp'),
    ('Forte Fantasies', 79, 9, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a32.webp'),
    ('Dolce Delights', 80, 10, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a33.webp'),
    ('Crescendo Crescents', 81, 1, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a34.webp'),
    ('Melodia Mosaic', 82, 2, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a35.webp'),
    -- 1 album par artiste
    ('Composer''s Canvas', 47, 5, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a36.webp'),
    ('Lyricist''s Lament', 48, 6, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a37.webp'),
    ('Rhythms Revealed', 49, 7, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a38.webp'),
    ('Serenader''s Serenade', 50, 8, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a39.webp'),
    ('Harmonics Harmony', 51, 9, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a4.webp'),
    ('Muse''s Musings', 52, 1, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a40.webp'),
    ('Sonnet Symphony', 53, 1, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a41.webp'),
    ('Melodies Unleashed', 54, 2, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a42.webp'),
    ('Harmony''s Haven', 55, 3, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a43.webp'),
    ('Serenade Serenity', 56, 4, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a44.webp'),
    ('Aria''s Awakening', 57, 5, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a45.webp'),
    ('Melody''s Magic', 58, 6, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a46.webp'),
    ('Harmonique Hues', 59, 7, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a47.webp'),
    ('Crescendo Crescendos', 60, 8, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a48.webp'),
    ('Serenada Songs', 61, 9, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a49.webp'),
    ('Melodique Moments', 62, 10, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a5.webp'),
    ('Harmonizer''s Melodies', 63, 1, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a50.webp'),
    ('Serenade Serenity', 64, 2, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a51.webp'),
    ('Composer''s Odyssey', 46, 5, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a52.webp'),
    ('Lyrical Reflections', 45, 6, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a53.webp'),
    ('Rhythmic Journeys', 44, 7, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a54.webp'),
    ('Serenade Stories', 43, 8, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a55.webp'),
    ('Harmonic Tales', 42, 9, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a56.webp'),
    ('Musical Musings', 41, 10, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a57.webp'),
    ('Sonnet Serenades', 40, 1, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a58.webp'),
    ('Melodic Dreams', 39, 2, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a59.webp'),
    ('Harmonious Harmony', 38, 3, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a6.webp'),
    ('Serenity Symphony', 37, 4, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a60.webp'),
    ('Aria of Emotions', 36, 5, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a61.webp'),
    ('Melodic Bliss', 35, 6, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a62.webp'),
    ('Harmonic Harmony', 34, 7, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a63.webp'),
    ('Crescendo Chronicles', 33, 8, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a64.webp'),
    ('Serenade of the Soul', 32, 9, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a65.webp'),
    ('Melodic Moments', 31, 10, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a66.webp'),
    ('Harmony Haven', 30, 1, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a67.webp'),
    ('Serenade Serenity', 29, 2, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a68.webp'),
    ('Harmonic Dreams', 28, 3, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a69.webp'),
    ('Serenity Symphony', 27, 4, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a7.webp'),
    ('Melodic Moments', 26, 5, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a70.webp'),
    ('Harmony Haven', 25, 6, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a71.webp'),
    ('Serenade Serenity', 24, 7, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a72.webp'),
    ('Melodic Meditations', 23, 8, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a73.webp'),
    ('Harmonic Harmony', 22, 9, 'Numerique', 2024, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a74.webp'),
    ('Musical Musings', 21, 10, 'Numerique', 2017, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a75.webp'),
    ('Rhythmic Reverie', 20, 1, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a76.webp'),
    ('Lyrical Landscapes', 19, 2, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a77.webp'),
    ('Sonic Serenity', 18, 3, 'Numerique', 2019, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a78.webp'),
    ('Harmony Hues', 17, 4, 'Numerique', 2023, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a79.webp'),
    ('Melodic Mastery', 16, 5, 'Numerique', 2021, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a8.webp'),
    ('Serenade Symphony', 15, 6, 'Numerique', 2020, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a80.webp'),
    ('Harmonic Hues', 14, 7, 'Numerique', 2018, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a81.webp'),
    ('Lyrical Lullabies', 13, 8, 'Numerique', 2022, 'https://artuneconnectimgs.s3.us-east-2.amazonaws.com/Album+imgs/a82.webp');


-- Chanson
INSERT INTO Chanson (id_album, titre, duree) VALUES
    (56, 'Eternal Echoes', 2.86),
    (103, 'Whispering Winds', 1.23),
    (29, 'Midnight Serenade', 3.55),
    (75, 'Celestial Symphony', 4.01),
    (11, 'Starry Melodies', 2.12),
    (87, 'Harmony of Dreams', 3.89),
    (34, 'Soothing Serenade', 3.21),
    (122, 'Mystic Melodies', 1.98),
    (68, 'Enchanted Euphony', 4.36),
    (91, 'Serene Sonnets', 2.77),
    (142, 'Tranquil Tunes', 0.92),
    (47, 'Melodic Whispers', 3.78),
    (2, 'Whispers of the Heart', 1.45),
    (110, 'Calm Cadence', 2.34),
    (86, 'Echoes of Serenity', 4.22),
    (19, 'Serenade Under the Moonlight', 1.87),
    (5, 'Melodies of Dawn', 3.67),
    (94, 'Dreamy Duets', 0.86),
    (114, 'Dancing in the Rain', 2.99),
    (41, 'Whispers of the Forest', 1.68),
    (127, 'Celestial Lullaby', 3.11),
    (76, 'Harmony of the Ocean', 4.12),
    (24, 'Whispers of the Wind', 2.45),
    (58, 'Serenade of the Stars', 3.88),
    (97, 'Ethereal Elegy', 1.92),
    (6, 'Mystical Melodies', 3.33),
    (83, 'Whispering Waves', 4.44),
    (38, 'Moonlit Melancholy', 2.21),
    (18, 'Serenade for the Soul', 1.34),
    (103, 'Echoes of Twilight', 3.67),
    (52, 'Harmony of the Heavens', 2.76),
    (14, 'Soothing Serenity', 3.09),
    (92, 'Melodies of Memories', 1.57),
    (67, 'Whispers in the Breeze', 2.88),
    (110, 'Celestial Cadence', 3.45),
    (8, 'Dreamy Duet', 1.76),
    (23, 'Serenade of the Night', 3.79),
    (129, 'Tranquil Twilight', 2.22),
    (72, 'Whispers of Solitude', 1.98),
    (51, 'Ethereal Echoes', 3.14),
    (116, 'Moonlit Sonata', 2.67),
    (93, 'Harmony of Dreams', 4.02),
    (35, 'Whispers of the Soul', 1.85),
    (79, 'Celestial Symphony', 3.56),
    (14, 'Mystic Melodies', 2.33),
    (101, 'Whispers in the Mist', 1.44),
    (67, 'Serenade of Serenity', 3.88),
    (41, 'Lullaby of the Stars', 2.99),
    (92, 'Tranquil Tranquility', 1.76),
    (58, 'Echoes of Eternity', 3.21),
    (19, 'Soothing Serenade', 2.45),
    (87, 'Celestial Serenade', 1.98),
    (108, 'Melody of Moonlight', 3.67),
    (10, 'Whispers of Dawn', 2.12),
    (134, 'Serenade of the Stars', 3.12),
    (48, 'Harmony of the Heart', 2.98),
    (76, 'Tranquil Waters', 4.22),
    (63, 'Ethereal Embrace', 3.67),
    (28, 'Whispers of the Wind', 1.88),
    (105, 'Soothing Serenity', 2.56),
    (82, 'Lullaby of the Moon', 3.01),
    (91, 'Celestial Cadence', 2.33),
    (55, 'Serenade of Solace', 1.99),
    (13, 'Melody of Memories', 3.45),
    (126, 'Whispers of the Ocean', 2.78),
    (37, 'Harmony of the Cosmos', 4.01),
    (68, 'Tranquil Tranquility', 1.76),
    (114, 'Ethereal Essence', 3.89),
    (77, 'Serenade of Serenity', 3.32),
    (57, 'Lullaby of Love', 2.10),
    (41, 'Celestial Symphony', 3.67),
    (83, 'Melody of the Mountains', 4.00),
    (19, 'Harmony in the Breeze', 2.35),
    (102, 'Serenade of Solitude', 3.79),
    (73, 'Tranquil Reflections', 1.95),
    (136, 'Ethereal Whispers', 3.12),
    (9, 'Whispers of Wonder', 4.11),
    (123, 'Soothing Melodies', 2.88),
    (33, 'Lullaby of the Stars', 3.45),
    (119, 'Celestial Voyage', 2.23),
    (97, 'Serenade of the Soul', 1.99),
    (135, 'Melody of the Universe', 3.56),
    (3, 'Whispers of Hope', 2.78),
    (16, 'Harmony in the Twilight', 4.01),
    (64, 'Tranquil Dreams', 1.76),
    (139, 'Ethereal Harmony', 3.89),
    (46, 'Serenade of Serendipity', 3.32),
    (29, 'Lullaby of the Sea', 2.10),
    (66, 'Celestial Serenade', 3.67),
    (85, 'Melody of the Sun', 4.00),
    (62, 'Whispers of the Forest', 2.95),
    (101, 'Harmony in the Meadows', 3.24),
    (56, 'Serenade of Serenity', 1.88),
    (72, 'Tranquil Waters', 2.67),
    (81, 'Ethereal Echoes', 4.23),
    (30, 'Whispers of the Wind', 3.11),
    (109, 'Soothing Serenade', 2.44),
    (117, 'Lullaby of the Moon', 3.78),
    (134, 'Celestial Symphony', 2.99),
    (5, 'Melody of Dreams', 1.75),
    (43, 'Harmony in Harmony', 4.32),
    (12, 'Serenade of Solace', 2.56),
    (41, 'Tranquil Tranquility', 3.89),
    (114, 'Ethereal Essence', 2.34),
    (58, 'Whispers of Peace', 3.01),
    (93, 'Harmony of Hope', 4.10),
    (26, 'Serenade of Serenity', 2.87),
    (71, 'Tranquil Moments', 3.45),
    (22, 'Whispers of the Ocean', 3.67),
    (99, 'Harmony in Bloom', 2.88),
    (37, 'Serenade of Sunset', 1.99),
    (63, 'Tranquil Twilight', 4.21),
    (88, 'Ethereal Elegance', 3.33),
    (18, 'Melody of Memories', 2.45),
    (119, 'Soothing Serenade', 3.78),
    (26, 'Lullaby of the Stars', 4.01),
    (137, 'Celestial Serenity', 3.25),
    (10, 'Harmony in Motion', 1.85),
    (48, 'Melody of Tranquility', 4.10),
    (7, 'Serenade of Sunrise', 2.59),
    (46, 'Tranquil Waters', 3.14),
    (111, 'Ethereal Echo', 3.93),
    (52, 'Whispers of Wisdom', 2.76),
    (95, 'Harmony of the Heart', 3.20),
    (29, 'Serenade of Serenity', 3.45),
    (77, 'Tranquil Dreams', 2.98),
    (72, 'Whispers of the Wind', 1.95),
    (104, 'Harmony of Hope', 4.30),
    (88, 'Serenade of Spring', 3.89),
    (15, 'Tranquil Melodies', 2.25),
    (41, 'Ethereal Embrace', 3.60),
    (93, 'Melody of Moonlight', 3.75),
    (128, 'Soothing Symphony', 2.88),
    (55, 'Celestial Lullaby', 4.10),
    (37, 'Harmony in Harmony', 3.15),
    (81, 'Whispers of Whimsy', 1.85),
    (63, 'Serenade of Solitude', 3.20),
    (120, 'Tranquil Echoes', 2.95),
    (22, 'Ethereal Enchantment', 3.40),
    (97, 'Melody of Morning', 2.55),
    (49, 'Harmony of Hearts', 4.05),
    (19, 'Serenade of Sunshine', 2.70),
    (113, 'Tranquil Symphony', 3.33),
    (66, 'Ethereal Essence', 3.80),
    (14, 'Whispers of Wonder', 1.80),
    (107, 'Harmony of Dreams', 4.20),
    (85, 'Serenade of Serenity', 3.95),
    (26, 'Tranquil Serenade', 2.10),
    (44, 'Ethereal Elegance', 3.50),
    (91, 'Melody of Memories', 3.65),
    (124, 'Soothing Serenade', 2.75),
    (57, 'Celestial Harmony', 4.15),
    (33, 'Harmony in Motion', 3.05),
    (77, 'Whispers of Wisdom', 1.90),
    (69, 'Serenade of Stars', 3.10),
    (117, 'Tranquil Tranquility', 2.85),
    (18, 'Ethereal Symphony', 3.30),
    (99, 'Melody of Midnight', 2.45),
    (53, 'Harmony of Hopes', 4.00),
    (23, 'Serenade of Silence', 2.60),
    (109, 'Tranquil Tunes', 3.40),
    (72, 'Ethereal Echoes', 3.75),
    (136, 'Whispers of the Wind', 2.85),
    (62, 'Harmony in Harmony', 1.95),
    (130, 'Serenade of Sunshine', 4.10),
    (39, 'Tranquil Melodies', 3.25),
    (138, 'Ethereal Embrace', 2.30),
    (119, 'Melody of Morning', 3.80),
    (113, 'Harmony of Hearts', 2.55),
    (76, 'Serenade of Serendipity', 1.75),
    (134, 'Tranquil Tranquility', 3.15),
    (29, 'Ethereal Essence', 4.30),
    (96, 'Whispers of the Woods', 3.35),
    (142, 'Harmony of Hope', 2.90),
    (121, 'Serenade of Summer', 1.80),
    (97, 'Tranquil Thoughts', 3.70),
    (92, 'Ethereal Euphoria', 2.40),
    (100, 'Melody of Moonlight', 3.45),
    (48, 'Harmony of Harmony', 2.65),
    (109, 'Serenade of Solitude', 3.20),
    (83, 'Whispers in the Night', 2.20),
    (104, 'Serenade of Stars', 3.90),
    (25, 'Melody of Memories', 3.60),
    (75, 'Harmony of Happiness', 1.85),
    (115, 'Tranquil Tide', 3.05),
    (35, 'Ethereal Echoes', 4.15),
    (67, 'Whispers of Whimsy', 2.75),
    (123, 'Serenade of Sorrow', 1.70),
    (95, 'Melody of Midnight', 3.50),
    (56, 'Harmony of Healing', 2.60),
    (86, 'Tranquil Tranquility', 3.25),
    (137, 'Ethereal Dreams', 2.95),
    (102, 'Whispers of Wonder', 2.30),
    (110, 'Serenade of Silence', 3.10),
    (131, 'Melody of Magic', 3.75),
    (78, 'Harmony of Harmony', 1.95),
    (46, 'Tranquil Reflections', 3.40),
    (99, 'Ethereal Enchantment', 2.50),
    (121, 'Whispers of Wisdom', 2.85),
    (70, 'Serenade of Serenity', 1.80),
    (34, 'Melody of Morning', 4.05),
    (89, 'Harmony of Hope', 2.15),
    (52, 'Tranquil Melancholy', 3.55),
    (98, 'Ethereal Essence', 2.45),
    (112, 'Whispers of Wonders', 2.25),
    (47, 'Serenade of Solitude', 1.75),
    (81, 'Melody of Mirth', 2.05),
    (29, 'Harmony of Hearts', 3.95),
    (107, 'Tranquil Moments', 3.15),
    (60, 'Ethereal Bliss', 2.75),
    (77, 'Whispers of the Wind', 2.20),
    (94, 'Serenade of Solace', 1.65),
    (113, 'Melody of Mystery', 2.15),
    (51, 'Harmony of Harmony', 4.10),
    (64, 'Tranquil Symphony', 3.30),
    (90, 'Ethereal Whispers', 2.65),
    (124, 'Song of Serenity', 1.90),
    (78, 'Melody of Memories', 2.25),
    (42, 'Harmony of Happiness', 3.75),
    (101, 'Whispers of Wonder', 2.35),
    (55, 'Serenade of Sunset', 1.80),
    (87, 'Tranquil Echoes', 3.10),
    (37, 'Ethereal Dreams', 2.85),
    (115, 'Song of Solace', 1.95),
    (68, 'Melody of Moonlight', 2.65),
    (91, 'Harmony of Hope', 3.45),
    (105, 'Whispers of the Heart', 2.15),
    (58, 'Serenade of Stars', 1.70),
    (83, 'Tranquil Reflections', 3.30),
    (46, 'Ethereal Essence', 2.50),
    (110, 'Song of Serendipity', 2.05),
    (63, 'Melody of Morning', 3.85),
    (74, 'Harmony of Harmony', 4.00),
    (99, 'Whispers of Wisdom', 2.40),
    (20, 'Dreams of Dawn', 1.45),
    (132, 'Melody of Midnight', 3.20),
    (89, 'Harmony of Hues', 2.75),
    (50, 'Whispers of Wind', 2.60),
    (79, 'Serenade of Silence', 1.95),
    (105, 'Tranquil Tides', 3.05),
    (68, 'Ethereal Enchantment', 2.30),
    (118, 'Song of Serenity', 1.80),
    (55, 'Melody of Moonlight', 2.90),
    (93, 'Harmony of Heaven', 3.65),
    (109, 'Whispers of Wonder', 2.25),
    (58, 'Serenade of Serenity', 1.60),
    (87, 'Tranquil Twilight', 3.40),
    (41, 'Ethereal Elegance', 2.20),
    (114, 'Song of Solitude', 2.10),
    (63, 'Melody of Magic', 3.75),
    (74, 'Harmony of Harmony', 3.90),
    (98, 'Whispers of Whimsy', 2.35),
    (25, 'Echoes of Eternity', 1.85),
    (137, 'Serenade of Stars', 2.15),
    (104, 'Melody of Memories', 3.30),
    (91, 'Harmony of Hope', 2.50),
    (113, 'Whispers of Wilderness', 3.15),
    (69, 'Tranquil Tranquility', 2.70),
    (54, 'Ethereal Echo', 1.95),
    (122, 'Song of Solace', 2.80),
    (61, 'Melody of Mirth', 1.60),
    (81, 'Harmony of Heartstrings', 3.45),
    (96, 'Whispers of Wisdom', 2.75),
    (49, 'Serenade of Spring', 3.05),
    (76, 'Tranquil Tempest', 2.20),
    (33, 'Ethereal Essence', 1.75),
    (126, 'Song of the Sea', 3.10),
    (71, 'Melody of Mystery', 2.40),
    (84, 'Harmony of Happiness', 1.90),
    (115, 'Whispers of Wonders', 2.65),
    (112, 'Echoes of Emotion', 2.90),
    (19, 'Serenade of Serenity', 3.25),
    (57, 'Melody of Moonlight', 2.15),
    (132, 'Harmony of Hues', 3.40),
    (28, 'Whispers of Whimsy', 2.70),
    (89, 'Tranquil Twilight', 1.85),
    (40, 'Ethereal Enchantment', 3.15),
    (101, 'Song of Sorrow', 2.55),
    (130, 'Melody of Morning', 3.00),
    (66, 'Harmony of Heaven', 2.35),
    (138, 'Whispers of the Wind', 1.95),
    (15, 'Serenade of Silence', 2.20),
    (127, 'Tranquil Tides', 3.30),
    (92, 'Ethereal Elegance', 2.45),
    (108, 'Song of Serendipity', 1.80),
    (82, 'Melody of Midnight', 3.10),
    (98, 'Harmony of Hope', 2.65),
    (35, 'Whispers of Wonder', 2.00),
    (72, 'Serenade of Solitude', 2.25),
    (50, 'Echoes of Eternity', 3.05),
    (121, 'Harmony of Heartache', 2.80),
    (11, 'Melody of Memories', 1.95),
    (107, 'Whispers of the Wild', 3.20),
    (84, 'Tranquil Tempest', 2.50),
    (36, 'Ethereal Echoes', 2.75),
    (124, 'Song of Solace', 3.35),
    (16, 'Melody of Madness', 1.85),
    (94, 'Harmony of the Highlands', 3.10),
    (31, 'Whispers of Whispers', 2.15),
    (137, 'Tranquil Tremors', 2.95),
    (41, 'Ethereal Embrace', 3.40),
    (100, 'Song of Serenity', 2.65),
    (76, 'Melody of Mystery', 1.90),
    (102, 'Harmony of the Hills', 3.25),
    (25, 'Whispers of Wishes', 2.05),
    (88, 'Tranquil Tranquility', 2.70),
    (61, 'Serenade of Serenity', 3.15),
    (15, 'Echoes of Emotion', 2.30),
    (113, 'Harmony of Hope', 3.05),
    (92, 'Melody of Magic', 1.80),
    (78, 'Whispers of Wonder', 2.45),
    (20, 'Tranquil Tales', 3.25),
    (128, 'Ethereal Enchantment', 2.90),
    (54, 'Song of Serendipity', 3.30),
    (33, 'Melody of Miracles', 1.75),
    (102, 'Harmony of Happiness', 3.10),
    (47, 'Whispers of Whimsy', 2.50),
    (142, 'Tranquil Tranquility', 3.15),
    (40, 'Ethereal Essence', 2.85),
    (95, 'Song of Sorrow', 3.20),
    (81, 'Melody of Mirth', 1.85),
    (108, 'Harmony of Harmony', 3.25),
    (26, 'Whispers of Wisdom', 2.55),
    (85, 'Tranquil Thoughts', 3.05),
    (71, 'Serenade of Solitude', 3.40),
    (7, 'Echoes of Euphoria', 2.95),
    (120, 'Harmony of Healing', 3.15),
    (99, 'Melody of Mystery', 1.90),
    (62, 'Whispers of Warmth', 2.60),
    (25, 'Tranquil Tunes', 3.35),
    (135, 'Ethereal Embrace', 2.75),
    (59, 'Song of Silence', 3.10),
    (45, 'Melody of Marvel', 1.65),
    (105, 'Harmony of Harmony', 3.30),
    (17, 'Whispers of Wonders', 2.70),
    (138, 'Tranquil Tributes', 3.25),
    (38, 'Ethereal Escapes', 2.80),
    (89, 'Song of Serenity', 3.05),
    (75, 'Melody of Memories', 2.00),
    (114, 'Harmony of Hope', 3.20),
    (29, 'Whispers of Whispers', 2.65),
    (80, 'Tranquil Transitions', 3.20),
    (92, 'Melodic Journey', 2.45),
    (12, 'Harmonious Bliss', 3.00),
    (67, 'Soothing Symphony', 2.85),
    (50, 'Whispers in the Wind', 2.15),
    (109, 'Rhythmic Reverie', 3.40),
    (34, 'Mystical Melodies', 1.80),
    (126, 'Serene Serenade', 3.10),
    (19, 'Tranquil Harmony', 2.55),
    (88, 'Ethereal Echoes', 2.90),
    (55, 'Melodic Memories', 2.25),
    (41, 'Harmonic Haven', 3.35),
    (132, 'Serenade of Dreams', 3.25),
    (72, 'Whispers of Wisdom', 2.75),
    (83, 'Ethereal Essence', 3.05),
    (96, 'Song of Solace', 2.35),
    (58, 'Melodic Muse', 2.10),
    (37, 'Harmonious Haven', 3.30),
    (101, 'Tranquil Tributaries', 2.95),
    (25, 'Serenade of Stars', 1.95),
    (77, 'Harmonious Whispers', 3.20),
    (113, 'Melodic Whispers', 2.65),
    (63, 'Soothing Serenade', 2.80),
    (85, 'Ethereal Euphony', 3.15),
    (47, 'Whispers of Wonder', 2.40),
    (119, 'Tranquil Tranquility', 3.05),
    (14, 'Rhythmic Reflections', 2.20),
    (104, 'Serenade of Silence', 3.35),
    (68, 'Melodic Meditations', 2.75),
    (27, 'Harmony of Hope', 1.85),
    (121, 'Ethereal Enchantment', 3.25),
    (93, 'Whispers of Wisdom', 2.45),
    (16, 'Tranquil Twilight', 2.30),
    (129, 'Soothing Soundscape', 3.40),
    (71, 'Melodic Murmurs', 2.70),
    (39, 'Harmonious Harmony', 3.10),
    (99, 'Rhythmic Reverberations', 2.90),
    (51, 'Whispers of the Wind', 2.50),
    (132, 'Serenade of Solitude', 3.45),
    (109, 'Melodic Memories', 3.00),
    (33, 'Harmony in the Night', 2.10),
    (94, 'Ethereal Echoes', 2.50),
    (41, 'Rhythmic Reflection', 2.15),
    (123, 'Tranquil Tranquility', 3.30),
    (79, 'Serenade of Serenity', 2.80),
    (38, 'Harmony of Hearts', 2.90),
    (104, 'Melodic Musings', 3.10),
    (54, 'Whispers of the Heart', 2.40),
    (135, 'Ethereal Essence', 3.20),
    (88, 'Tranquil Melodies', 2.70),
    (12, 'Soothing Serenade', 2.20),
    (101, 'Harmonious Melancholy', 2.60),
    (67, 'Melodic Mysteries', 3.00),
    (25, 'Rhythmic Rhapsody', 2.30),
    (142, 'Serenade of Dreams', 3.40),
    (22, 'Harmony of Hope', 1.90),
    (76, 'Whispers in the Woods', 2.80),
    (117, 'Melodic Whispers', 3.20),
    (48, 'Serenade of Solace', 2.50),
    (91, 'Tranquil Symphony', 2.70),
    (7, 'Echoes of Emotion', 1.80),
    (57, 'Harmony of Happiness', 2.60),
    (130, 'Rhythmic Reverie', 3.10),
    (98, 'Serenade of Sunset', 2.90),
    (16, 'Melodic Memories', 2.00),
    (34, 'Whispers of Wisdom', 2.10),
    (106, 'Ethereal Elegance', 3.00),
    (83, 'Tranquil Serenity', 2.40),
    (114, 'Harmonious Echoes', 3.30),
    (71, 'Rhythmic Reflections', 2.70),
    (37, 'Serenade of Stars', 2.20),
    (128, 'Melodic Moments', 3.20),
    (19, 'Harmony of the Heart', 1.80),
    (108, 'Whispers of the Wind', 3.40),
    (63, 'Melody of Memories', 2.30),
    (25, 'Serenade of Sunshine', 1.90),
    (82, 'Tranquil Tranquility', 2.50),
    (51, 'Harmony in Harmony', 2.10),
    (39, 'Rhythmic Raindrops', 2.70),
    (121, 'Melodic Mosaic', 3.10),
    (95, 'Serenade of Serenity', 2.80),
    (72, 'Whispers of the Heart', 2.20),
    (13, 'Melody of Magic', 1.80),
    (42, 'Harmony of Dreams', 2.30),
    (104, 'Tranquil Tunes', 2.60),
    (87, 'Rhythmic Rhapsody', 2.90),
    (54, 'Melodic Musings', 2.40),
    (33, 'Serenade of Silence', 2.00),
    (136, 'Whispers of Wonder', 3.00),
    (66, 'Harmony of the Soul', 2.50),
    (28, 'Rhythmic Reflection', 2.20),
    (94, 'Serenade of Solitude', 2.70),
    (41, 'Melodic Moments', 2.10),
    (127, 'Tranquil Twilight', 3.20),
    (79, 'Harmony of Hope', 2.30),
    (18, 'Rhythmic Reverie', 1.90),
    (58, 'Serenade of the Stars', 2.60),
    (37, 'Melody of the Moon', 2.40),
    (110, 'Tranquil Tempo', 2.80),
    (71, 'Harmony in Motion', 2.20),
    (30, 'Rhythmic Resonance', 2.00),
    (134, 'Serenade of Sorrow', 3.00),
    (85, 'Melodic Mysteries', 2.50),
    (45, 'Tranquil Tales', 2.70),
    (105, 'Harmony of the Heart', 2.40),
    (20, 'Rhythmic Radiance', 2.10),
    (77, 'Serenade of Serendipity', 2.90),
    (50, 'Melody of Miracles', 2.30),
    (35, 'Tranquil Tranquility', 2.60),
    (1, 'Whispers in the Wind', 1.80),
    (2, 'Echoes of Eternity', 1.95),
    (3, 'Harmony of the Heart', 2.20),
    (4, 'Melodic Memories', 2.10),
    (5, 'Serenade of the Soul', 2.30),
    (6, 'Tranquil Tranquility', 2.40),
    (7, 'Rhythmic Reverie', 2.15),
    (8, 'Melody of the Moon', 2.25),
    (9, 'Symphony of Serenity', 2.50),
    (10, 'Harmony in Motion', 2.35),
    (11, 'Serenade of Solitude', 2.60),
    (12, 'Melodic Moments', 2.45),
    (13, 'Tranquil Tempo', 2.70),
    (14, 'Rhythmic Resonance', 2.55),
    (15, 'Serenade of Sorrow', 2.80),
    (16, 'Melodic Mysteries', 2.65),
    (17, 'Harmony of the Heart', 2.90),
    (18, 'Rhythmic Radiance', 2.75),
    (19, 'Dreams of Destiny', 1.85),
    (20, 'Echoes of Emotion', 2.05),
    (21, 'Harmony Haven', 2.15),
    (22, 'Melodic Muse', 2.25),
    (23, 'Serenade in the Sunset', 2.35),
    (24, 'Tranquil Tales', 2.45),
    (25, 'Rhythmic Reflections', 2.55),
    (26, 'Melody of Memories', 2.65),
    (27, 'Symphony of Stars', 2.75),
    (28, 'Harmony in Harmony', 2.85),
    (29, 'Serenade of Silence', 2.95),
    (30, 'Melodic Melancholy', 3.05),
    (31, 'Tranquil Tunes', 3.15),
    (32, 'Rhythmic Reverberations', 3.25),
    (33, 'Serenade under the Stars', 3.35),
    (34, 'Melody of the Morning', 3.45),
    (35, 'Harmony of Hope', 3.55),
    (36, 'Rhythmic Rhapsody', 3.65),
    (37, 'Whispers in the Wind', 1.85),
    (38, 'Echoes of Eternity', 2.05),
    (39, 'Harmony in the Heart', 2.15),
    (40, 'Melodic Memories', 2.25),
    (41, 'Serenade of Serenity', 2.35),
    (42, 'Tranquil Symphony', 2.45),
    (43, 'Rhythmic Resonance', 2.55),
    (44, 'Melody of Magic', 2.65),
    (45, 'Symphony of Serendipity', 2.75),
    (46, 'Harmony in Motion', 2.85),
    (47, 'Serenade of Solitude', 2.95),
    (48, 'Melodic Harmony', 3.05),
    (49, 'Tranquil Echoes', 3.15),
    (50, 'Rhythmic Reverie', 3.25),
    (51, 'Serenade of Sorrow', 3.35),
    (52, 'Melody in Motion', 3.45),
    (53, 'Harmony of the Heart', 3.55),
    (54, 'Rhythmic Reflection', 3.65),
    (55, 'Echoes of Emotion', 1.9),
    (56, 'Harmony in Harmony', 2.1),
    (57, 'Melodic Melancholy', 2.3),
    (58, 'Serenade of Sunset', 2.5),
    (59, 'Tranquil Tunes', 2.7),
    (60, 'Rhythmic Reverberations', 2.9),
    (61, 'Symphony of Stars', 3.1),
    (62, 'Harmonys Hymn', 3.3),
    (63, 'Serenade of the Sea', 3.5),
    (64, 'Melody in Moonlight', 3.7),
    (65, 'Tranquil Twilight', 3.9),
    (66, 'Rhythmic Reflections', 4.1),
    (67, 'Symphony of Dreams', 4.3),
    (68, 'Harmonys Hope', 4.2),
    (69, 'Serenade of Solace', 4.4),
    (70, 'Melodic Mosaic', 4.0),
    (71, 'Tranquil Trails', 3.8),
    (72, 'Rhythmic Rapture', 3.6),
    (73, 'Tranquil Symphony', 1.9),
    (74, 'Whispers of Twilight', 2.1),
    (75, 'Echoes of Emotion', 3.5),
    (76, 'Harmony in Motion', 1.9),
    (77, 'Melodic Whispers', 2.3),
    (78, 'Serenade of Solitude', 2.7),
    (79, 'Tranquil Melodies', 3.1),
    (80, 'Rhythmic Reverie', 1.5),
    (81, 'Symphony of Dreams', 1.9),
    (82, 'Harmonys Embrace', 2.3),
    (83, 'Melodic Echoes', 2.7),
    (84, 'Serenade of Serendipity', 3.1),
    (85, 'Tranquil Waters', 1.5),
    (86, 'Rhythmic Harmony', 1.9),
    (87, 'Symphony of Serenity', 2.3),
    (88, 'Harmonys Whisper', 2.7),
    (89, 'Melodic Dreamscape', 3.1),
    (90, 'Serenade of Solace', 1.5),
    (91, 'Ethereal Melodies', 2.8),
    (92, 'Soothing Serenade', 3.2),
    (93, 'Harmonic Tranquility', 1.6),
    (94, 'Dreamy Cadence', 2.0),
    (95, 'Melodic Reflections', 2.4),
    (96, 'Serenade of Solitude', 2.8),
    (97, 'Tranquil Reverie', 1.2),
    (98, 'Rhythmic Rhapsody', 1.6),
    (99, 'Symphony of Dreams', 2.0),
    (100, 'Harmonys Embrace', 2.4),
    (101, 'Melodic Echoes', 2.8),
    (102, 'Serenade of Serenity', 1.2),
    (103, 'Tranquil Waters', 1.6),
    (104, 'Rhythmic Harmony', 2.0),
    (105, 'Symphony of Serenity', 2.4),
    (106, 'Harmonys Whisper', 2.8),
    (107, 'Melodic Dreamscape', 1.2),
    (108, 'Serenade of Solace', 1.6),
    (109, 'Ethereal Journey', 3.1),
    (110, 'Soothing Melancholy', 2.5),
    (111, 'Harmonic Whispers', 2.2),
    (112, 'Dreamy Melodies', 1.8),
    (113, 'Melodic Harmony', 3.0),
    (114, 'Serenade of Hope', 2.7),
    (115, 'Tranquil Symphony', 2.3),
    (116, 'Rhythmic Echoes', 1.5),
    (117, 'Symphony of Tranquility', 2.0),
    (118, 'Harmonys Bliss', 2.9),
    (119, 'Melodic Serenade', 2.4),
    (120, 'Serenade of Reflection', 1.7),
    (121, 'Tranquil Melodies', 2.1),
    (122, 'Rhythmic Harmony', 2.6),
    (123, 'Symphony of Dreams', 3.2),
    (124, 'Harmonys Essence', 2.8),
    (125, 'Melodic Reverie', 2.2),
    (126, 'Serenade of Tranquility', 1.9),
    (127, 'Ethereal Whispers', 3.5),
    (128, 'Soothing Serenade', 1.8),
    (129, 'Harmonic Dreams', 2.1),
    (130, 'Dreamy Serenity', 2.9),
    (131, 'Melodic Echo', 1.6),
    (132, 'Serenade of Solitude', 2.3),
    (133, 'Tranquil Reflections', 2.7),
    (134, 'Rhythmic Reverie', 3.2),
    (135, 'Symphony of Serenity', 1.9),
    (136, 'Harmonys Journey', 2.5),
    (137, 'Melodic Whispers', 2.0),
    (138, 'Serenade of the Night', 1.4),
    (139, 'Tranquil Symphony', 2.6),
    (140, 'Rhythmic Melancholy', 2.4),
    (141, 'Symphony of Stars', 3.0),
    (142, 'Harmonic Melodies', 2.2);

-- Transaction (aucunes données initiales)

-- Noter (aucunes données initiales)

-- Suivre (aucunes données initiales)

-- tests?