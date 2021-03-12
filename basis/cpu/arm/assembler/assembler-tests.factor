! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes
tools.test ;
IN: cpu.arm.assembler.tests

{ 0x91000210 } [ [ 0 X16 X16 ADDi64 ] test-arm64-instruction ] unit-test
{ 0x91002210 } [ [ 8 X16 X16 ADDi64 ] test-arm64-instruction ] unit-test
{ 0x913fe210 } [ [ 0xff8 X16 X16 ADDi64 ] test-arm64-instruction ] unit-test

{ 0x94000030 } [ 0x4003f8 [ 0x04004b8 BL ] offset-test-arm64-instruction ] unit-test
{ 0xd61f0220 } [ 0x4003f8 [ X17 BR ] offset-test-arm64-instruction ] unit-test

{ 0xd65f03c0 } [ [ f RET ] test-arm64-instruction ] unit-test
{ 0xa9bf7bfd } [ [ -16 SP X30 X29 STP-pre ] test-arm64-instruction ] unit-test
{ 0xa9bf7bf0 } [ [ -16 SP X30 X16 STP-pre ] test-arm64-instruction ] unit-test

{ 0xf947fe11 } [ [ 4088 X16 X17 LDR-uoff ] test-arm64-instruction ] unit-test
{ 0xf9400211 } [ [ 0 X16 X17 LDR-uoff ] test-arm64-instruction ] unit-test
! ldr     x17, [x16,#8]
{ 0xf9400611 } [ [ 8 X16 X17 LDR-uoff ] test-arm64-instruction ] unit-test

! ldr     x1, [sp]
{ 0xf94003e1 } [ [ 0 SP X1 LDR-uoff ] test-arm64-instruction ] unit-test

{ 0xb0000090 } [ 0x400440 [ 0x411000 X16 ADRP ] offset-test-arm64-instruction ] unit-test
{ 0xb0000090 } [ 0x400440 [ 0x411000 X16 ADRP ] offset-test-arm64-instruction ] unit-test

! mov     x29, #0x0
{ 0xd280001d } [ [ 0 X29 MOVwi64 ] test-arm64-instruction ] unit-test
{ 0xd280001e } [ [ 0 X30 MOVwi64 ] test-arm64-instruction ] unit-test
{ 0xaa0003e5 } [ [ X0 X5 MOVr64 ] test-arm64-instruction ] unit-test


{ 0xd36cfc20 } [ [ 44 X1 X0 LSRi64 ] test-arm64-instruction ] unit-test

{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
