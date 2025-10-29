! Copyright (C) 2024 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays cpu.arm.64.assembler endian kernel make tools.test
;
FROM: cpu.arm.64.assembler => B ;
IN: cpu.arm.64.assembler.tests

: test-insn ( n quot -- ) [ 1array ] dip '[ _ { } make be> ] unit-test ;

0xb7000010 [ PIC-TAIL 5 insns ADR ] test-insn
0x41190091 [ arg2 ds-0 6 ADD ] test-insn
0xce01098b [ cache dup temp ADD ] test-insn
0x4a118b8b [ ds-0 dup ds-1 4 <ASR> ADD ] test-insn
0x0a0001ab [ ds-0 arg1 arg2 ADDS ] test-insn
0xffbb314e [ fp-temp dup 0 ADDV ] test-insn
0x6bed7c92 [ ds-1 dup -16 AND ] test-insn
0x6a010a8a [ ds-0 ds-1 ds-0 AND ] test-insn
0xcf0d40f2 [ type obj 15 ANDS ] test-insn
0x00fc4493 [ arg1 dup 4 ASR ] test-insn
0x6f29ca9a [ temp2 ds-1 ds-0 ASR ] test-insn
0x03000014 [ 3 insns B ] test-insn
0x60000054 [ 3 insns BEQ ] test-insn
0x47000054 [ 2 insns BVC ] test-insn
0x46000054 [ 2 insns BVS ] test-insn
0xa1000054 [ 5 insns BNE ] test-insn
0x40033fd6 [ CACHE-MISS BLR ] test-insn
0x00001fd6 [ RETURN BR ] test-insn
0x5f0109eb [ ds-0 temp CMP ] test-insn
0x3f1d00f1 [ temp 7 CMP ] test-insn
0x3ffd8aeb [ temp ds-0 63 <ASR> CMP ] test-insn
0xff5b204e [ fp-temp dup CNTv ] test-insn
0xca418f9a [ ds-0 temp1 temp2 MI CSEL ] test-insn
0x4aed7cd2 [ ds-0 dup -16 EOR ] test-insn
0x6a010aca [ ds-0 ds-1 ds-0 EOR ] test-insn
0xa086ffa9 [ arg1 arg2 DS -8 [pre] LDP ] test-insn
0xabaa7fa9 [ ds-1 ds-0 DS -8 [+] LDP ] test-insn
0xfd7bc1a8 [ FP LR SP 16 [post] LDP ] test-insn
0x800640f9 [ arg1 CTX 8 [+] LDR ] test-insn
0xa0865ff8 [ arg1 DS -8 [post] LDR ] test-insn
0x290340f9 [ temp MEGA-HITS [] LDR ] test-insn
0x207961f8 [ X0 temp X1 3 <LSL*> [+] LDR ] test-insn
0x49000058 [ temp 2 insns LDR ] test-insn
0x4a554039 [ ds-0 dup 21 [+] LDRB ] test-insn
0xae0240f8 [ obj DS [] LDUR ] test-insn
0xceed7cd3 [ quotient dup 4 LSL ] test-insn
0x6e21ca9a [ temp1 ds-1 ds-0 LSL ] test-insn
0x42fc44d3 [ arg3 dup 4 LSR ] test-insn
0xf40300aa [ CTX RETURN MOV ] test-insn
0x290080d2 [ temp 1 MOV ] test-insn
0x00423bd5 [ X0 NZCV MRS ] test-insn
0x3f441bd5 [ FPSR XZR MSR ] test-insn
0x00421bd5 [ NZCV X0 MSR ] test-insn
0x4fad0e9b [ remainder ds-0 quotient ds-1 MSUB ] test-insn
0x0a7c019b [ ds-0 arg1 arg2 MUL ] test-insn
0xea030aeb [ ds-0 dup NEGS ] test-insn
0x4a010baa [ ds-0 dup ds-1 ORR ] test-insn
0xc0035fd6 [ RET ] test-insn
0x6e0dca9a [ quotient ds-1 ds-0 SDIV ] test-insn
0x097c419b [ temp arg1 arg2 SMULH ] test-insn
0xaaae3fa9 [ ds-0 ds-1 DS -8 [+] STP ] test-insn
0xfd27bfa9 [ FP temp SP -16 [pre] STP ] test-insn
0xf40700f9 [ CTX SP 8 [+] STR ] test-insn
0xaa8e00f8 [ ds-0 DS 8 [pre] STR ] test-insn
0xaf0200f9 [ remainder DS [] STR ] test-insn
0xff8300d1 [ SP dup 32 SUB ] test-insn
0x000002cb [ arg1 dup arg3 SUB ] test-insn
0xd6068acb [ RS dup ds-0 1 <ASR> SUB ] test-insn
0x0a0001eb [ ds-0 arg1 arg2 SUBS ] test-insn
0x41002836 [ X1 5 2 insns TBZ ] test-insn
0x5f0d40f2 [ ds-0 15 TST ] test-insn
0xcf0d7cd3 [ type obj 4 4 UBFIZ ] test-insn
