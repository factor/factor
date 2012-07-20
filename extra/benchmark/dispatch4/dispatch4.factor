USING: kernel.private kernel sequences math combinators
sequences.private ;
IN: benchmark.dispatch4

: foobar-1 ( n -- val )
    dup {
        [ 0 eq? [ 0 ] [ "x" ] if ]
        [ 1 eq? [ 1 ] [ "x" ] if ]
        [ 2 eq? [ 2 ] [ "x" ] if ]
        [ 3 eq? [ 3 ] [ "x" ] if ]
        [ 4 eq? [ 4 ] [ "x" ] if ]
        [ 5 eq? [ 5 ] [ "x" ] if ]
        [ 6 eq? [ 6 ] [ "x" ] if ]
        [ 7 eq? [ 7 ] [ "x" ] if ]
        [ 8 eq? [ 8 ] [ "x" ] if ]
        [ 9 eq? [ 9 ] [ "x" ] if ]
        [ 10 eq? [ 10 ] [ "x" ] if ]
        [ 11 eq? [ 11 ] [ "x" ] if ]
        [ 12 eq? [ 12 ] [ "x" ] if ]
        [ 13 eq? [ 13 ] [ "x" ] if ]
        [ 14 eq? [ 14 ] [ "x" ] if ]
        [ 15 eq? [ 15 ] [ "x" ] if ]
        [ 16 eq? [ 16 ] [ "x" ] if ]
        [ 17 eq? [ 17 ] [ "x" ] if ]
        [ 18 eq? [ 18 ] [ "x" ] if ]
        [ 19 eq? [ 19 ] [ "x" ] if ]
    } dispatch ;

: foobar-2 ( n -- val )
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

: dispatch4-benchmark ( -- )
    20000000 [
        20 [
            foobar-1 drop
        ] each-integer
    ] times ;

: foobar-test-2 ( -- )
    20000000 [
        20 [
            foobar-2 drop
        ] each-integer
    ] times ;

MAIN: dispatch4-benchmark
