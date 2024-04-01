from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getAlbums(choice):
    try:
        if choice is None:
            cursor.execute('SELECT * FROM Album;')
            rowsAlbum = cursor.fetchall()
        else:
            cursor.execute(f'SELECT * FROM Album WHERE  id_style = {choice};')
            rowsAlbum = cursor.fetchall()
        return rowsAlbum
    finally:
        #cursor.close()
        pass

def getCategories():
    try:
            cursor.execute('SELECT * FROM Styles;')
            rowsCategory = cursor.fetchall()
            return rowsCategory
    finally:
        #cursor.close()
        pass
