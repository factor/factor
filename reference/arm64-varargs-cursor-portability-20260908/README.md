# Cursor test portability

`alien.varargs` keeps portable synthetic register/stack tests enabled on
x86, but reads of half/BF16 scalar ABI representations are restricted to
ARM64. The non-ARM64 branch explicitly checks that both unsupported-type
errors remain intact.

Native list forwarding now calls the actual C fixture's
`va_vsnprintf_pointer` through `alien-indirect`. Its declarations live in a
separate `native/forwarding.factor` file loaded only on ARM64, so merely parsing the portable tests
does not attempt to resolve native fixture symbols on another architecture.
It deliberately lives outside the special `tests/` directory, whose files
are discovered and run independently by `tools.test`.
The macOS run against the integrated `final.image` passes all 28 checks with
zero compiler errors; `macos-after.log` records that run.

The independently refreshed x86-64 runtime also passes all 27 applicable
cursor checks with zero compiler errors (`x86-after.log`). The original
unguarded test fails with the expected unsupported half/BF16 ABI error;
that baseline is retained in
`reference/arm64-varargs-x86-20260908/cursor-before.log`. The broader x86
integration run, including these cursor tests, is recorded alongside it.

The Windows link oracle checks the missing-symbol contract without claiming
native Windows execution. Microsoft's [CRT change history][ms] documents
the printf-family move to header-defined inline functions. The upstream
[MinGW-w64 UCRT export inventory][exports] contains
`__stdio_common_vsprintf`, but no `vsnprintf` export. The inventory URL and
digest are recorded in `export-source.log`.

`check-windows-link.py` creates an ARM64 import library for that relevant
UCRT export and compiles two small COFF probes. A direct `vsnprintf`
reference fails to link. A model of the header-wrapper/function-pointer
route links into an ARM64 PE DLL importing `__stdio_common_vsprintf` and
exporting `va_vsnprintf_pointer`. The probes validate symbol resolution;
they do not replace tests against the real Windows SDK or runtime. The
permanent Factor test uses the real C fixture and CRT implementation.

Run the link check with:

```sh
python3 reference/arm64-varargs-cursor-portability-20260908/check-windows-link.py
```

[ms]: https://learn.microsoft.com/en-us/cpp/porting/visual-cpp-change-history-2003-2015
[exports]: https://github.com/mingw-w64/mingw-w64/blob/master/mingw-w64-crt/lib-common/ucrtbase-common.def.in
