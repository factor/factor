USING: math kernel ;
IN: benchmark.empty-loop-1

: empty-loop-1 ( n -- )
    [ drop ] each-integer ;

: empty-loop-1-benchmark ( -- )
    50000000 empty-loop-1 ;

MAIN: empty-loop-1-benchmark
