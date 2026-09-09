# Uniscribe audit — 2026-09-09

## Fixed

- UTF-16 hit conversion no longer decodes an incomplete surrogate pair.
- Hit-testing preserves the complete trailing cluster distance. Clicking near
  the end of `a` plus a combining acute accent or Devanagari `ki` now places the
  caret after both codepoints. Supplementary characters still occupy one Factor
  codepoint. The native trailing output is a distance, as documented by
  [ScriptStringXtoCP](https://learn.microsoft.com/en-us/windows/win32/api/usp10/nf-usp10-scriptstringxtocp).
- Line widths now come from the shaped string instead of the constant 50.
- Cap height and x-height now come from native glyph measurements instead of
  the constant 10; they scale with font size and monitor DPI. Font metrics also
  include external leading, and failed `GetTextMetrics` calls are checked.
  Added the native `FIXED`, `MAT2`, `GLYPHMETRICS`, and `GetGlyphOutlineW` bindings.
  Non-outline fonts may return unavailable cap/x heights. Measurement follows
  [GetGlyphOutlineW](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getglyphoutlinew).
- RGB packing no longer reads four bytes from a three-byte buffer.
- Foreground alpha is honored on opaque backgrounds by compositing the text
  color before GDI applies glyph coverage. Opaque text keeps native antialiasing.

## Follow-up: completed rendering and shaping support

| Area | Implemented support |
| --- | --- |
| Custom selection colors | Both Uniscribe and DirectWrite composite `selection.color`, including disjoint visual runs in bidirectional text. |
| Translucent backgrounds | Both paths preserve background RGBA and composite foreground coverage with source-over alpha. |
| Selection on transparent text images | Selection backgrounds are composited independently from glyph coverage; native pixel tests check the resulting RGBA. |
| Paragraph direction and tabs | `fonts.shaping` exposes explicit left-to-right/right-to-left direction and uniform tab intervals through both DirectWrite and Uniscribe. |
| OpenType feature controls | DirectWrite applies four-character feature tags and unsigned parameters. Native tests verify that toggling kerning changes the layout. |
| Color emoji/fonts | DirectWrite/Direct2D renders native color glyphs. Color can be disabled per font. Native tests verify colored pixels, monochrome opt-out, and palette glyph opacity. |

DirectWrite is now the Windows UI default; the repaired Uniscribe backend remains
available. Font options survive UI font derivation. Layout caches include DPI;
bitmap bounds include native glyph overhang, with a corresponding drawing offset.
Unspecified paragraph direction uses DirectWrite's left-to-right default. Tab
intervals are uniform, not arbitrary stop lists. Typography options apply to the
whole font run. Color format support depends on Windows and installed fonts.
Full bidirectional keyboard navigation and every font family remain unqualified.

API references:

- [ScriptStringOut selection behavior](https://learn.microsoft.com/en-us/windows/win32/api/usp10/nf-usp10-scriptstringout)
- [ScriptStringAnalyse flags and controls](https://learn.microsoft.com/en-us/windows/win32/api/usp10/nf-usp10-scriptstringanalyse)
- [ScriptShapeOpenType feature ranges](https://learn.microsoft.com/en-us/windows/win32/api/usp10/nf-usp10-scriptshapeopentype)
- [DirectWrite color-font support](https://learn.microsoft.com/en-us/windows/win32/directwrite/color-fonts)

## Additional Uniscribe corrections

- Empty layouts no longer call `ScriptStringAnalyse` with zero characters.
  They retain font height, return caret position zero, and produce an empty image.
- Caret conversion unwraps selections before converting UTF-16 indexes. Native
  probes previously raised `no-method` errors for both caret directions.
- Layouts register their disposable owner only after native setup succeeds,
  avoiding a partially initialized owner when setup fails.
- Selection coverage converts the starting UTF-16 prefix once and advances
  through codepoints, removing repeated prefix encoding for long selections.
- Transparent and selected text use `ANTIALIASED_QUALITY` during native analysis
  and drawing. `DEFAULT_QUALITY` can produce ClearType RGB channel differences,
  which are invalid as a single-channel coverage mask. Opaque plain text retains
  the system quality. Native tests also check fallback-font mask coverage.
- Rasterization expands its padding when ink approaches the guard region, then
  crops to the union of logical bounds and actual ink. This preserves italic
  overhang and tall stacks of combining accents. Logical dimensions and caret
  coordinates stay unchanged; the UI applies the resulting bitmap offset.
  Zero-advance combining marks still render: zero advance does not imply empty
  ink. Native examples include standalone U+0301 and U+0338 in Consolas.
- Offscreen rendering restores the original selected bitmap on success and
  exceptions before deleting the temporary DIB. Before the fix, 30 renders on
  one DC increased live GDI objects from 4 to 34; afterward the count stays at 4.
  Bitmap readback also flushes GDI drawing before copying DIB memory.

### DPI and native shaping follow-up

- Deferred rasterization uses the layout's captured backing scale for font
  selection and shaping. Previously, changing DPI between layout and rendering
  changed an Arial example from 55×27 to 108×45 pixels. Tests compare dimensions
  and pixels across scale changes for opaque, transparent, and selected text.
- The font cache normalizes heights before memoization. A native probe created
  100 handles for fractional sizes mapping to the same integer height; those
  requests now reuse one handle. Positive subpixel heights clamp to one pixel,
  avoiding GDI's zero-height default-font substitution.
- Uniscribe now honors paragraph direction and uniform tab intervals from
  `fonts.shaping` during both layout and rendering. Tab intervals round to native
  pixels after DPI scaling. Native tests cover RTL visual edges and ordering,
  repeated tab stops, fractional intervals, and signed-integer overflow.
- Native analysis ownership is explicit at the layout and rendering call sites.
  Temporary analyses no longer have both unconditional and error-only cleanup
  registered, avoiding a double free on interrupted rendering.
- A quality audit across 117 font/size/script combinations found matching layout
  bounds and caret positions for default and grayscale antialiasing.

### Input snapshots and layout lifetime

- Uniscribe snapshots caller-owned font names, text, selections, colors, and
  shaping options. A native probe previously laid out Arial 12 text at 9×15,
  then rendered it at 66×45 after the caller changed its font and string. The
  retained layout and its independent cache key now preserve the original input.
- The GDI font cache resolves aliases and copies names before memoization, so
  caller string edits cannot corrupt its keys. Aliases and resolved family names
  now share the same native handle.
- Uniscribe and DirectWrite reject caret, selection, and rendering operations on
  disposed layouts and clear their released native pointers.
- The Uniscribe UI adapter delegates empty and selected text to the native
  wrapper, avoiding plain-string sequence operations on selection objects.
- A 112-case fallback-font probe found consistent logical heights and baseline
  totals. Caret coordinates also survived destruction of the original DC and
  1,000 replacement DC allocations. No changes were justified by those probes.

### Caret indexing, long lines, and editor selections

- Layouts cache codepoint-to-UTF-16 boundaries. Caret-to-x uses direct lookup;
  x-to-caret uses binary search, preserving native cluster boundaries and
  flooring surrogate interiors. On this machine, 1,000 queries over a
  10,000-character ASCII/emoji line dropped from 0.129 to 0.0030 seconds
  for caret-to-x and from 0.185 to 0.0053 seconds for x-to-caret.
- A disposed layout found in the Uniscribe cache is replaced with a fresh
  layout. Direct operations on an already disposed layout still raise an error.
- Native fallback silently changed Consolas advances on long printable ASCII
  lines, including a 32,764-character example. Such lines now bypass fallback
  only after `GetGlyphIndicesW` proves the selected font covers every character.
  Non-ASCII text, controls, and failed coverage queries retain fallback.
  Glyph-buffer capacity is capped at 65,535 to avoid native rejection of the
  previous allocation request for 50,000-character lines. Tests validate exact
  ASCII advances; they do not establish arbitrary-length complex-script support.
- Editors let Uniscribe and DirectWrite paint their own selection backgrounds.
  The old extra rectangle blended translucent highlights twice and filled
  unselected gaps between bidirectional runs. Hidden-window GPU tests reproduce
  both defects on both backends and verify the fixes. A 50% red highlight over
  white changed from RGB `{255, 64, 64}` to `{255, 127, 127}`; bidi gaps stay white.
  Collapsed selections retain their one-pixel caret rectangle.

### Font aliases, bitmap copying, and glyph expansion

- Uniscribe resolves font aliases before snapshotting layouts and cache keys.
  Previously, changing an alias from Arial to Courier New after layout changed
  the deferred raster while retaining Arial's measurements. Existing layouts
  now keep their resolved family, and subsequent lookups use the updated alias.
  DirectWrite also snapshots resolved font names in independent layout/cache
  objects, fixing stale cache hits after alias changes.
- Bitmap cropping copies contiguous DIB rows instead of reading and writing
  each pixel through Factor. Twenty crops of a 4,096×256 source bitmap took
  0.601 seconds before and 0.240 seconds afterward on this machine. This measures
  the crop operation, not complete text rendering. Exact-byte tests cover row
  orientation, channel preservation, empty crops, and unchanged source pixels.
- An additional 672 native comparisons across eight font families, twelve
  sizes, and seven script samples found no differences between layout and
  grayscale rendering analyses in dimensions, UTF-16 caret positions, ascent,
  or descent. Another 189 selection comparisons found matching cluster coverage
  across combining, Indic, Arabic, emoji, and other samples. Neither audit
  justified changing the existing metrics or half-open selection geometry.

- The recommended `1.5 * UTF16-length + 16` glyph allowance was insufficient
  for repeated Tibetan and Kannada characters. Native analysis returned success
  but substituted glyphs or zero advances, including with fallback disabled.
  The allowance is now `4 * UTF16-length + 16`, still capped at 65,535, covering
  the reproduced expansion cases. This is additional headroom, not a guarantee
  for arbitrary fonts or text beyond native limits. Microsoft's
  [ScriptShape documentation](https://learn.microsoft.com/en-us/windows/win32/api/usp10/nf-usp10-scriptshape)
  explains why the usual estimate can be insufficient. Allocating the maximum
  for every string was rejected after a native probe retained roughly 145 MB
  for 100 short layouts; fallback remains enabled where it was enabled before.

## Validation

The latest alias, crop, and glyph-expansion pass runs 261 native/UI checks and
six GPU selection checks from the saved image without reloading implementations,
with zero failures. The old glyph allowance fails nine of eleven new expansion
regressions; the new allowance passes all eleven, comparing repeated-character
widths, 1,000-codepoint caret positions, and actual raster bytes against native
analyses with ample capacity. Local logs are
`temp/uniscribe-expansion-saved-tests.log`, `temp/uniscribe-expansion-gpu.log`,
and `temp/uniscribe-expansion-negative.log`.

The earlier caret, long-line, and editor-selection pass ran 244 native/UI checks
(229 unit tests plus 15 inference/error checks) from the saved image without
reloading implementations, with zero failures. Six additional hidden-window
GPU checks pass from that image, including alpha blending, bidi gaps, and
collapsed carets for both Windows renderers. The default remains DirectWrite.
The GPU regression is `reference/editor-selection-regression.factor`; local
saved-image logs are `temp/uniscribe-long-selection-saved-tests.log` and
`temp/editor-selection-saved.log`.

The earlier input-snapshot and lifetime pass ran 223 checks from the saved image
without reloading implementations, with zero failures. It includes six snapshot
regressions, disposed-state checks for both native backends, selected-text UI
geometry, and mutable-name/alias GDI cache checks.

The earlier overhang pass finished with 178 checks from the saved image,
including nine native overhang regressions and offscreen GDI ownership tests.
Both source-reload and saved-image runs report zero failures; the saved-image
run does not reload implementations.
The overhang tests compare coverage against an independently padded reference,
including 24 stacked accents, standalone zero-advance marks, opaque native pixels,
selection geometry, unchanged advances, and UI bitmap offsets. A native UI smoke
test at 1.5 DPI displays the formerly clipped italic and stacked-accent glyphs.

The two Uniscribe test vocabularies contain 19 native checks, including 18 added
regressions. The metric tests produced five failures before the fix. Tests cover
surrogate interiors, emoji, combining marks, Devanagari clusters, caret bounds,
line widths, two font sizes, RGB/alpha packing, GDI text color, and actual raster
pixels for fully transparent text on an opaque background.

Follow-up validation adds 11 font-option checks, 8 Uniscribe compositing checks,
19 native DirectWrite layout checks, 5 native color/selection raster checks, and
2 UI adapter checks. The combined suite also runs the existing text, baseline,
label, grid, editor, and pane tests with zero failures. Native color emoji
rendering produced 1,724 colored pixels; disabling color produced none.
The 1.5-DPI Listener reproduction with a half-physical-pixel translation has
no stray underlines. A separate UI smoke test displays color emoji, Arabic,
Hebrew, Indic text, explicit RTL paragraphs, and 100-logical-pixel tabs.

Rendering 100 distinct short labels at size 12 took 20.865 seconds before
reusing the Direct2D DC render target and 0.200–0.208 seconds afterward in a
warmed process on this machine. The renderer resets native target state on
image startup and target errors, and releases the target on shutdown.

Ran `windows.uniscribe`, `ui.text`, `ui.baseline-alignment`, `ui.gadgets.labels`,
`ui.gadgets.panes`, and `ui.gadgets.grids` after reloading changed dependencies:
zero failures, process exit 0. Local logs are `temp/uniscribe-audit-*` and
`temp/uniscribe-metrics-*`; feature probes are `temp/uniscribe-feature-probe.*`.
