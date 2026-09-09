# Round 3 loop optimization evidence

Base `8780b3c090`; standalone LICM implementation and tests are in
`basis/compiler/cfg/loop-optimization`. The shared opt-in optimizer hook is
root commit `8f611ccb67` (local cherry `30fb546ece`); its SLP dependency is present
but disabled. No allocator/GVN/rematerialization defaults changed.

ARM `unit-final` passes structural SSA tests and 216 native independently
computed arithmetic answers on baseline/transformed graphs. Shapes include
single and multiple entry predecessors, distinct incoming accumulator phis,
zero/negative/one/multiple iterations, and signed dynamic operands. A valid-SSA
irreducible cycle is rejected, as are induction-dependent expressions and
GC-containing loops; disabled operation is a no-op. The native allocator's
final symbolic value-flow checker is explicitly required.

ARM `source-final` passes all 16 allocator × GVN × rematerialization settings,
864 native answers, with SSA/allocation/final checks enabled. It loads ordinary
typed source from `workloads.factor`, explicitly recompiles its `typed-word`
under each flag setting, and executes runtime operands. Every setting records
exactly one hoisted instruction. This is real motion with GVN both off and on,
not a renamed global-value-numbering pass or an already-installed-method test.
The only diagnostic wrapper records per-CFG hoist counts in a shared vector;
the shared production optimizer hook invokes the actual LICM implementation.

Both final gates use `compiler-features-arm` matching VM/image assets and
`refresh-all`. Exact commands, VM/image hashes, source identity, raw compressed
output and exit status are retained per run. `source-hashes.json` hashes the
final scripts, helper, tests and shared optimizer hook. Run from the worktree:

```
ABS_VM -i=ABS_IMAGE -no-user-init -resource-path=ABS_WORKTREE reference/compiler-next3-loops-20260909/unit.factor
ABS_VM -i=ABS_IMAGE -no-user-init -resource-path=ABS_WORKTREE reference/compiler-next3-loops-20260909/source.factor
```

The retained earlier failures are harness/coverage diagnostics: ambiguous
`set` import, locals outside a lambda, wrong property-setter order, and no LICM
activity in a mutable-local source loop lowered through generic calls. The
last case remains intentionally unsupported; the functional typed-stack loop
provides the positive source witness. `source-debug.factor` retains that old
no-motion diagnostic and is not the acceptance script. No production compiler
miscompile occurred in these gates.

These are correctness/activity measurements, not benchmark timings. Hoisted
IR counts do not prove emitted instruction or runtime reduction. For benchmark
integration load `workloads.factor`, toggle `loop-optimization?`, and explicitly
compile `invariant-xor-loop`'s `typed-word` property before timing. Its independent
result is zero for an even nonnegative trip count and `x bitxor y` for an odd
count. Broad existing-corpus activity and matched native runtime measurements
are delegated to the parent/native measurement owner. The feature remains off.
