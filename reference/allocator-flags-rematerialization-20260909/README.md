# Rematerialization activation and safety audit

Base `ad0fc337de`; tests commit `02be782537`. No production or default changes.
All evidence here is native ARM64. Native x86 verification and the factorial
GVN/rematerialization benchmark matrix are separate evidence owned by the parent.

## Activation and coverage

Load `compiler.cfg.register-allocation.rematerialization`, then set
`rematerialize-constants?` to `t` in the compilation scope (or globally in an
isolated compiler process). Set it to `f` to disable. The symbol has no enabled
production default. GVN is independently controlled by
`compiler.cfg.value-numbering:global-value-numbering?`.

This implementation is restricted cheap integer-constant rematerialization,
not general recomputation of arbitrary expressions. It operates during allocation
and move reification, not as an executable-code peephole. `number-instructions`
prepares the per-CFG recipe table; chordal's source-spilling construction also
prepares recipes. Linear scan, greedy, backtracking and chordal all consult the
shared recipe locations when assigning spill/reload transport. SSA and linear-scan
edge resolution can materialize a recipe into the destination register. A recipe
location has no storage; stores into it are omitted.

The `loads` statistic, exposed by `rematerialization-count`, counts emitted recipe
instructions. The separately retained allocator statistics show actual algorithm
activity and zero fallback for the alternatives. Linear scan does not expose
allocator-specific counters through the generic diagnostics API.

## Safety audit

A recipe requires exactly one original definition for its leader, opcode
`##load-integer`, `int-rep`, and an integer literal between -32768 and 32767.
Any second definition of that leader rejects the recipe; equal literal bits or
leader membership alone are not treated as provenance. The original instruction
identity is retained for the optional final value-flow verifier.

Eligibility is rejected for every value used by an ABI clobber instruction, every
phi input, every value appearing in a GC root or derived-root map (both keys and
values), and non-integer representations. Tagged references, tagged constants,
floating-point constants (including negative zero and NaN), and wide integers
keep ordinary storage/relocation behavior. This conservative policy prevents
recipes from replacing required memory operands or GC-visible homes.

The finite literal range costs at most one native immediate-load instruction on
ARM64: MOVZ/MOVN, or a logical-immediate alias. The local ARM emitter selects
zero/ones halfwords before emitting additional MOVKs; these signed 16-bit values
never require extra halfwords. x86 uses MOV (or XOR for zero) without a literal
relocation. The audit relies on the repository's actual emitters. No float,
object, GC relocation, or NaN equivalence is inferred from integer representation.

Shared spill assignment omits a spill home only for eligible recipes and installs
a recipe as the later reload location. At CFG edges, the same location model
performs reconstruction. The final checker snapshots original constant literals,
checks the observer's original/clone pairing and literal/opcode, checks the final
instruction again, and preserves simultaneous resident copies of the original
value. No new correctness defect was found in this audit.

## Executed tests

`check.factor` refreshes the isolated image and runs the rematerialization subtree
with GVN off, then on. Both report zero failures. Every allocator runs OFF/ON
native straight-line pressure, diamond, loop and explicit GC fixtures with final
value-flow and interval checks. Existing source-level branch/loop/collection
compile-call oracles also run in both GVN settings. New tests add explicit direct
GC-root exclusion, clearing per-CFG recipes/statistics on OFF-after-ON, and signed
constant pressure: forty simultaneous live constants include -32768 and -16 bits,
with an independently checked native sum of -20.

`verifier-check.factor` separately runs the parent verifier subtree (zero
failures), including the positive simultaneous resident/rematerialized-copy case,
wrong recipe literal rejection, and corruption after observer notification.
All three completed processes exited 0. Logs and input/VM/source hashes are
retained; the driver contains the exact loaded vocabularies and flag bindings.

## Actual non-no-op allocator witness

`metrics.factor` constructs forty simultaneously live constants, calls the real
selected allocator with strict checks, builds the frame and generates native
code. Each allocator is measured with rematerialization off and on. These are
static counts, not runtime speed measurements.

| Allocator | Spills OFF→ON | Reloads OFF→ON | Spill bytes OFF→ON | Code bytes OFF→ON | Emitted recipes ON |
| --- | ---: | ---: | ---: | ---: | ---: |
| Linear scan | 24→0 | 24→0 | 192→0 | 544→432 | 24 |
| Greedy | 25→0 | 25→0 | 200→0 | 560→432 | 25 |
| Backtracking | 24→0 | 24→0 | 192→0 | 544→432 | 25 |
| Chordal | 24→0 | 24→0 | 192→0 | 544→432 | 24 |

All frames become zero-sized. The full per-allocator counters are in
`pressure-metrics.json`. Backtracking changes allocation choices as well as
transport: splits 24→25, evictions 0→2, and bundle merges 39→38. Greedy and chordal
retain their main allocation counts while replacing reload definitions/transport.
Thus an enabled flag is demonstrably active in every backend, including the
default linear-scan backend, but cannot be assumed to improve every workload.

The direct CFG witness deliberately enters after GVN and therefore provides no
GVN activity evidence or synergy claim. Source-level equivalence under both GVN
settings is correctness evidence only. Broader factorial measurements must report
runtime and compile costs independently; synthetic pressure code-size/spill wins
do not establish runtime speedup or justify changing defaults.
