! Copyright (C) 2022 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays kernel math math.bitwise
random sequences ;
IN: random.pcg-mwc-vec

! https://github.com/tkaitchuck/Mwc256XXA64/blob/main/impl/src/gen64.rs
! https://www.pcg-random.org/

! The state is an array of four u64 values in this order: x1, x2, x3, c.
TUPLE: Mwc256XXA64 state ;

<PRIVATE

CONSTANT: MULTIPLIER 0xfeb3_4465_7c0a_f413

: big>d/d ( n -- low high )
    dup -64 shift [ 64 bits ] bi@ ; inline

: multiply ( n -- low high )
    MULTIPLIER * big>d/d ; inline

: permute ( high x1 x2 x3 -- n )
    [ bitxor ] 2bi@ W+ ; inline

: rot-state ( obj x1 c -- obj' )
    [ over state>> first2 ] dip 4array >>state ; inline

: update-state ( obj low high -- )
    [ over state>> last + big>d/d ] dip W+ rot-state drop ; inline

: next-u64 ( obj -- n )
    dup state>> third multiply [ pick state>> first3 permute ] keep
    swap [ update-state ] dip ;

PRIVATE>

: <Mwc256XXA64> ( key1 key2 -- obj )
    0xcafef00dd15ea5e5 0x14057B7EF767814F 4array \ Mwc256XXA64 boa
    6 [ dup next-u64 drop ] times ; inline

M: Mwc256XXA64 random-32*
    next-u64 32 bits ;
