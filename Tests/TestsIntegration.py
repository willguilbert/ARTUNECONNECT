import unittest
from app import app
from database import Database

class IntegrationTests(unittest.TestCase):

    def setUp(self):
        """
        Fonction pour setup le test. On prends lapp et la database qui se trouve dans notre .env.
        :return: None
        """
        self.app = app.test_client()
        self.app_context = app.app_context()
        self.app_context.push()
        self.database = Database()
        self.database.init_db('../SQL/tests.sql')


    def tearDown(self):
        """
        On nettoire la database de tests et close app.
        :return: None
        """
        self.database.drop_db()
        self.app_context.pop()

    def test_user_registration(self):
        """
        Test du endpoint de registration. On peut jouer avec les valeurs pour tester differentes values
        :return: Ok ou failed.
        """
        response = self.app.post('/register', data=dict(
            nom='will',
            prenom='guil',
            email='w@exemple.com',
            password='test1234',
            age=10,
            lien_reseaux_sociaux='http://will.com',
            bio='Just a test bio',
            region_choice='1'
        ), follow_redirects=True)

        self.assertEqual(response.status_code, 200)
        self.assertIn('Compte créé'.encode('utf-8'), response.data)

    def test_login(self):
        """
        Fonction pour tester le login endpoint. On peut jouer avec les valeurs pour faire passer les tests ou non.
        :return: Ok ou failed.
        """
        response = self.app.post('/register', data=dict(
            nom='Guilbert',
            prenom='Will',
            email='w@example.com',
            password='test1234',
            age=30,
            lien_reseaux_sociaux='http://will.com',
            bio='Just a test bio',
            region_choice='1'
        ), follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn('Compte créé'.encode('utf-8'), response.data)
        response = self.app.post('/login', data=dict(
            email='w@example.com',
            password='test1234'
        ), follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Bienvenue Guilbert', response.data)


#Ajouter plus de tests ici les amis!

if __name__ == '__main__':
    unittest.main()
