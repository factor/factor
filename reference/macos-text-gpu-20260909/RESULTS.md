# Cached macOS text drawing, 2026-09-09

Follow-up to `6f05c93842`, tested on macOS Apple Silicon with native CGL
OpenGL 3.2 and a 1024 × 2048 RGBA8 framebuffer. Source vocabularies were
explicitly refreshed; the application image was not rebuilt.

## Changes

- Retain one VAO and static 96-byte VBO per cached text tile instead of
  retaining CPU vertices and uploading them on every repaint. Cache expiry
  and disposal delete the VAO, VBO, and texture.
- Set texture uniforms and restore color state once per line's visible tiles.
  Fully clipped lines skip this GL setup.
- Reuse the texture projection within a frame, invalidating it at reshape
  even when dimensions are unchanged so a new context gets an upload.
- Specialize modelview translation to update the last matrix column. Clone
  the input to preserve nested matrix stacks and retain the old float32 input
  rounding; the small conversion allocation is intentional and documented.

A VAO retains attribute format and buffer bindings, as specified in the
[Khronos glVertexAttribPointer reference](https://wikis.khronos.org/opengl/GlVertexAttribPointer).
Tile VAOs belong to the existing per-world text cache.

## Paired warm-drawing measurements

`paired.factor` reproduces the committed dynamic upload/uniform/translation
path and compares it with the new production path in the same context.
Five pairs alternate execution order; the table uses each mode's median.
Vertex data for the old path is read from the static buffers before timing.
Each measurement finishes with `glFinish`. Both modes use warmed text caches.

| Workload | Previous | Updated | Time reduction |
| --- | ---: | ---: | ---: |
| 100 lines, 100 repaints | 124.14 ms | 91.61 ms | 26.2% |
| Visible portion of a 10,000-character line, 1,000 repaints | 29.34 ms | 19.09 ms | 35.0% |

That is approximately 0.916 ms per 100-line repaint and 19.1 microseconds
per long-line repaint in this fixture. Raw alternating samples are in
`paired.jsonl`. These measure warm drawing in an offscreen fixture, not
complete editor frame latency or cold shaping/rasterization. Machine load
affects absolute timings.

## Validation

- Both paired framebuffer captures are byte-for-byte identical (8,388,608
  bytes per case); `compare.py` asserts this.
- The original five long-line, tall-tile, and selection comparisons are exact.
- The 29-case shaping corpus remains unchanged: 23 exact, two at most 1/255,
  and four oversized accent/Arabic cases at most 4/255 (integer origin) or
  2/255 (fractional origin). The existing native rasterization discrepancy
  remains; this pass does not claim universal pixel equality.
- Translucent selection coverage is applied once at 1× and 2×, including
  line leading. Cache isolation, expiry, recreation, and deletion of all GPU
  object types pass. Projection reset at the same dimensions and resize pass.
  The cache isolation fixture uses two world caches in one native context;
  it does not exercise switching between two native window contexts.
- Unit tests pass for `ui.render`, `core-text`, `core-graphics`, `ui.text`,
  `ui.text.core-text`, `ui.gadgets.line-support`, `ui.gadgets.editors`,
  `ui.backend.cocoa.views`, and `opengl.textures`. The runner asserts empty
  test failures and compiler errors. No automatic import restarts occurred.
- Translation tests compare against the previous full matrix multiplication
  for identity, rotated, and general matrices with fractional/large offsets,
  and assert that the input matrix remains unchanged.

## Reproduce

From the repository root:

```sh
./factor -no-user-init reference/macos-text-gpu-20260909/test.factor
./factor -no-user-init reference/macos-text-gpu-20260909/paired-run.factor
python3 reference/macos-text-gpu-20260909/compare.py
./factor -no-user-init reference/macos-text-gpu-20260909/lifetime-run.factor
./factor -no-user-init reference/macos-text-shaping-20260909/run.factor > reference/macos-text-shaping-20260909/results.jsonl
python3 reference/macos-text-shaping-20260909/compare.py
./factor -no-user-init reference/macos-text-optimization-20260909/run.factor > reference/macos-text-optimization-20260909/results.jsonl
python3 reference/macos-text-optimization-20260909/compare.py
```

The shaping comparison requires NumPy. Generated pixel captures are ignored.
