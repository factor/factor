# SQLite release comparison — 2026-09-08

The binding names SQLite **3.51.0** as its audited reference; the latest stable release is **3.53.4 (2026-07-24)**. The label does not constrain the shared library loaded at runtime. This is a declaration comparison, not a library upgrade or a claim that every optional symbol exists in the installed library. [Official downloads](https://www.sqlite.org/download.html), [3.53.4 release](https://www.sqlite.org/releaselog/3_53_4.html).

Compared `basis/db/sqlite/ffi/ffi.factor` at Factor commit `d6f31d261673c59555211bda72777119605dabf9` against both official release headers. Commented declarations are excluded. Pointer sentinel words `SQLITE_STATIC` and `SQLITE_TRANSIENT` are included as constants.

| Released header inventory | Present by name | Missing | Missing already in 3.51.0 | Added since 3.51.0 |
| --- | ---: | ---: | ---: | ---: |
| Functions, 364 total | 272 | 92 | 81 | 11 |
| Value macros, 523 total | 245 | 278 | 271 | 7 |
| Complete named structs, 23 total | 22 | 1 | 1 | 0 |
| Typedef names, 46 total | 40 | 6 | 6 | 0 |

“Present” counts names, not necessarily complete layouts or safe ownership semantics. Typedef presence includes Factor opaque C types and structs. The three extra Factor names `sqlite3_index_constraint`, `sqlite3_index_orderby`, and `sqlite3_index_constraint_usage` are legitimate names for nested C structs, not obsolete typedefs. No active Factor function name is absent from the latest header. No common upstream function signature, struct layout, or typedef changed between the two releases.

## Actual release delta

All **11 new functions** are missing:

- Core: `sqlite3_str_free`, `sqlite3_str_truncate`.
- Optional carray: `sqlite3_carray_bind_v2`.
- Optional session: `sqlite3changegroup_config`, `sqlite3changegroup_change_begin`, `sqlite3changegroup_change_blob`, `sqlite3changegroup_change_double`, `sqlite3changegroup_change_finish`, `sqlite3changegroup_change_int64`, `sqlite3changegroup_change_null`, `sqlite3changegroup_change_text`.

All **7 new value macros** are missing: `SQLITE_CHANGEGROUP_CONFIG_PATCHSET`, `SQLITE_CHANGESETAPPLY_NOUPDATELOOP`, `SQLITE_DBCONFIG_FP_DIGITS`, `SQLITE_LIMIT_PARSER_DEPTH`, `SQLITE_PREPARE_FROM_DDL`, `SQLITE_TESTCTRL_ATOF`, `SQLITE_UTF8_ZT`.

The 11 functions were introduced in 3.53.0. Version 3.52.0 was withdrawn. New SQL syntax/functions are available through existing SQL execution bindings when the runtime library supports them; they do not each require a new C binding. The new Query Result Formatter is a separate library, outside `sqlite3.h`. [3.53.0 release notes](https://www.sqlite.org/releaselog/3_53_0.html), [withdrawn 3.52.0](https://www.sqlite.org/releaselog/3_52_0.html).

Existing version/source metadata macros change, as does `SQLITE_DBCONFIG_MAX` (1022 → 1023). Among the 245 bound value macros, only the two deliberately documented audit-version constants differ; all other values match.

## Older gaps and optional APIs

| Function family | Header functions | Bound | Missing |
| --- | ---: | ---: | ---: |
| Core header, including optional core facilities | 301 | 270 | 31 |
| Session / changeset / changegroup / rebaser | 59 | 0 | 59 |
| Rtree | 2 | 2 | 0 |
| Carray | 2 | 0 | 2 |
| FTS5 | 0 standalone functions | — | Struct interfaces below |

The **29 older core-header function gaps** are:

- Filename/URI objects: `sqlite3_create_filename`, `sqlite3_database_file_object`, `sqlite3_filename_database`, `sqlite3_filename_journal`, `sqlite3_filename_wal`, `sqlite3_free_filename`, `sqlite3_uri_key`.
- Connection/status/control: `sqlite3_autovacuum_pages`, `sqlite3_db_status64`, `sqlite3_get_clientdata`, `sqlite3_set_clientdata`, `sqlite3_hard_heap_limit64`, `sqlite3_is_interrupted`, `sqlite3_set_errmsg`, `sqlite3_setlk_timeout`.
- Virtual tables and values: `sqlite3_drop_modules`, `sqlite3_value_encoding`, `sqlite3_vtab_distinct`, `sqlite3_vtab_in`, `sqlite3_vtab_in_first`, `sqlite3_vtab_in_next`, `sqlite3_vtab_rhs_value`.
- Optional preupdate hook: `sqlite3_preupdate_blobwrite`, `sqlite3_preupdate_count`, `sqlite3_preupdate_depth`, `sqlite3_preupdate_hook`, `sqlite3_preupdate_new`, `sqlite3_preupdate_old`.
- Optional statement scan status: `sqlite3_stmt_scanstatus_v2`.

There are **51 older session gaps** plus the 8 new functions above, and the older `sqlite3_carray_bind` is also missing. The complete exact lists, including all 271 older missing macros, are in [comparison.json](comparison.json). The missing macro breakdown is 247 core-header, 18 session, 5 FTS5, 5 carray, and 3 Rtree. The inventory includes public test-control and deprecated/unused value macros; those are not all equally useful implementation priorities.

The six missing typedef names are `sqlite3_filename`, `sqlite3_session`, `sqlite3_changeset_iter`, `sqlite3_changegroup`, `sqlite3_rebaser`, and `fts5_tokenizer_v2`. All existed in 3.51.0.

Optional symbols remain conditional on the library build. In particular session, preupdate, scanstatus, normalize, snapshot, Rtree, carray, column metadata, and extension-loading facilities must not be assumed available merely because the release header declares them. The inventory enables session, preupdate, and normalize declarations; does not enable proprietary CEROD; and assumes the usual floating-point build. It covers the complete amalgamation `sqlite3.h`, including appended Rtree/session/FTS5 declarations. Separate extension headers, `sqlite3ext.h`'s extension dispatch table, QRF, CLI, and language-specific interfaces are outside the denominator.

## Existing declaration problems

The automated comparison finds **zero parameter-count or variadic-marker mismatches** among the 272 active functions. The recently corrected formatting APIs retain explicit ellipses / canonical `va_list` and raw allocated-output or writable-buffer pointers. A matching pointer ABI alone does not establish safe marshaling:

| Existing declaration | Header contract and consequence | Follow-up |
| --- | --- | --- |
| `sqlite3_expanded_sql` returns `c-string` | SQLite allocates the result; automatic string conversion loses the pointer needed for `sqlite3_free` | Raw `char*` plus an ownership-aware convenience wrapper |
| `sqlite3_serialize` returns `c-string` | Result is binary, length-delimited database content and usually allocated; text conversion truncates at NUL and loses ownership | Raw `uchar*` plus explicit length/free handling |
| `sqlite3_deserialize` takes `c-string pData` | Database buffer is retained, optionally written, freed, or reallocated by SQLite | Raw `uchar*` with documented allocation and lifetime requirements |
| `sqlite3_prepare16` takes `c-string zSql` | C expects UTF-16 bytes; Factor's default string marshaling is not that contract | `void*` or explicit UTF-16 string type, consistent with `_v2`/`_v3` |

These are preexisting findings, not regressions introduced by 3.53.4. They were identified from declarations and ownership documentation, not newly executed fail-before/pass-after tests. [Expanded SQL ownership](https://www.sqlite.org/c3ref/expanded_sql.html), [serialization](https://www.sqlite.org/c3ref/serialize.html), [deserialization](https://www.sqlite.org/c3ref/deserialize.html), [UTF-16 preparation](https://www.sqlite.org/c3ref/prepare.html).

Other semantic follow-ups: `sqlite3_db_filename` copies a native filename object to a Factor string; filename/URI APIs that need the original SQLite filename object require a raw-pointer route. FTS5 phrase iterators expose opaque byte positions (`const unsigned char*`) as `c-string` fields, so normal field access performs text marshaling instead of preserving cursor addresses. Callback typedefs/struct callback fields are commonly `void*`, preserving pointer layout but providing no typed callback declaration. These are API-model limitations, not new scalar-width/argument-count failures. [SQLite filename objects](https://www.sqlite.org/c3ref/filename.html), [FTS5 extension interface](https://www.sqlite.org/fts5.html#custom_auxiliary_functions).

Three existing structs omit members already present in 3.51.0:

- `sqlite3_module`: `xIntegrity` (version 4).
- `Fts5ExtensionApi`: `xQueryToken`, `xInstToken`, `xColumnLocale`, `xTokenize_v2`.
- `fts5_api`: `xCreateTokenizer_v2`, `xFindTokenizer_v2`.

`fts5_tokenizer_v2` is entirely absent (fields `iVersion`, `xCreate`, `xDelete`, `xTokenize`). Existing prefixes can still be used with the appropriate older interface versions; merely raising their version values without extending the structs would be incorrect. No listed struct changed between 3.51.0 and 3.53.4.

## Reproduce

```sh
python3 reference/library-release-comparison-20260908/sqlite/compare.py
# Re-download official archives and verify recorded hashes before comparing:
python3 reference/library-release-comparison-20260908/sqlite/compare.py --download
```

Requires Python 3 and Clang; no installed SQLite or Factor executable is used. The script parses C declarations with Clang AST JSON, parses this binding's active declaration forms, checks header hashes, and regenerates the three inventories and comparison. Inventory collection was verified using Apple Clang 21.0.0. The complete release headers are SQLite public-domain source; `sources.json` records archive SHA3-256 and header SHA-256. The script's binding parser is deliberately specific to this vocabulary's current syntax. Arity/ellipsis and constant values are checked automatically; ownership, pointed-to data semantics, optional availability, and compatibility judgments above are manual review, not claims of a complete runtime ABI test.
