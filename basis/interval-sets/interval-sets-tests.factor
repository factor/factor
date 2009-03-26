! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test interval-sets math grouping sequences accessors
combinators.short-circuit ;
IN: interval-sets.tests

[ f ] [ 0 T{ interval-set } in? ] unit-test
[ f ] [ 2 T{ interval-set } in? ] unit-test

: i1 ( n -- ? )
    { { 3 4 } } <interval-set> ;

[ f ] [ 2 i1 in? ] unit-test
[ t ] [ 3 i1 in? ] unit-test
[ t ] [ 4 i1 in? ] unit-test
[ f ] [ 5 i1 in? ] unit-test

CONSTANT: unicode-max HEX: 10FFFF

: i2 ( n -- ? )
    { { 3 4 } } <interval-set>
    unicode-max <interval-not> ;

[ t ] [ 2 i2 in? ] unit-test
[ f ] [ 3 i2 in? ] unit-test
[ f ] [ 4 i2 in? ] unit-test
[ t ] [ 5 i2 in? ] unit-test

: i3 ( n -- ? )
    { { 2 4 } } <interval-set>
    { { 6 8 } } <interval-set>
    <interval-or> ;

[ f ] [ 1 i3 in? ] unit-test
[ t ] [ 2 i3 in? ] unit-test
[ t ] [ 3 i3 in? ] unit-test
[ t ] [ 4 i3 in? ] unit-test
[ f ] [ 5 i3 in? ] unit-test
[ t ] [ 6 i3 in? ] unit-test
[ t ] [ 7 i3 in? ] unit-test
[ t ] [ 8 i3 in? ] unit-test
[ f ] [ 9 i3 in? ] unit-test

: i4 ( n -- ? )
    { { 2 4 } } <interval-set>
    { { 6 8 } } <interval-set>
    <interval-and> ;

[ f ] [ 1 i4 in? ] unit-test
[ f ] [ 2 i4 in? ] unit-test
[ f ] [ 3 i4 in? ] unit-test
[ f ] [ 4 i4 in? ] unit-test
[ f ] [ 5 i4 in? ] unit-test
[ f ] [ 6 i4 in? ] unit-test
[ f ] [ 7 i4 in? ] unit-test
[ f ] [ 8 i4 in? ] unit-test
[ f ] [ 9 i4 in? ] unit-test

: i5 ( n -- ? )
    { { 2 5 } } <interval-set>
    { { 4 8 } } <interval-set>
    <interval-or> ;

[ f ] [ 1 i5 in? ] unit-test
[ t ] [ 2 i5 in? ] unit-test
[ t ] [ 3 i5 in? ] unit-test
[ t ] [ 4 i5 in? ] unit-test
[ t ] [ 5 i5 in? ] unit-test
[ t ] [ 6 i5 in? ] unit-test
[ t ] [ 7 i5 in? ] unit-test
[ t ] [ 8 i5 in? ] unit-test
[ f ] [ 9 i5 in? ] unit-test

: i6 ( n -- ? )
    { { 2 5 } } <interval-set>
    { { 4 8 } } <interval-set>
    <interval-and> ;

[ f ] [ 1 i6 in? ] unit-test
[ f ] [ 2 i6 in? ] unit-test
[ f ] [ 3 i6 in? ] unit-test
[ t ] [ 4 i6 in? ] unit-test
[ t ] [ 5 i6 in? ] unit-test
[ f ] [ 6 i6 in? ] unit-test
[ f ] [ 7 i6 in? ] unit-test
[ f ] [ 8 i6 in? ] unit-test
[ f ] [ 9 i6 in? ] unit-test

: criterion ( interval-set -- ? )
    array>> {
        [ [ < ] monotonic? ]
        [ length even? ]
    } 1&& ;

[ t ] [ i1 criterion ] unit-test
[ t ] [ i2 criterion ] unit-test
[ t ] [ i3 criterion ] unit-test
[ t ] [ i4 criterion ] unit-test
[ t ] [ i5 criterion ] unit-test
[ t ] [ i6 criterion ] unit-test
