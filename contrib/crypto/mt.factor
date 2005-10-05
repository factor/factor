! Copyright (C) 2005 Doug Coleman.
! See http://factor.sf.net/license.txt for BSD license.

! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c
! usage:   1000 [ drop genrand . ] each
! initializes to seed 5489 automatically

IN: crypto
USING: kernel math namespaces sequences arrays ;

: N 624 ; inline
: M 397 ; inline
: A HEX: 9908b0df ; inline
: HI-MASK HEX: 80000000 ; inline
: LO-MASK HEX: 7fffffff ; inline

SYMBOL: mt
SYMBOL: mti

: odd? ( n -- )
    1 bitand 0 > ; inline

: mt-nth ( n -- nth )
    mt get nth ; inline

: formula ( mt mti -- mt[mti] )
    dup rot nth dup -30 shift bitxor 1812433253 * + HEX: ffffffff bitand ; inline

: y ( index -- y )
    dup 1+ mt-nth LO-MASK bitand >r mt-nth HI-MASK bitand r> bitor ; inline
    
: set-mt-ith ( index index1 -- )
    >r dup >r y r> r> mt-nth rot dup odd? A 0 ? swap -1 shift bitxor bitxor swap mt get set-nth ; inline

: temper ( y -- yt )
    dup -11 shift bitxor
    dup 7 shift HEX: 9d2c5680 bitand bitxor
    dup 15 shift HEX: efc60000 bitand bitxor
    dup -18 shift bitxor ; inline

: generate-new-mt
    N M - [ dup 2dup M + set-mt-ith ] repeat
    M 1- [ dup 227 + dup 2dup M N - + set-mt-ith drop ] repeat
    0 mti set ;

: init-random ( seed -- )
    N zero-array swap
    HEX: ffffffff bitand 0 pick set-nth
    N 1- [ 2dup formula 1+ pick pick 1+ swap set-nth ] repeat
    mt set 0 mti set
    generate-new-mt ;

: genrand ( -- rand )
    mti get dup N < [ drop generate-new-mt 0 ] unless
    mt get nth temper mti inc ;

USE: compiler
USE: test

: million-genrand 1000000 [ drop genrand drop ] each ;
: test-genrand \ million-genrand compile [ million-genrand ] time ;

! test-genrand
! 5987 ms run / 56 ms GC time

