# Forced-memory fixture under global rematerialization

The full compiler gate and native x86 gate found one new fixture failure when
rematerialization was globally enabled. `number-instructions` freshly discovered
recipes for the fixture's integer constants 11 and 22; this was not stale recipe
state. The hand-authored intervals nevertheless assumed spill-slot homes. The
actual predecessor map could legitimately contain a recipe, so the profitability
guard delegated the edge and emitted a constant load. This direct-snapshot
mechanical fixture also did not install the active rematerialization provenance
context, so the strict checker rejected that generated load.

Test-only commit `96ca4b90f2` replaces the constant definitions with distinct
runtime `##peek` inputs. This makes the intended memory-home premise valid under
either rematerialization setting. It changes no production allocator, checker,
recipe rule or global flag. Existing mixed-location/cycle/mutation cases use the
same stronger fixture.

The original fixture fails in `negative-on` (exit 1). The explicitly loaded
backtracking subtree then passes with the fix under global rematerialization
on and off (`fixed-on`, `fixed-off`, both exit 0), with SSA and final allocation
checks enabled. The earlier failing full-compiler log is also retained. Exact
test-source, VM/image hashes and runner metadata accompany the raw output.
