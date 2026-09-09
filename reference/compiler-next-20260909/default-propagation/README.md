# Default propagation diagnostic

A count-only annotated 13-word compiler/benchmark corpus at clean source
`c1f7e4d34cd604bbdf22576b237406b39758896d` identifies repeated class construction
and class-algebra operations. Exact executed script, command, original source,
VM/image hashes and raw counts are retained. These are instrumentation counts,
not performance measurements or a full compiler closure. The script compiles
current word bodies through the production frontend, CFG passes and generation;
it does not install measured code.

Identical value-info objects are rare enough that an extra general intersection
identity branch was not selected. Repeated class-info construction is common,
but a new cache would require class-redefinition invalidation, and skipping
entailed refinements can change canonicalization of custom/noncanonical infos.
Neither broader shortcut is introduced.

The next candidate tests the existing class-algebra identity law only for named
word classes. Anonymous classoids remain on their structural-cache path, where
interning equal descriptors can affect subsequent conservative class<= queries.
Recorded same-class counters include anonymous descriptors and are an upper
bound for the narrower named-class fast path. Actual uninstrumented compiler
CPU/retired work must decide acceptance.

The named-class prototype passes the complete existing algebra test file plus
new named-class idempotency and primed anonymous-cache/opaque-predicate tests.
Exact tested source hashes and retained output are in `algebra-tests/`. Full
compiler correctness and uninstrumented cost acceptance are still pending.
