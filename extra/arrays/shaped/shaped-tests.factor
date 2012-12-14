! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays.shaped kernel tools.test ;
IN: arrays.shaped.tests

[ t ] [
    { 5 5 } increasing
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array =
] unit-test

[ { 5 5 } ] [
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array shape>>
] unit-test

[ { 5 5 } ] [
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array shape
] unit-test
