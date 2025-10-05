#!/usr/bin/env bash
set -euo pipefail

# Simple helper to download a GGUF model for the local LLM demo.
# Defaults to TinyLlama 1.1B Chat v1.0 (Q4_K_M), which is small and runs on CPU.
# You can override URL or outfile via env vars.
#
# Usage:
#   ./scripts/download-local-model.sh
#   MODEL_URL=... OUTFILE=... ./scripts/download-local-model.sh
#   HF_TOKEN=your_token ./scripts/download-local-model.sh  # for gated models

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELS_DIR="$ROOT_DIR/models"
mkdir -p "$MODELS_DIR"

# Authentication check for gated models
if [ -z "${HF_TOKEN:-}" ]; then
  echo "⚠️ HF_TOKEN not set - Qwen models are gated and require authentication"
  echo "  To use Qwen models (recommended for better performance):"
  echo "  1. Create an account at https://huggingface.co"
  echo "  2. Get a token at https://huggingface.co/settings/tokens"
  echo "  3. Accept the model license at https://huggingface.co/Qwen/Qwen3-4B-Instruct-GGUF"
  echo "  4. Export your token: export HF_TOKEN='your_token_here'"
  echo ""
  echo "Continuing without token. Will try Qwen models but may fall back to TinyLlama..."
  echo ""
fi

# Prefer Qwen3-4B-Instruct GGUF (Q4_K_M) by default; fallback to Qwen2.5-4B-Instruct then TinyLlama if download fails.
: "${MODEL_URL:=https://huggingface.co/Qwen/Qwen3-4B-Instruct-GGUF/resolve/main/qwen3-4b-instruct-q4_k_m.gguf}"
: "${OUTFILE:=$MODELS_DIR/qwen3-4b-instruct-q4_k_m.gguf}"

if [ -f "$OUTFILE" ]; then
  echo "✅ Model already exists at $OUTFILE"
  exit 0
fi

echo "🔄 Downloading model to $OUTFILE ..."
# Prefer curl, fallback to wget
# Build optional header flag in a way compatible with `set -u`.
HF_HEADER_ARG=""
if [ -n "${HF_TOKEN:-}" ]; then
  echo "🔑 Using HuggingFace token for authentication"
  HF_HEADER_ARG="-H \"Authorization: Bearer $HF_TOKEN\""
fi

if command -v curl >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  if ! eval curl -fL $HF_HEADER_ARG "$MODEL_URL" -o "$OUTFILE"; then
    echo "❌ Primary model failed (Qwen3-4B-Instruct)"
    if [ -z "${HF_TOKEN:-}" ]; then
      echo "   This is likely because you need a HuggingFace token for this gated model."
      echo "   Please set HF_TOKEN as described above and try again."
    fi
    
    echo "🔄 Trying Qwen2.5-4B-Instruct as fallback..."
    # shellcheck disable=SC2086
    if eval curl -fL $HF_HEADER_ARG "https://huggingface.co/Qwen/Qwen2.5-4B-Instruct-GGUF/resolve/main/qwen2.5-4b-instruct-q4_k_m.gguf" -o "$MODELS_DIR/qwen2.5-4b-instruct-q4_k_m.gguf"; then
      OUTFILE="$MODELS_DIR/qwen2.5-4b-instruct-q4_k_m.gguf"
      echo "✅ Downloaded Qwen2.5-4B-Instruct successfully"
    else
      echo "❌ Secondary model failed (Qwen2.5-4B-Instruct)"
      
      echo "🔄 Falling back to TinyLlama (non-gated model)..."
      if curl -L "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf" -o "$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"; then
        OUTFILE="$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
        echo "✅ Downloaded TinyLlama successfully"
      else
        echo "❌ All model downloads failed. Please check your internet connection."
        exit 1
      fi
    fi
  else
    echo "✅ Downloaded Qwen3-4B-Instruct successfully"
  fi
elif command -v wget >/dev/null 2>&1; then
  # wget cannot easily add headers as array; handle token inline if present
  WGET_AUTH=""
  if [ -n "${HF_TOKEN:-}" ]; then
    WGET_AUTH="--header=Authorization: Bearer $HF_TOKEN"
  fi
  if ! wget $WGET_AUTH -O "$OUTFILE" "$MODEL_URL"; then
    echo "❌ Primary model failed (Qwen3-4B-Instruct)"
    if [ -z "${HF_TOKEN:-}" ]; then
      echo "   This is likely because you need a HuggingFace token for this gated model."
      echo "   Please set HF_TOKEN as described above and try again."
    fi
    
    echo "🔄 Trying Qwen2.5-4B-Instruct as fallback..."
    if wget $WGET_AUTH -O "$MODELS_DIR/qwen2.5-4b-instruct-q4_k_m.gguf" "https://huggingface.co/Qwen/Qwen2.5-4B-Instruct-GGUF/resolve/main/qwen2.5-4b-instruct-q4_k_m.gguf"; then
      OUTFILE="$MODELS_DIR/qwen2.5-4b-instruct-q4_k_m.gguf"
      echo "✅ Downloaded Qwen2.5-4B-Instruct successfully"
    else
      echo "❌ Secondary model failed (Qwen2.5-4B-Instruct)"
      
      echo "🔄 Falling back to TinyLlama (non-gated model)..."
      if wget -O "$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf" "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"; then
        OUTFILE="$MODELS_DIR/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
        echo "✅ Downloaded TinyLlama successfully"
      else
        echo "❌ All model downloads failed. Please check your internet connection."
        exit 1
      fi
    fi
  else
    echo "✅ Downloaded Qwen3-4B-Instruct successfully"
  fi
else
  echo "❌ Error: curl or wget required to download models." >&2
  exit 1
fi

echo "🎉 Done! Model downloaded to $OUTFILE"
echo "   Set LOCAL_LLM_MODEL_PATH=$OUTFILE to use this model"
