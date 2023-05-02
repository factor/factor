! Copyright (C) 2016 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test math math.functions math.functions.integer-logs ;
IN: math.functions.integer-logs.tests

[ -576460752303423489 integer-log10 ] [ positive-number-expected? ] must-fail-with
[ -123124 integer-log10 ] [ positive-number-expected? ] must-fail-with
[ -1/2 integer-log10 ] [ positive-number-expected? ] must-fail-with
[ 0 integer-log10 ] [ positive-number-expected? ] must-fail-with

{ 0 } [ 1 integer-log10 ] unit-test
{ 0 } [ 5 integer-log10 ] unit-test
{ 0 } [ 9 integer-log10 ] unit-test
{ 1 } [ 10 integer-log10 ] unit-test
{ 1 } [ 99 integer-log10 ] unit-test
{ 2 } [ 100 integer-log10 ] unit-test
{ 2 } [ 101 integer-log10 ] unit-test
{ 2 } [ 101 integer-log10 ] unit-test
{ 8 } [ 134217726 integer-log10 ] unit-test
{ 8 } [ 134217727 integer-log10 ] unit-test
{ 8 } [ 134217728 integer-log10 ] unit-test
{ 8 } [ 134217729 integer-log10 ] unit-test
{ 8 } [ 999999999 integer-log10 ] unit-test
{ 9 } [ 1000000000 integer-log10 ] unit-test
{ 9 } [ 1000000001 integer-log10 ] unit-test
{ 17 } [ 576460752303423486 integer-log10 ] unit-test
{ 17 } [ 576460752303423487 integer-log10 ] unit-test
{ 17 } [ 576460752303423488 integer-log10 ] unit-test
{ 17 } [ 576460752303423489 integer-log10 ] unit-test
{ 17 } [ 999999999999999999 integer-log10 ] unit-test
{ 18 } [ 1000000000000000000 integer-log10 ] unit-test
{ 18 } [ 1000000000000000001 integer-log10 ] unit-test
{ 999 } [ 1000 10^ 1 - integer-log10 ] unit-test
{ 1000 } [ 1000 10^ integer-log10 ] unit-test
{ 1000 } [ 1000 10^ 1 + integer-log10 ] unit-test

{ 0 } [ 9+1/2 integer-log10 ] unit-test
{ 1 } [ 10 integer-log10 ] unit-test
{ 1 } [ 10+1/2 integer-log10 ] unit-test
{ 999 } [ 1000 10^ 1/2 - integer-log10 ] unit-test
{ 1000 } [ 1000 10^ integer-log10 ] unit-test
{ 1000 } [ 1000 10^ 1/2 + integer-log10 ] unit-test
{ -1000 } [ 1000 10^ 1/2 - recip integer-log10 ] unit-test
{ -1000 } [ 1000 10^ recip integer-log10 ] unit-test
{ -1001 } [ 1000 10^ 1/2 + recip integer-log10 ] unit-test
{ -1 } [ 8/10 integer-log10 ] unit-test
{ -1 } [ 4/10 integer-log10 ] unit-test
{ -1 } [ 1/10 integer-log10 ] unit-test
{ -2 } [ 1/11 integer-log10 ] unit-test

{ 99 } [ 100 2^ 1/2 - integer-log2 ] unit-test
{ 100 } [ 100 2^ integer-log2 ] unit-test
{ 100 } [ 100 2^ 1/2 + integer-log2 ] unit-test
{ -100 } [ 100 2^ 1/2 - recip integer-log2 ] unit-test
{ -100 } [ 100 2^ recip integer-log2 ] unit-test
{ -101 } [ 100 2^ 1/2 + recip integer-log2 ] unit-test
{ -1 } [ 8/10 integer-log2 ] unit-test
{ -2 } [ 4/10 integer-log2 ] unit-test
{ -3 } [ 2/10 integer-log2 ] unit-test
{ -4 } [ 1/10 integer-log2 ] unit-test
