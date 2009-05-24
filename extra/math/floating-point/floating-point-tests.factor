! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test math.floating-point kernel
math.constants fry sequences math ;
IN: math.floating-point.tests

[ t ] [ pi >double< >double pi = ] unit-test
[ t ] [ -1.0 >double< >double -1.0 = ] unit-test

[ t ] [ 1/0. infinity? ] unit-test
[ t ] [ -1/0. infinity? ] unit-test
[ f ] [ 0/0. infinity? ] unit-test
[ f ] [ 10. infinity? ] unit-test
[ f ] [ -10. infinity? ] unit-test
[ f ] [ 0. infinity? ] unit-test
