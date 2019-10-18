! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel vocabs vocabs.loader tools.time vocabs.hierarchy
arrays assocs io.styles io help.markup prettyprint sequences
continuations debugger math namespaces memory fry ;
IN: benchmark

<PRIVATE

SYMBOL: timings
SYMBOL: errors

PRIVATE>

: run-benchmark ( vocab -- time )
    [ 5 ] dip '[ gc [ _ run ] benchmark ] replicate infimum ;

<PRIVATE

: record-benchmark ( vocab -- )
    [ "=== " write print flush ] [
        [ [ require ] [ run-benchmark ] [ ] tri timings ]
        [ swap errors ]
        recover get set-at
    ] bi ;

PRIVATE>

: run-benchmarks ( -- timings errors )
    [
        V{ } clone timings set
        V{ } clone errors set
        "benchmark" child-vocab-names
        [ find-vocab-root ] filter
        [ record-benchmark ] each
        timings get
        errors get
    ] with-scope ;

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

: benchmarks ( -- )
    run-benchmarks [ timings. ] [ benchmark-errors. ] bi* ;

MAIN: benchmarks

