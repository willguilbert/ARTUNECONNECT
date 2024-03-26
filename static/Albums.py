from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getAlbums(category):
    try:
            if category is None:
                cursor.execute('SELECT * FROM Album;')
                rowsAlbum = cursor.fetchall()
            else:
                 cursor.execute(f'SELECT * FROM Album WHERE id_style = {category};')
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
