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

[ t 2 ] [ <min-heap> t 300 pick heap-push t 200 pick heap-push t 400 pick heap-push t 3 pick heap-push t 2 pick heap-push heap-pop ] unit-test

[ t 1 ] [ <min-heap> t 300 pick heap-push t 200 pick heap-push t 400 pick heap-push t 3 pick heap-push t 2 pick heap-push t 1 pick heap-push heap-pop ] unit-test

[ t 400 ] [ <max-heap> t 300 pick heap-push t 200 pick heap-push t 400 pick heap-push t 3 pick heap-push t 2 pick heap-push t 1 pick heap-push heap-pop ] unit-test

[ 0 ] [ <max-heap> heap-length ] unit-test
[ 1 ] [ <max-heap> t 1 pick heap-push heap-length ] unit-test
