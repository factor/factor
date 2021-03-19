! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes make math
math.bitwise tools.test ;
IN: cpu.arm.assembler.opcodes.tests

{ { 0x41 0x0 0x3 0x1a } } [ [ X3 X2 X1 ADC32-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0x3a } } [ [ X3 X2 X1 ADCS32-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0x5a } } [ [ X3 X2 X1 SBC32-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0x7a } } [ [ X3 X2 X1 SBCS32-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0x9a } } [ [ X3 X2 X1 ADC64-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0xba } } [ [ X3 X2 X1 ADCS64-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0xda } } [ [ X3 X2 X1 SBC64-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0xfa } } [ [ X3 X2 X1 SBCS64-encode ] { } make ] unit-test

{ { 0xfd 0x03 0x00 0x91 } } [ [ 0 31 X29 MOVsp64-encode ] { } make ] unit-test

! stp x29, x30, [sp,#-16]!
{ { 0xfd 0x7b 0xbf 0xa9 } } [ [ -16 8 / 7 bits X30 SP X29 STPpre64-encode ] { } make ] unit-test


{ { 0 0 0 0x10 } } [ [ 0 X0 ADR ] { } make ] unit-test
{ { 0 0 0 0x30 } } [ [ 1 X0 ADR ] { } make ] unit-test

{ { 0 0 0 0x90 } } [ [ 0 X0 ADRP ] { } make ] unit-test
{ { 0 0 0 0xb0 } } [ [ 1 X0 ADRP ] { } make ] unit-test
