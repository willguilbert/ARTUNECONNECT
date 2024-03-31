from database import Database
import static.Artistes
import static.Universites

database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getAlbums():
    try:
            cursor.execute('SELECT * FROM Album ORDER BY noteglobal DESC LIMIT 6;')
            rowsAlbum = cursor.fetchall()
            return rowsAlbum
    finally:
        pass


def getArtistes():
    try:
            cursor.execute('SELECT * FROM Artiste ORDER BY nombre_followers DESC LIMIT 6;')
            rowsArtistes = cursor.fetchall()

            for artiste in rowsArtistes:
                artiste['nomUni'] = static.Artistes.UniversityName(artiste['id_universite'])

            return rowsArtistes
    finally:
        pass

def getUniversite():
    try:
            cursor.execute('SELECT * FROM Universite ORDER BY nombre_artistes DESC LIMIT 6;')
            rowsUni = cursor.fetchall()

            for universite in rowsUni:
                universite["nomRegion"] = static.Universites.RegionName(universite['id_region'])

            return rowsUni
    finally:
        pass
        #cursor.close()
