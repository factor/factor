! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: math.extras tools.test ;

IN: math.extras.test

{ -1 } [ -1 7 jacobi ] unit-test
{ 0 } [ 3 3 jacobi ] unit-test
{ -1 } [ 127 703 jacobi ] unit-test
{ 1 } [ -4 197 jacobi ] unit-test
