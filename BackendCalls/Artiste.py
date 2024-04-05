from database import Database


database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getArtisteDetails(artiste_nom):
    """
    Fonction qui instancie un dictionnaire de clé valeur pour l'artiste demandé. On Join sur les albums et on va également
    chercher les styles que l'artiste a produit par le passé. On souhaite également avoir les informations concernant
    les produits vendus par l'artiste. Ce dictionnaire est donc énorme, il contient l'ensemble des albums, style et
    produit qu'un artiste possède dans la BD.
    :param artiste_nom: Nom de l'artiste pour lequel on cherche des informations
    :return: Dictionnaire comprenant les informations de l'artiste, soit ses albums, style et produit.
    """
    artiste_details = {}

    try:

            cursor.execute("SELECT * FROM Artiste WHERE nom_artiste = %s", (artiste_nom,))
            artiste = cursor.fetchone()
            artiste_details['artiste'] = artiste

            if artiste:
                cursor.execute("""
                    SELECT Album.*, Styles.nom AS style_nom
                    FROM Album
                    INNER JOIN Styles ON Album.id_style = Styles.id_style
                    WHERE Album.id_artiste = %s
                """, (artiste['id_artiste'],))
                albums = cursor.fetchall()
                artiste_details['albums'] = [{
                    'id_album': album['id_album'],
                    'id_artiste': album['id_artiste'],
                    'titre': album['titre'],
                    'style': album['style_nom'],
                    'annee_parution': album['annee_parution'],
                    'duree': album['duree'],
                    'noteglobal': album['noteglobal'],
                    'photo_album': album['photo_album'],

                } for album in albums]
                cursor.execute("SELECT * FROM Merch WHERE id_artiste = %s", (artiste['id_artiste'],))
                merch = cursor.fetchall()
                artiste_details['merch'] = merch

    except Exception as e:
        raise e

    return artiste_details
