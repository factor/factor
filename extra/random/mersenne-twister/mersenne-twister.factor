! Copyright (C) 2005, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c

USING: arrays kernel math namespaces sequences system init
accessors math.ranges combinators.cleave random new-effects ;
IN: random.mersenne-twister

<PRIVATE

TUPLE: mersenne-twister seq i ;

: mt-n 624 ; inline
: mt-m 397 ; inline
: mt-a HEX: 9908b0df ; inline
: mt-hi HEX: 80000000 bitand ; inline
: mt-lo HEX: 7fffffff bitand ; inline
: wrap ( x n -- y ) 2dup >= [ - ] [ drop ] if ; inline
: mt-wrap ( x -- y ) mt-n wrap ; inline

: set-generated ( mt y from-elt to -- )
    >r >r [ 2/ ] [ odd? mt-a 0 ? ] bi
    r> bitxor bitxor r> new-set-nth drop ; inline

: calculate-y ( mt y1 y2 -- y )
    >r over r>
    [ new-nth mt-hi ] [ new-nth mt-lo ] 2bi* bitor ; inline

: (mt-generate) ( mt-seq n -- y to from-elt )
    [ dup 1+ mt-wrap calculate-y ]
    [ mt-m + mt-wrap new-nth ]
    [ nip ] 2tri ;

: mt-generate ( mt -- )
    [ seq>> mt-n [ dupd (mt-generate) set-generated ] with each ]
    [ 0 >>i drop ] bi ;

: init-mt-first ( seed -- seq )
    >r mt-n 0 <array> r>
    HEX: ffffffff bitand 0 new-set-nth ;

: init-mt-formula ( seq i -- f(seq[i]) )
    tuck new-nth dup -30 shift bitxor 1812433253 * +
    1+ HEX: ffffffff bitand ;

: init-mt-rest ( seq -- )
    mt-n 1- [0,b) [
        dupd [ init-mt-formula ] keep 1+ new-set-nth drop
    ] with each ;

: init-mt-seq ( seed -- seq )
    init-mt-first dup init-mt-rest ;

: mt-temper ( y -- yt )
    dup -11 shift bitxor
    dup 7 shift HEX: 9d2c5680 bitand bitxor
    dup 15 shift HEX: efc60000 bitand bitxor
    dup -18 shift bitxor ; inline

PRIVATE>

: <mersenne-twister> ( seed -- obj )
    init-mt-seq 0 mersenne-twister construct-boa
    dup mt-generate ;

M: mersenne-twister seed-random ( mt seed -- )
    init-mt-seq >>seq drop ;

M: mersenne-twister random-32 ( mt -- r )
    dup [ seq>> ] [ i>> ] bi
    dup mt-n < [ drop 0 pick mt-generate ] unless
    new-nth mt-temper
    swap [ 1+ ] change-i drop ;
