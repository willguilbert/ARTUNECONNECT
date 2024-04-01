import hashlib

from flask import Flask, render_template, request, url_for, session, redirect

import static.Home as Home
import static.Albums
import static.Artistes
import static.Universites
import static.Album
import static.Artiste
import static.Merchs
import static.BuyAlbum
import static.BuyMerch
import static.User
from database import Database
import re
import bcrypt
import os


database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY')

database = Database()


@app.route('/')
def main():
    rowsAlbums = Home.getAlbums()
    rowsArtistes = Home.getArtistes()
    rowsUniversite = Home.getUniversite()
    return render_template('Home.html', rowsAlbum=rowsAlbums, rowsArtistes=rowsArtistes, rowsUniversite=rowsUniversite)


# Vous devez setter dans votre .env un SECRET_KEY=XXXX ou XXX est ce que vous désirez. C'est seulement
#pour faire fonctionner le tout, ça prends une secret key.
@app.route("/login", methods=['GET', 'POST'])
def login():
    msg = ''
    if request.method == 'POST' and 'email' in request.form and 'password' in request.form:
        email = request.form['email']
        password = request.form['password'].encode('utf-8')
        cursor.execute('SELECT * FROM Utilisateur WHERE email = %s', (email, ))
        account = cursor.fetchone()
        if account:
            storedPassword = account['mot_de_passe'].encode('utf-8')
            if bcrypt.checkpw(password, storedPassword):
                session['loggedin'] = True
                session['id'] = account['id_utilisateur']
                session['email'] = account['email']
                session['prenom'] = account['prenom']
                session['nom'] = account['nom']
                session['bio'] = account['bio']
                session['age'] = account['age']
                cursor.execute('SELECT nom FROM Region WHERE id_region = %s;', (account['id_region'],))
                session['region'] = cursor.fetchone()
                session['social_link'] = account['liens_reseaux_sociaux']
                achats = static.User.getAchatsRecents(session['id'])
                followings = static.User.getFollowings(session['id'])
                return render_template('Userpage.html', profile=session, achats=achats)
            else:
                msg = 'Wrong username or password'
        else:
            msg = 'Incorrect username/password!'
    return render_template('Login.html', msg=msg)


@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/buyMerch', methods=[ 'POST'])
def buyMerch():
    idProduit = request.form.get('buyMerchId')
    idUser = session['id']
    success = static.BuyMerch.buy(idProduit, idUser)
    if success:
        return render_template('Confirmation.html')

@app.route('/buyAlbum', methods=[ 'POST'])
def buyAlbum():
    idProduit = request.form.get('buyAlbumId')
    print(idProduit)
    idUser = session.get('id')
    success = static.BuyAlbum.buy(idProduit, idUser)
    if success:
        return render_template('Confirmation.html')


@app.route('/register', methods=['GET', 'POST'])
def register():
    msg = ''
    if request.method == 'POST' and 'prenom' in request.form and 'nom' in request.form and 'password' in request.form and 'email' in request.form:
        password = request.form['password'].encode('utf-8')
        email = request.form['email']
        nom = request.form['nom']
        prenom = request.form['prenom']
        age = request.form['age']
        link = request.form['lien_reseaux_sociaux']
        bio = request.form['bio']
        region = request.form['region_choice']
        cursor.execute('SELECT * FROM Utilisateur WHERE email = %s', (email,))
        account = cursor.fetchone()
        if account:
            msg = 'Account already exists!'
        elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
            msg = 'Invalid email address!'
        elif not email or not password or not nom or not prenom:
            msg = 'Please fill out the form!'
        else:
            hashed_password = bcrypt.hashpw(password, bcrypt.gensalt())
            cursor.execute('INSERT INTO Utilisateur (nom, prenom, email, mot_de_passe, age, bio, liens_reseaux_sociaux, id_region) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)',
                (nom, prenom, email, hashed_password, age, bio, link, region))
            connection.commit()
            msg = "Account created!"
            return render_template('Register.html', msg=msg)
    elif request.method == 'POST':
        msg = 'Please fill out the form!'

    cursor.execute('SELECT id_region, nom FROM Region;')
    regions = cursor.fetchall()

    return render_template('Register.html', msg=msg, regions=regions)

@app.route('/navCox')
def navCox():
    return render_template('navCox.html')

    return render_template('Register.html', msg=msg)


@app.route('/albums',  methods=['GET', 'POST'])
def albums():
    if request.method == 'POST': 
        chosen = request.form.get('cat')
        albums = static.Albums.getAlbums(chosen)
        categories = static.Albums.getCategories()
        return render_template('Albums.html', albums=albums, categories = categories, choisie = chosen)
    else:
        albums = static.Albums.getAlbums(None)
        categories = static.Albums.getCategories()
        return render_template('Albums.html', albums=albums, categories = categories)


@app.route('/merch', methods=['GET', 'POST'])
def merchs():
    merchs = static.Merchs.getMerchs()
    return render_template('Merch.html', merchs=merchs)


@app.route('/universities')
def universities():
     universites = static.Universites.getUniversites()
     return render_template('Universites.html', universites=universites)


@app.route('/artistes')
def artistes():
    artistes = static.Artistes.getArtistes()
    return render_template('Artistes.html', artistes=artistes)


@app.route('/album/<string:album_titre>')
def album(album_titre):
    album = static.Album.get_album_details(album_titre)
    return render_template('Album.html', album=album)


@app.route('/artiste/<string:artiste_nom>')
def artiste(artiste_nom):
    artiste = static.Artiste.getArtisteDetails(artiste_nom)
    return render_template('Artiste.html', artiste=artiste)
@app.route('/userpage')
def userpage():
    if 'loggedin' in session and session['loggedin']:
        achats = static.User.getAchatsRecents(session['id'])
        followings = static.User.getFollowings(session['id'])
        return render_template('Userpage.html', profile=session, achats=achats)
    else:
        # Redirigez l'utilisateur vers la page de connexion s'il n'est pas connecté
        return redirect(url_for('login'))


def get_current_user_id():
    if 'id' in session:
        return session['id']
    else:

        return None
@app.route('/submit_rating_and_review', methods=['POST'])
def submit_rating_and_review():
    if request.method == 'POST':
        # Récupérer les données soumises à partir du formulaire
        note = request.form.get('note')
        review = request.form.get('review')
        album_titre = request.form.get('album_titre')  # Récupérer le titre de l'album

        # Récupérer l'id de l'utilisateur
        id_utilisateur = get_current_user_id()

        # Récupérer les détails de l'album
        album_details = static.Album.get_album_details(album_titre)


        id_album = album_details['album']['id_album']

        # Insérer les données dans la base de données

        query = "INSERT INTO Noter (id_utilisateur, id_album, note, review) VALUES (%s, %s, %s, %s)"
        sql_with_values = cursor.mogrify(query, (id_utilisateur, id_album, note, review))


        # Exécutez la requête
        cursor.execute(query, (id_utilisateur, id_album, note, review))
        connection.commit()

            # Rediriger l'utilisateur vers la même page
        return render_template('Album.html', album=album_details)

if __name__ == '__main__':
    app.run(debug=True)
