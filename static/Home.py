import pymysql

def getAlbums():
    connection = pymysql.connect(host='localhost', user='root', password='1234', database='TEST_ARTUNECONNECT')
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Album LIMIT 6;')
            rowsAlbum = cursor.fetchall()
            return rowsAlbum
    finally:
        connection.close()


def getArtistes():
    connection = pymysql.connect(host='localhost', user='root', password='1234', database='TEST_ARTUNECONNECT')
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Artiste LIMIT 6;')
            rowsArtistes = cursor.fetchall()
            return rowsArtistes
    finally:
        connection.close()

def getUniversite():
    connection = pymysql.connect(host='localhost', user='root', password='1234', database='TEST_ARTUNECONNECT')
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Universite LIMIT 6;')
            rowsUni = cursor.fetchall()
            return rowsUni
    finally:
        connection.close()
