# ARM64 CI coverage audit

The shared `.github/arm64-tests.factor` runner is invoked in normal and
`-disable-neon-extensions` modes in the Linux, macOS and Windows ARM64 jobs.
It recursively loads and tests ARM64 backend/assembler/features, SIMD,
vector conversion, floating-point environment and small floats. It explicitly
runs the compiler FFI, large-return FFI and floating-point test files, which
are compiler test files rather than loadable `compiler.tests` vocabularies.

The runner disables interactive test restarts, requires an ARM64 VM, checks
that the disabled-extension process reports no optional capabilities, and
exits nonzero for either test failures or compiler errors. Existing tools.test
provides test discovery and execution; no replacement test framework is added.

## Local setup

Native macOS ARM64 validation uses an isolated worktree based on
`3c430ff2fc`. The VM and FFI test library were rebuilt there with
`./build.sh compile` (exit 0). The image was
cloned from the existing development image; its resource path was checked to
point to this worktree. Intrinsics, assembler, backend and SIMD extensions were
reloaded from this worktree, then a local image was saved for repeat runs.
Neither the VM, shared libraries nor image is committed. CI builds its own
VM, test library and image before invoking the runner.

## Negative control

`failure-control.factor` runs a deliberately failing `{ 0 } [ 1 ] unit test
before invoking the same complete runner. It is an audit fixture, not part of
ordinary CI discovery. To repeat with a built ARM64 VM/image:

```
./factor -no-user-init -no-monitors reference/arm64-gap-ci-20260908/failure-control.factor
```

The expected exit status is 1. This establishes failure propagation, not a
claim that CI configuration fixes a functional ARM64 bug. SIMD's own
`fake-unit-test` tests deliberately print two additional failure messages;
the final failure collection and process exit determine the verdict.

## Platform limits

Linux ARM64 and Windows ARM64 commands are statically checked here; no remote
CI was dispatched, and these platforms were not executed locally.

## Results

- Final normal run: exit 0, `ARM64 regression tests passed`, 33,968 output
  lines including all eight explicit suite/file progress markers.
- Final disabled-extension run: exit 0, `ARM64 regression tests passed`.
- Intentional failure-control run: exit 1, with only the audit fixture in the
  final failing-test collection.
- actionlint v1.7.12: exit 0, no diagnostics.
- `check-workflow.py`: passes; verifies both modes on all three ARM64 jobs,
  no per-step failure suppression, and Windows cmd/factor.com usage.
- `git diff --check`: passes.

The initial runs used an older copied VM and correctly exited 1 on four
floating-point environment tests: the VM lacked newly added unordered
comparison primitives and ordered-NaN behavior. Rebuilding the VM from the
snapshot fixed those local binary/source mismatches. This is setup evidence,
not a functional fix attributed to the CI change. Initial logs remain in
`/tmp/arm64-gap-ci/stale-vm-*.log` on the validation machine.

macOS had put test processes in background scheduling priority 4. Restoring
normal scheduling with `taskpolicy -B -p <owned-pid>` let them finish at
priority 31. No other workspace or process was changed.

Repeat commands after a native bootstrap (the local audit supplied
`-i=ci-loaded.image` to use its refreshed image):

```
./factor -no-user-init -no-monitors .github/arm64-tests.factor
./factor -no-user-init -no-monitors -disable-neon-extensions .github/arm64-tests.factor
./factor -no-user-init -no-monitors reference/arm64-gap-ci-20260908/failure-control.factor
```

`normal.log`, `portable.log`, and `failure-control.log` preserve complete
native test output. The corresponding `.exit` files retain exit statuses.
