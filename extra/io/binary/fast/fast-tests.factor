! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test io.binary.fast ;

{ 0x0102 } [ B{ 01 02 } 2be> ] unit-test
{ 0x01020304 } [ B{ 01 02 03 04 } 4be> ] unit-test
{ 0x0102030405060708 } [ B{ 01 02 03 04 05 06 07 08 } 8be> ] unit-test

{ 0x0102 } [ B{ 02 01 } 2le> ] unit-test
{ 0x01020304 } [ B{ 04 03 02 01 } 4le> ] unit-test
{ 0x0102030405060708 } [ B{ 08 07 06 05 04 03 02 01 } 8le> ] unit-test

{ 0x04030201 } [ B{ 1 2 3 4 } signed-le> ] unit-test
{ 0x01020304 } [ B{ 1 2 3 4 } signed-be> ] unit-test

{ -12 } [ B{ 0xf4 0xff 0xff 0xff } signed-le> ] unit-test
{ -12 } [ B{ 0xff 0xff 0xff 0xf4 } signed-be> ] unit-test
