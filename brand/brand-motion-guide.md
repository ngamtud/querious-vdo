# Querious — Brand & Motion Style Guide

> Resource for Claude when making short clips / motion graphics for Querious (querious.studio).
> Source of truth: `ngamtud/querios` → `web/src/style.css`, `web/index.html`, `web/public/favicon.svg`, `web/src/Chart.tsx`, `web/src/main.tsx` (surveyed 2026-11-04).
> Sections marked **[from site]** are taken directly from the code. Sections marked **[motion direction]** are recommendations for video that build on the site's style.

---

## 1. Brand at a glance [from site]

| | |
|---|---|
| Name | **Querious** (logo text renders the first letter "Q" in a pixel font) |
| Descriptor | Open data workbench |
| Made by | Viz Craft Studio |
| Status | Beta 1.1 (shown as a rotated lime "BETA" tag) |
| Hero line | **"Curiosity starts with *data.*_"** |
| Supporting line | "A playground for curious people to explore, query and create with open data. Start with a dataset. See where it leads." |
| Eyebrow | OPEN DATA / OPEN QUESTIONS |
| Core flow | DISCOVER → UNDERSTAND → QUERY → VISUALIZE → TAKE IT FURTHER |
| Promise | NO ACCOUNT NEEDED TO EXPLORE |
| Product features | Dataset catalog, provenance and data dictionary, SQL in the browser (DuckDB), charts and maps, CSV/JSON export, Challenges, Wiki, My Q (saved queries) |
| Languages | EN + TH (toggle in the header) |

**Personality:** curious, open, friendly to beginners while still precise about data. Like a researcher's notebook or a lab workbench: honest and source-transparent, with a little playfulness (pixel glyphs, the blinking cursor, the tilted tag).

## 2. Voice & copy [from site]

- Short, direct and inviting: "What would you like to explore?", "See where it leads."
- Headlines in sentence case, ending with an orange **`_`** cursor: `Data catalog_`, `Challenges_`, `Find your way in_`
- Eyebrow / label: **UPPERCASE MONO** with ` / ` separators: `DATASET / ID / V1`, `PLAY / LEARN / QUESTION`, `01 / THE QUESTION`
- Use · as a separator for meta info: `3 DATASETS · SQL · JOIN`
- Arrows: `↗` = open / go to another page, `→` = next step / see more
- CTAs are uppercase mono: `OPEN IN QUERY ↗`, `BROWSE ALL DATASETS →`, `TRY CHALLENGE ↗`
- Thai: plain, explanatory wording; keep dataset, column and organization names in English

## 3. Logo / mark [from site]

- **Favicon mark:** a dark square `#222923` holding a lime `#d5ed5a` line icon (a box with a tail, like a speech bubble crossed with a magnifying glass, read as a "Q"), stroke weight 3/32
- **Wordmark:** "Querious" in Space Grotesk 700, tracking −0.05em, with the first letter "Q" in **Pixelify Sans**
- Use on a cream background (ink text) or on a dark ink background (cream/lime text)
- Don't: add gradients, round the corners of the mark, or add drop shadows

## 4. Color [from site]

### Core palette
| Token | Hex | Role |
|---|---|---|
| `--paper` | `#F4F1E9` | Main background (warm cream, like paper) |
| `paper-2` | `#FAF9F3` / `#FBFAF5` | Cards / panels |
| `sage-tint` | `#E9EDE3` / `#E9EDE0` | Secondary panels, sidebars |
| `--ink` | `#283127` | Text, 1px lines, dark buttons (green-black) |
| `ink-deep` | `#222923` | Logo background, darkest scenes |
| `--muted` | `#677166` | Secondary text |
| `--line` | `#C7CBBF` | Light divider lines |
| `--accent` | `#D6ED63` | **Lime** for highlight, hover, hard shadows, featured cards |
| `--orange` | `#E5764B` | Cursor `_`, active underline, focus ring, ✳ (use sparingly) |
| `olive` | `#708348` | Emphasis word in headlines (e.g. *data.*) |
| `success` | `#245C3B` on `#E2F2DC` | Success states |
| `error` | `#903F29` on `#F9E7DE` | Error states |

**Approximate ratio:** cream 70% · ink 20% · lime 8% · orange 2%

### Data-viz palette (from Chart.tsx)
- Categorical (in order): `#424E3D` `#DD6B43` `#839B45` `#637B91` `#C6A04D`
- Sequential (maps / choropleth): `#E9EFD5` → `#ADC878` → `#667E50` → `#283F35`
- Axis line `#8B9485` · gridline `#E1E4DA` · axis text `#455044`
- Mini histogram bars `#6F8658`

