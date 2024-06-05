! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types combinators endian io kernel
math sequences ;
IN: audio.chunked-file

ERROR: invalid-audio-file ;

: ensured-read ( count -- output/f )
    [ read ] keep over length = and* ;
: ensured-read* ( count -- output )
    ensured-read [ invalid-audio-file ] unless* ;

: read-chunk ( -- byte-array/f )
    4 ensured-read [ 4 ensured-read* dup endian> ensured-read* 3append ] [ f ] if* ;

: id= ( chunk id -- ? )
    [ 4 head ] dip sequence= ; inline

: convert-data-endian ( audio -- audio )
    dup sample-bits>> {
        { 16 [ [ 2 seq>native-endianness ] change-data ] }
        { 32 [ [ 4 seq>native-endianness ] change-data ] }
        [ drop ]
    } case ;

: check-chunk ( chunk id class -- ? )
    heap-size [ id= ] [ [ length ] dip >= ] bi-curry* bi and ; inline
