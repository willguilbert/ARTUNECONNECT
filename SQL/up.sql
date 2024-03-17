CREATE DATABASE ARTUNECONNECT;

CREATE TABLE Utilisateur (
    id_utilisateur INTEGER,
    -- nom_utilisateur VARCHAR(16),
    nom VARCHAR(32),
    prenom VARCHAR(32),
    email VARCHAR(64),
    mot_de_passe VARCHAR(32),
    age INTEGER,
    photo_de_profil VARCHAR(256),
    bio varchar(1024),
    liens_reseaux_sociaux VARCHAR(256),
    id_region INTEGER, -- NOT NULL enlevé, car ON DELETE SET NULL

    PRIMARY KEY (id_utilisateur),
    FOREIGN KEY (id_region) REFERENCES Region (id_region) ON DELETE SET NULL,
    UNIQUE (email)
);

/*

SI EMAIL EST UNIQUE(), HANDLER VA SEN OCCUPER COTE SERVEUR

DELIMITER //
CREATE TRIGGER utilisateur_existe_deja BEFORE INSERT ON Utilisateur FOR EACH ROW
    BEGIN
        IF (
            (SELECT COUNT(*) FROM Utilisateur U WHERE U.email = new.email
            AND U.mot_de_passe = new.mot_de_passe) <> 0
            OR
            (SELECT COUNT(*) FROM Utilisateur U WHERE U.nom_utilisateur = new.nom_utilisateur
            AND U.mot_de_passe = new.mot_de_passe) <> 0
        ) THEN
            -- a modifier
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le compte existe déja.';
            -- rediriger vers log-in (serveur)
        -- else a ajouter?

        end if ;
    end //

DELIMITER ;

*/


/*------------------------------------------------------------------------------------------------------*/

-- UNIVERSITE

CREATE TABLE Universite (
    id_universite INTEGER,
    nom VARCHAR(64),
    id_region INTEGER, -- NOT NULL enlevé, car ON DELETE SET NULL

    PRIMARY KEY (id_universite),
    FOREIGN KEY (id_region) REFERENCES Region (id_region) ON DELETE SET NULL
);


INSERT INTO Universite (id_universite, nom, id_region) VALUES
    (1, 'Université du Québec en Abitibi-Témiscamingue', 1),
    (2, 'Université du Québec à Rimouski', 2),
    (3, 'École nationale d’administration publique', 3),
    (4, 'Institut national de la recherche scientifique', 3),
    (5, 'Université Laval', 3),
    (6, 'Université Bishop’s', 4),
    (7, 'Université de Sherbrooke', 4),
    (8, 'Université du Québec à Trois-Rivières', 5),
    (9, 'École des hautes études commerciales de Montréal', 6),
    (10, 'École de technologie supérieure', 6),
    (11, 'Polytechnique Montréal', 6),
    (12, 'Université Concordia', 6),
    (13, 'Université de Montréal', 6),
    (14, 'Université McGill', 6),
    (15, 'Université du Québec à Montréal', 6),
    (16, 'Université du Québec en Outaouais', 7),
    (17, 'Université du Québec à Chicoutimi', 8);

/*
DELIMITER //
CREATE TRIGGER nouvelle_uni BEFORE INSERT ON Universite FOR EACH ROW

    BEGIN
        IF new.id_region NOT IN (SELECT id_region FROM Region) THEN
            INSERT INTO Region VALUES (
                new.id_region, IDK
                );
        end if ;
    end //
DELIMITER ;
*/

/*------------------------------------------------------------------------------------------------------*/

-- REGION

CREATE TABLE Region (
    id_region INTEGER,
    nom VARCHAR(64),

    PRIMARY KEY (id_region)
);


INSERT INTO Region (id_region, nom) VALUES
    (1, 'Abitibi-Témiscamingue'),
    (2, 'Bas-Saint-Laurent'),
    (3, 'Capitale-Nationale'),
    (4, 'Estrie'),
    (5, 'Mauricie'),
    (6, 'Montréal'),
    (7, 'Outaouais'),
    (8, 'Saguenay – Lac-Saint-Jean');

