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

0x61080129 [ W1 W2 X3 8 [+] STP ] test-insn
0xc4947e29 [ W4 W5 X6 -12 [+] LDP ] test-insn
0xaa2e3f29 [ W10 W11 X21 -8 [+] STP ] test-insn
0xa006ff29 [ W0 W1 X21 -8 [pre] LDP ] test-insn

! FP/SIMD pair offsets scale with the S/D/Q register width
0x4084002d [ S0 S1 X2 4 [+] STP ] test-insn
0x4084006d [ D0 D1 X2 8 [+] STP ] test-insn
0x408400ad [ Q0 Q1 X2 16 [+] STP ] test-insn
0x828cff2d [ S2 S3 X4 -4 [pre] LDP ] test-insn
0x828cc06c [ D2 D3 X4 8 [post] LDP ] test-insn
0x828c7fad [ Q2 Q3 X4 -16 [+] LDP ] test-insn
[ [ SP X0 X1 [] STP ] { } make ] must-fail
[ [ X0 D1 X2 [] STP ] { } make ] must-fail

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

! Signed loads into a W register (opc[0] set from Rt), vs X dest
0x2000c039 [ W0 X1 [] LDRSB ] test-insn
0x20008039 [ X0 X1 [] LDRSB ] test-insn
0x2000c079 [ W0 X1 [] LDRSH ] test-insn
0x20008079 [ X0 X1 [] LDRSH ] test-insn
0x2068e238 [ W0 X1 X2 [+] LDRSB ] test-insn
0x2078e278 [ W0 X1 X2 1 <LSL*> [+] LDRSH ] test-insn

! Extended-register ADD/SUB with a W-sized Rm
0x2048228b [ X0 X1 W2 2 <UXTW> ADD ] test-insn
0x20a022cb [ X0 X1 W2 0 <SXTH> SUB ] test-insn
0x2068228b [ X0 X1 X2 2 <UXTX> ADD ] test-insn
0x2048220b [ W0 W1 W2 2 <UXTW> ADD ] test-insn
[ [ W0 W1 X2 2 <UXTX> ADD ] { } make ] must-fail

! SIMD arrangements narrower than 128 bits (Q taken from the shape)
0x2084220e [ V0 V1 V2 8B ADDv ] test-insn
0x2084620e [ V0 V1 V2 4H ADDv ] test-insn
0x2084a20e [ V0 V1 V2 2S ADDv ] test-insn
0x20d4220e [ V0 V1 V2 2S FADDv ] test-insn
0x2058200e [ V0 V1 8B CNTv ] test-insn
0x20b8202e [ V0 V1 8B NEGv ] test-insn
0x20a8600e [ V0 V1 4H CMLT ] test-insn
0x20d8210e [ V0 V1 2S SCVTFvi ] test-insn
0x20f8a00e [ V0 V1 2S FABSv ] test-insn
0x20b8710e [ V0 V1 4H ADDV ] test-insn
0x2028820e [ V0 V1 V2 2S TRN1 ] test-insn
0x2038020e [ V0 V1 V2 8B ZIP1 ] test-insn

! MOVZ rejects an out-of-range immediate
[ [ W0 0x1ffff 0 MOVZ ] { } make ] must-fail

! LSL #0 must wrap immr to zero, including for 32-bit registers.
0x207c0053 [ W0 W1 0 LSL ] test-insn
0x20fc40d3 [ X0 X1 0 LSL ] test-insn
0x20781f53 [ W0 W1 1 LSL ] test-insn
0x20000153 [ W0 W1 31 LSL ] test-insn

! Independently assembled with Clang for AArch64.
0x20cc224e [ V0 V1 V2 4S FMLAv ] test-insn
0x2088214e [ V0 V1 4S FRINTNv ] test-insn
0x2098214e [ V0 V1 4S FRINTMv ] test-insn
0x2088a14e [ V0 V1 4S FRINTPv ] test-insn
0x2098a14e [ V0 V1 4S FRINTZv ] test-insn
0x2088216e [ V0 V1 4S FRINTAv ] test-insn
0x2038306e [ V0 V1 16B UADDLV ] test-insn
0x2028206e [ V0 V1 16B UADDLP ] test-insn
0x2048a06e [ V0 V1 4S CLZv ] test-insn
0x2058606e [ V0 V1 RBITv ] test-insn
0x2008204e [ V0 V1 16B REV64v ] test-insn
0x2008206e [ V0 V1 16B REV32v ] test-insn
0x2018204e [ V0 V1 16B REV16v ] test-insn
0x20b8a16e [ V0 V1 4S FCVTZUvi ] test-insn
0x201c626e [ V0 V1 V2 16B BSLv ] test-insn

