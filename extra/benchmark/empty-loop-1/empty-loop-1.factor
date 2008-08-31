USING: math math.private kernel sequences ;
IN: benchmark.empty-loop-1

: empty-loop-1 ( n -- )
    [ drop ] each-integer ;

: empty-loop-main ( -- )
    50000000 empty-loop-1 ;

MAIN: empty-loop-main
