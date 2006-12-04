USE: compiler
USE: test
USE: math
USE: kernel
USE: words
USE: kernel
USE: math-internals
USE: memory
IN: temporary

: no-op ;

[ ] [ no-op ] unit-test

: literals 3 5 ;

: tail-call fixnum+ ;

[ 4 ] [ 1 3 tail-call ] unit-test

[ 3 5 ] [ literals ] unit-test

: literals&tail-call 3 5 fixnum+ ;

[ 8 ] [ literals&tail-call ] unit-test

: two-calls dup fixnum* ;

[ 25 ] [ 5 two-calls ] unit-test

: mix-test 3 5 fixnum+ 6 fixnum* ;

[ 48 ] [ mix-test ] unit-test

: indexed-literal-test "hello world" ;

full-gc
full-gc

[ "hello world" ] [ indexed-literal-test ] unit-test

: foo dup [ dup [ ] [ ] if drop ] [ drop ] if ;

[ 10 ] [ 10 2 foo ] unit-test

: foox dup [ foox ] when ; inline
: bar foox ;

: xyz 3 ;

: execute-test execute ; inline
: execute-test-2 \ xyz execute-test ;

\ execute-test-2 compile

[ f ] [ \ execute-test compiled? ] unit-test
[ 3 ] [ execute-test-2 ] unit-test
