# Conservative SSA loop optimization

`loop-optimization?` is opt-in and defaults to false. `optimize-loops` is the
flag-gated compiler pass; `perform-loop-optimization` is its unconditional test
entry. The shared SSA optimizer calls it after value numbering and copy
propagation, before SLP, multiply-negate fusion and dead-code elimination.
Representation selection and GC insertion happen later.

The implementation performs actual loop-invariant code motion, independently
of global value numbering. It processes natural loops from inner to outer,
validates that the header dominates every member, and considers only explicitly
listed nontrapping cell-integer arithmetic, bit operations and comparisons.
RPO/instruction order discovers invariant dependency chains. Every operand must
already be selected or have a definition outside the loop that dominates its
header. Undefined values and loop-carried phis are not assumed invariant.

Only productive loops are canonicalized. A dedicated non-kill predecessor is
reused. Otherwise all external edges are redirected through a new preheader;
header phi inputs are partitioned by their actual predecessor identities.
Distinct external values receive a fresh preheader phi, equal values share the
original input, and backedge inputs retain their values. Original movable
instruction objects are removed by identity and inserted before the preheader's
terminator in dependency order. CFG, predecessor, dominance and loop analyses
are invalidated after the change. Later SSA checking independently validates
dominance and complete phi-edge inputs.

The operation whitelist is a speculation contract, not the broader local-CSE
`foldable-insn` class. It excludes memory reads, conversions, FP operations,
division, checked-overflow branches and literal loads. Thus a zero-trip loop
may execute a moved integer calculation without adding a trap, memory access,
or FP status change. No floating-point reassociation or exception reordering is
claimed. Loops containing kill blocks, calls, allocation, GC-map instructions
or ABI/boxing boundaries are rejected altogether. This deliberately forgoes
hoisting in many existing loops, including mutable-local code lowered through
calls. There is no alias analysis, load hoisting, induction rewriting, physical
register constraint relaxation, or claim that every loop invariant is found.
Hoisting may increase register pressure; the pass remains off until measured.

The supported control-flow shape follows the conventional natural-loop and
preheader definitions in [LLVM's loop terminology](https://llvm.org/docs/LoopTerminology.html).
LLVM's [LICM implementation](https://llvm.org/docs/doxygen/LICM_8cpp_source.html)
likewise distinguishes invariance from safe speculation. This Factor pass uses
its own smaller explicit instruction contract rather than importing LLVM's
memory/effect assumptions.

Tests exercise dependency chains, changing induction values, exact multi-entry
phi merging, zero-trip execution, a valid-SSA irreducible cycle, disabled no-op
behavior, excluded unsafe instruction classes, and whole-loop GC rejection.
Generated native arithmetic cases compare independently computed answers with
baseline and transformed graphs, including both external-entry paths. The
ordinary source witness in `reference/compiler-next3-loops-20260909` uses typed
integer `bitxor` and `times`, with no custom IR or unsafe primitives. It freshly
recompiles the actual typed method under all four allocators and both GVN and
rematerialization flags, requires positive LICM activity, and executes dynamic
zero/one/even/odd-trip answers.

`loop-optimization-statistics` records `hoisted`, `preheaders`, and
`productive-loops` for one CFG; absent entries mean zero. These count source IR
changes, not emitted instructions or dynamic speedups. The separate benchmark
workload file can be loaded for matched flag-off/flag-on code and runtime
measurements; compile its `typed-word` property explicitly to avoid timing a
previously installed method.
