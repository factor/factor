! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Golden bytes from native OpenBSD gas and redstar LLVM M88k MC tests.
USING: byte-arrays cpu.m88k.assembler cpu.m88k.assembler.registers
kernel make tools.test ;
IN: cpu.m88k.assembler.tests
{ B{ 0xf4 0x01 0x60 0x02 } } [ [ R0 R1 R2 ADDU ] B{ } make ] unit-test
{ B{ 0xf4 0x01 0x64 0x02 } } [ [ R0 R1 R2 SUBU ] B{ } make ] unit-test
{ B{ 0xf4 0x01 0x58 0x02 } } [ [ R0 R1 R2 OR ] B{ } make ] unit-test
{ B{ 0x58 0x40 0x00 0x2a 0xf4 0x00 0xc0 0x01 } }
[ [ R2 ZERO 42 ORI RET ] B{ } make ] unit-test
{ B{ 0xf0 0x00 0xd1 0xc3 } } [ [ 0 ZERO 451 TB0 ] B{ } make ] unit-test
{ B{ 0x14 0x01 0x10 0x00 } } [ [ R0 R1 4096 LD ] B{ } make ] unit-test
{ B{ 0x24 0x01 0x10 0x00 } } [ [ R0 R1 4096 ST ] B{ } make ] unit-test
{ B{ 0xf4 0x00 0xc8 0x0a } } [ [ R10 JSR ] B{ } make ] unit-test
{ B{ 0x5c 0x40 0x12 0x34 0x58 0x42 0x56 0x78 } }
[ [ R2 0x12345678 LI32 ] B{ } make ] unit-test
[ [ R2 ZERO -1 ORI ] B{ } make ] must-fail
[ [ R2 ZERO 65536 ORI ] B{ } make ] must-fail
[ [ 32 ZERO 451 TB0 ] B{ } make ] must-fail
[ [ 0 ZERO 512 TB0 ] B{ } make ] must-fail
[ [ R2 0x100000000 LI32 ] B{ } make ] must-fail
{ B{ 0x84 0x42 0x2a 0xa2 0xf4 0x00 0xc0 0x01 } }
[ [ R2 R2 R2 FADD.D RET ] B{ } make ] unit-test
{ B{ 0x84 0x01 0x02 0xa2 } } [ [ R0 R1 R2 FMUL.D ] B{ } make ] unit-test
{ B{ 0x84 0x01 0x32 0xa2 } } [ [ R0 R1 R2 FSUB.D ] B{ } make ] unit-test
{ B{ 0x84 0x01 0x72 0xa2 } } [ [ R0 R1 R2 FDIV.D ] B{ } make ] unit-test
{ B{ 0xc0 0 0 2 } } [ [ 8 BR ] B{ } make ] unit-test
{ B{ 0xcb 0xff 0xff 0xfe } } [ [ -8 BSR ] B{ } make ] unit-test
{ B{ 0xd0 0x41 0xff 0xfe } } [ [ 2 R1 -8 BB0 ] B{ } make ] unit-test
[ [ 2 BR ] B{ } make ] must-fail
[ [ 0x8000000 BR ] B{ } make ] must-fail
[ [ -0x8000004 BR ] B{ } make ] must-fail
[ [ 0 R1 0x20000 BB0 ] B{ } make ] must-fail
{ B{ 0x84 0x42 0x32 0xa4 0xf4 0x00 0xc0 0x01 } }
[ [ R2 R2 R4 FSUB.D RET ] B{ } make ] unit-test
{ B{ 0x84 0x42 0x02 0xa4 0xf4 0x00 0xc0 0x01 } }
[ [ R2 R2 R4 FMUL.D RET ] B{ } make ] unit-test
{ B{ 0x84 0x42 0x72 0xa4 0xf4 0x00 0xc0 0x01 } }
[ [ R2 R2 R4 FDIV.D RET ] B{ } make ] unit-test
! Golden bytes from native OpenBSD GCC/objdump; template executed in GXemul.
{ B{ 0xf4 0x62 0x04 0 } } [ [ R3 R2 ZERO XMEM ] B{ } make ] unit-test
{ B{ 0xf0 0 0xd8 0x80 } } [ [ 0 ZERO 128 TB1 ] B{ } make ] unit-test
[ [ 32 ZERO 128 TB1 ] B{ } make ] must-fail
[ [ 0 ZERO 512 TB1 ] B{ } make ] must-fail
{ B{ 0xf5 0x40 0x58 1 0xc8 0 0 3 0xf4 0x20 0x58 0x0a
      0xf4 0 0xc0 1 0x60 0x42 0 1 0xf4 0 0xc0 1 } }
[ [ R10 ZERO RA OR 12 BSR RA ZERO R10 OR RET R2 R2 1 ADDUI RET ] B{ } make ] unit-test
{ B{ 0xd0 2 0 3 0x58 0x40 0 0x2b 0xc0 0 0 2
      0x58 0x40 0 0x2a 0xf4 0 0xc0 1 } }
[ [ 0 R2 12 BB0 R2 ZERO 43 ORI 8 BR R2 ZERO 42 ORI RET ] B{ } make ] unit-test
{ B{ 0xf4 1 0x6c 2 } } [ [ R0 R1 R2 MUL ] B{ } make ] unit-test
{ B{ 0xf4 0x22 0x90 3 } } [ [ R1 R2 R3 EXT ] B{ } make ] unit-test
{ B{ 0xf4 0x22 0x98 3 } } [ [ R1 R2 R3 EXTU ] B{ } make ] unit-test
{ B{ 0xf4 1 0xa0 2 } } [ [ R0 R1 R2 MAK ] B{ } make ] unit-test
{ B{ 0xf0 0x22 0x98 6 } } [ [ R1 R2 6 EXTUI ] B{ } make ] unit-test
[ [ R1 R2 32 EXTUI ] B{ } make ] must-fail
{ B{ 0x1c 1 0 0 } } [ [ R0 R1 0 LDB ] B{ } make ] unit-test
{ B{ 0x0c 1 0 0 } } [ [ R0 R1 0 LDBU ] B{ } make ] unit-test
{ B{ 0x18 1 0 0 } } [ [ R0 R1 0 LDH ] B{ } make ] unit-test
{ B{ 0x08 1 0 0 } } [ [ R0 R1 0 LDHU ] B{ } make ] unit-test
{ B{ 0x2c 1 0 0 } } [ [ R0 R1 0 STB ] B{ } make ] unit-test
{ B{ 0x28 1 0 0 } } [ [ R0 R1 0 STH ] B{ } make ] unit-test
{ B{ 0x84 0 0x20 0x2a } } [ [ R0 R10 FLT.D ] B{ } make ] unit-test
{ B{ 0x84 0x20 0x58 0x83 } } [ [ R1 R3 TRNC.D ] B{ } make ] unit-test
{ B{ 0x84 1 0x3a 0x82 } } [ [ R0 R1 R2 FCMP.D ] B{ } make ] unit-test
{ B{ 0xf0 1 0x99 0x45 } } [ [ R0 R1 10 5 EXTUW ] B{ } make ] unit-test
{ B{ 0x84 1 0 0x22 } } [ [ R0 R1 R2 FMUL.DSS ] B{ } make ] unit-test
{ B{ 0x84 1 2 2 } } [ [ R0 R1 R2 FMUL.SDS ] B{ } make ] unit-test
{ B{ 0xf4 0 0xc4 0x15 } } [ [ R21 JMP.N ] B{ } make ] unit-test
