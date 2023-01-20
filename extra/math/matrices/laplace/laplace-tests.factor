! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: math.matrices.laplace tools.test kernel ;

{ -2 } [ { { 1 2 } { 3 4 } } determinant ] unit-test

{ 0 } [
    { { 1 2 3 } { 4 5 6 } { 7 8 9 } } determinant
] unit-test

{ -47860032 } [
    {
        { 40 39 38 37 }
        { 1 1 1 831 }
        { 22 22 1110 299 }
        { 13 14 15 17 }
    } determinant
] unit-test
