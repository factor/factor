# Windows fixture export audit

`FACTOR_EXPORT` was empty on Windows, and `Nmakefile` links the fixture DLL with
an explicit `.def` file containing none of the outgoing varargs, scalar half,
or BF16 entry points. The incoming varargs fixture already has a separate
`__declspec(dllexport)` macro and is unaffected. The new promotion fixture uses
`FACTOR_EXPORT` and needs the shared correction too.

Defining `FACTOR_EXPORT` as `__declspec(dllexport)` on Windows produces COFF
`/EXPORT:` directives consumed by Microsoft's linker alongside the legacy `.def`
file. `before.log` shows no outgoing directives; `after.log` includes outgoing,
promotion, half/BF16, and their capability exports. The latter object was compiled
from exactly the production headers and definitions with Clang's Windows ARM64
target, without a Windows SDK or native Windows execution.

```
clang -target aarch64-pc-windows-msvc -Ivm -I/Users/erg/factor/vm -c \
  reference/arm64-varargs-windows-exports-20260908/probe.c -o /tmp/exports.obj
/opt/homebrew/opt/llvm/bin/llvm-readobj --coff-directives /tmp/exports.obj
```

Nmake's object dependencies now include all the included fixture source/header
files, so editing one triggers recompilation of the fixture DLL.

The same COFF object also links into an ARM64 PE DLL with `lld-link /dll
/noentry`; `pe-exports.log` confirms all 38 names in its actual export directory.
This verifies the linker result as well as the input directives. It still does
not constitute execution on Windows or a full MSVC VM build.
