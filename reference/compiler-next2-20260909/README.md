# Integer-pressure same-process native diagnosis

This is a bounded diagnostic of the prior native integer-pressure excess: about 38.4 million retired instructions per 600 WORK invocations, or two instructions per inner iteration. No production source changes are involved.

Logical baseline c1f7e4d34c is measured using its retained tree-identical 5c848 snapshot. Current 1d67bdd034 is measured using its retained tree-identical a7f554 snapshot. `source-equivalence.json` records complete basis/core/extra/VM tree identities. Existing prepared images and capability-bearing VM are reused unchanged; exact hashes and executed source markers are in each status.

Four fresh processes execute B1 C1 C2 B2 on native CPU 2, nice 0. Each compiles its original frozen word-object closure with backtracking, rematerialization ON, loop policy ON, GVN OFF, allocation/SSA/final checks OFF. The original 12 untimed kernel metrics remain. Only the integer-pressure runtime workload runs: one warmup and three measured batches. Each batch invokes WORK 600 times, and WORK invokes the kernel 32,000 times.

Installed code for the actual WORK word, integer kernel, generic `+` and fixnum `+` method is captured in the same process immediately before the counter starts and after it stops for every warmup/measured batch. There is no `generate` hook, detached recompilation, source instrumentation, or saved image. Captures occur outside the measured interval. All output assertions remain enabled. This changes diagnostic activity between batches, so comparison with prior matrix measurements must retain that qualification.

`make-integer-probe.py` derives the probe from the previously executed timing harness; `run-integer-pairs.py` records commands, source/image/VM hashes, affinity, priority, capability and hostload. All attempts and measured values are retained, with no selection based on performance. Analysis will compare actual installed hot paths and measured instruction counts before attributing the difference to code generation, alignment or event accounting.

## Result

All four processes passed, with 12 measured batches and 128 installed-code snapshots (four targets before/after each of four batches per process, including warmups). Every target's actual address and complete installed bytes remain unchanged across each measured interval.

| Process | Median retired instructions | Median CPU seconds |
|---|---:|---:|
| Baseline 1 | 3,447,577,498 | 0.145204542 |
| Candidate 1 | 3,447,577,498 | 0.145947323 |
| Candidate 2 | 3,447,577,574 | 0.146654477 |
| Baseline 2 | 3,447,577,569 | 0.145686433 |

The paired retired differences are **0 and 5 instructions**, not the prior 38.4 million. CPU ratios are 1.00512 and 1.00664; no speedup is inferred from this focused diagnostic.

All four actual installed integer kernels are 704 bytes and contain 147 static disassembled instructions from entry through the first return. Baseline/candidate kernels differ in physical registers and spill-slot assignments, so this new evidence does not claim byte identity between source revisions. The installed WORK wrapper's normalized instruction stream and the generic addition's fast-fixnum path agree, and all outputs pass. The fixnum method also agrees. Generic addition's cold paths differ. The 147-instruction count is a static path count, not a hardware branch trace. Raw installed bytes and address-bearing objdump disassembly are retained; address normalization is only an instruction-structure comparison and does not establish equality of arbitrary external targets.

Both revisions now produce the prior candidate's higher retired count. The old source-correlated excess therefore **does not reproduce in this same-process focused diagnostic**. Omitting the other 25 runtime warmups and adding snapshots outside each measured interval changes surrounding activity; the old matrix evidence remains intact. This does not establish alignment, PMU accounting, code replacement, or the entry-transport optimization as the cause. The bounded investigation stops here rather than selecting a favorable explanation.
