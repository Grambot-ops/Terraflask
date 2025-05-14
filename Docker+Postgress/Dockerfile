# Docker/Dockerfile (Production Ready)
FROM python:3.13-slim 

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

RUN addgroup --system app && adduser --system --ingroup app app

# Copy requirements first for caching
COPY ./example-flask-crud/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the runtime entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown app:app /entrypoint.sh

# Copy ALL application code, including the 'migrations' directory
# which was checked into Git during development.
COPY ./example-flask-crud /app

RUN chown -R app:app /app

USER app

EXPOSE 5000 

ENTRYPOINT ["/entrypoint.sh"]