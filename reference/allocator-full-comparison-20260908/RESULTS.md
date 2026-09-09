# Full allocator implementation and comparison

The three alternative allocators now implement distinct allocation mechanisms and
pass the final correctness gates. Linear scan remains the default. These are
Factor implementations of LLVM-style greedy, SSA bundle backtracking and
decoupled SSA chordal coloring, with their documented target boundaries; they
are not complete ports of every LLVM or regalloc2 target facility.

The [mechanism audit](AUDIT.md) describes the actual algorithms and independent
witness checks. The [merged compiler acceptance](../allocator-full-master-integration-20260908/README.md)
records full compiler tests against the newer master-candidate VM and image.
All four frozen allocator closures pass the strengthened verifier and all 26
output oracles on both native architectures. Both revisions pass the guarded
C ABI callback tests across all four allocators with rematerialization off/on.
Generated CFG, spill/reload, phi, ABI-slot and moving-GC regressions are retained.

## Native x86-64 result

Relative to final linear scan, across 26 equally weighted workload medians:

| Allocator | Runtime CPU | Runtime retired instructions | Compiler CPU |
| --- | ---: | ---: | ---: |
| Linear scan | 1.0000 | 1.0000 | 1.0000 |
| Greedy | 1.0247 | 1.0144 | 1.0306 |
| Backtracking | 1.0146 | 1.0222 | 1.1892 |
| Chordal | 1.0530 | 1.0774 | 1.2913 |

Lower is better. All three alternatives also have higher aggregate runtime CPU
in each separate round. Small differences on this shared host do not establish
statistical significance. See the [complete x86 report](native-x86-64/final-matrix/README.md)
for each allocator versus its repaired prototype, per-workload results, source
and image hashes, raw records and rematerialization attribution.

Both revisions use rematerialization on, loop spills on and GVN off for the
main matrix. Separate final-linear-scan off/on runs do not establish a reliable
broad runtime benefit from rematerialization. It remains disabled by default.
Runtime has six timed samples per workload and allocator; compiler cost has two
whole-closure observations per allocator. Timing uses the same frozen ordered
compiler/benchmark closure across allocators
within each revision; prototype comparisons also include added compiler helpers.

## Native ARM64 result

On the Apple M5 Max, recorded final-allocator ratios versus linear scan were:

| Allocator | Runtime CPU | Runtime retired instructions | Compiler CPU | Compiler retired instructions |
| --- | ---: | ---: | ---: | ---: |
| Linear scan | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| Greedy | 1.0037 | 1.0089 | 0.8352 | 1.0479 |
| Backtracking | 0.8031 | 1.0269 | 0.7816 | 1.3239 |
| Chordal | 1.2168 | 1.0956 | 1.1888 | 1.3409 |

**The apparent backtracking CPU win is not reliable promotion evidence.** Host
load ranged from 29.45 to 64.12. The unchanged baseline chordal compilation's
execution rate fell from 14.86 to 7.93 billion instructions per CPU second
between rounds; candidate backtracking fell from 18.91 to 12.46. Backtracking's
runtime CPU ratios versus linear scan were 0.7002 and 0.8449, while its retired
ratios were stable at 1.0270 and 1.0271. Greedy's CPU direction reversed between
rounds (1.0630 and 0.9261). These changing execution rates confound an inference
that the allocator caused the recorded time reduction. The raw observations
remain reported rather than discarded.

The [complete ARM report](native-arm64/final-matrix/README.md) includes separate
prototype comparisons, rematerialization attribution and every run. Its final
closure contains 27,296 words. Each architecture accepted 16 main timing
processes, two attribution processes and eight checked processes: 1,404 measured
runtime batches and 208 checked outputs, plus the independent callback gate.

## Default and bootstrap decision

Keep linear scan, GVN off and rematerialization off as defaults. The alternative
algorithms are available for explicit comparison; none has established a broad
repeatable runtime improvement over linear scan on both architectures. Further
tuning should address the measured cases below and use a more stable ARM host.

The merged source also cold-bootstraps and its fresh saved image passes default
selection, zero-compiler-error and arithmetic/loop/moving-GC checks. Its core
time is **2:12** (135.63 seconds whole process), so the requested under-two-minute
budget remains **unmet**. This uses the current root VM and boot seed in an
isolated worktree; the root image is unchanged. It is not a matched source-only
comparison to the older frozen VM's 3:11 result. Exact records are in the
[merged acceptance report](../allocator-full-master-integration-20260908/README.md).

## What the measurements suggest next

Greedy's integer-pressure case retains 29 reloads, 232 spill-slot bytes and 29
local splits versus its prototype, while stores rise from 29 to 57 and actual
code grows from 688 to 864 bytes. Runtime CPU rises 21.45% and retired work
15.77%. The unconditional trailing spill in `apply-local-split` is a concrete
candidate for investigating stores after a fragment's last use. Exact attribution
of the additional stores requires instruction-level provenance; this is a tuning
hypothesis, not a demonstrated correctness defect or an implemented improvement.

Backtracking reduces the twelve x86 diagnostic kernels' total spill-slot storage
from linear scan's 3,480 bytes to 1,776, and code from 42,976 to 42,432 bytes,
but increases aggregate runtime work and compiler cost. Its FFI-pressure
transport and allocation-query costs merit attention. Chordal's pressure and
coalescing decisions likewise need measured tuning before promotion.

Static copy/spill/reload counts describe final machine IR. An equal-register
`##copy` can emit zero machine instructions on x86, so the reported 358 chordal
copies do not imply 358 emitted machine moves. Code-byte measurements are actual
generated bytes. Neither fewer spill slots nor fewer bytes alone proves faster
execution.

## Selecting an allocator

Load its vocabulary and dynamically bind `register-allocator` around compilation,
for example:

```factor
USING: compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.greedy math namespaces prettyprint ;
greedy-allocator register-allocator
[ [ + ] measure-compilation . ] with-variable
```

The other objects are `linear-scan-allocator`, `backtracking-allocator` and
`chordal-allocator`; load the matching allocator vocabulary for the alternatives.
The binding affects new compilation. Existing compiled words must be recompiled
under that binding to compare their runtime. The benchmark harness deliberately
recompiles the full frozen closure, including compiler helpers.
