from flask import Flask, render_template, jsonify, request, url_for, session, redirect, flash
from pymysql.err import IntegrityError
import BackendCalls.Home as Home
import BackendCalls.Albums
import BackendCalls.Artistes
import BackendCalls.Universites
import BackendCalls.Album
import BackendCalls.Artiste
import BackendCalls.Merchs
import BackendCalls.BuyAlbum
import BackendCalls.BuyMerch
import BackendCalls.User
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
    """
    Endpoint pour render la home page.
    Fonction qui cree la page Home de lapplication. On va chercher les informations contenues dans la BD pour les
    albums, les artistes et les unviersites.
    :return: Render template de la Home page, avec les informations des albums, des artistes et des universites
    """
    try:
        rowsAlbums = Home.getAlbums()
        rowsArtistes = Home.getArtistes()
        rowsUniversite = Home.getUniversite()
        return render_template('Home.html', rowsAlbum=rowsAlbums, rowsArtistes=rowsArtistes, rowsUniversite=rowsUniversite)
    except Exception as e:
        flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger la page Home.", 'error')
        return render_template('Home.html', rowsAlbum=rowsAlbums, rowsArtistes=rowsArtistes, rowsUniversite=rowsUniversite)


# Vous devez setter dans votre .env un SECRET_KEY=XXXX ou XXX est ce que vous désirez. C'est seulement
#pour faire fonctionner le tout, ça prends une secret key.
@app.route("/login", methods=['GET', 'POST'])
def login():
    """
    Endpoint du login.
    Fonction qui soccupe de gérer le login utilisateur. On va chercher les informations contenues dans le forms de login
    et on vérifie que le email est valide et existe dans la BD. Ensuite, on verifie que le mot de passe entrée est le
    meme que celui contenu dans la BD (on regarde le hash). On store ensuite dans le cookie session les informations
    concernant l'utilisateur et on redirect vers la page UserPage, avec les informations de la session, les achats et
    les followings du user courant.
    :return: Render template de la UserPage, avec les informations de la session, les achats et les
    followings du user courant.
    """
    msg = ''
    if request.method == 'POST' and 'email' in request.form and 'password' in request.form:
        email = request.form['email']
        password = request.form['password'].encode('utf-8')
        cursor.execute('SELECT * FROM Utilisateur WHERE email = %s', (email, ))
        account = cursor.fetchone()
        if account and re.match(r'[^@]+@[^@]+\.[^@]+', email):
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
                achats = BackendCalls.User.getAchatsRecents(session['id'])
                followings = BackendCalls.User.getFollowings(session['id'])

                return render_template('Userpage.html', profile=session, achats=achats, followings=followings)
            else:
                msg = 'Mauvais mot de passe'
        else:
            msg = 'Mot de passe ou email incorrect!'
    return render_template('Login.html', msg=msg)


@app.route('/logout')
def logout():
    """
    Endpoint pour logout le user courant
    On fait seulement nettoyer la session courante, donc vider le cookie session.
    :return: Redirect vers le login page.
    """
    session.clear()
    return redirect(url_for('login'))

@app.route('/buyMerch', methods=[ 'POST'])
def buyMerch():
    """
    Endpoint pour l'achat de la merchandise.
    Fonction qui permet de l'achat de la merchandise dans l'application. On prends le userID et le produitId de la
    merch pour effectuer un INSERT dans la base de donnée. L'utilisateur *achete donc le produit associé au produitID.
    :return: Render template de confirmations, une simple page de confirmation d'achat.
    """
    idProduit = request.form.get('buyMerchId')
    idUser = session['id']
    success = BackendCalls.BuyMerch.buy(idProduit, idUser)
    try:
        if success:
            return render_template('Confirmation.html', success=True)
        else:
            return render_template('Confirmation.html', success=False)
    except Exception as e:
        return render_template('Confirmation.html', success=False)

@app.route('/buyAlbum', methods=[ 'POST'])
def buyAlbum():
    """
    Endpoint pour l'achat d'un album.
    Fonction qui permet d'acheter un album. On prends le userID et le produitId de l'album pour faire un INSERT dans la
    base de donnée. L'utilisateur achete donc l'album associée au produitID.
    :return: Render template de confirmations, une simple page de confirmation d'achat'
    """
    try:
        idProduit = request.form.get('buyAlbumId')
        idUser = session['id']
        success = BackendCalls.BuyAlbum.buy(idProduit, idUser)
        if success:
            return render_template('Confirmation.html', success=True)
        else:
            return render_template('Confirmation.html', success=False)
    except Exception as e:
        return render_template('Confirmation.html', success=False)



