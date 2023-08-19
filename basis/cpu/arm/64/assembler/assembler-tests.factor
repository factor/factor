! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.64.assembler make tools.test ;
IN: cpu.arm.64.assembler.tests

! useful for testing maybe: https://armconverter.com/

{ { 0x2e 0x01 0x10 0x94 } } [ [ 0x04004b8 BL ] { } make ] unit-test
{ { 0x20 0x02 0x1f 0xd6 } } [ [ X17 BR ] { } make ] unit-test

{ { 0xc0 0x03 0x5f 0xd6 } } [ [ f RET ] { } make ] unit-test

{ { 0x10 0x02 0x00 0x91 } } [ [ 0 X16 X16 ADDi ] { } make ] unit-test
{ { 0x10 0x22 0x00 0x91 } } [ [ 8 X16 X16 ADDi ] { } make ] unit-test
{ { 0x10 0xe2 0x3f 0x91 } } [ [ 0xff8 X16 X16 ADDi ] { } make ] unit-test

! mov x29, #0x0
{ { 0x1d 0x00 0x80 0xd2 } } [ [ 0 X29 MOVwi ] { } make ] unit-test
{ { 0x1e 0x00 0x80 0xd2 } } [ [ 0 X30 MOVwi ] { } make ] unit-test
{ { 0xe5 0x03 0x00 0xaa } } [ [ X0 X5 MOVr ] { } make ] unit-test

{ { 0x20 0xfc 0x6c 0xd3 } } [ [ 44 X1 X0 LSRi ] { } make ] unit-test

{ { 0xfd 0x7b 0xbf 0xa9 } } [ [ -16 SP X30 X29 STPpre ] { } make ] unit-test
{ { 0xf0 0x7b 0xbf 0xa9 } } [ [ -16 SP X30 X16 STPpre ] { } make ] unit-test

{ { 0x11 0xfe 0x47 0xf9 } } [ [ 4088 X16 X17 LDRuoff ] { } make ] unit-test
{ { 0x11 0x02 0x40 0xf9 } } [ [ 0 X16 X17 LDRuoff ] { } make ] unit-test
! ldr x17, [x16, #8]
{ { 0x11 0x06 0x40 0xf9 } } [ [ 8 X16 X17 LDRuoff ] { } make ] unit-test

! ldr x1, [sp]
{ { 0xe1 0x03 0x40 0xf9 } } [ [ 0 SP X1 LDRuoff ] { } make ] unit-test

{ { 0x08 0xed 0x7c 0x92 } } [ [ -16 X8 X8 ANDi ] { } make ] unit-test

{ { 0x00 0x00 0x00 0x10 } } [ [ 0 X0 ADR ] { } make ] unit-test
{ { 0x00 0x00 0x00 0x30 } } [ [ 1 X0 ADR ] { } make ] unit-test

{ { 0x90 0x20 0x00 0xb0 } } [ [ 0x411000 X16 ADRP ] { } make ] unit-test
