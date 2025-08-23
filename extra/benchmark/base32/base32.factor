! Copyright (C) 2019 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: math sequences kernel base32 ;
IN: benchmark.base32

: base32-benchmark ( -- )
    65535 <iota> [ 255 bitand ] "" map-as
    20 [ >base32 base32> ] times
    drop ;

MAIN: base32-benchmark
