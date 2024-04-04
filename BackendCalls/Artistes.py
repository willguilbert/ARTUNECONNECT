from database import Database
from random import shuffle
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getArtistes():
    """
    Cette fonction va chercher l'ensemble des artistes ainsi que le nom de l'université que fréquente chaque artiste.
    Lance une exception en cas d'erreur.
    :return: Les tuples artistes et leur nom d'université
    """
    try:
            cursor.execute('SELECT * FROM Artiste;')
            rowsArtiste = cursor.fetchall()

            for artiste in rowsArtiste:
                artiste['nomUni'] = UniversityName(artiste['id_universite'])
            shuffle(rowsArtiste)
            return rowsArtiste
    except Exception as e:
        raise e


def UniversityName(id):
    """
    Cette fonction va chercher le nom de l'université associé au id passé en paramètre.
    Lance une exception en cas d'erreur.
    :param id: id d'une université
    :return: Nom de l'université
    """
    try:
            cursor.execute(f'SELECT nom FROM Universite WHERE id_universite ={id};')
            UniversityName = cursor.fetchone()
            return UniversityName
    except Exception as e:
        raise e