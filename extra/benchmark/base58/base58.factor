! Copyright (C) 2019 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: math sequences kernel base58 ;
IN: benchmark.base58

: base58-benchmark ( -- )
    65535 <iota> [ 255 bitand ] "" map-as
    20 [ >base58 base58> ] times
    drop ;

MAIN: base58-benchmark
