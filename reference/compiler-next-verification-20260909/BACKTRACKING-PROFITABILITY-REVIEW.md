# Backtracking entry-transport profitability review

Reviewed production commit `0033ae82c523678a9e30d852ab64b40c2d7b5774`, relative to `eccfc0accc5c513b44701f2e59d4a9bafb7515f0`, in `compiler-next-backtracking-profitability` on 2026-09-09. This was an independent read-only review of code and targeted tests; no new test execution, builds, or performance jobs were performed by this reviewer. No correctness blocker was found within the existing SSA liveness, interval, and edge-map contracts.

The original eligibility exclusions remain: only an original live-in's spill-slot reload at an ordinary block entry is considered, with nonempty predecessors and no kill predecessor, kill successor, or phi/GC/clobber first instruction. Assignment initially retains that reload. The decision then uses each actual predecessor's `machine-live-out` entry, avoiding guesses from interval hulls, holes, or spill flags. Shared assignment can retain a register in its pending map across a hole or at a boundary-ending interval, so those guesses would not be equivalent.

When all predecessor locations equal the reload's source spill home, the implementation retains the common successor reload and its existing incoming map. Otherwise it delegates to parallel edge resolution by removing the recorded reload and changing that original value's incoming destination to the assigned register. Later uses and spill obligations remain intact. Recording occurs only around entry activation; it cannot accidentally capture GC saves or instruction prefixes. Before mutation, the code checks that the record contains exactly one reload with the expected source, destination, representation, and incoming memory home. Deletion uses object identity, preserving any later structurally equal reload.

The identity-keyed record table is passed explicitly through the shared phase API; existing callers pass `f`. No observer namespace or exception cleanup state is introduced. The unchanged no-record activation path remains available to other callers.

Reviewed targeted tests include an actual common-home CFG checked against original value flow, the existing mixed-memory/register permutation and deleted-copy mutation, and synthetic predecessor maps proving that a later equal-but-distinct reload survives delegation. The owner reported passing execution separately; this document does not claim a new run. The guard addresses the identified duplication of one successor reload onto multiple edges, but does not establish general or dynamic profitability; paired measurements remain necessary.

Reviewed production SHA-256 values:

- `backtracking.factor`: `6f82a95b997dd4bec37e9018679da8cdf5fce22b0288b02985eaddc6fd125d87`
- `ssa/phases/phases.factor`: `ce6a81a72bb7a1ddb0ad165cf68f2e0dd7df7017a63bf3df5c85a066a85ea134`
