! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel locals math math.bitwise
random sequences ;
IN: random.cmwc

! Multiply-with-carry RNG

TUPLE: cmwc Q a b c i r mod ;

TUPLE: cmwc-seed Q c ;

: <cmwc> ( length a b c -- cmwc )
    cmwc new
        swap >>c
        swap >>b
        swap >>a
        swap [ 1 - >>i ] [ 0 <array> >>Q ] bi
        dup b>> 1 - >>r
        dup Q>> length 1 - >>mod ;

: <cmwc-seed> ( Q c -- cmwc-seed )
    cmwc-seed new
        swap >>c
        swap >>Q ; inline

M: cmwc seed-random
    [ Q>> >>Q ]
    [ Q>> length 1 - >>i ]
    [ c>> >>c ] tri ;

M:: cmwc random-32* ( cmwc -- n )
    cmwc dup mod>> '[ 1 + _ bitand ] change-i
    [ a>> ]
    [ [ i>> ] [ Q>> ] bi nth * ]
    [ c>> + ] tri :> t!

    t -32 shift cmwc (>>c)

    t cmwc [ b>> bitand ] [ c>> + ] bi 64 bits t!
    t cmwc r>> > [
        cmwc [ 1 + ] change-c drop
        t cmwc b>> - 64 bits t!
    ] when

    cmwc [ r>> t - 32 bits dup ] [ i>> ] [ Q>> ] tri set-nth ;

: cmwc-4096 ( -- cmwc )
    4096
    [ 18782 4294967295 362436 <cmwc> ]
    [
        '[ [ random-32 ] replicate ] with-system-random
        362436 <cmwc-seed> seed-random
    ] bi ;
