# ARM64 variadic callback entry

The callback special object remains index 53. Its first two items are the
unchanged ordinary relocation and instruction byte arrays; item 2 is a second
`{ relocations code }` template. The runtime's internal return-rewind value -1
selects it only on ARM64. The immediate fixnum 1 in the stub's parameters slot
records the selection for later relocation updates without introducing a GC root.
`arm64_variadic_callbacks_supported()` is exported by both runtimes so the
compiler can reject an old runtime before asking it to allocate this template.
The updated runtime rejects an old image without the third template.

Capture layout relative to the original C entry SP:

- X0-X7: -64 through -8, one 8-byte slot per register, followed immediately by
  incoming native stack arguments. This supports Windows va_list traversal.
- Q0-Q7: -192 through -80, one 16-byte slot per register.
- Existing saved callback context follows below these captures: 112 bytes on
  Unix, 128 on Windows including its TEB pair. Thus original SP is the saved
  context stack pointer plus 304 (Unix) or 320 (Windows).
- X8 remains intact for the compiler's existing hidden-result-pointer capture.
- Return releases the capture area without overwriting return registers.

## Native evidence

Built with `make -j8 macos-arm-64`. The independent C caller in `capture.c`
supplies eight distinct integer and eight distinct FP arguments. The Factor
callback obtains the saved-stack pointer using a small independent assembly
sequence, checks all 16 captured values, and triggers compacting GC first.
Calling twice verifies callback relocation updates use the selected template.
This is a raw-entry test, independent of the new varargs reader/compiler path.

`before.log`: old root runtime, new template installed, expected 42 but got -1.
`after.log`: rebuilt runtime passes both capture calls, confirms the ordinary
stub is byte-identical, and rejects allocation before the new template exists.
The before script omits only the old-image guard assertion, which an old runtime
cannot satisfy.

Reproduce from this worktree:

```sh
clang -shared -o /tmp/arm64-varargs-entry-capture.dylib reference/arm64-varargs-entry-20260908/capture.c
./factor -i=/Users/erg/factor.worktrees/arm64-gaps-integration/verified.image reference/arm64-varargs-entry-20260908/runtime.factor
```

The evidence script intentionally records absolute source paths. For an
integration image refresh, initialize `bootstrap.image.private:special-objects`
and `sub-primitives` to empty hashtables, run the target's `arm.unix.factor` or
`arm.windows.factor` and then `arm.64.factor`, and install only the generated
CALLBACK-STUB object using `set-special-object`. Fresh bootstrap generation does
this automatically. Do not install unrelated generated special objects into an
existing image.

## Runtime build checks

Both runtime builds completed successfully in this worktree:

- C++: `make -j8 macos-arm-64`, exit 0; full output in `cpp-build.log`.
- Zig 0.16.0: `/Users/erg/.zvm/0.16.0/zig build test`, exit 0;
  result recorded in `zig-build-test.log` (the successful command was silent).
  `zig fmt --check src/callbacks.zig` also passed.

The installed default Zig 0.17 development build is incompatible with the
repository build script, so the supported installed 0.16.0 toolchain was used.