/*------------------------------------------------------------------------------------------------------*/

-- Artiste

CREATE TABLE Artiste (
    id_artiste INTEGER,
    nom_artiste VARCHAR(32),
    email_artiste VARCHAR(64),
    biographie_artiste VARCHAR(1024),
    origine VARCHAR(32),
    id_universite INTEGER, -- NOT NULL enlevé, car ON DELETE SET NULL
    -- STYLES SOIT FOREIGN KEY OU ATTRIBUT COMPOSÉ

    PRIMARY KEY (id_artiste),
    FOREIGN KEY (id_universite) REFERENCES Universite (id_universite) ON DELETE SET NULL
);

INSERT INTO Artiste (id_artiste, nom_artiste, email_artiste, biographie_artiste, origine, id_universite) VALUES
    (1, 'Emily Serenade', 'emily.serenade@gmail.com', 'Crafting enchanting serenades that linger in the heart like a sweet melody.', 'Fredericton', 5),
    (2, 'Marcus Melody', 'marcus.melody@outlook.com', 'Embarking on a musical journey, weaving diverse melodies into a harmonious symphony.', 'Montreal', 13),
    (3, 'Olivia Echo', 'olivia.echo@gmail.com', 'Creating echoes of emotion through every note, a reflection of the soul in music.', 'Saguenay', 3),
    (4, 'Dylan Harmony', 'dylan.harmony@videotron.ca', 'Harmony in every chord, crafting musical pieces that resonate with the heart.', 'Halifax', 14),
    (5, 'Ava Rhythm', 'ava.rhythm@gmail.com', 'Exploring the rhythmic landscapes of sound, creating vibrant and dynamic compositions.', 'Charlottetown', 6),
    (6, 'Ethan Songstress', 'ethan.songstress@outlook.com', 'A songstress in the realm of emotions, translating feelings into beautiful melodies.', 'Rimouski', 2),
    (7, 'Lily Composer', 'lily.composer@gmail.com', 'Composing musical tales that unfold like a story, each note a chapter of emotions.', 'Hamilton', 11),
    (8, 'Noah Lullaby', 'noah.lullaby@videotron.ca', 'Crafting lullabies that cradle the soul, creating a serene musical sanctuary.', 'Ottawa', 15),
    (9, 'Sophia Harmony', 'sophia.harmony@gmail.com', 'Harmony as a language, conveying emotions and stories through musical unity.', 'Kingston', 10),
    (10, 'Benjamin Melodies', 'benjamin.melodies@outlook.com', 'Melodies that dance through the air, each one telling a unique musical story.', 'Bathurst', 6),
    (11, 'Grace Harmony', 'grace.harmony@gmail.com', 'Harmony as the canvas, painting emotions with the vibrant colors of musical notes.', 'Trois-Rivières', 5),
    (12, 'Jack Serenader', 'jack.serenader@videotron.ca', 'A serenader at heart, enchanting audiences with soulful and melodious performances.', 'Quebec City', 13),
    (13, 'Chloe Rhythms', 'chloe.rhythms@gmail.com', 'Exploring rhythmic landscapes, creating intricate patterns that resonate with the heartbeat.', 'Toronto', 14),
    (14, 'Lucas Sonata', 'lucas.sonata@outlook.com', 'Crafting musical sonatas that weave a tapestry of emotions, each movement a journey.', 'London', 6),
    (15, 'Mia Melodic', 'mia.melodic@videotron.ca', 'Diving into the world of melody, creating tunes that evoke a myriad of emotions.', 'Windsor', 2),
    (16, 'Owen Crescendo', 'owen.crescendo@gmail.com', 'Building crescendos that rise and fall, capturing the essence of musical expression.', 'Sherbrooke', 6),
    (17, 'Zoe Harmony', 'zoe.harmony@outlook.com', 'Harmony as a guiding light, leading listeners through a melodic journey of emotions.', 'Kingston', 10),
    (18, 'Caleb Muse', 'caleb.muse@videotron.ca', 'Drawing inspiration from the muses, creating music that transcends artistic boundaries.', 'Montreal', 15),
    (19, 'Harper Serenade', 'harper.serenade@gmail.com', 'Serenading the soul with gentle tunes, creating a harmonious connection with emotions.', 'Ottawa', 10),
    (20, 'Isaac Harmonizer', 'isaac.harmonizer@outlook.com', 'Harmonizing sounds with precision, creating a musical blend that resonates with the spirit.', 'Quebec City', 6),
    (21, 'Amelia Cadence', 'amelia.cadence@gmail.com', 'Weaving intricate cadences that dance through the air like poetry set to music.', 'Halifax', 5),
    (22, 'Logan Harmony', 'logan.harmony@outlook.com', 'Exploring the harmonious realms of sound, creating melodies that resonate with the heart.', 'Charlottetown', 13),
    (23, 'Isabella Melody', 'isabella.melody@gmail.com', 'Crafting enchanting melodies that linger in the soul, like a timeless and sweet melody.', 'Saguenay', 3),
    (24, 'Aiden Serenade', 'aiden.serenade@videotron.ca', 'A serenader at heart, creating musical tales that captivate and enchant the listener.', 'Sherbrooke', 14),
    (25, 'Emma Rhythms', 'emma.rhythms@gmail.com', 'Exploring rhythmic landscapes, creating vibrant and dynamic compositions that echo with emotion.', 'Ottawa', 6),
    (26, 'Oliver Lyricist', 'oliver.lyricist@outlook.com', 'Crafting poetic lyrics that intertwine with melodies, creating a symphony of emotions.', 'Kingston', 2),
    (27, 'Ava Harmonics', 'ava.harmonics@gmail.com', 'Exploring the intricate harmonics of sound, creating a musical tapestry that resonates.', 'Toronto', 11),
    (28, 'Elijah Melodic', 'elijah.melodic@videotron.ca', 'Diving into the world of melody, creating tunes that evoke a myriad of emotions.', 'Montreal', 15),
    (29, 'Sophia Sonnet', 'sophia.sonnet@outlook.com', 'Crafting musical sonnets that tell stories through notes, each one a poetic expression.', 'Quebec City', 10),
    (30, 'Mason Harmony', 'mason.harmony@gmail.com', 'Harmony as a guiding light, leading listeners through a melodic journey of emotions.', 'Trois-Rivières', 5),
    (31, 'Abigail Composer', 'abigail.composer@videotron.ca', 'Composing musical tales that unfold like a story, each note a chapter of emotions.', 'Halifax', 6),
    (32, 'Jackson Lullaby', 'jackson.lullaby@gmail.com', 'Crafting lullabies that cradle the soul, creating a serene musical sanctuary.', 'Windsor', 13),
    (33, 'Harper Melodies', 'harper.melodies@outlook.com', 'Melodies that dance through the air, each one telling a unique musical story.', 'Montreal', 14),
    (34, 'Ethan Harmony', 'ethan.harmony@gmail.com', 'Harmony as the canvas, painting emotions with the vibrant colors of musical notes.', 'London', 6),
    (35, 'Addison Crescendo', 'addison.crescendo@videotron.ca', 'Building crescendos that rise and fall, capturing the essence of musical expression.', 'Sherbrooke', 6),
    (36, 'Liam Serenader', 'liam.serenader@gmail.com', 'A serenader at heart, enchanting audiences with soulful and melodious performances.', 'Kingston', 10),
    (37, 'Grace Aria', 'grace.aria@outlook.com', 'Crafting arias that soar through the air, a lyrical journey through the soul of music.', 'Ottawa', 15),
    (38, 'Noah Muse', 'noah.muse@gmail.com', 'Drawing inspiration from the muses, creating music that transcends artistic boundaries.', 'Montreal', 6),
    (39, 'Lily Serenade', 'lily.serenade@videotron.ca', 'Serenading the soul with gentle tunes, creating a harmonious connection with emotions.', 'Quebec City', 10),
    (40, 'Lucas Melody', 'lucas.melody@outlook.com', 'Crafting enchanting melodies that linger in the heart like a sweet melody.', 'Halifax', 5),
    (41, 'Mia Harmony', 'mia.harmony@gmail.com', 'Harmony that resonates with the soul, creating a musical landscape of tranquility and emotion.', 'Ottawa', 6),
    (42, 'Benjamin Crescendo', 'benjamin.crescendo@outlook.com', 'Building crescendos that echo with emotion, a journey through the heights of musical expression.', 'Quebec City', 13),
    (43, 'Stella Serenade', 'stella.serenade@gmail.com', 'Serenading the heart with melodies that shimmer like starlight, a musical journey through the cosmos.', 'Montreal', 15),
    (44, 'Henry Melodic', 'henry.melodic@videotron.ca', 'Exploring the melodic nuances of sound, crafting tunes that resonate with the essence of emotion.', 'Kingston', 6),
    (45, 'Aurora Lullaby', 'aurora.lullaby@gmail.com', 'Crafting lullabies that cradle the soul, creating a serene and enchanting musical dreamscape.', 'Windsor', 11),
    (46, 'Elijah Cadence', 'elijah.cadence@outlook.com', 'Weaving intricate cadences that dance through the air like poetry set to the rhythm of life.', 'Saguenay', 2),
    (47, 'Chloe Composer', 'chloe.composer@videotron.ca', 'Composing musical stories that unfold like a tapestry, each note a stroke in the canvas of emotion.', 'London', 14),
    (48, 'Samuel Lyricist', 'samuel.lyricist@gmail.com', 'Crafting poetic lyrics that resonate with the soul, a lyrical journey through the heart of music.', 'Montreal', 6),
    (49, 'Scarlett Rhythms', 'scarlett.rhythms@outlook.com', 'Exploring rhythmic landscapes, creating vibrant and dynamic compositions that echo with life.', 'Toronto', 10),
    (50, 'Wyatt Serenader', 'wyatt.serenader@videotron.ca', 'A serenader at heart, enchanting listeners with soulful melodies that paint emotions in the air.', 'Sherbrooke', 5),
    (51, 'Penelope Harmonics', 'penelope.harmonics@gmail.com', 'Exploring the intricate harmonics of sound, creating a symphony that resonates with the heart.', 'Halifax', 13),
    (52, 'Leo Muse', 'leo.muse@outlook.com', 'Drawing inspiration from the muses, creating music that transcends boundaries and sparks creativity.', 'Rimouski', 6),
    (53, 'Layla Sonnet', 'layla.sonnet@videotron.ca', 'Crafting musical sonnets that weave tales of love and emotion, creating a lyrical dreamscape.', 'Trois-Rivières', 6),
    (54, 'Jack Melodies', 'jack.melodies@gmail.com', 'Melodies that dance through the air, each note telling a unique story and painting emotions.', 'Montreal', 15),
    (55, 'Zoey Harmony', 'zoey.harmony@outlook.com', 'Harmony that resonates with the essence of life, creating a musical journey through emotions.', 'Quebec City', 10),
    (56, 'Caleb Serenade', 'caleb.serenade@videotron.ca', 'Serenading the soul with gentle tunes, creating a harmonious connection with emotions.', 'Trois-Rivières', 5),
    (57, 'Nora Aria', 'nora.aria@gmail.com', 'Crafting arias that soar through the air, each one a lyrical journey through the heart of music.', 'Windsor', 14),
    (58, 'Logan Melody', 'logan.melody@outlook.com', 'Crafting enchanting melodies that linger in the heart, a sweet and melodic journey through sound.', 'Sherbrooke', 15),
    (59, 'Riley Harmonizer', 'riley.harmonizer@gmail.com', 'Harmonizing the soul with rhythmic precision, creating a symphony of emotional expression.', 'London', 6),
    (60, 'Lucy Serenada', 'lucy.serenada@videotron.ca', 'Serenading the senses with melodies that dance through the air like whispers of musical enchantment.', 'Montreal', 11),
    (61, 'Mason Melodique', 'mason.melodique@gmail.com', 'Exploring melodies with a unique twist, creating a harmonious journey through a tapestry of sound.', 'Montreal', 6),
    (62, 'Ava Harmonique', 'ava.harmonique@outlook.com', 'Harmonizing the soul with enchanting tunes, creating a symphony of emotions through musical expression.', 'Quebec City', 13),
    (63, 'Oliver Crescendo', 'oliver.crescendo@videotron.ca', 'Building crescendos that rise like waves, crafting a musical journey through the heights of emotion.', 'Ottawa', 2),
    (64, 'Sophia Sonore', 'sophia.sonore@gmail.com', 'Exploring the sonorous realm of sound, creating melodies that resonate with the essence of life.', 'Toronto', 11),
    (65, 'Liam Rhapsody', 'liam.rhapsody@outlook.com', 'Embarking on a rhapsodic journey through sound, crafting vibrant and expressive musical compositions.', 'Halifax', 14),
    (66, 'Amelia Vibrato', 'amelia.vibrato@gmail.com', 'Creating vibrato-rich melodies that add a touch of emotion and depth to the musical canvas.', 'St. John', 5),
    (67, 'Jackson Harmonie', 'jackson.harmonie@videotron.ca', 'Crafting a harmonious blend of melodies, creating a symphony that resonates with the soul.', 'Hamilton', 6),
    (68, 'Aria Symphonique', 'aria.symphonique@outlook.com', 'Embarking on a symphonic journey through musical expression, creating an aria of emotional resonance.', 'Kingston', 15),
    (69, 'Noah Serenissimo', 'noah.serenissimo@gmail.com', 'Serenading the senses with tranquility, creating music that unfolds with serenity and grace.', 'London', 6),
    (70, 'Grace Allegro', 'grace.allegro@videotron.ca', 'Crafting allegros that dance with lively rhythms, creating a symphony that pulses with energy.', 'Windsor', 5),
    (71, 'Elijah Cadansa', 'elijah.cadansa@gmail.com', 'Dancing through musical landscapes with cadence, creating compositions that enthrall and captivate.', 'Sherbrooke', 10),
    (72, 'Lily Cantabile', 'lily.cantabile@outlook.com', 'Exploring the cantabile style, crafting melodies that flow with smooth and graceful expression.', 'Trois-Rivières', 6),
    (73, 'Benjamin Sonata', 'benjamin.sonata@gmail.com', 'Crafting sonatas that unfold like musical stories, each movement a journey through emotion and expression.', 'Saguenay', 6),
    (74, 'Mia Lyrique', 'mia.lyrique@videotron.ca', 'Expressing through lyrical compositions, crafting melodies that tell tales of love and emotion.', 'Rimouski', 6),
    (75, 'Lucas Melodista', 'lucas.melodista@gmail.com', 'Channeling a melodista approach, creating music that resonates with a melodic and expressive touch.', 'Bathurst', 11),
    (76, 'Harper Vivace', 'harper.vivace@outlook.com', 'Crafting vivace compositions that burst with life, creating a symphony of vibrant and lively sounds.', 'Montreal', 13),
    (77, 'Ethan Harmonioso', 'ethan.harmonioso@videotron.ca', 'Exploring the harmonioso style, creating harmonious compositions that resonate with tranquility.', 'Quebec City', 6),
    (78, 'Isabella Adagio', 'isabella.adagio@gmail.com', 'Crafting adagios that unfold with grace and elegance, creating a musical journey through the soul.', 'Montreal', 15),
    (79, 'Alexander Forte', 'alexander.forte@outlook.com', 'Expressing through forte compositions, crafting powerful melodies that resonate with strength and intensity.', 'Sherbrooke', 6),
    (80, 'Emma Dolce', 'emma.dolce@videotron.ca', 'Exploring the dolce style, creating melodies that unfold with sweetness and gentle expression.', 'Rimouski', 14),
    (81, 'Sebastian Crescendo', 'sebastian.crescendo@gmail.com', 'Crafting crescendos that rise with intensity, creating a symphony of dynamic and powerful melodies.', 'Montreal', 6),
    (82, 'Scarlett Melodia', 'scarlett.melodia@outlook.com', 'Expressing through melodic compositions, crafting tunes that resonate with the heart and soul.', 'Quebec City', 13),
    (83, 'Henry Serenade', 'henry.serenade@videotron.ca', 'Serenading the senses with melodic charm, creating compositions that evoke emotion and enchantment.', 'Ottawa', 2),
    (84, 'Stella Vibrante', 'stella.vibrante@gmail.com', 'Crafting vibrant compositions that resonate with energy, creating a symphony of lively and animated melodies.', 'Toronto', 11),
    (85, 'Samuel Sonique', 'samuel.sonique@outlook.com', 'Exploring the sonique style, crafting compositions that resonate with unique and expressive sonic elements.', 'Halifax', 14),
    (86, 'Aurora Cantabile', 'aurora.cantabile@gmail.com', 'Expressing through the cantabile style, creating melodies that flow with graceful and lyrical expression.', 'Montreal', 6),
    (87, 'Leo Lyrique', 'leo.lyrique@videotron.ca', 'Embarking on a lyrique journey, crafting compositions that tell tales of emotion and poetic expression.', 'St. John', 5),
    (88, 'Penelope Harmonique', 'penelope.harmonique@outlook.com', 'Crafting harmonique compositions that resonate with elegance, creating a symphony of refined and graceful melodies.', 'Hamilton', 6),
    (89, 'Maxime Rhapsode', 'maxime.rhapsode@gmail.com', 'Diving into the rhapsodic realm, crafting compositions that ebb and flow with expressive and dynamic melodies.', 'Kingston', 15),
    (90, 'Violet Harmonia', 'violet.harmonia@videotron.ca', 'Expressing through harmonia compositions, crafting melodies that resonate with balance and unity.', 'London', 6),
    (91, 'Daniel Allegretto', 'daniel.allegretto@gmail.com', 'Crafting allegretto compositions that dance with lively and brisk rhythms, creating a symphony of spirited melodies.', 'Windsor', 5),
    (92, 'Emily Adagietto', 'emily.adagietto@outlook.com', 'Exploring the adagietto style, creating compositions that unfold with gentle and unhurried expression.', 'Sherbrooke', 10),
    (93, 'Oliver Ritornello', 'oliver.ritornello@gmail.com', 'Crafting ritornello compositions that repeat with recurring themes, creating a musical journey through familiar and comforting melodies.', 'Trois-Rivières', 6),
    (94, 'Ava Fortissimo', 'ava.fortissimo@videotron.ca', 'Expressing through fortissimo compositions, crafting powerful and intense melodies that resonate with strength and grandeur.', 'Saguenay', 6),
    (95, 'Ethan Crescendo', 'ethan.crescendo@outlook.com', 'Crafting crescendos that build with intensity, creating a symphony of powerful and dynamic musical expressions.', 'Rimouski', 6),
    (96, 'Sofia Lyrical', 'sofia.lyrical@gmail.com', 'Exploring the lyrical style, crafting compositions that unfold with expressive and poetic melodies.', 'Montreal', 13),
    (97, 'Noah Dolce', 'noah.dolce@videotron.ca', 'Expressing through the dolce style, creating melodies that unfold with sweetness and gentle expression.', 'Quebec City', 6),
    (98, 'Mia Virtuoso', 'mia.virtuoso@outlook.com', 'Embarking on a virtuoso journey, crafting compositions that showcase technical mastery and expressive brilliance.', 'Montreal', 15),
    (99, 'Liam Serenata', 'liam.serenata@gmail.com', 'Serenading the soul with tranquil melodies, creating compositions that evoke feelings of serenity and peace.', 'Sherbrooke', 6),
    (100, 'Grace Sonante', 'grace.sonante@videotron.ca', 'Crafting sonante compositions that resonate with sound, creating a symphony of harmonious and resonant melodies.', 'Rimouski', 14);
