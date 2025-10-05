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

# Prefer Qwen3-4B-Instruct GGUF (Q4_K_M) by default; fallback to Qwen2.5-4B-Instruct then TinyLlama if download fails.
: "${MODEL_URL:=https://huggingface.co/Qwen/Qwen3-4B-Instruct-GGUF/resolve/main/qwen3-4b-instruct-q4_k_m.gguf}"
: "${OUTFILE:=$MODELS_DIR/qwen3-4b-instruct-q4_k_m.gguf}"

if [ -f "$OUTFILE" ]; then
  echo "Model already exists at $OUTFILE"
  exit 0
fi

echo "Downloading model to $OUTFILE ..."
# Prefer curl, fallback to wget
# Build optional header flag in a way compatible with `set -u`.
HF_HEADER_ARG=""
if [ -n "${HF_TOKEN:-}" ]; then
  HF_HEADER_ARG="-H \"Authorization: Bearer $HF_TOKEN\""
fi

if command -v curl >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  if ! eval curl -fL $HF_HEADER_ARG "$MODEL_URL" -o "$OUTFILE"; then
    echo "Primary model failed, trying Qwen2.5-4B-Instruct..."
    # shellcheck disable=SC2086
    if eval curl -fL $HF_HEADER_ARG "https://huggingface.co/Qwen/Qwen2.5-4B-Instruct-GGUF/resolve/main/qwen2.5-4b-instruct-q4_k_m.gguf" -o "$MODELS_DIR/qwen2.5-4b-instruct-q4_k_m.gguf"; then
      OUTFILE="$MODELS_DIR/qwen2.5-4b-instruct-q4_k_m.gguf"
    else
      echo "Secondary model failed, falling back to TinyLlama..."
      curl -L "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf" -o "$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
      OUTFILE="$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
    fi
  fi
elif command -v wget >/dev/null 2>&1; then
  # wget cannot easily add headers as array; handle token inline if present
  WGET_AUTH=""
  if [ -n "${HF_TOKEN:-}" ]; then
    WGET_AUTH="--header=Authorization: Bearer $HF_TOKEN"
  fi
  if ! wget $WGET_AUTH -O "$OUTFILE" "$MODEL_URL"; then
    echo "Primary model failed, trying Qwen2.5-4B-Instruct..."
    if wget $WGET_AUTH -O "$MODELS_DIR/qwen2.5-4b-instruct-q4_k_m.gguf" "https://huggingface.co/Qwen/Qwen2.5-4B-Instruct-GGUF/resolve/main/qwen2.5-4b-instruct-q4_k_m.gguf"; then
      OUTFILE="$MODELS_DIR/qwen2.5-4b-instruct-q4_k_m.gguf"
    else
      echo "Secondary model failed, falling back to TinyLlama..."
      wget -O "$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf" "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
      OUTFILE="$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
    fi
  fi
else
  echo "Error: curl or wget required." >&2
  exit 1
fi

echo "Done. Set LOCAL_LLM_MODEL_PATH=$OUTFILE to enable the local model."
