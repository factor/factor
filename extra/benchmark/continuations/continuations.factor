USING: math kernel continuations ;
IN: benchmark.continuations

: continuations-benchmark ( -- )
    100000 [ drop [ continue ] callcc0 ] each-integer ;

MAIN: continuations-benchmark
