from flask import Flask, request, redirect, render_template, jsonify
from flask_cors import CORS  # Import CORS
import mysql.connector
import os

app = Flask(__name__)

# Enable CORS for all routes and origins
CORS(app)

# Database configuration
db_config = {
    'host': os.environ.get('MYSQL_HOST', 'db'),  # Hostname of the database container
    'user': 'root',
    'password': os.environ.get('MYSQL_ROOT_PASSWORD', 'rootpassword'),
    'database': os.environ.get('MYSQL_DATABASE', 'tecvinson_registration')
}

@app.route('/register', methods=['POST'])
def register():
    # Get form data
    first_name = request.form['first_name']
    last_name = request.form['last_name']
    email = request.form['email']

    # Insert data into the database
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO students (first_name, last_name, email)
            VALUES (%s, %s, %s)
        """, (first_name, last_name, email))
        conn.commit()
    except mysql.connector.Error as err:
        return f"Database Error: {err}", 500
    finally:
        cursor.close()
        conn.close()

    return redirect('/success')

@app.route('/success')
def success():
    return render_template('success.html')

@app.route('/students', methods=['GET'])
def get_students():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT first_name, last_name, email, registration_date FROM students")
        students = cursor.fetchall()
        return jsonify(students)
    except mysql.connector.Error as err:
        return f"Database Error: {err}", 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    # Run the Flask app on port 5500
    app.run(host='0.0.0.0', port=5500)
