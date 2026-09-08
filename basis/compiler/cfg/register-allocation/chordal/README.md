This experimental allocator colors the SSA interference graph before lowering
phis. Select it with `chordal-allocator register-allocator set` after loading
`compiler.cfg.register-allocation.chordal`.

The motivation is Hack's SSA allocation result: strict SSA interference graphs
are chordal, permitting optimal unconstrained coloring. Maximum-cardinality
search and greedy coloring follow the approach discussed by Pereira and
Palsberg. Sources:

- Sebastian Hack, [Register Allocation for Programs in SSA Form](https://publikationen.bibliothek.kit.edu/1000007166/6532), chapters 4.1, 4.3, 4.4, and 4.6.
- Fernando Pereira and Jens Palsberg, [Register Allocation via Coloring of Chordal Graphs](https://web.cs.ucla.edu/~palsberg/paper/aplas05.pdf), APLAS 2005.

Implementation and limits:

- Liveness includes phi operands on incoming edges. Phi definitions occur
  simultaneously at block entry. Interference intersects full live-range lists,
  preserving holes, and separates machine register classes. The allocator never
  invokes `destruct-ssa`, CSSA coalescing, or the linear-scan allocation driver.
- Maximum-cardinality search supplies the coloring order. The allocator checks
  that every vertex's earlier neighbors form a clique. `chordal?` reports this
  certificate for the graph actually allocated, after representation, GC, and
  context lowering. If false, the same greedy graph coloring remains a valid
  heuristic; no optimal-coloring claim applies and no alternate allocator is
  silently selected.
- Greedy colors select physical registers within each class, respecting the
  frame-pointer exclusion. Excess colors and fragments displaced by spills use
  the existing next-use interval splitting primitives for repair. Calls retain
  the backend's synchronization and operand spill-slot rules. GC roots use the
  existing spill/reload and derived-root machinery. This is a graph-coloring
  policy with shared interval repair, not an implementation of Hack's complete
  pressure-reduction and register-targeting algorithm. The certificate does not
  assert globally optimal spilling or constrained physical assignment.
- Phi edges are resolved after assignment, with simultaneous physical moves and
  spill-slot temporaries for cycles. Phi results can occupy stack slots, so a
  join with more live phis than registers remains allocatable. Stack-to-stack
  copies borrow an admissible register, preserving the widest representation
  used in its class in a separate temporary slot. Identical locations need no
  move. Coloring prefers available colors of phi/copy partners without deleting
  interference edges or merging vertices. Copy quality can still trail the
  default allocator's SSA coalescer.
- Derived-pointer phis receive companion tagged-base phis before liveness.
  These select the matching GC base on each incoming edge; a plain integer edge
  selects immutable false. The local liveness pass seeds these relationships so
  moving GC updates derived values correctly. Provenance uses the existing
  arithmetic rules, including XOR for the two inputs of addition. Inconsistent
  cyclic provenance equations raise an explicit error instead of silently
  omitting a root.
- SSA uses can occur before their definition in linearized block order. ABI
  operand slots are reserved before splitting so a use-only call fragment can
  receive its value through an incoming edge even if synchronization removes
  its only interval use.
- This deliberately simple implementation explicitly builds the graph with
  pairwise range intersections and uses a quadratic maximum-cardinality search.
  Its compile-time cost is unsuitable for very large procedures without further
  engineering. It is a measurable contender, not the new default.

`allocator-statistics` returns vertices, edges, `chordal?`, direct physical color
assignments, and repair assignments. Counts include split fragments, making the
amount of work performed by each policy visible in `compiler.cfg.metrics`.
`check-allocation?` verifies register classes, range coverage, overlapping
assignments, and preservation of mandatory register uses across splitting.

The tests exercise graph certification (including rejection of a chordless
cycle), interval holes, branch joins, loop phi swaps, tagged roots across GC,
FFI calls in loops, and a generated 40-value floating-point pressure case.
Additional tests execute both paths through a 40-result phi join and check
scalar scratch copies preserve a live-vector-width register. A native lowered
CFG carries fresh nursery addresses through an integer phi and explicitly
collects before returning the selected object. Both exact pointer-identity
checks pass; disabling companion-base construction makes both fail.
