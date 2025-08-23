! Copyright (C) 2019 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: math sequences kernel base91 ;
IN: benchmark.base91

: base91-benchmark ( -- )
    65535 <iota> [ 255 bitand ] "" map-as
    20 [ >base91 base91> ] times
    drop ;

MAIN: base91-benchmark
