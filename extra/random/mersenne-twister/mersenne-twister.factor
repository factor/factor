! Copyright (C) 2005, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c
USING: arrays kernel math namespaces sequences system init
accessors math.ranges random circular math.bitfields.lib
combinators ;
IN: random.mersenne-twister

<PRIVATE

TUPLE: mersenne-twister seq i ;

: mt-n 624 ; inline
: mt-m 397 ; inline
: mt-a HEX: 9908b0df ; inline

: calculate-y ( n seq -- y )
    [ nth 32 mask-bit ]
    [ [ 1+ ] [ nth ] bi* 31 bits ] 2bi bitor ; inline

: (mt-generate) ( n seq -- next-mt )
    [
        calculate-y
        [ 2/ ] [ odd? mt-a 0 ? ] bi bitxor
    ] [
        [ mt-m + ] [ nth ] bi*
    ] 2bi bitxor ;

: mt-generate ( mt -- )
    [
        mt-n swap seq>> [
            [ (mt-generate) ] [ set-nth ] 2bi
        ] curry each
    ] [ 0 >>i drop ] bi ;

: init-mt-formula ( i seq -- f(seq[i]) )
    dupd nth dup -30 shift bitxor 1812433253 * + 1+ 32 bits ;

: init-mt-rest ( seq -- )
    mt-n 1- swap [
        [ init-mt-formula ] [ >r 1+ r> set-nth ] 2bi
    ] curry each ;

: init-mt-seq ( seed -- seq )
    32 bits mt-n 0 <array> <circular>
    [ set-first ] [ init-mt-rest ] [ ] tri ;

: mt-temper ( y -- yt )
    dup -11 shift bitxor
    dup 7 shift HEX: 9d2c5680 bitand bitxor
    dup 15 shift HEX: efc60000 bitand bitxor
    dup -18 shift bitxor ; inline

: next-index  ( mt -- i )
    dup i>> dup mt-n < [ nip ] [ drop mt-generate 0 ] if ;

PRIVATE>

: <mersenne-twister> ( seed -- obj )
    init-mt-seq 0 mersenne-twister boa
    dup mt-generate ;

M: mersenne-twister seed-random ( mt seed -- )
    init-mt-seq >>seq drop ;

M: mersenne-twister random-32* ( mt -- r )
    [ next-index ]
    [ seq>> nth mt-temper ]
    [ [ 1+ ] change-i drop ] tri ;
