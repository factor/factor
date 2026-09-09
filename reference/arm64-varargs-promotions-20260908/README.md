# Default argument promotion regressions

Native macOS ARM64, Apple Clang 21.0.0. Independent C callees and C-only
controls are in `vm/ffi_test_varargs_promotions.c`; permanent compiled FFI
tests are in `basis/compiler/tests/alien-varargs-promotions.factor`.

The 18 tests produced **15 failures and 3 passing controls before the
repair**, then **18 passes and zero compiler errors afterward**. Logs are
`before.log` and `after.log`; their final two counters are test failures and
compiler errors. The baseline used the integration `current.image` with the
original promotion helper. The after run reloaded `alien.c-types.varargs`
from the repaired source before defining and compiling the same tests.

Coverage includes direct and indirect calls, Factor boolean conversion,
signed/unsigned integer source-width conversion, narrow enum words and
numeric values, poisoned outgoing stack slots exposing incomplete enum
stores, binary32 rounding before double promotion, and native C calls to
both runtime and declared-tail callbacks. Callback tests retain the actual
values and verify promoted integer boxing outside the callback, so baseline
failures do not escape through C.

The standalone fixture was built with:

```sh
clang -O2 -dynamiclib vm/ffi_test_varargs_promotions.c -o libfactor-ffi-test.dylib
```

Integration must include this C file from `vm/ffi_test.c` and run the Factor
test file with the normal FFI suite. The C fixture is portable to the native
Linux and Windows lanes; those executions remain part of integration
qualification rather than the macOS evidence recorded here.