-- ** STYLES A AJOUTER **

/*------------------------------------------------------------------------------------------------------*/

-- Styles

CREATE TABLE Styles (
    id_style INTEGER,
    nom VARCHAR(32),

    PRIMARY KEY (id_style)
);

INSERT INTO Styles (id_style, nom) VALUES
    (1, 'Pop'),
    (2, 'Rock'),
    (3, 'Hip Hop'),
    (4, 'Jazz'),
    (5, 'Country'),
    (6, 'Electronique'),
    (7, 'Classique'),
    (8, 'Blues'),
    (9, 'R&B'),
    (10, 'Reggae');

/*------------------------------------------------------------------------------------------------------*/

-- Merch

CREATE TABLE Merch (
    id_merch INTEGER,
    id_produit INTEGER DEFAULT NULL, -- null, changé apres le trigger
    nom_article VARCHAR(32),
    image_art VARCHAR(256),
    couleur CHAR(6), -- hexa
    taille ENUM ('XS', 'S', 'M', 'L', 'XL', 'XXL', 'Standard'),
    typeArticle ENUM ('T-Shirt', 'Beanie', 'Hoodie'),
    id_artiste INTEGER NOT NULL,

    PRIMARY KEY (id_merch), -- enleve id_produit aussi (Ccomposee) car DEFAULT NULL
    FOREIGN KEY (id_produit) REFERENCES Produit (id_produit) ON DELETE CASCADE,
    FOREIGN KEY (id_artiste) REFERENCES Artiste (id_artiste) ON DELETE CASCADE
);


