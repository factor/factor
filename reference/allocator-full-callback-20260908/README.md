# Backtracking callback preservation regression

The original failure was a native ARM64 protection fault at address `0x180`
when the real C large-struct-return caller invoked a Factor callback containing
compacting GC. The hidden raw result address enters through `##callback-inputs`
in X8 and receives a spill home. It remains live through ordinary Factor calls
until the returned structure is copied into the caller's result area.

At source `84a10fe6be`, the second-chance pass reconstructed long no-use register
ranges from that original interval without excluding Factor call blocks. In the
retained diagnostic trace, the result address has original range `[6,1345]`,
mandatory final fragment `[1340,1345]` in X3, and a second-chance fragment
`[132,1339]` in X14 crossing dozens of call blocks. The earlier fragment
`[28,129]` also crosses calls. Actual calls overwrite those registers, so the
later result copy uses a corrupted address. `baseline-diagnostic/` contains the
fault and interval dump; its temporary diagnostic hook only printed callback
instructions, original/allocated intervals, and kill-block boundaries.

## Production correction

Commit `38003ffe56` changes the second-chance policy in two places:

- `prepare-backtracking-points` excludes the full inclusive phase range of every
  kill block. Excluding just the call instruction would still permit intervals
  beginning inside a block skipped by physical assignment.
- `gap-interval` gives an ordinary successor an explicit memory reload whenever
  any predecessor is a kill block. Call blocks have no outgoing register map.
  For a mixed join, entry recording publishes the reload's memory home, and
  ordinary predecessor edges initialize that home through existing parallel
  edge resolution. The callback path retains its ABI-created memory home.

No register assignment across Factor calls is introduced. The source regression
checks exact permitted ranges on either side of a skipped block and requires
an entry reload for a join with both ordinary and call predecessors. The fix
was reviewed independently by the rematerialization owner.

The independent checker correction `dfe08fc9bd` treats ordinary `##call` as a
register clobber. Previously its symbolic register state survived these calls,
which concealed the allocation bug. Its separate mutation tests reject both
removing the post-call reload and overwriting the saved address with a stale
register. The callback run also includes spill-tail correction `0f3c5628ba`.

## Native acceptance

`callback-matrix.factor` recompiles and executes the existing
`compiler/tests/alien-large-return.factor` C ABI fixture under all four
allocators, with rematerialization off and on. All eight configurations pass on
native ARM64: 40 actual ABI assertions including direct and indirect calls,
compacting-GC callbacks, and nested C calls returning large structures. The
backtracking subtree then passes, including the new source regression. SSA,
interval, and strengthened final value-flow checks are enabled; GVN is off and
loop spilling is on. `arm-all8/` retains output, command, source/asset hashes,
process samples, and exit status (zero failures, exit 0).

The successful run was made with the final callback patch in the working tree
before committing it; its environment record therefore names dependency HEAD
`638f3becf6` and lists those two modified source/test files. `38003ffe56` commits
that tested change. Elapsed time is correctness-run metadata, not a performance
comparison. Native x86 validation and the integrated full compiler suite are
separate parent-owned gates.

Run with a matching VM and image and the explicit source resource path, using
the parent's external process-priority wrapper:

```sh
python3 reference/allocator-speed-20260908/run-command.py \
  --cwd WORKTREE --output RESULT_DIRECTORY -- \
  VM -i=ABSOLUTE_IMAGE -no-user-init -resource-path=WORKTREE \
  WORKTREE/reference/allocator-full-callback-20260908/callback-matrix.factor
```

The wrapper lives in the allocator-speed integration evidence directory; the
retained environment records contain the exact absolute command used here.
