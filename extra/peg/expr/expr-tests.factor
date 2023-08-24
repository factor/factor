! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.expr multiline sequences ;
IN: peg.expr.tests

{ 5 } [ "2+3" expr ] unit-test
{ 5 } [ "2+(3)" expr ] unit-test
{ 5 } [ "(2)+3" expr ] unit-test
{ 5 } [ "(2)+(3)" expr ] unit-test

{ 6 } [ "2*3" expr ] unit-test

{ 14 } [ "2+3*4" expr ] unit-test

{ 17 } [ "2+3*4+3" expr ] unit-test

{ 23 } [ "2+3*(4+3)" expr ] unit-test

