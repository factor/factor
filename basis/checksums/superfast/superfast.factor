! Copyright (C) 2013 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data byte-arrays
checksums endian grouping kernel math math.bitwise ranges
sequences sequences.private ;

IN: checksums.superfast

TUPLE: superfast seed ;
C: <superfast> superfast

<PRIVATE

: (main-loop) ( hash n -- hash' )
    [ 16 bits ] [ -16 shift ] bi
    [ + ] [ 11 shift dupd bitxor ] bi*
    [ 16 shift ] [ bitxor ] bi* 32 bits
    [ -11 shift ] [ + ] bi ; inline

: main-loop ( seq hash -- seq hash' )
    over byte-array? alien.data:little-endian? and [
        [ 0 over length 4 - 4 <range> ] dip
        [ pick <displaced-alien> int deref (main-loop) ] reduce
    ] [
        [ dup length 4 mod dupd head-slice* 4 <groups> ] dip
        [ le> (main-loop) ] reduce
    ] if ; inline

: end-case ( seq hash -- hash' )
    swap dup length 4 mod [ tail-slice* ] keep {
        [ drop ]
        [
            first + [ 10 shift ] [ bitxor ] bi 32 bits
            [ -1 shift ] [ + ] bi
        ]
        [
            le> + [ 11 shift ] [ bitxor ] bi 32 bits
            [ -17 shift ] [ + ] bi
        ]
        [
            unclip-last-slice
            [ le> + [ 16 shift ] [ bitxor ] bi ]
            [ 18 shift bitxor ] bi* 32 bits
            [ -11 shift ] [ + ] bi
        ]
    } dispatch ; inline

: avalanche ( hash -- hash' )
    [ 3 shift ] [ bitxor ] bi 32 bits [ -5 shift ] [ + ] bi
    [ 4 shift ] [ bitxor ] bi 32 bits [ -17 shift ] [ + ] bi
    [ 25 shift ] [ bitxor ] bi 32 bits [ -6 shift ] [ + ] bi ; inline

PRIVATE>

M: superfast checksum-bytes
    seed>> 32 bits main-loop end-case avalanche ;
