! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Golden bytes independently assembled with GNU binutils hppa-linux-gnu-as.
USING: byte-arrays cpu.hppa.assembler cpu.hppa.assembler.registers
kernel make tools.test ;
FROM: cpu.hppa.assembler => B ;
IN: cpu.hppa.assembler.tests
{ B{ 0x08 0xa4 0x06 0x06 } } [ [ R6 R4 R5 ADD ] B{ } make ] unit-test
{ B{ 0x08 0xa4 0x04 0x06 } } [ [ R6 R4 R5 SUB ] B{ } make ] unit-test
{ B{ 0x08 0xa4 0x02 0x06 } } [ [ R6 R4 R5 AND ] B{ } make ] unit-test
{ B{ 0x08 0xa4 0x02 0x46 } } [ [ R6 R4 R5 OR ] B{ } make ] unit-test
{ B{ 0x08 0xa4 0x02 0x86 } } [ [ R6 R4 R5 XOR ] B{ } make ] unit-test
{ B{ 0x08 0x04 0x02 0x46 } } [ [ R6 R4 COPY ] B{ } make ] unit-test
{ B{ 0x34 0x06 0x3f 0xad } } [ [ R6 -42 LDI ] B{ } make ] unit-test
{ B{ 0x34 0xa6 0x3f 0xad } } [ [ R6 R5 -42 LDO ] B{ } make ] unit-test
{ B{ 0x20 0xc2 0x62 0x46 0x34 0xc6 0x0c 0xf0 } } [ [ R6 0x12345678 LI ] B{ } make ] unit-test
{ B{ 0x48 0xa6 0x3f 0xad } } [ [ R6 R5 -42 LDW ] B{ } make ] unit-test
{ B{ 0x68 0xa6 0x3f 0xad } } [ [ R6 R5 -42 STW ] B{ } make ] unit-test
{ B{ 0x40 0xa6 0x3f 0xad } } [ [ R6 R5 -42 LDB ] B{ } make ] unit-test
{ B{ 0x60 0xa6 0x3f 0xad } } [ [ R6 R5 -42 STB ] B{ } make ] unit-test
{ B{ 0x44 0xa6 0x3f 0xad } } [ [ R6 R5 -42 LDH ] B{ } make ] unit-test
{ B{ 0x64 0xa6 0x3f 0xad } } [ [ R6 R5 -42 STH ] B{ } make ] unit-test
{ B{ 0xe8 0xc0 0xc0 0x00 } } [ [ R6 BV ] B{ } make ] unit-test
{ B{ 0xe4 0xc0 0x20 0x00 } } [ [ R6 BLE ] B{ } make ] unit-test
{ B{ 0x08 0x1f 0x02 0x42 } } [ [ R2 R31 COPY ] B{ } make ] unit-test
{ B{ 0x08 0x00 0x02 0x40 } } [ [ NOP ] B{ } make ] unit-test
{ B{ 0xe4 0xc0 0x20 0x00 0x37 0xe2 0x3f 0xfb } } [ [ R6 CALL ] B{ } make ] unit-test
[ [ R6 8192 LDI ] B{ } make ] [ invalid-hppa-immediate? ] must-fail-with
[ [ R6 -8193 LDI ] B{ } make ] [ invalid-hppa-immediate? ] must-fail-with
[ [ F6 R4 R5 ADD ] B{ } make ] [ invalid-hppa-register? ] must-fail-with
{ B{ 0x80 0xa4 0x20 0x10 } } [ [ R4 R5 16 BEQ ] B{ } make ] unit-test
{ B{ 0x88 0xa4 0x20 0x10 } } [ [ R4 R5 16 BNE ] B{ } make ] unit-test
{ B{ 0x80 0xa4 0x40 0x10 } } [ [ R4 R5 16 BLT ] B{ } make ] unit-test
{ B{ 0x88 0xa4 0x40 0x10 } } [ [ R4 R5 16 BGE ] B{ } make ] unit-test
{ B{ 0x80 0xa4 0x80 0x10 } } [ [ R4 R5 16 BLTU ] B{ } make ] unit-test
{ B{ 0x88 0xa4 0x80 0x10 } } [ [ R4 R5 16 BGEU ] B{ } make ] unit-test
{ B{ 0xe8 0x00 0x00 0x10 } } [ [ 16 B ] B{ } make ] unit-test
{ B{ 0xe8 0x40 0x00 0x10 } } [ [ R2 16 BL ] B{ } make ] unit-test
{ B{ 0xd0 0x86 0x1b 0xe5 } } [ [ R6 R4 31 27 EXTRU ] B{ } make ] unit-test
{ B{ 0xd0 0x86 0x1f 0xe5 } } [ [ R6 R4 31 27 EXTRS ] B{ } make ] unit-test
{ B{ 0xd4 0xc4 0x08 0xa5 } } [ [ R6 R4 26 27 ZDEP ] B{ } make ] unit-test
{ B{ 0x01 0x64 0x18 0x40 } } [ [ R4 MTSAR ] B{ } make ] unit-test
{ B{ 0xd0 0x80 0x00 0x06 } } [ [ R6 R0 R4 VSHD ] B{ } make ] unit-test
{ B{ 0x30 0x85 0x0e 0x06 } } [ [ F6 F4 F5 FADD.D ] B{ } make ] unit-test
{ B{ 0x30 0x85 0x2e 0x06 } } [ [ F6 F4 F5 FSUB.D ] B{ } make ] unit-test
{ B{ 0x30 0x85 0x4e 0x06 } } [ [ F6 F4 F5 FMUL.D ] B{ } make ] unit-test
{ B{ 0x30 0x85 0x6e 0x06 } } [ [ F6 F4 F5 FDIV.D ] B{ } make ] unit-test
{ B{ 0x30 0x80 0x48 0x06 } } [ [ F6 F4 FCOPY.D ] B{ } make ] unit-test
[ [ R4 R5 3 BEQ ] B{ } make ] [ invalid-hppa-immediate? ] must-fail-with
[ [ R6 R4 32 SLLI ] B{ } make ] [ invalid-hppa-immediate? ] must-fail-with
{ B{ 0x2c 0xb1 0x10 0x06 } } [ [ F6 R5 -8 FLDD ] B{ } make ] unit-test
{ B{ 0x2c 0xb1 0x12 0x06 } } [ [ F6 R5 -8 FSTD ] B{ } make ] unit-test
{ B{ 0x24 0xb1 0x10 0x06 } } [ [ F6 R5 -8 FLDW ] B{ } make ] unit-test
{ B{ 0x24 0xb1 0x12 0x06 } } [ [ F6 R5 -8 FSTW ] B{ } make ] unit-test
{ B{ 0x24 0xb1 0x10 0x46 } } [ [ F6 R5 -8 FLDW.R ] B{ } make ] unit-test
{ B{ 0x24 0xb1 0x12 0x46 } } [ [ F6 R5 -8 FSTW.R ] B{ } make ] unit-test
{ B{ 0x30 0x80 0xa2 0x06 } } [ [ F6 F4 FCNV-I32.D ] B{ } make ] unit-test
{ B{ 0x30 0x81 0x8a 0x06 } } [ [ F6 F4 FCNV-D.I32 ] B{ } make ] unit-test
{ B{ 0x30 0x80 0x22 0x06 } } [ [ F6 F4 FCNV-S.D ] B{ } make ] unit-test
{ B{ 0x30 0x80 0x0a 0x06 } } [ [ F6 F4 FCNV-D.S ] B{ } make ] unit-test
{ B{ 0x30 0x80 0x68 0x06 } } [ [ F6 F4 FABS.D ] B{ } make ] unit-test
{ B{ 0x38 0x85 0x47 0x06 } } [ [ F6 F4 F5 XMPYU ] B{ } make ] unit-test
{ B{ 0x30 0x85 0x0c 0x04 } } [ [ F4 F5 4 FCMP.D ] B{ } make ] unit-test
{ B{ 0x30 0x00 0x24 0x20 } } [ [ FTEST ] B{ } make ] unit-test
{ B{ 0xd0 0x86 0x1b 0x45 } } [ [ R6 R4 5 SRLI ] B{ } make ] unit-test
{ B{ 0xd0 0x86 0x1f 0x45 } } [ [ R6 R4 5 SRAI ] B{ } make ] unit-test
[ [ F6 R5 -17 FLDD ] B{ } make ] [ invalid-hppa-immediate? ] must-fail-with

{ B{ 0xd4 0xc4 0x00 0x00 } } [ [ R6 R4 32 ZVDEP ] B{ } make ] unit-test
{ B{ 0xd0 0x86 0x14 0x00 } } [ [ R6 R4 32 VEXTRS ] B{ } make ] unit-test
{ B{ 0xd0 0x86 0x10 0x00 } } [ [ R6 R4 32 VEXTRU ] B{ } make ] unit-test
{ B{ 0xd4 0xe5 0x00 0x0f } } [ [ R7 R5 17 ZVDEP ] B{ } make ] unit-test
{ B{ 0xd0 0xa7 0x14 0x0f } } [ [ R7 R5 17 VEXTRS ] B{ } make ] unit-test
{ B{ 0xd0 0xa7 0x10 0x0f } } [ [ R7 R5 17 VEXTRU ] B{ } make ] unit-test
{ B{ 0x01 0x60 0x08 0xa4 } } [ [ R4 MFSAR ] B{ } make ] unit-test
{ B{ 0x01 0x60 0x08 0xb4 } } [ [ R20 MFSAR ] B{ } make ] unit-test
