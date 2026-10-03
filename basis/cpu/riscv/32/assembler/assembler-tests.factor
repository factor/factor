! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
! Instruction bytes checked against LLVM's RV32GC assembler.
USING: byte-arrays cpu.riscv.32.assembler cpu.riscv.32.assembler.registers
kernel make tools.test ;
IN: cpu.riscv.32.assembler.tests
{ B{ 0x33 0x85 0xc5 0x00 } } [ [ X10 X11 X12 ADD ] B{ } make ] unit-test
{ B{ 0x33 0x85 0xc5 0x40 } } [ [ X10 X11 X12 SUB ] B{ } make ] unit-test
{ B{ 0x33 0x95 0xc5 0x00 } } [ [ X10 X11 X12 SLL ] B{ } make ] unit-test
{ B{ 0x33 0xa5 0xc5 0x00 } } [ [ X10 X11 X12 SLT ] B{ } make ] unit-test
{ B{ 0x33 0xb5 0xc5 0x00 } } [ [ X10 X11 X12 SLTU ] B{ } make ] unit-test
{ B{ 0x33 0xc5 0xc5 0x00 } } [ [ X10 X11 X12 XOR ] B{ } make ] unit-test
{ B{ 0x33 0xd5 0xc5 0x00 } } [ [ X10 X11 X12 SRL ] B{ } make ] unit-test
{ B{ 0x33 0xd5 0xc5 0x40 } } [ [ X10 X11 X12 SRA ] B{ } make ] unit-test
{ B{ 0x33 0xe5 0xc5 0x00 } } [ [ X10 X11 X12 OR ] B{ } make ] unit-test
{ B{ 0x33 0xf5 0xc5 0x00 } } [ [ X10 X11 X12 AND ] B{ } make ] unit-test
{ B{ 0x33 0x85 0xc5 0x02 } } [ [ X10 X11 X12 MUL ] B{ } make ] unit-test
{ B{ 0x33 0x95 0xc5 0x02 } } [ [ X10 X11 X12 MULH ] B{ } make ] unit-test
{ B{ 0x33 0xa5 0xc5 0x02 } } [ [ X10 X11 X12 MULHSU ] B{ } make ] unit-test
{ B{ 0x33 0xb5 0xc5 0x02 } } [ [ X10 X11 X12 MULHU ] B{ } make ] unit-test
{ B{ 0x33 0xc5 0xc5 0x02 } } [ [ X10 X11 X12 DIV ] B{ } make ] unit-test
{ B{ 0x33 0xd5 0xc5 0x02 } } [ [ X10 X11 X12 DIVU ] B{ } make ] unit-test
{ B{ 0x33 0xe5 0xc5 0x02 } } [ [ X10 X11 X12 REM ] B{ } make ] unit-test
{ B{ 0x33 0xf5 0xc5 0x02 } } [ [ X10 X11 X12 REMU ] B{ } make ] unit-test
{ B{ 0x13 0x85 0x55 0xf8 } } [ [ X10 X11 -123 ADDI ] B{ } make ] unit-test
{ B{ 0x13 0xa5 0x55 0xf8 } } [ [ X10 X11 -123 SLTI ] B{ } make ] unit-test
{ B{ 0x13 0xb5 0x55 0xf8 } } [ [ X10 X11 -123 SLTIU ] B{ } make ] unit-test
{ B{ 0x13 0xc5 0x55 0xf8 } } [ [ X10 X11 -123 XORI ] B{ } make ] unit-test
{ B{ 0x13 0xe5 0x55 0xf8 } } [ [ X10 X11 -123 ORI ] B{ } make ] unit-test
{ B{ 0x13 0xf5 0x55 0xf8 } } [ [ X10 X11 -123 ANDI ] B{ } make ] unit-test
{ B{ 0x13 0x95 0xf5 0x00 } } [ [ X10 X11 15 SLLI ] B{ } make ] unit-test
{ B{ 0x13 0xd5 0xf5 0x00 } } [ [ X10 X11 15 SRLI ] B{ } make ] unit-test
{ B{ 0x13 0xd5 0xf5 0x40 } } [ [ X10 X11 15 SRAI ] B{ } make ] unit-test
{ B{ 0x03 0x85 0x05 0xf8 } } [ [ X10 X11 -128 LB ] B{ } make ] unit-test
{ B{ 0x03 0x95 0x05 0xf8 } } [ [ X10 X11 -128 LH ] B{ } make ] unit-test
{ B{ 0x03 0xa5 0x05 0xf8 } } [ [ X10 X11 -128 LW ] B{ } make ] unit-test
{ B{ 0x03 0xc5 0x05 0xf8 } } [ [ X10 X11 -128 LBU ] B{ } make ] unit-test
{ B{ 0x03 0xd5 0x05 0xf8 } } [ [ X10 X11 -128 LHU ] B{ } make ] unit-test
{ B{ 0x23 0x80 0xa5 0xf8 } } [ [ X10 X11 -128 SB ] B{ } make ] unit-test
{ B{ 0x23 0x90 0xa5 0xf8 } } [ [ X10 X11 -128 SH ] B{ } make ] unit-test
{ B{ 0x23 0xa0 0xa5 0xf8 } } [ [ X10 X11 -128 SW ] B{ } make ] unit-test
{ B{ 0x37 0xe5 0xcd 0xab } } [ [ X10 0xabcde LUI ] B{ } make ] unit-test
{ B{ 0x17 0xe5 0xcd 0xab } } [ [ X10 0xabcde AUIPC ] B{ } make ] unit-test
{ B{ 0x67 0x85 0x55 0xf8 } } [ [ X10 X11 -123 JALR ] B{ } make ] unit-test
{ B{ 0xe3 0x05 0xb5 0xea } } [ [ X10 X11 -342 BEQ ] B{ } make ] unit-test
{ B{ 0xe3 0x15 0xb5 0xea } } [ [ X10 X11 -342 BNE ] B{ } make ] unit-test
{ B{ 0xe3 0x45 0xb5 0xea } } [ [ X10 X11 -342 BLT ] B{ } make ] unit-test
{ B{ 0xe3 0x55 0xb5 0xea } } [ [ X10 X11 -342 BGE ] B{ } make ] unit-test
{ B{ 0xe3 0x65 0xb5 0xea } } [ [ X10 X11 -342 BLTU ] B{ } make ] unit-test
{ B{ 0xe3 0x75 0xb5 0xea } } [ [ X10 X11 -342 BGEU ] B{ } make ] unit-test
{ B{ 0x6f 0xb5 0x67 0xe1 } } [ [ X10 -543210 JAL ] B{ } make ] unit-test
{ B{ 0x13 0x00 0x00 0x00 } } [ [ NOP ] B{ } make ] unit-test
{ B{ 0x67 0x80 0x00 0x00 } } [ [ RET ] B{ } make ] unit-test
{ B{ 0x73 0x00 0x00 0x00 } } [ [ ECALL ] B{ } make ] unit-test
{ B{ 0x73 0x00 0x10 0x00 } } [ [ EBREAK ] B{ } make ] unit-test
{ B{ 0x0f 0x10 0x00 0x00 } } [ [ FENCE.I ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0xc5 0x00 } } [ [ F10 F11 F12 FADD.S ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0xc5 0x08 } } [ [ F10 F11 F12 FSUB.S ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0xc5 0x10 } } [ [ F10 F11 F12 FMUL.S ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0xc5 0x18 } } [ [ F10 F11 F12 FDIV.S ] B{ } make ] unit-test
{ B{ 0x53 0x85 0xc5 0x20 } } [ [ F10 F11 F12 FSGNJ.S ] B{ } make ] unit-test
{ B{ 0x53 0x95 0xc5 0x20 } } [ [ F10 F11 F12 FSGNJN.S ] B{ } make ] unit-test
{ B{ 0x53 0xa5 0xc5 0x20 } } [ [ F10 F11 F12 FSGNJX.S ] B{ } make ] unit-test
{ B{ 0x53 0x85 0xc5 0x28 } } [ [ F10 F11 F12 FMIN.S ] B{ } make ] unit-test
{ B{ 0x53 0x95 0xc5 0x28 } } [ [ F10 F11 F12 FMAX.S ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0x05 0x58 } } [ [ F10 F11 FSQRT.S ] B{ } make ] unit-test
{ B{ 0x53 0x85 0xb5 0x20 } } [ [ F10 F11 FMV.S ] B{ } make ] unit-test
{ B{ 0x53 0x95 0xb5 0x20 } } [ [ F10 F11 FNEG.S ] B{ } make ] unit-test
{ B{ 0x53 0xa5 0xb5 0x20 } } [ [ F10 F11 FABS.S ] B{ } make ] unit-test
{ B{ 0x53 0xa5 0xc5 0xa0 } } [ [ X10 F11 F12 FEQ.S ] B{ } make ] unit-test
{ B{ 0x53 0x95 0xc5 0xa0 } } [ [ X10 F11 F12 FLT.S ] B{ } make ] unit-test
{ B{ 0x53 0x85 0xc5 0xa0 } } [ [ X10 F11 F12 FLE.S ] B{ } make ] unit-test
{ B{ 0x53 0x95 0x05 0xc0 } } [ [ X10 F11 1 FCVT.W.S ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0x05 0xd0 } } [ [ F10 X11 7 FCVT.S.W ] B{ } make ] unit-test
{ B{ 0x53 0x95 0x15 0xc0 } } [ [ X10 F11 1 FCVT.WU.S ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0x15 0xd0 } } [ [ F10 X11 7 FCVT.S.WU ] B{ } make ] unit-test
{ B{ 0x53 0x95 0x05 0xe0 } } [ [ X10 F11 FCLASS.S ] B{ } make ] unit-test
{ B{ 0x43 0xf5 0xc5 0x68 } } [ [ F10 F11 F12 F13 FMADD.S ] B{ } make ] unit-test
{ B{ 0x47 0xf5 0xc5 0x68 } } [ [ F10 F11 F12 F13 FMSUB.S ] B{ } make ] unit-test
{ B{ 0x4b 0xf5 0xc5 0x68 } } [ [ F10 F11 F12 F13 FNMSUB.S ] B{ } make ] unit-test
{ B{ 0x4f 0xf5 0xc5 0x68 } } [ [ F10 F11 F12 F13 FNMADD.S ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0xc5 0x02 } } [ [ F10 F11 F12 FADD.D ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0xc5 0x0a } } [ [ F10 F11 F12 FSUB.D ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0xc5 0x12 } } [ [ F10 F11 F12 FMUL.D ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0xc5 0x1a } } [ [ F10 F11 F12 FDIV.D ] B{ } make ] unit-test
{ B{ 0x53 0x85 0xc5 0x22 } } [ [ F10 F11 F12 FSGNJ.D ] B{ } make ] unit-test
{ B{ 0x53 0x95 0xc5 0x22 } } [ [ F10 F11 F12 FSGNJN.D ] B{ } make ] unit-test
{ B{ 0x53 0xa5 0xc5 0x22 } } [ [ F10 F11 F12 FSGNJX.D ] B{ } make ] unit-test
{ B{ 0x53 0x85 0xc5 0x2a } } [ [ F10 F11 F12 FMIN.D ] B{ } make ] unit-test
{ B{ 0x53 0x95 0xc5 0x2a } } [ [ F10 F11 F12 FMAX.D ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0x05 0x5a } } [ [ F10 F11 FSQRT.D ] B{ } make ] unit-test
{ B{ 0x53 0x85 0xb5 0x22 } } [ [ F10 F11 FMV.D ] B{ } make ] unit-test
{ B{ 0x53 0x95 0xb5 0x22 } } [ [ F10 F11 FNEG.D ] B{ } make ] unit-test
{ B{ 0x53 0xa5 0xb5 0x22 } } [ [ F10 F11 FABS.D ] B{ } make ] unit-test
{ B{ 0x53 0xa5 0xc5 0xa2 } } [ [ X10 F11 F12 FEQ.D ] B{ } make ] unit-test
{ B{ 0x53 0x95 0xc5 0xa2 } } [ [ X10 F11 F12 FLT.D ] B{ } make ] unit-test
{ B{ 0x53 0x85 0xc5 0xa2 } } [ [ X10 F11 F12 FLE.D ] B{ } make ] unit-test
{ B{ 0x53 0x95 0x05 0xc2 } } [ [ X10 F11 1 FCVT.W.D ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0x05 0xd2 } } [ [ F10 X11 7 FCVT.D.W ] B{ } make ] unit-test
{ B{ 0x53 0x95 0x15 0xc2 } } [ [ X10 F11 1 FCVT.WU.D ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0x15 0xd2 } } [ [ F10 X11 7 FCVT.D.WU ] B{ } make ] unit-test
{ B{ 0x53 0x95 0x05 0xe2 } } [ [ X10 F11 FCLASS.D ] B{ } make ] unit-test
{ B{ 0x43 0xf5 0xc5 0x6a } } [ [ F10 F11 F12 F13 FMADD.D ] B{ } make ] unit-test
{ B{ 0x47 0xf5 0xc5 0x6a } } [ [ F10 F11 F12 F13 FMSUB.D ] B{ } make ] unit-test
{ B{ 0x4b 0xf5 0xc5 0x6a } } [ [ F10 F11 F12 F13 FNMSUB.D ] B{ } make ] unit-test
{ B{ 0x4f 0xf5 0xc5 0x6a } } [ [ F10 F11 F12 F13 FNMADD.D ] B{ } make ] unit-test
{ B{ 0x53 0x85 0x05 0xe0 } } [ [ X10 F11 FMV.X.W ] B{ } make ] unit-test
{ B{ 0x53 0x85 0x05 0xf0 } } [ [ F10 X11 FMV.W.X ] B{ } make ] unit-test
{ B{ 0x53 0xf5 0x15 0x40 } } [ [ F10 F11 FCVT.S.D ] B{ } make ] unit-test
{ B{ 0x53 0x85 0x05 0x42 } } [ [ F10 F11 FCVT.D.S ] B{ } make ] unit-test
{ B{ 0x07 0xa5 0x05 0xf8 } } [ [ F10 X11 -128 FLW ] B{ } make ] unit-test
{ B{ 0x07 0xb5 0x05 0xf8 } } [ [ F10 X11 -128 FLD ] B{ } make ] unit-test
{ B{ 0x27 0xa0 0xa5 0xf8 } } [ [ F10 X11 -128 FSW ] B{ } make ] unit-test
{ B{ 0x27 0xb0 0xa5 0xf8 } } [ [ F10 X11 -128 FSD ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0x0e } } [ [ X10 X11 X12 1 1 AMOSWAP.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0x06 } } [ [ X10 X11 X12 1 1 AMOADD.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0x26 } } [ [ X10 X11 X12 1 1 AMOXOR.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0x66 } } [ [ X10 X11 X12 1 1 AMOAND.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0x46 } } [ [ X10 X11 X12 1 1 AMOOR.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0x86 } } [ [ X10 X11 X12 1 1 AMOMIN.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0xa6 } } [ [ X10 X11 X12 1 1 AMOMAX.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0xc6 } } [ [ X10 X11 X12 1 1 AMOMINU.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0xe6 } } [ [ X10 X11 X12 1 1 AMOMAXU.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0xc5 0x1e } } [ [ X10 X11 X12 1 1 SC.W ] B{ } make ] unit-test
{ B{ 0x2f 0xa5 0x05 0x16 } } [ [ X10 X11 1 1 LR.W ] B{ } make ] unit-test
{ B{ 0x01 0x00 } } [ [  C.NOP ] B{ } make ] unit-test
{ B{ 0x3d 0x15 } } [ [ X10 -17 C.ADDI ] B{ } make ] unit-test
{ B{ 0x3d 0x55 } } [ [ X10 -17 C.LI ] B{ } make ] unit-test
{ B{ 0x7d 0x75 } } [ [ X10 0xfffff C.LUI ] B{ } make ] unit-test
{ B{ 0x41 0x71 } } [ [ -496 C.ADDI16SP ] B{ } make ] unit-test
{ B{ 0xe8 0x17 } } [ [ X10 1004 C.ADDI4SPN ] B{ } make ] unit-test
{ B{ 0xe8 0x5d } } [ [ X10 X11 124 C.LW ] B{ } make ] unit-test
{ B{ 0xe8 0xdd } } [ [ X10 X11 124 C.SW ] B{ } make ] unit-test
{ B{ 0xe8 0x3d } } [ [ F10 X11 248 C.FLD ] B{ } make ] unit-test
{ B{ 0xe8 0xbd } } [ [ F10 X11 248 C.FSD ] B{ } make ] unit-test
{ B{ 0x3d 0x81 } } [ [ X10 15 C.SRLI ] B{ } make ] unit-test
{ B{ 0x3d 0x85 } } [ [ X10 15 C.SRAI ] B{ } make ] unit-test
{ B{ 0x3e 0x05 } } [ [ X10 15 C.SLLI ] B{ } make ] unit-test
{ B{ 0x3d 0x99 } } [ [ X10 -17 C.ANDI ] B{ } make ] unit-test
{ B{ 0xdd 0xbe } } [ [ -1034 C.J ] B{ } make ] unit-test
{ B{ 0x2d 0xd9 } } [ [ X10 -142 C.BEQZ ] B{ } make ] unit-test
{ B{ 0x2d 0xf9 } } [ [ X10 -142 C.BNEZ ] B{ } make ] unit-test
{ B{ 0x7e 0x55 } } [ [ X10 252 C.LWSP ] B{ } make ] unit-test
{ B{ 0x7e 0x35 } } [ [ F10 504 C.FLDSP ] B{ } make ] unit-test
{ B{ 0xaa 0xdf } } [ [ X10 252 C.SWSP ] B{ } make ] unit-test
{ B{ 0xaa 0xbf } } [ [ F10 504 C.FSDSP ] B{ } make ] unit-test
{ B{ 0x02 0x85 } } [ [ X10 C.JR ] B{ } make ] unit-test
{ B{ 0x02 0x95 } } [ [ X10 C.JALR ] B{ } make ] unit-test
{ B{ 0x2e 0x85 } } [ [ X10 X11 C.MV ] B{ } make ] unit-test
{ B{ 0x2e 0x95 } } [ [ X10 X11 C.ADD ] B{ } make ] unit-test
{ B{ 0x02 0x90 } } [ [  C.EBREAK ] B{ } make ] unit-test
{ B{ 0x0d 0x8d } } [ [ X10 X11 C.SUB ] B{ } make ] unit-test
{ B{ 0x2d 0x8d } } [ [ X10 X11 C.XOR ] B{ } make ] unit-test
{ B{ 0x4d 0x8d } } [ [ X10 X11 C.OR ] B{ } make ] unit-test
{ B{ 0x6d 0x8d } } [ [ X10 X11 C.AND ] B{ } make ] unit-test
[ [ X10 X11 2048 ADDI ] B{ } make ] must-fail
[ [ X10 X11 -2049 ADDI ] B{ } make ] must-fail
[ [ X10 X11 32 SLLI ] B{ } make ] must-fail
[ [ X10 X11 3 BEQ ] B{ } make ] must-fail
[ [ X10 1048576 JAL ] B{ } make ] must-fail
[ [ X10 0 C.ADDI4SPN ] B{ } make ] must-fail
[ [ ZERO C.JR ] B{ } make ] must-fail
[ [ X10 0 C.LUI ] B{ } make ] must-fail
{ B{ 0xe8 0x7d } } [ [ F10 X11 124 C.FLW ] B{ } make ] unit-test
{ B{ 0xe8 0xfd } } [ [ F10 X11 124 C.FSW ] B{ } make ] unit-test
{ B{ 0x7e 0x75 } } [ [ F10 252 C.FLWSP ] B{ } make ] unit-test
{ B{ 0xaa 0xff } } [ [ F10 252 C.FSWSP ] B{ } make ] unit-test
{ B{ 0xdd 0x3e } } [ [ -1034 C.JAL ] B{ } make ] unit-test
{ B{ 0x73 0x25 0x00 0xc8 } } [ [ X10 RDCYCLEH ] B{ } make ] unit-test
{ B{ 0x73 0x25 0x10 0xc8 } } [ [ X10 RDTIMEH ] B{ } make ] unit-test
{ B{ 0x73 0x25 0x20 0xc8 } } [ [ X10 RDINSTRETH ] B{ } make ] unit-test
{ B{ 0x37 0x55 0x34 0x12 0x13 0x05 0x85 0x67 } } [ [ X10 0x12345678 LI32 ] B{ } make ] unit-test
{ B{ 0x37 0x05 0x00 0x80 0x13 0x05 0x05 0x00 } } [ [ X10 0x80000000 LI32 ] B{ } make ] unit-test
{ B{ 0x37 0x05 0x00 0x00 0x13 0x05 0xf5 0xff } } [ [ X10 0xffffffff LI32 ] B{ } make ] unit-test
{ B{ 0x13 0x05 0xf0 0xff } } [ [ X10 0xffffffff LI ] B{ } make ] unit-test
[ [ X10 32 C.SLLI ] B{ } make ] must-fail
[ [ X10 32 C.SRLI ] B{ } make ] must-fail
[ [ F10 X11 1 C.FLW ] B{ } make ] must-fail
[ [ F10 1 C.FLWSP ] B{ } make ] must-fail
