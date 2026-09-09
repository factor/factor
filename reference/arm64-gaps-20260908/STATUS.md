# ARM64 port work — completed

Follow-up: ARM64 variadic callbacks, native `va_list`, and Windows variadic FP transport are implemented. See the [current varargs audit](../arm64-varargs-20260908/AUDIT.md) for the added C regressions, Linux emulation results, and native CI qualification limits. The original six-workstream results below remain the historical snapshot.

All six authorized workstreams were implemented, independently verified, integrated with the concurrent allocator/GVN changes, and applied to the main working tree. The delivered ARM64 source, tests, evidence, and Linux plan are now committed on `master-candidate`. Unrelated files were excluded. Existing allocator/GVN changes remain intact.

- macOS ABI oracle: 25 failures before, 27 passes after.
- Final ARM64 CI suites: normal and disabled-extension both exit 0.
- Full compiler with SSA/allocation verification: 3,078 unit checks, zero failures/errors.
- Four allocators with global value numbering and FFI fixtures: 816 unit checks, zero failures/errors.
- x86 shared-code regression suite: exit 0.
- Windows half/BF16 variadic signatures explicitly rejected after compiler-oracle verification; fixed signatures retain compiler evidence only.
- Native Linux/Windows execution, SVE/SME and broader optional ISA work remain outside the verified scope.

See [AUDIT.md](AUDIT.md) for exact changes, fail/pass evidence, behavior differences, remaining gaps and delivery verification.
