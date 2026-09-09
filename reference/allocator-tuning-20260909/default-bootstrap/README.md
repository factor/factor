# Default bootstrap acceptance

Frozen source `5c848c90f63cea092191b70e1678bec4441e0238` bootstraps successfully
from the unchanged ARM64 boot seed with default linear scan, GVN off and
rematerialization off. Core and user bootstrap both report **1:52**; the entire
process takes **116.00 seconds**, below the requested 120-second budget.
The per-PID final sample records 113.93 CPU seconds,
1,800,212,929,873 retired instructions and 478,275,373,603 cycles.

This is an unprofiled run that saves a new image in the isolated final-candidate
worktree. [The exact command and run status](bootstrap/status.json) retain source,
VM/input-image hashes, host load and phase counters. The separately invoked
[image check](image-verification/status.json) passes: linear scan selected, GVN
and rematerialization off, zero compiler errors, integer/float arithmetic,
loop and moving-GC checks. It exits 0 in 0.49 seconds.

The new image is
`/Users/erg/factor.worktrees/allocator-tuning-final-candidate/full-tuning-default.factor.image`.
[Image hashes](image-hashes.json) prove that the root `factor.image` and the
original worktree image remain unchanged. No root image was overwritten.

This establishes an under-budget bootstrap on this host in this run. It does
**not** establish a default-path source optimization from the alternative
allocator changes. Retired work differs by only -0.138% from the retained
2:12 core bootstrap (135.63 seconds whole process); execution rate changed
substantially. The default LS path is unchanged, and the diagnostic profile
identified frontend/tree optimization as larger costs than shared allocator
base preparation. Preserve both observations when assessing bootstrap speed.
