from database import Database

database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getAlbums():
    try:
            cursor.execute('SELECT * FROM Album LIMIT 6;')
            rowsAlbum = cursor.fetchall()
            return rowsAlbum
    finally:
        pass
        #connection.close()


def getArtistes():
    try:
            cursor.execute('SELECT * FROM Artiste LIMIT 6;')
            rowsArtistes = cursor.fetchall()
            return rowsArtistes
    finally:
        pass
        #connection.close()

def getUniversite():
    try:
            cursor.execute('SELECT * FROM Universite LIMIT 6;')
            rowsUni = cursor.fetchall()
            return rowsUni
    finally:
        pass
        #connection.close()
