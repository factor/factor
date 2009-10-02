! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel math random random.sfmt ;
IN: benchmark.sfmt

: sfmt-benchmark ( n -- )
    >fixnum HEX: 533d <sfmt-19937> '[ _ random-32* drop ] times ;

: sfmt-main ( -- ) 100000000 sfmt-benchmark ;

MAIN: sfmt-main
