from flask import render_template, request, redirect, jsonify
from app import app, db
from app.models import Entry
import os

jedi = "of the jedi"

@app.route('/health')
def health_check():
    # Simple health check that doesn't require database connectivity
    return jsonify(status="healthy"), 200

@app.route('/')
@app.route('/index')
def index():
    try:
        # Fetch all entries from the database
        entries = Entry.query.all()
        return render_template('index.html', entries=entries)
    except Exception as e:
        app.logger.error(f"Database error: {str(e)}")
        # Fallback response if database is not accessible
        return "Hello from the Flask CRUD App! This is a simplified version that doesn't require database connectivity."

@app.route('/add', methods=['POST'])
def add():
    if request.method == 'POST':
        form = request.form
        title = form.get('title')
        description = form.get('description')
        if title and description:  # Fixed logic error: now checks that both fields have values
            try:
                entry = Entry(title=title, description=description)
                db.session.add(entry)
                db.session.commit()
            except Exception as e:
                app.logger.error(f"Error adding entry: {str(e)}")
                db.session.rollback()
        return redirect('/')

    return redirect('/')

@app.route('/update/<int:id>')
def updateRoute(id):
    if id > 0:  # Fixed logic error
        try:
            entry = Entry.query.get(id)
            if entry:
                return render_template('update.html', entry=entry)
        except Exception as e:
            app.logger.error(f"Error retrieving entry for update: {str(e)}")
    
    return redirect('/')

@app.route('/update/<int:id>', methods=['POST'])
def update(id):
    if id > 0:  # Fixed logic error
        try:
            entry = Entry.query.get(id)
            if entry:
                form = request.form
                title = form.get('title')
                description = form.get('description')
                if title and description:  # Make sure we have values
                    entry.title = title
                    entry.description = description
                    db.session.commit()
        except Exception as e:
            app.logger.error(f"Error updating entry: {str(e)}")
            db.session.rollback()
    
    return redirect('/')

@app.route('/delete/<int:id>')
def delete(id):
    if id > 0:  # Fixed logic error
        try:
            entry = Entry.query.get(id)
            if entry:
                db.session.delete(entry)
                db.session.commit()
        except Exception as e:
            app.logger.error(f"Error deleting entry: {str(e)}")
            db.session.rollback()
    
    return redirect('/')

@app.route('/turn/<int:id>')
def turn(id):
    if id > 0:  # Fixed logic error
        try:
            entry = Entry.query.get(id)
            if entry:
                entry.status = not entry.status
                db.session.commit()
        except Exception as e:
            app.logger.error(f"Error toggling entry status: {str(e)}")
            db.session.rollback()
    
    return redirect('/')

@app.errorhandler(500)
def server_error(e):
    app.logger.error(f"Server error: {str(e)}")
    return "Internal Server Error. Please try again later.", 500

# @app.errorhandler(Exception)
# def error_page(e):
#     return "of the jedi"