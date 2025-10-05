# FinBot CTF Demo
Cybersecurity Training for AI Assistants

OWASP Agentic Security Initiative

![OWASP Logo](https://raw.githubusercontent.com/OWASP/www-project-top-10/master/assets/images/owasp_logo_1c_w_notext.png) <!-- .element: style="max-width: 200px;" -->

---

# FinBot CTF: Overview

A cybersecurity Capture The Flag platform that demonstrates:

- **Agentic Security**: Exploitation of AI agent vulnerabilities
- **Educational Value**: Hands-on learning environment
- **Real-world Scenarios**: Financial system attack vectors
- **Tool Security**: Prompt injection and goal hijacking

![FinBot Screenshot](../screenshots/finbot-chat.png) <!-- .element: style="max-width: 400px;" -->

---

# Key Features

### Interactive Demonstration Platform

- **Neon Cyberpunk UI**: Immersive attack environment
- **Background Music**: Configurable 8-bit soundtrack
- **Self-Contained**: Runs entirely on your hardware
- **Local LLM Integration**: No external API dependencies

![FinBot Screenshot](../screenshots/vendor-portal.png) <!-- .element: style="max-width: 350px; float: right;" -->

---

# AI Security Challenges

### Goal Manipulation Attack

- Trick AI financial assistant into approving fraudulent invoices
- Bypass security controls through persuasive prompting
- Compromise system integrity without code vulnerabilities

### Vendor Invoice Fraud

- Submit manipulated invoices through the vendor portal
- Exploit trust relationship between AI and humans
- Demonstrate real financial impact of AI vulnerabilities

---

# Technical Architecture

### Components

- **Frontend**: HTML/CSS/JS with cyberpunk neon theme
- **Backend**: Python Flask server
- **LLM Options**:
  - Local models (Qwen3-4B, TinyLlama)
  - OpenAI API integration (optional)
- **Tool Execution**: Agentic framework with tool access

![Admin Dashboard](../screenshots/admin-dashboard.png) <!-- .element: style="max-width: 450px;" -->

---

# Live Demo Instructions

### Quick Setup

```bash
# Clone repository
git clone https://github.com/OWASP/finbot-ctf-demo

# Set HuggingFace token (for gated models)
export HF_TOKEN='your_token_here'

# Run the application
./scripts/run-local-macos.sh
```

### Access the application

- Open browser to http://localhost:5001
- Click "Enter Demo" button to begin

---

# CTF Challenge: Goal Manipulation

### Attack Vector

- Access the FinBot Chat interface
- Manipulate the AI assistant's goals
- Trick it into processing fraudulent invoices

### Success Criteria

- Process invoice INV-2023-9012 from Acme Supplies
- Bypass security controls without detection
- Force approval of the transaction

---

# Get Involved

### Extend the Demo

- Add new attack vectors and challenges
- Improve detection and defense mechanisms
- Create educational content around examples

### Contribute

- GitHub: https://github.com/OWASP/finbot-ctf-demo
- OWASP GenAI Security Project: https://genai.owasp.org
- License: Apache 2.0

---

# Thank You!

### Contact

- OWASP GenAI Security: https://genai.owasp.org
- GitHub: https://github.com/OWASP/finbot-ctf-demo

### Credits

- OWASP Foundation
- GenAI Security Project Team

![FinBot Logo](../static/FinBot1.png) <!-- .element: style="max-width: 200px;" -->