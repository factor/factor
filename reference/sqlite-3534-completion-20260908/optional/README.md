# SQLite 3.53.4 optional native API verification

The unmodified `c40418fff8` bindings failed all four declaration/layout regression
checks in `baseline-tests.factor`: session creation, `sqlite3_carray_bind_v2`, and
preupdate hooks were absent, and `fts5_api` was 32 bytes instead of the native
48-byte ARM64 layout. These are missing-feature/layout failures, not a claim that
an absent function was successfully called before implementation. `baseline.log`
records the actual run before the new binding source was copied into this worktree.

With the completed bindings, all **13 Factor checks pass**, including the same
four checks, five native integration cases and the filename declaration contract, native struct sizes, the exact runtime
version, and all eight required compile options. There are **zero compiler errors**.
The independent C program also passes all five integration controls. No test is
conditionally skipped when a symbol or build option is unavailable.

| Case | Factor calls and native oracle | Result |
|---|---|---|
| Session | Create/attach a session, insert/update rows, generate a changeset, apply it to a second database | Target sum `48` |
| Carray | Bind three signed 64-bit values using `sqlite3_carray_bind_v2`; pass a destructor context distinct from the array pointer | Sum `1000000042`; destructor called once with the correct context |
| Preupdate | SQLite invokes a Factor callback; Factor calls old/new/count/depth/blobwrite while the hook is active; C independently validates all callback arguments and values | One update; old `11`, new `29`, row IDs `7` |
| FTS5 | Read the new API and tokenizer struct fields in Factor; native code compares the retrieved function pointers and executes the returned tokenizer | `Hello world` produces `hello`, `world`; struct sizes `48`, `32` |
| VFS filename | A forwarding VFS invokes Factor inside rollback-journal and WAL `xOpen`; Factor passes the original filename to `sqlite3_database_file_object`; C compares the result to the main file object | Both journal and WAL paths return the exact main file pointer |

The upstream `unicode61` tokenizer returned through `xFindTokenizer_v2` has an
`iVersion` value of **0** in this release's compatibility wrapper. Both C and Factor
observe that value; the outer `fts5_api.iVersion` is 3. The test does not assume the
header comment's value of 2 for this built-in tokenizer.

The additional `vfs-before.log` run preserves the newly added but incorrectly
`c-string`-typed `sqlite3_database_file_object` argument. Its raw-filename
contract check fails. The native callback test passes even with that declaration,
because Factor permits a raw pointer through `c-string` conversion unchanged.
After changing the declaration to `sqlite3_filename`, both checks pass. We do not
call SQLite on a copied filename: its hidden metadata would be missing, violating
the API contract. The VFS test invokes the Factor callback synchronously inside
`xOpen` only when `SQLITE_OPEN_MAIN_JOURNAL` or `SQLITE_OPEN_WAL` is set, and never
retains the borrowed filename pointer. The registered forwarding VFS, connections,
and temporary database are cleaned up before returning. `vfs-build.log` records
the fifth independent C control using the same valid invocation window.

## Reproduce

The [official 3.53.4 amalgamation](https://www.sqlite.org/2026/sqlite-amalgamation-3530400.zip)
is downloaded and verified against the SHA3-256 published on SQLite's
[download page](https://www.sqlite.org/download.html):
`628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e`.
The release date is July 24, 2026, per the
[official release history](https://www.sqlite.org/changes.html).

```sh
python3 reference/sqlite-3534-completion-20260908/optional/build.py \
  --output /tmp/sqlite-3534-optional
python3 reference/sqlite-3534-completion-20260908/optional/run.py \
  --vm /path/to/factor --image /path/to/factor.image \
  --library /tmp/sqlite-3534-optional/libsqlite3-optional.dylib
```

The build enables SESSION, PREUPDATE_HOOK, FTS5, CARRAY, COLUMN_METADATA,
STMT_SCANSTATUS, NORMALIZE, and SNAPSHOT. On Linux the library suffix is `.so`.
Recorded native execution is **macOS ARM64**, using the project's updated ARM64
VM and `reference/arm64-varargs-20260908/final.image`; Linux execution is not claimed.

The runner creates a temporary copy of the declarations bound to a distinct test
library name. This forces already compiled FFI words in the supplied image to
resolve the test library too. It replaces both the library registration and the
later `LIBRARY: sqlite` selection. The checked-in binding source is not modified.
`SQLITE_3534_LIBRARY` selects the native fixture library and
`SQLITE_3534_BINDINGS` selects that temporary declaration copy.

`baseline.factor` is intended for a worktree whose binding source is still
`c40418fff8`, with this baseline runner and test file copied in. Run it with the
same VM/image and that worktree's `-resource-path`; it exits 1 and records four
failures. The after runner exits 0. The support vocabulary contains no automatic
test file: these optional APIs are deliberately tested through this explicit
runner rather than against an arbitrary host SQLite build.

The test library is built from `sqlite3.c` plus `optional.c`; the control executable
is compiled independently against `sqlite3.h` and calls the public APIs directly.
The checked-in C source uses assertions for setup, return codes, native data, and
cleanup, so a disabled option or faulty control cannot produce a PASS line.