@app.route('/register', methods=['GET', 'POST'])
def register():
    """
    Endpoint pour l'inscription d'un utilisateur au site.
    Fonction qui permet de faire l'inscription d'un utilisateur dans la base de donnée pour lui donner accès aux
    fonctionnalitées réservées aux user authenticated. On prends l'ensemble des informations qui sont stockées dans les
    champs du form, on vérifie si ce email est déjà associé à un autre compte puis sinon, on hash le mot de passe de
    l'utilisateur, on applique un salt et on stocke les informations du nouvel utilisateur dans la base de donnée,
    avec le mot de passe hashé.
    :return: Render template qui renvoie à registration avec un message qui est soit positif suite à la création,
    ou bien un message d'erreur.
    """
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
        if len(email) > 63 or len(nom) > 31 or len(prenom) > 31  or len(bio)>100:
            msg = "Erreur dans l'un des champs entré"
            return render_template('Register.html', msg=msg)
        cursor.execute('SELECT * FROM Utilisateur WHERE email = %s', (email,))
        account = cursor.fetchone()
        if account:
            msg = 'Ce compte existe deja!'
        elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
            msg = 'Adresse invalide'
        elif not email or not password or not nom or not prenom:
            msg = 'Vous devez remplir le formulaire!'
        else:
            hashed_password = bcrypt.hashpw(password, bcrypt.gensalt())
            cursor.execute('INSERT INTO Utilisateur (nom, prenom, email, mot_de_passe, age, bio, liens_reseaux_sociaux, id_region) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)',
                (nom, prenom, email, hashed_password, age, bio, link, region))
            connection.commit()
            msg = "Compte créé"
            return render_template('Register.html', msg=msg)
    elif request.method == 'POST':
        msg = 'Vous devez remplir le formulaire!'

    cursor.execute('SELECT id_region, nom FROM Region;')
    regions = cursor.fetchall()

    return render_template('Register.html', msg=msg, regions=regions)




@app.route('/albums',  methods=['GET', 'POST'])
def albums():
    """
    Endpoint pour les albums.
    Fonction qui s'occupe d'afficher les albums qui sont montrés sur la page Albums.html. On fetch les informations
    concernant l'ensemble des albums et des styles dans la base de donnée et les filtres appliqués,
    si certains on été sélectionnés.
    :return: Render template de la page Albums.html avec les informations concernant les styles et les albums, avec le
    filtre.
    """
    try:
        if request.method == 'POST':
            chosen = request.form.get('cat')
            # S'assurer que search est secure, injections SQL possibles
            search = request.form.get('search')
            albums = BackendCalls.Albums.getAlbums(chosen, search)
            categories = BackendCalls.Albums.getCategories()
            return render_template('Albums.html', albums=albums, categories = categories, choisie = chosen)
        else:
            albums = BackendCalls.Albums.getAlbums(None, None)
            categories = BackendCalls.Albums.getCategories()
            return render_template('Albums.html', albums=albums, categories = categories)
    except Exception as e:
        albums = BackendCalls.Albums.getAlbums(None, None)
        categories = BackendCalls.Albums.getCategories()
        flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger les albums.", 'error')
        return render_template('Albums.html', albums=albums, categories=categories)

@app.route('/unfollow', methods=['POST', 'GET'])
def unfollow():
    """
    Endpoint pour l'unfollow.
    Fonction qui gère le unfollow, mais sur la page utilisateur. On sépare la logique du unfollow de celui dans la page
    artiste pour simplifier l'interface utilisateur. On récupère le JSON qui contenait le artisteID qui a été unfollow,
    puis on DELETE dans la base de donnée sur SUIVRE le tuple qui reliait le current userID et le artisteID.
    :return: Objet JSON qui confirme le success ou l'erreur du unfollow.
    """
    if request.method == 'POST':
        id_utilisateur = session.get('id')
        if not id_utilisateur:
            return jsonify({'error': 'User not logged in'}), 403
        data = request.get_json()
        id_artiste = data.get('id_artiste')
        try:
            cursor.execute("DELETE FROM Suivre WHERE id_utilisateur = %s AND id_artiste = %s", (id_utilisateur, id_artiste))
            return jsonify({'success': True})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

