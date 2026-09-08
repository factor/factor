# Register allocator comparison

All three alternatives were developed by separate Astra high agents in `allocator-greedy`, `allocator-backtracking` and `allocator-chordal` worktrees. `compiler-allocator` integrates them behind one SSA CFG allocation interface. Linear scan remains the default.

## Native ARM64 results

The same executable, starting image, loaded allocator vocabularies and 13-word input corpus are used for every choice. Each fresh process warms the corpus, then measures compilation of fresh CFGs. Both allocation verifiers are enabled and explicitly recorded in every compilation record. Five runtime samples each install and run tree and spectral-norm workloads; all return matching results.

| Allocator | Code bytes | Spills | Reloads | Copies |
|---|---:|---:|---:|---:|
| linear-scan | 24384 | 42 | 42 | 17 |
| greedy | 24384 | 42 | 42 | 17 |
| backtracking | 24384 | 42 | 42 | 17 |
| chordal | 25584 | 60 | 60 | 155 |

Counts sum 19 generated procedures. All chordal graphs in this corpus pass the chordality certificate. Greedy and backtracking preserve baseline code quality here. Chordal remains worse despite affinity improvements; certified graph coloring alone does not solve coalescing and spilling well enough to replace the default.

### Constructed pressure cases

| Input | Allocator | Code bytes | Spills/reloads | Spill bytes |
|---|---|---:|---:|---:|
| 32 live floats | linear-scan | 848 | 12 | 96 |
| 32 live floats | greedy | 832 | 11 | 88 |
| 32 live floats | backtracking | 832 | 11 | 88 |
| 32 live floats | chordal | 848 | 12 | 96 |
| 40 live integers | linear-scan | 560 | 24 | 192 |
| 40 live integers | greedy | 560 | 24 | 192 |
| 40 live integers | backtracking | 576 | 25 | 192 |
| 40 live integers | chordal | 576 | 25 | 200 |

The float case holds 32 values live and returns `5092.0` for input `2.5`; the integer case holds 40 values live and returns `1220` for input `10`. All eight generated programs execute correctly with both verifiers. Greedy and backtracking save one spill/reload pair in the float case; only greedy also matches the baseline integer case.

These are code-quality and correctness results, not a general speedup claim. The host is contended, and compile measurements include verifier overhead. Raw CPU and retired-instruction observations are retained, but a default change needs repeated measurements on broader workloads with verification disabled during timing.

## Validation

- Full compiler suite passes under all four allocators, with all allocator vocabularies loaded together and both allocation checks enabled.
- Shared selection, diagnostic capture, both allocation verifiers, and help lint pass.
- Greedy initially failed nine FFI tests; reserving stack-only ABI operand slots fixes both the focused FFI and full compiler suites.
- Chordal has native moving-GC tests for derived phis, companion-base tests for cyclic phis, joins with more phi results than registers, and scratch-save width coverage. Disabling companion bases makes the relocation regression fail.
- Validation is native ARM64; no x86 performance result is claimed.

## Trying the allocators

From this worktree, refresh the compiler in a Factor listener and compare fresh CFGs:

```factor
USE: vocabs.refresh
"compiler" refresh
USING: compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal
kernel.private math prettyprint ;
[ { fixnum fixnum } declare + ]
{ linear-scan-allocator greedy-allocator
  backtracking-allocator chordal-allocator } compare-allocators .
```

Bind `register-allocator` with `with-variable` around compilation to select one without changing the process default. Each algorithm has a separate `allocate-cfg` method; the interval variants own SSA destruction, while chordal keeps SSA through graph coloring and lowers phis afterward. No failed allocation silently switches algorithms.

The portable API reports pass costs, emitted bytes, spills, reloads, copies, spill/frame sizes, and algorithm-specific diagnostics. `compare.factor` additionally uses this machine's counter dylib; run it with one allocator name and optional `check` or `runtime-only`. `pressure.factor` contains the exact pressure cases.

## Artifacts and exploratory runs

Primary samples are `shared-{linear-scan,greedy,backtracking,chordal}-check.jsonl`, `integrated-pressure.jsonl` and `integrated-*-compiler-tests.log`. `source-manifest.json` records the source and native artifacts. Verbose test logs and earlier samples are retained locally for debugging; the compact `validation-summary.json` and final measurements are versioned.

The first shared harness had reversed `member?` arguments for optional flags, so its `check` option was ineffective. Final samples record `allocation-checks: true`. The full compiler suites and pressure tests used explicit `check-allocation? on` throughout. Final comparisons also load all four vocabularies in every process to keep the compiler environment identical.
