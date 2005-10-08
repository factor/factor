! Copyright (C) 2005 Doug Coleman.
! See http://factor.sf.net/license.txt for BSD license.

! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c
! usage:   1000 [ drop genrand . ] each
! initializes to seed 5489 automatically

IN: crypto
USING: kernel math namespaces sequences arrays ;

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
    dup rot nth dup -30 shift bitxor 1812433253 * + HEX: ffffffff bitand ; inline

: mt-y ( i0 i1 -- y )
    mt-nth mt-lo bitand >r mt-nth mt-hi bitand r> bitor ; inline
    
: set-mt-ith ( yi0 yi1 mt-set mt-get -- )
    >r >r mt-y r> r> mt-nth rot dup odd? mt-a 0 ? swap -1 shift bitxor bitxor swap mt get set-nth ; inline

: mt-temper ( y -- yt )
    dup -11 shift bitxor
    dup 7 shift HEX: 9d2c5680 bitand bitxor
    dup 15 shift HEX: efc60000 bitand bitxor
    dup -18 shift bitxor ; inline

: generate-new-mt
    mt-n mt-m - [ dup 2dup >r 1+ r> dup mt-m + set-mt-ith ] repeat
    mt-m 1- [ dup 227 + dup 2dup >r 1+ r> dup mt-m mt-n - + set-mt-ith drop ] repeat
    mt-n 1- 0 mt-n 1- mt-m 1- set-mt-ith
    0 mti set ;

: init-random ( seed -- )
    mt-n zero-array swap
    HEX: ffffffff bitand 0 pick set-nth
    mt-n 1- [ 2dup mt-formula 1+ pick pick 1+ swap set-nth ] repeat
    mt set 0 mti set
    generate-new-mt ;

: genrand ( -- rand )
    mti get dup mt-n < [ drop generate-new-mt 0 ] unless
    mt get nth mt-temper mti inc ;

USE: compiler
USE: test

: million-genrand 1000000 [ drop genrand drop ] each ;
: test-genrand \ million-genrand compile [ million-genrand ] time ;

[ 4123659995 ] [ 5489 init-random 9999 [ drop genrand drop ] each genrand millis init-random ] unit-test

! test-genrand
! 5987 ms run / 56 ms GC time

