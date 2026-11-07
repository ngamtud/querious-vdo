# Querious — Sonic Identity & Background Music

> Add-on to the "Querious — Brand & Motion Style Guide" (section 11). Use for all background music in Querious clips.
> The generator lives in `engine/music.py`: `python3 engine/music.py <duration> <out.wav> [--section 13.5]`. It makes a track of any length, so it always matches the clip.

## 11. Sound & music [motion direction]

### 11.1 Approach
- Music is **synthesized directly in Python + NumPy**. No AI music generators, no stock/library tracks, so there are no licensing issues and the sound stays consistent across every clip
- Genre: **Minimal Electronic Ambient**: warm sine-wave pads holding the chords, plus short soft plucks on a steady pulse
- Mood: calm, curious, focused, like the "researcher's notebook" personality. Never busy, dramatic or loud

### 11.2 Musical spec
| | |
|---|---|
| Length | Any: matches the clip (`episode.json` → `duration`). Sections stay 13.5 s; a tail under 4 s joins the last section |
| Key / chords | A minor feel: **Am → G → F → Em/G**, one chord per section, repeating for longer clips (e.g. 58 s = Am G F Em/G Am · 120 s = 9 sections) |
| Pads | 4 voices per chord, sine + 18% 2nd harmonic, small phase offset per voice, 2.2 s equal-power crossfade centred on each section change (no dip in level); the last chord holds to the final frame |
| Plucks | Every 1.5 s (≈ 40 BPM pulse), pitch per section A4 → B4 → C5 → G4, exponential decay (`exp(-3.8t)`), 1.4 s long |
| Fades | Fade-in 2.5 s · one 3 s fade-out that ends exactly on the last frame (plucks stop 1.5 s before the end) |
| Level | Normalized, peak 0.23 (≈ −13 dBFS) so it sits under voice-over and UI sounds |
| File | WAV, mono, 16-bit, 44.1 kHz |

### 11.3 Syncing music with motion
- Section changes every 13.5 s line up with the clip template (section 7.6): use chord changes for scene changes / lime block wipes
- The 1.5 s pluck pulse is the beat grid for hard cuts and UI pops
- Music length follows the clip automatically (`engine/mix.py` passes the episode duration to `engine/music.py`). Change the chord length only with `--section`
- The voice sidechain is padded to the full clip, so music keeps playing after the last voice-over line
- If there is voice-over, duck the music a further 6–10 dB under speech

### 11.3b Voice-over
| | |
|---|---|
| English | Kokoro `af_bella`, speed 1.05 (offline) |
| Thai | Paxa Labs `nomyen` (via `.github/workflows/voice-paxa.yml`); MMS Thai only as an offline fallback (flat sound, non-commercial licence) |
| Timing | Each line must end ≥ 0.15 s before the next line starts; a second-language version keeps the same start times (`voice.fit` time-stretches up to 1.3×) |
| Loudness | Final mix ≈ −17 LUFS integrated, true peak ≤ −1.5 dBFS, the same for every language version. Paxa lines needed −2 dB to match Kokoro |

### 11.4 Rules
- Do: soft sine tones, slow envelopes, plenty of space, fade in and out
- Don't: drums, heavy bass, distortion, risers/whooshes with lots of noise, sudden loud hits, copyrighted music
- Limitations today: no drums, bass or full-production arrangement. It is a simple base

### 11.5 Next steps (ideas, not yet built)
- **Sonic logo:** a 3–5 s motif for the intro / end card (e.g. a short pluck phrase A4–C5–E5 over the Am pad)
- **Shared ambient bed:** one family of pads used in every clip, with the chord order varied per episode
- UI sound set: soft click, typewriter tick, "Run query" snap, all synthesized with the same sine/pluck sound

> Note: the first chord (Am) and the generator header were reconstructed because the original paste started mid-list. If the original first chord was different, change the first entry of `chords` in `engine/music.py`.
