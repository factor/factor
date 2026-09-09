# Windows ARM64 outgoing varargs

Implementation follows Windows's general-register argument stream for every
parameter in a variadic signature, including named float/half/BF16 parameters.
HFA/HVA arguments use ordinary composite layout; composites over 16 bytes are
passed indirectly. A two-word composite can straddle X7 and the native stack.
Return values retain their normal HFA and hidden-pointer rules.

The independent Clang Windows oracle revealed that variadic vector arguments
start at the next eight-byte slot, including X1/X2 after one named integer.
The implementation and incoming callback helpers use this eight-byte alignment.
The retained compiler output records that decision; it is not inferred solely
from the Microsoft prose's imaginary-stack description.

## Evidence

- `windows-before.log`: original committed image, no implementation refresh.
  The independent Windows C mixed-argument function returns 26711503868 instead
  of 285. Only Apple-specific anonymous-stack placement is disabled in this
  baseline, reproducing the old Windows argument allocator.
- `windows-after.log`: eight checks pass against Windows-generated C machine
  code: named and anonymous FP, register/stack spill, small and large HFAs,
  X7/stack composite splitting, HFA result, indirect call, named/anonymous
  half and BF16 across register exhaustion, and short-vector/HVA arguments.
- `test.log`: native macOS stack-checker and CFG suites plus outgoing C and
  scalar-small-float suites pass, including all 131,072 small-float raw results.
- `build-oracle.py` compiles the checked-in C fixture with Clang's Windows
  target, then changes only object-file directives and external symbol spelling
  to package its instructions into a macOS dylib. It excludes the C-only control
  function because that function uses Windows object-format constant sections.
- `windows-run.factor` selects Windows argument lowering and promotions without
  changing the host runtime ABI. This is a cross-ABI execution test on macOS,
  **not native Windows qualification**. The native CI cases use normal platform
  selection, without those overrides.

Run from this worktree with the verified image built before this change:

```
python3 reference/arm64-varargs-outgoing-20260908/build-oracle.py
clang -dynamiclib -O2 vm/ffi_test.c -o libfactor-ffi-test.dylib
/Users/erg/factor.worktrees/arm64-gaps-integration/factor \
  -i=/Users/erg/factor.worktrees/arm64-gaps-integration/verified.image \
  -resource-path=/Users/erg/factor.worktrees/arm64-varargs-outgoing \
  -no-user-init -no-monitors \
  reference/arm64-varargs-outgoing-20260908/windows-before.factor
# Expected exit 1.
# Use windows-run.factor or test.factor instead for passing checks (exit 0).
```

The machine here is Darwin ARM64; no native Windows runner was exercised.
Committed native CI fixtures cover the three target platforms. GCC/MSVC can
build ordinary fixtures; half/BF16 and short-vector/HVA extension cases are
covered in the existing positively gated capable-Clang suite.

Source: https://learn.microsoft.com/en-us/cpp/build/arm64-windows-abi-conventions
