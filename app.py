
from flask import Flask, render_template, request, url_for
import pymysql, pymysql.cursors
import static.Home
import static.Albums



app = Flask(__name__)
UserProfile = {}

@app.route('/')
def main():
    rowsAlbums = static.Home.getAlbums()
    rowsArtistes = static.Home.getArtistes()
    rowsUniversite = static.Home.getUniversite()
    return render_template('Home.html', rowsAlbum=rowsAlbums, rowsArtistes=rowsArtistes, rowsUniversite=rowsUniversite)

@app.route("/login", methods=['GET','POST'])
def login():
    if request.method == "POST":

        email = '"'+request.form.get('username')+'"'
        mdp = request.form.get('mdp')

        conn = pymysql.connect(host='localhost', user='root', password='1234', db='TEST_ARTUNECONNECT')
        try:
            cmd = 'SELECT mot_de_passe FROM Utilisateur WHERE email='+email+';'
            cur = conn.cursor()
        except Exception as e:
            print(e)
        cur.execute(cmd)
        mdpVrai = cur.fetchone()

        if (mdpVrai != None) and (mdp == mdpVrai[0]):
            cmd = 'SELECT * FROM Utilisateur WHERE email='+email+';'
            cur = conn.cursor()
            cur.execute(cmd)
            info = cur.fetchone()

            global UserProfile
            UserProfile['username'] = email
            UserProfile['email'] = info[2]
            UserProfile['ville']= info[3]
            UserProfile['bio']= info[4]
            UserProfile['telephone']= info[5]
            UserProfile['prenom']=info[7]
            UserProfile['nom']= info[8]
            cur.close()

            return render_template('Userpage.html', profile=UserProfile)
        return render_template('Login.html', message="Invalid username or password")
    else:
        return render_template('Login.html')

@app.route('/albums')
def albums():
    albums = static.Albums.getAlbums()
    return render_template('Albums.html', albums=albums)
@app.route('/merch')
def merch():
    return render_template('Merch.html')

@app.route('/universities')
def universities():
    return render_template('Universities.html')

@app.route('/artistes')
def artistes():
    return render_template('Artistes.html')


if __name__ == '__main__':
    app.run(debug=True)

