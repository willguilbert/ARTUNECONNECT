from database import Database
import BackendCalls.Artistes
import BackendCalls.Universites

database = Database()
connection = database.get_connection()
cursor = database.get_cursor()


def getAlbums():
    """
    Cette fonction selectionne, grace au curseur et la à requête SQL, en ordre de noteglobal les 6
    albums les mieux notés.
    :return: 6 tuples representant les albums
    """
    try:
        cursor.execute('SELECT * FROM Album ORDER BY noteglobal DESC LIMIT 6;')
        rowsAlbum = cursor.fetchall()

        for album in rowsAlbum:
            album['nomStyle'] = BackendCalls.Albums.getStyle(album['id_style'])

        return rowsAlbum
    except Exception as e:
        raise e


def getArtistes():
    """
        Cette fonction selectionne, grace au curseur et la à requête SQL, en ordre de followers les 6
        artistes ayant le plus grand nombre de followers.
        :return: 6 tuples representant les artistes
        """
    try:
        cursor.execute('SELECT * FROM Artiste ORDER BY nombre_followers DESC LIMIT 6;')
        rowsArtistes = cursor.fetchall()

        for artiste in rowsArtistes:
            artiste['nomUni'] = BackendCalls.Artistes.UniversityName(artiste['id_universite'])

        return rowsArtistes
    except Exception as e:
        raise e


def getUniversite():
    """
        Cette fonction selectionne, grace au curseur et à la requête SQL, en ordre de nombre d'artistes les 6
        universités ayant le plus grand nombre d'artistes.
        :return: 6 tuples representant les universités
        """
    try:
        cursor.execute('SELECT * FROM Universite ORDER BY nombre_artistes DESC LIMIT 6;')
        rowsUni = cursor.fetchall()

        for universite in rowsUni:
            universite["nomRegion"] = BackendCalls.Universites.RegionName(universite['id_region'])

        return rowsUni
    except Exception as e:
        raise e
