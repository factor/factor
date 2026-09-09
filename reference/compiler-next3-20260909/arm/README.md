# ARM64 feature comparison

All five isolated configurations and the all-four-enabled corpus gate pass strict SSA,
interval and final value-flow checks. The 27,834-word scope and all 30 workload outputs
match. Ten balanced fresh timing processes contribute 900 measured batches; both OFF
anchors are shared across comparisons. No measured runs were discarded.

[MEASUREMENTS.md](MEASUREMENTS.md) contains every feature and both rounds;
[results.json](results.json) retains every case. Negative percentages mean less work/time.
The original 26 workloads are separate from four deliberately constructed witnesses.

The representation witness is the clear large effect: roughly 67.5% fewer retired
instructions and 75.0% less CPU time. Its separate allocation probe changes 1,000 loop
float allocations to one exit box. The witness exercises a specific cost-model mismatch,
not typical performance of arbitrary Factor programs.

ARM CPU observations vary materially even for unchanged controls. For example, under
SLP the representation witness has essentially unchanged instructions and final code,
yet its aggregate CPU time falls about 24.4%. Small CPU deltas and the SLP witness's
observed +17.0% CPU therefore do not establish a general execution-rate conclusion.
Priority controls do not establish a fixed clock, core placement or identical execution
conditions. The report retains all observations without attributing this variation.

Across the original 26 workloads, retired-work geometric means change by only about
+0.015% to +0.055%. There is no broad measured gain supporting default promotion.
Compilation retired-work changes are +0.131% LICM, +0.468% representation costs,
+1.747% memory reuse and +0.770% SLP; CPU time varies much more than these work counts.

All 16 timed final static reports match their checked versions and repeat across rounds.
The original 12 all-OFF reports exactly match the retained old baseline. LICM can keep
identical total code bytes while moving instructions out of a loop. On ARM, memory's
witness shrinks 512→496 bytes, SLP 272→208, representation 1840→1792; scalar nbody
instead grows 3120→3168 under the representation policy.

macOS instruction counters and native Linux user-instruction counters have different
coverage. Compare ON/OFF ratios within an architecture, not raw counter totals across
architectures. There are two independent timing processes per actual configuration;
900 batches are not 900 independent compiler experiments.

The measured compiler source is 020b74ce5d. The exact measured script versions are in
executed-harness/, and their hashes match every retained run status. Later test-portability
and parser-import cleanups do not change production optimizer source. No bootstrap was
performed or timed in this matrix; preparation refreshes an existing pinned image.
