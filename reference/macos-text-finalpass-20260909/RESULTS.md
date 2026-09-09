# macOS rendering — final follow-up pass, 2026-09-09

This pass found and fixed three additional issues.

## Fixes

1. **Long-line caret conversions.** Each mouse hit previously encoded the entire string as UTF-16 and decoded its prefix to obtain a Factor index. Caret placement also encoded a prefix repeatedly. Cached lines now lazily store the positions of supplementary Unicode characters, allowing both conversions by binary search. ASCII requires no scan; BMP-only text needs no per-character index entries. The map is reused by selection geometry, and lives with the existing expiring line cache. Native hit-test failure returns a bounded index; an offset inside a surrogate pair maps to the beginning of its code point.
2. **Whitespace backgrounds.** Image bounds alone exclude most whitespace. Nontransparent font backgrounds now include the typographic bounds, so spaces receive their full background instead of a tiny bitmap. Transparent text keeps its ink bounds and antialias guard.
3. **Translucent editor selections.** The editor rectangle and the Core Text image both painted the highlight. With a transparent font background, 50% blue over black became 75% blue (192/255). The macOS GL3 renderer now paints only the portion of the editor highlight outside the text image; the image supplies the highlight inside it. The measured result is 128/255 throughout the text and extra line spacing at both 1× and 2×. Other renderers use the existing rectangle-then-text draw sequence through the new dispatch hook.

## Verification

- Relevant tests pass, with empty test-failure and compiler-error collections. New regressions cover UTF-16 round trips, surrogate interiors, map reuse, whitespace dimensions, selection bands and mirrored/sheared clip transforms.
- The native CGL selection probe checks three vertical positions at each scale and asserts their expected color values.
- GPU cache probes check separate world caches, expiry and deletion of one world's textures while the other remains live, and texture recreation on repaint.
- All five earlier long-line, scale and tall-text pixel comparisons remain byte-for-byte identical.
- The 29 shaping comparisons retain the same results: 23 exact, two differing by at most 1/255, and four oversized accent/Arabic cases with sparse differences up to 4/255. The latter remain an explicit limitation rather than pixel-perfect results.
- Empty/invisible control strings and whitespace were also probed for valid raster dimensions and successful rendering.

## Caret benchmark

Median of three batches of 100 warm hits, including the native Core Text hit test, on 100,000-character strings. The machine had concurrent workloads; these are local directional measurements.

| Text | Previous batch | New batch | Improvement |
| --- | ---: | ---: | ---: |
| ASCII | 2.793 s | 0.422 s | 6.6× |
| BMP Chinese | 13.284 s | 1.830 s | 7.3× |
| Latin with supplementary emoji | 6.976 s | 1.358 s | 5.1× |

Initial native shaping and Core Text's own hit-test cost still depend on line length. The sparse map uses memory proportional to the supplementary characters, and is created only for lines needing caret or selection conversion. The original rendering/reflow benchmark was also rerun successfully; its newer timings were collected under concurrent load and should not be directly compared with the earlier wall-clock measurements.

## Reproduce

```sh
./factor -no-user-init reference/macos-text-finalpass-20260909/test.factor
./factor -no-user-init reference/macos-text-finalpass-20260909/selection-run.factor
./factor -no-user-init reference/macos-text-finalpass-20260909/caret-run.factor
```

`unit-tests.log`, `selection-before.jsonl`, `selection-after.jsonl`, `caret.jsonl` and `long-line-pixel-check.log` retain the results. The complete shaping captures and checker remain in [the shaping audit](../macos-text-shaping-20260909/RESULTS.md). Changes are in source; the application image has not been rebuilt.
