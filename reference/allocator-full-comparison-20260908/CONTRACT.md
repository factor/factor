# Full allocator comparison contract

This is an independent acceptance and measurement contract, not a statement that
the replacement allocators are complete. The corrected prototype source is
`0b52875640`. Previously completed prototype measurements remain separate in
`reference/allocator-speed-crossarch-20260908/native-x86-64/provisional-source67caf`.
No final prototype matrix completed before the user redirected work toward full
algorithms. The normal compiler default remains linear scan, with GVN off.

## Reference scope

LLVM greedy must combine a size-prioritized work queue, interval-union queries,
eviction with requeue, progressive region/block/local splitting, and final spill
handling. Preferences and bounded recoloring need behavioral tests if claimed.
These are separate mechanisms; a density queue alone is not the algorithm.
See the [LLVM author's overview](https://blog.llvm.org/2011/09/greedy-register-allocation-in-llvm-30.html)
and [`RegAllocGreedy.cpp` at LLVM 9851e4f8979b8b57557d03cd98b54f57287a128f](https://github.com/llvm/llvm-project/blob/9851e4f8979b8b57557d03cd98b54f57287a128f/llvm/lib/CodeGen/RegAllocGreedy.cpp),
especially `tryRegionSplit`, `tryBlockSplit`, and `tryLastChanceRecoloring`.

The backtracking contract follows regalloc2 commit
`2fe490bc9dda433f70c54f90f7633ed929f693d9`: distinct SSA values can share
nonoverlapping bundles; descendants retain spillsets; probing supplies conflicts
and a split point; eviction and splitting make progress; residual spill bundles
receive a second chance; homes and edge moves are resolved afterward. See the
[pinned Ion design](https://github.com/bytecodealliance/regalloc2/blob/2fe490bc9dda433f70c54f90f7633ed929f693d9/doc/ION.md)
and the owner's `backtracking/ALGORITHM.md` for Factor-specific constraints.

Decoupled SSA allocation reduces pressure before coloring, colors the remaining
SSA interference graph, then improves copy affinities without invalidating that
coloring. The uniform-register theorem does not grant optimality for arbitrary
physical-register constraints. See Hack, Grund, and Goos,
[Register Allocation for Programs in SSA-Form, sections 3–4](https://compilers.cs.uni-saarland.de/papers/ssara.pdf).
An SSA coloring preference followed by a different interval allocator does not
demonstrate this architecture. The owner also targets Braun and Hack’s
[CFG spilling algorithm](https://pp.ipd.kit.edu/uploads/publikationen/braun09cc.pdf)
and [preference-guided assignment](https://pp.ipd.kit.edu/uploads/publikationen/braun10cc.pdf).
Accordingly, audit the actual register-resident/memory-valid block states,
successor-sensitive next-use decisions, edge coupling and fresh reload SSA
definitions; a loop-depth weight alone does not demonstrate that spilling pass.

Factor currently exposes representation classes, temporaries, memory-only ABI
operands and clobbers at the allocation boundary. Fixed ABI shuffles introduced
by lowering must be tested in their actual form. Do not invent unsupported
fixed/early/late operand fields merely to resemble another compiler's API.
Factor interval endpoints are inclusive; imported half-open assumptions must be
translated explicitly. This matters at touching endpoints and split boundaries.

## Evidence required for each mechanism

An implementation entry, a positive counter, and a passing checksum each provide
different evidence. Acceptance requires all three where applicable: identify the
production decision, retain its actual before/after state on a small fixture,
and execute the resulting code under the independent final value-flow checker.
A counter increment or an artificial helper-only test cannot establish that the
decision participates in the allocation path.

`witnesses.py` independently checks exported small-fixture facts: inclusive range
partition and use preservation, distinct-value bundle noninterference, exact
eviction/requeue sets, compatible nonoverlapping shared homes, perfect elimination
and coloring, and legal affinity-improving recoloring. It deliberately enumerates
bounded ranges instead of sharing production indexes. Its positive and corrupted
examples in `witnesses_test.py` are synthetic validator tests, not allocator results.
The script cannot certify that a compiler exported a truthful trace; source and
dispatch inspection are still required. It also does not replace the CFG checker.

The elimination witness uses a conventional order whose *later* neighbors form
a clique. Reverse an MCS selection/coloring order when needed; do not relabel it.
Strict weight growth in an eviction witness is required for the ION policy, not
assumed for every LLVM decision. Different SSA values in a bundle remain different
value identities for GC and phi verification.

## Comparative cases

These are the required fixture shapes and observations. Owners may reuse existing
builders, but the final record must identify the actual builder, inputs, register
budget and observed decision. Every arithmetic use contributes to a checksum.
Runtime-input-derived values prevent constant folding and rematerialization from
accidentally removing the pressure being tested.

| Case | Trigger | Required independent observation |
|---|---|---|
| Queue eviction | Long sparse value allocated before a shorter dense overlapping value, reduced integer budget | A physical allocation loses every conflicting owner; all victims requeue and are later resolved |
| Hole reuse | Interleaved disjoint ranges with overlapping hulls | Same physical register used without a spill; actual occupied points never intersect |
| Hot region | Cold definition, multi-block hot loop, cold suffix, and a zero-iteration edge | A split separates the hot region; weighted spill/reload traffic is recorded per block, with outputs for zero/one/many iterations |
| Local refinement | One block with two pressure peaks separated by a quiet region | Region failure progresses to block/local splitting; child ranges and uses partition the parent |
| Constraint boundary | Values live across real FFI clobber and memory-only ABI uses | Required homes/register classes hold at the boundary; source-level FFI result is independently checked |
| Recolor chain | Valid small assignment in which one preferred color is blocked by a relocatable neighbor chain | Physical assignments actually change; all interference/allowed-register constraints remain valid; benefit or newly assigned request is demonstrated |
| Distinct phi bundle | Diamond with different runtime values on each edge and nonoverlapping outgoing/incoming ranges | Multiple original SSA identities occupy one bundle; both branches execute with different expected outputs |
| Bundle obstruction | A merged multi-block bundle fits before a specific occupied point but conflicts afterward | Split is tied to the observed obstruction, not merely the median use; at least one resulting piece is assignable |
| Second chance | Split-required uses surrounding a long region with no register use | Residual bundle reaches the later pass and acquires a legal register or an explicit home; mandatory uses remain allocated |
| Shared spill homes | Nonoverlapping spilled value groups, each with multiple descendants | At least two spillsets share one compatible slot; descendants agree and occupied points do not intersect |
| Pressure before coloring | Strict SSA fixture whose peak exceeds K, plus a matching case at K | Pressure is reduced before final coloring; transformed SSA graph gets a checked perfect order and a legal K-coloring |
| Coalescing without graph damage | Phi affinity blocked by a two-color component | Recoloring reduces weighted edge-copy cost while preserving the same interference graph and fixed constraints |
| Parallel edge cycle | Loop-header permutation and critical-edge diamond under pressure | Resolver emits a correct cycle-breaking sequence; zero/one/many loop iterations and both diamond arms execute |
| Moving GC identity | Tagged base, coalesced bitcast, and nonzero derived pointer live across moving GC | Fresh object identities survive; original and derived roots remain independently represented where required |
| Recipe boundary | Cheap constant pressure crossing a diamond, loop and GC point, rematerialization both off/on | No read from an uninitialized spill home; both paths execute and recipe insertion is counted |
| Bounded progress | Increasing pressure and adversarial affinity/eviction ordering | Queue work, split counts and maximum depth are recorded; no cycle, abandoned value or alternate allocator fallback |

## Dispatch and resource equivalence

Instrument the concrete allocator method body and the actual work routines, not
only the selector or wrapper. Each test must enter the requested algorithm; other
allocation-policy routines must have zero entries. Shared liveness, interval
containers, instruction rewriting, stack layout and parallel-move mechanics are
allowed. Sharing an allocation policy under a neutral name is not an exception.
Inspect the reachable call graph when neutral helpers are extracted.

Use exactly the same admissible integer/SIMD register set, representations,
temporary requirements, clobbers, rematerialization setting and loop weighting
for a given comparison. Record reduced budgets and native ABI exclusions.
Algorithmic fixture tests may reduce the register budget; broad runtime workloads
must use the complete native admissible set. An abstract graph fixture proves a
graph property and cannot stand in for native execution.

## Timing gate and protocol

Start final timings only after the production implementations, all applicable
mechanism cases, independent checking, native ARM64/x86 execution, and compiler
acceptance pass on immutable source. Parent owns compiler/bootstrap acceptance.
Report omissions explicitly; do not redefine completion around passing examples.

Reuse the 26-workload installed-code harness and 12 actual-kernel code reports.
Freeze the word-object sequence once per source revision, including new compiler
helpers through the full dependency/dispatch closure. Retain exact source/image/VM
hashes and flags. Recompile and install that sequence entirely under the selected
backend; loading a helper later under linear scan invalidates the claimed scope.
Different revisions can have different helper counts, which must be reported.

Separate untimed correctness/diagnostic runs from timed compilation and runtime.
Keep fixed batches, equal inputs and independent output oracles. Run paired fresh
processes in both revision orders, at least two rounds and six timed samples per
workload/revision/allocator. Retain per-round results and all failures. Compare
both each allocator against its corrected prototype and the final allocators
against final linear scan. Publish per-workload medians and equally weighted
geometric means; never infer a runtime win from static spill counts alone.

Record compilation CPU/retired instructions separately from runtime CPU/retired
instructions. Retain final code bytes, spill/reload/copy counts, stack bytes and
per-block weighted traffic. Native x86 uses the existing isolated agent1 CPU-2
lane and per-thread pinned userspace counters; ARM retains externally applied
foreground policy and Mach priority guards. These shared hosts do not provide
fixed frequency or reserved cores. Cross-architecture absolute retired counts
have different counter scope and are not directly comparable.

## Diagnostic body probe

`dispatch.factor` annotates actual method and policy definitions in a disposable
process. It is intentionally excluded from timed runs. The source audit must
supply the policy routine names for each frozen implementation; missing names
fail instead of silently weakening coverage. Neutral shared mechanics do not
need policy labels, but their bodies must be reviewed before that classification.

`prototype-dispatch-probe.factor` and its retained native log show the mechanism
on the corrected prototype: one method/engine entry per allocator and two LS
register-choice entries. Chordal explicitly enters its prototype interval-repair
engine, illustrating why a method-only selector audit is insufficient for the
new completeness claim. This is a checked CFG pipeline smoke test in a native
x86 VM, not execution of generated machine code or a performance measurement.
Its historical script path uses the existing crossarch harness directory on
agent1; the exact environment and partial-image reload are recorded in the status.

After the existing `analyze.py --require-complete --min-samples 6` produces the
paired before/after summary, `rank.py SUMMARY.json --output PATH` derives the
within-final-source comparison against final linear scan. It rejects missing
allocators, workloads, source identity, rounds or samples. Its unit-test numbers
are synthetic and do not report any allocator performance. This additional
report answers a different question from each allocator’s improvement over its
own prototype baseline; both reports are required.
