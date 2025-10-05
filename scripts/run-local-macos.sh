#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Ensure venv
if [ ! -d .venv ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate

# Install deps (llama is optional; uncomment to install)
pip install -U pip
pip install -r requirements.txt
# Optional local engine
# pip install 'llama-cpp-python>=0.2.90'

# Download model if LOCAL_LLM_MODEL_PATH not set
if [ -z "${LOCAL_LLM_MODEL_PATH:-}" ]; then
  echo "LOCAL_LLM_MODEL_PATH not set; downloading a small model..."
  bash scripts/download-local-model.sh
  export LOCAL_LLM_MODEL_PATH="$(pwd)/models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
fi

export USE_LOCAL_LLM=true
export FLASK_APP=src/main.py
export PORT=${PORT:-5001}

# Start Flask
exec python -m flask run --port "$PORT" --no-reload
