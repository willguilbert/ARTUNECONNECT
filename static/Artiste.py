from database import Database


database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getArtisteDetails(artiste_nom):
    
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
                    'format': album['format'],
                    'noteglobal': album['noteglobal'],
                    'photo_album': album['photo_album'],

                } for album in albums]
                cursor.execute("SELECT * FROM Merch WHERE id_artiste = %s", (artiste['id_artiste'],))
                merch = cursor.fetchall()
                artiste_details['merch'] = merch

    finally:
        #cursor.close()
        pass

    return artiste_details
