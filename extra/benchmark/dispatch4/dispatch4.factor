USING: kernel math sequences.private ;
IN: benchmark.dispatch4

: dispatch4 ( n -- val )
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

: dispatch4-benchmark ( -- )
    20000000 [
        20 [
            dispatch4 drop
        ] each-integer
    ] times ;

MAIN: dispatch4-benchmark
