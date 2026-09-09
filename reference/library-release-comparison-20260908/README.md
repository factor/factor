# SQLite and Raylib latest-release comparison

Checked 2026-09-08 against stable released headers, after the variadic binding
cleanup. This report inventories declarations; it does not upgrade libraries.

| Library | Binding reference | Latest stable | Result |
| --- | --- | --- | --- |
| Raylib | 6.0 | 6.0, 2026-04-23 | All 600 exported function names; nine function type/arity discrepancies, one callback signedness mismatch, one missing enum member |
| SQLite | 3.51.0 | 3.53.4, 2026-07-24 | 272/364 header function names; 11 new and 81 older omissions, many optional |

[Raylib details and reproduction](raylib/README.md) identify the missing final
LoadFontData output pointer, UpdateModelAnimation's int-to-float change, binary
buffer/string distinctions, AudioCallback signedness, and missing mouse flag.
All 35 struct field ABI shapes and all 26 color values match after normalization;
these source checks do not substitute for platform ABI execution tests.

[SQLite details and reproduction](sqlite/README.md) separate new core functions
sqlite3_str_free/sqlite3_str_truncate from one new optional carray and eight new
session functions. Seven new value macros are missing. Older issues include
allocated/binary string marshaling, UTF-16 preparation, incomplete module/FTS5
struct tails, and older optional APIs. Existing bound function argument counts
and ellipsis markers match the latest header.

The runtime SQLite library is loaded dynamically; the binding's reference
version constant does not identify or upgrade that installed library. New SQL
syntax usually needs a newer engine, not a new FFI declaration.

Primary release sources: [Raylib 6.0](https://github.com/raysan5/raylib/releases/tag/6.0)
and [SQLite 3.53.4](https://sqlite.org/releaselog/3_53_4.html).
Both comparisons include reproducible scripts and machine-readable inventories.
