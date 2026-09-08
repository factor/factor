# Native allocator improvement comparisons

This extends the completed 20-workload experiment in
`allocator-benchmarks/reference/allocator-benchmarks-20260908` on the
`benchmark/register-allocators` worktree. It preserves the full forward compilation
closure (source references, recorded dependencies, generic methods and dispatch
engines), fixed batches, installed code, checked validation, and foreground
scheduling guards. The source baseline is `233db947df`.

Six added workloads create real register pressure: 32 live scalar floats,
40 live integers, a two-arm branch under float pressure, 32 live SIMD values,
32 float values live across a real foreign call, and 32 heap references live
across explicit full GC. Inputs vary across 32 values and exercise both branch
arms. Each workload asserts an independently calculated integer or exactly
representable floating result. `ffi.c` implements the foreign function separately.
The existing scalar/SIMD nbody and matrix exponential workloads provide broader
numerical and loop coverage; hashes, pi digits and tree counts retain the original
independent Python checks.

`metric-workloads` chooses 12 actual kernel definitions for final emitted code
size, spill/reload/copy instruction counts, frame size and allocator diagnostics.
These diagnostic compilations run after the timed full-closure installation and
before warmup; they do not install code or contribute to compile timing. The
original dispatch audit already established that concrete allocator methods run.

Native x86-64 uses the previously documented SSH host `agent1`, an AMD Ryzen 9
7950X3D. Its isolated directory is `/home/erg/factor-allocator-speed-20260908`.
The VM is built from baseline source; the seed image only generates a matching
boot image, followed by fresh native bootstrap. CPU affinity fixes all measured
processes to logical CPU 2. The machine is shared: affinity does not reserve a
core or prevent contention. Existing other jobs are left untouched.

Linux retired-instruction counters use a per-thread `perf_event_open` hardware
counter with kernel/hypervisor excluded. `CAP_PERFMON` is granted only to the
isolated Factor executable because the existing host policy
`perf_event_paranoid=4` blocks unprivileged access. No global kernel policy is
changed. Counter open/read failure aborts, rather than silently producing zeros.
Main-thread CPU time comes from `CLOCK_THREAD_CPUTIME_ID` on both platforms.
macOS retired counts use process `proc_pid_rusage`, as in the original experiment;
thus absolute Linux/macOS retired counts have different scopes and must not be
compared across architectures. Compare candidates with their same-host baseline.

macOS retains the external `taskpolicy -B -p PID` application after one second,
Mach effective-priority guard (at least 20), foreground helper and rejected-sample
retry. These prevent the earlier background-mode timing error without claiming
exclusive cores or fixed frequency. Linux checks the process nice value.

Both architectures leave GVN disabled and the default allocator linear scan.
Checked runs enable SSA and allocation checkers; unchecked timing runs disable
both. A full GC precedes each sample outside timing; GC performed by the workload
is included. Warmups use trial -1 and never contribute to timing aggregates.

## Running

Build `counters` from the platform counter C source and `ffi.c` as a shared library.
Run `prepare.factor` from the matching fresh image, then use `drive.py` with a
baseline/candidate label, `--mode check` or `--mode timing`, `--samples 3`, and
`--rounds` as needed. Each process recompiles and installs the entire frozen
word-object sequence. `drive.py` asserts complete record counts and retains the
exact command, status, CPU affinity, and elapsed driver time. `provenance.py`
records artifact hashes and machine/compiler information.

The default remains linear scan. Measurements, including compile regressions and
per-workload tradeoffs, must be assessed on both architectures before proposing
any default change.
