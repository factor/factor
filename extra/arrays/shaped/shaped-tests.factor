! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays.shaped kernel math sequences tools.test ;

{ t } [
    { 5 5 } increasing
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array =
] unit-test

{ { 5 5 } } [
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array shape>>
] unit-test

{ { 5 5 } } [
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array shape
] unit-test

{ sa{ 1 } } [ { } ones ] unit-test
{ sa{ 1 } } [ { 1 } ones ] unit-test

{ sa{ 0 } } [ { } zeros ] unit-test
{ sa{ 0 } } [ { 1 } zeros ] unit-test

! Error on 0, negative shapes

{
    sa{ { 1 3 3 } { 4 1 3 } { 4 4 1 } }
} [
    { 3 3 } 2 strict-lower
    [ drop 3 ] map-strict-upper
    [ drop 1 ] map-diagonal
    [ sq ] map-strict-lower
] unit-test


[ 15 <iota> { 3 5 1 } reshape ] must-not-fail
