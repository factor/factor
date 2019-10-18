IN: scratchpad
USE: math
USE: test
USE: compiler

: fac-benchmark
    10000 fac 10000 [ 1 + / ] times* ; compiled

[ 1 ] [ fac-benchmark ] unit-test