DELIMITER //
CREATE TRIGGER ajout_merch_a_produit BEFORE INSERT ON Merch FOR EACH ROW
-- ajoute le nouvel merch a la table produit, lui donne un prix et ajoute le product_id au merch

    BEGIN
        -- ajoute le produit, avec le prix en fonction de l'item
        INSERT INTO Produit (prix) VALUES (
            CASE
                WHEN NEW.typeArticle = 'T-Shirt' THEN 19.99
                WHEN NEW.typeArticle = 'Beanie' THEN 14.99
                WHEN NEW.typeArticle = 'Hoodie' THEN 29.99
                -- ELSE NULL? pas necessaire si tous les merch sont 1 des 3 types
            END );

        -- ajoute le id_produit au merch
        SET NEW.id_produit = LAST_INSERT_ID();

    END //
DELIMITER ;

/*------------------------------------------------------------------------------------------------------*/

-- Album

CREATE TABLE Album (
    id_album INTEGER,
    titre VARCHAR(32) NOT NULL,
    id_artiste INTEGER NOT NULL,
    id_style INTEGER NOT NULL,
    id_produit INTEGER DEFAULT NULL, -- null, changé apres le trigger
    format ENUM ('Numerique', 'Disque', 'Cassette', 'Vinyl'), -- a voir
    noteglobal REAL,
    photo_album VARCHAR(32) NOT NULL, -- est ce qu'il est possible de ne pas en avoir
    annee_parution INTEGER, -- etait DATE, modifie a INTEGER
    duree REAL DEFAULT 0.0, -- a regarder

    PRIMARY KEY(id_album),
    FOREIGN KEY(id_artiste) REFERENCES Artiste (id_artiste),
    FOREIGN KEY(id_style) REFERENCES Styles (id_style),
    FOREIGN KEY(id_produit) REFERENCES Produit (id_produit)
);


