! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel tools.test sequences ;

IN: math.binpack

{ { { } } } [ { } 1 binpack ] unit-test

{ { { 3 } { 2 1 } } } [ { 1 2 3 } 2 binpack ] unit-test

{ { { 1000 } { 100 60 30 7 } { 70 60 40 23 3 } } }
[ { 100 23 40 60 1000 30 60 07 70 03 } 3 binpack ] unit-test

{
    {
        { "violet" "orange" }
        { "indigo" "green" }
        { "yellow" "blue" "red" }
    }
} [
    { "red" "orange" "yellow" "green" "blue" "indigo" "violet" }
    [ length ] 3 map-binpack
] unit-test
