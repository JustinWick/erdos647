#!/usr/bin/env bash
# Repository-wide driver. Ordinary lake build/lake test remain supported.
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
export PYTHONDONTWRITEBYTECODE=1
exec python3 "$ROOT/scripts/check.py" "$@"
