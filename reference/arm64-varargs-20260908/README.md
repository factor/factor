# ARM64 variadic FFI regression evidence

Baseline: `233db947df`. Tests use independent ordinary C callers and C `va_arg`
readers in `vm/ffi_test_varargs.c`. The fixture is included by the existing FFI
shared library; it can also be compiled alone as a control executable:

```sh
clang -std=c11 -Wall -Wextra -Werror -O2 \
  -DFACTOR_VARARGS_CONTROL_MAIN vm/ffi_test_varargs.c -o /tmp/varargs-controls
/tmp/varargs-controls
```

On macOS ARM64 both Apple Clang and Homebrew Clang 23 pass all eight general
C controls (`0xff`). Half/BF16 controls also pass with capable Clang. A capability
query is provided separately; required CI lanes must assert it is nonzero.

`callback-before.log` records the unchanged image/source failing to load the new
suite because `alien.varargs` does not exist. `parser-before.log` independently
records terminal-ellipsis `CALLBACK:` rejected by
`varargs-in-function-declaration`. These are actual baseline failures, not tests
that expect the old behavior in the permanent suite.

`basis/compiler/tests/alien-varargs.factor` dispatches the new native ARM64 tests.
Its cases cover genuine zero-anonymous-argument calls, dynamic counts, named and
anonymous register/stack exhaustion, typed-tail promotion, aggregates, HFA and
indirect returns, GC/nested callbacks, cursor copying and expiry, borrowed native
lists, and repeated/partially consumed forwarding to C and real `vsnprintf`.
Real `snprintf` checks include formatting bytes, count, truncation, and size zero.

The stdout test is deliberately isolated in a subprocess:

```sh
python3 reference/arm64-varargs-20260908/check-printf.py \
  --factor /path/to/factor --image /path/to/verified.image --root /path/to/factor
```

It calls the real C `printf` with promoted narrow integer/float, dynamic width
and precision, string, and 64-bit integer parameters; verifies the native return
count; flushes; then checks exact subprocess bytes. All platforms call the
actual standard function through its address supplied by C. Unix additionally
checks direct named-symbol calls for `printf` and `snprintf`. Windows UCRT moved
these functions inline into its SDK headers, so their addresses provide the
real CRT implementation without assuming legacy DLL exports. See
[Microsoft's CRT change history](https://learn.microsoft.com/en-us/cpp/porting/visual-cpp-change-history-2003-2015). This already passes on the
baseline macOS image, and is a retained outgoing-varargs control.

## Compiler qualification

Homebrew Clang 23 at `-O0` currently miscompiles the mixed half/BF16 C-only
variadic caller on macOS: anonymous arguments are stored with `strh` in stack
slots while its `va_arg` reader reads promoted doubles, yielding NaN. At `-O2`
the caller stores the required doubles and the same independent controls pass.
Use the optimized fixture build (the project already builds this library with
optimization). The small-float C-only control intentionally fails if this
compiler defect is triggered; it does not silently skip or blame Factor.

Native Linux and Windows execution is still required for platform qualification.

## Integrated formatting verification

`printf-after.log` records both real printf entry points passing against the
integrated callback VM and `current.image`, using the merged repository source
and freshly rebuilt shared FFI fixture. The native standalone C controls were
also rebuilt from that integrated source and passed the general mask, HFA spill,
and half/BF16 checks. Incoming Factor callback completion is recorded by the
integration runner separately; this formatting check alone does not claim it.

## Failure propagation controls

`negative-controls/SUMMARY.txt` records six independently verified failures,
each exiting **1** with its expected diagnostic:

- The real compiler-qualified CI helper and runner report an injected Factor
  test failure. Only the runner's test workload is replaced in the overlay;
  native C coverage and the runner's final status logic remain unchanged.
- Omitting the C variadic fixture from the rebuilt shared library fails on
  missing `va_c_controls`, even though separately built C controls pass.
- A zero small-float capability fails the required-capability lane instead of
  silently skipping it.
- The printf harness rejects a deliberately incorrect expected native return
  count, incorrect subprocess bytes, and a nonzero child process exit despite
  correct bytes.

Reproduce on the native macOS ARM64 host:

```sh
python3 reference/arm64-varargs-20260908/check-negative-controls.py \
  --root /path/to/factor --factor /path/to/verified/factor \
  --image /path/to/current.image --cc /path/to/clang \
  --output /tmp/varargs-negative-evidence
```

The script makes temporary source overlays, copies edited files before writing,
and removes the output library symlink before invoking the real CI helper.
Recorded SHA-256 values confirm that the root fixture sources and library did
not change during the final run. An earlier exploratory run overlapped ongoing
integration edits; its mixed diagnostics were replaced by the isolated final
controls rather than used as evidence.
