USING: kernel math sequences namespaces
math.miller-rabin combinators.lib
math.functions accessors random ;
IN: random.blum-blum-shub

! TODO: take (log log M) bits instead of 1 bit
! Blum Blum Shub, M = pq
TUPLE: blum-blum-shub x n ;

C: <blum-blum-shub> blum-blum-shub

: generate-bbs-primes ( numbits -- p q )
    #! two primes congruent to 3 (mod 4)
    [ [ random-prime ] curry [ 4 mod 3 = ] generate ] dup bi ;

IN: crypto
: <blum-blum-shub> ( numbits -- blum-blum-shub )
    #! returns a Blum-Blum-Shub tuple
    generate-bbs-primes *
    [ find-relative-prime ] keep
    blum-blum-shub construct-boa ;

! 256 make-bbs blum-blum-shub set-global

: next-bbs-bit ( bbs -- bit )
    #! x = x^2 mod n, return low bit of calculated x
    [ [ x>> 2 ] [ n>> ] bi ^mod ]
    [ [ >>x ] keep x>> 1 bitand ] bi ;

IN: crypto
! : random ( n -- n )
    ! ! #! Cryptographically secure random number using Blum-Blum-Shub 256
    ! [ log2 1+ random-bits ] keep dupd >= [ -1 shift ] when ;

M: blum-blum-shub random-32* ( bbs -- r )
    ;
