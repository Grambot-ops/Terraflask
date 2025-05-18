#!/bin/sh
# Docker/entrypoint.sh

set -e # Abort on any error

# wait_for_postgres() { # This function is less relevant for external DBs like Aurora
#   echo "Waiting for postgres..."
#   # The old sleep was a very basic wait.
#   # For Aurora, the expectation is it's up, or the app handles connection issues.
#   # If you absolutely need a wait here, you might need to install 'pg_isready'
#   # or 'psql' in your Dockerfile to actively check the Aurora endpoint.
#   # For now, we'll assume the app/driver handles initial connection.
#   echo "Proceeding with assumption that external database is reachable."
# }

# wait_for_postgres # Consider removing or adapting this call

# Run database migrations
# FLASK_APP should be set via .env in docker-compose
echo "Running database migrations against ${DATABASE_URL}..." # Good to log the target
flask db upgrade
echo "Database migrations complete."

# Test if Python can import the app
echo "Attempting to import 'app:app' with python -c ..."
python -c "from app import app; print('Successfully imported app:app. App object:', app)" || echo "Failed to import app:app with python -c"

# Start Gunicorn server with enhanced logging, increased timeout, and preloading
echo "Starting Gunicorn server..."
exec gunicorn --workers 1 --bind 0.0.0.0:5000 --log-level debug --access-logfile - --error-logfile - --access-logformat '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"' --timeout 120 --preload app:app