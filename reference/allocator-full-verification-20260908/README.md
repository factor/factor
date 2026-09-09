# Allocation correctness release

Production repair: `660d676e71` prepares selected tagged bases for derived
SSA phis before the allocator dispatcher and verifier snapshot, preserves
those seeds through liveness resets, and reuses preparation in SSA allocators.
The no-phi and no-GC paths skip companion-base analysis. Allocator statistics
remain visible after the context restores.

The exact production files needed by the prototype baseline are:

- `basis/compiler/cfg/liveness/liveness.factor`
- `basis/compiler/cfg/register-allocation/register-allocation.factor`
- `basis/compiler/cfg/register-allocation/ssa/bases/bases.factor` (new)
- `basis/compiler/cfg/register-allocation/chordal/bases/bases.factor`

The last file is a compatibility facade for the shared base machinery; the
repair does not require adopting a new allocation policy.

## Native probes

From the target worktree, with its matching native VM and image:

```sh
./factor -i=/absolute/path/to/factor.image -no-user-init \
  reference/allocator-full-verification-20260908/MOVING-GC.factor
```

This standalone probe uses the ordinary allocator dispatcher and the full
native register banks. It imports no new validation vocabulary or reduced-bank
kernel API. It checks both tagged-base phis followed by derivation and phis of
already-derived pointers from different bases, for all four allocators. Each
word executes against 24 fresh object pairs. Both original objects remain
rooted on the caller's data stack, providing independently relocated identity
references. The local run passed with `{ allocator t t }` for all four allocators
(`/tmp/full-gc-standalone2/output.log`, exit 0).

The final candidate's stronger reduced-bank suite is:

```sh
./factor -i=/absolute/path/to/factor.image -no-user-init \
  reference/allocator-full-verification-20260908/VALIDATE.factor
```

It runs `compiler.cfg.register-allocation.ssa.bases` tests, including 16 native
CFGs with four integer registers: four allocators, two pointer-phi forms, and
both rematerialization settings. These execute 384 fresh object pairs (768
objects). It also verifies that the original snapshot contains the selected
base and derived obligation, rejects removal of the final derived map, checks
preparation idempotence and fast paths, and checks context/statistics lifetime.

The local combined bases/dispatcher/verifier/validation run passed
(`/tmp/full-derived-base-all2/output.log`, exit 0). That run used greedy
`6537edf3f6`, backtracking `1234c3f9b0`, and the earlier chordal implementation;
the parent subsequently reported a successful full compiler suite with the
completed backtracking and chordal implementations and all checker flags on.
The parent integration run is the final implementation validation authority.

## Other independent checks

The validation vocabulary provides parameterized diamonds, simultaneous
three-value phi cycles, explicit GC clobbers, scalar/SIMD pressure across a
native ABI call, and independent arithmetic/identity oracles. The final bank
audit rejects a deliberately corrupted kernel that discards its supplied
reduced bank. Evidence checks reject missing/wrong algorithm identifiers,
nonzero fallback counts, and absent or zero required feature counters.

The phase suite checks early/late operand endpoints, def-is-use constraints,
scratch overlap, ABI memory operands, fixed memory tokens, a native two-register
addition without spilling, phi boundary separation, rejected late reloads,
and incoming edge initialization before a successor-entry reload.

The final-flow checker also rejects late-input/output alias corruption,
spilled scratch operands, malformed transport widths, missing GC relocation,
and mutable-array aliasing of phi/derived-map snapshots. These are finite
generated and adversarial tests, not a mathematical proof. Feature counters
are evidence that paths ran; implementation review establishes algorithm
structure. Native results cover the executed cases and target, while the
checker relies on Factor's original representation and GC base semantics.
