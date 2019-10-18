USING: kernel math errors namespaces math-contrib sequences io ;
IN: crypto-internals

SYMBOL: a
SYMBOL: n
SYMBOL: r
SYMBOL: s
SYMBOL: composite
SYMBOL: count
SYMBOL: trials

: rand[1..n-1] ( m -- n ) 1- random-int 1+ ;

: (factor-2s) ( s n -- s n )
    dup 2 mod 0 = [ -1 shift >r 1+ r> (factor-2s) ] when ;

: factor-2s ( n -- r s )
    #! factor an even number into 2 ^ s * m
    dup dup even? >r 0 > r> and [
        "input must be positive and even" throw
    ] unless 0 swap (factor-2s) ;

: init-miller-rabin ( n trials -- ) 0 composite set trials set n set ;

: (miller-rabin) ( n -- bool )
    n get dup 1 = [ drop f ]
    [
        even? [
            f ] [
            n get 1- factor-2s s set r set
            trials get [
                n get rand[1..n-1] a set
                a get s get n get ^mod 1 = [
                    0 count set
                    r get [
                        2 over ^ s get * a get swap n get ^mod n get - -1 = [
                            count [ 1+ ] change
                            r get +
                        ] when
                    ] repeat
                    count get zero? [
                        composite on
                        trials get +
                    ] when
                ] unless
            ] repeat
            composite get 0 = [ t ] [ composite get not ] if
        ] if
    ] if ;

IN: crypto

: miller-rabin* ( n num-trials -- bool )
    #! Probailistic primality test for n > 2, with num-trials as a parameter
    over 2 > [ "miller-rabin error: must call with n > 2" throw ] unless
    [ init-miller-rabin (miller-rabin) ] with-scope ;

: miller-rabin ( n -- bool )
    #! Probabilistic primality test for n > 2, 100 trials
    [ 100 miller-rabin* ] with-scope ;

: next-miller-rabin-prime ( n -- p )
    #! finds the next prime probabilistically
    dup even? [ 1+ ] [ 2 + ] if
    dup miller-rabin [ next-miller-rabin-prime ] unless ;

! random miller rabin prime from a number, or a number of bits
! expand
: random-miller-rabin-prime ( numbits -- p )
    #! n = bits
    large-random-bits next-miller-rabin-prime ;

: random-miller-rabin-prime==3(mod4) ( numbits -- p )
    dup random-miller-rabin-prime dup 4 mod 3 = [
        drop random-miller-rabin-prime==3(mod4)
    ] [
        nip
    ] if ;

: (find-relative-prime) ( m g -- p )
    2dup gcd nip 1 > [ 2 + (find-relative-prime) ] [ nip ] if ;

: find-relative-prime* ( m g -- p )
    #! find a prime relative to m with initial guess g
    dup even? [ 1+ ] when (find-relative-prime) ;

: find-relative-prime ( m -- p )
    dup random-int dup even? [ 1+ ] when (find-relative-prime) ;

: generate-two-unique-primes ( n -- p q )
    #! generate two primes
    dup 5 < [ "not enough primes below 5 bits" throw ] when
    dup [ random-miller-rabin-prime ] keep random-miller-rabin-prime 2dup =
    [ 2drop generate-two-unique-primes ] [ rot drop ] if ;
