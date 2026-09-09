# Integer-pressure same-process native diagnosis

This is a bounded diagnostic of the prior native integer-pressure excess: about38.4million retired instructions per600WORK invocations, or two instructions per inner iteration. No production source changes are involved.

Logical baseline c1f7e4d34c is measured using its retained tree-identical5c848 snapshot. Current1d67bdd034 is measured using its retained tree-identicala7f554 snapshot. `source-equivalence.json` records complete basis/core/extra/VM tree identities. Existing prepared images and capability-bearing VM are reused unchanged; exact hashes and executed source markers are in each status.

Four fresh processes execute B1 C1 C2 B2 on native CPU2, nice0. Each compiles its original frozen word-object closure with backtracking, rematerializationON, loop policyON, GVNOFF, allocation/SSA/final checksOFF. The original12 untimed kernel metrics remain. Only the integer-pressure runtime workload runs: one warmup and three measured batches. Each batch invokes WORK600times, and WORK invokes the kernel32,000times.

Installed code for the actual WORK word, integer kernel, generic `+` and fixnum `+` method is captured in the same process immediately before the counter starts and after it stops for every warmup/measured batch. There is no `generate` hook, detached recompilation, source instrumentation, or saved image. Captures occur outside the measured interval. All output assertions remain enabled. This changes diagnostic activity between batches, so comparison with prior matrix measurements must retain that qualification.

`make-integer-probe.py` derives the probe from the previously executed timing harness; `run-integer-pairs.py` records commands, source/image/VM hashes, affinity, priority, capability and hostload. All attempts and measured values are retained, with no selection based on performance. Analysis will compare actual installed hot paths and measured instruction counts before attributing the difference to code generation, alignment or event accounting.

## Result

All four processes passed, with 12 measured batches and128 installed-code snapshots (four targets before/after each of four batches per process, including warmups). Every target's actual address and complete installed bytes remain unchanged across each measured interval.

| Process | Median retired instructions | Median CPU seconds |
|---|---:|---:|
| Baseline1 | 3,447,577,498 | 0.145204542 |
| Candidate1 | 3,447,577,498 | 0.145947323 |
| Candidate2 | 3,447,577,574 | 0.146654477 |
| Baseline2 | 3,447,577,569 | 0.145686433 |

The paired retired differences are **0 and5 instructions**, not the prior38.4million. CPU ratios are1.00512 and1.00664; no speedup is inferred from this focused diagnostic.

All four actual installed integer kernels are704bytes and contain147 executed instructions through return. Baseline/candidate kernels differ in physical registers and spill-slot assignments, so this new evidence does not claim byte identity between source revisions. The installed WORK wrapper's normalized instruction stream and the generic addition's fast-fixnum path agree, and all outputs pass. The fixnum method also agrees. Generic addition's cold paths differ. Raw installed bytes and address-bearing objdump disassembly are retained; address normalization is only an instruction-structure comparison and does not establish equality of arbitrary external targets.

Both revisions now produce the prior candidate's higher retired count. The old source-correlated excess therefore **does not reproduce in this same-process focused diagnostic**. Omitting the other25 runtime warmups and adding snapshots outside each measured interval changes surrounding activity; the old matrix evidence remains intact. This does not establish alignment, PMU accounting, code replacement, or the entry-transport optimization as the cause. The bounded investigation stops here rather than selecting a favorable explanation.
