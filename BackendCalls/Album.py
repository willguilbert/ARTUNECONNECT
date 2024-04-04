from database import Database

database = Database()
connection = database.get_connection()
cursor = database.get_cursor()


def get_album_details(album_title, id_artiste):
    """
    Fonction qui va chercher les informations d'un album, soit sont style, l'artiste l'ayant produit ainsi que l'ensemble
    des informations concernant cet album. On cherche a construire un dictionnaire de clé valeur pour accéder aux
    informations de l'album. Grâce aux requêtes SQL, on peut aller chercher les tuples satisfaisant les paramètres
    de la fonction.
    :param album_title: Titre de l'album qu'on cherche à avoir
    :param id_artiste: id de l'artiste ayant produit cet album
    :return: Dictionnaire clé valeur avec les albums, les chansons de cet album,l'artiste les ayants produit et
    les styles de chaque album.
    """
    album_details = {}
    try:
        cursor.execute("SELECT * FROM Album WHERE titre = %s AND id_artiste=%s", (album_title, id_artiste,))
        album = cursor.fetchone()
        if album:
            album_details['album'] = album
            cursor.execute("SELECT nom FROM Styles WHERE id_style = %s", (album['id_style'],))
            style = cursor.fetchone()
            album_details['style'] = style['nom'] if style else 'Unknown'

            cursor.execute("SELECT * FROM Artiste WHERE id_artiste = %s", (album['id_artiste'],))
            artiste = cursor.fetchone()
            album_details['artiste'] = artiste

            cursor.execute("SELECT * FROM Chanson WHERE id_album = %s", (album['id_album'],))
            chansons = cursor.fetchall()
            album_details['chansons'] = chansons


    except Exception as e:
        raise e

    return album_details
