import os

import pymysql
from dotenv import load_dotenv


class Database:
    def __init__(self):
        """
            Chargez les variables d'environnement de votre fichier .env, puis complétez les lignes 15 à 19 afin de récupérer les valeurs de ces variables
        """
        load_dotenv(override=True)
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

    def init_db(self, sql_file_path):
        """
        Load le sql file et le preparer pour les tests.
        :param sql_file_path: PATH du script tests.
        :return: None
        """
        with self.connection.cursor() as cursor:
            with open(sql_file_path, 'r') as f:
                sql_script = f.read()
            for statement in sql_script.split(';'):
                cursor.execute(statement)

    def drop_db(self):
        """
        On drop lensemble des constraints keys de la database avant de drop l'ensemble des tables.
        :return: None
        """
        self.cursor.execute("SET FOREIGN_KEY_CHECKS=0;")
        self.cursor.execute("SHOW TABLES;")
        tables = self.cursor.fetchall()
        for table in tables:
            table_name = list(table.values())[0]
            self.cursor.execute(f"DROP TABLE IF EXISTS `{table_name}`;")
        self.cursor.execute("SET FOREIGN_KEY_CHECKS=1;")
        self.connection.commit()
