! Copyright (C) 2005, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c
USING: alien.c-types kernel math namespaces sequences
sequences.private system init accessors math.ranges random
math.bitwise combinators specialized-arrays fry ;
SPECIALIZED-ARRAY: uint
IN: random.mersenne-twister

<PRIVATE

TUPLE: mersenne-twister { seq uint-array } { i fixnum } ;

CONSTANT: n 624
CONSTANT: m 397
CONSTANT: a uint-array{ 0 HEX: 9908b0df }

: y ( n seq -- y )
    [ nth-unsafe 31 mask-bit ]
    [ [ 1 + ] [ nth-unsafe ] bi* 31 bits ] 2bi bitor ; inline

: mt[k] ( offset n seq -- )
    [
        [ [ + ] dip nth-unsafe ]
        [ y [ 2/ ] [ 1 bitand a nth ] bi bitxor ] 2bi
        bitxor
    ] 2keep set-nth-unsafe ; inline

: mt-generate ( mt -- )
    [
        seq>>
        [ [ n m - ] dip '[ [ m ] dip _ mt[k] ] each ]
        [ [ m 1 - ] dip '[ [ m n - ] [ n m - + ] bi* _ mt[k] ] each ]
        bi
    ] [ 0 >>i drop ] bi ; inline

: init-mt-formula ( i seq -- f(seq[i]) )
    dupd nth dup -30 shift bitxor 1812433253 * + 1 + 32 bits ; inline

: init-mt-rest ( seq -- )
    n 1 - swap '[
        _ [ init-mt-formula ] [ [ 1 + ] dip set-nth ] 2bi
    ] each ; inline

: init-mt-seq ( seed -- seq )
    32 bits n <uint-array>
    [ set-first ] [ init-mt-rest ] [ ] tri ; inline

: mt-temper ( y -- yt )
    dup -11 shift bitxor
    dup 7 shift HEX: 9d2c5680 bitand bitxor
    dup 15 shift HEX: efc60000 bitand bitxor
    dup -18 shift bitxor ; inline

: next-index  ( mt -- i )
    dup i>> dup n < [ nip ] [ drop mt-generate 0 ] if ; inline

PRIVATE>

: <mersenne-twister> ( seed -- obj )
    init-mt-seq 0 mersenne-twister boa
    dup mt-generate ;

M: mersenne-twister seed-random ( mt seed -- )
    init-mt-seq >>seq drop ;

M: mersenne-twister random-32* ( mt -- r )
    [ next-index ]
    [ seq>> nth-unsafe mt-temper ]
    [ [ 1 + ] change-i drop ] tri ;

[
    [ 32 random-bits ] with-system-random
    <mersenne-twister> random-generator set-global
] "bootstrap.random" add-init-hook
