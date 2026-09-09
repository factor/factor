# Four compiler improvements: implementation and measured results

Implemented and committed in four separate worktrees, with a fifth integration
worktree and a separate native benchmark worktree. All four are opt-in. Linear
scan remains the allocator default; GVN and rematerialization defaults are unchanged.

- **Loops:** canonical preheaders and conservative integer loop-invariant code motion.
- **Representations:** charge shared use conversions once per value/representation/block,
  matching the conversion emitter's cache.
- **Memory:** reuse dominating managed slot loads across blocks with a must-availability
  analysis and conservative effect barriers.
- **Vectorization:** automatically pack profitable independent integer expression trees
  into two SIMD lanes. This is straight-line SLP, not loop vectorization.

[Implementation, flags, and worktree names](IMPLEMENTATION.md) describe the supported
scope. Production compiler source was frozen at `020b74ce5d` for measurement.
Subsequent changes are test-portability, benchmark-import, documentation and evidence
updates; production optimizer definitions remain identical to that freeze.

## Actual gains and limits

The representation witness is the strongest result: about **75% less CPU time on both
architectures**, with roughly two-thirds fewer retired instructions. A separate native
allocation probe changes 1,000 hot-loop float boxes to one exit box: **16,464→480 bytes**,
including fixed result/measurement overhead. Zero iterations pay one extra box.
This witness deliberately exercises repeated cold uses that distort the original model;
it does not establish a 75% gain on normal programs.

Each row below measures the feature's own constructed witness. Percentages are ON/OFF
minus one; negative means less retired work or CPU time.

| Feature | ARM retired / CPU | Native x86 retired / CPU |
| --- | ---: | ---: |
| LICM | -16.69% / -8.19% | -28.57% / +53.62% |
| Representation costs | -67.46% / -74.97% | -65.64% / -75.92% |
| Memory load reuse | -1.93% / -7.05% | -1.11% / +3.96% |
| Integer SLP | -2.82% / +16.96% | -2.67% / -3.13% |

ARM CPU measurements vary materially for unchanged controls, so small CPU differences
and the SLP CPU observation require caution. The native SLP witness improves CPU about
3.1%, but the original corpus has a repeatable Base32 regression: **+3.419% retired work,
+3.219% CPU**. Its cause remains unresolved; it is retained rather than dismissed as noise.

The native LICM witness's CPU regression repeats despite fewer executed instructions.
An unchanged loop under the representation-only control also changes execution rate.
Detached assembly captures show different loop offsets, but they are not captures from
the timing processes and do not establish the cause. LICM's unchanged code size is
expected: moving an instruction changes how often it executes, not necessarily bytes.

The original **26-workload corpus shows no broad win**. Native retired-work geometric
means range from -0.025% to +0.132%; ARM from +0.015% to +0.055%. Memory analysis adds
about 1.98% native / 1.75% ARM compilation work. Full CPU, compile, per-case and per-round
results—including unfavorable results—are in the architecture reports. No feature is
promoted to default on the strength of a constructed witness.

## Verification and reproducibility

Each architecture passed all-off and four isolated-on full-closure checks, plus a
separate all-four-on full-corpus check. SSA, interval and final allocation value-flow
verification remained enabled. Every configuration produces the same 30 workload outputs
and uses the same architecture-specific scope: 27,834 words on ARM, 28,959 on native x86.
All 16 metric roots and 30 runtime roots belong to those frozen compilation scopes.

Each architecture then ran ten fresh timing processes in balanced order: OFF, LICM,
representations, memory, SLP, SLP, memory, representations, LICM, OFF. Three samples per
workload yield **900 measured batches per architecture**, with no discarded timing runs.
The two OFF anchors are shared, so comparisons are correlated and differ in temporal
distance from baseline. There are only two independent processes per configuration;
no significance claims are made. Counter coverage differs across operating systems.

All 16 timed final static reports match their strict checked counterparts and repeat
across rounds. With all new features off, the original 12 reports exactly match the old
baseline. Runtime calls reach freshly compiled kernel handles, including typed bodies.

Independent native oracles additionally cover 1,080 generated/source LICM answers,
4,096 integer SLP cases and 48 buffer edge cases, aliased mutable objects, float bits,
FFI and moving GC. An intentionally unsound memory mutant fails its native oracle even
though the allocation verifier accepts it. Review led to explicit C-unbox memory barriers
and conservative rejection of pointer-bearing CFGs in LICM and SLP. Floating-point SLP
was removed because enabled traps make reordering observable. An unsupported-backend
SLP test verifies refusal and restoration of the host capability binding.

- [ARM results and raw evidence](arm/README.md)
- [Native x86 results and raw evidence](candidate-native/README.md)
- [Timing protocol](FEATURE-PROTOCOL.md)
- [Combined ARM corpus gate](combined-corpus-arm/validation.json)

No new bootstrap was timed. These prepared images refresh an existing pinned image;
this work does not resolve the earlier bootstrap-duration concern. The original checkout's
image and unrelated edits are preserved, and no changes are pushed remotely.

Further work remains: induction/range optimization, safe motion through more loops,
more precise alias information, architecture-specific SLP costs and actual loop
vectorization. The measured Base32 and small-loop execution-rate effects need diagnosis
before promotion. These bounded passes are useful implementations, not complete versions
of all optimization algorithms.
