#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Uso: $0 <staging|production> [setup|deploy]" >&2
  exit 1
fi

TARGET="$1"
ACTION="${2:-deploy}"

case "$TARGET" in
  staging|production) ;;
  *)
    echo "Error: destino inválido: $TARGET" >&2
    exit 1
    ;;
esac

case "$ACTION" in
  setup|deploy) ;;
  *)
    echo "Error: acción inválida: $ACTION" >&2
    exit 1
    ;;
esac

# Fallar antes de invocar Kamal si no se puede exportar.
./scripts/export-requirements.sh

# Construir y desplegar con la configuración del destino.
exec kamal "$ACTION" -d "$TARGET"
