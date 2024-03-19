from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def get_album_details(album_title):
    album_details = {}
    try:
            cursor.execute("SELECT * FROM Album WHERE titre = %s", (album_title,))
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

    finally:
        connection.close()

    return album_details