! Encodings independently assembled by Clang for armv8.6-a+fp16.
{ 0x2094824e } [ [ V0 V1 V2 SDOT ] { } make be> ] unit-test
{ 0x2094826e } [ [ V0 V1 V2 UDOT ] { } make be> ] unit-test
{ 0x209c824e } [ [ V0 V1 V2 USDOT ] { } make be> ] unit-test
{ 0x20a4824e } [ [ V0 V1 V2 SMMLA ] { } make be> ] unit-test
{ 0x20a4826e } [ [ V0 V1 V2 UMMLA ] { } make be> ] unit-test
{ 0x20ac824e } [ [ V0 V1 V2 USMMLA ] { } make be> ] unit-test
{ 0x20fc426e } [ [ V0 V1 V2 BFDOT ] { } make be> ] unit-test
{ 0x20ec426e } [ [ V0 V1 V2 BFMMLA ] { } make be> ] unit-test
{ 0x2014424e } [ [ V0 V1 V2 FADDHv ] { } make be> ] unit-test
{ 0x2014c24e } [ [ V0 V1 V2 FSUBHv ] { } make be> ] unit-test
{ 0x201c426e } [ [ V0 V1 V2 FMULHv ] { } make be> ] unit-test
{ 0x203c426e } [ [ V0 V1 V2 FDIVHv ] { } make be> ] unit-test
{ 0x200c424e } [ [ V0 V1 V2 FMLAHv ] { } make be> ] unit-test
{ 0x2004c24e } [ [ V0 V1 V2 FMINNMHv ] { } make be> ] unit-test
{ 0x2004424e } [ [ V0 V1 V2 FMAXNMHv ] { } make be> ] unit-test
{ 0x2024424e } [ [ V0 V1 V2 FCMEQHv ] { } make be> ] unit-test
{ 0x2024c26e } [ [ V0 V1 V2 FCMGTHv ] { } make be> ] unit-test
{ 0x2024426e } [ [ V0 V1 V2 FCMGEHv ] { } make be> ] unit-test
{ 0x20f8f96e } [ [ V0 V1 FSQRTHv ] { } make be> ] unit-test
{ 0x2078210e } [ [ V0 V1 FCVTLH ] { } make be> ] unit-test
{ 0x2078214e } [ [ V0 V1 FCVTLH2 ] { } make be> ] unit-test
{ 0x2068210e } [ [ V0 V1 FCVTNH ] { } make be> ] unit-test
{ 0x2068214e } [ [ V0 V1 FCVTNH2 ] { } make be> ] unit-test
{ 0x2068a10e } [ [ V0 V1 BFCVTN ] { } make be> ] unit-test
{ 0x2068a14e } [ [ V0 V1 BFCVTN2 ] { } make be> ] unit-test

! Widening FP conversions take the source arrangement. In particular, 4S
! must encode single-to-double, not half-to-single (Clang reference bytes).
0x2078610e [ V0 V1 4S FCVTL ] test-insn
0x2078614e [ V0 V1 4S FCVTL2 ] test-insn
0x3f7a610e [ V31 V17 2S FCVTL ] test-insn
0x3f7a614e [ V31 V17 4S FCVTL2 ] test-insn
0x2078210e [ V0 V1 4H FCVTL ] test-insn
0x2078214e [ V0 V1 8H FCVTL2 ] test-insn

! Register-indexed Q loads/stores use a 16-byte scale even though size=0.
! Reference bytes assembled independently with Clang for AArch64.
0x2078e23c [ Q0 X1 X2 4 <LSL*> [+] LDR ] test-insn
0x2078a23c [ Q0 X1 X2 4 <LSL*> [+] STR ] test-insn
0x2058e23c [ Q0 X1 W2 4 <UXTW> [+] LDR ] test-insn
0x20d8a23c [ Q0 X1 W2 4 <SXTW> [+] STR ] test-insn
0x2068e23c [ Q0 X1 X2 [+] LDR ] test-insn
0x3f7bbe3c [ Q31 X25 X30 4 <LSL*> [+] STR ] test-insn
[ [ Q0 X1 X2 3 <LSL*> [+] LDR ] { } make ] must-fail
[ [ D0 X1 X2 4 <LSL*> [+] LDR ] { } make ] must-fail

