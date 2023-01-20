! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: fry kernel math random random.sfmt ;
IN: benchmark.sfmt

: sfmt-bench ( n -- )
    >fixnum 0x533d <sfmt-19937> '[ _ random-32* drop ] times ;

: sfmt-benchmark ( -- ) 10000000 sfmt-bench ;

MAIN: sfmt-benchmark
