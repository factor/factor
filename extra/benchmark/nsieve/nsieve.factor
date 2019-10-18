USING: math math.parser sequences sequences.private kernel
arrays make io ;
IN: benchmark.nsieve

: clear-flags ( step i seq -- )
    2dup length >= [
        3drop
    ] [
        f 2over set-nth-unsafe [ over + ] dip clear-flags
    ] if ; inline recursive

: (nsieve) ( count i seq -- count )
    2dup length < [
        2dup nth-unsafe [
            over dup 2 * pick clear-flags
            [ 1 + ] 2dip ! increment count
        ] when [ 1 + ] dip (nsieve)
    ] [
        2drop
    ] if ; inline recursive

: nsieve ( m -- count )
    [ 0 2 ] dip 1 + t <array> (nsieve) ;

: nsieve. ( m -- )
    [ "Primes up to " % dup # " " % nsieve # ] "" make print ;

: nsieve-main ( n -- )
    [ 2^ 10000 * nsieve. ]
    [ 1 - 2^ 10000 * nsieve. ]
    [ 2 - 2^ 10000 * nsieve. ]
    tri ;

: nsieve-benchmark ( -- ) 9 nsieve-main ;

MAIN: nsieve-benchmark
