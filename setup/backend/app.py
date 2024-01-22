from flask import Flask
from db import database, get_db_settings


def create_app():
    app = Flask(__name__, instance_relative_config=False)
    app.config["SQLALCHEMY_DATABASE_URI"] = get_db_settings()
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    database.init_app(app)

    with app.app_context():
        import routes

        database.create_all()

        return app
