# Linear integration

`agent1-sheeple` was fetched again at the user's request. Its
`master-candidate` remained at `2e42c46e631340a4a95bd6ce9f8e61f9aa624bf6`.
The common base was `c398c7cb417622c0df784520faf95165e4bb20f9`:
eight incoming commits and eighteen local ABI/binding commits.

The eighteen local commits were replayed above the fetched tip in an isolated
worktree, yielding `2bff152061ab859d9b75aad774783b4b0e37cf67`. The sole conflict
was an add/add of `extra/libudev/libudev-tests.factor`; the resolution retains
both the Linux capability tests and the variadic callback signature test.
`macos/range-diff.txt` records that this test union is the only change in the
replayed patches. The incoming and rebased tree comparisons cover the same
27 paths, with no unexpected or missing paths.

The root `master-candidate` branch was then rebased onto that verified replay.
SQLite 3.53.4 completion, Raylib 6.0 completion, and the test-driven integration
fixes were cherry-picked or committed above it. No merge commits were added.
`backup/bindings-before-agent1-20260908` retains the original local tip
`c40418fff8`.

The library and platform reports retain their original worktree commit IDs
as provenance; cherry-picking changes commit IDs without changing their patches.
The root branch contains the resulting changes in linear history. No push was
requested or performed.
