// Background 8-bit cyberpunk music controller
// Autoplay policies: start only after a clear user gesture (e.g., clicking Enter Demo)
(function(){
  const MUSIC_KEY = 'bgm_enabled';
  const VOLUME_KEY = 'bgm_volume';
  const PENDING_KEY = 'bgm_pending';
  let audioEl;

  // Generate a small loopable 8-bit style chiptune as a WAV data URI (mono 16-bit PCM)
  // This is a lightweight, license-free fallback used only if the MP3 is missing.
  function generateChiptuneWavDataURI(){
    const sr = 22050;         // sample rate
    const seconds = 6;        // loop length
    const n = sr * seconds;
    const mix = new Float32Array(n);
    const TAU = Math.PI * 2;

    // Simple square wave with basic ADSR envelope
    function addSquare(startSec, durSec, freq, vol){
      const attack = Math.min(0.01, durSec * 0.2);
      const decay = Math.min(0.08, durSec * 0.3);
      const sustain = 0.7;
      const release = Math.min(0.04, durSec * 0.2);

      const start = Math.floor(startSec * sr);
      const end = Math.min(n, Math.floor((startSec + durSec) * sr));
      for (let i = start; i < end; i++){
        const t = i / sr - startSec;
        let env;
        if (t < attack) env = t / attack;
        else if (t < attack + decay) env = 1 - (1 - sustain) * ((t - attack) / decay);
        else if (t < durSec - release) env = sustain;
        else env = Math.max(0, sustain * (1 - (t - (durSec - release)) / release));
        const s = Math.sign(Math.sin(TAU * freq * (i / sr))) * vol * env;
        mix[i] += s;
      }
    }

    // Simple noise burst for snare/hihat
    function addNoise(startSec, durSec, vol){
      const start = Math.floor(startSec * sr);
      const end = Math.min(n, Math.floor((startSec + durSec) * sr));
      for (let i = start; i < end; i++){
        // Exponential decay
        const t = (i - start) / sr;
        const env = Math.exp(-18 * t);
        const s = (Math.random() * 2 - 1) * vol * env;
        mix[i] += s;
      }
    }

    // Tiny cyber-ish groove: 110 BPM, Am → F → G → Em
    const bpm = 110;
    const beat = 60 / bpm;
    const measures = seconds / (beat * 4);
    const chords = [
      // bass root frequencies (approx)
      [110, 220, 440], // A minor
      [87.31, 174.61, 349.23], // F
      [98, 196, 392], // G
      [82.41, 164.81, 329.63] // E minor
    ];

    for (let m = 0; m < measures; m++){
      const chord = chords[m % chords.length];
      const baseT = m * 4 * beat;
      // Kick (low thump via very low square) + snare on beats 2 and 4
      addSquare(baseT + 0.00, 0.08, 55, 0.22);
      addNoise(baseT + beat * 1, 0.03, 0.25);
      addNoise(baseT + beat * 3, 0.03, 0.25);

      // Bass on every beat
      for (let b = 0; b < 4; b++){
        const t = baseT + b * beat;
        addSquare(t, beat * 0.46, chord[0], 0.24);
      }

      // Arp lead in eighths cycling chord tones
      const arp = [chord[0]*2, chord[1]*2, chord[2]*2, chord[1]*2];
      for (let e = 0; e < 8; e++){
        const t = baseT + e * (beat/2);
        const f = arp[e % arp.length];
        addSquare(t, beat*0.45, f, 0.12);
      }
    }

    // Soft limiter to avoid clipping
    let max = 0;
    for (let i = 0; i < n; i++) max = Math.max(max, Math.abs(mix[i]));
    const gain = 0.85 / (max || 1);

    // Convert to 16-bit PCM WAV
    const bytesPerSample = 2, channels = 1;
    const dataSize = n * bytesPerSample;
    const headerSize = 44;
    const buffer = new ArrayBuffer(headerSize + dataSize);
    const view = new DataView(buffer);

    function writeStr(offset, str){
      for (let i = 0; i < str.length; i++) view.setUint8(offset+i, str.charCodeAt(i));
    }
    function write16(offset, val){ view.setUint16(offset, val, true); }
    function write32(offset, val){ view.setUint32(offset, val, true); }

    // RIFF header
    writeStr(0, 'RIFF');
    write32(4, 36 + dataSize);
    writeStr(8, 'WAVE');
    // fmt chunk
    writeStr(12, 'fmt ');
    write32(16, 16);           // PCM chunk size
    write16(20, 1);            // audio format = PCM
    write16(22, channels);
    write32(24, sr);
    write32(28, sr * channels * bytesPerSample);
    write16(32, channels * bytesPerSample);
    write16(34, 16);           // bits per sample
    // data chunk
    writeStr(36, 'data');
    write32(40, dataSize);

    // PCM samples
    let off = 44;
    for (let i = 0; i < n; i++){
      const s = Math.max(-1, Math.min(1, mix[i] * gain));
      view.setInt16(off, (s * 0x7FFF) | 0, true);
      off += 2;
    }

    // Base64 encode
    const u8 = new Uint8Array(buffer);
    const chunkSize = 0x8000;
    let b64 = '';
    for (let i = 0; i < u8.length; i += chunkSize){
      const slice = u8.subarray(i, i + chunkSize);
      b64 += String.fromCharCode.apply(null, slice);
    }
    return 'data:audio/wav;base64,' + btoa(b64);
  }

  function ensureAudio(){
    if (!audioEl) {
      audioEl = document.createElement('audio');
      audioEl.src = 'music/8bit-cyberpunk.mp3';
      audioEl.loop = true;
      audioEl.preload = 'auto';
      audioEl.volume = parseFloat(localStorage.getItem(VOLUME_KEY) || '0.35');
      audioEl.dataset.finbotBgm = 'true';
      document.body.appendChild(audioEl);
      // If the MP3 is missing/unavailable, fall back to the generated WAV loop
      audioEl.addEventListener('error', () => {
        if (audioEl.dataset.fallbackApplied === '1') return;
        try {
          audioEl.dataset.fallbackApplied = '1';
          audioEl.src = generateChiptuneWavDataURI();
          audioEl.load();
        } catch (err) {
          console.warn('Could not generate fallback chiptune:', err);
        }
      }, { once: true });
    }
    return audioEl;
  }

  function isEnabled(){ return localStorage.getItem(MUSIC_KEY) !== 'off'; }
  function setEnabled(val){ localStorage.setItem(MUSIC_KEY, val ? 'on' : 'off'); }

  async function play(){
    try {
      const a = ensureAudio();
      if (a.paused) { await a.play(); }
    } catch (e) {
      console.warn('BGM play blocked:', e);
    }
  }
  function pause(){ const a = ensureAudio(); if (!a.paused) a.pause(); }

  // Public API attached to window
  window.finbotMusic = {
    startAfterGesture: async function(){
      if (!isEnabled()) return;
      await play();
    },
    toggle: function(){
      if (isEnabled()) {
        setEnabled(false); pause();
      } else {
        setEnabled(true); play();
      }
      updateToggleUI();
    },
    setVolume: function(v){
      const vol = Math.max(0, Math.min(1, Number(v)||0));
      localStorage.setItem(VOLUME_KEY, String(vol));
      ensureAudio().volume = vol;
      updateVolumeUI();
    },
    enabled: isEnabled
  };

  function updateToggleUI(){
    const btn = document.querySelector('[data-bgm-toggle]');
    if (!btn) return;
    const on = isEnabled();
    btn.textContent = on ? '🔊 Music: ON' : '🔇 Music: OFF';
  }

  function updateVolumeUI(){
    const display = document.querySelector('[data-bgm-volume]');
    if (!display) return;
    const vol = ensureAudio().volume;
    display.textContent = Math.round(vol * 100) + '%';
  }

  // Initialize toggle state on DOMContentLoaded
  document.addEventListener('DOMContentLoaded', () => {
    // default to ON unless user turned OFF previously
    if (localStorage.getItem(MUSIC_KEY) == null) setEnabled(true);
    ensureAudio();
    updateToggleUI();
    updateVolumeUI();

    // Inject a compact volume rocker next to the toggle if not present
    const toggleBtn = document.querySelector('[data-bgm-toggle]');
    if (toggleBtn && !document.querySelector('[data-bgm-rocker]')){
      const wrap = document.createElement('span');
      wrap.setAttribute('data-bgm-rocker', '');
      wrap.style.marginLeft = '8px';

      const down = document.createElement('button');
      down.className = toggleBtn.className + ' btn-compact';
      down.type = 'button';
      down.textContent = '➖';
      down.title = 'Volume down';
      down.addEventListener('click', () => {
        const current = ensureAudio().volume;
        window.finbotMusic.setVolume(Math.max(0, current - 0.1));
      });

      const display = document.createElement('span');
      display.setAttribute('data-bgm-volume', '');
      display.style.margin = '0 6px';
      display.style.minWidth = '32px';
      display.style.display = 'inline-block';
      display.style.textAlign = 'center';

      const up = document.createElement('button');
      up.className = toggleBtn.className + ' btn-compact';
      up.type = 'button';
      up.textContent = '➕';
      up.title = 'Volume up';
      up.addEventListener('click', () => {
        const current = ensureAudio().volume;
        window.finbotMusic.setVolume(Math.min(1, current + 0.1));
      });

      wrap.appendChild(down);
      wrap.appendChild(display);
      wrap.appendChild(up);
      toggleBtn.insertAdjacentElement('afterend', wrap);
      updateVolumeUI();
    }

    // If a pending start was requested (e.g., user clicked Enter Demo before navigation),
    // try to start immediately and also attach a 1-time pointer handler as fallback.
    if (localStorage.getItem(PENDING_KEY) === 'true') {
      localStorage.removeItem(PENDING_KEY);
      // Best-effort immediate play
      if (isEnabled()) { play(); }
      // First user interaction fallback
      const onFirst = async () => {
        if (isEnabled()) await play();
        window.removeEventListener('pointerdown', onFirst);
      };
      window.addEventListener('pointerdown', onFirst, { once: true });
    }
  });
})();
