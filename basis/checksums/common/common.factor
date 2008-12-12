! Copyright (C) 2006, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.bitwise strings io.binary namespaces
make grouping ;
IN: checksums.common

SYMBOL: bytes-read

: calculate-pad-length ( length -- pad-length )
    dup 56 < 55 119 ? swap - ;

: pad-last-block ( str big-endian? length -- str )
    [
        rot %
        HEX: 80 ,
        dup HEX: 3f bitand calculate-pad-length 0 <string> %
        3 shift 8 rot [ >be ] [ >le ] if %
    ] "" make 64 group ;

: update-old-new ( old new -- )
    [ [ get ] bi@ w+ dup ] 2keep [ set ] bi@ ; inline
