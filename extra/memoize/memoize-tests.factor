! Copyright (C) 2007 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel memoize tools.test parser ;

MEMO: fib ( m -- n )
    dup 1 <= [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ;

[ 89 ] [ 10 fib ] unit-test

[ "USE: memoize MEMO: x ( a b c d e -- f g h i j ) >r >r >r >r 1+ r> r> r> r> ;" parse ] unit-test-fails
