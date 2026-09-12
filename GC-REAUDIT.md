# GC re-audit — 2026-09-11

Follow-up: the [profiler issue audit](PROFILER-ISSUES-AUDIT.md) subsequently
exposed a compiler safepoint bug under sampling-triggered collection. That
failure, its fix, and the required image recompilation are documented there.

Reviewed nursery and aging collection, promotion retries, full marking and
sweeping, data/code compaction, heap growth, remembered cards, native root
lifetimes, callstack/derived roots, and compiler GC maps/write barriers.
The audit covered the C++ VM used by the local server and corresponding Zig
paths. Runtime tests used separate processes.

The collection paths tested on Linux x86.64 passed. Three inconsistencies were
found around `become`, the operation used for tuple reshaping and object
coalescing, which shares GC's pointer traversal machinery.

## Fixed

### Zig: current-context roots were replaced twice

`primitive_become` visited the current context explicitly, then again through
the active-context list. With simultaneous replacements `A -> B` and `B -> C`,
an A on the current data stack incorrectly became C, while an A in a heap slot
became B. Skip the current context in the second traversal.

The regression creates three distinct objects, performs both replacements in
one operation, and checks the result on the stack. It failed with marker 3
before the fix and passes with marker 2 afterwards.

### Zig: recorded profiler roots were omitted

Normal Zig collection traces the thread objects retained in native profiler
sample records. `become` omitted those roots, leaving the sample referring to
A after other references had been replaced with B. Visit each sample's thread
slot along with the other roots.

The regression failed with marker 1 before the fix and passes with marker 2.
Both regressions include the nursery collection performed by `become`.
These two fixes are committed as `8f26995685`. The C++ root visitor already
handles these cases correctly.

### C++: rewritten instructions lacked an instruction-cache flush

`primitive_become` rewrote embedded literals in compiled code without flushing
the instruction cache. The normal collector and the Zig implementation already
flush after such writes. Flush each changed code block before returning to
Factor execution (`4dc094a020`).

The added Factor regression compiles and executes a literal quotation before
replacement, then checks the new result immediately and after nursery, full,
and compacting collection. It passes on Linux x86.64. The missing flush was
identified by code inspection: x86's flush helper is a no-op, so this machine
cannot reproduce the stale-instruction behavior relevant to ARM.
The Linux ARM64 helper uses the compiler's
[instruction-cache flush builtin](https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html#index-__builtin___clear_cache),
whose contract covers publishing modified executable memory on targets that
require cache maintenance.

## Verification

* Native GC tests and all eight Unix signal regression groups pass.
* 234 Factor checks pass across `memory`, `arrays`, `byte-arrays`, `strings`,
  `math.bignums`, `compiler.cfg.gc-checks`, `compiler.cfg.write-barrier`,
  `compiler.codegen.gc-maps`, and `tools.profiler.sampling`. The memory suite
  ran with 1 MiB nursery and aging settings, including its long tests for
  retained objects, large allocations, and deep-stack collection. The complete
  pre-fix suite also passed with those small-generation settings.
* Zig 0.16.0: 74 tests pass, one is skipped. The two new root regressions fail
  against the old implementation and pass with the fixes.
* All six `vm/tests/stack_safety.py` tests pass with the rebuilt C++ VM,
  including hundreds of isolated probes around the measured 4,067-frame
  callstack limit, all three GC entry points, repeated overflow recovery,
  and repeated continuation tests.

The rebuilt C++ binary is prepared for the next restart. Its predecessor is
backed up with SHA-256 checksums in:

```
/tmp/factor-before-gc-reaudit-20260911T233656Z-dpyedi0n/
```

The existing image is compatible with these changes; no Factor production
definitions or image format changed in this audit.

The repository requires Zig 0.16.0 in `build.zig.zon`. The default local Zig
0.15.1 failed to compile the unchanged baseline. A separate temporary 0.16.0
toolchain was downloaded and verified against the SHA-256 checksum in the
[official release manifest](https://ziglang.org/download/index.json).

## Limits

Passing these tests does not establish that every possible heap graph or
collection failure is correct. ARM/macOS execution and instruction-cache
behavior were not tested on hardware here. The Zig fixes were unit-tested;
they do not change the C++ VM currently serving the website. No server process
was restarted or sent test signals.
