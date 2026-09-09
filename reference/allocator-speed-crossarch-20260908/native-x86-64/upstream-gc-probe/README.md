# Upstream compiler provenance probe

The same moving-GC regression fails with exact upstream-master implementations
from `b21f5d1611`. On native x86-64 it reports
`{ linear-scan-allocator f f }` and exits 1: neither the plain bitcast nor the
nonzero-offset pointer preserves object identity across collection.

The experiment loads only upstream `liveness.factor`, SSA `destruction.factor`
and interference `live-ranges.factor` into a separate process from the existing
source-233 prepared VM/image. It confirms that these upstream compiler routines
contain the defect in this native test environment. It is **not a clean upstream
bootstrap or full upstream validation**. Exact source hashes, upstream commit,
process status and raw log are retained.

For replay, extract the three paths listed by `source-manifest.json` from the
recorded upstream commit into `reference/allocator-speed-crossarch-20260908/
upstream-gc-probe/` as `liveness.factor`, `destruction.factor` and
`live-ranges.factor`, then run this directory's `moving-gc.factor` using the
recorded source-233 prepared image and explicit resource root.

The corrected three-file implementation in `d1bfcc67b9` passes all four
allocators and both cases in the same VM/image; see the adjacent
`gc-provenance-regression` evidence.
