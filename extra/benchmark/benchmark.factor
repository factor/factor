! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs command-line continuations debugger
formatting help.markup io io.styles kernel math memory
namespaces sequences tools.profiler.sampling tools.test
tools.time vocabs.hierarchy vocabs.loader ;
IN: benchmark

SYMBOL: benchmarks-disabled?

: run-timing-benchmark ( vocab -- time )
    5 swap '[ gc [ _ run ] benchmark ] replicate infimum ;

: run-profile-benchmark ( vocab -- profile )
    compact-gc '[ _ run ] profile most-recent-profile-data ;

: all-benchmark-vocabs ( -- seq )
    "benchmark" disk-child-vocab-names [ find-vocab-root ] filter ;

: find-benchmark-vocabs ( -- seq )
    benchmarks-disabled? get [
        "benchmarks-disabled? is true, not benchmarking anything!" print
        { }
    ] [
        command-line get [ all-benchmark-vocabs ] when-empty
    ] if ;

<PRIVATE

: write-header ( str -- )
    "=== %s\n" printf ;

: run-benchmark ( vocab quot: ( vocab -- res ) -- result ok? )
    over write-header '[ _ @ t ] [
        f f f <test-failure> f
    ] recover ; inline

PRIVATE>

: run-benchmarks ( benchmarks quot: ( vocab -- res ) -- results errors )
    '[ dup _ run-benchmark 3array ] map
    [ third ] partition [ [ 2 head ] map ] bi@ ; inline

: run-profile-benchmarks ( -- results errors )
    find-benchmark-vocabs [ run-profile-benchmark ] run-benchmarks ;

: run-timing-benchmarks ( -- results errors )
    find-benchmark-vocabs [ run-timing-benchmark ] run-benchmarks ;

: timings. ( assoc -- )
    standard-table-style [
        [
            [ "Benchmark" write ] with-cell
            [ "Time (seconds)" write ] with-cell
        ] with-row
        [
            [
                [ [ 1array $vocab-link ] with-cell ]
                [ 1,000,000,000 /f [ "%.3f" printf ] with-cell ]
                bi*
            ] with-row
        ] assoc-each
    ] tabular-output nl ;

: benchmark-errors. ( assoc -- )
    [
        [ write-header ] [ error. ] bi*
    ] assoc-each ;

: timing-benchmarks ( -- )
    run-timing-benchmarks [ timings. ] [ benchmark-errors. ] bi* ;

MAIN: timing-benchmarks
