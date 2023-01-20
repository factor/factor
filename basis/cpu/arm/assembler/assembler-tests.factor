! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes make
tools.test ;
IN: cpu.arm.assembler.tests

{ { 0x10 0x02 0x00 0x91 } } [ [ 0 X16 X16 ADDi64 ] { } make ] unit-test
{ { 0x10 0x22 0x00 0x91 } } [ [ 8 X16 X16 ADDi64 ] { } make ] unit-test
{ { 0x10 0xe2 0x3f 0x91 } } [ [ 0xff8 X16 X16 ADDi64 ] { } make ] unit-test

{ { 0xb8 0x04 0x40 0x94 } } [ [ 0x04004b8 BL ] { } make ] unit-test
{ { 0x20 0x02 0x1f 0xd6 } } [ [ X17 BR ] { } make ] unit-test

{ { 0xc0 0x03 0x5f 0xd6 } } [ [ f RET ] { } make ] unit-test
{ { 0xfd 0x7b 0xbf 0xa9 } } [ [ -16 SP X30 X29 STP-pre ] { } make ] unit-test
{ { 0xf0 0x7b 0xbf 0xa9 } } [ [ -16 SP X30 X16 STP-pre ] { } make ] unit-test

{ { 0x11 0xfe  0x47 0xf9 } } [ [ 4088 X16 X17 LDR-uoff ] { } make ] unit-test
{ { 0x11 0x02  0x40 0xf9 } } [ [ 0 X16 X17 LDR-uoff ] { } make ] unit-test
! ldr     x17, [x16,#8]
{ {  0x11  0x06 0x40 0xf9 } } [ [ 8 X16 X17 LDR-uoff ] { } make ] unit-test

! ldr     x1, [sp]
{ { 0xe1 0x03 0x40 0xf9  } } [ [ 0 SP X1 LDR-uoff ] { } make ] unit-test

! XXX: shift 4096 right first?
! { { 0x90 0x00 0x00 0xb0 } } [ [ 0x411000 X16 ADRP ] { } make ] unit-test
! { { 0x90 0x00 0x00 0xb0 } } [ [ 0x411000 X16 ADRP ] { } make ] unit-test

! mov     x29, #0x0
{ { 0x1d 0x00 0x80 0xd2 } } [ [ 0 X29 MOVwi64 ] { } make ] unit-test
{ { 0x1e 0x00 0x80 0xd2 } } [ [ 0 X30 MOVwi64 ] { } make ] unit-test
{ { 0xe5 0x03 0x00 0xaa } } [ [ X0 X5 MOVr64 ] { } make ] unit-test


{ { 0x20 0xfc 0x6c 0xd3 } } [ [ 44 X1 X0 LSRi64 ] { } make ] unit-test