DELIMITER //
CREATE TRIGGER ajout_album_a_produit BEFORE INSERT ON Album FOR EACH ROW
-- ajoute le nouvel album a la table produit, lui donne un prix et ajoute le product_id a l'album

    BEGIN
        -- ajoute le produit avec le prix pour un album
        INSERT INTO Produit (prix) VALUES
            (5.99);

        -- ajoute le id_produit a l'album
        SET NEW.id_produit = LAST_INSERT_ID();

    END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER note_globale_album AFTER INSERT ON Noter FOR EACH ROW
-- modifie la note globale de l'album lorsqu'une nouvelle note lui est donnee

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


DELIMITER //
CREATE TRIGGER duree_album AFTER INSERT ON Chanson FOR EACH ROW
-- modifie la duree totale de l'album lorsque les chansons sont ajoutes dans l'album

    BEGIN
        UPDATE Album A SET A.duree = (A.duree + NEW.duree)
        WHERE NEW.id_album = A.id_album;
    END //
DELIMITER ;

/*------------------------------------------------------------------------------------------------------*/

-- Chanson

CREATE TABLE Chanson (
    id_chanson INTEGER,
    id_album INTEGER NOT NULL,
    titre VARCHAR(32) NOT NULL,
    duree REAL,

    PRIMARY KEY (id_chanson),
    FOREIGN KEY (id_album) REFERENCES Album (id_album) ON DELETE CASCADE
);

