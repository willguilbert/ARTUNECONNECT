
from flask import Flask, render_template, request, url_for
import pymysql, pymysql.cursors



app = Flask(__name__)
UserProfile = {}

@app.route('/')
def main():  # put application's code here
    return render_template('Home.html')

@app.route("/login", methods=['GET','POST'])
def login():
    if request.method == "POST":

        username = '"'+request.form.get('username')+'"'
        mdp = request.form.get('mdp')

        conn = pymysql.connect(host='localhost', user='root', password='1234', db='courslab1')
        try:
            cmd = 'SELECT mdp FROM Users WHERE user='+username+';'
            cur = conn.cursor()
        except Exception as e:
            print(e)
        cur.execute(cmd)
        mdpVrai = cur.fetchone()

        if (mdpVrai != None) and (mdp == mdpVrai[0]):
            cmd = 'SELECT * FROM Users WHERE user='+username+';'
            cur = conn.cursor()
            cur.execute(cmd)
            info = cur.fetchone()

            global UserProfile
            UserProfile['username'] = username
            UserProfile['email'] = info[2]
            UserProfile['ville']= info[3]
            UserProfile['bio']= info[4]
            UserProfile['telephone']= info[5]
            UserProfile['prenom']=info[7]
            UserProfile['nom']= info[8]
            UserProfile['rating'] = info[6]
            return render_template('Userpage.html', profile=UserProfile)
        return render_template('Login.html', message="Invalid username or password")
    else:
        return render_template('Login.html')

@app.route('/albums')
def albums():
    return render_template('Albums.html')
@app.route('/merch')
def merch():
    return render_template('Merch.html')

@app.route('/universities')
def universities():
    return render_template('Universities.html')


if __name__ == '__main__':
    app.run()