! Baseline integer additions; reference bytes assembled with Clang/AArch64.
0x2000021a [ W0 W1 W2 ADC ] test-insn
0x2000023a [ W0 W1 W2 ADCS ] test-insn
0x2000025a [ W0 W1 W2 SBC ] test-insn
0x2000027a [ W0 W1 W2 SBCS ] test-insn
0xe003015a [ W0 W1 NGC ] test-insn
0xe003017a [ W0 W1 NGCS ] test-insn
0x2004c05a [ W0 W1 REV16 ] test-insn
0x2008c05a [ W0 W1 REV ] test-insn
0x20fc021b [ W0 W1 W2 MNEG ] test-insn
0x202cc21a [ W0 W1 W2 ROR ] test-insn
0x20008113 [ W0 W1 0 ROR ] test-insn
0x20008213 [ W0 W1 W2 0 EXTR ] test-insn
0x207c0033 [ W0 W1 0 32 BFXIL ] test-insn
0x207c0033 [ W0 W1 0 32 BFI ] test-insn
0x2000423a [ W1 W2 0 EQ CCMN ] test-insn
0x2008403a [ W1 0 0 EQ CCMN ] test-insn
0x2000427a [ W1 W2 0 EQ CCMP ] test-insn
0x2008407a [ W1 0 0 EQ CCMP ] test-insn
0x2000029a [ X0 X1 X2 ADC ] test-insn
0x200002ba [ X0 X1 X2 ADCS ] test-insn
0x200002da [ X0 X1 X2 SBC ] test-insn
0x200002fa [ X0 X1 X2 SBCS ] test-insn
0xe00301da [ X0 X1 NGC ] test-insn
0xe00301fa [ X0 X1 NGCS ] test-insn
0x2004c0da [ X0 X1 REV16 ] test-insn
0x200cc0da [ X0 X1 REV ] test-insn
0x2008c0da [ X0 X1 REV32 ] test-insn
0x20fc029b [ X0 X1 X2 MNEG ] test-insn
0x202cc29a [ X0 X1 X2 ROR ] test-insn
0x2000c193 [ X0 X1 0 ROR ] test-insn
0x2000c293 [ X0 X1 X2 0 EXTR ] test-insn
0x20fc40b3 [ X0 X1 0 64 BFXIL ] test-insn
0x20fc40b3 [ X0 X1 0 64 BFI ] test-insn
0x200042ba [ X1 X2 0 EQ CCMN ] test-insn
0x200840ba [ X1 0 0 EQ CCMN ] test-insn
0x200042fa [ X1 X2 0 EQ CCMP ] test-insn
0x200840fa [ X1 0 0 EQ CCMP ] test-insn
0x200c229b [ X0 W1 W2 X3 SMADDL ] test-insn
0x208c229b [ X0 W1 W2 X3 SMSUBL ] test-insn
0x200ca29b [ X0 W1 W2 X3 UMADDL ] test-insn
0x208ca29b [ X0 W1 W2 X3 UMSUBL ] test-insn
0x207c229b [ X0 W1 W2 SMULLs ] test-insn
0x20fc229b [ X0 W1 W2 SMNEGL ] test-insn
0x207ca29b [ X0 W1 W2 UMULLs ] test-insn
0x20fca29b [ X0 W1 W2 UMNEGL ] test-insn

! Boundary fields, ZR/SP semantics, and canonical logical immediates.
0x3e021d1a [ W30 W17 W29 ADC ] test-insn
0xff031ffa [ XZR XZR XZR SBCS ] test-insn
0x207c8213 [ W0 W1 W2 31 EXTR ] test-insn
0x20fcc293 [ X0 X1 X2 63 EXTR ] test-insn
0x207c8113 [ W0 W1 31 ROR ] test-insn
0x20fcc193 [ X0 X1 63 ROR ] test-insn
0x20f87fb3 [ X0 X1 1 63 BFI ] test-insn
0x207c1f33 [ W0 W1 31 1 BFXIL ] test-insn
0x2fc25dfa [ X17 X29 15 GT CCMP ] test-insn
0x251a5f3a [ W17 31 5 NE CCMN ] test-insn
0x3e2e3d9b [ X30 W17 W29 X11 SMADDL ] test-insn
0xffffbf9b [ XZR WZR WZR XZR UMSUBL ] test-insn
0xffd322eb [ XZR SP W2 4 <SXTW> SUBS ] test-insn
0xffd322eb [ SP W2 4 <SXTW> CMP ] test-insn
0xff53222b [ WZR WSP W2 4 <UXTW> ADDS ] test-insn
0xff53222b [ WSP W2 4 <UXTW> CMN ] test-insn
0xff73228b [ SP SP X2 4 <UXTX> ADD ] test-insn
0x20000012 [ W0 W1 1 AND ] test-insn
0x206c1c12 [ W0 W1 -16 AND ] test-insn
0x209c0892 [ X0 X1 18374966859414961920 AND ] test-insn

