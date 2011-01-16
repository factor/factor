! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs
byte-arrays byte-vectors combinators fry io.backend io.binary
kernel locals math math.bitwise math.constants math.functions
math.order math.ranges namespaces sequences sets summary system
vocabs.loader ;
IN: random

SYMBOL: system-random-generator
SYMBOL: secure-random-generator
SYMBOL: random-generator

GENERIC# seed-random 1 ( tuple seed -- tuple' )
GENERIC: random-32* ( tuple -- r )
GENERIC: random-bytes* ( n tuple -- byte-array )

M: object random-bytes* ( n tuple -- byte-array )
    [ [ <byte-vector> ] keep 4 /mod ] dip
    [ pick '[ _ random-32* 4 >le _ push-all ] times ]
    [
        over zero?
        [ 2drop ] [ random-32* 4 >le swap head append! ] if
    ] bi-curry bi* ;

M: object random-32* ( tuple -- r ) 4 swap random-bytes* le> ;

ERROR: no-random-number-generator ;

M: no-random-number-generator summary
    drop "Random number generator is not defined." ;

M: f random-bytes* ( n obj -- * ) no-random-number-generator ;

M: f random-32* ( obj -- * ) no-random-number-generator ;

: random-bytes ( n -- byte-array )
    random-generator get random-bytes* ;

<PRIVATE

: random-integer ( n -- n' )
    dup log2 7 + 8 /i 1 +
    [ random-bytes >byte-array byte-array>bignum ]
    [ 3 shift 2^ ] bi / * >integer ;

PRIVATE>

: random-bits ( numbits -- r ) 2^ random-integer ;

: random-bits* ( numbits -- n )
    1 - [ random-bits ] keep set-bit ;

GENERIC: random ( obj -- elt )

M: integer random [ f ] [ random-integer ] if-zero ;

M: sequence random
    [ f ] [
        [ length random-integer ] keep nth
    ] if-empty ;

: random-32 ( -- n ) random-generator get random-32* ;

: randomize-n-last ( seq n -- seq ) 
    [ dup length dup ] dip - 1 max '[ dup _ > ] 
    [ [ random ] [ 1 - ] bi [ pick exchange ] keep ]
    while drop ;

: randomize ( seq -- randomized )
    dup length randomize-n-last ;

ERROR: too-many-samples seq n ;

: sample ( seq n -- seq' )
    2dup [ length ] dip < [ too-many-samples ] when
    [ [ length iota >array ] dip [ randomize-n-last ] keep tail-slice* ]
    [ drop ] 2bi nths ;

: delete-random ( seq -- elt )
    [ length random-integer ] keep [ nth ] 2keep remove-nth! drop ;

: with-random ( tuple quot -- )
    random-generator swap with-variable ; inline

: with-system-random ( quot -- )
    system-random-generator get swap with-random ; inline

: with-secure-random ( quot -- )
    secure-random-generator get swap with-random ; inline

: uniform-random-float ( min max -- n )
    4 random-bytes underlying>> uint deref >float
    4 random-bytes underlying>> uint deref >float
    2.0 32 ^ * +
    [ over - 2.0 -64 ^ * ] dip
    * + ; inline

: normal-random-float ( mean sigma -- n )
    0.0 1.0 uniform-random-float
    0.0 1.0 uniform-random-float
    [ 2 pi * * cos ]
    [ 1.0 swap - log -2.0 * sqrt ]
    bi* * * + ;

{
    { [ os windows? ] [ "random.windows" require ] }
    { [ os unix? ] [ "random.unix" require ] }
} cond

"random.mersenne-twister" require
