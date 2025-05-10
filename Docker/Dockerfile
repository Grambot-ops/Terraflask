# Use an official Python runtime as a parent image
FROM python:3.13-slim

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file
COPY example-flask-crud/requirements.txt .

# Install Python dependencies
# --no-cache-dir reduces image size
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

# Copy the rest of the application code into the container
# This includes your 'app' package, crudapp.py, etc.
COPY example-flask-crud/ .

# Expose the port Gunicorn will run on
EXPOSE 5000

# Run the application using Gunicorn
# Adjust the number of workers based on your instance's CPU cores (e.g., (2 * CPU_CORES) + 1)
# This assumes your Flask app instance is named 'app' in 'crudapp.py'
# (e.g., crudapp.py contains: from app import create_app; app = create_app())
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:5000", "crudapp:app"]
