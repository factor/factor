# Shared x86 regression verification (2026-09-08)

Executed x86-64 macOS Factor under Rosetta, using an isolated source worktree and x86-64 C fixture dylib. This is shared parser/compiler/FFI regression coverage, not x86 variadic callback support.

Final result: **264 Unit Test reports, zero test failures, zero compiler errors, exit 0** (`final.log`). Coverage includes small floats, multiply-negate, alien.parser, stack-checker.alien, compiler.cfg.builder.alien, portable alien.varargs cursor checks, general C FFI, large returns, portable outgoing varargs, and direct/indirect source-value promotions.

The original image was `/Users/erg/factor.worktrees/arm64-gaps-x86/factor.image`; executable `/Users/erg/factor.worktrees/arm64-gaps-x86/Factor.app/Contents/MacOS/factor`. `run.factor` reloads the source snapshot listed in `source-sha256.txt` and saves `refreshed.image`. `final.factor` reruns all checks from that refreshed image. Native fixture build: `clang -arch x86_64 -dynamiclib -O2 vm/ffi_test.c -o libfactor-ffi-test.dylib` in the isolated worktree. The ARM64 fixture was never overwritten.

```
/Users/erg/factor.worktrees/arm64-gaps-x86/Factor.app/Contents/MacOS/factor -resource-path=/Users/erg/factor.worktrees/arm64-varargs-x86 -i=/Users/erg/factor.worktrees/arm64-varargs-x86/refreshed.image -no-user-init reference/arm64-varargs-x86-20260908/final.factor
```

## Fail-before evidence and scope

`baseline.log` uses the old image and old `alien-invoke` primitive against the independent C fixture: C-only control is 317, Factor outgoing aggregate varargs is 365 instead of 317. This establishes a preexisting x86 SysV ABI gap in the newly added ARM64 register-boundary scenario; that scenario is explicitly ARM64-only in commit a9a26120ad. Portable outgoing controls and source-promotion tests remain enabled on x86. This ARM64 implementation does not claim to fix all preexisting x86 varargs behavior.

`cursor-before.log` shows the original synthetic half/BF16 HFA cursor test reaching unsupported scalar ABI representation on x86. The portable suite now explicitly checks unsupported x86 half/BF16 representation and guards ARM64-specific reader cases. `run.log` then exposed discovery of the ARM64 native forwarding helper under `tests/` despite its caller guard. Commit 9884ba3b95 moves the helper to `native/`; `final.log` verifies the whole corrected suite.

The copied implementation source is not part of this evidence commit. Binary, image, and dylib artifacts are intentionally excluded.
