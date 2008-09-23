! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math math.functions math.compare tools.test ;

IN: math.compare.tests

[ -1 ] [ -1 5 absmin ] unit-test
[ -1 ] [ -1 -5 absmin ] unit-test

[ -5 ] [ 1 -5 absmax ] unit-test
[ 5 ] [ 1 5 absmax ] unit-test

[ 0 ] [ -1 -3 posmax ] unit-test
[ 1 ] [ 1 -3 posmax ] unit-test
[ 3 ] [ -1 3 posmax ] unit-test

[ 0 ] [ 1 3 negmin ] unit-test
[ -3 ] [ 1 -3 negmin ] unit-test
[ -1 ] [ -1 3 negmin ] unit-test

[ 0 ] [ 0 -1 2 clamp ] unit-test
[ 1 ] [ 0 1 2 clamp ] unit-test
[ 2 ] [ 0 3 2 clamp ] unit-test




