# Allocator tuning results

The demonstrated greedy, backtracking and chordal regressions are repaired.
Greedy and chordal improve aggregate native x86 runtime against their pre-tuning
versions; backtracking substantially reduces compiler work. **Linear scan remains
the default**, with GVN and rematerialization off. The alternatives have not
established a broad runtime win over linear scan on both architectures.
The separate default bootstrap passes in **1:52 core / 116.00 seconds whole
process**, and its saved image passes verification.

Baseline source is `7b6cd9519a71960a4fb0385bf6ceeaf66097d618`; the immutable combined
source executed on both architectures is
`5c848c90f63cea092191b70e1678bec4441e0238`. Integration history was rebased onto the
user's rewritten master-candidate with tree equivalence verified; executed
worktrees were unchanged.

## Implemented changes

- Greedy retains a terminal fragment already ending at its last use without
  adding a new trailing spill. Existing memory obligations and live-through
  tails retain their required stores. Native integer-pressure emission proves
  **57→29 actual stores**, unchanged 29 reloads, and unchanged 161 mandatory
  register assignments: [emission and assignment proof](native-greedy-provenance/README.md).
- Backtracking indexes allocated fragments once by original value, avoiding
  repeated scans and full-range work. Its independent occupied-point oracle
  and isolated comparison preserve all 26 answers and all 12 diagnostic kernel
  reports: [index attribution](native-backtracking-index/README.md).
- Backtracking omits no-use gaps strictly inside one block when they cannot
  connect two register fragments. Entry/exit and multiblock carriers remain,
  including the fast edge around an out-of-line GC block. This is a placement
  policy, not an assumption that a memory slot is initialized:
  [gap attribution](native-backtracking-gap/README.md).
- Chordal avoids speculative entry reloads when every predecessor is known and
  none supplies the value in a register. Fully known joins retain only memory
  homes valid on every path, avoiding redundant stores on a dirty common path.
  Unknown loop states remain conservative; later evictions still store before
  reloads. Native branch-pressure code falls **2256→2048 bytes**, stores 48→35
  and reloads 45→35: [chordal attribution](native-chordal-policies/README.md).

The isolated native diagnostic pairs measured greedy integer-pressure CPU −17.0%,
backtracking index compilation CPU −14.8%, gap-policy FFI CPU −5.7%, and chordal
branch-pressure CPU −22.2%. They establish attribution for the targeted changes;
the broader combined-source measurements below are the allocator comparison.
Static counts can move in different directions: the narrow gap policy's ARM
fixture changes stores 58→60 and reloads 55→57 while copies fall 36→20. Native
isolated FFI code grows 16 bytes while executed work falls. Static IR copies are
not necessarily emitted machine moves.

## Complete native x86 comparison

Ratios below compare each final allocator with its own pre-tuning baseline;
lower is better. Runtime uses an equally weighted geometric mean of 26 workload
ratios, each based on six timed batches from two fresh processes.

| Allocator | Runtime CPU | Runtime retired instructions | Compiler CPU | Compiler retired instructions |
| --- | ---: | ---: | ---: | ---: |
| Linear scan | 1.0027 | 1.0000 | 0.9864 | 0.9931 |
| Greedy | 0.9755 | 0.9879 | 0.9995 | 1.0105 |
| Backtracking | 1.0038 | 0.9972 | 0.8381 | 0.7856 |
| Chordal | 0.9797 | 0.9952 | 0.9868 | 1.0014 |

Greedy and chordal improve aggregate CPU in both rounds. Backtracking's runtime
CPU direction changes between rounds; its clear improvement is compiler work.
Against final linear scan, runtime CPU ratios are **1.0072 greedy, 1.0275
backtracking and 1.0298 chordal**. Compiler CPU ratios are respectively 1.0493,
1.0026 and 1.2919: backtracking compilation is now close to linear scan.

The repaired full-matrix pressure cases retain the expected changes: greedy
integer-pressure CPU 0.8303/retired 0.8638 with code 864→688; backtracking FFI
CPU 0.9916/retired 0.9671 with code 2000→2000; chordal branch-pressure
CPU 0.7909/retired 0.9441 with code 2256→2048. These combined-source comparisons
differ from the isolated gap diagnostic's index-only baseline.

