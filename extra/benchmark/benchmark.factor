! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel vocabs vocabs.loader tools.time tools.vocabs
arrays assocs io.styles io help.markup prettyprint sequences
continuations debugger math ;
IN: benchmark

: run-benchmark ( vocab -- result )
    [ "=== " write vocab-name print flush ] [
        [ [ require ] [ [ run ] benchmark ] bi ] curry
        [ error. f ] recover
    ] bi ;

: run-benchmarks ( -- assoc )
    "benchmark" all-child-vocabs-seq
    [ dup run-benchmark ] { } map>assoc ;

: benchmarks. ( assoc -- )
    standard-table-style [
        [
            [ "Benchmark" write ] with-cell
            [ "Time (seconds)" write ] with-cell
        ] with-row
        [
            [
                [ [ 1array $vocab-link ] with-cell ]
                [ [ 1000000 /f pprint-cell ] [ "failed" write ] if* ] bi*
            ] with-row
        ] assoc-each
    ] tabular-output ;

: benchmarks ( -- )
    run-benchmarks benchmarks. ;

MAIN: benchmarks

