# Allocator speed implementation and integration

All implementation work starts from `233db947df`, in separate worktrees. The
main checkout has unrelated ARM64/FFI work in progress and is not modified by
these experiments. Its installed image remains linear scan with GVN disabled.

| Worktree suffix | Responsibility |
|---|---|
| value-flow | Final physical value-flow verifier, generated and corruption tests |
| interference | Indexed occupancy and cached costs for backtracking and greedy |
| coalescing | Chordal copy coalescing and spill placement |
| rematerialization | Shared constant recipes and spill/reload/edge lowering |
| crossarch | Native ARM64/x86 workload comparisons and provenance |
| integration | Combined compiler validation and cold-bootstrap acceptance |

The acceptance target for the default cold bootstrap is below two minutes.
Previous current-source runs completed in 1:57 (ordinary default) and 1:52
(linear scan/GVN-off with all allocator vocabularies loaded). Those are individual
foreground measurements, not guarantees under arbitrary host load. New shared
features must be checked for cold-compiler cost as well as generated-code quality.

`run-command.py` runs a single command, captures its log, source/native/image
identity, phase and periodic process counters, and reapplies macOS foreground
policy from the parent every second. It refuses to overwrite an existing result
directory. Counters use Mach timebase conversion and exclude helper processes.
The runner is for correctness and bootstrap acceptance; the crossarch worktree
owns calibrated runtime benchmarking and native Linux counters.

Example, from this worktree:

```sh
python3 reference/allocator-speed-20260908/run-command.py \
  --output reference/allocator-speed-20260908/results/example \
  -- ./factor -i="$PWD/factor.image" -no-user-init -e='USING: io ; "SPEED smoke" print'
```

Final results and the exact integrated source revision will be recorded after
the implementation branches are combined. No optimization is considered a win
solely because it reduces copies: spills, reloads, total instructions, code
bytes, compilation work, and executed workload results must also be considered.