Remaining losses are explicit in the [complete native report](native-x86-64/final-matrix/README.md).
For example, chordal SHA-1 retires 1.58% more instructions and uses about 3% more
CPU. Some larger CPU-only outliers are round-sensitive: backtracking base64 is
1.0013 then 1.3916 with essentially identical retired work. Do not describe those
as stable source-caused regressions. The report retains every workload, both
rounds, code metrics, commands and counter observations.

## Complete ARM64 comparison and limits

Again, each allocator versus its own pre-tuning baseline:

| Allocator | Runtime CPU | Runtime retired instructions | Compiler CPU | Compiler retired instructions |
| --- | ---: | ---: | ---: | ---: |
| Linear scan | 1.1002 | 1.0001 | 1.0071 | 1.0005 |
| Greedy | 1.0260 | 0.9897 | 0.9915 | 1.0034 |
| Backtracking | 0.9617 | 0.9949 | 0.7849 | 0.7599 |
| Chordal | 0.9568 | 0.9911 | 0.9984 | 1.0037 |

**ARM CPU ratios do not establish an attributable aggregate allocator win.**
Host load ranges 37–93. Unchanged linear-scan runtime retired work accompanies
about 10% more CPU, and all three alternatives reverse their own-baseline CPU
direction between rounds: greedy 1.1018/0.9705, backtracking 1.0072/0.9448,
chordal 0.8831/1.0275. Pooled ratios differ from separate-round ratios.

Against final linear scan, pooled runtime CPU ratios are 0.9669 greedy, 0.9464
backtracking and 0.9732 chordal, but retired ratios are 1.0001,1.0238 and 1.0770.
Those apparent time wins therefore do not justify promotion. See the
[complete ARM report](native-arm64/final-matrix/README.md) for per-round execution
rates and retained observations.

The targeted instruction-work reductions do survive the complete ARM matrix:
greedy integer-pressure retired 0.8802 and code 672→576; backtracking FFI
retired 0.9536 and code 1392→1344; chordal branch-pressure retired 0.9117 and
code 1472→1376. Whole-closure backtracking compiler retired work falls 24.0%.

## Correctness, protocol and bootstrap

Both architectures accept **16 timing processes and eight checked closures**,
covering **1,248 measured runtime batches and 208 checked outputs per host**.
Main options are rematerialization on, loop spilling on, GVN off. Each selected
allocator recompiles the full frozen closure, including new compiler helpers;
workloads invoke the resulting code dynamically. Within each revision the
ordered closure is identical across allocators. Baseline/candidate closures
contain 28,484/28,489 words on x86 and 27,351/27,356 on ARM.

The [acceptance record](ACCEPTANCE.md) retains full compiler verification,
independent spill/reload and phi tests, and final-machine value-flow checks.
Both revisions pass actual C ABI callbacks and moving-GC tests across all four
allocators with rematerialization off/on: 160 C ABI assertions and 1536 fresh
object pairs. Matching VM and original image hashes, exact source manifests
and gate outcomes are retained in [the gate archive](gates/acceptance.json).

One ARM launcher attempt finished Factor before the final priority refresh,
causing an exited-child race. Its unaccepted log and exact driver revision are
preserved in [the race record](arm-driver-exit-race/reason.json); the same slot
was rerun after a narrow launcher repair. No accepted observation was discarded
based on performance. The collector rejects missing samples, wrong answers,
changed options/scope order and failed counters. Six batches from two processes
do not provide six independent process replications.

The unprofiled default bootstrap saves and validates a separate image in the
final-candidate worktree. It meets the two-minute budget in this run, and the
root image hash is unchanged: [bootstrap evidence](default-bootstrap/README.md).
Retired work is within 0.2% of the previous 2:12 core observation, so the faster
bootstrap does not establish a default-path source optimization from these
opt-in allocator changes. Preserve that execution-rate limit alongside the
successful **1:52 core / 116.00-second whole-process** result.
