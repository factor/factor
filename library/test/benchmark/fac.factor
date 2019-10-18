IN: scratchpad
USE: math
USE: test
USE: compiler

: fac-benchmark
    10000 fac 10000 [ succ / ] times* ; compiled

[ 1 ] [ fac-benchmark ] unit-test
