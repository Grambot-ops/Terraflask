# Docker/Dockerfile (Production Ready)
FROM python:3.13-slim 

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=crudapp.py
ENV FLASK_ENV=production

WORKDIR /app

RUN addgroup --system app && adduser --system --ingroup app app

# Install required packages for PostgreSQL
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for caching
COPY ./Docker/example-flask-crud/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir psycopg2-binary

# Copy ALL application code, including the 'migrations' directory
COPY ./Docker/example-flask-crud /app

RUN chown -R app:app /app

USER app

EXPOSE 5000 

# Run migrations and start Gunicorn
CMD flask db upgrade || flask db init && flask db migrate -m "Initial migration" && flask db upgrade && \
    gunicorn --workers 1 --bind 0.0.0.0:5000 --log-level debug \
    --access-logfile - --error-logfile - \
    --access-logformat '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"' \
    --timeout 120 --preload app:app