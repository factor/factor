! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io.backend io.launcher kernel math sequences
system ;

IN: benchmark.spawn-cat

! Like Jarred Sumner's spawning-cat benchmark: 100 concurrent children per
! batch, no shell, all standard streams discarded, and every exit awaited.
: cat-command ( path -- command )
    os windows? { "cmd.exe" "/c" "type" } { "cat" } ? swap suffix ;

: spawn-cat-batch ( path -- )
    '[
        <process> _ cat-command >>command
        +closed+ >>stdin +closed+ >>stdout +closed+ >>stderr run-detached
    ] 100 swap replicate wait-for-success ;

: spawn-cat ( path batches -- )
    [ normalize-path ] dip swap '[ _ spawn-cat-batch ] times ;

: spawn-cat-benchmark ( -- )
    "resource:extra/benchmark/spawn-cat/spawn-cat.factor" 100 spawn-cat ;

MAIN: spawn-cat-benchmark
