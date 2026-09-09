# Independent GVN moving-GC review

This records a native ARM64 **machine-IR optimization/GC mismatch**. It does not
claim a demonstrated ordinary high-level Factor program regression. No compiler
implementation changes or performance measurements were made for this review.

The GVN source is exactly `e311c04c1a`'s `global.factor`. Execution used current
integration commit `de619c6daf`, its matching VM and `speed.factor.image`, with
explicit resource path and source reloads. That integration includes the later
allocator/derived-root provenance repairs, avoiding a known unrelated baseline
GC bug. Exact relevant source, VM and image hashes are in `provenance.json`.

## Native experiment

Each variant starts with the same fresh SSA graph:

```
p = tagged>integer(object)
a = xor(p, 7)
before = encode-as-fixnum(a)
[explicit save-context / call-gc]
b = xor(p, 7)
after = encode-as-fixnum(b)
return before, after
```

The first three variants place the operations in three connected blocks. The
second three put them in one block. Modes are no numbering, local numbering,
and the production opt-in global numbering pipeline. Final copy propagation
runs in all modes, as it does after numbering in `optimize-ssa`. `check-ssa`
accepts the graphs before and after optimization. All use the same linear-scan
backend and allocation legality checking.

The caller independently roots each fresh array and obtains its address before
and after the compiled probe through a separate native word. No old pointer is
dereferenced, and no pointer is retained by C code. Only encoded fixnum snapshots
are returned by the probe. Every sample's independently observed object address
changed, so a test cannot pass merely because no collection moved the object.

| Layout | Mode | Actual moves | Correct pre snapshots | Correct post snapshots |
| --- | --- | ---: | ---: | ---: |
| Three blocks | No numbering | 8/8 | 8/8 | 8/8 |
| Three blocks | Local | 8/8 | 8/8 | 8/8 |
| Three blocks | Global | 8/8 | 8/8 | **0/8** |
| One block | No numbering | 8/8 | 8/8 | 8/8 |
| One block | Local | 8/8 | 8/8 | **0/8** |
| One block | Global | 8/8 | 8/8 | **0/8** |

In every wrong case the post snapshot equals the pre snapshot. The raw log
contains the optimized instruction streams, caller addresses, callee results
and boolean comparisons. The final probe process exited 0. `analyze.py` derives
`results.json` from the raw log; it does not infer collection from the callee.

The mechanism matches the source review: GC relocates the derived pointer `p`,
but the XOR/shift result is an ordinary integer snapshot. Expression numbering
assumes the operand's bits remain unchanged and reuses the earlier result.
Global numbering's opcode whitelist admits these operations; its availability
analysis treats kill blocks as barriers, but this GC block is not a kill block.
The single-block control shows an analogous pre-existing LVN limitation.

## Contract boundary

The IR uses supported instructions with matching tagged/int representations,
unique SSA definitions, dominating uses, and the backend's implemented derived
root relocation. The documented restriction on C retaining a byte-array pointer
across callbacks is not exercised: there is no C-held pointer or stale-pointer
dereference in this probe.

Nevertheless, normal `optimize-cfg` runs **before** `insert-gc-checks`. This probe
feeds an explicit GC instruction through numbering to expose the semantic
assumption directly. Production reachability from a normal high-level word, or
an explicit optimizer input contract that forbids this shape, remains to be
established. The result should not be presented as proof that the new pass broke
an existing source program. It does show that the whitelist's comment about
excluding derived-pointer hazards is broader than what its opcode test enforces,
and that structural SSA checking alone cannot prove this property.

## Reproduce

With the pinned integration VM/image available:

```
python3 reference/gvn-moving-gc-review-20260908/run.py
python3 reference/gvn-moving-gc-review-20260908/analyze.py
```

`run.py` optionally accepts another source root containing a matching `factor`,
`libfactor.dylib` and `speed.factor.image`. Such a run has different provenance
unless its hashes match the committed manifest.

## Overall code-review assessment

The GVN work is substantive compiler engineering: it shares existing local
rewrites, fixes predecessor/value phi association, preserves the phi prefix,
uses a fixed-point congruence analysis and must-availability before replacing
expressions, and keeps literal loads local to avoid spill regressions. The
reported broad validation and decision to leave it opt-in are appropriate.
It has not demonstrated a representative optimization win: the recorded 13-word
corpus has unchanged generated code size and +2.50% compiler instructions.

Highest-value next cost reductions are an admission test before full numbering
(single-block/no-duplicate-op cases), sparse dependency/SCC iteration instead of
whole-CFG sweeps, caching per-block defined candidate sets, and cloning the
mutable availability map once per block rather than once per candidate def.
Algorithmic scope remains conservative global scalar congruence elimination;
there is no PRE, memory/FP GVN or new phi synthesis in this implementation.