## 5. Typography [from site]

| Use | Font | Style |
|---|---|---|
| Display / headings | **Space Grotesk** 700 | Very tight tracking (−0.07 to −0.09em), line-height 0.9–1.0, large |
| Body | Space Grotesk 400–500 | 14–20px, line-height 1.45–1.6 |
| Labels / UI / data / code | **IBM Plex Mono** 400–600 | 9–13px, uppercase for eyebrows, tracking +0.05–0.09em |
| Thai | **IBM Plex Sans Thai** 400–700 | No negative tracking, line-height 1.3+ |
| Accent glyphs | **Pixelify Sans** 500–700 | Only for single characters: "Q", ✳, empty-state icons, challenge icon |

All of these are Google Fonts.

## 6. Visual language / UI motifs [from site]

- **Flat, square corners on everything** (no border-radius), no gradients, no soft shadows
- **1px ink borders** around cards and panels; 2px rules under section headings
- **Hard offset shadow** on hover: `5px 5px 0 #D6ED63` plus a −2px lift
- Lime highlight block on active or selected items
- Grid layouts: 3-column cards, 5-column topic grid, workbench split into schema | editor | guide
- **Blinking orange `_` cursor** after headlines
- **Pixel ✳** in orange as the "curiosity" symbol
- "BETA" tag rotated −4°
- SQL code panel: dark ink background, light text, 4px lime left border

Closest design terms: **flat editorial / soft neo-brutalism** (square shapes, crisp lines, hard shadows) with **retro-pixel accents**, in a warm paper-and-sage palette. ("Flat digital" works as shorthand.)

---

## 7. Motion style: "Cinematic × Flat Editorial" [motion direction]

**Idea:** keep every graphic flat and precise like the website, but handle it like a film: camera moves, depth, pacing and lighting. Think of filming a paper diorama of the website.

### 7.1 Cinematic layer (camera & mood)
- **Virtual camera:** slow push-ins (scale 1.00 → 1.06 over 3–5s), gentle pans, a quick *snap-zoom* to the point being clicked
- **Depth from flat layers:** 2–4 parallax layers (background grid / main panel / labels / cursor), each moving at a different speed
- **Rack focus:** blur the background 6–10px when the focus moves to a detail, then sharpen again
- **Light:** soft vignette (5–8%), very fine paper grain (opacity 3–4%), and a slow light sweep across cream surfaces
- **Dramatic scenes:** switch to the dark `#222923` background with cream text and lime highlights, for example for the opening, key insights and the end card
- **Letterbox** 2.39:1 is optional for the opener only (16:9 format)
- **Pacing:** slow → snap → hold. Let the main moment hold for 0.6–1.2s before moving on

### 7.2 Flat-digital layer (graphics)
- All shapes are flat with 1px/2px ink lines, square corners, solid colors from the palette
- Transitions:
  - **Lime block wipe:** a lime rectangle sweeps across the frame to reveal the next scene
  - **Line-draw reveal:** borders draw themselves, then content fades in
  - **Hard-shadow pop:** a card lifts by −4px and its lime shadow snaps out
  - **Typewriter:** text types in, then ends with a blinking `_` cursor
  - Hard cuts on the beat of the music
- Avoid glow, lens flare, 3D extrude, gradients, rounded corners and bouncy elastic easing

### 7.3 Timing & easing
| Action | Duration | Easing |
|---|---|---|
| Camera push / pan | 2–5s | `cubic-bezier(.45,0,.2,1)` (slow in–out) |
| Snap-zoom | 0.35–0.5s | `cubic-bezier(.7,0,.2,1)` |
| UI enter (cards, labels) | 0.25–0.4s | `cubic-bezier(.2,.8,.2,1)` (ease-out) |
| Stagger between items | 40–70ms | — |
| Cursor blink | 530ms on/off | step |
| Hold on key moment | 0.6–1.2s | — |

FPS: 30 (social) or 60 (smoother cursor and UI movement)

### 7.4 Web walkthrough scenes (click-through steps)
- Rebuild the UI from the real tokens in this guide, or use screenshots placed inside a flat browser frame (1px ink border, square corners, cream bar)
- **Cursor:** a crisp black arrow with a thin cream outline that moves along a gentle curve (not a straight line) and slows down before each click
- **Click feedback:** a square orange `#E5764B` ripple (not a circle) plus a lime highlight on the button that was clicked
- **Step label:** a mono pill in the corner, e.g. `STEP 02 / QUERY`
- **Callout:** a cream box with a 1px ink border, a hard lime shadow and a straight 1px leader line to the point it describes
- Zoom in to 140–180% on the area being interacted with, then pull back out to show the context
- Typing SQL: type at 25–40 characters/second, highlight keywords in lime/olive, then press Run with a snap

