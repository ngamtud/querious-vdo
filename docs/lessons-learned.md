# Lessons learned

Things that went wrong or needed a second pass while making episodes, and the rule that came out of each. Newest first. `CLAUDE.md` links here; the short rules are also copied into `CLAUDE.md`.

## Episode: renewable (2026-11-07)

### Visuals
- **Facebook crops the sides.** On Facebook's full-screen player the fertility clip lost ~85–90 px per side (measured from a phone screenshot: "Querious" lost its "Q", "1960" lost its "1"); its top bar covers ~280 px, the like/comment/share column sits over the right ~230 px from y≈1180–1780, and the caption starts ~1630 px. New 9:16 safe zone: top 300, bottom 380, sides 150, right 230 clear in y 1180–1780. Scenes use `--safe-*` CSS variables; the logo sits inside the top bar row (top 300, right 150). Check previews with the safe box drawn (`#safe` in the URL, or draw it on the preview frames).
- **Camera pushes move edge text outward.** With 150 px margins, keep scene scale ≤ 1.025 so text at the edges stays inside the safe zone.
- **Narrower frame (780 px) means shorter lines.** Headlines ~110 px max, captions one line (e.g. "Over 2× Europe." instead of "More than double Europe."), SQL at ~20 px mono with column aliases.

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
