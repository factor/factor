! Copyright (C) 2005 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c

IN: math-internals
USING: arrays kernel math namespaces sequences ;

: mt-n 624 ; inline
: mt-m 397 ; inline
: mt-a HEX: 9908b0df ; inline
: mt-hi HEX: 80000000 ; inline
: mt-lo HEX: 7fffffff ; inline

SYMBOL: mt
SYMBOL: mti

: mt-nth ( n -- nth )
    mt get nth ; inline

: mt-formula ( mt mti -- mt[mti] )
    dup rot nth dup -30 shift bitxor
    1812433253 * + HEX: ffffffff bitand ; inline

: mt-y ( i0 i1 -- y )
    mt-nth mt-lo bitand >r mt-nth mt-hi bitand r> bitor ; inline
    
: set-mt-ith ( yi0 yi1 mt-set mt-get -- )
    >r >r mt-y r> r> mt-nth rot dup odd? mt-a 0 ?
    swap -1 shift bitxor bitxor swap mt get set-nth ; inline

: mt-temper ( y -- yt )
    dup -11 shift bitxor
    dup 7 shift HEX: 9d2c5680 bitand bitxor
    dup 15 shift HEX: efc60000 bitand bitxor
    dup -18 shift bitxor ; inline

: (generate-mt)
    dup 2dup >r 1+ r> dup mt-m ;

: generate-mt
    mt-n mt-m - [ (generate-mt) + set-mt-ith ] repeat
    mt-m 1- [ dup 227 + (generate-mt) mt-n - + set-mt-ith drop ] repeat
    mt-n 1- 0 mt-n 1- mt-m 1- set-mt-ith
    0 mti set ;

IN: math

: init-random ( seed -- )
    #! Initialize the random number generator with a new seed.
    global [
        mt-n 0 <array> swap
        HEX: ffffffff bitand 0 pick set-nth
        mt-n 1- [ 2dup mt-formula 1+ pick pick 1+ swap set-nth ] repeat
        mt set 0 mti set
        generate-mt
    ] bind ;

: (random-int) ( -- rand )
    #! Generate a random integer between 0 and 2^32-1 inclusive.
    global [
        mti get dup mt-n < [ drop generate-mt 0 ] unless
        mt-nth mt-temper mti inc
    ] bind ;

: random-int ( n -- rand )
    #! Generate a random integer between 0 and n-1 inclusive.
    (random-int) * -32 shift ;
