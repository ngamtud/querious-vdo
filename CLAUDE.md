# Working rules for Claude in querious-vdo

This repo makes short motion-graphic clips for Querious. The brand is fixed; every episode must look and sound like the same series.

## Read first
- `brand/brand-motion-guide.md`: colours, fonts, motion style ("Cinematic × Flat Editorial"), formats and safe zones
- `brand/sonic-identity.md`: music rules (ambient only: no drums, risers, whooshes or loud hits)
- `episodes/gapminder/` + `episodes/gapminder-th/`: bubble chart on the Facebook-safe layout; one scene file for both languages (`T` copy block + `const LANG`)
- `episodes/renewable/`: current reference: Facebook-safe margins (`--safe-*` variables), bar chart, scatter (log axis), two-dataset JOIN walkthrough, erase-out end card
- `episodes/renewable-th/`: Thai version on the same timeline (Thai text + Paxa voice `nomyen` via GitHub Actions, `voice.fit`); see lessons learned for how to make a second-language version
- `episodes/fertility-th/`: Thai fertility on the Facebook-safe layout (line + bar charts, single-dataset walkthrough)
- `episodes/fertility/`: reference for line charts, bar charts, the catalog → query → result → connect walkthrough and the standard end card (erase-out)
- `docs/lessons-learned.md`: mistakes from past episodes and the rules they produced. Read it before starting, and add to it after each episode

