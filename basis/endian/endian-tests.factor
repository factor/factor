! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: classes endian endian.private kernel math namespaces tools.test ;

{ t } [ [ endianness get big-endian = ] with-big-endian ] unit-test
{ t } [ [ endianness get little-endian = ] with-little-endian ] unit-test

{ 0x0102 } [ B{ 01 02 } be> ] unit-test
{ 0x01020304 } [ B{ 01 02 03 04 } be> ] unit-test
{ 0x0102030405060708 } [ B{ 01 02 03 04 05 06 07 08 } be> ] unit-test

{ 0x0102 } [ B{ 02 01 } le> ] unit-test
{ 0x01020304 } [ B{ 04 03 02 01 } le> ] unit-test
{ 0x0102030405060708 } [ B{ 08 07 06 05 04 03 02 01 } le> ] unit-test

{ 0x7a2c793b2ff08554 } [
    B{ 0x54 0x85 0xf0 0x2f 0x3b 0x79 0x2c 0x7a } le>
] unit-test

{ 0x988a259c3433f237 } [
    B{ 0x37 0xf2 0x33 0x34 0x9c 0x25 0x8a 0x98 } le>
] unit-test

{ 0x03020100 } [ B{ 0 1 2 3 } le> ] unit-test
{ 0x00010203 } [ B{ 0 1 2 3 } be> ] unit-test

{ 0x332211 } [
    B{ 0x11 0x22 0x33 } le>
] unit-test

{ 0x04030201 } [ B{ 1 2 3 4 } signed-le> ] unit-test
{ 0x01020304 } [ B{ 1 2 3 4 } signed-be> ] unit-test

{ -12 } [ B{ 0xf4 0xff 0xff 0xff } signed-le> ] unit-test
{ -12 } [ B{ 0xff 0xff 0xff 0xf4 } signed-be> ] unit-test

{ B{ 0 0 4 0xd2 } } [ 1234 4 >be ] unit-test
{ B{ 0 0 0 0 0 0 4 0xd2 } } [ 1234 8 >be ] unit-test
{ B{ 0xd2 4 0 0 } } [ 1234 4 >le ] unit-test
{ B{ 0xd2 4 0 0 0 0 0 0 } } [ 1234 8 >le ] unit-test

{ 1234 } [ 1234 4 >be be> ] unit-test
{ 1234 } [ 1234 4 >le le> ] unit-test

{ fixnum } [ B{ 0 0 0 0 0 0 0 0 0 0 } be> class-of ] unit-test

