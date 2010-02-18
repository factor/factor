USING: tuple-arrays sequences tools.test namespaces kernel
math accessors classes.tuple eval ;
IN: tuple-arrays.tests

SYMBOL: mat
TUPLE: foo bar ; final
C: <foo> foo
TUPLE-ARRAY: foo

[ 2 ] [ 2 <foo-array> dup mat set length ] unit-test
[ T{ foo } ] [ mat get first ] unit-test
[ T{ foo f 2 } ] [ T{ foo f 2 } 0 mat get [ set-nth ] keep first ] unit-test
[ t ] [ { T{ foo f 1 } T{ foo f 2 } } >foo-array dup mat set foo-array? ] unit-test
[ T{ foo f 3 } t ] 
[ mat get [ bar>> 2 + <foo> ] map [ first ] keep foo-array? ] unit-test

[ 2 ] [ 2 <foo-array> dup mat set length ] unit-test
[ T{ foo } ] [ mat get first ] unit-test
[ T{ foo f 1 } ] [ T{ foo f 1 } 0 mat get [ set-nth ] keep first ] unit-test

TUPLE: baz { bing integer } bong ; final
TUPLE-ARRAY: baz

[ 0 ] [ 1 <baz-array> first bing>> ] unit-test
[ f ] [ 1 <baz-array> first bong>> ] unit-test

TUPLE: broken x ; final
: broken ( -- ) ;

TUPLE-ARRAY: broken

[ 100 ] [ 100 <broken-array> length ] unit-test

! Can't define a tuple array for a non-tuple class
[ "IN: tuple-arrays.tests USING: tuple-arrays words ; TUPLE-ARRAY: word" eval( -- ) ]
[ error>> not-a-tuple? ]
must-fail-with

! Can't define a tuple array for a non-final class
TUPLE: non-final x ;

[ "IN: tuple-arrays.tests USE: tuple-arrays TUPLE-ARRAY: non-final" eval( -- ) ]
[ error>> not-final? ]
must-fail-with