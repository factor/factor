! Copyright (C) 2010 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license

USING: kernel math math.approx math.constants
math.floating-point sequences tools.test ;

{ { 3 3 13/4 16/5 19/6 22/7 } }
[
    pi double>ratio
    { 1/2 1/4 1/8 1/16 1/32 1/64 }
    [ approximate ] with map
] unit-test

{ { -3 -3 -13/4 -16/5 -19/6 -22/7 } }
[
    pi double>ratio neg
    { 1/2 1/4 1/8 1/16 1/32 1/64 }
    [ approximate ] with map
] unit-test
