! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays io.backend io.launcher io.pathnames kernel math sequences ;

IN: benchmark.spawn-cat

! Like Jarred Sumner's spawning-cat benchmark: 100 concurrent children per
! batch, no shell, all standard streams discarded, and every exit awaited.
: spawn-cat-batch ( path -- )
    '[
        <process> "cat" _ 2array >>command
        +closed+ >>stdin +closed+ >>stdout +closed+ >>stderr run-detached
    ] 100 swap replicate wait-for-success ;

: spawn-cat ( path batches -- )
    [ normalize-path ] dip swap '[ _ spawn-cat-batch ] times ;

: spawn-cat-benchmark ( -- )
    "resource:extra/benchmark/spawn-cat/spawn-cat.factor" 100 spawn-cat ;

MAIN: spawn-cat-benchmark