! Reject operands which would spill into adjacent fields or encode reserved forms.
! Use a builder so failure must come from validation, not emitting outside make.
[ [ W0 W1 X2 ADC ] { } make ] must-fail
[ [ SP X1 X2 SBC ] { } make ] must-fail
[ [ W0 W1 REV32 ] { } make ] must-fail
[ [ X0 SP REV ] { } make ] must-fail
[ [ W0 W1 W2 32 EXTR ] { } make ] must-fail
[ [ X0 X1 X2 64 EXTR ] { } make ] must-fail
[ [ X0 X1 X2 -1 EXTR ] { } make ] must-fail
[ [ X0 X1 W2 0 EXTR ] { } make ] must-fail
[ [ W0 W1 32 ROR ] { } make ] must-fail
[ [ W0 W1 32 0 SBFM ] { } make ] must-fail
[ [ X0 X1 0 64 UBFM ] { } make ] must-fail
[ [ X0 X1 -1 0 BFM ] { } make ] must-fail
[ [ X0 X1 1 0 SBFX ] { } make ] must-fail
[ [ X0 X1 1 0 UBFX ] { } make ] must-fail
[ [ X0 X1 1 0 BFXIL ] { } make ] must-fail
[ [ X0 X1 63 2 BFI ] { } make ] must-fail
[ [ X0 X1 1 0 BFI ] { } make ] must-fail
[ [ X0 X1 X2 1 <ROR> ADD ] { } make ] must-fail
[ [ X0 X1 X2 1 <ROR> SUBS ] { } make ] must-fail
[ [ XZR X1 W2 0 <UXTW> ADD ] { } make ] must-fail
[ [ SP X1 W2 0 <UXTW> ADDS ] { } make ] must-fail
[ [ X0 X1 16 EQ CCMP ] { } make ] must-fail
[ [ X0 X1 0 16 CCMN ] { } make ] must-fail
[ [ X0 32 0 EQ CCMP ] { } make ] must-fail
[ [ X0 -1 0 EQ CCMN ] { } make ] must-fail
[ [ X0 W1 0 EQ CCMP ] { } make ] must-fail
[ [ SP X1 0 EQ CCMN ] { } make ] must-fail
[ [ X0 X1 X2 16 CSEL ] { } make ] must-fail
[ [ X0 X1 W2 X3 SMADDL ] { } make ] must-fail
[ [ W0 W1 W2 X3 SMSUBL ] { } make ] must-fail
[ [ X0 W1 W2 W3 UMADDL ] { } make ] must-fail
[ [ X0 WSP W2 X3 UMSUBL ] { } make ] must-fail
[ [ 0 16 B.cond ] { } make ] must-fail
[ [ W0 32 0 TBZ ] { } make ] must-fail
[ [ X0 64 0 TBNZ ] { } make ] must-fail
[ [ X0 -1 0 TBZ ] { } make ] must-fail
[ [ X0 X1 X2 5 <LSL*> ADD ] { } make ] must-fail
[ [ X0 X1 X2 -1 <LSL*> SUB ] { } make ] must-fail
0x20fcdf88 [ W0 X1 LDAR ] test-insn
0x20fc9f88 [ W0 X1 STLR ] test-insn
0x207c5f88 [ W0 X1 LDXR ] test-insn
0x20fc5f88 [ W0 X1 LDAXR ] test-insn
0x207c0288 [ W2 W0 X1 STXR ] test-insn
0x20fc0288 [ W2 W0 X1 STLXR ] test-insn
0x20fcdf08 [ W0 X1 LDARB ] test-insn
0x20fc9f08 [ W0 X1 STLRB ] test-insn
0x207c5f08 [ W0 X1 LDXRB ] test-insn
0x20fc5f08 [ W0 X1 LDAXRB ] test-insn
0x207c0208 [ W2 W0 X1 STXRB ] test-insn
0x20fc0208 [ W2 W0 X1 STLXRB ] test-insn
0x20fcdf48 [ W0 X1 LDARH ] test-insn
0x20fc9f48 [ W0 X1 STLRH ] test-insn
0x207c5f48 [ W0 X1 LDXRH ] test-insn
0x20fc5f48 [ W0 X1 LDAXRH ] test-insn
0x207c0248 [ W2 W0 X1 STXRH ] test-insn
0x20fc0248 [ W2 W0 X1 STLXRH ] test-insn
0x20fcdfc8 [ X0 X1 LDAR ] test-insn
0x20fc9fc8 [ X0 X1 STLR ] test-insn
0x207c5fc8 [ X0 X1 LDXR ] test-insn
0x20fc5fc8 [ X0 X1 LDAXR ] test-insn
0xbf3003d5 [ 0 DMB ] test-insn
0xbf3103d5 [ 1 DMB ] test-insn
0xbf3203d5 [ 2 DMB ] test-insn
0xbf3303d5 [ 3 DMB ] test-insn
0xbf3403d5 [ 4 DMB ] test-insn
0xbf3503d5 [ 5 DMB ] test-insn
0xbf3603d5 [ 6 DMB ] test-insn
0xbf3703d5 [ 7 DMB ] test-insn
0xbf3803d5 [ 8 DMB ] test-insn
0xbf3903d5 [ 9 DMB ] test-insn
0x9f3003d5 [ 0 DSB ] test-insn
0x9f3103d5 [ 1 DSB ] test-insn
0x9f3203d5 [ 2 DSB ] test-insn
0x9f3303d5 [ 3 DSB ] test-insn
0x9f3403d5 [ 4 DSB ] test-insn
0x9f3503d5 [ 5 DSB ] test-insn
0x9f3603d5 [ 6 DSB ] test-insn
0x9f3703d5 [ 7 DSB ] test-insn
0x9f3803d5 [ 8 DSB ] test-insn
0x9f3903d5 [ 9 DSB ] test-insn
0xdf3f03d5 [ ISB ] test-insn
0x5f3f03d5 [ CLREX ] test-insn
0x200c021f [ S0 S1 S2 S3 FMADDs ] test-insn
0x208c021f [ S0 S1 S2 S3 FMSUBs ] test-insn
0x200c221f [ S0 S1 S2 S3 FNMADDs ] test-insn
0x208c221f [ S0 S1 S2 S3 FNMSUBs ] test-insn
0x200c421f [ D0 D1 D2 D3 FMADDs ] test-insn
0x208c421f [ D0 D1 D2 D3 FMSUBs ] test-insn
0x200c621f [ D0 D1 D2 D3 FNMADDs ] test-insn
0x208c621f [ D0 D1 D2 D3 FNMSUBs ] test-insn

