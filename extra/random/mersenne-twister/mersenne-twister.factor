! Copyright (C) 2005, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! mersenne twister based on 
! http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c

USING: arrays kernel math namespaces sequences system init
accessors math.ranges random ;
IN: random.mersenne-twister

<PRIVATE

: curry2 ( w quot1 quot2 -- quot1 quot2 )
    >r over r> [ curry ] 2bi@ ;

TUPLE: mersenne-twister seq i ;

: mt-n 624 ; inline
: mt-m 397 ; inline
: mt-a HEX: 9908b0df ; inline
: mt-hi HEX: 80000000 bitand ; inline
: mt-lo HEX: 7fffffff bitand ; inline
: wrap ( x n -- y ) 2dup >= [ - ] [ drop ] if ; inline
: mt-wrap ( x -- y ) mt-n wrap ; inline

: set-generated ( y from-elt to seq -- )
    >r >r >r [ 2/ ] [ odd? mt-a 0 ? ] bi
    r> bitxor bitxor r> r> set-nth ; inline

: calculate-y ( y1 y2 mt -- y )
    [ nth mt-hi ] [ nth mt-lo ] curry2 bi* bitor ; inline

: (mt-generate) ( n mt-seq -- y to from-elt )
    [ >r dup 1+ mt-wrap r> calculate-y ]
    [ >r mt-m + mt-wrap r> nth ]
    [ drop ] 2tri ;

: mt-generate ( mt -- )
    [ >r mt-n r> seq>> [ [ (mt-generate) ] keep set-generated ] curry each ]
    [ 0 >>i drop ] bi ;

: init-mt-first ( seed -- seq )
    >r mt-n 0 <array> r>
    HEX: ffffffff bitand 0 pick set-nth ;

: init-mt-formula ( seq i -- f(seq[i]) )
    tuck swap nth dup -30 shift bitxor 1812433253 * +
    1+ HEX: ffffffff bitand ;

: init-mt-rest ( seq -- )
    mt-n 1- [0,b) [
        dupd [ init-mt-formula ] keep 1+ rot set-nth
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

M: mersenne-twister random-32* ( mt -- r )
    dup [ i>> ] [ seq>> ] bi
    over mt-n < [ nip >r dup mt-generate 0 r> ] unless
    nth mt-temper
    swap [ 1+ ] change-i drop ;
