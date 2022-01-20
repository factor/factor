USING: math.private kernel ;
IN: benchmark.fib1

: fast-fixnum-fib ( m -- n )
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum-fast dup fast-fixnum-fib
        swap 1 fixnum-fast fast-fixnum-fib fixnum+fast
    ] if ;

: fib1-benchmark ( -- ) 34 fast-fixnum-fib 9227465 assert= ;

MAIN: fib1-benchmark
