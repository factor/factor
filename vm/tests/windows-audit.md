# Windows C++ VM audit — 2026-09-09

This pass reviewed the Windows C++ VM platform implementations, their shared
startup/I/O and exception interfaces, and the Windows build configuration.
It does not certify every shared VM algorithm or cover the Zig VM in `src/`.

## Coverage and fixes

| Area | Sources reviewed | Result |
| --- | --- | --- |
| DLL loading and executable paths | `os-windows.cpp`, `os-windows.hpp`, `zstd.cpp` | Match narrow native library names to `LoadLibraryExA`; preserve dotted directories when finding an extensionless executable's image; reject truncated executable paths. |
| Memory and guards | `os-windows.cpp`, `segments.hpp`, `contexts.cpp`, `code_heap.cpp` | Check segment rounding/addition overflow; reject x64 code heaps whose rounded exclusive end does not fit a 32-bit unwind RVA. |
| Threads and clocks | `os-windows.cpp`, `mvm-windows.cpp`, `atomic-cl-32.hpp`, `atomic-cl-64.hpp`, `atomic.hpp`, `sampling_profiler.cpp` | Use a correctly typed Windows thread entry; check creation; join workers cooperatively; preserve existing suspend counts; avoid absolute-QPC multiplication overflow and mutable shared clock state; split sleeps that would wrap or become `INFINITE`. |
| Startup failures | `main-windows.cpp`, `mvm-windows.cpp`, `errors.cpp`, `factor.cpp` | Check argument allocation and free it; report fatal errors before TLS/VM registration without dereferencing absent or unrelated VM state. |
| File and image I/O | `io.cpp`, `io.hpp`, `vm.hpp`, `image.cpp`, `os-windows.hpp` | Use 64-bit offsets; advance partial transfers by bytes and clear EINTR stream errors; keep image saving nonthrowing and close failed streams; reject unreadable/short embedded footers. |
| Exception handling | `os-windows-{x86.32,x86.64,arm.64}.{cpp,hpp}`, `callbacks.cpp`, `code_heap.hpp`, `safeseh.asm` | Give ARM64 heap fragments phantom-prolog unwind metadata; flush the x64 generated exception-handler trampoline. |
| Other Windows branches/build | `alien.cpp`, Windows branches in `bignum.cpp`, `bignumint.hpp`, `debug.cpp`, `platform.hpp`, `Config.windows*`, `Nmakefile`, `build.cmd`, `cpu-arm.64-trampoline.asm` | No additional confirmed changes in these branches. Add native Windows regression targets; declare the VM abort wrapper non-returning to remove a cross-compilation warning. |

## Validation

Run from a Visual Studio x64 developer environment:

```bat
build.cmd compile
nmake /nologo /f Nmakefile LTO=1 test-windows
python -B vm/tests/stack_safety.py
```

The x64 clean compilation and LTO link completed without compiler warnings.
An open Listener held the old executable and FFI test DLL during the first link;
those loaded files were preserved under temporary names and the link completed.

Native probes cover DLL loading/export lookup, startup diagnostics, dotted image
paths, segment guards/overflow, thread entry/exit and suspend-count preservation,
partial transfers/EINTR, file offsets above 4 GiB, embedded footers, allocation
failure, code-heap bounds, and the existing GC suite. The DLL-loading probe was
also run before the fix and failed as expected.

Factor integration ran `alien`, `compiler`, `io.files`, `io.streams.c`,
`tools.profiler.sampling`, and `math.floats` with zero test failures. This includes
repeated profiler start/stop, GC while profiling, and blocking/sleeping samples.
All six `stack_safety.py` tests passed, including the measured recursion boundary,
GC near that boundary, repeated continuations, and overflow recovery with and
without an intervening GC.

The modified platform/startup/I/O files cross-compile with clang-cl for Windows
x86 and ARM64 using `/EHsc /std:c++17 /W4 /D_CRT_SECURE_NO_WARNINGS`.
`windows_arm64_unwind.cpp` also cross-compiles for ARM64. On native ARM64, build
and run the standalone probe (it includes the production table generator):

```bat
cl /nologo /EHsc vm/tests/windows_arm64_unwind.cpp
windows_arm64_unwind.exe
```

## Limits and remaining coverage

- x86 and ARM64 received compile checks, not native runtime qualification.
  ARM64 `RtlVirtualUnwind` fragment-boundary assertions still require a native run.
- MinGW configurations were inspected but not built.
- Long-duration sleep chunking and extreme-uptime clock behavior were reviewed;
  those time intervals were not reproduced in real time.
- Interactive Ctrl-C/Ctrl-Break behavior and concurrent multiple-VM ownership
  were not qualified. The console handler still assumes one registered VM.
- This audit does not establish that all Windows or shared VM bugs are fixed.

## Platform references

- [Windows DLL loading](https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexa)
- [Module path truncation](https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulefilenamew)
- [64-bit file seeking](https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/fseek-fseeki64)
- [Thread suspension](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-suspendthread)
- [Forced thread termination hazards](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-terminatethread)
- [QPC guarantees](https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps)
- [ARM64 function fragments](https://learn.microsoft.com/en-us/cpp/build/arm64-exception-handling#function-fragments)
