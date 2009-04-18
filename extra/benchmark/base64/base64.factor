! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math sequences kernel base64 ;
IN: benchmark.base64

: base64-benchmark ( -- )
    65535 [ 255 bitand ] "" map-as
    20 [ >base64 base64> ] times
    drop ;

MAIN: base64-benchmark
