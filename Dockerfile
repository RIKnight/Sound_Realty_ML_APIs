# syntax=docker/dockerfile:1.7
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Non-root user
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python -m pip install --upgrade pip && pip install -r requirements.txt

# Copy source
COPY app app
COPY gunicorn.conf.py .

# Version at build-time (also override at runtime via env)
ARG APP_VERSION=0.1.0
ENV APP_VERSION=${APP_VERSION}

USER appuser
EXPOSE 8000
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD curl -fsS http://localhost:8000/healthz || exit 1

CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:create_app()"]

