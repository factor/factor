IN: scratchpad
USE: compiler
USE: math
USE: stack
USE: test
USE: combinators

: fib ( n -- nth fibonacci number )
    dup 1 <= [ drop 1 ] [ pred dup fib swap pred fib + ] ifte ;

[ 9227465 ] [ 34 fib ] unit-test
