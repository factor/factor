! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel math namespaces sequences
io.backend io.binary combinators system vocabs.loader
summary math.bitwise byte-vectors fry byte-arrays ;
IN: random

SYMBOL: system-random-generator
SYMBOL: secure-random-generator
SYMBOL: random-generator

GENERIC: seed-random ( tuple seed -- )
GENERIC: random-32* ( tuple -- r )
GENERIC: random-bytes* ( n tuple -- byte-array )

<PRIVATE

: adjust-random ( n m -- n' )
    3 mask zero? [ 1+ ] unless ; inline

PRIVATE>

M: object random-bytes* ( n tuple -- byte-array )
    [ [ 4 /i ] keep adjust-random ] dip
    over 4 * <byte-vector>
    [ '[ _ random-32* 4 >le _ push-all ] times ] keep ;

M: object random-32* ( tuple -- r ) 4 random-bytes* le> ;

ERROR: no-random-number-generator ;

M: no-random-number-generator summary
    drop "Random number generator is not defined." ;

M: f random-bytes* ( n obj -- * ) no-random-number-generator ;

M: f random-32* ( obj -- * ) no-random-number-generator ;

: random-bytes ( n -- byte-array )
    [
        dup adjust-random random-generator get random-bytes*
    ] keep head-slice >byte-array ;

<PRIVATE

: random-integer ( n -- n' )
    dup log2 7 + 8 /i 1+
    [ random-bytes byte-array>bignum ]
    [ 3 shift 2^ ] bi / * >integer ;

PRIVATE>

: random-bits ( n -- r ) 2^ random-integer ;

: random ( seq -- elt )
    [ f ] [
        [ length random-integer ] keep nth
    ] if-empty ;

: delete-random ( seq -- elt )
    [ length random-integer ] keep [ nth ] 2keep delete-nth ;

: with-random ( tuple quot -- )
    random-generator swap with-variable ; inline

: with-system-random ( quot -- )
    system-random-generator get swap with-random ; inline

: with-secure-random ( quot -- )
    secure-random-generator get swap with-random ; inline

USE: vocabs.loader

{
    { [ os windows? ] [ "random.windows" require ] }
    { [ os unix? ] [ "random.unix" require ] }
} cond

"random.mersenne-twister" require
