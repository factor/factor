# Correctness validation

2026-09-08, native ARM64, fresh process using the matching integration Factor.app,
libfactor.dylib and speed image copied to this worktree. The image is invoked by
absolute path and the resource path is explicitly this source checkout. Shared
assignment and greedy definitions are explicitly reloaded before testing.

```
./factor -i=/Users/erg/factor.worktrees/allocator-full-greedy/factor.image \
  -resource-path=/Users/erg/factor.worktrees/allocator-full-greedy -no-user-init \
  reference/allocator-full-greedy-20260908/VALIDATE.factor
```

Result: exit 0, no test failures. The log contains 1,114 printed Unit Test / Must
Fail invocations from the loaded compiler.cfg subtree. Tests that select an
allocator explicitly retain that selection; all other compilation inherits
greedy. `check-allocation?` and the original-SSA/final-machine verifier are active.
The compressed raw log is `compiler-cfg-validation.log.gz`.

Focused source suites contain 25 greedy tests, 5 residency-solver tests (including
an exhaustive oracle over 32 small networks), and 17 assignment tests. Tests
inspect cascade transfers, real recoloring and full rollback, local interference
windows, physically selected hot-loop residency with a bypass, actual edge
stores after a defining terminator, and checked native pressure execution.

The broad run additionally executes the existing 40-constant diamond, loop and
GC fixtures with rematerialization off/on. The first run exposed false pressure
in the loop: an atomic interval could not evict newer spillable cascades. After
adding LLVM's penalized urgent-cascade exception, the complete run passed.

This is correctness evidence. No allocator speed ranking is inferred from these
runs, which were permitted to overlap other correctness work.
