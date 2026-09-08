# Backtracking allocator

`backtracking-allocator` implements the common `allocate-cfg` protocol. Select it
with `backtracking-allocator register-allocator [ ... ] with-variable`.

This is an independent allocator inspired by regalloc2's bundle work queue and
backtracking approach. It shares Factor's SSA destruction, precise live ranges,
spill-slot representation, instruction assignment and edge move resolution.
It never calls the linear-scan allocator as a fallback.

The implementation:

* Splits ranges at mandatory call clobbers, preserving stack operands, destination
  exceptions, and spill/reload representations from Factor's existing IR.
* Bundles disjoint fragments with the same coalesced SSA leader, including values
  carried across calls. These affinity bundles receive one register atomically.
* Processes bundles in a maximum heap ordered by total live-range length.
* Probes all admissible registers against complete assigned ranges, including
  holes. Frame-pointer and integer/vector register restrictions are preserved.
* Evicts and requeues all conflicting bundles if their maximum spill density is
  strictly lower than the requesting bundle's density.
* Unbundles unsuccessful affinity groups, then splits individual intervals at
  their median use boundary, connecting the pieces through typed spill slots.
* Shrinks a final single-use interval to its operand and spill position. Such a
  minimal interval has infinite weight and cannot be evicted by another minimal
  interval. Impossible operand pressure raises an explicit error.

Termination follows from strict weight increases along evictions while the bundle
set is unchanged, plus a finite number of unbundlings and use partitions. Each
partition reduces the number of uses per piece; single-use trimming happens at
most once per piece. There is no retry-limit fallback or hidden linear scan.

Differences from full regalloc2 are deliberate: affinities come from Factor's
existing SSA coalescer and same-leader fragments, rather than a separate general
cross-vreg bundle merger; occupancy uses vectors rather than per-register B-trees;
spill density is unweighted use count divided by live-range length, and splits
are median-use boundaries rather than loop-aware placement. Thus this is a
correctness-oriented experimental implementation, with potentially quadratic
conflict-query cost, not a claim to reproduce regalloc2 performance.

Primary design references:

* [Chris Fallin's regalloc2 design article](https://cfallin.org/blog/2022/06/09/cranelift-regalloc2/)
* [regalloc2 bundle processing implementation](https://github.com/bytecodealliance/regalloc2/blob/main/src/ion/process.rs)

## Executable comparison

```factor
USING: compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking kernel.private math prettyprint ;

[ { fixnum fixnum } declare + ]
{ linear-scan-allocator backtracking-allocator } compare-allocators .
```

The common harness builds a fresh CFG for each allocator and reports code bytes,
spill/reload counts and compilation pass timings. Warm up both choices and repeat
in alternating order before interpreting timings.

## Tests

```factor
USING: compiler.cfg.register-allocation.backtracking tools.test ;
"compiler.cfg.register-allocation.backtracking" test
```

Tests force eviction and splitting with a single available register, verify
same-value affinity bundles, check clobber spill/reload formation, execute
compiled integer/float/loop/GC code and compare fresh CFGs through the common API.

Initial native ARM64 validation (2026-09-08): the focused tests, including a
forty-live-value compiled integer reduction, passed range and mandatory-use
verification. Existing `compiler/tests/{spilling,float,alien,simple}.factor`
completed with 301 unit-test cases and 16 expected-failure cases, with range
verification enabled. This includes executed FFI and GC cases.

On the forty-value reduction, fresh-CFG measurements gave linear scan 560 code
bytes and 24 spill/reload pairs versus backtracking 576 bytes and 25 pairs; both
used 192 spill bytes. Six small integer, float, branch, reduction, map and bitwise
examples had identical code sizes. These are correctness smoke comparisons, not
evidence of a performance advantage.

The shared 32-live-float kernel (input 2.5, result 5092.0) also executed with both
verifiers enabled: backtracking generated 832 bytes, 11 spill/reload pairs and
88 spill bytes, versus linear scan's 848 bytes, 12 pairs and 96 spill bytes.
Backtracking performed 11 evictions and 11 splits. All 13 compilation bodies in
the shared compiler/benchmark corpus passed both allocation verifiers.
