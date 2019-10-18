USING: math kernel hints prettyprint io combinators ;
IN: benchmark.recursive

: fib ( m -- n )
    dup 2 <
    [ drop 1 ]
    [ [ 1 - fib ] [ 2 - fib ] bi + ] if ; inline recursive

: ack ( m n -- x )
    {
        { [ over zero? ] [ nip 1 + ] }
        { [ dup zero? ] [ drop 1 - 1 ack ] }
        [ [ drop 1 - ] [ 1 - ack ] 2bi ack ]
    } cond ; inline recursive

: tak ( x y z -- t )
    2over <= [
        2nip
    ] [
        [  rot 1 - -rot tak ]
        [ -rot 1 - -rot tak ]
        [      1 - -rot tak ]
        3tri
        tak
    ] if ; inline recursive

: recursive ( n -- )
    [ 3 swap ack . flush ]
    [ 27.0 + fib . flush ]
    [ 1 - [ 3 * ] [ 2 * ] [ ] tri tak . flush ] tri
    3 fib . flush
    3.0 2.0 1.0 tak . flush ;

HINTS: recursive fixnum ;

: recursive-benchmark ( -- ) 10 recursive ;

MAIN: recursive-benchmark
