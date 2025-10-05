This folder holds the background music track for the site.

By default, the app tries to load `8bit-cyberpunk.mp3` from this folder. If the file is missing, the UI automatically falls back to a tiny, generated 8-bit style loop (embedded as a WAV data URI) so you have background music without shipping any external asset.

## Features

- **Auto-start after user gesture**: Music begins after clicking "Enter Demo" to comply with browser autoplay policies
- **Toggle control**: ON/OFF button in the site header (`[data-bgm-toggle]`)
- **Volume controls**: +/- buttons next to the toggle to adjust volume in 10% increments
- **Persistence**: Settings stored in localStorage, maintained across navigation
- **Self-contained fallback**: Uses a generated WAV data URI if the MP3 is missing

## Using Your Own Music

- Drop an MP3 file named `8bit-cyberpunk.mp3` into this folder
- Keep it small (< 2–3 MB is ideal) for faster loads
- Ensure you have the right to use and distribute the track in your project

## Technical Notes

- The player is implemented in `src/static/js/music.js`
- All pages include the script and toggle button
- If you prefer a different filename, update `audioEl.src` in the script
- Volume percentage display updates in real-time when adjusted
