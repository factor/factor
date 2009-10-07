! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel math random random.mersenne-twister ;
IN: benchmark.mt

: mt-benchmark ( n -- )
    >fixnum HEX: 533d <mersenne-twister> '[ _ random-32* drop ] times ;

: mt-main ( -- ) 100000000 mt-benchmark ;

MAIN: mt-main
