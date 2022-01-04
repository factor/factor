! Copyright (C) 2022 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays kernel math math.bitwise
random sequences ;
IN: random.pcg-vec

! https://github.com/tkaitchuck/Mwc256XXA64/blob/main/impl/src/gen64.rs
! https://www.pcg-random.org/

! The state is an array of four u64 values in this order: x1, x2, x3, c.
! Since we are only returning 32 bits per step of this 64-bit PRNG, the rest are
! saved in the rem field.
TUPLE: Mwc256XXA64 state rem ;

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
    swap [ update-state ] dip ; inline

! If cache is f, use quot to produce a new pair of values from obj: one to be
! cached, and one to be used. Otherwise return cache as value and cache' = f.
: cache ( obj cache/f quot: ( obj -- n1 n2 ) -- value cache' )
    [ nip f ] swap if* ; inline

PRIVATE>

: <Mwc256XXA64> ( key1 key2 -- obj )
    0xcafef00dd15ea5e5 0x14057B7EF767814F 4array f \ Mwc256XXA64 boa
    6 [ dup next-u64 drop ] times ;

M: Mwc256XXA64 random-32*
    dup [ [ next-u64 d>w/w ] cache ] change-rem drop ;
