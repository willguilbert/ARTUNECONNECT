from database import Database
database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

def buy(idProduit, idUser):
       try:
        cursor.execute("INSERT INTO Transaction (id_produit, id_utilisateur) VALUES (%s, %s);", (idProduit,idUser,))
        return True
       finally:
           pass