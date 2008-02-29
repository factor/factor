! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel vocabs vocabs.loader tools.time tools.browser
arrays assocs io.styles io help.markup prettyprint sequences
continuations debugger ;
IN: benchmark

: run-benchmark ( vocab -- result )
  [ dup require [ run ] benchmark ] [ error. drop f f ] recover 2array ;

: run-benchmarks ( -- assoc )
  "benchmark" all-child-vocabs values concat [ vocab-name ] map
  [ dup run-benchmark ] { } map>assoc ;

: benchmarks. ( assoc -- )
    standard-table-style [
        [
            [ "Benchmark" write ] with-cell
            [ "Run time (ms)" write ] with-cell
            [ "GC time (ms)" write ] with-cell
        ] with-row
        [
            [
                swap [ ($vocab-link) ] with-cell
                first2 pprint-cell pprint-cell
            ] with-row
        ] assoc-each
    ] tabular-output ;

: benchmarks ( -- )
    run-benchmarks benchmarks. ;

MAIN: benchmarks

