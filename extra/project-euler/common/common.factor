USING: arrays kernel hashtables math math.functions math.miller-rabin
    math.parser math.ranges namespaces sequences combinators.lib ;
IN: project-euler.common

! A collection of words used by more than one Project Euler solution.

: nth-pair ( n seq -- nth next )
    over 1+ over nth >r nth r> ;

<PRIVATE

: count-shifts ( seq width -- n )
    >r length 1+ r> - ;

: shift-3rd ( seq obj obj -- seq obj obj )
    rot 1 tail -rot ;

: max-children ( seq -- seq )
    [ dup length 1- [ over nth-pair max , ] each ] { } make nip ;

: >multiplicity ( seq -- seq )
    dup prune [
        [ 2dup [ = ] curry count 2array , ] each
    ] { } make nip ; inline

: reduce-2s ( n -- r s )
    dup even? [ factor-2s >r 1+ r> ] [ 1 swap ] if ;

PRIVATE>

: collect-consecutive ( seq width -- seq )
    [
        2dup count-shifts [ 2dup head shift-3rd , ] times
    ] { } make 2nip ;

: divisor? ( n m -- ? )
    mod zero? ;

: max-path ( triangle -- n )
    dup length 1 > [
        2 cut* first2 max-children [ + ] 2map add max-path
    ] [
        first first
    ] if ;

: number>digits ( n -- seq )
    number>string string>digits ;

: perfect-square? ( n -- ? )
    dup sqrt divisor? ;

: prime-factorization ( n -- seq )
    [
        2 [ over 1 > ]
        [ 2dup divisor? [ dup , [ / ] keep ] [ next-prime ] if ]
        [ ] while 2drop
    ] { } make ;

: prime-factorization* ( n -- seq )
    prime-factorization >multiplicity ;

: prime-factors ( n -- seq )
    prime-factorization prune >array ;

! The divisor function, counts the number of divisors
: tau ( n -- n )
    prime-factorization* flip second 1 [ 1+ * ] reduce ;

! Optimized brute-force, is often faster than prime factorization
: tau* ( n -- n )
    reduce-2s [ perfect-square? -1 0 ? ] keep
    dup sqrt >fixnum [1,b] [
        dupd divisor? [ >r 2 + r> ] when
    ] each drop * ;
