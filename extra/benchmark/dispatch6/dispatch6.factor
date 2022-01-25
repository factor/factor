USING: kernel math combinators ;
IN: benchmark.dispatch6

: dispatch6 ( n -- val )
    {
        { [ dup 0 eq? ] [ drop 0 ] }
        { [ dup 1 eq? ] [ drop 1 ] }
        { [ dup 2 eq? ] [ drop 2 ] }
        { [ dup 3 eq? ] [ drop 3 ] }
        { [ dup 4 eq? ] [ drop 4 ] }
        { [ dup 5 eq? ] [ drop 5 ] }
        { [ dup 6 eq? ] [ drop 6 ] }
        { [ dup 7 eq? ] [ drop 7 ] }
        { [ dup 8 eq? ] [ drop 8 ] }
        { [ dup 9 eq? ] [ drop 9 ] }
        { [ dup 10 eq? ] [ drop 10 ] }
        { [ dup 11 eq? ] [ drop 11 ] }
        { [ dup 12 eq? ] [ drop 12 ] }
        { [ dup 13 eq? ] [ drop 13 ] }
        { [ dup 14 eq? ] [ drop 14 ] }
        { [ dup 15 eq? ] [ drop 15 ] }
        { [ dup 16 eq? ] [ drop 16 ] }
        { [ dup 17 eq? ] [ drop 17 ] }
        { [ dup 18 eq? ] [ drop 18 ] }
        { [ dup 19 eq? ] [ drop 19 ] }
    } cond ;

: dispatch6-benchmark ( -- )
    20000000 [
        20 [
            dispatch6 drop
        ] each-integer
    ] times ;

MAIN: dispatch6-benchmark
