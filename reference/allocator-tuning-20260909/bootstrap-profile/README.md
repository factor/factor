# Diagnostic default-bootstrap profile

Source a1a0ac367d (merged baseline plus backtracking index-only optimization,
which is not selected by default), with the archived diagnostic-only stage2
patch. The patch enables 100 Hz sampling around the original default components,
prints flat/leaf profiles after stopping collection, and exits without saving
an image. Production stage2 source was restored afterward. Exact hashes,
command and status are retained. This is not a timing acceptance run.

The run completed with exit 0, core report 1:59 and whole process 123.66 seconds.
This does not establish that the prior 2:12 budget miss is fixed: no bootstrap
optimization was applied, and profiling/reporting differs from cold image
creation. An unprofiled final bootstrap and saved-image verification remain
required.

Sampled inclusive times (overlapping, not additive) include 119.74 seconds total,
29.01 seconds optimize-tree, 24.00 seconds frontend, 6.11 seconds linear-scan,
5.21 seconds destruct-ssa, 1.72 seconds coalesce-cfg and 0.34 seconds shared
prepare-allocation-bases. Derived-definition analysis accounts for 0.09 seconds.
These coarse samples do not support treating the new GC-base preparation as a
major default-bootstrap regression, or justify speculative changes to its
correctness fix. Sampling includes substantial signal-handler frames; leaf
attribution should not be read as a precise primitive-level cost model.
