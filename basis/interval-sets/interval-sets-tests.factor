! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test interval-sets math grouping sequences accessors
combinators.short-circuit literals ;
IN: interval-sets.tests

{ f } [ 0 T{ interval-set } interval-in? ] unit-test
{ f } [ 2 T{ interval-set } interval-in? ] unit-test

CONSTANT: i1 $[
    { { 3 4 } } <interval-set> ]

{ f } [ 2 i1 interval-in? ] unit-test
{ t } [ 3 i1 interval-in? ] unit-test
{ t } [ 4 i1 interval-in? ] unit-test
{ f } [ 5 i1 interval-in? ] unit-test

CONSTANT: i2 $[
    { { 3 4 } } <interval-set>
    0x10FFFF <interval-not> ] ! unicode-max

{ t } [ 2 i2 interval-in? ] unit-test
{ f } [ 3 i2 interval-in? ] unit-test
{ f } [ 4 i2 interval-in? ] unit-test
{ t } [ 5 i2 interval-in? ] unit-test

CONSTANT: i3 $[
    { { 2 4 } } <interval-set>
    { { 6 8 } } <interval-set>
    <interval-or> ]

{ f } [ 1 i3 interval-in? ] unit-test
{ t } [ 2 i3 interval-in? ] unit-test
{ t } [ 3 i3 interval-in? ] unit-test
{ t } [ 4 i3 interval-in? ] unit-test
{ f } [ 5 i3 interval-in? ] unit-test
{ t } [ 6 i3 interval-in? ] unit-test
{ t } [ 7 i3 interval-in? ] unit-test
{ t } [ 8 i3 interval-in? ] unit-test
{ f } [ 9 i3 interval-in? ] unit-test

CONSTANT: i4 $[
    { { 2 4 } } <interval-set>
    { { 6 8 } } <interval-set>
    <interval-and> ]

{ f } [ 1 i4 interval-in? ] unit-test
{ f } [ 2 i4 interval-in? ] unit-test
{ f } [ 3 i4 interval-in? ] unit-test
{ f } [ 4 i4 interval-in? ] unit-test
{ f } [ 5 i4 interval-in? ] unit-test
{ f } [ 6 i4 interval-in? ] unit-test
{ f } [ 7 i4 interval-in? ] unit-test
{ f } [ 8 i4 interval-in? ] unit-test
{ f } [ 9 i4 interval-in? ] unit-test

CONSTANT: i5 $[
    { { 2 5 } } <interval-set>
    { { 4 8 } } <interval-set>
    <interval-or> ]

{ f } [ 1 i5 interval-in? ] unit-test
{ t } [ 2 i5 interval-in? ] unit-test
{ t } [ 3 i5 interval-in? ] unit-test
{ t } [ 4 i5 interval-in? ] unit-test
{ t } [ 5 i5 interval-in? ] unit-test
{ t } [ 6 i5 interval-in? ] unit-test
{ t } [ 7 i5 interval-in? ] unit-test
{ t } [ 8 i5 interval-in? ] unit-test
{ f } [ 9 i5 interval-in? ] unit-test

CONSTANT: i6 $[
    { { 2 5 } } <interval-set>
    { { 4 8 } } <interval-set>
    <interval-and> ]

{ f } [ 1 i6 interval-in? ] unit-test
{ f } [ 2 i6 interval-in? ] unit-test
{ f } [ 3 i6 interval-in? ] unit-test
{ t } [ 4 i6 interval-in? ] unit-test
{ t } [ 5 i6 interval-in? ] unit-test
{ f } [ 6 i6 interval-in? ] unit-test
{ f } [ 7 i6 interval-in? ] unit-test
{ f } [ 8 i6 interval-in? ] unit-test
{ f } [ 9 i6 interval-in? ] unit-test

: criterion ( interval-set -- ? )
    array>> {
        [ [ < ] monotonic? ]
        [ length even? ]
    } 1&& ;

{ t } [ i1 criterion ] unit-test
{ t } [ i2 criterion ] unit-test
{ t } [ i3 criterion ] unit-test
{ t } [ i4 criterion ] unit-test
{ t } [ i5 criterion ] unit-test
{ t } [ i6 criterion ] unit-test
