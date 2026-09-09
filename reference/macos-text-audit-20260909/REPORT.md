# macOS text rendering audit — 2026-09-09

The Core Text → Core Graphics bitmap → OpenGL 3 path has four reproduced rendering defects. The highest priority is incorrect blending of premultiplied text images. Integer-position texture sampling itself preserved pixels exactly when the blend factor was corrected in the probe.

Scope: macOS only. No production source files were changed. Windows work is outside this audit.

Environment: macOS 26.6.2 (25G83), Apple Silicon; repository HEAD `8780b3c0908ba06be2720c5ac0949e3c68b871e4`. Tests use the local Factor executable, actual Core Text rasterization, the repository's GL3 texture upload/draw functions, and an offscreen CGL framebuffer. The 1×/2× cases set the font backing scale explicitly; they are not physical monitor-migration tests.

## 1. P1 — GL3 multiplies premultiplied text color by alpha again

Evidence: [bitmap creation](/Users/erg/factor/basis/core-graphics/core-graphics.factor:169), [frame blend setup](/Users/erg/factor/basis/ui/render/render.factor:740), [text draw](/Users/erg/factor/basis/ui/text/text.factor:73), [texture draw](/Users/erg/factor/basis/ui/render/render.factor:813).

Core Graphics uses premultiplied alpha and marks the resulting image accordingly. The GL3 text path uploads that image, but its draw function receives no alpha-convention information. The active blend mode uses `GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA`; the texture shader returns the sampled color unchanged. Unlike the legacy texture path, GL3 never selects the premultiplied blend factor for this image.

For white text with coverage `a` over black, the desired RGB is `a`; the current result is approximately `a²`. This affects antialiased edges on transparent backgrounds, partially transparent content, and color glyphs. Fully opaque baked text/background pixels do not have this particular RGB error.

Reproduction: `Hamburgefontsiv AV fi é 日本語`, default sans-serif, white on transparent, drawn over black.

| Backing scale | Partially covered pixels | Pixels darkened by current blend | Maximum RGB error |
| --- | ---: | ---: | ---: |
| 1× | 933 | 933 | 64/255 |
| 2× | 1,918 | 1,918 | 64/255 |

Changing only the source blend factor to `GL_ONE` in the probe produced zero RGB error against the source white-text bitmap at integer placement. This reference isolates compositing; it is not an AppKit screenshot or a color-management reference.

Recommended fix: honor image alpha representation in both direct GL3 text drawing and cached texture drawing, then restore the blend state needed by subsequent primitives. Do not change the blend mode globally: other image sources can use straight alpha. If destination alpha matters, also review separate RGB/alpha blend factors.

## 2. P2 — Tight glyph bounds clip antialias coverage

Evidence: [bounds and surface allocation](/Users/erg/factor/basis/core-text/core-text.factor:137).

The raster origin is the floor of `CTLineGetImageBounds`; only the extent receives an extra pixel. There is no guard pixel before the minimum x/y bounds. Apple's installed `CTLine.h` explicitly distinguishes ideal glyph bounds from raster coverage. The [API documentation](https://developer.apple.com/documentation/coretext/ctlinegetimagebounds(_:_:)) identifies this as image-bound measurement.

Reproduction: italic default sans-serif at 2×, `jfy Ág é ạ́ 日本語`. Rendering the same CTLine with the same integer phase into a surface padded by 16 pixels revealed three nonzero pixels outside the normal crop, all at x = −1, with alpha values 22, 26, and 2. Every pixel inside the normal crop matched exactly. The emoji sample had no clipped pixels.

Recommended fix: include a raster guard band on all sides and adjust the returned image origin with it. Verify overhangs, combining marks, fallback fonts, and emoji against larger reference surfaces. A single passing font is insufficient to establish a universal padding amount.

## 3. P2 — Selection backgrounds are constrained to glyph ink

Evidence: [selection rectangle](/Users/erg/factor/basis/core-text/core-text.factor:86), [selection fill into the glyph-sized surface](/Users/erg/factor/basis/core-text/core-text.factor:158).

The surface is sized from glyph image bounds, while selection spans are computed from typographic offsets. Whitespace has advance width without corresponding ink, so its selection background is clipped away.

Reproduction: selecting all five spaces at 2× produces a **2 × 1 pixel image** for a line whose logical layout in device units is **38 × 29 pixels**. Trailing-space selection has the same structural problem. This finding concerns the `selection` rendering API; editors that paint their own selection rectangles separately need separate checks.

