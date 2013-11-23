! Copyright (C) 2013 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors checksums combinators fry grouping io.binary
kernel math math.bitwise sequences sequences.private ;

IN: checksums.superfast

TUPLE: superfast seed ;
C: <superfast> superfast

<PRIVATE

: 32-bit ( n -- n' ) 32 on-bits mask ; inline

: main-loop ( seq seed -- hash )
    [ 4 <groups> ] dip [
        2 cut-slice
        [ le> + ] [ le> 11 shift dupd bitxor ] bi*
        [ 16 shift ] [ bitxor ] bi* 32-bit
        [ -11 shift ] [ + ] bi
    ] reduce ; inline

: end-case ( hash seq -- hash' )
    dup length {
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
    [ dup length 4 mod cut* ] [ seed>> 32-bit ] bi*
    '[ _ main-loop ] [ end-case ] bi* avalanche ;
