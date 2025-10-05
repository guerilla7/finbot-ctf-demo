# FinBot CTF Demo Presentations

## Introduction
This PowerPoint-style presentation showcases the FinBot Capture The Flag demo - an educational platform for learning about AI security risks in agentic systems.

## Available Formats

1. **Markdown Source**: `finbot-demo-slides.md`
   - Raw markdown with presentation formatting
   - Edit this file to customize content
   - Compatible with Marp and other markdown slide tools

2. **HTML Presentation (Marp)**: `finbot-demo-slides.html`
   - Generated using Marp CLI
   - Full-featured presentation with animations
   - Requires modern browser

3. **HTML Presentation (Simplified)**: `finbot-demo-slides-simplified.html`
   - Self-contained HTML with minimal dependencies
   - Works in any browser
   - Includes navigation controls and keyboard shortcuts

## Usage Instructions

### View Presentations
- Open either HTML file in any modern web browser
- Navigate with arrow keys or on-screen controls
- Use F11 for fullscreen presentation mode

### Regenerate From Markdown
If you modify the markdown source, regenerate the presentation:

```bash
# Install Marp CLI (if not already installed)
npm install -g @marp-team/marp-cli

# Generate HTML presentation
marp finbot-demo-slides.md -o finbot-demo-slides.html
```

## Presentation Content

The presentation includes 8 slides covering:

1. Title and introduction
2. Overview of FinBot CTF
3. Key features
4. AI security challenges
5. Technical architecture
6. Live demo instructions
7. CTF challenge details
8. How to get involved

## License

The presentation content is licensed under Apache License 2.0, consistent with the FinBot CTF Demo project.