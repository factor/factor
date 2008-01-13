USING: combinators combinators.lib io locals kernel math
math.functions math.ranges namespaces random sequences ;
IN: math.miller-rabin

SYMBOL: a
SYMBOL: n
SYMBOL: r
SYMBOL: s
SYMBOL: count
SYMBOL: trials

: >even ( n -- int )
    dup even? [ 1- ] unless ; foldable

: >odd ( n -- int )
    dup even? [ 1+ ] when ; foldable

: next-odd ( m -- n )
    dup even? [ 1+ ] [ 2 + ] if ;

: random-bits ( m -- n ) 2^ random ; foldable

TUPLE: positive-even-expected n ;

: (factor-2s) ( r s -- r s )
    dup even? [ -1 shift >r 1+ r> (factor-2s) ] when ;

: factor-2s ( n -- r s )
    #! factor an even number into s * 2 ^ r
    dup even? over 0 > and [
        positive-even-expected construct-boa throw
    ] unless 0 swap (factor-2s) ;

:: (miller-rabin) | n prime?! |
    n 1- factor-2s s set r set
    trials get [
        n 1- [1,b] random a set
        a get s get n ^mod 1 = [
            0 count set
            r get [
                2^ s get * a get swap n ^mod n - -1 = [
                    count [ 1+ ] change
                    r get +
                ] when
            ] each
            count get zero? [
                f prime?!
                trials get +
            ] when
        ] unless
        drop
    ] each prime? ;

TUPLE: miller-rabin-bounds ;

: miller-rabin* ( n numtrials -- ? )
    over {
        { [ dup 1 <= ] [ 3drop f ] }
        { [ dup 2 = ] [ 3drop t ] }
        { [ dup even? ] [ 3drop f ] }
        { [ t ] [ [ drop trials set t (miller-rabin) ] with-scope ] }
    } cond ;

: miller-rabin ( n -- ? ) 10 miller-rabin* ;

: next-prime ( n -- p )
    next-odd dup miller-rabin [ next-prime ] unless ;

: random-prime ( numbits -- p )
    random-bits next-prime ;

: (find-relative-prime) ( n guess -- p )
    2dup gcd nip 1 > [ 2 + (find-relative-prime) ] [ nip ] if ;

: find-relative-prime* ( n guess -- p )
    #! find a prime relative to n with initial guess
    >odd (find-relative-prime) ;

: find-relative-prime ( n -- p )
    dup random (find-relative-prime*) ;

: unique-primes ( numbits n -- seq )
    #! generate two primes
    over 5 < [ "not enough primes below 5 bits" throw ] when
    [ [ drop random-prime ] with map ] [ all-unique? ] generate ;
