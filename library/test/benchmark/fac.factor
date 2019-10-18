IN: scratchpad
USE: math
USE: test
USE: compiler
USE: kernel

: (fac) ( n! i -- n! )
    dup 0 = [
        drop
    ] [
        [ * ] keep 1 - (fac)
    ] ifte ;

: fac ( n -- n! )
    1 swap (fac) ;

: small-fac-benchmark
    #! This tests fixnum math.
    1 swap [ 10 fac 10 [ [ 1 + / ] keep ] repeat max ] times ; compiled

: big-fac-benchmark
    10000 fac 10000 [ [ 1 + / ] keep ] repeat ; compiled

[ 1 ] [ big-fac-benchmark ] unit-test

[ 1 ] [ 1000000 small-fac-benchmark ] unit-test
