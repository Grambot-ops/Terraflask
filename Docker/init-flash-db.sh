#!/bin/bash
# init-flask-db.sh - Script to perform one-time Flask-Migrate setup

set -e # Exit immediately if a command exits with a non-zero status.

echo "Ensuring application image is built..."
docker-compose build application

# Check if migrations directory already exists locally
if [ -d "example-flask-crud/migrations" ]; then
  echo "'example-flask-crud/migrations' directory already exists."
  # Optionally, ask if user wants to proceed or exit
  # read -p "Proceed with migrate anyway? (y/N) " -n 1 -r
  # echo
  # if [[ ! $REPLY =~ ^[Yy]$ ]]
  # then
  #     exit 1
  # fi
else
  echo "Running flask db init (as root in temporary container)..."
  docker-compose run --rm \
    -u root \
    -v "$(pwd)/example-flask-crud:/app" \
    --entrypoint "" \
    application flask db init
  echo "Flask db init completed."
fi

echo "Starting database service..."
docker-compose up -d db
echo "Waiting for database to be ready (approx 15s)..."
sleep 15
docker-compose ps db # Show DB status

echo "Running flask db migrate (as root in temporary container)..."
docker-compose run --rm \
  -u root \
  -v "$(pwd)/example-flask-crud:/app" \
  --entrypoint "" \
  application flask db migrate -m "Initial migration setup"
  # Note: Maybe prompt for a message? Or keep it generic for init.
echo "Flask db migrate completed."

echo "Stopping database service..."
docker-compose down

echo "Fixing ownership of migrations directory..."
sudo chown -R $(id -u):$(id -g) example-flask-crud/migrations
echo "Ownership fixed."

echo "------------------------------------------------------------------"
echo "Initialization complete."
echo "IMPORTANT: Add 'example-flask-crud/migrations' to Git and commit!"
echo "You can now run 'docker-compose up -d' to start the application."
echo "------------------------------------------------------------------"