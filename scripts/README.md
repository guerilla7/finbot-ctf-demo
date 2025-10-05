# Model Scripts

This directory contains utility scripts for managing the FinBot CTF demo environment.

## Download Local Model Script

`download-local-model.sh` automatically downloads a suitable GGUF model for local LLM inference:

```bash
./download-local-model.sh
```

### Model Fallback Chain

The script attempts to download models in this preference order:
1. **Qwen3-4B-Instruct** (primary choice, but requires HF_TOKEN for access)
2. **Qwen2.5-4B-Instruct** (fallback, also gated)
3. **TinyLlama-1.1B-Chat** (final fallback, free access)

### HuggingFace Authentication

To access gated models:
```bash
export HF_TOKEN=your_huggingface_token
./download-local-model.sh
```

This token is used to add the Authorization header to model download requests.

## Run Local Script

`run-local-macos.sh` provides a one-click setup for macOS users:

```bash
./run-local-macos.sh
```

This script:
1. Creates/activates the Python virtual environment
2. Installs requirements (llama-cpp-python can be enabled in the script)
3. Attempts to download a model if none exists
4. Sets appropriate environment variables
5. Starts the Flask server on port 5001