! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs continuations debugger formatting fry help.markup
io io.styles kernel math memory prettyprint sequences
tools.profiler.sampling tools.test tools.time vocabs.hierarchy vocabs.loader ;
IN: benchmark

: run-timing-benchmark ( vocab -- time )
    5 swap '[ gc [ _ run ] benchmark ] replicate infimum ;

: run-profile-benchmark ( vocab -- profile )
    compact-gc '[ _ run ] profile most-recent-profile-data ;

: find-benchmark-vocabs ( -- seq )
    "benchmark" disk-child-vocab-names [ find-vocab-root ] filter ;

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
                [ 1,000,000,000 /f pprint-cell ]
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
