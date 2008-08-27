USING: math math.private kernel sequences ;
IN: benchmark.empty-loop-2

: empty-loop-2 ( n -- )
    [ drop ] each ;

: empty-loop-main ( -- )
    5000000 empty-loop-2 ;

MAIN: empty-loop-main