INSERT INTO Chanson (id_chanson, id_album, titre, duree) VALUES
    ();

/*------------------------------------------------------------------------------------------------------*/

-- Produit

CREATE TABLE Produit (
    id_produit INTEGER AUTO_INCREMENT,
    prix REAL,

    PRIMARY KEY (id_produit)
);

/*------------------------------------------------------------------------------------------------------*/

-- Transaction

CREATE TABLE Transaction (
    id_transaction INTEGER,
    id_produit INTEGER NOT NULL,
    id_utilisateur INTEGER NOT  NULL,
    date_transaction DATE,

    PRIMARY KEY(id_transaction),
    FOREIGN KEY(id_produit) REFERENCES Produit (id_produit),
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur (id_utilisateur)
);

/*------------------------------------------------------------------------------------------------------*/

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

/*------------------------------------------------------------------------------------------------------*/

-- Suivre

CREATE TABLE Suivre (
    id_utilisateur INTEGER NOT NULL,
    id_artiste INTEGER NOT NULL,

    PRIMARY KEY (id_utilisateur, id_artiste),
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur (id_utilisateur),
    FOREIGN KEY(id_artiste) REFERENCES Artiste (id_artiste)
);

/*------------------------------------------------------------------------------------------------------*/

/*

MODIFICATIONS
-utilisateurs: UNIQUE(nom_utilisateur, mot_de_passe) et (email, mdp) - pas necessaire si trigger
-localisation: au lieu de localisation avec attribut region, region avec attribut nom?
-mettre les primary keys en INTEGER au lieu de en Varchar(32)

- ON DELETE SET NULL au lieu de SET DEFAULT NULL
-origine d'un artiste ne reference pas une region (ex. un artiste peut venir des etats-unis)
    alors que region = regions aux quebec

-artiste: style est rendu l'attribut style principal, c'est plus simple qu'un attribut composé car ca
    devient une foreign key


TRIGGERS
1. trigger de creation d'un compte (email et mdp existent deja)\
2. lorsque une merch se fait ajouter, l'ajouter dans la table produit
3. lorsque un album, l'ajouter dans la table produit
4. note globale album
5. duree totale album

*quand quelqun cree un album et upload donc album + chansons:
1. tuple chansons sont crees (id_album = NULL)
2. tuple album est cree
3. id_album de la chansons est change a LAST_INSERT_...

*si une universite se cree, et elle n'est pas dans une region qui existe, creer cette region dans la table region


PRIX ARTICLES MERCH
-- album = 5.99 prix
-- t.shirt = 19.99 prix
-- beanie = 14.99 prix
-- hoodie = 29.99 prix


NOTES
-log in seulement avec email et mdp (pas besoin de nom utilisateur)
-changer STYLE dans le sql, trigger qui va chercher les styles des albums, ON INSERT ON Album
-revoir le trigger note global si album a 0 notes


**** CHANGER LES PRIMARY KEYS EN INT *****



*/



