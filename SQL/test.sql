
/*---------------------------------DATABASE--------------------------------*/

CREATE DATABASE TEST_ARTUNECONNECT;

USE TEST_ARTUNECONNECT;

/*---------------------------------CREATES--------------------------------*/

CREATE TABLE Region (
    id_region INTEGER,
    nom VARCHAR(64),

    PRIMARY KEY (id_region)
);

CREATE TABLE Universite (
    id_universite INTEGER,
    nom VARCHAR(64),
    id_region INTEGER,

    PRIMARY KEY (id_universite),
    FOREIGN KEY (id_region) REFERENCES Region (id_region) ON DELETE SET NULL
);

CREATE TABLE Utilisateur (
    id_utilisateur INTEGER,
    nom VARCHAR(32),
    prenom VARCHAR(32),
    email VARCHAR(64),
    mot_de_passe VARCHAR(32),
    age INTEGER,
    photo_de_profil VARCHAR(256),
    bio varchar(1024),
    liens_reseaux_sociaux VARCHAR(256),
    id_region INTEGER,

    PRIMARY KEY (id_utilisateur),
    FOREIGN KEY (id_region) REFERENCES Region (id_region) ON DELETE SET NULL,
    UNIQUE (email)
);

CREATE TABLE Artiste (
    id_artiste INTEGER,
    nom_artiste VARCHAR(32),
    email_artiste VARCHAR(64),
    biographie_artiste VARCHAR(1024),
    origine VARCHAR(32),
    id_universite INTEGER,
    -- STYLES SOIT FOREIGN KEY OU ATTRIBUT COMPOSÉ

    PRIMARY KEY (id_artiste),
    FOREIGN KEY (id_universite) REFERENCES Universite (id_universite) ON DELETE SET NULL
);

CREATE TABLE Styles (
    id_style INTEGER,
    nom VARCHAR(32),

    PRIMARY KEY (id_style)
);

CREATE TABLE Produit (
    id_produit INTEGER AUTO_INCREMENT,
    prix REAL,

    PRIMARY KEY (id_produit)
);

CREATE TABLE Merch (
    id_merch INTEGER,
    id_produit INTEGER DEFAULT NULL,
    nom_article VARCHAR(32),
    image_art VARCHAR(256),
    couleur CHAR(6), -- hexa
    taille ENUM ('XS', 'S', 'M', 'L', 'XL', 'XXL', 'Standard'),
    typeArticle ENUM ('T-Shirt', 'Beanie', 'Hoodie'),
    id_artiste INTEGER NOT NULL,

    PRIMARY KEY (id_merch),
    FOREIGN KEY (id_produit) REFERENCES Produit (id_produit) ON DELETE CASCADE,
    FOREIGN KEY (id_artiste) REFERENCES Artiste (id_artiste) ON DELETE CASCADE
);

CREATE TABLE Album (
    id_album INTEGER,
    titre VARCHAR(32) NOT NULL,
    id_artiste INTEGER NOT NULL,
    id_style INTEGER NOT NULL,
    id_produit INTEGER DEFAULT NULL,
    format ENUM ('Numerique', 'Disque', 'Cassette', 'Vinyl'),
    noteglobal REAL,
    photo_album VARCHAR(32),
    annee_parution INTEGER,
    duree REAL DEFAULT 0.0, -- a regarder

    PRIMARY KEY(id_album),
    FOREIGN KEY(id_artiste) REFERENCES Artiste (id_artiste),
    FOREIGN KEY(id_style) REFERENCES Styles (id_style),
    FOREIGN KEY(id_produit) REFERENCES Produit (id_produit)
);

CREATE TABLE Chanson (
    id_chanson INTEGER,
    id_album INTEGER NOT NULL,
    titre VARCHAR(32) NOT NULL,
    duree REAL,

    PRIMARY KEY (id_chanson),
    FOREIGN KEY (id_album) REFERENCES Album (id_album) ON DELETE CASCADE
);

CREATE TABLE Transaction (
    id_transaction INTEGER,
    id_produit INTEGER NOT NULL,
    id_utilisateur INTEGER NOT  NULL,
    date_transaction DATE,

    PRIMARY KEY(id_transaction),
    FOREIGN KEY(id_produit) REFERENCES Produit (id_produit),
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur (id_utilisateur)
);

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

CREATE TABLE Suivre (
    id_utilisateur INTEGER NOT NULL,
    id_artiste INTEGER NOT NULL,

    PRIMARY KEY (id_utilisateur, id_artiste),
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur (id_utilisateur),
    FOREIGN KEY(id_artiste) REFERENCES Artiste (id_artiste)
);

