#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# -----------------------------------------------------
# HuggingFace Token Setup
# -----------------------------------------------------
# The preferred models (Qwen) require a HuggingFace token
if [ -z "${HF_TOKEN:-}" ]; then
  echo "⚠️ HF_TOKEN not set. Preferred models (Qwen3, Qwen2.5) require authentication."
  echo "To access these models, get a token at https://huggingface.co/settings/tokens"
  echo "Then run: export HF_TOKEN='your_token_here'"
  echo "Continuing with TinyLlama fallback if needed..."
  read -p "Would you like to set HF_TOKEN now? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your HuggingFace token: " HF_TOKEN
    export HF_TOKEN
    echo "HF_TOKEN set for this session."
  fi
fi

# -----------------------------------------------------
# Virtual Environment and Dependencies
# -----------------------------------------------------
# Ensure venv
if [ ! -d .venv ]; then
  echo "Creating Python virtual environment..."
  python3 -m venv .venv
fi
source .venv/bin/activate

# Install deps (llama is optional; uncomment to install)
echo "Installing dependencies..."
pip install -U pip
pip install -r requirements.txt
# Optional local engine
# pip install 'llama-cpp-python>=0.2.90'

# -----------------------------------------------------
# Model Selection
# -----------------------------------------------------
# Download model if LOCAL_LLM_MODEL_PATH not set
if [ -z "${LOCAL_LLM_MODEL_PATH:-}" ]; then
  echo "LOCAL_LLM_MODEL_PATH not set; downloading a model (prefers Qwen 4B Instruct)..."
  bash scripts/download-local-model.sh
  # Prefer Qwen if present, else TinyLlama
  if [ -f "models/qwen3-4b-instruct-q4_k_m.gguf" ]; then
    export LOCAL_LLM_MODEL_PATH="$(pwd)/models/qwen3-4b-instruct-q4_k_m.gguf"
  elif [ -f "models/Qwen3-4B-Instruct-Q4_K_M.gguf" ]; then
    export LOCAL_LLM_MODEL_PATH="$(pwd)/models/Qwen3-4B-Instruct-Q4_K_M.gguf"
  elif [ -f "models/qwen2.5-4b-instruct-q4_k_m.gguf" ]; then
    export LOCAL_LLM_MODEL_PATH="$(pwd)/models/qwen2.5-4b-instruct-q4_k_m.gguf"
  elif [ -f "models/Qwen2.5-4B-Instruct-Q4_K_M.gguf" ]; then
    export LOCAL_LLM_MODEL_PATH="$(pwd)/models/Qwen2.5-4B-Instruct-Q4_K_M.gguf"
  elif [ -f "models/qwen3-4b-instruct-q4_k_m.gguf" ]; then
    export LOCAL_LLM_MODEL_PATH="$(pwd)/models/qwen3-4b-instruct-q4_k_m.gguf"
  else
    export LOCAL_LLM_MODEL_PATH="$(pwd)/models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
  fi
fi

# -----------------------------------------------------
# Start Flask App
# -----------------------------------------------------
export USE_LOCAL_LLM=true
export FLASK_APP=src/main.py
export PORT=${PORT:-5001}

echo "Starting Flask app on http://127.0.0.1:$PORT"
echo "Using model: $LOCAL_LLM_MODEL_PATH"
exec python -m flask run --port "$PORT" --no-reload
