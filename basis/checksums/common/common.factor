! Copyright (C) 2006, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.bitwise strings io.binary namespaces
make grouping byte-arrays ;
IN: checksums.common

SYMBOL: bytes-read

: calculate-pad-length ( length -- length' )
    [ 56 < 55 119 ? ] keep - ;

: calculate-pad-length-long ( length -- length' )
    [ 120 < 119 247 ? ] keep - ;

: pad-last-block ( str big-endian? length -- str )
    [
        [ % ] 2dip HEX: 80 ,
        [ HEX: 3f bitand calculate-pad-length <byte-array> % ]
        [ 3 shift 8 rot [ >be ] [ >le ] if % ] bi
    ] B{ } make 64 group ;

: update-old-new ( old new -- )
    [ [ get ] bi@ w+ dup ] 2keep [ set ] bi@ ; inline
