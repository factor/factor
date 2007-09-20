USING: math kernel continuations ;
IN: benchmark.continuations

: continuations-main
    100000 [ drop [ continue ] callcc0 ] each-integer ;

MAIN: continuations-main
