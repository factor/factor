! Copyright (C) 2022 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct kernel locals math
math.bitwise random ;
IN: random.pcg-mwc

! https://github.com/tkaitchuck/Mwc256XXA64/blob/main/impl/src/gen64.rs
! https://www.pcg-random.org/

STRUCT: Mwc256XXA64
    { x1 ulonglong } { x2 ulonglong } { x3 ulonglong } { c ulonglong } ;

<PRIVATE

CONSTANT: MULTIPLIER 0xfeb3_4465_7c0a_f413

: big>d/d ( n -- low high )
    dup -64 shift [ 64 bits ] bi@ ; inline

: multiply ( n -- low high )
    MULTIPLIER * big>d/d ; inline

: permute ( high x1 x2 x3 -- n )
    [ bitxor ] 2bi@ W+ ; inline

:: rot-state ( struct x1 c -- struct' )
    struct
        struct x2>> >>x3
        struct x1>> >>x2
        x1 >>x1
        c >>c ; inline

: update-state ( struct low high -- )
    [ over c>> + big>d/d ] dip W+ rot-state drop ; inline

: next-u64 ( struct -- n )
    dup x3>> multiply [ pick [ x1>> ] [ x2>> ] [ x3>> ] tri permute ] keep
    swap [ update-state ] dip ;

PRIVATE>

: <Mwc256XXA64> ( key1 key2 -- obj )
    0xcafef00dd15ea5e5 0x14057B7EF767814F Mwc256XXA64 <struct-boa>
    6 [ dup next-u64 drop ] times ;

M: Mwc256XXA64 random-32*
    next-u64 32 bits ;

! USING: random random.pcg-mwc random.pcg-mwc-vec ;
! gc 0 0 random.pcg-mwc:<Mwc256XXA64> [ 10,000,000 [ dup random-32* drop ] times ] time drop
! gc 0 0 random.pcg-mwc-vec:<Mwc256XXA64> [ 10,000,000 [ dup random-32* drop ] times ] time drop