! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler.opcodes math math.bitwise tools.test ;
IN: cpu.arm.assembler.opcodes.tests

{ 0b00011010000000110000000001000001 } [ X3 X2 X1 ADC32-encode ] unit-test
{ 0b00111010000000110000000001000001 } [ X3 X2 X1 ADCS32-encode ] unit-test
{ 0b01011010000000110000000001000001 } [ X3 X2 X1 SBC32-encode ] unit-test
{ 0b01111010000000110000000001000001 } [ X3 X2 X1 SBCS32-encode ] unit-test
{ 0b10011010000000110000000001000001 } [ X3 X2 X1 ADC64-encode ] unit-test
{ 0b10111010000000110000000001000001 } [ X3 X2 X1 ADCS64-encode ] unit-test
{ 0b11011010000000110000000001000001 } [ X3 X2 X1 SBC64-encode ] unit-test
{ 0b11111010000000110000000001000001 } [ X3 X2 X1 SBCS64-encode ] unit-test

{ 0x910003fd } [ 0 31 X29 MOVsp64-encode ] unit-test

! stp x29, x30, [sp,#-16]!
{ 0xa9bf7bfd } [ -16 8 / 7 bits X30 SP X29 STPpre64-encode ] unit-test