@app.route('/follow', methods=['POST', 'DELETE'])
def follow():
    """
    Endpoint follow.
    Fonction qui gère le follow d'un artiste sur l'application. On vérifie d'abord si la méthode est un POST ou un
    DELETE, puis on applique l'opération nécéssaire en fonction de l'ID artiste passée en query params ainsi que
    de l'ID de l'utilisateur présentement connecté.On envoie ces informations dans la BD peu importe la méthode choisie,
    soit on unfollow (DELETE) ou follow(POST).
    :return: Variable follows qui confirme si l'utilisateur s'est abonné ou désabonné, et cette valeur sera
    utiliser pour le display du bouton sur la page de l'artiste.
    """
    id_utilisateur = session.get('id')
    id_artiste = request.args.get('artiste_id')

    try:
        if request.method == 'POST':
            cursor.execute("SELECT 1 FROM Suivre WHERE id_utilisateur = %s AND id_artiste = %s",
                           (id_utilisateur, id_artiste))
            is_following = cursor.fetchone() is not None
            if is_following:
                cursor.execute("DELETE FROM Suivre WHERE id_utilisateur = %s AND id_artiste = %s",
                               (id_utilisateur, id_artiste))
            else:
                cursor.execute("INSERT INTO Suivre (id_utilisateur, id_artiste) VALUES (%s, %s)",
                               (id_utilisateur, id_artiste))
            follows = not is_following
        else:
            cursor.execute("SELECT 1 FROM Suivre WHERE id_utilisateur = %s AND id_artiste = %s",
                           (id_utilisateur, id_artiste))
            follows = cursor.fetchone() is not None

        return jsonify({'follows': follows})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/merch', methods=['GET', 'POST'])
def merchs():
    """
    Endpoint pour la merch.
    Fonction qui ne fait qu'appeler la base de données pour avoir les informations sur l'ensemble des merchs disponibles.
    :return: Render template de la page merch avec l'ensemble des merchs.
    """
    try:
        merchs = BackendCalls.Merchs.getMerchs()
    except Exception as e:
        flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger les produits.", 'error')
        return render_template('Merch.html', merchs=merchs)
    return render_template('Merch.html', merchs=merchs)


@app.route('/universities')
def universities():
    """
    Endpoint pour universités.
    Fonction qui ne fait qu'appeler la base de données pour avoir les informations sur l'ensemble des universities.
    :return: Render template de la page universités avec l'ensemble des université
    """
    try:
        universites = BackendCalls.Universites.getUniversites()
    except Exception as e:
        flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger les Universités.", "error")
        return render_template('Universites.html', universites=universites)
    return render_template('Universites.html', universites=universites)


@app.route('/artistes', methods = ['GET', 'POST'])
def artistes():
    """
       Endpoint pour les artistes.
       Fonction qui ne fait qu'appeler la base de données pour avoir les informations sur l'ensemble des artiste.
       :return: Render template de la page artistes avec l'ensemble des artistes.
       """
    if request.method == 'POST' :
        try:
            chosen = request.form.get('cat')
            search = request.form.get('search')
            artistes = BackendCalls.Artistes.getArtistes(chosen, search)
            universites = BackendCalls.Artistes.getUniversities()
            return render_template('Artistes.html', artistes=artistes, universites = universites)
        except Exception as e:
            flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger les Artistes.", "error")
            return render_template('Artistes.html', artistes=artistes, universites = universites)
    else :
        try:
            artistes = BackendCalls.Artistes.getArtistes(None, None)
            universites = BackendCalls.Artistes.getUniversities()
            return render_template('Artistes.html', artistes=artistes, universites = universites)
        except Exception as e:
            flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger les Artistes.", "error")
            return render_template('Artistes.html', artistes=artistes, universites = universites)


@app.route('/album/<string:album_titre>/<int:id_artiste>')
def album(album_titre, id_artiste):
    """
       Endpoint pour un album.
       Fonction qui va chercher l'ensemble des informations nécessaires pour la page d'un seul album. On utilise
       le titre de l'album et l'id de l'artiste pour faire les appels.
       :return: Render template de la page Album avec les informations concernant un seul album.
       """
    try:
        album = BackendCalls.Album.get_album_details(album_titre, id_artiste)
        # Exécutez la requête pour récupérer les avis de l'album
        cursor.execute(
            "SELECT U.nom, N.note, N.review FROM Noter N JOIN Utilisateur U ON N.id_utilisateur = U.id_utilisateur WHERE N.id_album = %s",
            (album['album']['id_album'],))
        avis_album = cursor.fetchall()
        # Passage des avis au modèle lors du rendu du template
        return render_template('Album.html', album=album, avis_album=avis_album)
    except Exception as e:
        flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger la page de l'album.", "error")
        return render_template('Album.html', album=album)


