IN: scratchpad
USE: compiler
USE: test
USE: math
USE: kernel
USE: words
USE: kernel
USE: math-internals

: no-op ; compiled

[ ] [ no-op ] unit-test

: literals 3 5 ; compiled

: tail-call fixnum+ ; compiled

[ 4 ] [ 1 3 tail-call ] unit-test

[ 3 5 ] [ literals ] unit-test

: literals&tail-call 3 5 fixnum+ ; compiled

[ 8 ] [ literals&tail-call ] unit-test

: two-calls dup fixnum* ; compiled

[ 25 ] [ 5 two-calls ] unit-test

: mix-test 3 5 fixnum+ 6 fixnum* ; compiled

[ 48 ] [ mix-test ] unit-test

: indexed-literal-test "hello world" ; compiled

garbage-collection
garbage-collection

[ "hello world" ] [ indexed-literal-test ] unit-test
