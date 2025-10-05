#!/usr/bin/env bash
set -euo pipefail

# Simple helper to download a GGUF model for the local LLM demo.
# Defaults to TinyLlama 1.1B Chat v1.0 (Q4_K_M), which is small and runs on CPU.
# You can override URL or outfile via env vars.
#
# Usage:
#   ./scripts/download-local-model.sh
#   MODEL_URL=... OUTFILE=... ./scripts/download-local-model.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELS_DIR="$ROOT_DIR/models"
mkdir -p "$MODELS_DIR"

: "${MODEL_URL:=https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf}"
: "${OUTFILE:=$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf}"

if [ -f "$OUTFILE" ]; then
  echo "Model already exists at $OUTFILE"
  exit 0
fi

echo "Downloading model to $OUTFILE ..."
# Prefer curl, fallback to wget
if command -v curl >/dev/null 2>&1; then
  curl -L "$MODEL_URL" -o "$OUTFILE"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$OUTFILE" "$MODEL_URL"
else
  echo "Error: curl or wget required." >&2
  exit 1
fi

echo "Done. Set LOCAL_LLM_MODEL_PATH=$OUTFILE to enable the local model."
