from flask import render_template, request, redirect, jsonify
from app import app, db
from app.models import Entry
import os

jedi = "of the jedi"

@app.route('/health')
def health():
    """Health check endpoint for ALB"""
    try:
        # Test database connection
        db.session.execute('SELECT 1')
        return jsonify({"status": "healthy"})
    except Exception as e:
        app.logger.error(f"Health check failed: {e}")
        return jsonify({"status": "unhealthy", "reason": str(e)}), 500

@app.route('/')
@app.route('/index')
def index():
    try:
        # Check if we can connect to the database
        db.session.execute('SELECT 1')
        entries = Entry.query.all()
        return render_template('index.html', entries=entries)
    except Exception as e:
        app.logger.error(f"Database connection error: {e}")
        # Fallback response when database is not available
        return "Hello from the Flask CRUD App! This is a simplified version that doesn't require database connectivity."

@app.route('/add', methods=['GET', 'POST'])
def add():
    if request.method == 'POST':
        form = request.form
        title = form.get('title')
        description = form.get('description')
        if title and description:  # Fixed logic: Only add if both title AND description are provided
            try:
                entry = Entry(title=title, description=description)
                db.session.add(entry)
                db.session.commit()
            except Exception as e:
                app.logger.error(f"Error adding entry: {e}")
        return redirect('/')
    else:
        # For GET requests, render a simple form
        return render_template('content.html', entries=[])

@app.route('/update/<int:id>', methods=['GET', 'POST'])
def update(id):
    if not id or id == 0:
        return redirect('/')
        
    if request.method == 'POST':
        entry = Entry.query.get(id)
        if entry:
            form = request.form
            title = form.get('title')
            description = form.get('description')
            entry.title = title
            entry.description = description
            db.session.commit()
        return redirect('/')
    else:
        entry = Entry.query.get(id)
        if entry:
            return render_template('update.html', entry=entry)
        return redirect('/')

@app.route('/delete/<int:id>')
def delete(id):
    if not id or id == 0:
        return redirect('/')
        
    entry = Entry.query.get(id)
    if entry:
        db.session.delete(entry)
        db.session.commit()
    return redirect('/')

@app.route('/turn/<int:id>')
def turn(id):
    if not id or id == 0:
        return redirect('/')
        
    entry = Entry.query.get(id)
    if entry:
        entry.status = not entry.status
        db.session.commit()
    return redirect('/')

# Error handler for all exceptions
@app.errorhandler(Exception)
def error_page(e):
    app.logger.error(f"Unhandled error: {e}")
    return "An error occurred. Please try again later or contact support."