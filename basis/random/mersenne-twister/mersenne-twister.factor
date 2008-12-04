! Copyright (C) 2005, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c
USING: kernel math namespaces sequences sequences.private system
init accessors math.ranges random math.bitwise combinators
specialized-arrays.uint fry ;
IN: random.mersenne-twister

<PRIVATE

TUPLE: mersenne-twister { seq uint-array } { i fixnum } ;

: mt-n 624 ; inline
: mt-m 397 ; inline
: mt-a HEX: 9908b0df ; inline

: mersenne-wrap ( n -- n' )
    dup mt-n > [ mt-n - ] when ; inline

: wrap-nth ( n seq -- obj )
    [ mersenne-wrap ] dip nth-unsafe ; inline

: set-wrap-nth ( obj n seq -- )
    [ mersenne-wrap ] dip set-nth-unsafe ; inline

: calculate-y ( n seq -- y )
    [ wrap-nth 31 mask-bit ]
    [ [ 1+ ] [ wrap-nth ] bi* 31 bits ] 2bi bitor ; inline

: (mt-generate) ( n seq -- next-mt )
    [
        calculate-y
        [ 2/ ] [ odd? mt-a 0 ? ] bi bitxor
    ] [
        [ mt-m + ] [ wrap-nth ] bi*
    ] 2bi bitxor ; inline

: mt-generate ( mt -- )
    [
        mt-n swap seq>> '[
            _ [ (mt-generate) ] [ set-wrap-nth ] 2bi
        ] each
    ] [ 0 >>i drop ] bi ; inline

: init-mt-formula ( i seq -- f(seq[i]) )
    dupd wrap-nth dup -30 shift bitxor 1812433253 * + 1+ 32 bits ; inline

: init-mt-rest ( seq -- )
    mt-n 1- swap '[
        _ [ init-mt-formula ] [ [ 1+ ] dip set-wrap-nth ] 2bi
    ] each ; inline

: init-mt-seq ( seed -- seq )
    32 bits mt-n <uint-array>
    [ set-first ] [ init-mt-rest ] [ ] tri ; inline

: mt-temper ( y -- yt )
    dup -11 shift bitxor
    dup 7 shift HEX: 9d2c5680 bitand bitxor
    dup 15 shift HEX: efc60000 bitand bitxor
    dup -18 shift bitxor ; inline

: next-index  ( mt -- i )
    dup i>> dup mt-n < [ nip ] [ drop mt-generate 0 ] if ; inline

PRIVATE>

: <mersenne-twister> ( seed -- obj )
    init-mt-seq 0 mersenne-twister boa
    dup mt-generate ;

M: mersenne-twister seed-random ( mt seed -- )
    init-mt-seq >>seq drop ;

M: mersenne-twister random-32* ( mt -- r )
    [ next-index ]
    [ seq>> wrap-nth mt-temper ]
    [ [ 1+ ] change-i drop ] tri ;

USE: init

[
    [ 32 random-bits ] with-system-random
    <mersenne-twister> random-generator set-global
] "bootstrap.random" add-init-hook
