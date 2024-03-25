from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getUniversites():
    try:
            cursor.execute('SELECT * FROM Universite;')
            rowsUniversite = cursor.fetchall()
            return rowsUniversite
    finally:
        cursor.close()
