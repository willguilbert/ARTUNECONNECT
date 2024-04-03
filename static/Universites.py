from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getUniversites():
    '''

    :return:
    '''
    try:
            cursor.execute('SELECT * FROM Universite;')
            rowsUniversite = cursor.fetchall()

            for universite in rowsUniversite:
                universite["nomRegion"] = RegionName(universite['id_region'])

            return rowsUniversite
    finally:
       # cursor.close()
        pass


def RegionName(id):
    '''

    :param id:
    :return:
    '''
    try:
            cursor.execute(f'SELECT nom FROM Region WHERE id_region ={id};')
            RegionName = cursor.fetchone()
            return RegionName
    finally:
        pass