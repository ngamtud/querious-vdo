# Lessons learned

Things that went wrong or needed a second pass while making episodes, and the rule that came out of each. Newest first. `CLAUDE.md` links here; the short rules are also copied into `CLAUDE.md`.

## Episode: high-income (EN, 2026-11-08)

- **Use the official series when the story is about an official status (user review).** The first two cuts used GDP per capita as a stand-in for the World Bank's GNI-based groups; the user then added `worldbank_income_classification_history` (OGHIST), `..._thresholds` and `worldbank_gni_per_capita_atlas` to querios and the episode was redone. The story changed a lot: 38 → 36 countries, Brazil/Mexico/Turkey/Kazakhstan were never officially high income, Korea 1995 (not 1992) and back in 2001 (not a year later), Argentina in twice not three times, China 99% not 95%. "Income per person" is only right for GNI, not GDP (Guyana's GDP far exceeds its residents' income).
- **Official groups ≠ today's GNI.** OGHIST was set with the estimates of each July; current WDI GNI is revised, so a GNI line chart can sit above the threshold in years a country was not high income (Korea 1998–2000, Argentina 2013/2015/2018/2025). A one-square-per-year strip of the official group was tried and rejected on review (the user prefers line charts); the fix kept the GNI line vs the stepped threshold and added lime bands for the years officially classified high income, with a note saying the line is today's revised estimate.
- **Timing fixes don't need new voices.** To add air after a beat or hold a chart, change only `at` (text unchanged) and mix the cached voice files again with `engine/mix.py --voice-dir`; for Thai that saves a Paxa run. Commit `episode.json` with `[skip ci]` so `voice-paxa.yml` doesn't re-voice the episode. A pause can be added without retiming every scene by warping time in `render()` (hold the frame for N s at the gap, then `t − N`).
- **high-income-th:** copied the EN episode (separate `scene.html` with a Thai `T` block plus a small Thai CSS override, as in renewable-th). Paxa `nomyen` lines ran over only on v5 (3.4 s in a 2.8 s slot, fitted 1.2×) and v6 (+0.05 s). Paxa needed −3 dB (not −2) to land at −18.0 LUFS next to EN −18.2. The Korea note wraps to two lines in Thai; it sits at y 1150 at 16 px so it clears the year labels.
- **Story review (user, round 4):** two "in-and-out" line charts in a row (Argentina, then Korea) felt repetitive, and a fast-climb detour (Guyana) diluted the point. Final order: map hook (world only) → line → cumulative columns of the 36 (waves + falls in one chart, not up/down bars) → "Once rich, always rich?" → 32 of 36 → Argentina, which greys out while Korea is drawn on the same axes, then the y axis grows after the crisis so Korea's take-off shows → Thailand vs China. Label wave ranges as net changes (9 → 19, 19 → 28) on a cumulative chart and voice them the same way.
- **When revised data contradicts the official call, say so at that moment.** Korea's 1998 GNI line stays above the threshold on today's revised data; the VO says it "was moved back down" (not "fell below") and a one-line note under the chart explains it.
- **Count countries, name the territories.** Nine of the 45 economies that moved up are territories (incl. Macao, which also moved up in East Asia); the hook counts countries and the note says so.
- **When Querious MCP is rate-limited,** read the parquet files from the querios repo (sparse clone of `data/worldbank/<dataset>`) with DuckDB in Python; the SQL is the same.
- **Approximate measures say so on every chart.** The World Bank classifies by GNI per capita (Atlas); the catalog has GDP per capita, so every chart note says "vs. WB high-income line (GNI, Atlas) · approximate", and the thresholds by year live in `data.sql`. A PPP dataset was considered and rejected: the thresholds are nominal US$, so PPP values would make Thailand, Indonesia and Viet Nam "high income".
- **Drop data artifacts openly.** Iraq's 1990 → 1991 values ($10,261 → $23) are a Gulf War artifact; it is excluded from the bar chart and the note says "Iraq excluded". The on-screen SQL result still shows 1990 = 1 because it is the exact query displayed.
- **Wording follows the line, not the story.** Thailand was 53% of the line in 2017 and 53% in 2024, but 61% in 2019 in between, so the VO says "right back there", not "stuck", and the peak is on screen.
- **Longer is fine when the content earns it.** The user prefers complete content at 1–1.5 min over cutting beats; this cut is 97 s with 16 lines (Guyana, "33 of 38 stayed", Korea question all kept).
- **Legends beat in-chart line labels** on step lines: the "HIGH-INCOME LINE" label collided with the steps on both the Argentina and Korea charts; a legend row above the plot fixed it. Value labels near a line's end: keep them short ("95.5%") so they clear the last segments.
- **Labels over 1180 px sit in the like/comment band.** Year ticks at y 1190 put "2020" into the band; moved to y 1176.
- **Loudness:** the first mix hit −16.9 LUFS / 0.0 dBFS true peak. Voice −2 dB → −18.3 LUFS / −1.7 dBFS (−1 dB gave −0.7 dBFS peak).
- **Map hooks beat number hooks (user review).** The first cut opened on a big number; the user asked for a world map lighting up country by country with the counter. Countries light in order of their first crossing year with a year ticker, so the waves show before the bar chart explains them. Map: `make-map.mjs` (world-atlas 110m, Equal Earth, ids = M49 codes, squares for tiny islands). Clip the map with a wrapping `div` (`overflow:hidden` on the root `svg` did not clip the zoomed group), use `vector-effect:non-scaling-stroke` for the zoom, and keep "below the line" fill dark (#2E382C) so "already high" (#6B7B5E) reads as a separate class.
- **Push the new branch before adding files** so the Paxa workflow doesn't re-voice every Thai episode (rule from gapminder, followed here).

## Episode: gapminder + gapminder-th (2026-11-08)

- **Old episodes need a re-layout, not a nudge.** Gapminder was built on 72 px margins. Rebuilt on the `--safe-*` variables: chart x 215–920 with axes ending at y 1110, note/caption/SQL/connection panel/destination cards use class `R` (right 230) because they sit in the like/comment band, play and Run buttons on the left. Captions shortened to one line ("Bubble = country.", "He pressed play.").
- **One scene file for both languages.** All copy lives in `T={en:{…},th:{…}}` and `const LANG='en'`; `gapminder-th/scene.html` is the same file with `LANG='th'`, so layout fixes apply to both by copying one file.
- **Result-row counts must match the SQL shown.** The query on screen has no `WHERE … IS NOT NULL`, so the result is 13,975 rows (the 11,523 in the old cut came from the filtered data query). Count the exact query you display.
- **The first push of a new branch voices every Paxa episode.** The workflow diff starts from `0000…` on a new branch, so all Paxa episodes were re-voiced (rate limit). Next time push the branch before changing any `episode.json`, or run the workflow manually with `-f episodes=<ep>`.
- **Thai lines over the slot:** v4 "ทางนี้รวยขึ้น ทางนั้นสุขภาพดีขึ้น" overran even at 1.3× (2.91 s in a 2.7 s slot) → "ทางนี้รวย ทางนั้นสุขภาพดี"; v2 hit the 1.3× cap → "วงกลมคือประเทศ". Second pass max stretch 1.28.
- **Loudness:** EN −17.6 LUFS / −1.7 dBFS; TH with Paxa −2 dB −17.4 LUFS / −3.3 dBFS; music audible in the last 3 s of both.
- **End card:** the clip was extended 54 → 58 s so "Your turn_" holds ~3 s after the last line before the erase-out.

## Episode: sea-renewable + sea-renewable-th (2026-11-07)

- **Thai voice: spell English words in Thai, or use Thai words.** Paxa read "เควียเรียส" and "คิวรี" wrongly. Thai voice-over text now uses **คิวเรียส** for Querious, **ดึงข้อมูล** for the verb "query", **คำสั่ง** for a query/SQL, **กดรัน** for Run, **ชุดข้อมูล** for dataset. On-screen text keeps the English (SQL, UI labels, dataset names). Fixed in renewable-th and fertility-th too.
- **The user's framing vs the data.** The brief was "renewable share fell everywhere in Southeast Asia"; the data says 10 of 11 (Singapore rose, 0.2% → 1.1%). The clip says "10 of 11" and uses Singapore as a small turn.
- **Retime instead of trimming good lines.** Five English lines overran slots copied from the `renewable` timeline. The chunks were moved (clip 62 → 65.8 s) rather than cutting words; the end card still holds ~3 s after the last line (`ES` shift in scene.html).
- **One copy block per language.** `scene.html` keeps all on-screen text in a `T` object at the top of the script (captions with times, labels, end card, step labels, country names), so the Thai copy only replaces that block plus a small CSS override (no negative tracking, smaller hook/headline sizes).
- **Dumbbell instead of slope chart** for "first year → 2021" across 11 countries: slope-chart labels collided at the low end (Malaysia 8.3, Brunei 0.7, Singapore 0.2).
- **Thai lines still ran long on the first Paxa pass** (v6, v8, v10 over their slots even at 1.3×). Trimmed: v6 → "แต่นี่ไม่ใช่ข่าวร้าย", v7 dropped "พลังงานหมุนเวียน", v8 → "พอบ้านมีไฟ สัดส่วนก็ลด แต่การใช้ไฟต่อคนเพิ่มยี่สิบสี่เท่า", v10 dropped "ทั้งที่ใช้ไฟเพิ่มขึ้นตลอด" (the caption and the kWh line carry it). Second pass: all fit, max stretch 1.27.
- **Remixing fertility-th** with the new voice hit −1.0 dBFS peak at −2 dB voice; −3 dB gave −18.0 LUFS, peak −1.9.
- **Baselines differ by country.** Cambodia's renewable series starts in 1995 and Timor-Leste's in 2002; the source line says so.

## Episode: fertility-th (2026-11-07)

- **Re-layout, not just translate.** The English fertility cut predates the Facebook-safe zone (72 px sides). The Thai copy was rebuilt on the `--safe-*` variables: charts span x 215–920 with axes ending above y 1180, and the note, caption, result table and connection panel use `right: 230px` (class `R`) because they sit in the like/comment band (y 1180–1780). The English `fertility` episode still has the old margins.
- **Draw the safe box on preview frames.** Overlaying the 150/300/380 box plus the right band on the stills caught a wrapped question headline (120 px Thai was too big for 780 px; 100 px fits) and action buttons overlapping the last result row.
- **Paxa rate limit (429).** The first run stopped after 10 of 13 lines: `tts.py` retried only 3 times at 5–15 s. It now retries 7 times, honouring `Retry-After` (Paxa asked for 60 s) or backing off 15–90 s.
- **Voice only what changed.** The workflow used to re-voice every Paxa episode on every push (renewable-th too), which burns the rate limit. Now a push voices only episodes whose `episode.json` changed; a change to `engine/tts.py` or the workflow re-voices all. Manual run: `gh workflow run voice-paxa.yml --ref <branch> -f episodes=<ep>`.
- **Thai lines run long.** Three lines needed trimming to fit slots taken from the English timeline (≤ 1.3× stretch): "วันนี้ สองประเทศแทบเท่ากัน" → "วันนี้แทบเท่ากัน" (2.1 s slot), and the Querious line dropped the dataset name. Count on ~10–15% fewer words than a literal translation.
- **Loudness:** lowering the Paxa files 2 dB again matched English (−17.3 vs −17.0 LUFS).

## Episode: renewable (2026-11-07)

### Visuals
- **Facebook crops the sides.** On Facebook's full-screen player the fertility clip lost ~85–90 px per side (measured from a phone screenshot: "Querious" lost its "Q", "1960" lost its "1"); its top bar covers ~280 px, the like/comment/share column sits over the right ~230 px from y≈1180–1780, and the caption starts ~1630 px. New 9:16 safe zone: top 300, bottom 380, sides 150, right 230 clear in y 1180–1780. Scenes use `--safe-*` CSS variables; the logo sits inside the top bar row (top 300, right 150). Check previews with the safe box drawn (`#safe` in the URL, or draw it on the preview frames).
- **Camera pushes move edge text outward.** With 150 px margins, keep scene scale ≤ 1.025 so text at the edges stays inside the safe zone.
- **Narrower frame (780 px) means shorter lines.** Headlines ~110 px max, captions one line (e.g. "Over 2× Europe." instead of "More than double Europe."), SQL at ~20 px mono with column aliases.

### Thai version (renewable-th)
- **Same timeline, other language:** copy the episode, keep every voice `id`, `at`, `duration`, `chunks` and `sfx` identical, translate `text` (keep the English in `text_en`). Then the English voice can be laid over the Thai visuals with `engine/mix.py episodes/<ep>-th --voice-dir .cache/<ep>/voice --out ...`.
- **Thai voice:** Edge/Azure TTS is blocked from both the cloud workspace and the Mac VM. The offline option is Meta MMS-TTS Thai (`voice.engine: "mms-tha"`, `./setup.sh --thai`). It is **CC BY-NC 4.0 (non-commercial)** and sounds flatter than Kokoro. Write numbers as Thai words; the model has no SARA AM (handled in `tts.py`). `voice.fit: true` time-stretches (ffmpeg atempo, pitch kept, max 1.3×) any line that is too long for its slot.
- **Paxa Labs replaced MMS for Thai** (user found MMS too flat). Voice `nomyen`. Generated by `.github/workflows/voice-paxa.yml` with the repo secret `PAXA_API_KEY`; the secret must be on **ngamtud/querious-vdo** under Actions → Repository secrets (the first attempt was saved on another repo, and the run failed with "Repo secret PAXA_API_KEY is missing"). Download the zip with the REST API (`gh api -H "Accept: application/octet-stream" repos/ngamtud/querious-vdo/releases/assets/<id>`), since `gh release download` uses GraphQL, which is blocked from cloud sessions. All 14 Thai lines fit their slots.
- **Match loudness between languages.** Paxa lines came out ~1.7 LU louder than Kokoro (final mix −15.5 LUFS, peak −0.5 dBFS vs −17.2 LUFS for English). Lowering the voice files 2 dB brought it to −17.1 LUFS, peak −2.4. Check `ffmpeg -i <mp4> -af ebur128=peak=true -f null -` on every language version.
- **Thai end card** is its own copy, not a translation: "ข้อมูลพร้อมแล้ว_ / มาหาคำตอบกัน / QUERIOUS.STUDIO ↗ / สำรวจข้อมูลได้ฟรี ไม่ต้องสมัครสมาชิก".
- **Thai type:** IBM Plex Sans Thai (`TH` font family) as fallback after SG/PM, no negative tracking, line-height ≥ 1.2. A `@font-face` with `font-family:PM,TH` is invalid and silently drops the face (mono labels fell back to a serif); declare one family per `@font-face`. Typewriter and erase effects slice by grapheme (`Intl.Segmenter`) so Thai vowels and tone marks never split from their consonant. Thai captions run longer: check every caption stays on one line.

### Data and story
- **Renewable share ≠ clean electricity.** WDI EG.FEC.RNEW.ZS is a share of final energy and includes traditional biomass (wood, charcoal). Africa leads on it, DR Congo is 96%, but DR Congo uses ~134 kWh of electricity per person a year vs Finland ~15,600. The clip says so on screen.
- **2021 is the last complete year** for the renewable package (2022 has 71 of 215 values and no DR Congo).
- **Check the user's recollection against the data.** "Finland leads on share × use" was close: Iceland is first, Norway second, Finland third.
- The "share × use" ranking mixes a final-energy share with electricity per person; label it as a rough lens.

## Episode: fertility (2026-11-05)

### Audio
- **Music stopped at the last voice-over line, not at the end of the clip.** In `engine/mix.py` the voice track is the sidechain that ducks the music, and ffmpeg's `sidechaincompress` ends when its sidechain ends. Every clip built before this fix (including the 54 s fertility cut and Gapminder) went silent after the last line. Fix: the voice mix is padded to the full duration (`apad=whole_dur`) before it is split. Rule: after every build, check that the last seconds still have music (command in `CLAUDE.md`).
- **The old music generator stretched 4 chords over the whole clip and faded twice at the end.** Long clips got very long chords, and the last pad faded over 2.2 s on top of the 3 s master fade, so the music was nearly silent ~2 s before the end. `engine/music.py` now keeps 13.5 s sections, repeats the Am → G → F → Em/G cycle, crossfades without a dip, holds the last chord and fades once, ending exactly on the last frame.

### Visuals
- **End card needs room to breathe.** "Your turn_" originally appeared ~1.5 s before the clip ended. Now: hold the end card ~4 s after the last line, then erase every text block from its beginning (bottom block first, headline last) until only the blinking orange `_` is left, fade the logo, and fade the cursor out in the last ~0.5 s. Use this ending for every episode.
- **Check previews for collisions at the busiest moments.** Problems found in stills: a reference-line label overlapping a moving data label; a 1.08 camera push that slid the top bar's tag under the logo (keep total scene scale ≤ ~1.06 on scenes with the top bar); a result table taller than estimated that covered the action buttons; a two-line text block that jumped up when its first line was erased (keep the `<br>` so lines keep their place).

### Data and story
- **Check which years are complete before choosing "latest".** The WDI fertility package covers 1960–2025 in metadata, but every 2025 value is null; 2024 is the latest usable year. Query `count(value)` per year first.
- **Look for the surprising comparison in the data, not only the requested one.** The brief was "Japan is famous for low fertility, now others are falling too". The data showed Thailand was below Japan for seven years (2016–2022), which became the hook.
- **Avoid hooks that need two steps to understand.** "One in four people live in countries with fertility ≤ 1.3" was rejected: viewers must first understand the threshold, then the population share. Prefer one direct comparison (A < B, X years).
- **Say what the numbers are.** WDI fertility values are modelled estimates and can differ from national statistics; the chart note says so, and labels the 2.1 line as a common replacement reference.
- **Closing question:** the user preferred an open, personal question ("Where does your country sit?") over a quiz whose answer is held back.

### Product accuracy
- Use the real web app labels from `ngamtud/querios` (`web/src/Workbench.tsx`): `OPEN IN QUERY ↗`, `RUN QUERY ▶`, `↓ CSV`, `↓ JSON`, `COPY CSV`, `CONNECT`, `COPY CSV URL`. Table names in SQL use the dataset id, e.g. `worldbank_fertility_rate_total`.

### Workflow
- From a cloud session the user's Mac folder has no `node_modules`, `.venv` or Kokoro model. Clone `querious-vdo` (and `querios` for data) into the cloud workspace, run `./setup.sh` there (~1 min), build there, then copy the episode files and the MP4 back to `~/Dev/viz/querious-vdo`.
- A full 58 s build takes about 3 minutes; `./build.sh <ep> --skip-video` remixes audio only.
