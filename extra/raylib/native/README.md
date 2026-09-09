# Raylib headless native tests

`varargs.factor` and `callback.factor` cover formatted calls and trace callbacks.
`binary.factor` checks binary file ownership, Base64 decoding, PNG round trips,
and WAV samples without opening a window or audio device. `ownership.factor`
checks allocated text raw pointers and copying conveniences, writable text
buffers, static results, and cleanup when copying raises an exception.

`boundaries.factor` uses the independent C oracle `api60.c` against the real
Raylib **6.0** header and library. It checks every offset in ModelSkeleton,
Model, ModelAnimation and AudioStream; fractional animation interpolation;
unsigned AudioCallback counts; and LoadFontData's seventh output parameter.

Build the additional C fixture, for example on macOS:

```sh
cc -Wall -Wextra -Werror -dynamiclib -I /path/to/raylib-6.0/src \
  api60.c -L /path/to/raylib-6.0/src -lraylib -o libraylib-api60.dylib
```

On Linux use `-shared -fPIC` and an `.so` output. Register the resulting library
as `raylib-api60` with `alien.libraries:add-library`, and register the matching
Raylib 6.0 library as `raylib`. Set `RAYLIB_API60_FONT` to the upstream fixture
`examples/text/resources/anonymous_pro_bold.ttf`. After `"raylib" test`, run:

```factor
"resource:extra/raylib/native/binary.factor" run-test-file
"resource:extra/raylib/native/ownership.factor" run-test-file
"resource:extra/raylib/native/boundaries.factor" run-test-file
```

The native boundary suite requires its fixture and font and does not skip
missing dependencies. Its baseline signature guards deliberately prevent
calling an old six-argument LoadFontData declaration or an int-frame animation
declaration: these can corrupt memory. The signature assertion fails instead;
once correct, the same suite executes both real native calls. The C fixture
also supports a standalone control executable; see its source.

These tests qualify representative runtime boundaries. The separate tagged
header inventory covers all declarations; it does not mean all 600 graphics,
audio, platform, and input functions were executed.
