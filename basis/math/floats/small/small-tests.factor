USING: kernel math math.floats.small sequences tools.test ;
IN: math.floats.small.tests

{ 0x3c00 0xbc00 0x8000 0x7c00 0xfc00 } [
    1.0 float>half-bits -1.0 float>half-bits -0.0 float>half-bits
    1/0. float>half-bits -1/0. float>half-bits
] unit-test
{ 0x3f80 0xbf80 0x8000 0x7f80 0xff80 } [
    1.0 float>bfloat-bits -1.0 float>bfloat-bits -0.0 float>bfloat-bits
    1/0. float>bfloat-bits -1/0. float>bfloat-bits
] unit-test
{ 0x3c00 0x3c02 0x0001 0x0400 0x7bff 0x7c00 } [
    1.00048828125 float>half-bits 1.00146484375 float>half-bits
    0.000000059604644775390625 float>half-bits
    0.00006103515625 float>half-bits
    65504.0 float>half-bits 65520.0 float>half-bits
] unit-test

! Every finite representation and infinity round-trips; all NaNs canonicalize.
{ t } [
    65536 <iota> [
        dup half-bits>float float>half-bits
        swap dup 0x7c00 bitand 0x7c00 = over 0x03ff bitand zero? not and
        [ drop 0x7e00 ] when =
    ] all?
] unit-test
{ t } [
    65536 <iota> [
        dup bfloat-bits>float float>bfloat-bits
        swap dup 0x7f80 bitand 0x7f80 = over 0x007f bitand zero? not and
        [ drop 0x7fc0 ] when =
    ] all?
] unit-test
