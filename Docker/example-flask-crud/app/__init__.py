from flask import Flask, render_template_string, request
from app.config import Config
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import os
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
app.logger.setLevel(logging.INFO)

# Load configuration
app.config.from_object(Config)

# Set up database
db = SQLAlchemy(app)

# Initialize migration engine
migrate = Migrate(app, db)

# Import routes and models after app and db are defined
from app import routes, models

# Check if we can connect to the database
try:
    with app.app_context():
        db.engine.execute('SELECT 1')
    app.logger.info("Database connection successful")
except Exception as e:
    app.logger.error(f"Database connection failed: {str(e)}")
    
    @app.route('/')
    @app.route('/index')
    def fallback_index():
        return "Hello from the Flask CRUD App! This is a simplified version that doesn't require database connectivity."
    
    @app.route('/add', methods=['GET', 'POST'])
    def fallback_add():
        if request.method == 'POST':
            return "Database connection is not available. Cannot add entries."
        return render_template_string("""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Add Entry - Flask CRUD App</title>
            <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
        </head>
        <body>
            <div class="container mt-5">
                <h2>Add New Entry</h2>
                <div class="alert alert-danger">
                    Database connection is not available. This is a fallback form.
                </div>
                <form method="post">
                    <div class="form-group">
                        <input type="text" class="form-control" name="title" placeholder="Title" required>
                    </div>
                    <div class="form-group">
                        <textarea class="form-control" name="description" placeholder="Description" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">Add Entry</button>
                    <a href="/" class="btn btn-secondary">Cancel</a>
                </form>
            </div>
        </body>
        </html>
        """)
    
    # Override other routes that require database access
    @app.route('/update/<int:id>', methods=['GET', 'POST'])
    def fallback_update(id):
        return "Database connection is not available. Cannot update entries."
    
    @app.route('/delete/<int:id>')
    def fallback_delete(id):
        return "Database connection is not available. Cannot delete entries."
