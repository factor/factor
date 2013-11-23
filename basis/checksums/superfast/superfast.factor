! Copyright (C) 2013 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.data byte-arrays checksums
combinators fry grouping io.binary kernel math math.bitwise
math.ranges sequences sequences.private ;
QUALIFIED-WITH: alien.c-types c

IN: checksums.superfast

TUPLE: superfast seed ;
C: <superfast> superfast

<PRIVATE

: 32-bit ( n -- n' ) 32 on-bits mask ; inline

: main-loop ( seq hash -- seq hash' )
    over byte-array? little-endian? and [
        [ 0 over length 4 - 4 <range> ] dip
        [
            pick
            [ <displaced-alien> c:short deref ]
            [ [ 2 + ] dip <displaced-alien> c:short deref ] 2bi
            [ + ] [ 11 shift dupd bitxor ] bi*
            [ 16 shift ] [ bitxor ] bi* 32-bit
            [ -11 shift ] [ + ] bi
        ] reduce
    ] [
        [ dup length 4 mod dupd head-slice* 4 <groups> ] dip [
            2 cut-slice
            [ le> + ] [ le> 11 shift dupd bitxor ] bi*
            [ 16 shift ] [ bitxor ] bi* 32-bit
            [ -11 shift ] [ + ] bi
        ] reduce
    ] if ; inline

: end-case ( seq hash -- hash' )
    swap dup length 4 mod [ tail-slice* ] keep {
        [ drop ]
        [
            first + [ 10 shift ] [ bitxor ] bi 32-bit
            [ -1 shift ] [ + ] bi
        ]
        [
            le> + [ 11 shift ] [ bitxor ] bi 32-bit
            [ -17 shift ] [ + ] bi
        ]
        [
            unclip-last-slice
            [ le> + [ 16 shift ] [ bitxor ] bi ]
            [ 18 shift bitxor ] bi* 32-bit
            [ -11 shift ] [ + ] bi
        ]
    } dispatch ; inline

: avalanche ( hash -- hash' )
    [ 3 shift ] [ bitxor ] bi 32-bit
    [ -5 shift ] [ + ] bi
    [ 4 shift ] [ bitxor ] bi 32-bit
    [ -17 shift ] [ + ] bi
    [ 25 shift ] [ bitxor ] bi 32-bit
    [ -6 shift ] [ + ] bi ; inline

PRIVATE>

M: superfast checksum-bytes
    seed>> 32-bit main-loop end-case avalanche ;
