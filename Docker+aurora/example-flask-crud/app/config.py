# app/config.py
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class Config(object):
    # Always use environment variables in containerized setups
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-key-for-testing')
    
    # Use a fallback for database URL
    database_url = os.environ.get('DATABASE_URL')
    if not database_url:
        logger.warning("No DATABASE_URL set, using in-memory SQLite")
        SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    else:
        logger.info("Using configured DATABASE_URL")
        SQLALCHEMY_DATABASE_URI = database_url
        
    SQLALCHEMY_TRACK_MODIFICATIONS = False # Good practice to disable if not needed

    # Basic error check: Ensure essential variables are set
    if not SECRET_KEY:
        raise ValueError("No SECRET_KEY set for Flask application")
    if not SQLALCHEMY_DATABASE_URI:
        raise ValueError("No DATABASE_URL set for Flask application")