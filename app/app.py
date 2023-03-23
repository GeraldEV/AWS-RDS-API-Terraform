import os
import json

import boto3

from flask import Flask, request, Response, jsonify, render_template
from flask_api import status
from flask_sqlalchemy import SQLAlchemy


db = SQLAlchemy()
app = Flask(__name__)

secret_name = os.environ.get("SECRET_NAME")
secret_region_name = os.environ.get("SECRET_REGION_NAME")
session = boto3.session.Session()
client = session.client(service_name="secretsmanager", region_name=secret_region_name)
secrets = json.loads(client.get_secret_value(SecretId=secret_name)["SecretString"])

endpoint = secrets["host"]
username = secrets["username"]
password = secrets["password"]
dbName = os.environ.get("DB_NAME")

dbType = secrets["engine"] + "+pymysql"
port = secrets["port"]

app.config["SQLALCHEMY_DATABASE_URI"] = f"{dbType}://{username}:{password}@{endpoint}:{str(port)}/{dbName}"

db.init_app(app)


class Artist(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(64), unique=True, nullable=False)

  @property
  def serialise(self):
    return {"id": self.id, "name": self.name}

def get_artist_or_error(artist_id):
  return Artist.query.get_or_404(artist_id)


@app.get("/")
def index():
  return render_template("index.html")

@app.get("/ping/")
def ping():
  return "pong"

@app.get("/health/")
def health():
  try:
    Artist.query.first()
  except:
    return jsonify({"status": "Failed to query database"}), status.HTTP_503_SERVICE_UNAVAILABLE

  return jsonify({"status": "Healthy"}), status.HTTP_200_OK

@app.get("/artists/")
def get_artists():
  artists = db.session.query(Artist).all()
  data = [artist.serialise for artist in artists]
  return jsonify(data)

@app.post("/artists/")
def post_artists():
  data = request.json
  if "artist" not in data:
    return jsonify({"error": "Missing \"artist\" in json"}), status.HTTP_400_BAD_REQUEST

  name = data["artist"].strip()
  artist = Artist.query.filter_by(name=name).first()
  if artist is not None:
    return jsonify({"error": f"Artist with name \"{name}\" already exists"}), status.HTTP_400_BAD_REQUEST

  artist = Artist(name=name)
  db.session.add(artist)
  db.session.commit()
  return jsonify(artist.serialise), status.HTTP_201_CREATED

@app.get("/artists/<int:artist_id>/")
def get_artist(artist_id):
  artist = Artist.query.get_or_404(artist_id)
  return jsonify(artist.serialise)

@app.post("/artists/<int:artist_id>/")
def post_artist(artist_id):
  artist = Artist.query.get_or_404(artist_id)

  data = request.json
  if "artist" not in data:
    return jsonify({"error": "Missing \"artist\" in json"}), status.HTTP_400_BAD_REQUEST

  artist.name = data["artist"]
  db.session.commit()

  return jsonify(artist.serialise)

@app.delete("/artists/<int:artist_id>/")
def delete_artist(artist_id):
  artist = Artist.query.get_or_404(artist_id)
  db.session.delete(artist)
  db.session.commit()
  return "", status.HTTP_204_NO_CONTENT


if __name__ == "__main__":
  with app.app_context():
    db.create_all()

  app.run(host="0.0.0.0", port=80)

