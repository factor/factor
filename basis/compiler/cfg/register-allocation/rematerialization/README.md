# Constant rematerialization

This optional allocator lowering recomputes cheap constant bits at register
reloads and control-flow edges. It does not allocate a spill slot or emit a
spill store for an eligible constant. All four allocators use the same
numbering, splitting, assignment, and edge-resolution hooks.

Enable within a compilation scope:

```factor
USING: compiler.cfg.register-allocation.rematerialization namespaces ;
t rematerialize-constants? [ ... ] with-variable
```

The default is off pending whole-bootstrap and representative application
measurements. `rematerialization-count` reports actual materializations in
the current allocation scope. Its mutable statistics object survives the
nested scopes used by instruction builders and parallel-copy resolution.

Eligibility is deliberately narrow: exactly one original `##load-integer`
definition per coalesced leader, all operands in `int-rep`, and an immediate
in the signed 16-bit range. These immediates need at most one integer-load
instruction on ARM64 and PPC and a bounded immediate move on x86. No
floating-point, vector, tagged, reference, address, or wide-integer recipes
are supported. In particular, negative zero and NaN encodings never pass
through this lowering.

Any ABI memory operand, phi input, nonconstant definition, representation
alias, or GC root/derived-root reference disqualifies the whole leader.
Copies coalesced to multiple explicit definitions also disqualify it. These
restrictions intentionally leave unsupported forms spilling. A non-root
integer live across `##call-gc` can be restored from its recipe; GC-map slots
and actual ABI operand slots retain their ordinary allocation.

Recipes retain the original instruction identity. The optional
`rematerialization-observer` callback receives `( original-insn new-insn -- )`
before each generated load is emitted, permitting the value-flow checker
to verify both provenance and the actual immediate. Original definitions
remain present. Recipe locations have no mutable storage: incoming recipe
destinations need no edge move, and an outgoing recipe is materialized only
when the successor requires a register.

Tests execute native code with forty simultaneously live constants on all
four allocators, with rematerialization both on and off, through straight
line pressure, a diamond, a loop, and an actual collection. They also check
strict reductions in spills, reloads, stack spill bytes and generated code
bytes, and cover ABI, phi, multiple-definition, object, float, NaN,
negative-zero and wide-immediate exclusions. Existing shared spilling,
assignment and resolution unit tests also pass with the default off.

Native ARM64 measurements on the 40-constant executable pressure fixture
(September 8, 2026, prepared image based on `233db947df`):

| Allocator | Spills/reloads off → on | Spill bytes off → on | Code bytes off → on |
|---|---:|---:|---:|
| Linear scan | 24/24 → 0/0 | 192 → 0 | 544 → 432 |
| Greedy | 25/25 → 0/0 | 200 → 0 | 560 → 432 |
| Backtracking | 24/24 → 0/0 | 192 → 0 | 544 → 432 |
| Chordal | 25/25 → 0/0 | 200 → 0 | 560 → 432 |

These are final generated instruction/code-size measurements, not a claim
about representative runtime or bootstrap performance. Reproduce by running
the vocabulary tests, then calling `pressure-metrics` from the test vocabulary
with each allocator and `f`/`t`. Runtime and cold-bootstrap comparisons must
use fresh processes and the integration benchmark corpus.
