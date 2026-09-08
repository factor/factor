# master-candidate compiler integration

Both development branches are merged into an integration worktree based on `c83f2f171b`. Native VM rebuilt from the combined source. All four compiler validation runs passed with SSA and allocation checks enabled: linear scan/local VN and greedy, backtracking, chordal/global VN. The earlier individual branches also passed their own tests; GVN passed fresh bootstrap, load-all and the full project suite.

Linear scan remains the default; global numbering remains opt-in. No alternate allocator is silently used as a fallback.

`ASSESSMENT.md` compares the implementations and prioritizes remaining work. `validation.json` records combined-source checks. `compiler-suite.factor` reproduces them with a named allocator and optional `global`. Refresh CPU architecture before the compiler because older starting images lack the recently added return-struct-pointer? protocol.

The main checkout contains earlier uncommitted versions of the same folding changes. Their contents are included in the finished GVN implementation, with additional wrapping/narrowing fixes and regression tests. The original patch, file hashes and untracked folding test are backed up locally here before promotion. Unrelated ARM64/SIMD edits are preserved byte-for-byte and left uncommitted.

This does not claim a full project suite on the newly combined branch or a cross-architecture performance win. Verbose logs and main-checkout backups remain local.

Fresh unchecked compilation measurements are in `timing-summary.json` and `timing-*.jsonl` (three alternating fresh-process trials per allocator). `summarize.py` verifies sample counts and runtime results and computes the comparison. No new default is selected.
