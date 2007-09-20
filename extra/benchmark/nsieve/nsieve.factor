IN: benchmark.nsieve
USING: math math.parser sequences sequences.private kernel
arrays namespaces io ;

: clear-flags ( step i seq -- )
    2dup length >= [
        3drop
    ] [
        f pick pick set-nth-unsafe >r over + r> clear-flags
    ] if ; inline

: (nsieve) ( count i seq -- count )
    2dup length <= [
        2dup nth-unsafe [
            over dup 2 * pick clear-flags
            rot 1+ -rot ! increment count
        ] when >r 1+ r> (nsieve)
    ] [
        2drop
    ] if ; inline

: nsieve ( m -- count )
    0 2 rot 1+ t <array> (nsieve) ;

: nsieve. ( m -- )
    [ "Primes up to " % dup # " " % nsieve # ] "" make print ;

: nsieve-main ( n -- )
    dup 2^ 10000 * nsieve.
    dup 1 - 2^ 10000 * nsieve.
    2 - 2^ 10000 * nsieve. ;

: nsieve-main* 9 nsieve-main ;

MAIN: nsieve-main*
