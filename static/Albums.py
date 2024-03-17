import pymysql


def getAlbums():
    connection = pymysql.connect(host='localhost', user='root', password='1234', database='TEST_ARTUNECONNECT')
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Album;')
            rowsAlbum = cursor.fetchall()
            return rowsAlbum
    finally:
        connection.close()