/*--------------------------------INSERTS--------------------------------*/

INSERT INTO Region (id_region, nom) VALUES
    (1, 'Abitibi-Témiscamingue'),
    (2, 'Bas-Saint-Laurent'),
    (3, 'Capitale-Nationale');

INSERT INTO Universite (id_universite, nom, id_region) VALUES
    (1, 'Université du Québec en Abitibi-Témiscamingue', 1),
    (2, 'Université du Québec à Rimouski', 2),
    (3, 'École nationale d’administration publique', 3),
    (4, 'Institut national de la recherche scientifique', 3),
    (5, 'Université Laval', 3);

INSERT INTO Utilisateur (id_utilisateur, nom, prenom, email, mot_de_passe, age, photo_de_profil,
                         bio, liens_reseaux_sociaux, id_region) VALUES
    (1, 'Desmarais', 'Alexandre', 'alex.desmarais2004@gmail.com', '123', 40, null,
     'Bienvenue sur la page à Alex!', 'https://github.com/Desmarais13', 3),
    (2, 'Guilbert', 'William', 'willguilbert@gmail.com', '456', 999, null,
     'Bienvenue sur la page à Will!', 'https://github.com/willguilbert', 3);

INSERT INTO Artiste (id_artiste, nom_artiste, email_artiste, biographie_artiste, origine, id_universite) VALUES
    (1, 'Emily Serenade', 'emily.serenade@gmail.com', 'Crafting enchanting serenades that linger in the heart like a sweet melody.', 'Fredericton', 1),
    (2, 'Marcus Melody', 'marcus.melody@outlook.com', 'Embarking on a musical journey, weaving diverse melodies into a harmonious symphony.', 'Montreal', 1),
    (3, 'Olivia Echo', 'olivia.echo@gmail.com', 'Creating echoes of emotion through every note, a reflection of the soul in music.', 'Saguenay', 3),
    (4, 'Dylan Harmony', 'dylan.harmony@videotron.ca', 'Harmony in every chord, crafting musical pieces that resonate with the heart.', 'Halifax', 4),
    (5, 'Ava Rhythm', 'ava.rhythm@gmail.com', 'Exploring the rhythmic landscapes of sound, creating vibrant and dynamic compositions.', 'Charlottetown', 5);
INSERT INTO Artiste (id_artiste, nom_artiste, email_artiste, biographie_artiste, origine, id_universite) VALUES
(6, 'Ava Rhythm', 'ava.rhythm@gmail.com', 'Exploring the rhythmic landscapes of sound, creating vibrant and dynamic compositions.', 'Charlottetown', 5),
(7, 'Ava Rhythm', 'ava.rhythm@gmail.com', 'Exploring the rhythmic landscapes of sound, creating vibrant and dynamic compositions.', 'Charlottetown', 5);

INSERT INTO Styles (id_style, nom) VALUES
    (1, 'Pop'),
    (2, 'Rock'),
    (3, 'Hip Hop'),
    (4, 'Jazz'),
    (5, 'Country');

INSERT INTO Produit (id_produit, prix) VALUES
    (1, 19.99),
    (2, 14.99),
    (3, 29.99),
    (4, 19.99),
    (5, 29.99),
    (6, 5.99),
    (7, 5.99),
    (8, 5.99),
    (9, 5.99),
    (10, 5.99);

INSERT INTO Merch (id_merch, id_produit, nom_article, image_art,
                   couleur, taille, typeArticle, id_artiste) VALUES
    (1, 1, 'Emily Serenade Red Tee', null, 'F44336', 'S', 'T-Shirt', 1),
    (2, 2, 'Emily Serenade Green Beanie', null, '388E3C', 'Standard', 'Beanie', 1),
    (3, 3, 'Olivia Echo Black Hoodie', null, '000000', 'XL', 'Hoodie', 3),
    (4, 4, 'Dylan Harmony White Tee', null, 'FFFFFF', 'M', 'T-Shirt', 4),
    (5, 5, 'Ava Rhythm Blue Hoodie', null, '1E88E5', 'L', 'Hoodie', 5);

