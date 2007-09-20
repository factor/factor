USING: math math.private kernel sequences ;
IN: benchmark.empty-loop

: empty-loop-0 ( n -- )
    dup 0 fixnum< [ drop ] [ 1 fixnum-fast empty-loop-0 ] if ;

: empty-loop-1 ( n -- )
    [ drop ] each-integer ;

: empty-loop-2 ( n -- )
    [ drop ] each ;

: empty-loop-main ( -- )
    5000000 empty-loop-0
    5000000 empty-loop-1
    5000000 empty-loop-2 ;

MAIN: empty-loop-main
