IN: benchmark.nsieve-bytes
USING: math math.parser sequences sequences.private kernel
byte-arrays make io ;

: clear-flags ( step i seq -- )
    2dup length >= [
        3drop
    ] [
        0 2over set-nth-unsafe [ over + ] dip clear-flags
    ] if ; inline recursive

: (nsieve) ( count i seq -- count )
    2dup length < [
        2dup nth-unsafe 0 > [
            over dup 2 * pick clear-flags
            rot 1 + -rot ! increment count
        ] when [ 1 + ] dip (nsieve)
    ] [
        2drop
    ] if ; inline recursive

: nsieve ( m -- count )
    0 2 rot 1 + <byte-array> [ drop 1 ] map! (nsieve) ;

: nsieve. ( m -- )
    [ "Primes up to " % dup # " " % nsieve # ] "" make print ;

: nsieve-main ( n -- )
    dup 2^ 10000 * nsieve.
    dup 1 - 2^ 10000 * nsieve.
    2 - 2^ 10000 * nsieve. ;

: nsieve-bytes-benchmark ( -- ) 9 nsieve-main ;

MAIN: nsieve-bytes-benchmark
