
#!/usr/bin/env bash
set -Eeuo pipefail

# Ejecutar desde cualquier directorio.
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

if ! command -v uv >/dev/null 2>&1; then
  echo "Error: uv no está instalado o no está disponible en PATH." >&2
  exit 1
fi

if [[ ! -f pyproject.toml ]]; then
  echo "Error: no se encuentra pyproject.toml en $PROJECT_ROOT" >&2
  exit 1
fi

if [[ ! -f uv.lock ]]; then
  echo "Error: no se encuentra uv.lock. Ejecuta 'uv lock' primero." >&2
  exit 1
fi

OUTPUT_FILE="requirements.txt"

echo "Exportando dependencias bloqueadas para producción..."

uv export \
  --locked \
  --no-dev \
  --no-emit-project \
  --format requirements.txt \
  --output-file "$OUTPUT_FILE"

echo "Dependencias exportadas correctamente a $OUTPUT_FILE"
