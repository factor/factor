! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: benchmark.flip

CONSTANT: my-generic { { 1 2 3 } V{ 4 5 6 } "ABC" }
CONSTANT: my-array { { 1 2 3 } { 4 5 6 } { 7 8 9 } }

: flip-benchmark ( -- )
    1,000,000 [ my-generic flip drop ] times
    1,000,000 [ my-array flip drop ] times ;

MAIN: flip-benchmark