Recommended fix: draw selection geometry separately from glyph textures, or allocate the union of glyph coverage and selection bounds. Preserve the intended line-height background extent.

## 4. P2 — Long lines silently lose their rasterized tail

Evidence: [surface clamp](/Users/erg/factor/basis/core-text/core-text.factor:126).

`max-layout-dim` caps the bitmap extent without tiling or changing the line's measured width. The code avoids excessive surface sizes by discarding the rest of the rendering.

Reproduction: 3,000 `W` characters at 2× measure **61,594 device pixels wide**, while the bitmap is **16,384 pixels wide**. Scrolling the resulting texture cannot reveal the omitted tail.

Recommended fix: rasterize visible spans or tiles, preserving shaping context across tile boundaries. Do not simply remove the cap and rely on arbitrarily large allocations.

## Pixel alignment, antialiasing, and subpixels

The sampled white glyphs contain intermediate alpha values, so antialiasing is active. Their RGB channels are equal at both scales: these captures use grayscale coverage, not RGB subpixel antialiasing. This observation is specific to the tested bitmap contexts and OS; it does not claim that every font/context has identical behavior.

Subpixel glyph positioning is distinct from RGB subpixel antialiasing. [Apple documents fractional glyph positioning as its own control](https://developer.apple.com/documentation/coregraphics/cgcontext/setshouldsubpixelpositionfonts(_:)). The current bitmap setup does not explicitly configure antialiasing, font smoothing, subpixel positioning, or subpixel quantization. `CGContextSetShouldSmoothFonts` is bound but unused here. Do not infer that these features are disabled merely because their setters are not called.

GL3 uses linear texture filtering. At integer device-pixel placement and matching texture/draw size, the probe preserved every source RGB value with correct blending. At a half-device-pixel translation, 1,266 pixels changed at 1× and 2,820 at 2×. Rerasterizing Core Text at the corresponding half-pixel position produced a different result from filtering the cached bitmap: 1,269 and 2,834 differing RGB pixels respectively.

The cache includes backing scale but not the final fractional draw origin. The renderer accepts fractional transforms without snapping the final accumulated text origin. Many layout paths already round positions; this is a conditional quality limitation, not evidence that all text is blurred.

For crisp static UI text, snap the final text origin in device pixels while preserving Core Text's internal glyph advances. If fractional motion/placement is required, treat rerasterization phase as part of the rasterization policy and cache key. Switching everything to nearest filtering would cause its own stepping artifacts.

## Checks that passed and remaining limits

- Existing `core-text`, `core-graphics`, `ui.text`, and `ui.backend.cocoa.views` tests passed. They cover basic metrics, offsets, object creation, and scale-cache/layout handling, but do not catch these pixel defects.
- Font size and line cache keys account for backing scale. Cocoa requests high-resolution OpenGL surfaces, selects scale with the window context, and clears window textures/recomputes layout after backing changes. These mechanisms are already implemented.
- Padded emoji rendering matched the original crop exactly; the tested crop lost no emoji pixels.
- GL calls in the probe completed without reported errors.
- GL3 recreates/uploads/deletes each text texture on every draw despite caching CPU bitmaps. This is a performance concern, not a measured pixel defect; no frame-time claim is made here.
- End-to-end display color management, AppKit parity, live mixed-monitor migration, every script/font, and animated gadget placement were not certified by this audit. DeviceRGB bitmap creation and raw GL upload warrant separate color-space tests before claiming display-level pixel equivalence.

## Reproduction and artifacts

From the repository root:

```sh
./factor -no-user-init reference/macos-text-audit-20260909/probe.factor > reference/macos-text-audit-20260909/probe.jsonl
python3 reference/macos-text-audit-20260909/analyze.py
```

The analysis script uses Pillow for the contact sheet. Core Graphics source captures are native little-endian BGRA; GL readbacks are bottom-up RGBA. The script normalizes their row orientation for comparison.

- [Probe source](probe.factor)
- [Analysis source](analyze.py)
- [Measured results](results.json)
- [3× nearest-neighbor pixel comparison](comparison.png)

Comparison rows: `current` uses the production blend factors; `reference` changes only the source factor to `GL_ONE`; `half-pixel` shifts that corrected texture by 0.5 device pixel; `native-phase` rerasterizes Core Text at the same fractional position before drawing at an integer origin.
