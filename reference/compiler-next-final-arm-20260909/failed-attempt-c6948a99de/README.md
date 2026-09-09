# Failed c6948a99de ARM attempt

The parent-owned final queue stopped after the greedy-selected loaded
compiler-vocabulary suite failed a backtracking entry-transport test.
Linear scan exited 0; greedy exited 1. The failure is an
`unexpected-allocation-instruction` from `check-value-flow` in the all-memory
`(entry-edge-fixture)` case. These are retained failed-attempt records,
not accepted final validation or performance evidence. No backtracking/chordal
suite, final preparation, selected closure, timing, callback/GC or bootstrap
step had completed in this attempt. The owner is diagnosing the same fixture
failure on both ARM and native x86; a new frozen revision is required.
