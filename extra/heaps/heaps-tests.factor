! Copyright 2007 Ryan Murphy
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math tools.test heaps heaps.private ;
IN: temporary

[ <min-heap> pop-heap ] unit-test-fails
[ <max-heap> pop-heap ] unit-test-fails

[ t ] [ <min-heap> heap-empty? ] unit-test
[ f ] [ <min-heap> 1 over push-heap heap-empty? ] unit-test
[ t ] [ <max-heap> heap-empty? ] unit-test
[ f ] [ <max-heap> 1 over push-heap heap-empty? ] unit-test

! Binary Min Heap
{ 1 2 3 4 5 6 } [ 0 left 0 right 1 left 1 right 2 left 2 right ] unit-test
{ t } [ 5 3 T{ min-heap } heap-compare ] unit-test
{ f } [ 5 3 T{ max-heap } heap-compare ] unit-test

[ T{ min-heap T{ heap f V{ -6 -4 2 1 5 3 2 4 3 7 6 8 3 4 4 6 5 5 } } } ]
[ <min-heap> { 3 5 4 6 7 8 2 4 3 5 6 1 3 2 4 5 -6 -4 } over push-heap* ] unit-test

[ T{ min-heap T{ heap f V{ 5 6 6 7 8 } } } ] [
    <min-heap> { 3 5 4 6 5 7 6 8 } over push-heap*
    3 [ dup pop-heap* ] times
] unit-test

[ 2 ] [ <min-heap> 300 over push-heap 200 over push-heap 400 over push-heap 3 over push-heap 2 over push-heap pop-heap ] unit-test

[ 1 ] [ <min-heap> 300 over push-heap 200 over push-heap 400 over push-heap 3 over push-heap 2 over push-heap 1 over push-heap pop-heap ] unit-test

[ 400 ] [ <max-heap> 300 over push-heap 200 over push-heap 400 over push-heap 3 over push-heap 2 over push-heap 1 over push-heap pop-heap ] unit-test
