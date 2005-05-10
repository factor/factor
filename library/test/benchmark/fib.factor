IN: temporary
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

TUPLE: box i ;

: tuple-fib ( n -- n )
    dup box-i 1 <= [
        drop 1 <box>
    ] [
        box-i 1 - <box>
        dup tuple-fib
        swap
        box-i 1 - <box>
        tuple-fib
        swap box-i swap box-i + <box>
    ] ifte ; compiled

[ << box f 9227465 >> ] [ << box f 34 >> tuple-fib ] unit-test
