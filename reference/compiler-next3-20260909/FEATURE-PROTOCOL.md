# Isolated feature protocol

`prepare.factor` loads the four compiler features and the owners' definitions-only witnesses, computes the independent SLP checksum outside measurement, resets every feature flag **globally** to false, asserts those globals, and saves one common image. It freezes a closure containing all 30 runtime roots and all 16 metric roots, including the actual typed LICM/memory kernels. Source identity comes from an immutable `.allocator-source-commit` marker and production manifest, not later evidence-only Git commits. The retained 8780/ad0 image is the input seed, not the output candidate image.

Required witness files are the committed loop/repr `workloads.factor`, memory validation vocabulary, and vectorization `kernels.factor` plus `workload.factor`. Their executed hashes must be captured with the candidate manifest. No feature activation or observer is installed by those files. All four runtime wrappers invoke mutable/selected word handles to prevent stale inlined scalar bodies. The benchmark recompiles those exact target objects under the selected flag.

`drive.py` retains the previous CPU2/counter/macOS priority guards. Arguments add `--feature loops|representations|memory|slp --enabled off|on`. LS, GVN off, rematerialization off, and backtracking loop spilling off are defaults. Each fresh process resets every new feature off, then activates only the selected feature and records actual readback. Every process uses the same source, common image, 30 runtime cases, 16 metric cases, and selected word sequence. Witness batches are fixed: LICM10×10,000,001 loop iterations; representation50×10,000; memory10×1,000,003; SLP50×200,000 kernel calls. Existing 26 batches are unchanged.

Before timing, run the all-off checked closure and each individually enabled checked closure. Require strict SSA, interval, final-value verification, exactly 30 matching language outputs, all 16 metric targets, and identical scope. Owner positive-activity/native/edge-case gates remain separate from timing. Then use two balanced rounds of the five unique configurations: OFF, loops, representations, memory, SLP / SLP, memory, representations, loops, OFF. Ten fresh processes retain two independent process observations per actual configuration and three measured batches per case per process: 900 measured batches. The two OFF anchors are shared across comparisons, so the four estimated effects are correlated and ON states differ in temporal distance from their anchors. Report both rounds and execution-rate variation; make no significance claims. An explicit `--protocol individual` option retains the earlier16-process OFF/ON/ON/OFF design, but the current matrix uses `--protocol shared`. Report original 26 corpus and each witness separately; do not let a constructed witness determine a broad-corpus conclusion. No 16-way factorial is planned.

Example after a source freeze and successful common preparation:

```
python3 reference/compiler-next3-20260909/drive.py native-loops-on --feature loops --enabled on --mode check --allocator linear-scan --image ABS_PREPARED_IMAGE
```

Preparation and full end-to-end execution await the final compiler freeze. The configuration/timing definitions have passed a standalone native syntax gate; this is not a claim that candidate feature gates or timings have run.
