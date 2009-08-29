USING: tools.test byte-arrays sequences kernel math ;
IN: byte-arrays.tests

[ 6 B{ 1 2 3 } ] [
    6 B{ 1 2 3 } resize-byte-array
    [ length ] [ 3 head ] bi
] unit-test

[ B{ 1 2 } ] [ 2 B{ 1 2 3 4 5 6 7 8 9 } resize-byte-array ] unit-test

[ -10 B{ } resize-byte-array ] must-fail

[ B{ 123 } ] [ 123 1byte-array ] unit-test

[ B{ 123 } ] [ 123 0 B{ 0 } [ set-nth ] keep ] unit-test

[ B{ 123 } ] [ 123 >bignum 0 B{ 0 } [ set-nth ] keep ] unit-test