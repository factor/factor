# Windows incoming variadic callback execution oracle

`build.py` compiles independent C callers using Clang's Windows ARM64 ABI.
It repackages those instructions into Mach-O, rewriting only object directives,
constant-symbol spelling, and page-relative relocation syntax. Tests execute
those C callers against Factor's Windows parameter reader on the macOS CPU.
This does not qualify the Windows operating-system runtime or TEB handling.

`overrides.factor` selects Windows named-argument allocation, boxed argument
conversion, cursor construction and native-list forwarding while retaining
macOS's native callback entry frame. It also installs the corrected callback
metadata order, needed with the first candidate image. `before-overrides.factor`
retains the erroneous property order to reproduce the actual missing-capture
failure; the named FP values decode correctly, but the anonymous cursor reads
unrelated memory because the ordinary stub was selected.

Seven tests pass (`after.log`): named FP plus runtime cursor, declared tail,
named pair plus indirect HFA, GP exhaustion followed by stack arguments,
indirect aggregate return with GC, repeat forwarding to a Windows C native
`va_list` consumer without advancing the original cursor, and named stack
arguments followed by a declared variadic tail. The metadata-negative control
fails (`before.log`). Both runners require the root candidate image and the
updated entry runtime, as recorded in `run.factor`'s invocation below:

```
python3 reference/arm64-varargs-outgoing-20260908/incoming/build.py
/Users/erg/factor.worktrees/arm64-varargs-entry/factor \
  -i=/Users/erg/factor/reference/arm64-varargs-20260908/candidate.image \
  -resource-path=/Users/erg/factor -no-user-init -no-monitors \
  reference/arm64-varargs-outgoing-20260908/incoming/run.factor
```

Use `before.factor` for the expected failure. The vector callback case is kept
separately in `vector.factor`: it exposed an optimizing-compiler recursion
error for the `float-4` reader, reported to the cursor implementation owner.
The boxing fix removes that compile error (`vector-before.log`), but the C caller
also misclassifies its anonymous vector in V0 instead of X1/X2. The result then
fails semantically (`vector-after.log`); it is not counted as passing coverage.

## Independent Clang caller defect

`incoming_split` passes seven named integers followed by a two-double aggregate.
Both Apple Clang 21 and upstream Clang 23 place the entire aggregate on the stack
and leave X7 unused. Their own `va_arg` implementation consumes saved X7 and the
first stack slot as that aggregate. This fails without any Factor callback:

```
python3 reference/arm64-varargs-outgoing-20260908/incoming/compiler-control.py
# Expected mathematical sum: 385. Observed C-only result: 302.0.
```

`compiler-split-defect.log` and both Windows assembly files retain this evidence.
The passing incoming GP exhaustion test uses an aggregate occupying X6/X7 and a
following stack value, avoiding that compiler defect. Outgoing Factor's X7/stack
split is separately verified against the Windows C `va_arg` reader in the parent
directory. Do not treat this C caller inconsistency as a successful semantic
callback test or change the cursor to silently match the broken caller.

The composite caller defect persists at `-O0`, `-O1`, `-O2`, `-Os`, and
`-fclang-abi-compat=18` on Apple Clang 21, and at `-O2` on upstream Clang 23.
No tested compiler flag repairs it. The outgoing fixture therefore separates
its non-inlined C-only control for the supported mixed/HFA cases (570) from
`varout_split_control` (317). The latter remains required with supported C
callers, including MSVC, while Clang Windows emits an explicit diagnostic.
The Factor-to-C split assertion remains required on every platform. This
isolates a known C caller defect without disabling the Factor ABI regression.
