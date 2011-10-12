! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test io.binary.fast ;
IN: io.binary.fast.tests

[ HEX: 0102 ] [ B{ 01 02 } 2be> ] unit-test
[ HEX: 01020304 ] [ B{ 01 02 03 04 } 4be> ] unit-test
[ HEX: 0102030405060708 ] [ B{ 01 02 03 04 05 06 07 08 } 8be> ] unit-test

[ HEX: 0102 ] [ B{ 02 01 } 2le> ] unit-test
[ HEX: 01020304 ] [ B{ 04 03 02 01 } 4le> ] unit-test
[ HEX: 0102030405060708 ] [ B{ 08 07 06 05 04 03 02 01 } 8le> ] unit-test

