This folder holds the background music track for the site.

By default, the app will try to load `8bit-cyberpunk.mp3` from this folder. If the file is missing, the UI will automatically fall back to a tiny, generated 8-bit style loop (embedded as a WAV data URI) so you still have background music without shipping any external asset.

How to use your own track:
- Drop an MP3 file named `8bit-cyberpunk.mp3` into this folder.
- Keep it small (< 2–3 MB is ideal) for faster loads.
- Ensure you have the right to use and distribute the track in your project.

Tip: If you prefer a different filename, update `src/static/js/music.js` (the `audioEl.src`) accordingly.
