! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel math namespaces sequences
io.backend ;
IN: random

HOOK: os-crypto-random-bytes io-backend ( n -- byte-array )
HOOK: os-random-bytes io-backend ( n -- byte-array )
HOOK: os-crypto-random-32 io-backend ( -- r )
HOOK: os-random-32 io-backend ( -- r )

GENERIC: seed-random ( tuple seed -- )
GENERIC: random-32 ( tuple -- r )

: (random-bytes) ( tuple n -- byte-array )
    [ drop random-32 ] with map >c-uint-array ;

DEFER: random

: random-bytes ( n -- r )
    [
        4 /mod zero? [ 1+ ] unless
        \ random get swap (random-bytes)
    ] keep head ;

: random-bits ( n -- r ) 2^ random ;

: random ( seq -- elt )
    dup empty? [
        drop f
    ] [
        [
            length dup log2 7 + 8 /i
            random-bytes byte-array>bignum swap mod
        ] keep nth
    ] if ;

: with-random ( tuple quot -- )
    \ random swap with-variable ; inline
