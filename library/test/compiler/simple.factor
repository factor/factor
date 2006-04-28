IN: temporary
USE: compiler
USE: test
USE: math
USE: kernel
USE: words
USE: kernel
USE: math-internals
USE: memory

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

full-gc
full-gc

[ "hello world" ] [ indexed-literal-test ] unit-test

: foo dup [ dup [ ] [ ] if drop ] [ drop ] if ; compiled

[ 10 ] [ 10 2 foo ] unit-test

: foox dup [ foox ] when ; inline
: bar foox ;

[ ] [ \ bar compile ] unit-test
