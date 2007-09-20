USING: tuple-arrays sequences tools.test namespaces kernel math ;

SYMBOL: mat
TUPLE: foo bar ;
C: <foo> foo
[ 2 ] [ 2 T{ foo } <tuple-array> dup mat set length ] unit-test
[ T{ foo } ] [ mat get first ] unit-test
[ T{ foo f 1 } ] [ T{ foo 2 1 } 0 mat get [ set-nth ] keep first ] unit-test
[ t ] [ { T{ foo f 1 } T{ foo f 2 } } >tuple-array dup mat set tuple-array? ] unit-test
[ T{ foo f 3 } t ] 
[ mat get [ foo-bar 2 + <foo> ] map [ first ] keep tuple-array? ] unit-test

[ 2 ] [ 2 T{ foo t } <tuple-array> dup mat set length ] unit-test
[ T{ foo } ] [ mat get first ] unit-test
[ T{ foo 2 1 } ] [ T{ foo 2 1 } 0 mat get [ set-nth ] keep first ] unit-test
