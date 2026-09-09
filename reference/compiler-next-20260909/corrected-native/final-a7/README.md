# Corrected native backtracking comparison

Executed final source **a7f554b613bd763fb7fbfc520643b75b321a6e16**, versus logical baseline **c1f7e4d34cd604bbdf22576b237406b39758896d**. The retained baseline's executed source marker is **5c848c90f63cea092191b70e1678bec4441e0238**; its compiler/core/extra/VM trees are identical to c1. This compares the combined final source under backtracking, including the class-algebra and selector optimizations; it is not isolated attribution to the entry-transport policy.

The guarded native Linux x86-64 sequence passed: explicit backtracking unit file, both revision checked closures, final chordal checked closure, all four allocators' real C ABI callbacks with rematerialization off/on, and moving-GC gates. All 26 numerical outputs agree. Timings used CPU 2, nice 0, the same capability-bearing VM and initial image, rematerialization ON, loop-spill policy ON, GVN OFF, checks OFF. Separate checked processes enable the final value-flow verifier. Exact commands, source/image hashes, load snapshots and scripts are retained alongside each status.

Four timing processes ran B1 C1 C2 B2, with six measured runtime samples per case and revision (312 measured batches), and two whole-closure compiler observations per revision. Every accepted observation is retained. `summary.json` audits source, helpers, counts and gates; `case-details.json` contains every case's raw samples, per-round ratios and 12 kernel metric comparisons.

| Candidate / baseline | CPU time | Retired instructions |
|---|---:|---:|
| Whole selected compiler closure | 0.983492 | 0.986848 |
| Runtime geometric mean, 26 cases | 0.985704 | 0.999446 |
| Runtime geometric mean, round 1 | 0.996769 | 0.999444 |
| Runtime geometric mean, round 2 | 0.975432 | 0.999448 |

The overall runtime retired-work difference is only −0.0554%. CPU changes vary more across rounds, so they do not establish a broad allocator speedup.

| Focused runtime case | Round 1 retired ratio | Round 2 retired ratio | Pooled CPU ratio |
|---|---:|---:|---:|
| FFI pressure | 0.984522289 | 0.984548850 | 0.835568 |
| Branch pressure | 0.999949263 | 0.999981314 | 0.997682 |
| Integer pressure | 1.011263684 | 1.011263731 | 1.010722 |
| SIMD pressure | 0.985554853 | 0.985585813 | 0.975203 |
| Base32 | 0.999992383 | 0.999997226 | 0.971272 |

The corrected policy removes the prior branch regression and retains the FFI improvement. FFI machine code falls 2000→1952 bytes, with four fewer stores, two fewer reloads and two fewer blocks. Branch returns to 1856 bytes, 31 stores, 31 reloads and eight blocks. Integer pressure retains a systematic +1.1264% retired-work regression: median excesses are 38,399,996 and 38,400,001 instructions over 19.2 million inner iterations, effectively two extra instructions per iteration. Its origin is investigated in the separate untimed captures below; it is not dismissed as timing noise.

## Selected scope and shared-phase bracket

The baseline scope contains 28,489 actual word objects; final contains 28,500. All 26 benchmark entrypoints remain. Thirteen reachable helper words are added and two now-unreachable non-recording phase wrappers leave the closure (`assign-phase-ssa-block` and `assign-phase-ssa-registers`). Exact lists are in `summary.json`. The classes.algebra `class-and`/`class-or` and new recording/profitability APIs are explicitly required in the selected closure. Each revision retains its exact frozen object sequence across checks and timing processes.

A separate chordal compile-only bracket used pre-fix ecc / final a7 / pre-fix ecc, with scopes **28,493 / 28,500 / 28,493**. Final compilation costs **+0.77518% retired instructions** and **+0.24812% CPU** versus the mean of its two neighbors. This is the correction's whole-closure cost, including added helper definitions. It does not isolate steady-state recording-hook overhead. The exact three observations and scripts are under `chordal-bracket/`.

## Actual generated code captures

The untimed hook records physical CFGs and the actual code descriptor emitted while the selected frozen closure is compiled and installed. It does not recompile a wrapper after measuring it. Instrumented images are never saved or used for timing. Positive target-presence assertions prevent empty captures from passing. These are separate-process identities, not retrospective captures from the timed processes.

The extended capture proves the actual `integer-pressure` kernel (704 bytes, no call literals) and `integer-pressure-work` wrapper (208 bytes) have identical emitted bytes, relocation streams, parameters, literals and complete physical instruction streams across baseline/final. The wrapper calls the kernel and `+` per inner iteration, then `assert=` once. The separate addition capture finds the 64-byte fixnum method identical. The 5392-byte generic `math:+` differs only beyond its identical non-overflow fixnum fast path (entry through return at offset 0x46; first byte difference at offset 129 in a float/GC path). Its relocation and literal streams are identical. These checked captures therefore do not explain the two-instruction difference. A final capture with checks OFF closes the compiler-configuration gap below.

The two `base32-work` captures are both 1376 bytes but differ in code/relocations and physical register-copy placement. This establishes a source-revision code difference in these captures; it does not establish the cause of earlier same-source process variation. Current base32 retired ratios are flat across both rounds. Machine-IR `##copy` counts are not emitted move counts: same-register copies can disappear during emission.

The initially rejected c694 unit fixture and capture parser attempt remain outside accepted measurements in sibling directories. The unit failure was a test-premise error: rematerializable constants invalidated its assumed common spill home. The final test uses runtime peek inputs, preserves rematerialization ON, and passes. Production c694 and a7 are byte-identical; the correction is test-only.

### Final timing-flag and installed-code audit

The final two untimed processes use the exact timing compiler flags (all allocation/SSA/final checks OFF, rematerialization/loop policy ON, GVN OFF), run the ordinary output assertions, and collect zero measured timing samples. The same integer kernel, WORK wrapper and fixnum method identities hold, as does the generic addition's identical fast-fixnum path. They therefore do not explain the measured excess.

Installed-code snapshots were taken immediately after selected closure installation and after the output passes. Addresses and relocated operand bytes change across the intervening GCs. Masking only fields described by each actual relocation stream proves every captured target's remaining installed bytes unchanged within each process. This normalization follows the x86 relocation class/offset encoding in `vm/instruction_operands.hpp` and patch widths in `vm/instruction_operands.cpp`. Both before and after output passes, decoded WORK call destinations match the captured kernel and generic `+` entry addresses exactly. Raw installed bytes, disassembly, call destinations and normalization audit are retained under `timing-flags-capture/`.

These separate diagnostic processes close the tested configuration and observed later-replacement gaps. They still do not capture the exact machine-code/state of the earlier timed processes or prove the cause of their systematic two-instruction excess. That +1.1264% observation remains an explicit unresolved limitation. No further workload timing or source change was made to erase it.
