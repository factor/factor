! Copyright (C) 2019 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: math sequences kernel base85 ;
IN: benchmark.base85

: base85-benchmark ( -- )
    65535 <iota> [ 255 bitand ] "" map-as
    20 [ >base85 base85> ] times
    drop ;

MAIN: base85-benchmark
