USING: accessors alien.c-types alien.syntax math.floats.half kernel
math tools.test specialized-arrays alien.data classes.struct ;
SPECIALIZED-ARRAY: half
IN: math.floats.half.tests

{ 0x0000 } [  0.0  half>bits ] unit-test
{ 0x8000 } [ -0.0  half>bits ] unit-test
{ 0x3e00 } [  1.5  half>bits ] unit-test
{ 0xbe00 } [ -1.5  half>bits ] unit-test
{ 0x7c00 } [  1/0. half>bits ] unit-test
{ 0xfc00 } [ -1/0. half>bits ] unit-test
{ 0x7eaa } [ NAN: aaaaaaaaaaaaa half>bits ] unit-test

! too-big floats overflow to infinity
{ 0x7c00 } [   65536.0 half>bits ] unit-test
{ 0xfc00 } [  -65536.0 half>bits ] unit-test
{ 0x7c00 } [  131072.0 half>bits ] unit-test
{ 0xfc00 } [ -131072.0 half>bits ] unit-test

! too-small floats flush to zero
{ 0x0000 } [  1.0e-9 half>bits ] unit-test
{ 0x8000 } [ -1.0e-9 half>bits ] unit-test

{  0.0  } [ 0x0000 bits>half ] unit-test
{ -0.0  } [ 0x8000 bits>half ] unit-test
{  1.5  } [ 0x3e00 bits>half ] unit-test
{ -1.5  } [ 0xbe00 bits>half ] unit-test
{  1/0. } [ 0x7c00 bits>half ] unit-test
{ -1/0. } [ 0xfc00 bits>half ] unit-test
{  3.0  } [ 0x4200 bits>half ] unit-test
{    t  } [ 0x7e00 bits>half fp-nan? ] unit-test

STRUCT: halves
    { tom half }
    { dick half }
    { harry half }
    { harry-jr half } ;

{ 8 } [ halves heap-size ] unit-test

{ 3.0 } [
    halves <struct>
        3.0 >>dick
    dick>>
] unit-test

{ half-array{ 1.0 2.0 3.0 1/0. -1/0. } }
[ { 1.0 2.0 3.0 1/0. -1/0. } half >c-array ] unit-test
