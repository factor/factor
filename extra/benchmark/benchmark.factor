! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs continuations debugger fry help.markup io
io.styles kernel math memory namespaces prettyprint sequences
tools.profiler.sampling tools.time vocabs vocabs.hierarchy
vocabs.loader ;
IN: benchmark

<PRIVATE

SYMBOL: results
SYMBOL: errors

PRIVATE>

: run-timing-benchmark ( vocab -- time )
    [ 5 ] dip '[ gc [ _ run ] benchmark ] replicate infimum ;

: run-profile-benchmark ( vocab -- profile )
    compact-gc '[ _ run ] profile most-recent-profile-data ;

: find-benchmark-vocabs ( -- seq )
    "benchmark" disk-child-vocab-names
    [ find-vocab-root ] filter ;

<PRIVATE

: print-record-header ( vocab -- )
    "=== " write print flush ;

: run-benchmark ( vocab quot -- )
    [ drop print-record-header ] [
        '[
            _ [ [ require ] _ [ ] tri results ]
            [ swap errors ]
            recover get set-at
        ] call
    ] 2bi ; inline

: run-benchmarks ( quot -- results errors )
    '[
        results errors
        [ [ V{ } clone swap set ] bi@ ]
        [ 2drop find-benchmark-vocabs [ _ run-benchmark ] each ]
        [ [ get ] bi@ ]
        2tri
    ] with-scope ; inline

PRIVATE>

: run-timing-benchmarks ( -- results errors )
    [ run-timing-benchmark ] run-benchmarks ;

: run-profile-benchmarks ( -- results errors )
    [ run-profile-benchmark ] run-benchmarks ;

: timings. ( assocs -- )
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

: benchmark-errors. ( errors -- )
    [
        [ "=== " write vocab-name print ]
        [ error. ]
        bi*
    ] assoc-each ;

: timing-benchmarks ( -- )
    run-timing-benchmarks
    [ timings. ] [ benchmark-errors. ] bi* ;

MAIN: timing-benchmarks
