# Raylib release comparison — 2026-09-08

Latest stable upstream release: **6.0**, released 2026-04-23. The local binding
also declares 6.0. This comparison uses tag `6.0`, commit
`dbc56a87da87d973a9c5baa4e7438a9d20121d28`, not upstream master.

Sources:
- [Latest release](https://github.com/raysan5/raylib/releases/latest)
- [6.0 header](https://github.com/raysan5/raylib/blob/6.0/src/raylib.h)
- [5.5 header](https://github.com/raysan5/raylib/blob/5.5/src/raylib.h)
- Local `extra/raylib/raylib.factor`, after the variadic cleanup.

## Coverage

| Item | Comparison |
| --- | --- |
| Exported functions | All 600 names present; no extra exported function names |
| Structs | All 35 present; field order and ABI type shapes match after aliases/pointers are normalized |
| Enum members | 304 of 305 present; all represented numeric values match |
| Color constants | All 26 values match |
| Callback declarations | All 6 present; one signedness mismatch |

This is a source-level declaration comparison. Matching struct field shapes is
not a new platform-specific sizeof/offsetof or runtime ABI qualification.
The helper accepts pointer stars attached to Factor parameter names, as the
real Factor parser does; these are not incorrectly counted as missing pointers.

## Changes needed

Two function signatures still reflect 5.5 rather than 6.0:

- **LoadFontData**: the 6.0 function has a seventh `int *glyphCount` output
  parameter. The binding has only six parameters. Its binary `fileData` parameter
  is also declared as `c-string` rather than `uchar*`.
- **UpdateModelAnimation**: 6.0 takes `float frame`; the binding still uses `int`.
  This changes argument transport on ARM64, as well as value interpretation.

Seven additional pointer/string discrepancies bring the function-signature
inventory to **nine entries**:

- `LoadFileData` returns binary `unsigned char*`, currently copied as a string;
  `UnloadFileData` likewise takes that raw allocation, currently `c-string`.
- `LoadImageFromMemory`, `LoadFontFromMemory`, `LoadWaveFromMemory`, and
  `LoadMusicStreamFromMemory` declare binary data buffers as `c-string`.
- `DecodeDataBase64` expects `const char*` encoded input; the binding uses
  `uchar*`. This is pointer-ABI compatible but differs in conversion behavior.

Other gaps:

- `AudioCallback.frames` is `unsigned int` in C, but `int` locally.
- `FLAG_WINDOW_MOUSE_PASSTHROUGH = 0x00004000` is missing. It was already in 5.5.
- The named `ModelAnimPose` typedef is absent. Current struct fields use
  ABI-equivalent `Transform**` or opaque pointers; this is not a layout defect.
- Several allocated text results (for example `LoadFileText`, `LoadUTF8`, and
  `EncodeDataBase64`) are copied to Factor strings, losing the ownership-bearing
  pointer needed by the corresponding release function. The JSON also lists
  other mutable string returns for review; some use static storage and must not
  be treated as allocations merely because their return type is `char*`.

Model/ModelSkeleton and AudioStream use some `void*` fields where the header
names a concrete pointee type. These preserve pointer layout and are reported
separately from the function errors. Existing ARRAY-SLOT helpers intentionally
handle several of those fields.

The inventory compares public functions, callback signatures, struct field
shapes, enums, and colors. Preprocessor implementation macros, mathematical
convenience macros, and deprecated mouse-button macro aliases are not included
in the completeness totals. Const qualifiers and enum-to-int mappings are
normalized; ownership is reviewed separately.

## Reproduction

```sh
git clone --depth 1 --branch 6.0 https://github.com/raysan5/raylib.git /tmp/raylib-6.0
python3 reference/library-release-comparison-20260908/raylib/compare.py \
  /tmp/raylib-6.0 /path/to/factor > comparison.json
```

The tagged upstream parser inventory contains malformed JSON descriptions and a
pointer typedef emitted as `*ModelAnimPose`. The comparison discards description
text, reads pointer typedefs from the actual header, and independently checks
all exported function names and normalized signatures against that header. `comparison.json` retains the
header SHA-256 and raw declaration discrepancies. No binding upgrade is made
by this comparison.
