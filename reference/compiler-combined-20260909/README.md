# Combined compiler feature experiment

Compare all four new flags OFF against all four ON: loop optimization,
conversion-aware representation costs, memory optimization, and automatic SLP.
Linear scan is fixed; GVN, rematerialization, and backtracking loop spills are OFF.
No production default changes. The prior individual experiment is retained in
`reference/compiler-next3-20260909`.

Prepare one refreshed image per architecture. Run `queue.py check --prefix PREFIX`,
then `queue.py timing --prefix PREFIX`. Two strict gates precede the balanced
OFF / ON / ON / OFF timing queue; each timing process runs three measured batches
of 26 existing workloads and four witnesses, plus 16 compilation metric targets.
`analyze.py DIRECTORY --prefix PREFIX --output RESULTS` requires matching image,
VM, source, scope, outputs, trial counts, and checked/timed final static metrics.
Runtime assertions remain inside every invocation. Raw records and statuses are
retained. Source markers are separate from the prior allocator/feature datasets.

Production source is frozen at 6b14328972 (optimizer definitions unchanged from
020b74ce5d). Source and harness provenance are recorded separately.

To reproduce on this ARM worktree (the seed image is local and untracked):

```sh
python3 reference/compiler-combined-20260909/prepare.py \
  --image reference/compiler-next3-20260909/prepared.image --label arm-prepare
python3 reference/compiler-combined-20260909/queue.py check --prefix arm-combined
python3 reference/compiler-combined-20260909/queue.py timing --prefix arm-combined
python3 reference/compiler-combined-20260909/archive-arm.py
```

Use a new output prefix for a new run; preserve the published dataset. Preparation
saves a new benchmark image. It does not replace the main checkout's image.
The flag dictionary is read back from the compiler namespaces in each run's
`scope` record; ON must contain four true values and OFF four false values.
