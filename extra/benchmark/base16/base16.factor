! Copyright (C) 2019 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: math sequences kernel base16 ;
IN: benchmark.base16

: base16-benchmark ( -- )
    65535 <iota> [ 255 bitand ] "" map-as
    20 [ >base16 base16> ] times
    drop ;

MAIN: base16-benchmark
