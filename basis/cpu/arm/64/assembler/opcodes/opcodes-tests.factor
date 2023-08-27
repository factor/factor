! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.64.assembler cpu.arm.64.assembler.opcodes make
math math.bitwise tools.test ;
IN: cpu.arm.64.assembler.opcodes.tests

{ { 0x41 0x0 0x3 0x1a } } [ [ 0 W3 W2 W1 ADC-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0x3a } } [ [ 0 W3 W2 W1 ADCS-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0x5a } } [ [ 0 W3 W2 W1 SBC-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0x7a } } [ [ 0 W3 W2 W1 SBCS-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0x9a } } [ [ 1 X3 X2 X1 ADC-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0xba } } [ [ 1 X3 X2 X1 ADCS-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0xda } } [ [ 1 X3 X2 X1 SBC-encode ] { } make ] unit-test
{ { 0x41 0x0 0x3 0xfa } } [ [ 1 X3 X2 X1 SBCS-encode ] { } make ] unit-test

{ { 0xfd 0x03 0x00 0x91 } } [ [ 1 0 SP X29 MOVsp-encode ] { } make ] unit-test

! stp x29, x30, [sp, #-16]!
{ { 0xfd 0x7b 0xbf 0xa9 } } [ [ 1 -16 8 / 7 bits X30 SP X29 STPpre-encode ] { } make ] unit-test
