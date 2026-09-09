# SQLite 3.53.4 declaration and native layout audit

The expanded binding covers every public declaration in the pinned official
SQLite 3.53.4 `sqlite3.h`: **364 functions, 523 value macros, 46 typedefs, and
23 complete records**. All normalized function signatures, callback aliases,
record field names/order/types, typedefs, and constant values pass. All **242
native layout measurements** match Factor: 23 sizes, 23 alignments, and 196
field offsets.

This includes the header's optional session, Rtree, FTS5, and carray surfaces.
It does not establish that a particular installed SQLite library enables every
optional facility. The layout oracle requires no linked SQLite library.

## Fail then pass

The baseline is `c40418fff8:basis/db/sqlite/ffi/ffi.factor`, retained as `baseline-ffi.factor` so history rebases do not invalidate reproduction. The audit records
SHA-256 hashes of both binding snapshots and of the official header.

| Check | Baseline | Expanded binding |
| --- | ---: | ---: |
| Functions present | 272/364 | 364/364 |
| Value macros present | 245/523 | 523/523 |
| Typedefs present | 40/46 | 46/46 |
| Complete record declarations present | 22/23 | 23/23 |
| Record field/order mismatches | 3 | 0 |
| Constant value mismatches | 2 | 0 |
| Raw pointer / ownership contract mismatches | 10 | 0 |
| Records invalidated by later `C-TYPE:` | 1 | 0 |
| Native layout mismatches/unavailable measurements | 37 | 0 |

The baseline has undersized `sqlite3_module` (192 instead of 200 bytes),
`Fts5ExtensionApi` (160 instead of 192), and `fts5_api` (32 instead of 48).
Their missing tail members and the absent `fts5_tokenizer_v2` account for 13
unavailable measurements. A `C-TYPE: sqlite3_io_methods` after its `STRUCT:`
invalidates that record and makes all 21 of its measurements fail. The baseline
therefore returns 208 numeric measurements, with 3 wrong sizes, against 242
expected values. These errors are preserved in `layout-factor-before.log` and
`layout-before.json`.

`header-audit-before.json` enumerates all absent declarations, version-value
mismatches, lost owned pointers (`sqlite3_expanded_sql` and `sqlite3_serialize`),
UTF-16/retained buffers, filename identity, FTS5 iterator pointers, and the invalidated record. `header-audit.json` and `layout-after.json` contain the
passing results. The `.log` files provide short summaries and raw measurements.

## Method and limits

`header-audit.py` reads declarations through Clang's C AST, using
`SQLITE_ENABLE_SESSION`, `SQLITE_ENABLE_PREUPDATE_HOOK`, and
`SQLITE_ENABLE_NORMALIZE`. It retains the release comparison's documented
public value-macro inventory, extends its Factor parser to include `CALLBACK:`
typedefs and the three Rtree relation constants, and detects opaque declarations
that overwrite complete records. It verifies all 523 values, including aliases,
bit expressions, strings, and the destructor sentinels.

Signature comparison resolves typedefs and callback aliases recursively,
compares return/argument types, pointer depth, arrays, variadic markers, record
field order/types, and callback argument signatures. C qualifiers have no
corresponding Factor FFI qualifier and are normalized away. Existing opaque
`void*` callback and data-pointer representations are ABI compatible but do not
provide typed callback signatures. Every such accepted representation, plus
UTF-8 byte/string representations, is explicitly recorded in
`abi_compatible_representations` (181 entries); it is not reported as an exact
C type match. Dedicated ownership checks retain allocating returns as raw
pointers, writable snprintf buffers as `char*`, and UTF-16 buffers as `void*`.
These structural checks complement the separate native behavioral FFI tests.

`layout-oracle.c` is generated solely from the official header inventory. Clang
measures each complete C record with `sizeof`, `_Alignof`, and `offsetof`.
`layout-factor.factor` measures the actual loaded Factor types with `heap-size`,
`c-type-align`, and `offset-of`. The comparator requires every native measurement
to be present and equal; caught Factor errors cannot produce a passing result.
The baseline probe omits declarations absent from that source snapshot and
records errors for declared but invalid types, allowing the entire baseline to
be compared.

Recorded execution: macOS ARM64, Apple Clang 21.0.0, target
`arm64-apple-darwin25.6.0`, verified variadic VM at
`/Users/erg/factor.worktrees/arm64-varargs-entry/factor`, image
`/Users/erg/factor/reference/arm64-varargs-20260908/final.image`.
Other platform layouts must be rerun on those targets; these are native macOS
measurements, not Linux or Windows execution claims.

## Reproduction

From the checkout root, using a Factor executable/image built for this checkout:

```sh
python3 reference/sqlite-3534-completion-20260908/header-audit.py --generate-layout
clang -std=c11 -Wall -Wextra -Werror reference/sqlite-3534-completion-20260908/layout-oracle.c -o /tmp/sqlite-layout-oracle
/tmp/sqlite-layout-oracle > reference/sqlite-3534-completion-20260908/layout-c.log
./factor -no-user-init reference/sqlite-3534-completion-20260908/layout-factor.factor > reference/sqlite-3534-completion-20260908/layout-factor.log 2>&1
python3 reference/sqlite-3534-completion-20260908/header-audit.py --check-layout reference/sqlite-3534-completion-20260908/layout-c.log reference/sqlite-3534-completion-20260908/layout-factor.log --name layout-after.json
```

When reusing another checkout's VM/image, add its `-i=/absolute/image` and this
checkout's `-resource-path=/absolute/checkout` arguments. The generated Factor
probe reloads `db.sqlite.ffi` at parse time. On this host background processes
required `taskpolicy -B -p <actual Factor.app process ID>` for normal throughput.

For baseline declaration evidence, pass `--binding reference/sqlite-3534-completion-20260908/baseline-ffi.factor --name header-audit-before.json`.
For baseline native layout evidence, run the retained
`layout-factor-before.factor` in an isolated checkout containing that binding,
then compare its output with the same native oracle using `--check-layout`.
The baseline audit/comparison must exit 1; the updated audit/comparison must
exit 0. Generating a new baseline probe with `--binding` and `--generate-layout`
writes `layout-factor.factor`, so preserve the final probe before doing so.

The pinned header is from the [official 3.53.4 amalgamation archive](https://www.sqlite.org/2026/sqlite-amalgamation-3530400.zip).
Its archive and extracted-header checksums are recorded in
`../library-release-comparison-20260908/sqlite/sources.json`; the audit refuses
a header with a different SHA-256. The release is listed in SQLite's
[official release history](https://www.sqlite.org/changes.html).
