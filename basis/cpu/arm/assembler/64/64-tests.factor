! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler.64 cpu.arm.assembler.opcodes make
tools.test ;
IN: cpu.arm.assembler.64.tests

{ { 0x10 0x02 0x00 0x91 } } [ [ 0 X16 X16 ADDi ] { } make ] unit-test
{ { 0x10 0x22 0x00 0x91 } } [ [ 8 X16 X16 ADDi ] { } make ] unit-test
{ { 0x10 0xe2 0x3f 0x91 } } [ [ 0xff8 X16 X16 ADDi ] { } make ] unit-test
