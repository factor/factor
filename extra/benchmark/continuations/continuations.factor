USING: math kernel continuations ;
IN: benchmark.continuations

: continuations-benchmark ( -- )
    1,000,000 [ drop [ continue ] callcc0 ] each-integer ;

MAIN: continuations-benchmark
