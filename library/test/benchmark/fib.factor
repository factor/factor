IN: temporary
USE: compiler
USE: kernel
USE: math
USE: test
USE: math-internals
USE: namespaces

! Four fibonacci implementations, each one slower than the
! previous.

: fixnum-fib ( n -- nth fibonacci number )
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum- dup fixnum-fib swap 1 fixnum- fixnum-fib fixnum+
    ] if ;
    compiled

[ 9227465 ] [ 34 fixnum-fib ] unit-test

: fib ( n -- nth fibonacci number )
    dup 1 <= [ drop 1 ] [ 1- dup fib swap 1- fib + ] if ;
    compiled

[ 9227465 ] [ 34 fib ] unit-test

TUPLE: box i ;

: tuple-fib ( n -- n )
    dup box-i 1 <= [
        drop 1 <box>
    ] [
        box-i 1- <box>
        dup tuple-fib
        swap
        box-i 1- <box>
        tuple-fib
        swap box-i swap box-i + <box>
    ] if ; compiled

[ T{ box f 9227465 } ] [ T{ box f 34 } tuple-fib ] unit-test

SYMBOL: n
: namespace-fib ( n -- n )
    [
        n set
        n get 1 <= [
            1
        ] [
            n get 1 - namespace-fib
            n get 2 - namespace-fib
            +
        ] if
    ] with-scope ; compiled

[ 1346269 ] [ 30 namespace-fib ] unit-test
