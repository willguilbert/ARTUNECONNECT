from database import Database
from random import shuffle
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()


def getAlbums(choice):
    """
    Cette fonction applique les filtres choisis par l'utilisateur sur les albums retournés. On execute le curseur
    approprié sur la commande SQL. Si aucun filtre n'est appliqué, on retourne l'ensemble des tuples de la table Album.
    :param choice: Style choisi par l'utilisateur
    :return: Dictionnaire des tuples de la relation Album avec les filtres si demandés.
    """
    try:
        if choice is None:
            cursor.execute('SELECT * FROM Album;')
            rowsAlbum = cursor.fetchall()
        else:
            cursor.execute(f'SELECT * FROM Album WHERE  id_style = {choice};')
            rowsAlbum = cursor.fetchall()
        shuffle(rowsAlbum)
        return rowsAlbum
    except Exception as e:
        raise e

def getCategories():
    """
    Cette fonction exécute le curseur sur la requête SQL. On place le retour dans une variable rowsCategory, qui contient
    l'ensemble des tuples de la table style.
    :return: Tuples de la table Style
    """
    try:
            cursor.execute('SELECT * FROM Styles;')
            rowsCategory = cursor.fetchall()
            return rowsCategory
    except Exception as e:
        raise e
