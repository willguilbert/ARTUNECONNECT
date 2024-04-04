from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getMerchs():
    """
    Fonction qui va chercher l'ensemble des entrées dans la table Merch de la base de données.
    :return: Dictionnaire des produits
    """
    try:
        cursor.execute('SELECT * FROM Merch;')
        merchs = cursor.fetchall()
        return merchs
    except Exception as e:
        raise e