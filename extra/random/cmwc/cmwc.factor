! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays fry kernel locals math
math.bitwise random sequences sequences.private
specialized-arrays specialized-arrays.instances.uint ;
IN: random.cmwc

! Multiply-with-carry RNG

TUPLE: cmwc
    { Q uint-array }
    { a fixnum }
    { b fixnum }
    { c fixnum }
    { i fixnum }
    { r fixnum }
    { mod fixnum } ;

TUPLE: cmwc-seed { Q uint-array read-only } { c read-only } ;

: <cmwc> ( length a b c -- cmwc )
    cmwc new
        swap >>c
        swap >>b
        swap >>a
        swap [ 1 - >>i ] [ <uint-array> >>Q ] bi
        dup b>> 1 - >>r
        dup Q>> length 1 - >>mod ; inline

: <cmwc-seed> ( Q c -- cmwc-seed )
    cmwc-seed boa ; inline

M: cmwc seed-random
    [ Q>> >>Q ]
    [ Q>> length 1 - >>i ]
    [ c>> >>c ] tri ;

M:: cmwc random-32* ( cmwc -- n )
    cmwc dup mod>> '[ 1 + _ bitand ] change-i
    [ a>> ]
    [ [ i>> ] [ Q>> ] bi nth-unsafe * ]
    [ c>> + ] tri

    [ -32 shift cmwc (>>c) ]

    [ cmwc [ b>> bitand ] [ c>> + ] bi 32 bits ] bi
    dup cmwc r>> > [
        cmwc [ 1 + ] change-c drop
        cmwc b>> - 32 bits
    ] when

    cmwc swap '[ r>> _ - 32 bits dup ] [ i>> ] [ Q>> ] tri set-nth-unsafe ;

: cmwc-4096 ( -- cmwc )
    4096
    [ 18782 4294967295 362436 <cmwc> ]
    [
        '[ [ random-32 ] uint-array{ } replicate-as ] with-system-random
        362436 <cmwc-seed> seed-random
    ] bi ;

: default-cmwc ( -- cmwc ) cmwc-4096 ;
