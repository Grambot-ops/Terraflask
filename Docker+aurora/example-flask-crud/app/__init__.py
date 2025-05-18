from flask import Flask
from app.config import Config
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from werkzeug.middleware.proxy_fix import ProxyFix
import faulthandler
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

faulthandler.enable()

app = Flask(__name__)
app.config.from_object(Config)

# If the app is behind a proxy, wrap it with ProxyFix
# This helps with URL generation and header handling (e.g., X-Forwarded-For)
# x_for=1 means trust one hop for X-Forwarded-For (e.g., our ALB)
# x_proto=1 means trust one hop for X-Forwarded-Proto (e.g., http vs https from ALB)
# x_host=1 means trust one hop for X-Forwarded-Host
# x_prefix=1 means trust one hop for X-Forwarded-Prefix
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

db = SQLAlchemy(app)
migrate = Migrate(app, db)

# Attempt to create database tables if they don't exist, but don't fail if there's an issue
try:
    with app.app_context():
        db.create_all()
        logger.info("Database tables created or already exist")
except Exception as e:
    logger.error(f"Error creating database tables: {str(e)}")
    logger.info("Continuing without database initialization")

from app import routes, models
