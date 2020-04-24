! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test cpu.arm64.assembler ;
IN: cpu.arm64.assembler.tests

{ 0b00011010000000110000000001000001 } [ X3 X2 X1 ADC32 ] unit-test
{ 0b00111010000000110000000001000001 } [ X3 X2 X1 ADCS32 ] unit-test
{ 0b01011010000000110000000001000001 } [ X3 X2 X1 SBC32 ] unit-test
{ 0b01111010000000110000000001000001 } [ X3 X2 X1 SBCS32 ] unit-test
{ 0b10011010000000110000000001000001 } [ X3 X2 X1 ADC64 ] unit-test
{ 0b10111010000000110000000001000001 } [ X3 X2 X1 ADCS64 ] unit-test
{ 0b11011010000000110000000001000001 } [ X3 X2 X1 SBC64 ] unit-test
{ 0b11111010000000110000000001000001 } [ X3 X2 X1 SBCS64 ] unit-test


{ 0x910003fd } [ 0 31 X29 MOVsp64 ] unit-test

{ 0x94000030 } [  ] unit-test

{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test
{ } [ ] unit-test