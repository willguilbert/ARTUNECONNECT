import hashlib

from flask import Flask, render_template, request, url_for, session, redirect

import static.Home as Home
import static.Albums
import static.Artistes
import static.Universites
import static.Album
import static.Artiste
from database import Database
import re
import bcrypt
import os


database = Database()
connection = database.get_connection()
cursor = database.get_cursor()

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY')
UserProfile = {}

database = Database()


@app.route('/')
def main():
    rowsAlbums = Home.getAlbums()
    rowsArtistes = Home.getArtistes()
    rowsUniversite = Home.getUniversite()
    return render_template('Home.html', rowsAlbum=rowsAlbums, rowsArtistes=rowsArtistes, rowsUniversite=rowsUniversite)


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
                return render_template('Userpage.html', profile=session)
            else:
                msg = 'Wrong username or password'
        else:
            msg = 'Incorrect username/password!'
    return render_template('Login.html', msg=msg)


@app.route('/logout')
def logout():
    session.pop('loggedin', None)
    session.pop('id', None)
    session.pop('username', None)
    return redirect(url_for('login'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    msg = ''
    if request.method == 'POST' and 'prenom' in request.form and 'nom' in request.form and 'password' in request.form and 'email' in request.form:
        password = request.form['password'].encode('utf-8')
        email = request.form['email']
        nom = request.form['nom']
        prenom = request.form['prenom']
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
            cursor.execute('INSERT INTO Utilisateur (nom, prenom, email, mot_de_passe) VALUES (%s, %s, %s, %s)',
                           (nom,prenom,email, hashed_password))
            connection.commit()
            msg = "Account created!"
            return render_template('Register.html', msg=msg)
    elif request.method == 'POST':
        msg = 'Please fill out the form!'

    return render_template('Register.html', msg=msg)

@app.route('/albums')
def albums():
    albums = static.Albums.getAlbums()
    return render_template('Albums.html', albums=albums)


@app.route('/merch')
def merch():
    return render_template('Merch.html')


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


if __name__ == '__main__':
    app.run(debug=True)
