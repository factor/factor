IN: scratchpad
USE: math
USE: test
USE: compiler
USE: kernel

: small-fac-benchmark
    #! This tests fixnum math.
    1 swap [ 10 fac 10 [ 1 + / ] times* max ] times ; compiled

: big-fac-benchmark
    10000 fac 10000 [ 1 + / ] times* ; compiled

[ 1 ] [ big-fac-benchmark ] unit-test

[ 1 ] [ 1000000 small-fac-benchmark ] unit-test
