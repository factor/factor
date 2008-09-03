USING: tuple-arrays sequences tools.test namespaces kernel
math accessors ;
IN: tuple-arrays.tests

SYMBOL: mat
TUPLE: foo bar ;
C: <foo> foo
[ 2 ] [ 2 foo <tuple-array> dup mat set length ] unit-test
[ T{ foo } ] [ mat get first ] unit-test
[ T{ foo f 2 } ] [ T{ foo f 2 } 0 mat get [ set-nth ] keep first ] unit-test
[ t ] [ { T{ foo f 1 } T{ foo f 2 } } >tuple-array dup mat set tuple-array? ] unit-test
[ T{ foo f 3 } t ] 
[ mat get [ bar>> 2 + <foo> ] map [ first ] keep tuple-array? ] unit-test

[ 2 ] [ 2 foo <tuple-array> dup mat set length ] unit-test
[ T{ foo } ] [ mat get first ] unit-test
[ T{ foo f 1 } ] [ T{ foo f 1 } 0 mat get [ set-nth ] keep first ] unit-test

TUPLE: baz { bing integer } bong ;
[ 0 ] [ 1 baz <tuple-array> first bing>> ] unit-test
[ f ] [ 1 baz <tuple-array> first bong>> ] unit-test
