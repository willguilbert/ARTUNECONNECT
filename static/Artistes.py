from database import Database

database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getArtistes():
    try:
            cursor.execute('SELECT * FROM Artiste;')
            rowsArtiste = cursor.fetchall()

            for artiste in rowsArtiste:
                artiste['nomUni'] = UniversityName(artiste['id_universite'])

            return rowsArtiste
    finally:
        #cursor.close()
        pass

def UniversityName(id):
    try:
            cursor.execute(f'SELECT nom FROM Universite WHERE id_universite ={id};')
            UniversityName = cursor.fetchone()
            return UniversityName
    finally:
        pass