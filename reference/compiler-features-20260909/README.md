# GVN and rematerialization verification

Production source: `ad0fc337de5ce51816f8251fa490f7aee9b74074`.
All work was performed in isolated worktrees. This investigation changes tests
and measurement tools; production implementations and defaults are unchanged.

## What the switches do

`compiler.cfg.value-numbering:global-value-numbering?` enables the optional
cross-block congruence analysis and elimination. Local value numbering and its
folding/simplification still run when this switch is off. The global pass is
conservative: it handles selected pure integer operations and congruent phis;
it is not general memory-load elimination or partial redundancy elimination.

`compiler.cfg.register-allocation.rematerialization:rematerialize-constants?`
enables reconstruction of eligible signed 16-bit integer constants instead of
preserving them in spill slots. It works in linear scan, greedy, backtracking
and chordal. It does not reconstruct arbitrary expressions, floating constants,
object references, ABI memory operands or phi inputs.

Set either symbol to `t` in the compilation scope before recompiling the target
words. Already compiled code does not change when a symbol is toggled. The
measurement harness makes both settings explicit and verifies their values.

## Correctness and activity

The ARM four-way strict benchmark comparison passes with exactly 27,367 selected
word objects and 26 matching language outputs per configuration. SSA, interval
allocation and final value-flow checks are enabled in these separate correctness
processes. Their elapsed times are not performance comparisons.

Focused GVN tests independently check 1,312 native branch/loop answers across
the four feature combinations. The production pipeline removes one of two
redundant cross-block XOR operations only with GVN enabled. Untimed ordinary
benchmark probes observe 16 GVN replacements in spectral norm and two in
struct-array code. Counts describe intermediate replacements, not final machine
instructions or runtime savings. The allocator's final value-flow checker starts
after GVN and cannot independently prove GVN semantic equivalence.

Rematerialization tests cover all four allocators with GVN both off and on,
including negative GC-root eligibility, state reset and corrupted-recipe rejection.
An independent constant-pressure witness replaces 24–25 spills and reloads with
constant loads and reduces ARM code from 544–560 to 432 bytes. This synthetic
witness proves activation; it is not a runtime benchmark result. Ordinary
pressure kernels often retain computed, floating, vector or GC values outside
the restricted recipe set.

[Callback and moving-GC gates](../compiler-flags-safety-20260909/README.md)
exercise all 16 allocator/GVN/rematerialization settings on ARM. Moving-GC
fixtures retain a real collector and derived-pointer metadata, with 768 checked
native answers. GVN runs before synthetic GC insertion, matching production
ordering. Intermediate harness errors are preserved in their own records.

## Measurement protocol

The [shared protocol](../compiler-flags-20260909/PROTOCOL.md) uses linear scan and
holds loop-spill policy off. Configuration names are GVN/rematerialization:
`00`, `10`, `01`, `11`. After four strict checked closures, pristine fresh timing
processes run `00,10,11,01 / 01,11,10,00`. Each process compiles the same selected
closure, collects 12 static kernel reports, warms up all 26 workloads, then runs
three measured batches per workload. There are 624 measured batches and two
compiler observations per configuration on each architecture.

`run-arm.py` rejects changed production source, failed gates, differing scopes or
differing checked outputs before timing. `analyze.py` verifies all outputs and
sample ordinals, compares each configuration with its same-round baseline, and
retains per-case/per-round CPU, elapsed-time and retired-instruction ratios.
Runtime summaries use geometric means of per-case ratios; compiler ratios are
reported separately. The two rounds are a bounded comparison, not a confidence
interval or a bootstrap measurement. Host-load snapshots are retained; changing
execution rates can make CPU and wall-time comparisons noisy.

The 624 batches are repeated observations within eight fresh processes, not 624
independent compiler trials. macOS retired counts use process-wide usage while
CPU seconds use the current thread; Linux counters measure the current thread
and exclude kernel instructions. Compare ratios within each architecture, not
absolute instruction totals between architectures. Priority guards do not prove
constant CPU frequency. The analysis also retains the per-round multiplicative
interaction `M11 * M00 / (M10 * M01)` and verifies common source/image/VM/harness
identity before accepting the records.

Native x86 results and the completed ARM timing interpretation will be added
after their balanced queues finish. No default promotion is implied by activity
or correctness alone.
