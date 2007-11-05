! Copyright 2007 Ryan Murphy
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math tools.test heaps heaps.private ;
IN: temporary

[ <min-heap> heap-pop ] unit-test-fails
[ <max-heap> heap-pop ] unit-test-fails

[ t ] [ <min-heap> heap-empty? ] unit-test
[ f ] [ <min-heap> 1 t pick heap-push heap-empty? ] unit-test
[ t ] [ <max-heap> heap-empty? ] unit-test
[ f ] [ <max-heap> 1 t pick heap-push heap-empty? ] unit-test

! Binary Min Heap
{ 1 2 3 4 5 6 } [ 0 left 0 right 1 left 1 right 2 left 2 right ] unit-test
{ t } [ { 5 t } { 3 t } T{ min-heap } heap-compare ] unit-test
{ f } [ { 5 t } { 3 t } T{ max-heap } heap-compare ] unit-test

[ T{ min-heap T{ heap f V{ { -6 t } { -4 t } { 2 t } { 1 t } { 5 t } { 3 t } { 2 t } { 4 t } { 3 t } { 7 t } { 6 t } { 8 t } { 3 t } { 4 t } { 4 t } { 6 t } { 5 t } { 5 t } } } } ]
[ <min-heap> { { 3 t } { 5 t } { 4 t } { 6 t } { 7 t } { 8 t } { 2 t } { 4 t } { 3 t } { 5 t } { 6 t } { 1 t } { 3 t } { 2 t } { 4 t } { 5 t } { -6 t } { -4 t } } over heap-push-all ] unit-test

[ T{ min-heap T{ heap f V{ { 5 t } { 6 t } { 6 t } { 7 t } { 8 t } } } } ] [
    <min-heap> { { 3 t } { 5 t } { 4 t } { 6 t } { 5 t } { 7 t } { 6 t } { 8 t } } over heap-push-all
    3 [ dup heap-pop* ] times
] unit-test

[ 2 t ] [ <min-heap> 300 t pick heap-push 200 t pick heap-push 400 t pick heap-push 3 t pick heap-push 2 t pick heap-push heap-pop ] unit-test

[ 1 t ] [ <min-heap> 300 300 pick heap-push 200 200 pick heap-push 400 400 pick heap-push 3 3 pick heap-push 2 2 pick heap-push 1 1 pick heap-push heap-pop ] unit-test

[ 400 t ] [ <max-heap> 300 300 pick heap-push 200 200 pick heap-push 400 400 pick heap-push 3 3 pick heap-push 2 2 pick heap-push 1 1 pick heap-push heap-pop ] unit-test

[ 0 ] [ <max-heap> heap-length ] unit-test
[ 1 ] [ <max-heap> 1 1 pick heap-push heap-length ] unit-test
