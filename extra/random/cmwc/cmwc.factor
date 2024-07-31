! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data kernel
math math.bitwise random sequences sequences.private
specialized-arrays ;
SPECIALIZED-ARRAY: uint
IN: random.cmwc

! Multiply-with-carry RNG

TUPLE: cmwc
    { Q uint-array }
    { a integer }
    { b integer }
    { c integer }
    { i integer }
    { r integer }
    { mod fixnum } ;

TUPLE: cmwc-seed { Q uint-array read-only } { c read-only } ;

: <cmwc> ( length a b c -- cmwc )
    cmwc new
        swap >>c
        swap >>b
        swap >>a
        swap [ 1 - >>i ] [ uint <c-array> >>Q ] bi
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

    [ >fixnum -32 shift cmwc c<< ]
    [ cmwc [ b>> bitand ] [ c>> w+ ] bi ] bi

    dup cmwc r>> > [
        cmwc [ 1 + ] change-c drop
        cmwc b>> w-
    ] when

    cmwc swap '[ r>> _ w- dup ] [ i>> ] [ Q>> ] tri set-nth-unsafe ;

INSTANCE: cmwc base-random

: cmwc-4096 ( -- cmwc )
    4096
    [ 18782 4294967295 362436 <cmwc> ]
    [
        '[ [ random-32 ] uint-array{ } replicate-as ] with-system-random
        362436 <cmwc-seed> seed-random
    ] bi ;

: default-cmwc ( -- cmwc ) cmwc-4096 ;
