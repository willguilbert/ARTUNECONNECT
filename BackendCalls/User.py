from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()


def getAchatsRecents(idUser):
    """
    Fonction qui instancie un dictionnaire achats_details clé - valeur et ayant 3 clés soit transactions, merch et albums
    qui contiennent toutes les 3 une liste vide. On remplit la liste de chaque clé avec le retour des requêtes SQL
    avec comme paramètre les id_produits présent dans la table transaction associé à une transaction. Ici, on tente
    de fetch l'ensemble des transactions pour un user, y avoir le type et les informations concernant le type de produit
    soit une merch ou bien un album.
    :param idUser: id du user pour lequel on cherche les achats récents.
    :return: Dicitonnaire comportant les transactions et les items achetés.
    """
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

    except Exception as e:
        raise e

    return achats_details


def getFollowings(id):
    """
    Fonction qui instancie un dictionnaire clé valeur et va chercher grâce aux requetes SQL les informations de la table
    Suivre, vérifie si il y a des entrées, puis si c'est le cas, on va chercher les informaitons concernant l'artiste
    qui est followed dans la table Suivre.
    :param id: id du user pour lequel on cherche les followings.
    :return: Dictionnaire contenant les informations de la table suivre ainsi que des artistes suivis.
    """
    followings = {'suivre' : [], 'artiste' : []}
    try:
            cursor.execute('SELECT * FROM Suivre where id_utilisateur = %s', (id,))
            follows = cursor.fetchall()
            for follow in follows:
                cursor.execute('SELECT * FROM Artiste WHERE id_artiste = %s', (follow['id_artiste'],))
                artiste = cursor.fetchall()
                followings['artiste']+=artiste
                followings['suivre']=follows

    except Exception as e:
        raise e
    return followings
