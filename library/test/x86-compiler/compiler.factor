IN: scratchpad
USE: compiler
USE: test
USE: math
USE: stack
USE: kernel
USE: combinators
USE: words

"Hi." USE: stdio print

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

: dummy-ifte-1 t [ ] [ ] ifte ; compiled

[ ] [ dummy-ifte-1 ] unit-test

: dummy-ifte-2 f [ ] [ ] ifte ; compiled

[ ] [ dummy-ifte-2 ] unit-test

: dummy-ifte-3 t [ 1 ] [ 2 ] ifte ; compiled

[ 1 ] [ dummy-ifte-3 ] unit-test

: dummy-ifte-4 f [ 1 ] [ 2 ] ifte ; compiled

[ 2 ] [ dummy-ifte-4 ] unit-test

: dummy-ifte-5 0 dup 1 fixnum<= [ drop 1 ] [ ] ifte ; compiled

[ 1 ] [ dummy-ifte-5 ] unit-test

: dummy-ifte-6
    dup 1 <= [
        drop 1
    ] [
        1 fixnum- dup swap 1 fixnum- fixnum+
    ] ifte ;

[ 17 ] [ 10 dummy-ifte-6 ] unit-test

: dead-code-rec
    t [
        #{ 3 2 }
    ] [
        dead-code-rec
    ] ifte ; compiled

[ #{ 3 2 } ] [ dead-code-rec ] unit-test

: one-rec [ f one-rec ] [ "hi" ] ifte ; compiled

[ "hi" ] [ t one-rec ] unit-test

: after-ifte-test
    t [ ] [ ] ifte 5 ; compiled

[ 5 ] [ after-ifte-test ] unit-test

DEFER: countdown-b

: countdown-a ( n -- ) dup 0 eq? [ drop ] [ pred countdown-b ] ifte ;
: countdown-b ( n -- ) dup 0 eq? [ drop ] [ pred countdown-a ] ifte ; compiled

[ ] [ 10 countdown-b ] unit-test
