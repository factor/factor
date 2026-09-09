# Backtracking entry-transport profitability

Base: frozen `eccfc0accc`. The earlier `784a05ead7` entry-transport change
delegated eligible successor reloads to incoming edges. This eliminated useful
register-to-slot-to-register round trips, but also duplicated a shared reload
when every predecessor already carried its value in the same spill home.

The correction retains the original reload through assignment and decides
from the actual published predecessor locations. All locations equal the
reload home: retain one successor reload. Otherwise, delegate to the existing
parallel edge resolver. It does not infer residency from interval hulls or run
a second allocation/assignment pass.

Shared phase assignment optionally records the exact instructions emitted
while activating selected entry intervals. The table is passed explicitly,
with no observer namespace or retained state. Existing callers keep the
original activation loop when recording is absent. Backtracking validates
the recorded source, destination, representation and incoming map before
removing only those recorded objects by identity. A structurally equal later
reload is preserved. Existing phi/GC/ABI/kill-block exclusions remain intact.

`focused-tests/output.log` runs the explicitly loaded backtracking subtree
and ends with `BT-PROFITABILITY-GATE PASS`. New cases cover an actual common-home
CFG with final symbolic checking, different memory homes, mixed memory/register
locations, and identity-only removal. Existing parallel swaps, corruption
rejection, native loop/GC and callback fixtures remain enabled. The initial
attempt without explicitly loading the backtracking vocabulary executed no
tests; it is excluded from this evidence. No recorder cleanup is necessary on
success or failure because its lifetime is lexical and no global observer is
installed.

`checked-probe/output.log` measures three ARM kernels with GVN off,
rematerialization on, and SSA/interval/final-value checks on. It additionally
executes freshly compiled branch code and checks results 3672 and 16712.

| Kernel | Code bytes | Final stores | Final reloads | Blocks | Delegated entries |
| --- | ---: | ---: | ---: | ---: | ---: |
| FFI pressure | 1312 | 56 | 55 | 6 | 2 |
| Branch pressure | 1264 | 31 | 31 | 8 | 0 |
| Integer pressure | 576 | 25 | 25 | 3 | 0 |

The branch kernel returns to the original 31-reload/eight-block shape while
FFI keeps direct entry transports. These are checked static diagnostics,
not runtime speed measurements. The parent owns matched native remeasurement
and combined compiler gates. Exact modified source hashes, VM/image hashes,
commands and raw logs are retained alongside this note. Defaults are unchanged.
