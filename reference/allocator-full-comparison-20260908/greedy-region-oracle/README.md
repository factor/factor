# Independent CFG residency solver check

All **122** native x86 solver outputs match exhaustive enumeration of the binary
placement objective and satisfy forced-memory constraints. Cases contain one to
six nodes; they include explicit transparent-node and hard-barrier examples plus
120 seeded small graphs with cycles, zero costs and varied transition weights.
The oracle also checks that every captured input equals the requested case.

The solver is an immutable copy of the greedy owner's uncommitted `regions.factor`
at the recorded SHA-256, based on branch commit `a09a069773`. This validates the
mathematical solver snapshot. It does **not** prove the region pass constructs the
right network, lowers the chosen residency into correct code, participates in the
production allocation path, or improves performance. Those remain separate gates.

`run.factor` was executed with `taskset -c 2` on the existing native x86 host
`agent1`, under `/home/erg/factor-allocator-candidate-20260908`, with the existing
`reference/allocator-speed-crossarch-20260908/prepared.image`. It explicitly loads
the copied solver. The process exited 0, saved no image, and performed no ranked
timing or generated-code execution. Its path is retained for reproduction.

Run `python3 check.py` here to verify the source hash and replay the independent
oracle against `inputs.json` and `output.jsonl`. The oracle enumerates assignments;
it does not reuse the solver's augmenting-path or residual-network implementation.
