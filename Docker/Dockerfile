# Use the official Python image from the Docker Hub
FROM python:3.13-slim

# Set the working directory in the container
WORKDIR /app

# Create a non-root user and group (good practice for production)
RUN addgroup --system app && adduser --system --ingroup app app

# Copy the requirements file into the container
COPY ./example-flask-crud/requirements.txt .

# Install the dependencies (including uvicorn)
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
# Ensure .dockerignore is set up
COPY . .

# Change ownership of the app directory
RUN chown -R app:app /app

# Switch to the non-root user
USER app

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application using Uvicorn
# This assumes your Flask app instance is named 'app' in 'crudapp.py'
CMD ["uvicorn", "crudapp:app", "--host", "0.0.0.0", "--port", "5000"]