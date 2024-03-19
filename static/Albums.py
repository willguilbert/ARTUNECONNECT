import pymysql
from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getAlbums():
    try:
            cursor.execute('SELECT * FROM Album;')
            rowsAlbum = cursor.fetchall()
            return rowsAlbum
    finally:
        connection.close()
