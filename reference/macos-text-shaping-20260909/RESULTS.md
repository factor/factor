# macOS text shaping and ligature audit — 2026-09-09

Audited the macOS Core Text renderer, including the new visible-region GPU tiles. Source changes are tested with explicit vocabulary refreshes; the application image has not been rebuilt.

## Fixed

- **Bidirectional selection:** two primary caret offsets cannot describe a logical selection. Selecting the entire Hebrew run in `abc אבג def` previously yielded identical endpoints and no highlight. Selection geometry now intersects the logical range with Core Text glyph runs, handles each run's direction and boundary positions, and returns disjoint visual intervals when needed. Both editor rectangles and rendered selection backgrounds use this geometry.
- **Selection reuse:** each cached line retains the most recent selection intervals. Touching/overlapping intervals are merged before painting, avoiding repeated coverage at fractional run boundaries with translucent selection colors.
- **Large color emoji rasterization:** moving the text position outside a bitmap tile changed native color-emoji rasterization, with errors as high as 108/255 in the stress corpus. Translating the graphics context while keeping Core Text's text position at zero eliminates these differences in the tested emoji. The complete shaped line is still passed to Core Text for every region.

## Shaping and caret checks

`probe.factor` measures native glyph counts with ligature values 0, 1 and 2, and samples mouse hit testing across complete lines. Tested fonts include Times, Hoefler Text, Baskerville and Didot. Results depend on the font's actual features:

| Hoefler Text sample | Essential only (0) | Standard (1) | All available (2) |
| --- | ---: | ---: | ---: |
| `fi` | 2 glyphs | 1 | 1 |
| `ffi`, `ffl` | 3 | 1 | 1 |
| `st`, `ct` | 2 | 2 | 1 |

Arabic lam-alef remains a single required ligature even at value 0. The probe also checks stacked combining marks, Devanagari, Bengali, Thai, Hebrew mixed with Latin, emoji ZWJ sequences, family emoji, skin tones, regional-indicator flags and keycaps. The tested joined emoji produce one glyph. Sampled mouse hits avoid splitting the tested emoji, combining and Devanagari clusters; Latin `fi` retains an insertion position between its letters.

The UI retains native standard ligatures. Value 2 is exercised explicitly through attributed-string attributes in the audit; the patch does not globally enable decorative ligatures. Apple's definitions: [ligature attribute](https://developer.apple.com/documentation/coretext/kctligatureattributename), [glyph runs](https://developer.apple.com/documentation/coretext/ctlinegetglyphruns(_:)), [primary and secondary caret offsets](https://developer.apple.com/documentation/coretext/ctlinegetoffsetforstringindex(_:_:_:)).

## Pixel comparisons

`run.factor` creates a native CGL context and compares actual tiled GL readbacks against one continuous Core Text image drawn through the same GL pipeline. Fourteen samples are sized to cross a 512-pixel tile boundary and rendered at both 1× integer placement and 2× half-device-pixel placement. A selected long mixed-script line adds a 29th case. Optional ligatures are explicitly enabled for these captures.

- 23 cases: byte-for-byte identical.
- 2 cases: maximum component difference 1/255.
- 4 oversized accented/Arabic outline cases: sparse region-dependent antialias differences, maximum 4/255 at integer placement and 2/255 at fractional placement. These are a remaining limit, **not pixel-perfect results**. The checker records a separate explicit tolerance only for these four cases.
- All oversized color emoji cases are byte-for-byte identical after the context-transform fix.
- The five earlier long-line, selected-text and tall-text comparisons were rerun and remain byte-for-byte identical.

The retained `before-ctm-*.png` images show the earlier rasterization. Final captures are the numbered `.rgba` files; `pixel-results.json` records the final comparisons. The tall-tile experiment is retained separately and is not a production setting.

## Validation and limits

Native shaping, caret, bidirectional selection, interval merging and color-emoji region regression tests are in the Core Text vocabularies. The full relevant test run also includes Core Graphics, UI text, line support, editors, Cocoa view handling and OpenGL textures, with explicit assertions that both test failures and compiler errors are empty.

The existing long-line and document-size optimizations remain active. The final benchmark rerun measured 95.3 ms versus 28.0 ms for 100 lines × 20 warm repaints (3.4×), and 229.6 ms versus 3.22 ms for unchanged 10,000-line measurement (71×). These are local synthetic benchmarks; initial shaping still processes a full logical line.

This corpus is not an exhaustive inventory of every font feature, script or installed font. Full visual bidi arrow navigation and secondary-caret affinity are separate editor concerns. Fractional movement of a cached texture also remains filtered bitmap movement, rather than rerasterization at each new fractional origin.

Reproduce:

```sh
./factor -no-user-init reference/macos-text-shaping-20260909/test.factor
./factor -no-user-init reference/macos-text-shaping-20260909/probe-run.factor
./factor -no-user-init reference/macos-text-shaping-20260909/run.factor > reference/macos-text-shaping-20260909/results.jsonl
python3 reference/macos-text-shaping-20260909/compare.py
```

The pixel checker uses NumPy for fast byte-array comparisons. `unit-tests.log`, `probe.jsonl`, `results.jsonl` and `pixel-check.log` retain the validation output.


A [final follow-up pass](../macos-text-finalpass-20260909/RESULTS.md) adds sparse UTF-16 index conversion, whitespace background coverage and correct translucent editor selection, with additional native GPU cache checks.
