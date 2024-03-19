import pymysql
from database import Database

database = Database()
connection = database.get_connection()

def getAlbums():
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Album LIMIT 6;')
            rowsAlbum = cursor.fetchall()
            return rowsAlbum
    finally:
        pass
        #connection.close()


def getArtistes():
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Artiste LIMIT 6;')
            rowsArtistes = cursor.fetchall()
            return rowsArtistes
    finally:
        pass
        #connection.close()

def getUniversite():
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Universite LIMIT 6;')
            rowsUni = cursor.fetchall()
            return rowsUni
    finally:
        pass
        #connection.close()