## Workflow
1. Run `./setup.sh` if `node_modules/`, `.venv/` or `.cache/kokoro/` is missing
2. Agree the script with the user first: hook → insight (≈75–80% of the clip: the story, the twist, the answer) → how to do it in Querious (≈20–25%) → end card. Check every claim against the data first, including numbers the user remembers (e.g. "Finland leads" was really Iceland 1st, Finland 3rd), and say on screen when a measure is a rough lens or mixes units. Ending on an open question instead of the answer is optional, only when the user asks for it
3. Write `episode.json` (lines + start times), run `engine/tts.py` and check every line fits its slot before animating
4. Build `scene.html`, check still frames with `node engine/render.js episodes/<name> --preview ...` at the busiest moments, then render
5. Final: `./build.sh episodes/<name>`. Output goes to `renders/` (git-ignored). Never commit videos, voice files or models
6. Check the final audio: music must play to the last second (it ducks under voice, it must not stop after the last line):
   `ffmpeg -i <final.mp4> -ss <duration-3> -af volumedetect -f null - 2>&1 | grep mean_volume` should be around −18 to −30 dB, not −90 dB or silence (don't pass `-v error`, it hides the result).
   Loudness: `ffmpeg -i <final.mp4> -af ebur128=peak=true -f null - 2>&1 | grep -E "I:|Peak:"` should be about −17 LUFS with peak ≤ −1.5 dBFS, the same for every language version (adjust the voice files with `volume=-NdB`, not the music)
7. After the episode, add what went wrong or was changed on review to `docs/lessons-learned.md`

## Content rules
- Product flow shown must match the real product (repo `ngamtud/querios`): catalog → dataset → SQL in the browser (DuckDB) → result table → CSV/JSON download or **Connect** (live CSV/JSON connection URL for AI or BI tools). The web app does not build animated bubble charts from a query result. Don't show features it doesn't have
- Use real data from the querios catalog, with the query saved as `data.sql`. Never invent numbers
- Every chart carries a short mono source/caveat line (e.g. current US$, not inflation-adjusted)
- Logo top right inside the safe zone (top 300, right 150), 76 px: `brand/querious-logo-lime.svg` on dark scenes, `brand/querious-logo-dark.svg` on light scenes
- Default format 9:16, 1080×1920, 30 fps. Safe zone (Facebook-proof): top 300, bottom 380, sides 150, and the right 230 px clear between y 1180–1780. Facebook crops ~85–90 px off each side. Use the `--safe-*` CSS variables from `episodes/renewable/scene.html` instead of hard-coded 72/96 px
- Voice: Kokoro `af_bella`, speed 1.05 unless the user asks otherwise (other voices in `engine/tts.py`)
- Thai voice: Paxa Labs (`voice.engine: "paxa"`, female picks `foithong`, `sanaechan`, `nomyen`). The API is not reachable from the cloud workspace: push the episode and `.github/workflows/voice-paxa.yml` generates the lines with the repo secret `PAXA_API_KEY` and uploads `<ep>-<voice>.zip` to the `voice-cache` pre-release; then download it with the REST API (`gh release download` uses GraphQL, which is blocked): `gh api -H "Accept: application/octet-stream" repos/ngamtud/querious-vdo/releases/assets/$(gh api repos/ngamtud/querious-vdo/releases/tags/voice-cache --jq '.assets[] | select(.name=="<ep>-<voice>.zip") | .id') > voice.zip`, unzip, and `engine/mix.py episodes/<ep> --voice-dir <folder> --out renders/<ep>/<ep>-<voice>-<date>.mp4`. A push voices only the episodes whose `episode.json` changed (a change to `engine/tts.py` or the workflow re-voices every Paxa episode, so batch those edits); to re-run one episode: `gh workflow run voice-paxa.yml --ref <branch> -f episodes=<ep>`. Lower Paxa files 2 dB to match the English loudness. MMS Thai (`mms-tha`) is only an offline fallback (non-commercial licence, flat sound). In Thai voice-over text, write English words the way Thai speakers say them or use Thai words: คิวเรียส (Querious), ดึงข้อมูล (to query), คำสั่ง (a query), กดรัน (Run), ชุดข้อมูล (dataset)
- Before choosing "latest year", count non-null values per year (some packages list a final year that is all null)
- Hook: one direct, surprising comparison found in the data (e.g. "Thailand < Japan, 2016–2022"). Avoid stats that need two steps to read (e.g. share of population living in countries below a threshold)
- UI labels must match the web app (`web/src/Workbench.tsx`): `OPEN IN QUERY ↗`, `RUN QUERY ▶`, `↓ CSV`, `↓ JSON`, `CONNECT`, `COPY CSV URL`; SQL table names are dataset ids (e.g. `worldbank_fertility_rate_total`)
- End card (standard for every episode): "Your turn_" (Thai: "ข้อมูลพร้อมแล้ว_ / มาหาคำตอบกัน / QUERIOUS.STUDIO ↗ / สำรวจข้อมูลได้ฟรี ไม่ต้องสมัครสมาชิก"), hold ~3–4 s after the last voice line, then erase each text block from its beginning (bottom first, headline last) until only the blinking `_` is left; fade the logo, then the cursor in the last ~0.5 s
- Camera push: total scale ≤ 1.025 (with 150 px side margins, more pushes edge text out of the safe zone and the tag under the logo). Check previews with the safe zone drawn for overlapping or clipped labels
- Music: `engine/music.py` builds a track of any length (13.5 s chord sections repeating); don't stretch the 4 chords to fit
- Second-language version (e.g. Thai): copy the episode to `episodes/<ep>-th`, keep every voice `id`, `at`, `duration`, `chunks` and `sfx` identical, translate `text` (keep the English as `text_en`) and the explanatory on-screen text (headlines, captions, labels, callouts, end card). Keep SQL, web-app UI labels, dataset/column names, source lines and numbers in English. Thai type: IBM Plex Sans Thai, no negative tracking, line-height ≥ 1.2, captions on one line, typewriter/erase by grapheme (`Intl.Segmenter`). `voice.fit: true` time-stretches lines that overrun their slot (max 1.3×), so write Thai lines ~10–15% shorter than a literal translation. Mark phrase breaks with ` | ` in the voice text (each phrase is voiced separately and joined with `voice.gap` s of silence); Paxa otherwise runs Thai phrases together. Any language's voice can be laid over any version's visuals with `engine/mix.py --voice-dir`
- Gapminder episode uses Gapminder's four-region colours (Africa #00D5E9, Americas #7FEB00, Asia & Oceania #FF5872, Europe #FFE700); other charts use the Querious data-viz palette
