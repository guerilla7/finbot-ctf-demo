# Local LLM Models

This folder is where local LLM model files (GGUF format) are stored when downloaded.

## Handling Large Model Files

**IMPORTANT:** Model files are excluded from Git via `.gitignore` due to their size.

GitHub has a 100 MB file size limit, and most GGUF files exceed this. Instead of using Git LFS or similar approaches, we recommend:

1. Download models at runtime using the provided scripts
2. Keep models in this folder (they're automatically gitignored)
3. Use the download fallback chain for automatic selection

## Preferred Models

The system attempts to use models in this preference order:

1. **Qwen3-4B-Instruct** (primary choice)
   - Higher quality responses
   - Requires HuggingFace token (gated model)

2. **Qwen2.5-4B-Instruct** (first fallback)
   - Similar quality but older
   - Also requires HuggingFace token

3. **TinyLlama-1.1B-Chat** (free fallback)
   - Smaller and freely available
   - Limited capability but works for basic responses

## Download Methods

### Automatic (recommended)
```bash
# Set HF_TOKEN if needed for gated models
export HF_TOKEN=your_huggingface_token
./scripts/download-local-model.sh
```

### Manual
You can also download GGUF files manually from HuggingFace and place them in this directory:
- https://huggingface.co/Qwen/Qwen3-4B-Instruct-GGUF (gated)
- https://huggingface.co/Qwen/Qwen2-5-4B-Instruct-GGUF (gated) 
- https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF (free)