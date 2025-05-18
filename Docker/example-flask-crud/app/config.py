# app/config.py
import os

class Config(object):
    # Always use environment variables in containerized setups
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False # Good practice to disable if not needed

    # Gracefully handle missing database URL
    if not SQLALCHEMY_DATABASE_URI:
        print("WARNING: No DATABASE_URL environment variable set. Using SQLite as fallback.")
        SQLALCHEMY_DATABASE_URI = 'sqlite:///app.db'