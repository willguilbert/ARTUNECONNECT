from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()


def getAchatsRecents(idUser):
    achats_details = {'transactions': [], 'merch': [], 'albums': []}

    try:
        cursor.execute("SELECT * FROM Transaction WHERE id_utilisateur = %s", (idUser,))
        transactions = cursor.fetchall()
        for transaction in transactions:

            cursor.execute("SELECT * FROM Merch WHERE id_produit = %s", (transaction['id_produit'],))
            merch = cursor.fetchall()

            cursor.execute("SELECT * FROM Album WHERE id_produit = %s", (transaction['id_produit'],))
            album = cursor.fetchall()

            if merch:
                achats_details['merch'] += merch

            elif album:
                achats_details['albums'] += album

            achats_details['transactions'].append(transaction)

    finally:
       pass

    return achats_details


def getFollowings(id):
    followings = {'suivre' : [], 'artiste' : []}
    try:
            cursor.execute('SELECT * FROM Suivre where id_utilisateur = %s', (id,))
            follows = cursor.fetchall()
            for follow in follows:
                cursor.execute('SELECT * FROM Artiste WHERE id_artiste = %s', (follow['id_artiste'],))
                artiste = cursor.fetchall()
                followings['artiste']+=artiste
                followings['suivre']=follows

    finally:

        pass
    return followings
