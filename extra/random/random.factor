! Copyright (C) 2005, 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c

USING: arrays kernel math math.functions namespaces sequences
system init alien.c-types ;
IN: random

<PRIVATE

TUPLE: mersenne-twister seed seq i ;

C: <mersenne-twister> mersenne-twister

: mt-n 624 ; inline
: mt-m 397 ; inline
: mt-a HEX: 9908b0df ; inline
: mt-hi HEX: 80000000 ; inline
: mt-lo HEX: 7fffffff ; inline

SYMBOL: mt

: mt-seq ( -- seq )
    mt get mersenne-twister-seq ; inline

: mt-nth ( n -- nth )
    mt-seq nth ; inline

: mt-i ( -- i )
    mt get mersenne-twister-i ; inline

: mti-inc ( -- )
    mt get [ mersenne-twister-i 1+ ] keep set-mersenne-twister-i ; inline

: set-mt-ith ( y i-get i-set -- )
    >r mt-nth >r
    [ -1 shift ] keep odd? mt-a 0 ? r> bitxor bitxor r>
    mt-seq set-nth ; inline

: mt-y ( y1 y2 -- y )
    mt-nth mt-lo bitand
    >r mt-nth mt-hi bitand r> bitor ; inline

: mod* ( x n -- y )
    #! no floating point
    2dup >= [ - ] [ drop ] if ; inline

: (mt-generate) ( n -- y n n+(mt-m) )
    dup [ 1+ 624 mod* mt-y ] keep [ mt-m + 624 mod* ] keep ;

: mt-generate ( -- )
    mt-n [ (mt-generate) set-mt-ith ] each
    0 mt get set-mersenne-twister-i ;

: init-mt-first ( seed -- seq )
    >r mt-n 0 <array> r>
    HEX: ffffffff bitand 0 pick set-nth ;

: init-mt-formula ( seq i -- f(seq[i]) )
    dup rot nth dup -30 shift bitxor
    1812433253 * + HEX: ffffffff bitand 1+ ; inline

: init-mt-rest ( seq -- )
    mt-n 1 head* [
        [ init-mt-formula ] 2keep 1+ swap set-nth
    ] curry* each ;

: mt-temper ( y -- yt )
    dup -11 shift bitxor
    dup 7 shift HEX: 9d2c5680 bitand bitxor
    dup 15 shift HEX: efc60000 bitand bitxor
    dup -18 shift bitxor ; inline

PRIVATE>

: init-random ( seed -- )
    global [
         dup init-mt-first
         [ init-mt-rest ] keep
         0 <mersenne-twister> mt set
         mt-generate
    ] bind ;

: (random) ( -- rand )
    global [
        mt-i dup mt-n < [ drop mt-generate 0 ] unless
        mt-nth mti-inc
        mt-temper
    ] bind ;

: big-random ( n -- r )
    [ drop (random) ] map >c-uint-array byte-array>bignum ;

: random ( seq -- elt )
    dup empty? [
        drop f
    ] [
        [
            length dup log2 31 + 32 /i big-random swap mod
        ] keep nth
    ] if ;

[ millis init-random ] "random" add-init-hook