### 7.5 Data-viz scenes
- Use only the data-viz palette in section 4
- Bars grow from the baseline (stagger 50ms) · lines draw from left to right · numbers count up (mono, tabular)
- Choropleth maps fill country by country with the sequential palette, in a wave across the map
- Gridlines and axes appear first (line-draw), then the data
- Highlight the insight: dim everything else to 30% opacity, mark the key point in orange, and add a large Space Grotesk headline on top
- Show the data source in mono on every chart: `SOURCE / WORLD BANK WDI · 2026` (in line with the brand's transparency)

### 7.6 Clip structure template
1. **Hook (0–3s):** dark background, typewriter headline + `_`, e.g. "Curiosity starts with data._"
2. **Problem / Question (3–8s):** a question in large type, cream background
3. **Walkthrough (8–30s):** 3–4 steps: DISCOVER → QUERY → VISUALIZE
4. **Insight (30–40s):** the animated chart plus the key number
5. **End card (last ~6s):** "Your turn_", `querious.studio ↗`, "NO ACCOUNT NEEDED TO EXPLORE", wordmark. Hold ~3–4 s after the last voice line, then **erase-out**: delete each text block from its first letter (bottom block first, headline last) until only the blinking orange `_` is left, the same cursor the hook opens with. Fade the logo, then the cursor in the last ~0.5 s. Reference: `episodes/fertility/` and `episodes/renewable/`

### 7.7 Formats
| Format | Size | Safe zone |
|---|---|---|
| 16:9 (YouTube / presentations) | 1920×1080 | 96px on every side |
| 9:16 (Reels / TikTok / Shorts / Facebook) | 1080×1920 | **top 300px, bottom 380px, sides 150px**; also keep the right 230px clear between y 1180–1780 (Facebook like/comment/share buttons) |
| 1:1 (Feed / LinkedIn) | 1080×1080 | 80px on every side |

**Why the 9:16 safe zone is this wide:** Facebook's full-screen player scales a 9:16 video to fill taller phone screens (e.g. 19.5:9) and crops ~85–90px off each side; its top bar covers ~280px and the caption block starts ~1630px. Measured from a Facebook screenshot of the fertility episode (2026-11-07), where 72px side margins left text touching the screen edge. Everything that must be read (text, labels, axis ticks, logo) goes inside the safe zone; backgrounds and chart gridlines may run to the edge.

Minimum text size: headings 64px+ (9:16: 80px+), mono labels 22px+ so they stay readable on a phone

---

## 8. CSS tokens (copy-ready)

```css
:root{
  --paper:#F4F1E9; --paper-2:#FAF9F3; --sage:#E9EDE3;
  --ink:#283127; --ink-deep:#222923; --muted:#677166; --line:#C7CBBF;
  --accent:#D6ED63; --orange:#E5764B; --olive:#708348;
  --viz-1:#424E3D; --viz-2:#DD6B43; --viz-3:#839B45; --viz-4:#637B91; --viz-5:#C6A04D;
  --seq-1:#E9EFD5; --seq-2:#ADC878; --seq-3:#667E50; --seq-4:#283F35;
  --font-display:'Space Grotesk','IBM Plex Sans Thai',sans-serif;
  --font-mono:'IBM Plex Mono',monospace;
  --font-pixel:'Pixelify Sans',sans-serif;
  --shadow-hard:5px 5px 0 var(--accent);
  --ease-cine:cubic-bezier(.45,0,.2,1);
  --ease-snap:cubic-bezier(.7,0,.2,1);
  --ease-out:cubic-bezier(.2,.8,.2,1);
}
```

## 9. Do / Don't

**Do**
- Cream background, ink lines, lime as the main highlight, orange only in small touches
- Square corners, 1px lines, hard shadows
- Slow film-like camera moves, then a sharp snap at each key moment
- Show the data source on every chart

**Don't**
- Gradients, glow, rounded corners, soft drop shadows
- Bright saturated colors outside the palette, or neon on black
- Pixelify Sans for whole sentences
- Bouncy or elastic movement, or a cluttered screen with no breathing room

## 10. Prompt snippet for future clips

> Make a motion-graphic clip following the "Querious — Brand & Motion Style Guide" in project resources. Style: Cinematic × Flat Editorial. Format [9:16/16:9], length [xx] seconds, [scene list]. Use only the palette and fonts from the guide, and end with the standard end card.
