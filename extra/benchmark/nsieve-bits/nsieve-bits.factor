USING: math math.parser sequences sequences.private kernel
bit-arrays make io ;
IN: benchmark.nsieve-bits

: clear-flags ( step i seq -- )
    2dup length >= [
        3drop
    ] [
        f 2over set-nth-unsafe [ over + ] dip clear-flags
    ] if ; inline recursive

: (nsieve-bits) ( count i seq -- count )
    2dup length < [
        2dup nth-unsafe [
            over dup 2 * pick clear-flags
            [ 1 + ] 2dip ! increment count
        ] when [ 1 + ] dip (nsieve-bits)
    ] [
        2drop
    ] if ; inline recursive

: nsieve-bits ( m -- count )
    [ 0 2 ] dip 1 + <bit-array> dup set-bits (nsieve-bits) ;

: nsieve-bits. ( m -- )
    [ "Primes up to " % dup # " " % nsieve-bits # ] "" make
    print ; inline

: nsieve-bits-main ( n -- )
    [ 2^ 10000 * nsieve-bits. ]
    [ 1 - 2^ 10000 * nsieve-bits. ]
    [ 2 - 2^ 10000 * nsieve-bits. ]
    tri ;

: nsieve-bits-benchmark ( -- ) 11 nsieve-bits-main ;

MAIN: nsieve-bits-benchmark
