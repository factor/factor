! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes make tools.test ;
IN: cpu.arm.assembler.tests

{ { 0xb8 0x04 0x40 0x94 } } [ [ 0x04004b8 BL ] { } make ] unit-test
{ { 0x20 0x02 0x1f 0xd6 } } [ [ X17 BR ] { } make ] unit-test

{ { 0xc0 0x03 0x5f 0xd6 } } [ [ f RET ] { } make ] unit-test
