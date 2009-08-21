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
            rot 1 + -rot ! increment count
        ] when [ 1 + ] dip (nsieve-bits)
    ] [
        2drop
    ] if ; inline recursive

: nsieve-bits ( m -- count )
    0 2 rot 1 + <bit-array> dup set-bits (nsieve-bits) ;

: nsieve-bits. ( m -- )
    [ "Primes up to " % dup # " " % nsieve-bits # ] "" make
    print ;

: nsieve-bits-main ( n -- )
    dup 2^ 10000 * nsieve-bits.
    dup 1 - 2^ 10000 * nsieve-bits.
    2 - 2^ 10000 * nsieve-bits. ;

: nsieve-bits-main* ( -- ) 11 nsieve-bits-main ;

MAIN: nsieve-bits-main*
