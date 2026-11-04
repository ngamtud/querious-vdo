# Working rules for Claude in querious-vdo

This repo makes short motion-graphic clips for Querious. The brand is fixed; every episode must look and sound like the same series.

## Read first
- `brand/brand-motion-guide.md`: colours, fonts, motion style ("Cinematic × Flat Editorial"), formats and safe zones
- `brand/sonic-identity.md`: music rules (ambient only: no drums, risers, whooshes or loud hits)
- `episodes/gapminder/`: the reference episode. Start new episodes by copying it

## Workflow
1. Run `./setup.sh` if `node_modules/`, `.venv/` or `.cache/kokoro/` is missing
2. Agree the script with the user first: hook → story → question (don't reveal the answer) → how to do it in Querious → end card "Your turn_"
3. Write `episode.json` (lines + start times), run `engine/tts.py` and check every line fits its slot before animating
4. Build `scene.html`, check still frames with `node engine/render.js episodes/<name> --preview ...` at the busiest moments, then render
5. Final: `./build.sh episodes/<name>`. Output goes to `renders/` (git-ignored). Never commit videos, voice files or models

## Content rules
- Product flow shown must match the real product (repo `ngamtud/querios`): catalog → dataset → SQL in the browser (DuckDB) → result table → CSV/JSON download or **Connect** (live CSV/JSON connection URL for AI or BI tools). The web app does not build animated bubble charts from a query result. Don't show features it doesn't have
- Use real data from the querios catalog, with the query saved as `data.sql`. Never invent numbers
- Every chart carries a short mono source/caveat line (e.g. current US$, not inflation-adjusted)
- Logo top right, 76 px: `brand/querious-logo-lime.svg` on dark scenes, `brand/querious-logo-dark.svg` on light scenes
- Default format 9:16, 1080×1920, 30 fps; respect safe zones (top 220, bottom 340, sides 72)
- Voice: Kokoro `af_bella`, speed 1.05 unless the user asks otherwise (other voices in `engine/tts.py`)
- Gapminder episode uses Gapminder's four-region colours (Africa #00D5E9, Americas #7FEB00, Asia & Oceania #FF5872, Europe #FFE700); other charts use the Querious data-viz palette
