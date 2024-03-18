import pymysql


def get_album_details(album_title):
    connection = pymysql.connect(host='localhost', user='root', password='1234', database='TEST_ARTUNECONNECT')
    album_details = {}
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
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
