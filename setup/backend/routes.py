from flask import jsonify, request, current_app as app
from models import Item
from db import database


@app.route("/")
def index():
    from flask import render_template

    return (
        "Flask should not serve the static HTML pages. Make sure you adjust your setup!"
    )


@app.route("/json")
def get_from_db():
    try:
        items = Item.query.all()
        if not len(items):
            return jsonify({"message": "Database is empty!"}), 500

        return jsonify([item.json() for item in items])
    except Exception as e:
        return (
            jsonify({"message": "Cannot connect to Mongo server! --- " + str(e)}),
            500,
        )


@app.route("/add", methods=["POST"])
def add_item():
    body = request.get_json()
    item = Item(name=body["name"], bcit_id=body["bcit_id"])
    database.session.add(item)

    try:
        database.session.commit()
    except Exception as e:
        return jsonify({"message": "An error occurred! --- " + str(e)}), 500

    return jsonify(item.json()), 201
