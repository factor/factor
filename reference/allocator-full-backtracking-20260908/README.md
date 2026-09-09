# Backtracking mechanism evidence, 2026-09-08

Allocator code: `90a2b6d590`, following `ec5efcbe68`. Native host ARM64.
Evidence vocabulary source: `14283004f1`. Final export was rerun at
`64a90d4abf` (same allocator plus shared derived-phi GC prerequisites),
using the committed `export.factor`; `export.log` records the successful
native assertion and `witness-check.log` records independent validation.
The optional `compiler.cfg.register-allocation.backtracking.evidence` vocabulary
exports actual allocator state; it is not loaded by normal compilation.
The algorithm/source/behavioral matrix is in
[basis ALGORITHM.md](../../basis/compiler/cfg/register-allocation/backtracking/ALGORITHM.md).

`witnesses.json` contains:

- One native compiled graph: peek, two copies, add immediate, return. It executes
  10→11. Four different SSA values merge into a disjoint bundle with inclusive
  ranges `[3,4]`, `[5,6]`, `[7,8]`, `[9,10]`. Arithmetic changes the bits, so this
  also distinguishes a register affinity from value equivalence.
- A real reduced-bank interval allocation of two independent pressure regions.
  Spillsets `[0,100]` and `[200,300]` share typed slot 0; every allocated child
  reports its own ranges and slot. These are allocator-stage witnesses, not
  native machine executions.
- Actual before/after occupancy and requeued owner from a strict-weight eviction.
  The dense request has weight 0.190476, exceeding the sparse owner's 0.019802.
- Actual `split-for-bundle` output and computed canonical no-use ranges. The
  children conserve every inclusive point and mandatory operand of `[0,100]`.

The independent comparison agent's `witnesses.py` accepted all four objects:

```json
{"native_execution_or_source_completeness_certified": false, "witness_invariants_passed": {"bundle": 1, "eviction": 1, "spillsets": 1, "split": 1}}
```

Reproduce from a checkout with its matching Factor image, explicitly refreshing
changed vocabularies as the exporter does:

```sh
./factor -i=/absolute/path/factor.image -no-user-init reference/allocator-full-backtracking-20260908/export.factor
python3 reference/allocator-full-comparison-20260908/witnesses.py reference/allocator-full-backtracking-20260908/witnesses.json
```

The full `compiler.cfg` test tree also passed with global backtracking, SSA,
interval and final original-value checks enabled, rematerialization off, and
GVN off. Its spill-site tests independently compare the opt-in loop policy.
The parent integration run preceding 90a2b6d590 executed 900 reduced-bank native
answers over backtracking/chordal and rematerialization off/on; that report is
not a claim to rerun the corpus on this final code revision. Shared derived-phi
GC fixes and final cross-architecture correctness are integrated separately.
No runtime performance conclusion follows from these small witnesses.
