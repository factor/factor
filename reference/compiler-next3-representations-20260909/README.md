# Representation selection: account for shared block conversions

Production commits `2bbace275a` and `b05ac4fed0`, based on `8780b3c090`.
Frozen ordinary source workload and additional tests: `e5ae5da0a4`.
Enable `conversion-aware-representation-costs?` in
`compiler.cfg.representations.selection`. It is unset/off by default. No
allocator, GVN or rematerialization default changes.

## Concrete problem and bounded policy

`representations.rewrite` caches each use conversion by original vreg and required
representation, resetting the cache at each block boundary. The original cost
model nevertheless charges every use. Many repeated cold tagged uses can outweigh
a hot float loop even though those cold uses share a single box.

The opt-in model charges generic, non-peephole use conversions once per original
vreg/required representation/block. It retains the old definition, temporary,
peephole and copy costs. Copies bypass conversion insertion; their costs therefore
remain unchanged. Phi/copy components and `compute-possibilities` are unchanged.
No copy or phi equality assumptions, conversion emission, GC-root rules, ABI
constraints or instruction placement rules are added or relaxed.

The heuristic still uses fixed weights 2/5 and `10^loop-depth`; it is not a profile
or an architecture-specific cycle model. Deduplication corrects a specific
mismatch with actual lowering, not all representation cost inaccuracies. Mixed
peephole/generic accesses may still be conservatively overcounted. The OFF path
uses the prior block-cost calculation after one per-CFG flag check. The ON path
adds a block-local set of conversion keys and does no whole-CFG search.

## Actual source witness

`workloads.factor` contains ordinary named Factor source, not a hand-written
machine CFG. `representation-loop-values ( n -- values )` loops over `float+`, then
returns the same final float in 32 array entries. Its loop count is runtime input.
The benchmark WORK wrapper supplies 10,000 iterations, executes the selected
kernel through a namespace-stored word handle, and independently checks array
length and all values. The metric target is `representation-loop-values`.

The original model selects tagged representation for the loop phi: actual
post-selection IR contains one float allocation and one unbox load in the loop.
The candidate contains neither hot instruction and one allocation at the exit.
The tests assert these real allocation locations independently of the cost table;
a separate scalar cost test observes four repeated uses priced 20→5.

## Native ARM64 correctness and allocation evidence

The final loaded representation subtree and named source OFF/ON recompilation
completed with exit 0, zero failures and strict SSA/interval/final value-flow
checking. Runtime oracles cover 0/1/100 iterations, the named 10,000-iteration WORK,
fixnum-to-bignum promotion at both limits, signed zero, an inexact-single sentinel,
±infinity, and a runtime NaN payload. Float bit cases pass through a foreign `fcos`
call and explicit collection. Distinct original vregs in the same component are
charged separately; clearing the block cache charges the next block again.

`allocated-bytes.factor` independently compiles and executes the source quotation
under each setting, checks results, warms both input sizes, samples nursery
occupancy, and asserts no GC events occurred in each measured region:

| Policy | Zero iterations | 1,000 iterations |
| --- | ---: | ---: |
| OFF | 464 bytes | 16,464 bytes |
| ON | 480 bytes | 480 bytes |

The difference at 1,000 is 15,984 bytes, exactly 999×16-byte float objects. The
constant 464-byte measurement/result-array overhead is retained in the raw totals.
The candidate pays one extra 16-byte box on the zero-trip path; this is a real
tradeoff of keeping the loop phi unboxed. These are allocation measurements,
**not runtime speed or compile-cost measurements**. Native x86 and broad
fixed-scope measurements are separate parent/crossarch gates.

The diagnostic sampled occupancy after warming both sizes and forces a collection
outside each measurement. It does not count all allocations across arbitrary GC
cycles and must not be used for larger batches without retaining the no-GC check.

## Exposed baseline limitation and development records

An initial constant-NaN loop fixture stalled already with the new policy OFF.
`constant-nan-off-timeout/` retains the bounded timeout and trace reaching the NaN
literal's OFF case after earlier finite cases. This is not classified as a
successful test or as a proven new-policy regression. The accepted NaN test passes
its payload at runtime, exercising conversions/FFI/GC without asking the existing
constant propagator to solve a NaN-valued loop fixed point. This separate
convergence issue was reported to the parent; no unrelated fix was attempted.

`initial-placement-observations.log.gz` is a development log: its box/unbox
observations are independently confirmed by passing unit tests, but its old
script later failed top-level `compile-call` inference and is not an accepted
native run. Accepted terminal statuses are under `final-correctness/`,
`safety/` and `allocated-bytes/`. Final harness imports include an explicit parser
import suggested by the passing run's automatic import restart.
