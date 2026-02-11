! Copyright (C) 2024 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays cpu.arm.64.assembler
cpu.arm.64.assembler.registers endian kernel make tools.test ;
FROM: cpu.arm.64.assembler => B ;
IN: cpu.arm.64.assembler.tests

: test-insn ( n quot -- ) [ 1array ] dip '[ _ { } make be> ] unit-test ;

0xb7000010 [ X23 5 insns ADR ] test-insn

0x41190091 [ X1 X10 6 ADD ] test-insn
0xff8300d1 [ SP SP 32 SUB ] test-insn
0x3f1d00f1 [ X9 7 CMP ] test-insn

0x6bed7c92 [ X11 X11 -16 AND ] test-insn
0x4aed7cd2 [ X10 X10 -16 EOR ] test-insn
0xcf0d40f2 [ X15 X14 15 ANDS ] test-insn
0x5f0d40f2 [ X10 15 TST ] test-insn

0x290080d2 [ X9 1 MOV ] test-insn

0x00fc4493 [ X0 X0 4 ASR ] test-insn
0x42fc44d3 [ X2 X2 4 LSR ] test-insn
0xceed7cd3 [ X14 X14 4 LSL ] test-insn
0xcf0d7cd3 [ X15 X14 4 4 UBFIZ ] test-insn

0x60000054 [ 3 insns BEQ ] test-insn
0xa1000054 [ 5 insns BNE ] test-insn
0x46000054 [ 2 insns BVS ] test-insn
0x47000054 [ 2 insns BVC ] test-insn

0x3f441bd5 [ FPSR XZR MSR ] test-insn
0x00421bd5 [ NZCV X0 MSR ] test-insn
0x00423bd5 [ X0 NZCV MRS ] test-insn

0x00001fd6 [ X0 BR ] test-insn
0x20033fd6 [ X25 BLR ] test-insn
0xc0035fd6 [ RET ] test-insn

0x03000014 [ 3 insns B ] test-insn
0x00000094 [ 0 BL ] test-insn

0x41002836 [ X1 5 2 insns TBZ ] test-insn

0x49000058 [ X9 2 insns LDR ] test-insn

0xa086ffa9 [ X0 X1 X21 -8 [pre] LDP ] test-insn
0xabaa7fa9 [ X11 X10 X21 -8 [+] LDP ] test-insn
0xfd7bc1a8 [ FP LR SP 16 [post] LDP ] test-insn
0xfd27bfa9 [ FP X9 SP -16 [pre] STP ] test-insn
0xaaae3fa9 [ X10 X11 X21 -8 [+] STP ] test-insn

0xae0240f8 [ X14 X21 [] LDUR ] test-insn

0x4a554039 [ X10 X10 21 [+] LDRB ] test-insn

0x800640f9 [ X0 X20 8 [+] LDR ] test-insn
0xa0865ff8 [ X0 X21 -8 [post] LDR ] test-insn
0xf40700f9 [ X20 SP 8 [+] STR ] test-insn
0xaa8e00f8 [ X10 X21 8 [pre] STR ] test-insn

0x890340f9 [ X9 X28 [] LDR ] test-insn
0x207961f8 [ X0 X9 X1 3 <LSL*> [+] LDR ] test-insn
0xaf0200f9 [ X15 X21 [] STR ] test-insn

0x6e0dca9a [ X14 X11 X10 SDIV ] test-insn

0x6e21ca9a [ X14 X11 X10 LSL ] test-insn
0x6f29ca9a [ X15 X11 X10 ASR ] test-insn

0x6a010a8a [ X10 X11 X10 AND ] test-insn
0x4a010baa [ X10 X10 X11 ORR ] test-insn
0x6a010aca [ X10 X11 X10 EOR ] test-insn
0xf40300aa [ X20 X0 MOV ] test-insn

0xce01098b [ X14 X14 X9 ADD ] test-insn
0x4a118b8b [ X10 X10 X11 4 <ASR> ADD ] test-insn
0x0a0001ab [ X10 X0 X1 ADDS ] test-insn
0x000002cb [ X0 X0 X2 SUB ] test-insn
0xd6068acb [ X22 X22 X10 1 <ASR> SUB ] test-insn
0x0a0001eb [ X10 X0 X1 SUBS ] test-insn
0x5f0109eb [ X10 X9 CMP ] test-insn
0x3ffd8aeb [ X9 X10 63 <ASR> CMP ] test-insn
0xea030aeb [ X10 X10 NEGS ] test-insn

0xca418f9a [ X10 X14 X15 MI CSEL ] test-insn

0x4fad0e9b [ X15 X10 X14 ds-1 MSUB ] test-insn
0x0a7c019b [ X10 X0 X1 MUL ] test-insn
0x097c419b [ X9 X0 X1 SMULH ] test-insn

0xc703669e [ X7 D30 FMOV ] test-insn
0x9e00679e [ D30 X4 FMOV ] test-insn
0xa340601e [ D3 D5 FMOV ] test-insn

0x0200789e [ X2 D0 FCVTZSsi ] test-insn
0x6100629e [ D1 X3 SCVTFsi ] test-insn
0x21c0611e [ D1 D1 FSQRTs ] test-insn
0x01c0221e [ D1 S0 FCVT ] test-insn
0x4540621e [ S5 D2 FCVT ] test-insn

0x0020611e [ D0 D1 FCMP ] test-insn
0x7020601e [ D3 D0 FCMPE ] test-insn

0x6408651e [ D4 D3 D5 FMULs ] test-insn
0x2118601e [ D1 D1 D0 FDIVs ] test-insn

0x42b8a14e [ V2 V2 4S FCVTZSvi ] test-insn

0x21001e4e [ V1 V1 V30 TBL ] test-insn

0x2328824e [ V3 V1 V2 4S TRN1 ] test-insn

0xc30b036e [ V3 V30 V3 1 16B EXT ] test-insn

0x2506186e [ V5 1 D[] V17 0 D[] INS ] test-insn
0x801c1c4e [ V0 3 S[] X4 INS ] test-insn
0x3f0d044e [ V31 X9 4S DUP ] test-insn

0xde5b204e [ V30 V30 16B CNTv ] test-insn
0x1ea8204e [ V30 V0 16B CMLT ] test-insn
0xdf3b212e [ V31 V30 16B SHLL ] test-insn

0xffbb314e [ V31 V31 16B ADDV ] test-insn

0x50d4e04e [ V16 V2 V0 2D FSUBv ] test-insn
0xa0d4656e [ V0 V5 V5 2D FADDP ] test-insn
0xa51c256e [ V5 V5 V5 16B EORv ] test-insn

0x8454324f [ V4 V4 18 4S SHL ] test-insn
0x4204356f [ V2 V2 11 4S USHR ] test-insn
0x04a4082f [ V4 V0 16B UXTL ] test-insn
