USING: math kernel ;
IN: benchmark.fib3

: fib ( m -- n )
    dup 1 <= [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ;

: fib3-benchmark ( -- ) 34 fib 9227465 assert= ;

MAIN: fib3-benchmark
