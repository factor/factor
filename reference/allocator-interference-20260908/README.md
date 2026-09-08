# Occupancy/cost-cache measurements (2026-09-08)

Implementation: `40daa1f79e`, baseline source: `233db947df`.
Default allocator remains linear scan; GVN is disabled for every comparison.

## Correctness and allocation policy

Thirty tests pass in `compiler.cfg.register-allocation.{occupancy,backtracking,greedy}`.
The occupancy tests exhaustively compare 903 inclusive query intervals against
pairwise range intersection for each of three index states. Backend tests cover
real evictions/splits and recomputed greedy priorities after splitting.

`policy.factor` compiles six workloads under both backends in separate fresh
processes with baseline and candidate source. Exact emitted native byte arrays,
all allocator statistics, and all per-pass instruction/spill/reload/copy/frame
counts are identical after removing timing fields. `policy-equality.json`
records the twelve matching fingerprints. These cases include integer/float
arithmetic, reduction, map, branching, and forty-value register pressure.
This establishes policy equality on that corpus; it is not an exhaustive proof
that every CFG emits identical code.

## Compile experiment

The fixed scope consists of the 25,958 **actual word objects** retained in
`benchmark-words` by the existing twenty-workload prepared image. The driver does
not reconstruct words by name. The scope includes compiler implementation code;
therefore each fresh process performs one measured compile, without compiling
the host using the tested allocator in a warm-up first. Source loading and
backend recompilation happen before timing. New helper definitions are initially
compiled by the host's default compiler. Each variant starts from the same image.

Host: Apple M5 Max, macOS arm64. CPU is `CLOCK_THREAD_CPUTIME_ID`; retired
instructions are process `proc_pid_rusage(RUSAGE_INFO_V4).ri_instructions`.
The native VM comes from the `233db947df` worktree. The frozen host image is the
historical benchmark prepared image (recorded source `3849b2f6`, SHA-256
`c62ce317ffc87dfe4ff9267421158ad0226e02b422d8782479bdd7f6d8440a3f`). This is an
isolated backend comparison, not an integrated bootstrap timing.

The initial samples in `initial-samples.json` are exploratory. They did not
record Mach background priority. Backtracking's baseline also omitted the
explicit `-resource-path` flag, although both baseline backend files were loaded
by explicit paths before timing. The candidate in these samples precedes the
final small empty-index/range-cache allocation optimizations. Do not treat these
samples as a controlled final CPU result:

| Backend | Baseline CPU s | Candidate CPU s | Baseline instructions | Candidate instructions |
|---|---:|---:|---:|---:|
| Backtracking | 55.595 | 63.876 | 968,842,247,976 | 520,007,596,834 |
| Greedy | 61.943 | 59.039 | 552,816,660,427 | 528,125,392,785 |

The guarded repeat uses identical explicit resource paths and records Mach
priority before/after compilation and on every yield. An external parent runs
`taskpolicy -B -p PID` every second; startup waits for a foreground observation.
The final paired samples are in `guarded-samples.json`. With baseline
`233db947df` versus final `40daa1f79e`, retired instructions fall from
969,036,555,406 to 514,606,665,204 (**46.90% fewer**). The scope count and SHA-256
match exactly. Both samples begin and end in foreground, but observe background
priority on 10/25,957 and 19/25,954 yields respectively. The CPU samples are
therefore **rejected for controlled CPU-speed claims**: raw thread CPU is
61.153 seconds versus 37.709 seconds, and wall time is 62.667 versus 39.066 seconds.
They are retained to expose the scheduling limitation rather than discard an
inconvenient observation.

No full-bootstrap speed claim follows from this experiment.

## Reproduction

The scripts record the local experiment paths. Put the script copies in
`work/interference-perf/` in the candidate worktree. Create the two baseline files
there using `git show 233db947df:basis/compiler/cfg/register-allocation/B/B.factor`
for `B=backtracking,greedy`, named `baseline-B.factor`. Point the image path in
`drive.py` at the original prepared image, and make its counters dylib available
at `reference/allocator-benchmarks-20260908/counters.dylib`. `drive.py` runs fresh
baseline/candidate processes sequentially. `policy.factor` uses the worktree's
fresh image and its loaded metrics vocabulary; run it separately with `baseline`
and `candidate`, the same explicit `-resource-path`, and `-no-user-init`.

`query.factor` is an optional, **unrun** short query-only microbenchmark. It
compares an old-style global assignment scan with indexed queries over 512
owners and eight registers in one process. It is included for follow-up
investigation and supplies no measurement evidence in this report.
