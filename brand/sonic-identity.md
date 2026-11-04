# Querious — Sonic Identity & Background Music

> Add-on to the "Querious — Brand & Motion Style Guide" (section 11). Use for all background music in Querious clips.
> The generator lives in `engine/music.py` (same algorithm as `generate_music.py` below, with the duration as an argument).

## 11. Sound & music [motion direction]

### 11.1 Approach
- Music is **synthesized directly in Python + NumPy**. No AI music generators, no stock/library tracks, so there are no licensing issues and the sound stays consistent across every clip
- Genre: **Minimal Electronic Ambient**: warm sine-wave pads holding the chords, plus short soft plucks on a steady pulse
- Mood: calm, curious, focused, like the "researcher's notebook" personality. Never busy, dramatic or loud

### 11.2 Musical spec (current track: `querious-original-ambient.wav`)
| | |
|---|---|
| Length | 54 s = 4 sections × 13.5 s |
| Key / chords | A minor feel: **Am → G → F → Em/G**, one chord per section |
| Pads | 4 voices per chord, sine + 18% 2nd harmonic, small phase offset per voice, 2.2 s crossfade between sections |
| Plucks | Every 1.5 s (≈ 40 BPM pulse), pitch per section A4 → B4 → C5 → G4, exponential decay (`exp(-3.8t)`), 1.4 s long |
| Fades | Fade-in 2.5 s · fade-out 3 s |
| Level | Normalized, peak 0.23 (≈ −13 dBFS) so it sits under voice-over and UI sounds |
| File | WAV, mono, 16-bit, 44.1 kHz |

### 11.3 Syncing music with motion
- Section changes every 13.5 s line up with the clip template (section 7.6): use chord changes for scene changes / lime block wipes
- The 1.5 s pluck pulse is the beat grid for hard cuts and UI pops
- Match the music length to the clip: change `duration` and the section length (`13.5`) together; keep `duration = sections × section_length`
- If there is voice-over, duck the music a further 6–10 dB under speech

### 11.4 Rules
- Do: soft sine tones, slow envelopes, plenty of space, fade in and out
- Don't: drums, heavy bass, distortion, risers/whooshes with lots of noise, sudden loud hits, copyrighted music
- Limitations today: no drums, bass or full-production arrangement. It is a simple base

### 11.5 Next steps (ideas, not yet built)
- **Sonic logo:** a 3–5 s motif for the intro / end card (e.g. a short pluck phrase A4–C5–E5 over the Am pad)
- **Shared ambient bed:** one family of pads used in every clip, with the chord order varied per episode
- UI sound set: soft click, typewriter tick, "Run query" snap, all synthesized with the same sine/pluck sound

> Note: the first chord (Am) and the generator header were reconstructed because the original paste started mid-list. If the original first chord was different, change the first entry of `chords` in `engine/music.py`.
