# OWASP Agentic AI CTF - FinBot DEMO

Welcome to the **OWASP Agentic AI CTF Demo – FinBot AI Assistant**, an interactive Capture-the-Flag experience designed to explore vulnerabilities in agentic AI systems. This environment is intended for educational use only.

## Live Instance

👉 **Launch the Live FinBot CTF: [owasp-finbot-ctf.org](http://owasp-finbot-ctf.org/)**

Redirected to: https://owasp-finbot-ctf-demo.onrender.com
<br></br>
## FinBot Chat UI (New)

- Open `finbot-chat.html` from the app (Home > FinBot Chat, Vendor Portal > FinBot Chat, or Admin Dashboard > FinBot Chat)
- Type prompts like:
	- "Find invoice INV-1001 and process it"
	- "Show the decision, confidence, and reasoning for INV-1001"
- Optional security:
	- Set `CHAT_API_TOKEN` to require `Authorization: Bearer <token>` on `/api/finbot/chat`
	- Toggle "Allow actions" in the UI to prevent the assistant from calling state-changing tools
- OpenAI configuration:
	- Set `OPENAI_API_KEY` in the environment to enable live LLM calls; otherwise, chat replies fall back gracefully


## Local LLM Mode (Self-Contained)

You can run FinBot without any external API by enabling the local LLM path. By default, it provides concise deterministic replies suitable for the demo. Optionally, you can use a real on-device model via llama.cpp (GGUF).

Options:
- `USE_LOCAL_LLM=true` (forces local path and disables OpenAI)
- `LOCAL_LLM_MODEL_PATH=/abs/path/to/model.gguf` (optional; requires `llama-cpp-python`)

macOS one-click script:

```
./scripts/run-local-macos.sh
```

This will:
- create/activate .venv
- install requirements (llama-cpp is optional; uncomment inside the script to install)
- download a small GGUF model if `LOCAL_LLM_MODEL_PATH` isn’t set
- export `USE_LOCAL_LLM=true` and start Flask on port 5001

Manual enablement:

```
export USE_LOCAL_LLM=true
# optional:
# pip install 'llama-cpp-python>=0.2.90'
# ./scripts/download-local-model.sh
# export LOCAL_LLM_MODEL_PATH="$PWD/models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
flask --app src/main.py run --port 5001 --no-reload
```

Note: When `LOCAL_LLM_MODEL_PATH` is not set or the engine isn't available, FinBot returns short, deterministic replies but still performs all invoice operations via built-in tools.



## CTF Challenges
🎯 **[Goal Manipulation](docs/FinBot-CTF-walkthrough-goal-manipulation.md)**
<br></br>

## Participation Policy

Please use this environment ethically and responsibly:
- Educational use only – system is monitored and logged
- Do not attempt to misuse or damage the environment
- Respect system data, rules, and other participants
- Violation of policies may result in access restriction

By using the system, you acknowledge and agree to these terms.
<br></br>

## About the Project

This CTF showcases:
- Realistic AI goal manipulation risks
- AI-powered invoice processing simulation
- Prompt injection detection techniques
- Ethical experimentation in a controlled sandbox

Built as part of the OWASP GenAI Security Project’s [Agentic Security Initiative](https://genai.owasp.org/initiatives/#agenticinitiative).

**Creators:** [**Helen Oakley**](https://www.linkedin.com/in/helen-oakley/) and [**Allie Howe**](https://www.linkedin.com/in/allisonhowe/)
<br></br>


## How To Contribute

- Check out the collaboration hub for OWASP FinBot CTF workstream https://github.com/OWASP-ASI/FinBot-CTF-workstream 
<br></br>

## License

Licensed under the Apache License, Version 2.0 (the "License").

https://www.apache.org/licenses/LICENSE-2.0.html

Copyright 2025 OWASP GenAI Security Project and contributors.

