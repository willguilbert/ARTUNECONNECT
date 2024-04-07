from database import Database
from random import shuffle
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()


def getAlbums(choice, search):
    """
    Cette fonction applique les filtres choisis par l'utilisateur sur les albums retournés. On execute le curseur
    approprié sur la commande SQL. Si aucun filtre n'est appliqué, on retourne l'ensemble des tuples de la table Album.
    :param choice: Style choisi par l'utilisateur
    :return: Dictionnaire des tuples de la relation Album avec les filtres si demandés.
    """
    try:
        like = ""
        if search is not None:
            like = f" WHERE titre LIKE '%{search}%'"
        if choice is None:
            cursor.execute(f'SELECT * FROM Album{like};')
            rowsAlbum = cursor.fetchall()
        else:
            cursor.execute(f'CALL filter_temp_table_style({choice});')
            cursor.execute(f'SELECT * FROM FilteredAlbums{like};')
            rowsAlbum = cursor.fetchall()
        shuffle(rowsAlbum)

        for album in rowsAlbum:
            album['nomStyle'] = getStyle(album['id_style'])

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


def getStyle(id):
    """
    Fonction qui va chercher le nom d'un style en fonction d'un id style.
    :param id: id du style
    :return: nom du style
    """
    try:
            cursor.execute(f'SELECT nom FROM Styles WHERE id_style ={id};')
            styleName = cursor.fetchone()
            return styleName
    except Exception as e:
        raise e