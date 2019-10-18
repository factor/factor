IN: temporary
USE: compiler
USE: kernel
USE: math
USE: test
USE: math-internals
USE: namespaces
USE: words

! Five fibonacci implementations, each one slower than the
! previous.

: fast-fixnum-fib ( m -- n )
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum-fast dup fast-fixnum-fib
        swap 1 fixnum-fast fast-fixnum-fib fixnum+fast
    ] if ;

[ 9227465 ] [ 34 fast-fixnum-fib ] unit-test

: fixnum-fib ( m -- n )
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum- dup fixnum-fib swap 1 fixnum- fixnum-fib fixnum+
    ] if ;

[ 9227465 ] [ 34 fixnum-fib ] unit-test

: fib ( m -- n )
    dup 1 <= [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ;

[ 9227465 ] [ 34 fib ] unit-test

TUPLE: box i ;

: tuple-fib ( m -- n )
    dup box-i 1 <= [
        drop 1 <box>
    ] [
        box-i 1- <box>
        dup tuple-fib
        swap
        box-i 1- <box>
        tuple-fib
        swap box-i swap box-i + <box>
    ] if ;

[ T{ box f 9227465 } ] [ T{ box f 34 } tuple-fib ] unit-test

SYMBOL: n
: namespace-fib ( m -- n )
    [
        n set
        n get 1 <= [
            1
        ] [
            n get 1 - namespace-fib
            n get 2 - namespace-fib
            +
        ] if
    ] with-scope ;

[ 1346269 ] [ 30 namespace-fib ] unit-test
