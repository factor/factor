IN: scratchpad
USE: compiler
USE: kernel
USE: math
USE: test

: fib ( n -- nth fibonacci number )
    dup 1 <= [ drop 1 ] [ 1 - dup fib swap 1 - fib + ] ifte ;
    compiled

[ 9227465 ] [ 34 fib ] unit-test
