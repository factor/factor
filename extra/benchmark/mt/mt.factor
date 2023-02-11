! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math random random.mersenne-twister ;
IN: benchmark.mt

: mt-bench ( n -- )
    >fixnum 0x533d <mersenne-twister> '[ _ random-32* drop ] times ;

: mt-benchmark ( -- ) 10000000 mt-bench ;

MAIN: mt-benchmark
