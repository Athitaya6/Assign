from flask import Flask, render_template, request, redirect, url_for
import mysql.connector
import os

app = Flask(__name__, static_url_path='/static', static_folder='../frontend/static')

db = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

@app.route('/')
def home():
    return render_template("home.html")

@app.route('/movies')
def movie_list():
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM movies")
    movies = cursor.fetchall()
    return render_template("movies.html", movies=movies)

@app.route('/add', methods=['POST'])
def add_movie():
    data = (
        request.form['title'],
        request.form['year'],
        request.form['imdb'],
        request.form['rt'],
        request.form['poster']
    )
    cursor = db.cursor()
    cursor.execute("INSERT INTO movies (title, year, imdb_score, rt_score, poster_url) VALUES (%s, %s, %s, %s, %s)", data)
    db.commit()
    return redirect(url_for('movie_list'))

@app.route('/delete/<int:id>')
def delete_movie(id):
    cursor = db.cursor()
    cursor.execute("DELETE FROM movies WHERE id = %s", (id,))
    db.commit()
    return redirect(url_for('movie_list'))

@app.route('/edit/<int:id>', methods=['GET', 'POST'])
def edit_movie(id):
    cursor = db.cursor(dictionary=True)
    if request.method == 'POST':
        data = (
            request.form['title'],
            request.form['year'],
            request.form['imdb'],
            request.form['rt'],
            request.form['poster'],
            id
        )
        cursor.execute("UPDATE movies SET title=%s, year=%s, imdb_score=%s, rt_score=%s, poster_url=%s WHERE id=%s", data)
        db.commit()
        return redirect(url_for('movie_list'))
    cursor.execute("SELECT * FROM movies WHERE id = %s", (id,))
    movie = cursor.fetchone()
    return render_template("edit.html", movie=movie)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
