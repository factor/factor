USING: kernel math sequences namespaces
math.miller-rabin combinators.lib
math.functions accessors random ;
IN: random.blum-blum-shub

! Blum Blum Shub, n = pq, x_i+1 = x_i ^ 2 mod n
! return low bit of x+1
TUPLE: blum-blum-shub x n ;

<PRIVATE

: generate-bbs-primes ( numbits -- p q )
    [ [ random-prime ] curry [ 4 mod 3 = ] generate ] dup bi ;

: <blum-blum-shub> ( numbits -- blum-blum-shub )
    generate-bbs-primes *
    [ find-relative-prime ] keep
    blum-blum-shub boa ;

: next-bbs-bit ( bbs -- bit )
    [ [ x>> 2 ] [ n>> ] bi ^mod ] keep
    over >>x drop 1 bitand ;

PRIVATE>

M: blum-blum-shub random-32* ( bbs -- r )
    0 32 rot
    [ next-bbs-bit swap 1 shift bitor ] curry times ;
