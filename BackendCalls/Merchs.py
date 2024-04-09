from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def getMerchs():
    """
    Fonction qui va chercher l'ensemble des entrées dans la table Merch de la base de données.
    :return: Dictionnaire des produits
    """
    try:
        cursor.execute('SELECT * FROM Merch;')
        merchs = cursor.fetchall()

        for merch in merchs:
            merch['prix'] = getPrice(merch['id_produit'])

        return merchs
    except Exception as e:
        raise e

def getPrice(id):
    '''
        Fonction qui va chercher le prix d'un article (merch ou album) en fonction d'un id_produit.
        :param id: id du produit
        :return: prix du produit
        '''
    try:
        cursor.execute(f'SELECT prix FROM Produit WHERE id_produit ={id};')
        prixProduit = cursor.fetchone()
        return prixProduit
    except Exception as e:
        raise e