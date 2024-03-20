from database import Database

database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getArtistes():
    try:
            cursor.execute('SELECT * FROM Artiste;')
            rowsArtiste = cursor.fetchall()
            return rowsArtiste
    finally:
        #cursor.close()
        pass
