# Design System — Style Guide

Tokens live in [`design-tokens.json`](./design-tokens.json) in this folder; both the Flutter app and the React dashboard consume it (generate a `ThemeExtension`/Dart class and a CSS-variables/Tailwind config from the same file — never hand-copy hex values into either codebase).

## Color — derived from `../../logo/logo.jpeg`

The logo (أكاديمية الطفل الرائد — RAEED Academy for Education and Development) is a running child reaching for a star, rendered in a blue-to-gold gradient on black. Colors below were pixel-sampled directly from the file, not eyeballed:

| Sampled from logo | Hex |
|---|---|
| Blue, cluster average | `#0A82DA` |
| Blue, darkest (gradient shadow) | `#06336A` |
| Blue, lightest (gradient highlight) | `#14E9FF` |
| Gold, cluster average | `#EFA80E` |
| Gold, darkest | `#9A5F19` |
| Gold, lightest (star highlight) | `#E4E74E` |
| Backdrop | `#000000` |

These raw values are logged in `design-tokens.json` under `color.logoSource` for traceability, but the app doesn't use them directly — each was adjusted to hit WCAG AA (4.5:1 for text) before becoming a token, computed, not guessed:

| Token | Hex | Contrast | Where it's used |
|---|---|---|---|
| `primary` (light) | `#0A4A8C` | 8.86:1 on white | Buttons, links, primary UI on light backgrounds — this is the deep end of the logo's blue gradient |
| `primary` (dark) | `#29C4EF` | 8.74:1 on `bg` (dark) | Buttons, links on dark backgrounds — the bright end of the same gradient |
| `accent` (light, text use) | `#9C6900` | 4.74:1 on white | Text-bearing gold accents (a badge label, an inline highlight) |
| `accentDecorative` | `#F2A900` | 2.01:1 on white — **decorative/large-scale only in light mode** (icons, illustration fills, borders ≥3px); on dark backgrounds it's 8.92:1 and safe for text too | The star/highlight gold from the logo |

**Why the logo's blue isn't the token directly:** the raw average blue (`#0A82DA`) only reaches 3.97:1 on white — enough for large text and icons (WCAG's 3:1 threshold) but not body text or button labels. `primary` uses the darker end of the same gradient instead of a different hue, so brand identity holds while small text stays legible. Reach for `accentDecorative` freely in illustration, gradients, and the star motif itself; reach for `accent` (or the dark-mode `accentDecorative`, which is already accessible) whenever gold carries actual text.

**Semantic colors** (`success`/`warning`/`danger`/`info`) are deliberately not brand hues reused — a warning shouldn't look like "brand gold" and confuse the two systems. `info` reuses `primary`-adjacent blue since blue-as-informational is already the brand's own association.

## Typography — Amiri for Arabic

**Arabic (primary language) is set in [Amiri](https://fonts.google.com/specimen/Amiri)** — a Naskh text face designed for sustained, high-quality reading of classical and modern Arabic, which fits RAEED's Quran/hadith-adjacent educational content better than a geometric UI sans would. Load it from Google Fonts:

```html
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&display=swap">
```

**Know its limits before building the type scale around it:** Amiri ships two weights (400, 700) and an italic-analog (slanted) style — no 500/600. Build Arabic hierarchy with **size, color, and letter-spacing**, not intermediate weights (`typography.scale` in the tokens file only ever alternates between 400 and 700 for exactly this reason). For long Quranic or hadith excerpts specifically, Google Fonts also serves **Amiri Quran** (`family=Amiri+Quran`) — a variant tuned for Uthmanic-style typesetting; use it only for verse/hadith blocks in Materials content, never for UI chrome.

**Latin script (French/English UI, and any Latin proper nouns inside Arabic layouts)** pairs with **Lora** for headings — a serif with warmth comparable to Amiri's, so the two scripts feel like one typographic identity rather than "Arabic in a decorative font, everything else in a generic sans." Dense UI chrome (buttons, tabs, form labels, timestamps) in either script direction uses **Public Sans**, which has the fuller weight range Amiri lacks and reads cleanly at small sizes.

| Role | Typeface | Used for |
|---|---|---|
| Arabic display/body | Amiri | Headings, body copy, announcements, session content — anywhere Arabic is the reading language |
| Arabic — Quranic/hadith excerpts | Amiri Quran | Verse/hadith blocks only, inside Materials |
| Latin display | Lora | French/English headings |
| UI chrome, both scripts | Public Sans | Buttons, tabs, labels, timestamps, form fields |
| Data/specs (not shipped in-app) | IBM Plex Mono | Code blocks in these spec files only |

## Numerals, dates, RTL

- **Western digits (0-9)**, not Eastern Arabic-Indic — Morocco's own convention, unlike the Mashriq. Pin `NumberFormat` to `ar_MA` explicitly, not generic `ar`, and keep it an org-level setting rather than a hardcoded assumption.
- `font-variant-numeric: tabular-nums` (or Flutter's `FontFeature.tabularFigures()`) wherever digits line up in columns — attendance counts, dashboard stats.
- Gregorian is the system of record; Hijri displays alongside it with an org-level `hijri_offset_days` setting (default 0, ±1) so executives can align to the officially announced date without a release.
- Every layout mirrors under `Directionality` for Arabic — never a hardcoded LTR assumption. Chevrons/back-arrows mirror; a handful of universally-recognized icons (play button, phone) don't, per platform convention.
- Arabic plurals need all six ICU categories (zero/one/two/few/many/other) authored per string from the start — not retrofitted after translation.

## Logo usage

- **Clear space:** minimum padding around the logo equal to the height of the star glyph at any size it's placed.
- **Minimum size:** don't render below 32px tall (mobile app icon aside) — the Arabic wordmark's diacritics disappear first.
- **Don't:** recolor the mark, stretch it off its aspect ratio, place it on a background that drops its contrast (busy photos, mid-tone blues close to the mark's own blue), or add effects (drop shadows, outlines) not in the source file.
- **Backgrounds:** the source file's black backdrop is a presentation choice, not a mandate — the mark reads fine on `color.light.surface` (white) and `color.dark.bg` (near-black) alike; use whichever matches the current theme rather than forcing the logo's own black behind it everywhere.
- App icon: crop to the running-figure mark alone (drop the Arabic/English wordmark) for the launcher icon — the wordmark version is for in-app headers, splash, and the dashboard's login screen.
