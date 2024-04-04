from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getUniversites():
    '''
    Fonction qui va chercher dans la base de donnée les tuples de la table Universite et également va chercher le nom
    de la region de l'université en fonction de l'id région d'une université. Lance une exception en cas d'erreur.
    :return: Les tuples d'université et le nom de leur région.
    '''
    try:
            cursor.execute('SELECT * FROM Universite;')
            rowsUniversite = cursor.fetchall()

            for universite in rowsUniversite:
                universite["nomRegion"] = RegionName(universite['id_region'])

            return rowsUniversite
    except Exception as e:
       raise e



def RegionName(id):
    '''
    Fonction qui va chercher le nom d'une région en fonction d'un id région.
    :param id: id de la region
    :return: Nom de la région
    '''
    try:
            cursor.execute(f'SELECT nom FROM Region WHERE id_region ={id};')
            RegionName = cursor.fetchone()
            return RegionName
    except Exception as e:
        raise e