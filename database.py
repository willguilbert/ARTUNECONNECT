import os

import pymysql
from dotenv import load_dotenv


class Database:
    def __init__(self):
        """
            Chargez les variables d'environnement de votre fichier .env, puis complétez les lignes 15 à 19 afin de récupérer les valeurs de ces variables
        """
        load_dotenv()
        self.host = os.environ.get("HOST")
        self.port = int(os.environ.get("PORT"))
        self.database = os.environ.get("DATABASE")
        self.user = os.environ.get("USER")
        self.password = os.environ.get("PASSWORD")

        self._open_sql_connection()

    def _open_sql_connection(self):
        self.connection = pymysql.connect(
            host=self.host,
            port=self.port,
            user=self.user,
            password=self.password,
            db=self.database,
            autocommit=True
        )
        self.cursor = self.connection.cursor(pymysql.cursors.DictCursor)

    def get_cursor(self):
        return self.cursor

    def get_connection(self):
        return self.connection