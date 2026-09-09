# SQLite 3.53.4 binding completion

The binding now covers all public declarations in the pinned official 3.53.4 `sqlite3.h`: **364 functions, 523 value macros, 46 typedef names, and 23 complete named structs**. The completed inventory includes optional session/changeset/changegroup/rebaser, Rtree, FTS5, and carray interfaces. The library build still determines which optional symbols are available. Separate extension dispatch tables (`sqlite3ext.h`), QRF, CLI, and language interfaces remain outside this header's scope. [Official release](https://www.sqlite.org/releaselog/3_53_4.html), [download and checksums](../library-release-comparison-20260908/sqlite/sources.json).

The work adds the 92 missing functions and 278 missing macros, six missing type names, the missing tokenizer struct, and all missing struct tails. It also removes an older duplicate `C-TYPE:` declaration that invalidated the full `sqlite3_io_methods` layout.

## Public API changes

- `sqlite3_expanded_sql` returns owned `char*`; callers decode explicitly and call `sqlite3_free`.
- `sqlite3_serialize` returns raw binary `uchar*`, with length through `piSize`. The normal result is owned; `SQLITE_SERIALIZE_NOCOPY` borrows existing storage.
- `sqlite3_deserialize` takes a retained native `uchar*`. SQLite may write/free/reallocate it according to flags. SQLite allocation is required for FREEONCLOSE/RESIZEABLE.
- `sqlite3_prepare16` accepts UTF-16 bytes as `void*`, consistently with the other UTF-16 preparation functions.
- `sqlite3_filename` is a raw `char*` alias. Filename-returning functions and URI-input functions preserve native identity. `sqlite3_database_file_object` takes the original journal/WAL filename provided to VFS `xOpen`.
- FTS5 phrase iterator fields are raw `uchar*` positions. Extended callback tables include the latest fields; callers must respect their interface versions.
- New callback types cover preupdate, streaming, session filtering/conflicts, autovacuum, and tokenizer interfaces. `sqlite3_destructor_type` is now a typed callback; documented STATIC/TRANSIENT sentinels retain their behavior.

The only existing repository caller affected by filename result marshaling was `db.sqlite.lib:current-sqlite-filename`; it now decodes explicitly and preserves its string-returning behavior. Its existing regression test passes. No repository callers of the newly raw serialization/expanded-SQL or corrected legacy UTF-16 preparation interfaces required migration. Vocabulary documentation describes allocation, lifetime, and optional-feature requirements.

## Native evidence

| Check | Before | After |
| --- | --- | --- |
| Full released-header declaration audit | 92 function / 278 macro / 6 type / 1 struct omissions; other contract failures | Zero omissions, signature/value/layout-declaration/contract failures |
| C versus Factor struct measurements | 37 mismatches or unavailable values | 242/242: 23 sizes, 23 alignments, 196 field offsets |
| Core pointer contract checks | Four failures using the old declarations with the same 3.53.4 library | Nine passing native checks |
| Optional extension checks | Four declaration/layout failures | Thirteen passing checks, including journal/WAL VFS filename identity |
| Existing SQLite vocabulary tests and help lint | — | 26 checks, no test/compiler/help-lint failures |

`core-before.log` records actual incorrect expanded-SQL and binary serialization return results, plus two declaration-contract failures for retained binary and UTF-16 inputs. The negative run deliberately avoids invoking deserialization with the unsafe old string contract. `core-after.log` includes an owned binary round-trip: serialize a database, close its source connection, transfer the native allocation to another connection, read the original value, and close the target. It also covers Unicode UTF-16 SQL, filename components, and builder truncation/free. `core-controls.c` independently performs the corresponding real SQLite operations and passes.

The [optional report](optional/README.md) documents session changeset/apply, carray values with a distinct destructor context, preupdate callbacks and introspection, and native FTS5 tokenization. Its runner positively checks version 3.53.4 and every required compile option. The [header/layout report](HEADER-AUDIT.md) includes exact baseline and passing measurements, limitations, and full reproducible audits. The VFS evidence checks original pointers during journal and WAL `xOpen` calls. Its pre-fix metadata check fails, while a correctly supplied raw pointer already passes at runtime because Factor c-string input accepts raw pointers unchanged; the test does not manufacture an unsafe copied-filename call.

All recorded native execution here is **macOS ARM64**, Apple Clang 21, using the verified Factor VM/image from the ARM64 ABI work. Linux and Windows native runs are not claimed. The binding reference version is not a runtime minimum; existing APIs can still be used against older libraries, with application-selected capability checks for newer or optional symbols.

## Reproduce

Build the official amalgamation with the tested optional facilities and C oracle:

```sh
python3 reference/sqlite-3534-completion-20260908/optional/build.py --output /tmp/sqlite-3534-optional
```

Run the pointer tests and existing regressions using a compatible Factor executable and image:

```sh
python3 reference/sqlite-3534-completion-20260908/run-core.py \
  --vm /path/to/factor --image /path/to/factor.image \
  --library /tmp/sqlite-3534-optional/libsqlite3-optional.dylib
# Same command with --baseline must exit 1 (four expected failures).
# Same command with --regressions must exit 0.
```

The retained `baseline-ffi.factor` is the original binding source, so the negative test does not depend on old commit IDs surviving a rebase. `baseline-tests.factor` deliberately contains only APIs present before the change. The isolated runner rewrites a temporary binding copy to a distinct library name before loading it, ensuring cached image code cannot silently continue calling the host's older SQLite library. It does not edit the installed or checked-in library configuration.

Build/run the independent core control against that same library:

```sh
clang -std=c11 -Wall -Wextra -Werror -O2 \
  -I/tmp/sqlite-3534-optional \
  reference/sqlite-3534-completion-20260908/core-controls.c \
  /tmp/sqlite-3534-optional/libsqlite3-optional.dylib -o /tmp/sqlite-core-controls
/tmp/sqlite-core-controls
```

The optional build script currently uses macOS shared-library flags; its documented native result is specific to that host. The full header audit and C layout oracle can be rerun independently on other targets. Optional native fixtures are explicit-run qualification tools, not silently skipped tests against arbitrary host libraries.
