USING: io.binary tools.test classes math ;
IN: io.binary.tests

{ 0x03020100 } [ B{ 0 1 2 3 } le> ] unit-test
{ 0x00010203 } [ B{ 0 1 2 3 } be> ] unit-test

{ 0x332211 } [
    B{ 0x11 0x22 0x33 } le>
] unit-test

{ 0x04030201 } [ B{ 1 2 3 4 } signed-le> ] unit-test
{ 0x01020304 } [ B{ 1 2 3 4 } signed-be> ] unit-test

{ -12 } [ B{ 0xf4 0xff 0xff 0xff } signed-le> ] unit-test
{ -12 } [ B{ 0xff 0xff 0xff 0xf4 } signed-be> ] unit-test

{ 0x7a2c793b2ff08554 } [
    B{ 0x54 0x85 0xf0 0x2f 0x3b 0x79 0x2c 0x7a } le>
] unit-test

{ 0x988a259c3433f237 } [
    B{ 0x37 0xf2 0x33 0x34 0x9c 0x25 0x8a 0x98 } le>
] unit-test

{ B{ 0 0 4 0xd2 } } [ 1234 4 >be ] unit-test
{ B{ 0 0 0 0 0 0 4 0xd2 } } [ 1234 8 >be ] unit-test
{ B{ 0xd2 4 0 0 } } [ 1234 4 >le ] unit-test
{ B{ 0xd2 4 0 0 0 0 0 0 } } [ 1234 8 >le ] unit-test

{ 1234 } [ 1234 4 >be be> ] unit-test
{ 1234 } [ 1234 4 >le le> ] unit-test

{ fixnum } [ B{ 0 0 0 0 0 0 0 0 0 0 } be> class-of ] unit-test

{ 0x56780000 0x12340000 } [ 0x1234000056780000 d>w/w ] unit-test
{ 0x5678 0x1234 } [ 0x12345678 w>h/h ] unit-test
{ 0x34 0x12 } [ 0x1234 h>b/b ] unit-test
