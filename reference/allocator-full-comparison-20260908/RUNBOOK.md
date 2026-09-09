# Final native comparison sequence (prepared, not launched)

The baseline is prototype `0b52875640` plus accepted surgical correctness fixes;
it must not inherit a new allocator policy, SSA extraction, or phase model merely
to make a patch apply. Final compiler commits and image hashes remain pending.
No final matrix starts until all three complete pipelines pass acceptance.

1. Freeze baseline/final source and the harness; record the complete baseline fix
   list. Use the same native VM and initial image per architecture. Prepare fresh
   images with explicit resource paths. Record source, VM, image, and harness
   hashes and the ordered compiler word-object closure. Within each revision all
   four allocators install this exact closure. Revision helper counts may differ;
   every new helper must be included, with no hidden linear-scan installation.
2. On ARM64 obtain the parent CPU lane after compiler acceptance and the separate
   default bootstrap experiment. Retain Mach priority/counter guards and external
   `taskpolicy -B` orchestration. On native x86 use isolated `agent1` directories,
   CPU 2, and the existing per-thread userspace perf counters. Inspect host jobs
   first, leave unrelated jobs untouched, and record load. The physical hosts can
   run concurrently. Do not compare absolute counters between architectures.
3. Run all four allocators on both revisions in checked mode: 26 independent
   expected outputs, allocation constraints, and final value-flow verification.
   Run concrete method and policy-body dispatch audits in separate disposable
   processes. Record actual mechanism witnesses and forbid another allocator's
   policy loop. Keep instrumentation out of timing images/processes.
4. Main configuration is **rematerialization ON, backtracking loop-spills ON,
   GVN OFF on both revisions**. The loop flag only affects its applicable backend.
   These are experimental comparison options, not new defaults. The default LS,
   rematerialization-OFF, GVN-OFF cold bootstrap has a separate two-minute goal.
5. Run the following command on each host after replacing both directory paths.
   Removing `--dry-run` is an execution step reserved for the accepted freeze:

   ```sh
   python3 reference/allocator-speed-crossarch-20260908/pair.py \
     /absolute/baseline /absolute/final \
     --rounds 2 --samples 3 \
     --baseline-rematerialize on --candidate-rematerialize on \
     --baseline-loop-spills on --candidate-loop-spills on --dry-run
   ```

   The 16 fresh timing processes are 4 allocators × 2 revisions × 2 rounds.
   Round 1 visits LS, greedy, backtracking, chordal, baseline then final.
   Round 2 visits greedy, backtracking, chordal, LS, final then baseline.
   Each process compiles the entire frozen closure, records 12 kernel code
   reports, warms each workload, and records 3 samples on each of 26 workloads.
   Thus each allocator/revision has 6 measured samples per workload, and the
   whole architecture has 1,248 measured runtime batches. Checked runs and
   warmups are excluded. Fixed batch sizes match both revisions and allocators.
6. Retain raw JSONL, status, source/flags/scope provenance, compile CPU/retired,
   runtime CPU/retired, and final code size, spill/reload/copy/frame metrics.
   Require all expected outputs, both rounds, six samples, finite positive
   metrics, stable final code, and exact configuration/source consistency.
   Use the paired analyzer for each allocator's before/after comparison and
   `rank.py` for final-source comparisons against final LS. Report per-round
   variation and individual workloads alongside geometric means. These two
   reports use the same matrix; no redundant second timing matrix is needed.

## Lane estimate from retained observations

Native x86 prototype processes took 79.6–98.5 seconds, including 43.6–61.9 seconds
compiling the closure. Sixteen comparable processes imply about 22–30 minutes,
plus roughly 10 minutes for eight checked processes and 1–2 minutes preparing
images: **33–42 minutes on the native x86 lane**. Completed algorithm compilation
may cost more. Historical ARM ordinary processes took 52–128 seconds; a 495-second
record contains a parent-requested pause and is excluded. Given host execution-rate
variation, reserve **35–50 minutes on ARM including preparation/checks**, then
refine from the first accepted pair. These are scheduling estimates, not cutoffs.
An optional final-LS rematerialization OFF/ON attribution adds two timing processes
per architecture, approximately three minutes at the earlier x86 rate.

The old measurements used a smaller/older ARM closure and prototype policies;
they establish an order-of-magnitude schedule, not predicted final speed.
