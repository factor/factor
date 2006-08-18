USING: kernel math sequences namespaces crypto math-contrib ;
IN: crypto-internals

! TODO: take (log log M) bits instead of 1 bit
! Blum Blum Shub, M = pq
TUPLE: bbs x n ;

: generate-bbs-primes ( numbits -- p q )
    #! two primes congruent to 3 (mod 4)
    dup [ random-miller-rabin-prime==3(mod4) ] 2apply ;

IN: crypto
: make-bbs ( numbits -- blum-blum-shub )
    #! returns a Blum-Blum-Shub tuple
    generate-bbs-primes * [ find-relative-prime ] keep <bbs> ;

IN: crypto-internals
SYMBOL: blum-blum-shub 256 make-bbs blum-blum-shub set-global

: next-bbs-bit ( bbs -- bit )
    #! x = x^2 mod n, return low bit of calculated x
    [ [ bbs-x ] keep 2 swap bbs-n ^mod ] keep
    [ set-bbs-x ] keep bbs-x 1 bitand ;

SYMBOL: temp-bbs
: (bbs-bits) ( numbits bbs -- n )
    temp-bbs set [ [ temp-bbs get next-bbs-bit ] swap make-bits ] with-scope ;

IN: crypto
: random-bbs-bits* ( numbits bbs -- n ) (bbs-bits) ;
: random-bits ( numbits -- n ) blum-blum-shub get (bbs-bits) ;
: random-bytes ( numbits -- n ) 8 * random-bits ;
: random-int ( n -- n )
    ! #! Cryptographically secure random number using Blum-Blum-Shub 256
    [ log2 1+ random-bits ] keep dupd >= [ -1 shift ] when ;

