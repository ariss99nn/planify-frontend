#!/usr/bin/env bash
set -euo pipefail

# run_frontend.sh
# Usage:
#   ./run_frontend.sh            -> runs web on chrome at port 3000 using .env or default
#   ./run_frontend.sh --release  -> passes args through to `flutter run`
#   ./run_frontend.sh -d <device>  -> run on specific device

# Load .env if present
if [ -f .env ]; then
  # export all variables from .env
  set -a
  # shellcheck disable=SC1091
  . .env
  set +a
fi

# Allow overriding via environment variable already present (e.g. CI)
API_BASE=${API_BASE_URL:-http://127.0.0.1:8000}

echo "[run_frontend] API_BASE_URL=${API_BASE}"

echo "Running flutter pub get..."
flutter pub get

ARGS=("--dart-define=API_BASE_URL=${API_BASE}")

if [ "$#" -gt 0 ]; then
  # forward user args to flutter run
  flutter run "${ARGS[@]}" "$@"
else
  # default: run web on chrome port 3000
  flutter run "${ARGS[@]}" -d chrome --web-port 3000
fi
