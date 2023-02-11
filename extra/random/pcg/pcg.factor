! Copyright (C) 2022 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct kernel locals math
math.bitwise random sets system ;
IN: random.pcg

! https://www.pcg-random.org/
! https://github.com/tkaitchuck/Mwc256XXA64/blob/main/impl/src/gen32.rs
! https://github.com/tkaitchuck/Mwc256XXA64/blob/main/impl/src/gen64.rs

! Since we are only returning 32 bits per step of this 64-bit PRNG, the rest are
! saved in the rem field.
TUPLE: Mwc256XXA64 x1 x2 x3 c rem ;
TUPLE: Mwc128XXA32 x1 x2 x3 c ;

<PRIVATE

CONSTANT: MULTIPLIER 0xfeb3_4465_7c0a_f413
CONSTANT: MULTIPLIER-32 3487286589

: big>d/d ( n -- low high )
    dup -64 shift [ 64 bits ] bi@ ; inline

: multiply-32 ( n -- low high )
    MULTIPLIER-32 * d>w/w ; inline

: multiply ( n -- low high )
    MULTIPLIER * big>d/d ; inline

: permute-32 ( high x1 x2 x3 -- n )
    [ bitxor ] 2bi@ w+ ; inline

: permute ( high x1 x2 x3 -- n )
    [ bitxor ] 2bi@ W+ ; inline

:: rot-state ( obj x1 c -- struct' )
    obj
        obj x2>> >>x3
        obj x1>> >>x2
        x1 >>x1
        c >>c ; inline

: update-state-32 ( obj low high -- )
    [ over c>> + d>w/w ] dip w+ rot-state drop ; inline

: update-state ( obj low high -- )
    [ over c>> + big>d/d ] dip W+ rot-state drop ; inline

: next-u32 ( obj -- n )
    dup x3>> multiply-32 [ pick [ x1>> ] [ x2>> ] [ x3>> ] tri permute-32 ] keep
    swap [ update-state-32 ] dip ; inline

: next-u64 ( obj -- n )
    dup x3>> multiply [ pick [ x1>> ] [ x2>> ] [ x3>> ] tri permute ] keep
    swap [ update-state ] dip ; inline

PRIVATE>

: <Mwc128XXA32> ( key1 key2 -- obj )
    0xcafef00d 0xd15ea5e5 Mwc128XXA32 boa
    6 [ dup next-u32 drop ] times ;

: <Mwc256XXA64> ( key1 key2 -- obj )
    0xcafef00dd15ea5e5 0x14057B7EF767814F f Mwc256XXA64 boa
    6 [ dup next-u64 drop ] times ;

: <pcg> ( key1 key2 -- obj )
    cpu { x86.32 ppc.32 arm.32 } in? [ <Mwc128XXA32> ] [ <Mwc256XXA64> ] if ;

M: Mwc128XXA32 random-32*
    next-u32 ;

M: Mwc256XXA64 random-32*
    dup '[ [ f ] [ _ next-u64 d>w/w ] if* ] change-rem drop ;

! USING: random random.pcg ;
! gc 0 0 random.pcg:<Mwc256XXA64> [ 10,000,000 [ dup random-32* drop ] times ] time drop
! gc 0 0 random.pcg:<Mwc128XXA32> [ 10,000,000 [ dup random-32* drop ] times ] time drop
