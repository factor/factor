# Preliminary native x86 results from source 233db947df

These runs established that the expanded workload harness compiles and executes
real code, and exposed a pre-existing chordal failure. They are **not the final
performance comparison**: later validation found a shared tagged-pointer
liveness bug as well. Final causal comparisons must use a baseline containing
both necessary correctness repairs.

Native CPU: AMD Ryzen 9 7950X3D, logical CPU 2, Ubuntu 26.04. The original source 233
VM, fresh bootstrap image and prepared 27,183-word closure are recorded by
`../environment-baseline.json`. Linux user-space retired counters and main-thread
CPU clocks work. The original VM and image artifacts remain on the isolated
remote host under `/home/erg/factor-allocator-speed-20260908`.

Linear scan, greedy and backtracking each completed checked full-closure
compilation plus all 26 workload checks, and an unchecked run with 3 measured
samples per workload. Native chordal failed during the full compile at
`compiler.cfg.gc-checks.private:update-predecessor-phis` with `bad-vreg {652 8}`
in the isolated reproduction. All failed logs and status records are retained.
No failed run is treated as a timing success or quietly excluded from its scope.

The initial linear-scan checked pilot calibrated the six pressure batches;
it used 20 arithmetic-pressure repetitions and 32 explicit collections. Final
unchecked samples use 600 repetitions and 4 explicit collections. Assertions use
the corresponding independently calculated totals. Checked timings are not ranked.

`chordal-repro.factor` in the parent harness directory reproduces the failure
from the original prepared image with GVN off and SSA/allocation checks enabled.
The diagnostic source 233 + coalescing candidate still failed before its boundary
fix. Candidate commit `dc1ad8b982` reserves missing live-through SSA edge spill
locations. The repaired candidate passed both the single-word reproduction and
a complete 27,183-word checked installation plus all 26 workload checks (40 records,
exit 0). That diagnostic loaded the candidate chordal source in a separate process;
the baseline source tree was left unchanged. `candidate-chordal-source-sha256.json`
records the tested source bytes. Generate the diagnostic input file with
`git show dc1ad8b982:basis/compiler/cfg/register-allocation/chordal/chordal.factor`
into the harness directory as `candidate-chordal.factor` before using the
`chordal-candidate-*` scripts.

The Python analysis independently validated captured MD5/SHA1 results, 1,000 pi
digits, tree counts and other original workload invariants. All26 captured
outputs agree across the successful runs, including the fixed-chordal checked
run. The six additional pressure workloads assert their outputs in Factor.
