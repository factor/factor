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
| Paragraph direction and tabs | `fonts.shaping` exposes explicit left-to-right/right-to-left direction and uniform tab intervals through DirectWrite. |
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

## Validation

The additional Uniscribe pass finishes with 178 checks from the saved image,
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
