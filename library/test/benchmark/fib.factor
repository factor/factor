IN: scratchpad
USE: compiler
USE: kernel
USE: math
USE: test
USE: math-internals

: fixnum-fib ( n -- nth fibonacci number )
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum- dup fixnum-fib swap 1 fixnum- fixnum-fib fixnum+
    ] ifte ;
    compiled

[ 9227465 ] [ 34 fixnum-fib ] unit-test

: fib ( n -- nth fibonacci number )
    dup 1 <= [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] ifte ;
    compiled

[ 9227465 ] [ 34 fib ] unit-test
