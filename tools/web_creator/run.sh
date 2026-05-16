#!/usr/bin/env bash
# Run the MimicXI web character creator locally.
# Usage: ./run.sh [port]
#
# Reads DB credentials from ../../settings/network.lua automatically.
# Override with: MIMIC_NETWORK_LUA=/path/to/network.lua ./run.sh

set -e
cd "$(dirname "$0")"

PORT="${1:-5000}"

if [ ! -d ".venv" ]; then
  echo "Creating virtual environment..."
  python3 -m venv .venv
  .venv/bin/pip install --quiet -r requirements.txt
fi

echo "Starting MimicXI Character Creator on http://127.0.0.1:${PORT}"
FLASK_APP=app.py FLASK_DEBUG=0 .venv/bin/python app.py
