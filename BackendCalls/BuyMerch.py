from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def buy(idProduit, idUser):
    """
    Fonction qui insert un achat dans la table transaction. On éxecute le curseur, qui INSERT le idProduit et le
    idUser et crée un nouveau tuple dans la table transaction qui associe l'utilisateur à son achat.
    :param idProduit: id du produit acheté.
    :param idUser: id du user qui achète.
    :return: True si la transaction est faite.
    """
    try:
        cursor.execute("INSERT INTO Transaction (id_produit, id_utilisateur) VALUES (%s, %s);", (idProduit,idUser,))
        return True
    except Exception as e:
        raise e