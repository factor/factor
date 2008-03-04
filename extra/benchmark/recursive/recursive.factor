IN: benchmark.recursive
USING: math kernel hints prettyprint io ;

: fib ( m -- n )
    dup 2 < [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ;

: ack ( m n -- x )
    over zero? [
        nip 1+
    ] [
        dup zero? [
            drop 1- 1 ack
        ] [
            dupd 1- ack >r 1- r> ack
        ] if
    ] if ;

: tak ( x y z -- t )
    2over swap < [
        [ rot 1- -rot tak ] 3keep
        [ -rot 1- -rot tak ] 3keep
        1- -rot tak
        tak
    ] [
        2nip
    ] if ;

: recursive ( n -- )
    3 over ack . flush
    dup 27.0 + fib . flush
    1-
    dup 3 * over 2 * rot tak . flush
    3 fib . flush
    3.0 2.0 1.0 tak . flush ;

: recursive-main 11 recursive ;

MAIN: recursive-main
