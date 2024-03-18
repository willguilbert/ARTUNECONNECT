import pymysql


def getArtistes():
    connection = pymysql.connect(host='localhost', user='root', password='1234', database='TEST_ARTUNECONNECT')
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Artiste;')
            rowsArtiste = cursor.fetchall()
            return rowsArtiste
    finally:
        connection.close()
