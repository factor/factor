USING: combinators combinators.lib io locals kernel math
math.functions math.ranges namespaces random sequences
hashtables sets ;
IN: math.miller-rabin

: >even ( n -- int ) dup even? [ 1- ] unless ; foldable
: >odd ( n -- int ) dup even? [ 1+ ] when ; foldable
: next-odd ( m -- n ) dup even? [ 1+ ] [ 2 + ] if ;

TUPLE: positive-even-expected n ;

: (factor-2s) ( r s -- r s )
    dup even? [ -1 shift >r 1+ r> (factor-2s) ] when ;

: factor-2s ( n -- r s )
    #! factor an integer into s * 2^r
    0 swap (factor-2s) ;

:: (miller-rabin) ( n trials -- ? )
    [let | r [ n 1- factor-2s drop ]
           s [ n 1- factor-2s nip ]
           prime?! [ t ]
           a! [ 0 ]
           count! [ 0 ] |
        trials [
            n 1- [1,b] random a!
            a s n ^mod 1 = [
                0 count!
                r [
                    2^ s * a swap n ^mod n - -1 =
                    [ count 1+ count! r + ] when
                ] each
                count zero? [ f prime?! trials + ] when
            ] unless drop
        ] each prime? ] ;

: miller-rabin* ( n numtrials -- ? )
    over {
        { [ dup 1 <= ] [ 3drop f ] }
        { [ dup 2 = ] [ 3drop t ] }
        { [ dup even? ] [ 3drop f ] }
        [ [ drop (miller-rabin) ] with-scope ]
    } cond ;

: miller-rabin ( n -- ? ) 10 miller-rabin* ;

: next-prime ( n -- p )
    next-odd dup miller-rabin [ next-prime ] unless ;

: random-prime ( numbits -- p )
    random-bits next-prime ;

ERROR: no-relative-prime n ;

: (find-relative-prime) ( n guess -- p )
    over 1 <= [ over no-relative-prime ] when
    dup 1 <= [ drop 3 ] when
    2dup gcd nip 1 > [ 2 + (find-relative-prime) ] [ nip ] if ;

: find-relative-prime* ( n guess -- p )
    #! find a prime relative to n with initial guess
    >odd (find-relative-prime) ;

: find-relative-prime ( n -- p )
    dup random find-relative-prime* ;

ERROR: too-few-primes ;

: unique-primes ( numbits n -- seq )
    #! generate two primes
    over 5 < [ too-few-primes ] when
    [ [ drop random-prime ] with map ] [ all-unique? ] generate ;
