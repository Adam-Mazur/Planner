from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from os import environ

app = Flask(__name__)

# From https://blog.pythonanywhere.com/121/
sqlalchemy_database_uri = environ.get("SQLALCHEMY_DATABASE_URI")

app.config['SQLALCHEMY_DATABASE_URI'] = sqlalchemy_database_uri 
app.config["SQLALCHEMY_POOL_RECYCLE"] = 299
# suppress SQLALCHEMY_TRACK_MODIFICATIONS warning
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# # The main model in the database
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    data = db.Column(db.Text)

# Update data
@app.route("/update/<int:id>", methods=['POST'])
def update(id):
    user = User.query.get(id)
    if not user:
        user = User()
        db.session.add(user)
    data = request.json
    user.data = str(data)
    db.session.commit()
    return jsonify(data)

# Get data
@app.route("/get/<int:id>")
def get(id):
    user = User.query.get(id)
    if not user:
        user = User()
        db.session.add(user)
    return jsonify(eval(user.data)) 
