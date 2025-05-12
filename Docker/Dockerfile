# Docker/Dockerfile
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Install system dependencies if needed (e.g., for psycopg2, netcat for better wait)
# RUN apt-get update && apt-get install -y --no-install-recommends netcat-openbsd postgresql-client && rm -rf /var/lib/apt/lists/*

RUN addgroup --system app && adduser --system --ingroup app app

# Copy requirements *first* from the app sub-directory
COPY ./example-flask-crud/requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the entrypoint script from the build context root (Docker/)
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown app:app /entrypoint.sh

# Copy the application code from the app sub-directory
COPY ./example-flask-crud /app

RUN chown -R app:app /app

USER app

EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]