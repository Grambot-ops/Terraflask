#!/bin/sh
# Docker/entrypoint.sh

set -e # Abort on any error

wait_for_postgres() {
  echo "Waiting for postgres..."
  # Simplified wait - adjust sleep time as needed, or implement robust check
  # (Requires installing netcat or postgresql-client in Dockerfile)
  sleep 15 # Increased sleep slightly
  echo "Assuming Postgres is up..."
}

# Wait for the database service to be ready
wait_for_postgres

# Run database migrations
# FLASK_APP should be set via .env in docker-compose
echo "Running database migrations..."
flask db upgrade
echo "Database migrations complete."

# Start Gunicorn
echo "Starting Gunicorn..."
exec gunicorn --bind 0.0.0.0:5000 crudapp:app