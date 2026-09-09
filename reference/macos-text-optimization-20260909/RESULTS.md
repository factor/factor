# macOS long-line and many-line rendering improvements

Implemented in the working tree, 2026-09-09. Windows text backend files were not changed.

## Changes

- [Core Text regions](/Users/erg/factor/basis/core-text/core-text.factor:129) retain the complete shaped line and full image extent. Onscreen rendering no longer loses the tail at 16,384 pixels. Glyphs, bidi ordering, ligatures, combining marks, and fallback fonts keep their original shaping context across tile boundaries.
- [Visible tiles and GPU caching](/Users/erg/factor/basis/ui/text/core-text/core-text.factor:72) rasterize only visible 512×256 device-pixel tiles. Each tile includes neighboring pixels for linear filtering, while its geometry draws only the interior. Per-window caches reuse texture IDs and vertex arrays; CPU tile bitmaps can be collected after upload. Existing cache aging, backing-scale invalidation, and window disposal release textures in the proper context.
- The new macOS draw path uses premultiplied-alpha blending. Raster bounds include an antialias guard on all sides and full typographic extents for selections.
- [Editor measurement caching](/Users/erg/factor/basis/ui/gadgets/editors/editors.factor:284) retains small dimensions independently of expiring native layouts. Reflow measures only new/changed strings, invalidates for font geometry or backing-scale changes, and drops entries for removed lines. Color-only font changes reuse measurements.
- [Selection work](/Users/erg/factor/basis/ui/gadgets/editors/editors.factor:227) is limited to visible rows instead of every selected row. Editors already culled vertically offscreen text drawing.
- A renderer hook selects the macOS tile path. Other text backends keep their existing draw path. Shared GL3 drawing gained a vertex-array entry point used by the tiles; existing whole-texture drawing delegates to it.

## Measurements

Local macOS 26.6.2, Apple Silicon, actual offscreen CGL rendering with production functions compiled. These are microbenchmarks, not end-to-end interactive latency or universal speed guarantees. Timings are medians of three samples.

| Workload | Previous path | New path | Ratio |
| --- | ---: | ---: | ---: |
| 100 distinct lines, 20 repaints, CPU bitmaps already warm | 96.09 ms | 27.22 ms | 3.53× faster |
| Reflow 10,000 unchanged lines after clearing native layouts | 211.85 ms | 3.44 ms | 61.51× faster |

The repaint test retains exactly 100 textures across repeated frames. The reflow test creates zero new native line layouts on the cached path. A selection covering a 10,000-line document creates entries for only 30 visible rows in the benchmark viewport.

The long-line fixture scrolls to device x = 20,000 and uses only three tiles for its 1,024-pixel-wide viewport. A repeated draw reuses those tiles. The glyph fixture includes Latin ligatures, combining accents, Arabic, and a ZWJ emoji.

## Correctness

All five GPU comparisons produced **zero differing components** against an untiled Core Text region drawn with the same transform and correct alpha blending:

1. Long line at 1×, x = 20,000.
2. Long line at 2×, x = 20,000.
3. The same 2× line shifted half a device pixel.
4. Large glyphs spanning vertical tile boundaries, scrolled on both axes and shifted half a device pixel.
5. Selected text, including whitespace, crossing horizontal tile boundaries.

Cache reuse and `glIsTexture` checks verify that cached GPU objects survive warm draws and are deleted when the cache is disposed. The capture helper functions are intentionally unoptimized to avoid excessive compiler specialization of the fixture; production drawing functions and benchmark loops remain optimized. Pixel comparisons run separately in Python.

Unit coverage includes long-line region ink beyond the former cutoff, bounded region dimensions, italic antialias coverage, whitespace selection bounds, clip transforms, 1×/2× visible tile ranges, measurement reuse/invalidation, reversed selections, and offscreen selected rows. The relevant Core Text, Core Graphics, UI text, editor, line-support, Cocoa backing-scale, and texture suites are run with explicit assertions that both test failures and compiler errors are empty.

## Remaining limits

Initial shaping of a new long line still processes the full line, and initial exact document measurement still visits all lines. The dimension-cache reflow still scans the document's strings; it avoids reshaping unchanged lines rather than making reflow constant-time.

The standalone `string>image` API keeps its existing maximum surface size. The uncapped behavior is the macOS onscreen tile path. Non-axis-aligned or projective transforms conservatively draw all tiles. Physical monitor migration and end-to-end AppKit/color-management parity were not re-tested here.

## Reproduce

From the repository root:

```sh
./factor -no-user-init reference/macos-text-optimization-20260909/run.factor > reference/macos-text-optimization-20260909/results.jsonl 2>&1
python3 reference/macos-text-optimization-20260909/compare.py
```

[Raw timings and counters](results.jsonl), [pixel results](pixel-results.json), [GPU fixture](validate.factor), [unit-test log](unit-tests.log).

Changes are source edits; the existing application image was not overwritten.


Follow-up: [ligature, complex shaping and selection audit](../macos-text-shaping-20260909/RESULTS.md). After its context-transform and selection fixes, all five pixel comparisons still match exactly. The final benchmark rerun measured 95.3 ms versus 28.0 ms for repainting (3.4×), and 229.6 ms versus 3.22 ms for unchanged 10,000-line measurement (71×).
