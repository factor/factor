! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math modern.slices shuffle.extras tools.test ;
IN: shuffle.extras.tests

{ 2 3 4 5 6 1 } [ 1 2 3 4 5 6 6roll ] unit-test
{ 2 3 4 5 6 7 1 } [ 1 2 3 4 5 6 7 7roll ] unit-test
{ 2 3 4 5 6 7 8 1 } [ 1 2 3 4 5 6 7 8 8roll ] unit-test

{ 1 2 3 } [ 1 2 [ 3 ] dip-1up ] unit-test
{ 2 2 } [ 1 2 [ 1 + ] dip-1up ] unit-test
{ 20 11 } [ 10 20 [ 1 + ] dip-1up ] unit-test

{ 0 10 20 30 40 50 60 80 71 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ]  dip-1up ] unit-test
{ 0 10 20 30 40 50 70 80 61 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ] 2dip-1up ] unit-test
{ 0 10 20 30 40 60 70 80 51 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ] 3dip-1up ] unit-test


{ 0 10 20 30 40 50 80 61 71 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ]  dip-2up ] unit-test
{ 0 10 20 30 40 70 80 51 61 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ] 2dip-2up ] unit-test
{ 0 10 20 30 60 70 80 41 51 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ] 3dip-2up ] unit-test

{ 0 10 20 60 70 80 31 41 51 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] tri@ ] 3dip-3up ] unit-test

{ 4 "abcd" 97 98 99 100 } [
    0 "abcd"
    [ [ CHAR: a = ] accept1 ]
    [ [ CHAR: b = ] accept1 ]
    [ [ CHAR: c = ] accept1 ]
    [ [ CHAR: d = ] accept1 ] 4craft-1up
] unit-test

: test-keep-under ( -- a b c d e ) 1 [ [ 5 + ] call 10 20 30 ] keep-under ;
: test-2keep-under ( -- a b c d e f g ) 1 2 [ [ 5 + ] bi@ 10 20 30 ] 2keep-under ;
: test-3keep-under ( -- a b c d e f g h i ) 1 2 3 [ [ 5 + ] tri@ 10 20 30 ] 3keep-under ;

{ 1 6 10 20 30 } [ test-keep-under ] unit-test
{ 1 2 6 7 10 20 30 } [ test-2keep-under ] unit-test
{ 1 2 3 6 7 8 10 20 30 } [ test-3keep-under ] unit-test

{ 20 30 2500 } [ 20 30 [ + sq ] 2keep-1up ] unit-test

{ 10 1 } [ 10 [ drop 1 ] keep-1up ] unit-test
{ 10 20 1 } [ 10 20 [ 2drop 1 ] 2keep-1up ] unit-test
{ 10 20 30 1 } [ 10 20 30 [ 3drop 1 ] 3keep-1up ] unit-test


{ 10 1 } [ 10 [ drop 1 ] keep-1up ] unit-test
{ 10 20 1 } [ 10 20 [ 2drop 1 ] 2keep-1up ] unit-test
{ 10 20 30 1 } [ 10 20 30 [ 3drop 1 ] 3keep-1up ] unit-test

{ 10 1 2 } [ 10 [ drop 1 2 ] keep-2up ] unit-test
{ 10 20 1 2 } [ 10 20 [ 2drop 1 2 ] 2keep-2up ] unit-test
{ 10 20 30 1 2 } [ 10 20 30 [ 3drop 1 2 ] 3keep-2up ] unit-test

{ 10 1 2 3 } [ 10 [ drop 1 2 3 ] keep-3up ] unit-test
{ 10 20 1 2 3 } [ 10 20 [ 2drop 1 2 3 ] 2keep-3up ] unit-test
{ 10 20 30 1 2 3 } [ 10 20 30 [ 3drop 1 2 3 ] 3keep-3up ] unit-test
