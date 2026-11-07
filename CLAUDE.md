# Working rules for Claude in querious-vdo

This repo makes short motion-graphic clips for Querious. The brand is fixed; every episode must look and sound like the same series.

## Read first
- `brand/brand-motion-guide.md`: colours, fonts, motion style ("Cinematic × Flat Editorial"), formats and safe zones
- `brand/sonic-identity.md`: music rules (ambient only: no drums, risers, whooshes or loud hits)
- `episodes/gapminder/`: the reference episode. Start new episodes by copying it
- `episodes/renewable/`: current reference: Facebook-safe margins (`--safe-*` variables), bar chart, scatter (log axis), two-dataset JOIN walkthrough, erase-out end card
- `episodes/renewable-th/`: Thai version on the same timeline (Thai text + MMS Thai voice, `voice.fit`); see lessons learned for how to make a second-language version
- `episodes/fertility/`: reference for line charts, bar charts, the catalog → query → result → connect walkthrough and the standard end card (erase-out)
- `docs/lessons-learned.md`: mistakes from past episodes and the rules they produced. Read it before starting, and add to it after each episode

## Workflow
1. Run `./setup.sh` if `node_modules/`, `.venv/` or `.cache/kokoro/` is missing
2. Agree the script with the user first: hook → story → question (don't reveal the answer) → how to do it in Querious → end card "Your turn_"
3. Write `episode.json` (lines + start times), run `engine/tts.py` and check every line fits its slot before animating
4. Build `scene.html`, check still frames with `node engine/render.js episodes/<name> --preview ...` at the busiest moments, then render
5. Final: `./build.sh episodes/<name>`. Output goes to `renders/` (git-ignored). Never commit videos, voice files or models
6. Check the final audio: music must play to the last second (it ducks under voice, it must not stop after the last line):
   `ffmpeg -v error -i <final.mp4> -ss <duration-3> -af volumedetect -f null - 2>&1 | grep mean_volume` should be around −20 to −30 dB, not −90 dB or silence
7. After the episode, add what went wrong or was changed on review to `docs/lessons-learned.md`

## Content rules
- Product flow shown must match the real product (repo `ngamtud/querios`): catalog → dataset → SQL in the browser (DuckDB) → result table → CSV/JSON download or **Connect** (live CSV/JSON connection URL for AI or BI tools). The web app does not build animated bubble charts from a query result. Don't show features it doesn't have
- Use real data from the querios catalog, with the query saved as `data.sql`. Never invent numbers
- Every chart carries a short mono source/caveat line (e.g. current US$, not inflation-adjusted)
- Logo top right inside the safe zone (top 300, right 150), 76 px: `brand/querious-logo-lime.svg` on dark scenes, `brand/querious-logo-dark.svg` on light scenes
- Default format 9:16, 1080×1920, 30 fps. Safe zone (Facebook-proof): top 300, bottom 380, sides 150, and the right 230 px clear between y 1180–1780. Facebook crops ~85–90 px off each side. Use the `--safe-*` CSS variables from `episodes/renewable/scene.html` instead of hard-coded 72/96 px
- Voice: Kokoro `af_bella`, speed 1.05 unless the user asks otherwise (other voices in `engine/tts.py`)
- Before choosing "latest year", count non-null values per year (some packages list a final year that is all null)
- Hook: one direct, surprising comparison found in the data (e.g. "Thailand < Japan, 2016–2022"). Avoid stats that need two steps to read (e.g. share of population living in countries below a threshold)
- UI labels must match the web app (`web/src/Workbench.tsx`): `OPEN IN QUERY ↗`, `RUN QUERY ▶`, `↓ CSV`, `↓ JSON`, `CONNECT`, `COPY CSV URL`; SQL table names are dataset ids (e.g. `worldbank_fertility_rate_total`)
- End card (standard for every episode): "Your turn_", hold ~3–4 s after the last voice line, then erase each text block from its beginning (bottom first, headline last) until only the blinking `_` is left; fade the logo, then the cursor in the last ~0.5 s
- Camera push on scenes with the top bar: total scale ≤ ~1.06, or the tag slides under the logo. Check previews for overlapping labels
- Music: `engine/music.py` builds a track of any length (13.5 s chord sections repeating); don't stretch the 4 chords to fit
- Gapminder episode uses Gapminder's four-region colours (Africa #00D5E9, Americas #7FEB00, Asia & Oceania #FF5872, Europe #FFE700); other charts use the Querious data-viz palette