@app.route('/artiste/<string:artiste_nom>')
def artiste(artiste_nom):
    """
       Endpoint pour un artiste.
       Fonction qui va chercher l'ensemble des informations relatives à un artiste, selon le nom de l'artiste passé
       en paramètre.
       :return: Render template de la page Artiste avec les informations concernant un artiste.
       """
    try:
        artiste = BackendCalls.Artiste.getArtisteDetails(artiste_nom)
        print(artiste)
        return render_template('Artiste.html', artiste=artiste)
    except Exception as e:
        flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger la page de l'artiste.", "error")
        return render_template('Artiste.html', artiste=artiste)

@app.route('/userpage')
def userpage():
    """
    Endpoint pour UserPage.
    On vérifie ici si l'utilisateur est connecté, et s'il' l'est on va récupérer l'ensemble des achats et des
    followings du user connecté.
    :return: Render template de la page User avec les informations sur lui, sur ses achats et ses followings.
    """
    try:
        if 'loggedin' in session and session['loggedin']:
            achats = BackendCalls.User.getAchatsRecents(session['id'])
            followings = BackendCalls.User.getFollowings(session['id'])
            return render_template('Userpage.html', profile=session, achats=achats, followings=followings)
        else:
            return redirect(url_for('login'))
    except Exception as e:
        flash("Erreur interne. Veuillez rafraichir la page. Impossible de charger la page utilisateur.", "error")
        return render_template('Userpage.html', profile=session)


@app.route('/submit_rating_and_review', methods=['POST'])
def submit_rating_and_review():
    """
        Endpoint pour l'envoie des ratings.
        Fonciton qui récupère les données entrées par l'utilisateur dans le forms pour envoyer un review, et ajoute à la
        base de données les informations relatives à ce review. On mets en relation l'utilisateur présentement connecté
        et ces informations ainsi que les informations de l'album qu'on tente de noter. Si l'utilisateur tente de faire
        un review pour un album sur lequel il a deja post un review, on génére un flash qui lui indique qu'il ne peut
        pas le faire, et on rollback la BD pour l'intégrité des données. Un flash est également présenté si l'utilisateur
        fais une note pour la première fois pour lui indiquer un succès.'
        :return: Render template de la page Album, ainsi que les details de l'album qu'on notait présentement.
        """
    if request.method == 'POST':
        note = request.form.get('note')
        review = request.form.get('review')
        album_titre = request.form.get('album_titre')
        artiste_id = request.form.get('artiste_id')
        id_album = request.form.get('id_album')
        id_utilisateur = session['id']
        album_details = BackendCalls.Album.get_album_details(album_titre, artiste_id)
        # Exécutez la requête pour récupérer les avis actualisés des utilisateurs
        cursor.execute(
            "SELECT U.nom, N.note, N.review FROM Noter N JOIN Utilisateur U ON N.id_utilisateur = U.id_utilisateur WHERE N.id_album = %s",
            (id_album,))
        avis_album = cursor.fetchall()
        if len(review)> 1000:
            flash('Votre note est trop longue!', 'error')
            return render_template('Album.html', album=album_details)
        try:
            query = "INSERT INTO Noter (id_utilisateur, id_album, note, review) VALUES (%s, %s, %s, %s)"
            cursor.execute(query, (id_utilisateur, id_album, note, review))
            flash('Votre note a bien été envoyé!', 'success')
            #refaire l'execution de la requête pour récupérer le review q'ont vient d'inserer
            cursor.execute(
                "SELECT U.nom, N.note, N.review FROM Noter N JOIN Utilisateur U ON N.id_utilisateur = U.id_utilisateur WHERE N.id_album = %s",
                (id_album,))
            avis_album = cursor.fetchall()
            return render_template('Album.html', album=album_details, avis_album=avis_album)
        except IntegrityError as e:
            connection.rollback()
            if 'duplicate entry' in str(e).lower():
                flash('Vous avez déjà noté cet album!', 'error')
            else:
                flash('Une erreur est survenue, veuillez réessayer.', 'error')
            return render_template('Album.html', album=album_details, avis_album=avis_album)
        except Exception as e:
            connection.rollback()
            flash('Une erreur est survenue, veuillez réessayer.', 'error')
            return render_template('Album.html', album=album_details, avis_album=avis_album)



if __name__ == '__main__':
    app.run()
