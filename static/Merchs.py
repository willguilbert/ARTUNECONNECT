from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getMerchs():
    try:
           # if category is None:
        cursor.execute('SELECT * FROM Merch;')
        merchs = cursor.fetchall()
            #else:
             ##   rowsAlbum = cursor.fetchall()
        return merchs
    finally:
        #cursor.close()
        pass