INSERT INTO Album (id_album, titre, id_artiste, id_style, id_produit, format,
                   noteglobal, photo_album, annee_parution, duree) VALUES
    (1, 'Graduation', 1, 1, 6, 'Numerique', 5, null, 2004, 25.50),
    (2, 'For All The Dogs', 2, 2, 7, 'Numerique', 1, null, 2005, 25),
    (3, 'Eternal Atake', 3, 3, 8, 'Numerique', 2.2, null, 2024, 35.20),
    (4, 'Donda', 3, 4, 9, 'Numerique', 3.6, null, 2006, 2.22),
    (5, 'UTOPIA', 5, 5, 10, 'Numerique', 4.4, null, 1999, 1);
INSERT INTO Album (id_album, titre, id_artiste, id_style, id_produit, format,
                   noteglobal, photo_album, annee_parution, duree) VALUES
  (6, 'Graduation', 1, 1, 6, 'Numerique', 5, null, 2004, 25.50),
    (7, 'For All The Dogs', 2, 2, 7, 'Numerique', 1, null, 2005, 25),
    (8, 'Eternal Atake', 3, 3, 8, 'Numerique', 2.2, null, 2024, 35.20),
    (9, 'Donda', 3, 4, 9, 'Numerique', 3.6, null, 2006, 2.22),
    (10, 'UTOPIA', 5, 5, 10, 'Numerique', 4.4, null, 1999, 1),
  (11, 'Graduation', 1, 1, 6, 'Numerique', 5, null, 2004, 25.50),
    (12, 'For All The Dogs', 2, 2, 7, 'Numerique', 1, null, 2005, 25),
    (13, 'Eternal Atake', 3, 3, 8, 'Numerique', 2.2, null, 2024, 35.20),
    (14, 'Donda', 3, 4, 9, 'Numerique', 3.6, null, 2006, 2.22),
    (15, 'UTOPIA', 5, 5, 10, 'Numerique', 4.4, null, 1999, 1),
  (16, 'Graduation', 1, 1, 6, 'Numerique', 5, null, 2004, 25.50),
    (17, 'For All The Dogs', 2, 2, 7, 'Numerique', 1, null, 2005, 25),
    (18, 'Eternal Atake', 3, 3, 8, 'Numerique', 2.2, null, 2024, 35.20),
    (19, 'Donda', 3, 4, 9, 'Numerique', 3.6, null, 2006, 2.22),
    (20, 'UTOPIA', 5, 5, 10, 'Numerique', 4.4, null, 1999, 1);

INSERT INTO Chanson (id_chanson, id_album, titre, duree) VALUES
    (1, 1, 'Chanson A', 1),
    (2, 1, 'Chanson B', 1.33),
    (3, 1, 'Chanson C', 2),
    (4, 1, 'Chanson D', 2.22),
    (5, 1, 'Chanson E', 1.89),
    (6, 1, 'Chanson F', 1.60),
    (7, 3, 'Chanson G', 1.66),
    (8, 3, 'Chanson H', 1.50),
    (9, 4, 'Chanson I', 3),
    (10, 5, 'Chanson J', 1.10);

INSERT INTO Transaction (id_transaction, id_produit,
                         id_utilisateur, date_transaction) VALUES
    (1, 1, 1, '2024-03-03'),
    (2, 1, 1, '2024-03-03'),
    (3, 2, 1, '2024-03-03'),
    (4, 3, 1, '2024-03-03'),
    (5, 6, 1, '2024-03-03'),
    (6, 6, 2, '2024-03-03'),
    (7, 6, 2, '2024-03-03'),
    (8, 6, 2, '2024-03-03'),
    (9, 6, 2, '2024-03-03'),
    (10, 9, 2, '2024-03-03');

INSERT INTO Noter (id_utilisateur, id_album, note, review) VALUES
    (1, 1, 1.50, 'mauvais album'),
    (1, 2, 1, 'pire album!!!'),
    (1, 3, 5, 'meilleur album!!!'),
    (2, 3, 4.21, 'bon album'),
    (2, 4, 3.33, 'moyen album');

INSERT INTO Suivre (id_utilisateur, id_artiste) VALUES
    (1, 2),
    (2, 2),
    (2, 3),
    (2, 4),
    (2, 5);

/*---------------------------------SELECTS--------------------------------*/

SELECT * FROM Region;

SELECT * FROM Universite;

SELECT * FROM Utilisateur;

SELECT * FROM Artiste;

SELECT * FROM Styles;

SELECT * FROM Produit;

/* SELECT * FROM Merch; */

/* SELECT * FROM Album; */

/* SELECT * FROM Chanson; */

/* SELECT * FROM Transaction; */

/* SELECT * FROM Noter; */

/* SELECT * FROM Suivre; */
