import configparser
import logging
import sys
from os import environ

from flask_sqlalchemy import SQLAlchemy

logger = logging.getLogger(__name__)
database = SQLAlchemy()


def get_db_settings():
    mapping = {
        "host": "MYSQL_HOST",
        "port": "MYSQL_PORT",
        "db": "MYSQL_DB",
        "user": "MYSQL_USER",
        "password": "MYSQL_PASSWORD",
    }

    data = {k: environ.get(v) for k, v in mapping.items()}

    if not all(data.values()):
        config = configparser.ConfigParser()
        config.read("backend.conf")
        try:
            options = config["database"]
            data = {k: options[v] for k, v in mapping.items()}
        except KeyError:
            logger.warn("Configuration file (backend.conf) is missing or incorrect!")

    if any([not data[key] for key in mapping.keys()]):
        sys.exit(-1)

    connection_string = f'mysql://{data["user"]}:{data["password"]}@{data["host"]}:{data["port"]}/{data["db"]}'
    return connection_string