! Type/width/address validation and constrained-unpredictable store overlap.
[ [ X0 W1 LDAR ] { } make ] must-fail
[ [ X0 XZR LDAR ] { } make ] must-fail
[ [ SP X1 LDAR ] { } make ] must-fail
[ [ S0 X1 STLR ] { } make ] must-fail
[ [ X0 X1 LDARB ] { } make ] must-fail
[ [ WSP X1 LDARH ] { } make ] must-fail
[ [ X0 X1 STLRB ] { } make ] must-fail
[ [ W0 WSP STLRH ] { } make ] must-fail
[ [ X0 X1 LDXRB ] { } make ] must-fail
[ [ X0 X1 LDAXRH ] { } make ] must-fail
[ [ X0 X1 X2 STXR ] { } make ] must-fail
[ [ W0 X0 X1 STXR ] { } make ] must-fail
[ [ W0 X1 X0 STLXR ] { } make ] must-fail
[ [ WZR XZR SP STXR ] { } make ] must-fail
[ [ W0 X1 SP STXRB ] { } make ] must-fail
[ [ W0 W1 XZR STLXRH ] { } make ] must-fail
[ [ -1 DMB ] { } make ] must-fail
[ [ 16 DSB ] { } make ] must-fail
[ [ S0 D1 S2 S3 FMADDs ] { } make ] must-fail
[ [ X0 X1 X2 X3 FMSUBs ] { } make ] must-fail
[ [ Q0 Q1 Q2 Q3 FNMADDs ] { } make ] must-fail

! Clang oracle: reference/arm64-gap-reduced-ffi-20260908/moves.s.
! Scalar small-float aggregate accesses retain their two-byte width.
USE: cpu.architecture
0xe007407d [ V0 SP 2 [+] half-rep LDR* ] test-insn
0xe007407d [ V0 SP 2 [+] bfloat-rep LDR* ] test-insn
0xe10f007d [ V1 SP 6 [+] half-rep STR* ] test-insn
0xe10f007d [ V1 SP 6 [+] bfloat-rep STR* ] test-insn
