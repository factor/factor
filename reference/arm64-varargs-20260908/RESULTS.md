# Validation results

All exits below are real tool/process results. Generated runtimes, images, and
shared libraries are not committed.

| Check | Result |
| --- | --- |
| macOS ARM64 full regression suite | 1,175 unit reports per mode; normal/disabled exit 0 |
| Full compiler, SSA/allocation checking | 3,188 unit reports; zero failures/compiler errors |
| Four allocators + global value numbering + FFI | 1,236 unit reports; zero failures/compiler errors |
| Apple Clang native CI check, before alignment follow-up | Normal/disabled, C controls, formatting: exit 0 |
| Clang 23 native CI check | Normal/disabled, required half/BF16, formatting: exit 0 |
| x86/Rosetta shared regression run | 264 unit reports; zero failures/compiler errors |
| Cursor portability | ARM64: 28 checks; x86: 27 applicable checks; pass |
| C++ ARM64 VM build | `make -j8 macos-arm-64`: exit 0 |
| Zig VM tests | Zig 0.16.0 `zig build test`: exit 0; formatting check passed |
| Compatible older v5 seed | Full native stage2, restart, C FFI: exit 0 |
| Linux ARM64 under QEMU, Clang 21 | 189 unit + 15 expected-failure reports per mode; normal/disabled pass |
| Linux ARM64 under QEMU, GCC 15 | 177 unit + 15 expected-failure reports; normal pass; half/BF16 explicitly unavailable |
| Linux actual printf | Four direct/indirect × normal/disabled combinations per compiler pass |
| Alignment regressions | Six native C failures and three Windows ABI pointer failures become passes |
| Help lint | alien, alien.varargs, alien.syntax: exit 0 |
| CI failure propagation | Six intentional failures correctly exit 1 |

The compiler subprocess harness uses the same verified image/source as the
parent process. Its earlier two callback-error failures came from accidentally
launching the worktree's older default image; that harness setup was corrected.
Counts are log reports, not a claim of unique assertions: test frameworks can
include their own negative-control output. The alignment repair also passes
the x86 shared regression run. The main compiler, allocator, normal, portable,
and Clang CI logs contain the final macOS
reruns after that repair; `alignment-update.factor` records the image refresh.

## Limits

Linux execution used QEMU; native Linux qualification remains pending.
Native Windows was unavailable here. Windows-target compiler code was executed
through documented macOS ABI oracles and exports were checked in actual ARM64
PE DLLs; this is not native Windows execution. Native CI steps are defined.

The official master boot seed checked during this work is image version 4, while
this checkout already requires version 5. Default download-based CI is therefore
blocked before Factor source loads until a compatible seed is supplied. The
new callback compatibility helper is proven on older compatible v5 seeds and
does not bypass the VM's format check. Artifact hashes and the released-host
experiment are in the bootstrap compatibility evidence.

The old x86 image independently reproduces the aggregate-varargs boundary bug
(365 instead of 317). Only that ARM64-specific new assertion is gated by CPU;
portable outgoing calls, promotions, parsing, compiler logic, and cursor layout
regressions pass on x86. Windows Clang C caller defects are independently
controlled and documented separately. GCC 15 at `-O2` also miscomputes a
C-only vector-union variadic control (17 instead of 53); a GCC-only `may_alias`
annotation on the fixture union restores the expected result with unchanged
size/alignment. Factor callbacks already passed before the annotation. The
Linux evidence preserves the isolated before/after C results.
