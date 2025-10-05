"""
Local LLM wrapper for self-contained demos.

Usage:
- Set LOCAL_LLM_MODEL_PATH to a GGUF model file (e.g., a small llama/phi variant)
- Optionally set LOCAL_LLM_CTX_SIZE, LOCAL_LLM_THREADS

If llama-cpp-python is unavailable or the model cannot be loaded, this
module falls back to a simple stub that returns concise, deterministic
responses suitable for the CTF demo without external APIs.
"""
from __future__ import annotations

import os
from typing import List, Dict, Optional


class LocalLLM:
    def __init__(self,
                 model_path: Optional[str] = None,
                 ctx_size: int = 4096,
                 n_threads: Optional[int] = None):
        self.model_path = model_path or os.getenv("LOCAL_LLM_MODEL_PATH")
        self.ctx_size = int(os.getenv("LOCAL_LLM_CTX_SIZE", str(ctx_size)))
        self.n_threads = int(os.getenv("LOCAL_LLM_THREADS", str(n_threads or os.cpu_count() or 4)))
        self._engine = None
        self._backend = None
        # If no explicit path, try common defaults (prefer Qwen3-4B-Instruct if present)
        if not self.model_path:
            candidates = [
                os.path.join(os.getcwd(), "models", "qwen3-4b-instruct-q4_k_m.gguf"),
                os.path.join(os.getcwd(), "models", "Qwen3-4B-Instruct-Q4_K_M.gguf"),
                os.path.join(os.getcwd(), "models", "qwen2.5-4b-instruct-q4_k_m.gguf"),
                os.path.join(os.getcwd(), "models", "tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"),
            ]
            for c in candidates:
                if os.path.exists(c):
                    self.model_path = c
                    break
        self._init_engine()

    @property
    def available(self) -> bool:
        return self._engine is not None

    def _init_engine(self):
        # Try llama-cpp-python first
        if not self.model_path or not os.path.exists(self.model_path):
            return
        try:
            from llama_cpp import Llama  # type: ignore
            self._engine = Llama(
                model_path=self.model_path,
                n_ctx=self.ctx_size,
                n_threads=self.n_threads,
            )
            self._backend = "llama-cpp"
        except Exception as e:
            # Could not initialize a real local LLM; will use stub
            print(f"Warning: Local LLM init failed: {e}")
            self._engine = None
            self._backend = None

    def chat(self, messages: List[Dict[str, str]], max_tokens: int = 256, temperature: float = 0.3) -> str:
        """Return a reply string to the given chat messages.

        If a real local engine is available, use it; otherwise return a succinct
        deterministic response tailored for the demo.
        """
        if self._backend == "llama-cpp" and self._engine is not None:
            try:
                # Prefer llama-cpp's chat completion when available (uses model chat template)
                if hasattr(self._engine, "create_chat_completion"):
                    out = self._engine.create_chat_completion(
                        messages=messages,
                        temperature=temperature,
                        max_tokens=max_tokens,
                        stop=["</s>"]
                    )
                    text = out.get("choices", [{}])[0].get("message", {}).get("content", "").strip()
                    if text:
                        return text
                # Fallback: construct a simple prompt
                prompt = []
                system = ""
                for m in messages:
                    role = m.get("role", "user")
                    content = (m.get("content") or "").strip()
                    if role == "system":
                        system += content + "\n"
                    elif role == "user":
                        prompt.append(f"User: {content}")
                    elif role == "assistant":
                        prompt.append(f"Assistant: {content}")
                final_prompt = (("System: " + system + "\n") if system else "") + "\n".join(prompt) + "\nAssistant:"
                out = self._engine(
                    final_prompt,
                    max_tokens=max_tokens,
                    temperature=temperature,
                    top_p=0.9,
                    stop=["\nUser:", "\nSystem:"]
                )
                text = out.get("choices", [{}])[0].get("text", "").strip()
                return text or ""
            except Exception as e:
                print(f"Warning: Local LLM generation failed: {e}")
                # fall through to stub

        # Stub fallback: generate a compact, friendly reply
        last_user = next((m.get("content") for m in reversed(messages) if m.get("role") == "user"), "")
        last_user = (last_user or "").strip()
        if not last_user:
            return "I'm ready. Ask me about invoices or FinBot's config."
        # Provide short, relevant responses for typical CTF prompts
        low = last_user.lower()
        if "list vendors" in low:
            return "Listing vendors… I'll include id, name, and trust level."
        if "list invoices" in low:
            return "Listing invoices… I'll include id, number, amount, status."
        if "get config" in low or "current config" in low:
            return "Here are FinBot's current configuration and goals."
        if "process invoice" in low:
            return "Processing the requested invoice according to goals and thresholds."
        if "reprocess" in low and "invoice" in low:
            return "Reprocessing the invoice after resetting its state."
        if "set vendor trust" in low:
            return "Updating the vendor trust level as requested."
        if "show details" in low or "invoice" in low:
            return "Retrieving invoice details and current decision state."
        return "Understood. I'll help with invoices, vendors, or FinBot config."
