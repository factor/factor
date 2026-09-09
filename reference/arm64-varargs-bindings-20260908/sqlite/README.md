# SQLite variadic bindings

The SQLite FFI declared eight variadic entrypoints as fixed signatures and left
three native `va_list` entrypoints commented out. Its allocating formatters and
`sqlite3_str_finish` copied returned strings into Factor while losing the pointer
needed to release SQLite's allocation. The snprintf binding also returned a copy
instead of the caller's buffer pointer.

## Changes and compatibility

- `sqlite3_mprintf`, `sqlite3_snprintf`, and `sqlite3_str_appendf` now mark their
  anonymous tail with `...`. Their existing words represent zero-tail call
  shapes. Typed `FUNCTION-ALIAS` declarations provide other format shapes.
- `sqlite3_vmprintf`, `sqlite3_vsnprintf`, and `sqlite3_str_vappendf` use the
  canonical ABI-aware `alien.varargs:va_list` type.
- `sqlite3_mprintf`, `sqlite3_vmprintf`, and `sqlite3_str_finish` return owned
  `char*` pointers. Callers must release them with `sqlite3_free`. This changes
  the previous mprintf/finish return values from Factor strings to pointers.
- `sqlite3_snprintf` and `sqlite3_vsnprintf` accept writable `char*` buffers and
  return the supplied buffer pointer. The caller retains ownership. Their
  capacity-first argument order is unchanged. `sqlite3_str_value` still copies
  SQLite's borrowed string.
- `sqlite3_config`, `sqlite3_db_config`, `sqlite3_test_control`, `sqlite3_log`, and
  `sqlite3_vtab_config` now carry their correct variadic metadata. Their ordinary
  zero-tail words do not manufacture operation-specific arguments; typed aliases
  are required when the operation expects an anonymous tail.

No in-tree callers of the ownership-changing words required migration. Help for
`db.sqlite.ffi` documents ownership, writable buffers, typed aliases, and this
compatibility change. Tests release owned results; decoding helpers use `finally`
so a conversion exception also releases the allocation.

## Verification

Native macOS ARM64, SQLite **3.51.0**, using the verified callback VM and
`reference/arm64-varargs-20260908/final.image`:

- `before.log`: **four failures**, exit 1, using the FFI declarations from
  `fa62cb4cb7`. The variadic metadata is missing; real native mprintf and
  str_finish calls return copied strings rather than owned pointers; a real
  snprintf call writes correct buffer bytes but returns a copied string.
- `after.log`: **16 checks pass**, no compiler errors, exit 0.
- `portable.log`: the same **16 checks pass** with optional ARM64 extensions
  disabled, exit 0, including the final exception-safe decoding helpers.
- `c-controls.log`: an independently compiled program calls the actual SQLite
  formatting functions and all three native-list variants; it passes.
- `help-lint.log`: `db.sqlite.ffi` help lint passes.

The twelve vocabulary tests check declaration metadata, pointer ownership,
caller-buffer bytes, truncation, zero capacity, SQLite-specific `%Q` escaping,
integer/double tails, and dynamic string builders. Four additional compiler FFI
tests pass lists created by the existing independent C `va_call_format_list`
fixture into the real SQLite vmprintf/vsnprintf/str_vappendf functions. They cover
repeated forwarding followed by reading the original cursor, full output,
truncation, and builder output. No custom formatter substitutes for SQLite.

`baseline-tests.factor` preserves the four common before/after checks. To replay
the baseline, write `git show fa62cb4cb7:basis/db/sqlite/ffi/ffi.factor` to
`/tmp/sqlite-old-ffi.factor`, then run `baseline.factor`. `after.factor` reloads
the vocabulary before running the permanent tests. Both runners use the current
resource path. The compiler FFI driver requires the ordinary built
`libfactor-ffi-test` library alongside Factor.

The independent C control is built and run with:

```
clang -std=c11 -Wall -Wextra -Werror -O2 controls.c -lsqlite3 -o sqlite-controls
./sqlite-controls
```

Global configuration and SQLite's optional, unstable test-control operations are
checked as declarations; tests do not alter process-wide SQLite configuration.
The virtual-table configuration interface is likewise not invoked outside its
required callback context. Native Linux/Windows SQLite execution is not claimed.

## Primary API references

The implementation follows SQLite's documented
[formatting signatures, ownership, and snprintf behavior](https://www.sqlite.org/c3ref/mprintf.html),
[dynamic string formatting](https://www.sqlite.org/c3ref/str_append.html), and
[builder finalization ownership](https://www.sqlite.org/c3ref/str_finish.html).
The variadic declaration audit also checks
[global configuration](https://www.sqlite.org/c3ref/config.html),
[connection configuration](https://www.sqlite.org/c3ref/db_config.html),
[virtual-table configuration](https://www.sqlite.org/c3ref/vtab_config.html),
[logging](https://www.sqlite.org/c3ref/log.html), and
[the testing interface](https://www.sqlite.org/c3ref/test_control.html).
