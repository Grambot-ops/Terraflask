# app/config.py
import os

class Config(object):
    # Always use environment variables in containerized setups
    SECRET_KEY = os.environ.get('SECRET_KEY')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False # Good practice to disable if not needed

    # Basic error check: Ensure essential variables are set
    if not SECRET_KEY:
        raise ValueError("No SECRET_KEY set for Flask application")
    if not SQLALCHEMY_DATABASE_URI:
        raise ValueError("No DATABASE_URL set for Flask application")