# VM tests

Run the C++ collector tests with the same build configuration as the VM:

```sh
make test-vm CONFIG=vm/Config.macos.arm.64
```

On Windows, use a Visual Studio developer command prompt matching the VM's
architecture:

```bat
nmake /nologo /f Nmakefile test-vm LTO=1
python vm/tests/stack_safety.py -v
python vm/tests/windows_allocation.py -v
```

The subprocess runner defaults to `factor.com` on Windows and `factor` on Unix.

The Windows allocation probe requests an impossible C++ allocation size,
without exhausting RAM. It verifies a clear diagnostic and a nonzero exit
even before a VM exists. `nmake test-vm` builds the probe executable.

The stack-safety regressions run Factor in isolated subprocesses so a native
crash, low-level debugger entry, or timeout fails the test without taking down
the test runner:

```sh
python3 vm/tests/stack_safety.py --factor ./factor --image ./factor.image -v
```

The runner also accepts a Zig VM executable using a compatible image. It checks
invalid callstack inputs (#1279), the repeated-continuations reproducer from
#1419, GC near the measured recursion limit of a 64 KiB callstack, and continued
execution and GC after repeated stack overflows. Compacting, full, and nursery
collection entry points are exercised. Recovery is also repeated without GC
to check that it restores Windows' one-shot stack guards itself.
The boundary test starts a
fresh process for each depth because one failed GC can invalidate the VM.
Allow a few minutes for the full sweep; `--timeout` controls the timeout of each
child process, in seconds. An individual test can be selected, for example:

```sh
python3 vm/tests/stack_safety.py -v StackSafetyTests.test_callstack_type_errors
```

These tests need a working image with the standard test vocabularies. Run them
on each target OS: a pass on macOS ARM64 does not validate Windows stack-overflow
handling or Linux signal delivery.
