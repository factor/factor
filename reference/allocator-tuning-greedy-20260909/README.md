# Greedy local spill-tail repair

The full allocator's integer-pressure kernel emitted 57 spills and 29 reloads,
versus 29 of each in the earlier prototype. It used the same 232 spill bytes.
`apply-local-split` unconditionally called `spill-before` on its selected
product, creating a trailing store even when the product already ended at its
last required use. Native interval-expiry records identify all 28 additional
stores as coming from use-only final fragments.

The repair, commit `dca2e6e19a` based on `7b6cd9519a`, preserves that exact upper
endpoint when the selected product has no existing `spill-to`. Otherwise it
retains the normal spill path. The check runs after both actual splits, so a
store required by a split or ABI boundary is preserved. A tail extending past
the final local use still gets a store before it is shortened. At a terminator,
the retained register remains in machine live-out and shared edge resolution
supplies each successor's required home. The change makes no assumption that a
spill slot is initialized or clean and introduces no shared allocator changes.

## Correctness

Focused tests cover a final definition, final ordinary use, inherited store
obligation, a live-through tail, actual definition-store/reload/final-use flow
with forced expiry, and a final terminator use with two successors including a
backedge. The machine-flow fixtures use the original-SSA value-flow checker.

On native ARM64, the complete greedy and region suites passed under the image's
default rematerialization setting and again with rematerialization enabled;
the final assertion confirms the enabled option remains restored. The run
printed 71 successful unit-test invocations and exited zero. It used the fresh
`allocator-full-master-candidate/full-master-default.factor.image`, matching
root VM/libraries, this worktree's explicit resource path, and
`<< refresh-all >>` before loading tests. Output: [arm-tests.log.gz](arm-tests.log.gz).

The independent native x86-64 run used the newly built matching `7b6cd9519a` VM
and the same prepared image for both sources. It checked SSA, required uses,
allocated intervals, and final value flow. Its untraced runtime driver also
executes 32 scalar oracle checks through a namespace-held compiled word, so a
direct call cannot be inlined into a driver compiled with another allocator.

## Native x86-64 results

| Measurement | Before | After |
| --- | ---: | ---: |
| Actual stack-move stores per kernel | 57 | 29 |
| Actual stack-move reloads per kernel | 29 | 29 |
| Generated code bytes | 864 | 688 |
| Median CPU seconds per batch | 0.1748126685 | 0.1450260010 |
| Median retired instructions per batch | 3,946,650,959.5 | 3,409,050,902.5 |

CPU time falls **17.04%** and retired instructions fall **13.62%**. Each source
has six timed samples across two rounds with reversed source order; warmups
are excluded. Round CPU ratios are 0.83045 and 0.82896. Each batch evaluates the
kernel 19.2 million times. The median instruction reduction of 537,600,057
matches the 28 removed stores multiplied by those evaluations, within 57
counter/driver instructions.

An independent structural comparison ignoring vreg renumbering found identical
physical-register assignments for all 161 mandatory definitions and uses.
Allocation counters, including 29 local splits, are unchanged. This is a
recovery from unnecessary emitted stores, preserving the full greedy algorithm.
It is isolated integer-pressure evidence; it does not establish a new overall
ranking across the 26-workload matrix or a whole-compiler speedup.

The exact executed scripts, interval/store provenance, generated binaries,
objdump listings, source hashes, runtime logs and statuses are archived in
[the independent native evidence directory](../allocator-tuning-20260909/native-greedy-provenance/).
In particular:

- [Runtime summary](../allocator-tuning-20260909/native-greedy-provenance/runtime-summary.json)
- [Executed untraced runtime driver](../allocator-tuning-20260909/native-greedy-provenance/executed-runtime.factor)
- [Mandatory assignment equivalence](../allocator-tuning-20260909/native-greedy-provenance/assignment-equivalence.json)
- [Before emission](../allocator-tuning-20260909/native-greedy-provenance/baseline-emission.json) and [after emission](../allocator-tuning-20260909/native-greedy-provenance/candidate-emission.json)

The remaining conservative cases are intentional: existing spill obligations
and tails extending beyond the final local use are retained. Removing stores
from those cases would need an additional proof about live-out transport or
memory availability; this patch does not attempt it. Default linear scan is
unchanged.
