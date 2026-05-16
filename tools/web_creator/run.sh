#!/usr/bin/env bash
# MimicXI Web Character Creator — Linux / macOS launcher
# Usage: ./run.sh [port]
#
# Reads DB credentials from ../../settings/network.lua automatically.
# Override: MIMIC_NETWORK_LUA=/path/to/network.lua ./run.sh

PORT="${1:-5000}"
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

error_exit() {
    echo ""
    echo "ERROR: $1"
    exit 1
}

# Prefer python3, fall back to python
PYTHON=$(command -v python3 2>/dev/null || command -v python 2>/dev/null)
[ -z "$PYTHON" ] && error_exit "Python not found. Install Python 3.10+."

# Create venv if missing
if [ ! -f ".venv/bin/python" ]; then
    echo "Creating virtual environment..."
    "$PYTHON" -m venv .venv || error_exit "Failed to create virtual environment."
    echo "Installing dependencies..."
    .venv/bin/pip install --quiet -r requirements.txt || error_exit "pip install failed."
fi

# Quick dependency sanity check
if ! .venv/bin/python -c "import flask, mariadb, bcrypt" 2>/dev/null; then
    echo "Dependencies missing — reinstalling..."
    .venv/bin/pip install --quiet -r requirements.txt || error_exit "pip install failed."
fi

echo "Starting MimicXI Character Creator at http://127.0.0.1:${PORT}"
echo "Press Ctrl+C to stop."
echo ""

.venv/bin/python app.py "$PORT"
