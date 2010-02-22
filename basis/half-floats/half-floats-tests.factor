USING: accessors alien.c-types alien.syntax half-floats kernel
math tools.test specialized-arrays alien.data classes.struct ;
SPECIALIZED-ARRAY: half
IN: half-floats.tests

[ HEX: 0000 ] [  0.0  half>bits ] unit-test
[ HEX: 8000 ] [ -0.0  half>bits ] unit-test
[ HEX: 3e00 ] [  1.5  half>bits ] unit-test
[ HEX: be00 ] [ -1.5  half>bits ] unit-test
[ HEX: 7c00 ] [  1/0. half>bits ] unit-test
[ HEX: fc00 ] [ -1/0. half>bits ] unit-test
[ HEX: 7eaa ] [ NAN: aaaaaaaaaaaaa half>bits ] unit-test

! too-big floats overflow to infinity
[ HEX: 7c00 ] [   65536.0 half>bits ] unit-test
[ HEX: fc00 ] [  -65536.0 half>bits ] unit-test
[ HEX: 7c00 ] [  131072.0 half>bits ] unit-test
[ HEX: fc00 ] [ -131072.0 half>bits ] unit-test

! too-small floats flush to zero
[ HEX: 0000 ] [  1.0e-9 half>bits ] unit-test
[ HEX: 8000 ] [ -1.0e-9 half>bits ] unit-test

[  0.0  ] [ HEX: 0000 bits>half ] unit-test
[ -0.0  ] [ HEX: 8000 bits>half ] unit-test
[  1.5  ] [ HEX: 3e00 bits>half ] unit-test
[ -1.5  ] [ HEX: be00 bits>half ] unit-test
[  1/0. ] [ HEX: 7c00 bits>half ] unit-test
[ -1/0. ] [ HEX: fc00 bits>half ] unit-test
[  3.0  ] [ HEX: 4200 bits>half ] unit-test
[    t  ] [ HEX: 7e00 bits>half fp-nan? ] unit-test

STRUCT: halves
    { tom half }
    { dick half }
    { harry half }
    { harry-jr half } ;

[ 8 ] [ halves heap-size ] unit-test

[ 3.0 ] [
    halves <struct>
        3.0 >>dick
    dick>>
] unit-test

[ half-array{ 1.0 2.0 3.0 1/0. -1/0. } ]
[ { 1.0 2.0 3.0 1/0. -1/0. } >half-array ] unit-test

