! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel vocabs vocabs.loader tools.time tools.vocabs
arrays assocs io.styles io help.markup prettyprint sequences
continuations debugger ;
IN: benchmark

: run-benchmark ( vocab -- result )
  [ [ require ] [ [ run ] benchmark ] bi ] curry
  [ error. f ] recover ;

: run-benchmarks ( -- assoc )
  "benchmark" all-child-vocabs-seq
  [ dup run-benchmark ] { } map>assoc ;

: benchmarks. ( assoc -- )
    standard-table-style [
        [
            [ "Benchmark" write ] with-cell
            [ "Time (ms)" write ] with-cell
        ] with-row
        [
            [
                [ [ 1array $vocab-link ] with-cell ]
                [ pprint-cell ] bi*
            ] with-row
        ] assoc-each
    ] tabular-output ;

: benchmarks ( -- )
    run-benchmarks benchmarks. ;

MAIN: benchmarks

