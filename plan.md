# Plan: Shrink the 604 per-page Quran font assets (preserving offline-first)

## Context

Per `PROJECT_OVERVIEW.md` perf roadmap item #1, the app ships **604 TTF font files** (one per mushaf page) totaling **~92 MB** inside the `data/quran_fonts/` folder. Combined with other bundled data (SQLite, translations, tafsirs), the `data/` folder is **121 MB** — dominant on final APK/IPA size.

**Measured facts** (verified during planning):
- 604 files, average 153 KB, max 173 KB, min 0.3 KB (`p1.ttf` is tiny = Al-Fatiha; most pages are full-size)
- All 604 files are byte-unique (no trivial dedup possible)
- Each file is registered as its own font family (`Page1` … `Page604`) in `pubspec.yaml` lines 151-1968 — **1,800+ lines of pubspec**
- Fonts are referenced in code only via `fontFamily: 'Page$page'` at [lib/pages/surat_page_v3/surat_page_v3.dart:688](lib/pages/surat_page_v3/surat_page_v3.dart#L688), [:893](lib/pages/surat_page_v3/surat_page_v3.dart#L893) (and ~6 adjacent sites). There is **no FontLoader or runtime font registration code today**.

**Hard constraint** — Quran Plus is **offline-first**. The app must fully function without internet after install. Any solution that requires an internet connection on first launch to render mushaf pages is rejected.

**Goal of this plan**: reduce install size meaningfully **without regressing offline-first**, and with minimal rendering-correctness risk (Arabic mushaf typesetting is glyph-ID specific — a wrong subset will visibly break ayah rendering).

---

## Approach — Two phases, shipped independently

### Phase A — Font subsetting (biggest win, ships first)

**Idea**: each `pN.ttf` likely contains glyphs beyond what page N actually renders (standard OS/2 tables, full cmap coverage, placeholder glyphs, hinting for unused sizes, digital signature `DSIG`, etc.). Subsetting keeps only the glyphs actually shaped on that page.

**Expected saving**: **30-60% per file** → **~30-55 MB reduction** on a 92 MB baseline. This is an educated estimate — calibration on a few sample pages is the first task of implementation.

**Why this is the first step**: no code changes needed in the Flutter app — it's a pure build-pipeline win. The fonts stay bundled, still rendered the same way, still offline from install.

**Mechanism**:
1. Add a Python tool (`tools/subset_quran_fonts.py`) using `fonttools` + `uharfbuzz`.
2. For each page `N`:
   - Query `data/` SQLite + Quran text source to extract the exact Arabic text rendered on page N.
   - Shape that text through the corresponding `pN.ttf` with HarfBuzz → collect actual **glyph IDs used**.
   - Run `pyftsubset` with `--gids=<list>` plus essential layout tables (`GSUB`, `GPOS` entries referenced by those glyphs).
   - Drop `DSIG` (digital signature — not needed at runtime), drop hinting for unused sizes, drop unused OpenType feature tables.
3. Write the subset fonts into `data/quran_fonts/` (overwrite in place, so the Flutter asset path doesn't change).
4. Commit the subset `.ttf` files. Old full-size fonts available via git history.

**Verification** (critical because Arabic mushaf is ligature-heavy):
- Golden-image diff: render page 1, 50, 100, 300, 500, 604 before/after with `flutter_test` + `matchesGoldenFile`. Bit-identical rendering required.
- If goldens don't match, widen the subset (add OpenType layout tables back) and re-run.
- `flutter analyze` + full test suite still passing.
- Manual QA on a device: scroll the whole mushaf, spot-check surahs the project team reads often.

**Rollback path**: the subsetting script is deterministic. If a regression ships, restore the full fonts from a pre-subset git tag (or keep a `data/quran_fonts_full/` backup folder committed at tag time).

**Effort**: ~2-3 days — most of it is writing the glyph-ID collector correctly and validating goldens.

---

### Phase B — Android Play Asset Delivery (install-time pack) — optional, ships second

**Idea**: split the `data/quran_fonts/` directory out of the base APK into a separate **install-time asset pack** delivered by Google Play.

**What the user sees**: identical — the Play Store downloads the base APK + the fonts pack together at install. App is offline-first from first launch.

**What changes**: the base APK download is smaller (so cold install over patchy networks is faster, and the app can ship more frequent updates without re-downloading fonts). No iOS equivalent that preserves offline-first (iOS On-Demand Resources downloads lazily at runtime, breaking offline-on-first-use), so iOS stays as-is.

**Mechanism**:
1. Create an Android **asset pack module** in `android/` (`fonts_pack` with `install-time` delivery).
2. Move `data/quran_fonts/` out of Flutter's asset bundle. Use the `play_asset_delivery` Flutter plugin (or `AssetManager` via platform channel) to resolve font paths from the pack at runtime.
3. At first use of a page font, load bytes from the pack into a `FontLoader` and register family `Page$N` dynamically.
4. Keep a **small bundled fallback set** (say pages 1-2, which are Al-Fatiha + start of Al-Baqarah — the most-opened content) in the base APK so the first-paint is instant even before the pack resolves.

**Cost / risk**:
- Significant Android-only work; complicates the build.
- Needs `play_asset_delivery` plugin wiring + native Kotlin glue.
- iOS gets nothing from this phase.
- Code paths now diverge for "font loaded" vs "font being loaded" → loading state UI needed.

**Recommendation**: **skip Phase B unless Phase A doesn't shrink enough**. Phase A is likely sufficient.

**Effort**: ~1-2 weeks if pursued.

---

### Phase C — Runtime `FontLoader` indirection — deferred / nice-to-have

**Idea**: remove all 604 `Page1..Page604` entries from `pubspec.yaml`, keep TTFs as raw assets (`rootBundle.load(...)`), register a page font with `FontLoader` on demand when a page becomes visible.

**Does NOT reduce install size**. Benefits are:
- Faster app cold start (no 604 font-family registrations at boot).
- Lower steady-state memory (fonts not in use can be GC'd — modest gain).
- Pairs naturally with perf roadmap item #2 (`PageView.builder`).

**Recommend deferring to the perf work in item #2** where it slots in for free. Not needed for the install-size goal.

---

## Recommended shipping order

1. **Phase A first** (subsetting). Ships a ~30-50 MB install-size win with zero Flutter-code churn.
2. **Re-measure** APK/IPA size. If still too big, go to Phase B. If acceptable, stop.
3. **Phase C** is optional and belongs to perf item #2's implementation.

---

## Critical files (read-only for this plan; may be touched during implementation)

- [pubspec.yaml:147-1968](pubspec.yaml#L147) — the 604 `Page$N` font declarations. Stays as-is for Phase A (paths unchanged, just smaller bytes). Phase B/C would rewrite this section.
- [lib/pages/surat_page_v3/surat_page_v3.dart:688](lib/pages/surat_page_v3/surat_page_v3.dart#L688), [:893](lib/pages/surat_page_v3/surat_page_v3.dart#L893) — the only font-name usage sites. Untouched in Phase A. Phase C would rewrite these to resolve font names through a registry.
- `data/quran_fonts/p*.ttf` (604 files) — the artifacts being shrunk.

## New files added by Phase A

- `tools/subset_quran_fonts.py` — the subsetter (build-time, not shipped).
- `tools/README.md` — brief doc on how to re-run if the mushaf text source ever changes.
- `test/golden/quran_pages/page_*.png` — one golden per sampled page for regression detection.
- `test/quran_font_rendering_test.dart` — widget test that renders each sampled page and compares to goldens.

## Verification plan (end-to-end)

1. Run `python3 tools/subset_quran_fonts.py` → confirm new total size of `data/quran_fonts/`.
2. `flutter test test/quran_font_rendering_test.dart` → all golden diffs pass.
3. `flutter build apk --release` → compare APK size before/after. Record the delta in the PR description.
4. Install the release APK on a real Android device, open the app **with airplane mode on**, read pages 1, 100, 300, 604, and a bookmark list. Confirm identical rendering + no blank pages.
5. Repeat step 4 on iOS (TestFlight build) — offline-first must hold on both platforms.

## Non-goals

- Not altering app code paths in `surat_page_v3.dart` for Phase A. Phase A is purely build-time.
- Not implementing any form of runtime-network font download.
- Not touching the CLAUDE.md, README.md, or `PROJECT_OVERVIEW.md` (the overview describes the plan; this file is the plan).
- Not changing bundled SQLite data (`data/quran_tafsirs/`, `data/quran_translations/`) — those are separate roadmap items if needed.

## Open questions for the user (before implementation)

- Is the mushaf script the **Uthmani Hafs Madinah** print? (Affects which glyph shaping engine we need — standard HarfBuzz is fine for both Madinah and IndoPak, but confirming avoids surprises.)
- Is there an existing source of truth for per-page Arabic text we can query deterministically (SQLite table / JSON file), or do we need to read pages via the app's own `DbLocal` helpers from a Dart script?
- Do you want goldens generated from the **current** (un-subset) fonts as the source of truth, or should we visually QA fresh goldens against a reference mushaf PDF?
