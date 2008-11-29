! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test math.floating-point math.constants kernel ;
IN: math.floating-point.tests

[ t ] [ pi >double< >double pi = ] unit-test
[ t ] [ -1.0 >double< >double -1.0 = ] unit-test
