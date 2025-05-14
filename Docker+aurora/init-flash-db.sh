#!/bin/bash
# init-flask-db.sh - Script to perform one-time Flask-Migrate setup

set -e # Exit immediately if a command exits with a non-zero status.

echo "Ensuring application image is built..."
# Ensure .env file is present and configured for Aurora if flask db migrate needs it
if [ ! -f .env ]; then
    echo "ERROR: .env file not found. Please create it and configure DATABASE_URL."
    exit 1
fi
# Source .env to make DATABASE_URL available if needed by commands below,
# though docker-compose run usually handles this if env_file is specified.
# However, for direct flask commands outside compose, this might be useful.
# export $(grep -v '^#' .env | xargs)

docker-compose build application

# Check if migrations directory already exists locally
if [ -d "example-flask-crud/migrations" ]; then
  echo "'example-flask-crud/migrations' directory already exists."
else
  echo "Running flask db init (as root in temporary container)..."
  # This command doesn't need DB connectivity
  docker-compose run --rm \
    -u root \
    -v "$(pwd)/example-flask-crud:/app" \
    --entrypoint "" \
    application flask db init
  echo "Flask db init completed."
fi

# No need to start 'db' service as it's removed.
# echo "Starting database service..."
# docker-compose up -d db
# echo "Waiting for database to be ready (approx 15s)..."
# sleep 15
# docker-compose ps db # Show DB status

echo "Running flask db migrate (as root in temporary container)..."
echo "This will generate the initial migration script based on your models."
echo "It will use DATABASE_URL from your .env file, which should point to Aurora."
# Ensure your Aurora DB is accessible from where you run this script,
# or that flask db migrate can generate a script without full connectivity
# for the very first migration (often it can, just comparing to models).
docker-compose run --rm \
  -u root \
  -e DATABASE_URL=${DATABASE_URL} ` # Explicitly pass, ensure .env is sourced or vars set` \
  -v "$(pwd)/example-flask-crud:/app" \
  --entrypoint "" \
  application flask db migrate -m "Initial migration setup"
echo "Flask db migrate completed. A new migration script should be in example-flask-crud/migrations/versions/"

# No 'db' service to stop
# echo "Stopping database service..."
# docker-compose down

echo "Fixing ownership of migrations directory (if it was created)..."
if [ -d "example-flask-crud/migrations" ]; then
  # Use sudo only if necessary, try without first if you run Docker as non-root
  # or have user namespace remapping.
  # If you run docker-compose as root, then sudo chown is needed.
  # If you run docker-compose as your user, this might not be needed or
  # 'sudo' might not be the right command.
  # A safer alternative is to ensure the container runs as your user ID for this step.
  # For simplicity, assuming sudo is available and needed if files are root-owned.
  if sudo -n true 2>/dev/null; then # Check if sudo can be run without password
    sudo chown -R $(id -u):$(id -g) example-flask-crud/migrations
  else
    echo "Attempting chown without sudo. If it fails, you may need to run manually:"
    echo "  sudo chown -R $(id -u):$(id -g) example-flask-crud/migrations"
    chown -R $(id -u):$(id -g) example-flask-crud/migrations
  fi
  echo "Ownership fixed."
fi

echo "------------------------------------------------------------------"
echo "Initialization complete."
echo "IMPORTANT: Add 'example-flask-crud/migrations' to Git and commit!"
echo "The 'flask db upgrade' in entrypoint.sh will apply these to Aurora."
echo "You can now run 'docker-compose up -d application' to start the application"
echo "locally, connecting to your AWS Aurora database."
echo "Ensure your local IP is whitelisted in Aurora's security group if testing this way."
echo "------------------------------------------------------------------"