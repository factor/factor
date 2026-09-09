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

## Confirmed gaps and missing features

| Area | Evidence and remaining work |
| --- | --- |
| Custom selection colors | `selection.color` is not used by this backend. Native probes with red and blue selections produce identical bitmaps. `ScriptStringOut` uses system highlight colors; custom selection backgrounds need their own rendering path. |
| Translucent backgrounds | The grayscale-mask path discards background color and alpha. A space on a half-transparent blue background currently produces zero-alpha pixels. It needs proper background compositing. |
| Selection on transparent text images | System-colored selection output is passed through a grayscale coverage conversion. Selection backgrounds and text coverage need separate handling. |
| Paragraph direction and tabs | `make-ssa` hardcodes flags and passes null control/state/tab definitions. Basic script shaping and fallback exist, but the backend exposes no paragraph base-direction or custom tab-stop controls. |
| OpenType feature controls | No `ScriptShapeOpenType` pipeline or feature-range bindings exist here. This is missing user control over features, not an absence of basic complex-script shaping. |
| Color emoji/fonts | The GDI path renders monochrome glyphs or a single foreground-color mask. Layered color-glyph rendering requires a new rendering path, such as DirectWrite. |

The first three gaps have direct code or native-probe evidence. Paragraph,
OpenType, and color-font support are larger feature work and were not implemented
by this audit. Full bidirectional editor navigation, font-fallback ink bounds,
and all font families were not qualified.

API references:

- [ScriptStringOut selection behavior](https://learn.microsoft.com/en-us/windows/win32/api/usp10/nf-usp10-scriptstringout)
- [ScriptStringAnalyse flags and controls](https://learn.microsoft.com/en-us/windows/win32/api/usp10/nf-usp10-scriptstringanalyse)
- [ScriptShapeOpenType feature ranges](https://learn.microsoft.com/en-us/windows/win32/api/usp10/nf-usp10-scriptshapeopentype)
- [DirectWrite color-font support](https://learn.microsoft.com/en-us/windows/win32/directwrite/color-fonts)

## Validation

The two Uniscribe test vocabularies contain 19 native checks, including 18 added
regressions. The metric tests produced five failures before the fix. Tests cover
surrogate interiors, emoji, combining marks, Devanagari clusters, caret bounds,
line widths, two font sizes, RGB/alpha packing, GDI text color, and actual raster
pixels for fully transparent text on an opaque background.

Ran `windows.uniscribe`, `ui.text`, `ui.baseline-alignment`, `ui.gadgets.labels`,
`ui.gadgets.panes`, and `ui.gadgets.grids` after reloading changed dependencies:
zero failures, process exit 0. Local logs are `temp/uniscribe-audit-*` and
`temp/uniscribe-metrics-*`; feature probes are `temp/uniscribe-feature-probe.*`.
