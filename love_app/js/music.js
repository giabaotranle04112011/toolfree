/**
 * LOVE COUPLE APP - ROMANTIC AUDIO & SOUND FX SYNTHESIZER
 * Uses Web Audio API for 100% offline, zero-dependency sweet music and sound effects.
 */

class LoveAudioEngine {
  constructor() {
    this.ctx = null;
    this.isPlayingBgm = false;
    this.bgmGain = null;
    this.sfxGain = null;
    this.bgmInterval = null;
    this.chordStep = 0;
    
    // Romantic chords (Cmaj9, Am9, Fmaj7, Gsus4/G)
    this.chords = [
      [261.63, 329.63, 392.00, 493.88, 587.33], // Cmaj9 (C4, E4, G4, B4, D5)
      [220.00, 261.63, 329.63, 392.00, 493.88], // Am9 (A3, C4, E4, G4, B4)
      [174.61, 220.00, 261.63, 329.63, 392.00], // Fmaj7 (F3, A3, C4, E4, G4)
      [196.00, 246.94, 293.66, 392.00, 493.88]  // G7/Gsus (G3, B3, D4, G4, B4)
    ];
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioCtx();
      
      this.bgmGain = this.ctx.createGain();
      this.bgmGain.gain.value = 0.25;
      this.bgmGain.connect(this.ctx.destination);
      
      this.sfxGain = this.ctx.createGain();
      this.sfxGain.gain.value = 0.4;
      this.sfxGain.connect(this.ctx.destination);
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  toggleBgm() {
    this.init();
    if (this.isPlayingBgm) {
      this.stopBgm();
      return false;
    } else {
      this.startBgm();
      return true;
    }
  }

  startBgm() {
    this.init();
    if (this.isPlayingBgm) return;
    this.isPlayingBgm = true;
    this.chordStep = 0;
    
    this.playChordStep();
    this.bgmInterval = setInterval(() => {
      this.playChordStep();
    }, 4200); // smooth 4.2s per chord measure
  }

  stopBgm() {
    this.isPlayingBgm = false;
    if (this.bgmInterval) {
      clearInterval(this.bgmInterval);
      this.bgmInterval = null;
    }
  }

  playChordStep() {
    if (!this.isPlayingBgm || !this.ctx) return;
    const now = this.ctx.currentTime;
    const chord = this.chords[this.chordStep % this.chords.length];
    this.chordStep++;

    // Play soft arpeggiated piano/synth notes
    chord.forEach((freq, index) => {
      const osc = this.ctx.createOscillator();
      const noteGain = this.ctx.createGain();
      
      // Warm sine/triangle mixture
      osc.type = index % 2 === 0 ? 'sine' : 'triangle';
      osc.frequency.setValueAtTime(freq, now + index * 0.22);
      
      // Gentle attack and long romantic decay
      const noteStart = now + index * 0.22;
      noteGain.gain.setValueAtTime(0.001, noteStart);
      noteGain.gain.exponentialRampToValueAtTime(0.08, noteStart + 0.15);
      noteGain.gain.exponentialRampToValueAtTime(0.0001, noteStart + 3.8);
      
      osc.connect(noteGain);
      noteGain.connect(this.bgmGain);
      
      osc.start(noteStart);
      osc.stop(noteStart + 4.0);
    });
  }

  setVolume(val) {
    if (this.bgmGain) {
      this.bgmGain.gain.value = Math.max(0, Math.min(1, val));
    }
  }

  /* Sound FX Synthesizers */
  playHeartPop() {
    this.init();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    
    osc.type = 'sine';
    osc.frequency.setValueAtTime(320, now);
    osc.frequency.exponentialRampToValueAtTime(740, now + 0.12);
    
    gain.gain.setValueAtTime(0.35, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.18);
    
    osc.connect(gain);
    gain.connect(this.sfxGain);
    
    osc.start(now);
    osc.stop(now + 0.2);
  }

  playKiss() {
    this.init();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    
    // Kiss smack sound simulation
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(800, now);
    osc.frequency.exponentialRampToValueAtTime(1400, now + 0.08);
    osc.frequency.exponentialRampToValueAtTime(400, now + 0.22);
    
    gain.gain.setValueAtTime(0.4, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
    
    osc.connect(gain);
    gain.connect(this.sfxGain);
    
    osc.start(now);
    osc.stop(now + 0.28);
  }

  playPokeChime() {
    this.init();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    
    // Two sweet chime tones
    [523.25, 659.25, 783.99].forEach((freq, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + i * 0.1);
      
      gain.gain.setValueAtTime(0.3, now + i * 0.1);
      gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.1 + 0.8);
      
      osc.connect(gain);
      gain.connect(this.sfxGain);
      
      osc.start(now + i * 0.1);
      osc.stop(now + i * 0.1 + 0.9);
    });
  }

  playSuccess() {
    this.init();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    [440, 554.37, 659.25, 880].forEach((freq, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, now + i * 0.08);
      gain.gain.setValueAtTime(0.25, now + i * 0.08);
      gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.08 + 0.6);
      osc.connect(gain);
      gain.connect(this.sfxGain);
      osc.start(now + i * 0.08);
      osc.stop(now + i * 0.08 + 0.7);
    });
  }
}

window.loveAudio = new LoveAudioEngine();
