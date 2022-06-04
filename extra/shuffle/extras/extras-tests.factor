! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math modern.slices shuffle.extras tools.test ;
IN: shuffle.extras.tests

{ 2 3 4 5 6 1 } [ 1 2 3 4 5 6 6roll ] unit-test
{ 2 3 4 5 6 7 1 } [ 1 2 3 4 5 6 7 7roll ] unit-test
{ 2 3 4 5 6 7 8 1 } [ 1 2 3 4 5 6 7 8 8roll ] unit-test

{ 1 2 3 } [ 1 2 [ 3 ] dip1 ] unit-test
{ 2 2 } [ 1 2 [ 1 + ] dip1 ] unit-test
{ 20 11 } [ 10 20 [ 1 + ] dip1 ] unit-test

{ 0 10 20 30 40 50 60 80 71 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ]  dip1 ] unit-test
{ 0 10 20 30 40 50 70 80 61 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ] 2dip1 ] unit-test
{ 0 10 20 30 40 60 70 80 51 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ] 3dip1 ] unit-test


{ 0 10 20 30 40 50 80 61 71 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ]  dip2 ] unit-test
{ 0 10 20 30 40 70 80 51 61 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ] 2dip2 ] unit-test
{ 0 10 20 30 60 70 80 41 51 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ] 3dip2 ] unit-test

{ 0 10 20 60 70 80 31 41 51 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] tri@ ] 3dip3 ] unit-test

{ 4 "abcd" 97 98 99 100 } [
    0 "abcd"
    [ [ CHAR: a = ] accept1 ]
    [ [ CHAR: b = ] accept1 ]
    [ [ CHAR: c = ] accept1 ]
    [ [ CHAR: d = ] accept1 ] 4craft1
] unit-test
