IN: temporary
USING: compiler kernel math math-internals sequences test ;

: (fac) ( n! i -- n! )
    dup zero? [
        drop
    ] [
        [ * ] keep 1- (fac)
    ] if ;

: fac ( n -- n! )
    1 swap (fac) ;

: small-fac-benchmark
    #! This tests fixnum math.
    1 swap [ 10 fac 10 [ 1+ / ] each max ] times ;

: big-fac-benchmark
    10000 fac 10000 [ 1+ / ] each ;

[ 1 ] [ big-fac-benchmark ] unit-test

[ 1 ] [ 1000000 small-fac-benchmark ] unit-test

[ ] [ 1000000 [ 10 fac drop ] times ] unit-test

: (fast-fixnum-fac) ( n! i -- n! )
    dup zero? [
        drop
    ] [
        [ fixnum*fast ] keep 1 fixnum-fast (fast-fixnum-fac)
    ] if ;

: fast-fixnum-fac ( n -- n! )
    1 swap (fast-fixnum-fac) ;

[ ] [ 1000000 [ 10 fast-fixnum-fac drop ] times ] unit-test

: (fixnum-fac) ( n! i -- n! )
    dup zero? [
        drop
    ] [
        [ fixnum* ] keep 1 fixnum- (fixnum-fac)
    ] if ;

: fixnum-fac ( n -- n! )
    1 swap (fixnum-fac) ;

[ ] [ 1000000 [ 10 fixnum-fac drop ] times ] unit-test
