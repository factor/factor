! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs
byte-arrays byte-vectors combinators fry io.backend io.binary
kernel locals math math.bitwise math.constants math.functions
math.order math.ranges namespaces sequences sequences.private
sets summary system vocabs hints typed ;
IN: random

SYMBOL: system-random-generator
SYMBOL: secure-random-generator
SYMBOL: random-generator

GENERIC# seed-random 1 ( tuple seed -- tuple' )
GENERIC: random-32* ( tuple -- r )
GENERIC: random-bytes* ( n tuple -- byte-array )

M: object random-bytes* ( n tuple -- byte-array )
    [ [ <byte-vector> ] keep 4 /mod ] dip
    [ pick '[ _ random-32* int <ref> _ push-all ] times ]
    [
        over zero?
        [ 2drop ] [ random-32* int <ref> swap head append! ] if
    ] bi-curry bi* B{ } like ;

HINTS: M\ object random-bytes* { fixnum object } ;

M: object random-32* ( tuple -- r ) 4 swap random-bytes* be> ;

ERROR: no-random-number-generator ;

M: no-random-number-generator summary
    drop "Random number generator is not defined." ;

M: f random-bytes* ( n obj -- * ) no-random-number-generator ;

M: f random-32* ( obj -- * ) no-random-number-generator ;

: random-32 ( -- n ) random-generator get random-32* ;

TYPED: random-bytes ( n: fixnum -- byte-array: byte-array )
    random-generator get random-bytes* ; inline

<PRIVATE

: (random-integer) ( bits -- n required-bits )
    [ random-32 32 ] dip 32 - [ dup 0 > ] [
        [ 32 shift random-32 + ] [ 32 + ] [ 32 - ] tri*
    ] while drop ;

: random-integer ( n -- n' )
    dup next-power-of-2 log2 (random-integer)
    [ * ] [ 2^ /i ] bi* ;

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

: randomize-n-last ( seq n -- seq )
    [ dup length dup ] dip - 1 max '[ dup _ > ]
    [ [ random ] [ 1 - ] bi [ pick exchange-unsafe ] keep ]
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
    4 random-bytes uint deref >float
    4 random-bytes uint deref >float
    2.0 32 ^ * +
    [ over - 2.0 -64 ^ * ] dip
    * + ; inline

: (cos-random-float) ( -- n )
    0. 2. pi * uniform-random-float cos ;

: (log-sqrt-random-float) ( -- n )
    0. 1. uniform-random-float log -2. * sqrt ;

: normal-random-float ( mean sigma -- n )
    (cos-random-float) (log-sqrt-random-float) * * + ;

{
    { [ os windows? ] [ "random.windows" require ] }
    { [ os unix? ] [ "random.unix" require ] }
} cond

"random.mersenne-twister" require
