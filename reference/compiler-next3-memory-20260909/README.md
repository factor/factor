# Cross-block managed-slot load availability

Initial implementation and validation from `8780b3c090`, 2026-09-09. Production vocabulary: `compiler.cfg.memory-optimization`; flag: `memory-optimization?` (default false); stage: `optimize-memory ( cfg -- )`. The parent owns the optimizer hook, planned after existing SSA copy propagation and before LICM. The experimental `native.factor` harness adds the stage after the previous optimize-ssa body in its isolated process; no normal optimizer source is modified here.

The accepted ARM gate exited 0. Structural tests cover dominating reuse, sibling values that cannot supply a join, aliased stores on one incoming path, slot/tag distinction, loop backedge stores, and a transparent loop. An effect table explicitly checks 18 kinds of stores/calls/GC/allocation/barriers/unknown instructions. The native ordinary-source witness reads a mutable typed tuple field across a branch. Compilation with the stage enabled removed one load across the three native helper CFGs; mutation-bearing branch and loop helpers were unchanged. Fresh native words under OFF and ON settings match independent answers and observable mutations with identical as well as distinct object arguments. SSA and final allocation checks were enabled.

No performance conclusion is drawn from this correctness run. Counters and process durations include startup and tests. The longer-lived load result may increase register pressure, so promotion requires measured code/runtime effects.

## Integrated pipeline and native negative control

The follow-up `integrated.factor` gate uses the actual installed optimizer
hook from `84f2066b196c5e07e972bfa470364924026106c0`: memory reuse follows copy
propagation and precedes LICM. It does not replace `optimize-ssa`. It explicitly
loads the reviewed memory implementation and validation definitions, observes
the memory stage in this untimed process, and leaves sibling experimental
flags off. Both structural and native suites pass with SSA and allocation
checks. Configurable C-type `##unbox` and `##unbox-long-long` helpers explicitly
clear facts; the effect table now covers 20 instructions.

`memory-loop-work ( memory-cell n -- fixnum )` is an ordinary typed-source
hotloop with runtime arguments. The driver recompiles both its typed method
and wrapper under OFF and ON. Four initial field values and seven iteration
counts, including 100003, match `memory-loop-answer`, a separate period-four
checksum oracle. ON compiles two observed CFGs and eliminates one load; OFF
does not enter the stage. This proves activity and outputs, not a speedup.
Benchmark drivers must rebuild the typed method, rather than only a wrapper
which could call saved code.

`mutation.factor` is a deliberately unsound, isolated-process negative
control. It makes managed stores and write barriers transparent, then calls
the aliasing branch with the same runtime object in both argument positions.
The corrupted optimization returns 0; the independent correct answer is
`17 xor 91 = 74`, and the object really holds 91. Native results distinguish
the mutant although SSA and final allocation checks pass. Never load this
driver into a benchmark image.

Accepted raw logs, status, and environment are retained in `hotloop-arm`,
`mutation-arm`, and `integrated-arm`. The initial hotloop and mutation drivers
append the stage after the older optimizer; only the integrated gate validates
the final stage order. The first integrated attempt stopped at a harness
parse-time helper-loading error and is not accepted evidence. The integrated
source manifest hashes the actual reviewed implementation, tests, helper,
driver, and installed optimizer hook. These are correctness runs, with no
performance claim based on process duration.
