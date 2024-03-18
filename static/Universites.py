import pymysql


def getUniversites():
    connection = pymysql.connect(host='localhost', user='root', password='1234', database='TEST_ARTUNECONNECT')
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute('SELECT * FROM Universite;')
            rowsUniversite = cursor.fetchall()
            return rowsUniversite
    finally:
        connection.close()
