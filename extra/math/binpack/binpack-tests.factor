! Copyright (C) 2008 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: kernel math.binpack sequences tools.test ;

{ { V{ } } } [ { } 1 binpack ] unit-test

{ { V{ 3 } V{ 2 1 } } } [ { 1 2 3 } 2 binpack ] unit-test

{ { V{ 1000 } V{ 100 60 30 7 } V{ 70 60 40 23 3 } } }
[ { 100 23 40 60 1000 30 60 07 70 03 } 3 binpack ] unit-test

{
    {
        V{ "violet" "orange" }
        V{ "indigo" "green" }
        V{ "yellow" "blue" "red" }
    }
} [
    { "red" "orange" "yellow" "green" "blue" "indigo" "violet" }
    [ length ] 3 map-binpack
] unit-test
