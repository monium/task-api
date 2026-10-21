FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Instalar dependencias antes de copiar el código para
# aprovechar la caché de las capas Docker.
COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt

# Copiar únicamente el código de la aplicación.
COPY app/ ./app/

# Usuario sin privilegios y directorio de SQLite.
RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /data \
    && chown -R appuser:appuser /app /data

USER 10001

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "app.main:app", \
     "--host", "0.0.0.0", "--port", "8000"]
