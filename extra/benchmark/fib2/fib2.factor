USING: math.private kernel ;
IN: benchmark.fib2

: fixnum-fib ( m -- n )
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum- dup fixnum-fib swap 1 fixnum- fixnum-fib fixnum+
    ] if ;

: fib2-benchmark ( -- ) 34 fixnum-fib 9227465 assert= ;

MAIN: fib2-benchmark
