# justfile — Tasks API
# Requiere: just, uv, Docker y Kamal.

set shell := ["bash", "-euo", "pipefail", "-c"]

# Entornos disponibles.
default_target := "staging"

# Mostrar recetas disponibles.
default:
    @just --list

# Instalar/sincronizar dependencias locales.
setup-local:
    uv sync

# Actualizar el lockfile tras modificar dependencias.
lock:
    uv lock

# Ejecutar la API en desarrollo.
run:
    uv run uvicorn app.main:app --reload

# Ejecutar pruebas, si existe el conjunto de tests.
test:
    uv run pytest

# Exportar dependencias de producción para Docker.
export-requirements:
    uv export \
        --locked \
        --no-dev \
        --no-emit-project \
        --format requirements.txt \
        --output-file requirements.txt

# Construir la imagen local.
docker-build: export-requirements
    docker build -t tasks-api:local .

# Arrancar la imagen local con SQLite persistente.
docker-run:
    docker volume create tasks-api-data
    docker run --rm \
        --name tasks-api \
        -p 8000:8000 \
        -v tasks-api-data:/data \
        -e DATABASE_URL=sqlite:////data/tasks.db \
        tasks-api:local

# Validar configuración de Kamal.
config $TARGET=default_target:
    #!/usr/bin/env bash
    case "$TARGET" in
        staging|production) ;;
        *) echo "Destino inválido: $TARGET" >&2; exit 1 ;;
    esac
    kamal config -d "$TARGET"

# Preparar el entorno en el primer despliegue.
setup $TARGET=default_target: export-requirements
    #!/usr/bin/env bash
    case "$TARGET" in
        staging|production) ;;
        *) echo "Destino inválido: $TARGET" >&2; exit 1 ;;
    esac
    kamal setup -d "$TARGET"

# Desplegar una nueva versión.
deploy $TARGET=default_target: export-requirements
    #!/usr/bin/env bash
    case "$TARGET" in
        staging|production) ;;
        *) echo "Destino inválido: $TARGET" >&2; exit 1 ;;
    esac
    kamal deploy -d "$TARGET"

# Consultar el estado de los servicios.
status $TARGET=default_target:
    #!/usr/bin/env bash
    case "$TARGET" in
        staging|production) ;;
        *) echo "Destino inválido: $TARGET" >&2; exit 1 ;;
    esac
    kamal details -d "$TARGET"

# Consultar los logs de la aplicación.
logs $TARGET=default_target:
    #!/usr/bin/env bash
    case "$TARGET" in
        staging|production) ;;
        *) echo "Destino inválido: $TARGET" >&2; exit 1 ;;
    esac
    kamal app logs -d "$TARGET"

# Consultar las opciones disponibles para rollback.
rollback-help:
    kamal rollback --help
