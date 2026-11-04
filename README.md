# querious-vdo

Motion-graphic clips for [Querious](https://querious.studio), the open-data workbench. Each clip ("episode") is an HTML page animated frame by frame, rendered to MP4 with Playwright + ffmpeg, then mixed with an offline Kokoro voice-over and the Querious ambient music.

Style: **Cinematic × Flat Editorial**, as defined in [`brand/brand-motion-guide.md`](brand/brand-motion-guide.md) and [`brand/sonic-identity.md`](brand/sonic-identity.md).

## Setup (once)

Needs Node 20+, Python 3.10+ and ffmpeg (`brew install node ffmpeg` on macOS).

```sh
./setup.sh
```

It installs the fonts and Playwright (with Chromium), creates `.venv` with the Python packages, and downloads the Kokoro TTS model (Apache-2.0) into `.cache/`.

## Build an episode

```sh
./build.sh episodes/gapminder
```

1. **Voice:** `engine/tts.py` speaks every line in `episode.json` and checks it fits its time slot
2. **Video:** `engine/render.js` renders `scene.html` in parallel chunks at 30 fps
3. **Music + mix:** `engine/music.py` generates the ambient track; `engine/mix.py` ducks it under the voice, adds UI clicks and writes the final file

The finished video lands in `renders/<episode>/<episode>-<date-time>.mp4`. **`renders/` is git-ignored**: videos stay on your machine and are never pushed.

Faster loops:

```sh
node engine/render.js episodes/gapminder --preview 3,12,30,45   # still frames → renders/gapminder/preview/
./build.sh episodes/gapminder --skip-video                       # new voice or music only
./build.sh episodes/gapminder --skip-voice                       # new visuals only
```

To use a different voice (e.g. ElevenLabs), save one file per line as `v1.mp3`, `v2.mp3` … and run:

```sh
.venv/bin/python engine/mix.py episodes/gapminder --voice-dir path/to/voice
```

## Repository map

| Path | What |
|---|---|
| `brand/` | Brand & motion guide, sonic identity, logos (lime for dark backgrounds, dark for light backgrounds) |
| `engine/` | Shared render, TTS, music and mix scripts |
| `episodes/<name>/episode.json` | Format, duration, render chunks, voice, voice-over lines with start times, music, click times |
| `episodes/<name>/scene.html` | The animation. Defines `window.render(t)`; reads `window.__DATA__` |
| `episodes/<name>/data.json` | Data for the scene (+ `data.sql` showing how it was made) |
| `renders/` | Output videos (local only, git-ignored) |
| `.cache/` | Model, voice lines, video chunks (rebuilt, git-ignored) |

## Making a new episode

Copy `episodes/gapminder` to `episodes/<new-name>`, then edit `episode.json` (lines, timings) and `scene.html` (scenes). Keep the shared pieces: lime block wipes, typewriter headline with orange `_`, flat cards with hard lime shadows, cursor + square orange ripple, logo top right (lime on dark, dark on light), source note under every chart. See `CLAUDE.md` for the working rules.

## Licences

Kokoro model: Apache-2.0. Fonts: SIL Open Font License (Space Grotesk, IBM Plex Mono, Pixelify Sans). Data: World Bank WDI and UN M49 via Querious; check each dataset's licence in the querios catalog.
