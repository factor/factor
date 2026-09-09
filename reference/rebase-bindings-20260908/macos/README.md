# Native macOS ARM64 integration checks

The replayed source at `2bff152061`, plus the explicitly compiled shuffle
regression committed as `8ec42ef071`, passes the focused native checks below.
The latest SQLite source was also rechecked directly from the root branch
after cherry-picking its completion commits. Every recorded run exited 0.

| Check | Result |
| --- | --- |
| SIMD intrinsic suite, normal extensions | 75 unit tests and 2 expected failures pass |
| SIMD intrinsic suite, extensions disabled | Same 75 + 2 pass |
| Native C varargs controls, Clang 23 | HFA spill, both ABI masks `0xff`, half/BF16 controls pass |
| ARM64 variadic suite, normal and extensions disabled | Both pass; 24 small-float native checks executed in each lane |
| Real `printf` | Exact bytes and return count pass through both entry points |
| Completed SQLite source, native core suite | 9 checks pass |
| Completed SQLite header audit | 364 functions, 523 constants, 46 typedefs, 23 records; zero discrepancies |

`varargs.log`, `simd-normal.log`, `simd-portable.log`, `sqlite-core.log`, and
`sqlite-audit.log` retain the complete outputs. The variadic runner reports
Raylib's optional formatting tests unavailable in its isolated source tree;
those skips are not counted as native Raylib passes. The separate
[Raylib completion run](../../raylib-6-completion-20260908/README.md) requires
and exercises the actual 6.0 library. The
[SQLite completion report](../../sqlite-3534-completion-20260908/README.md)
contains the broader native/layout coverage and pre-fix evidence.

The reused image initially contained old compiled SIMD methods. Reloading only
the compiler emitter does not replace those methods. `refresh.factor` reloads
the emitter, runtime intrinsics, and SIMD vocabulary before saving the isolated
image used by both final SIMD lanes. A preliminary run using the incomplete
refresh was discarded, and no full `.github/arm64-tests.factor` pass is claimed
by this report. The original-emitter failure and corrected-emitter success for
the new compiled regression are recorded in the parent Linux report.

The executable was the verified native ARM64 C++ VM at
`/Users/erg/factor.worktrees/arm64-varargs-entry/Factor.app/Contents/MacOS/factor`.
The starting compatible image was
`/Users/erg/factor/reference/arm64-varargs-20260908/final.image`.
The source and saved integration images were isolated in
`/Users/erg/factor.worktrees/bindings-on-agent1-20260908`.
The root production executable and image were not replaced.

## Reproduction

Using a compatible executable/image and this source tree, refresh the SIMD
vocabularies as in `refresh.factor`, choosing an isolated output image path.
Then run:

```sh
/path/to/factor -i=/path/to/refreshed.image -resource-path="$PWD" \
  -no-user-init -no-monitors reference/rebase-bindings-20260908/macos/simd.factor
/path/to/factor -i=/path/to/refreshed.image -resource-path="$PWD" \
  -no-user-init -no-monitors -disable-neon-extensions \
  reference/rebase-bindings-20260908/macos/simd.factor
python3 .github/check-arm64-varargs.py --cc /path/to/clang --require-small \
  --factor /path/to/factor --image /path/to/refreshed.image
python3 reference/sqlite-3534-completion-20260908/run-core.py \
  --vm /path/to/factor --image /path/to/refreshed.image \
  --library /tmp/sqlite-3534-vfs/libsqlite3-optional.dylib
python3 reference/sqlite-3534-completion-20260908/header-audit.py \
  --output /tmp/sqlite-rebased-header-audit
```

The SQLite library is the pinned 3.53.4 build with the optional features and
native fixture enabled, built as documented in its completion report. The
focused ABI runner compiles its own C fixture with Clang and runs both extension
lanes plus the real-printf check. No generated executables or images are committed.
