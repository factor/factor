! Copyright (C) 2024 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays cpu.arm.64.assembler endian kernel make tools.test
;
FROM: cpu.arm.64.assembler => B ;
IN: cpu.arm.64.assembler.tests

: test-insn ( n quot -- ) [ 1array ] dip '[ _ { } make le> ] unit-test ;

0xa9bf4ff2 [ X18 X19 SP -16 [pre] STP ] test-insn
0xf81f0ffe [ X30 SP -16 [pre] STR ] test-insn
0x910003fd [ FP SP MOV ] test-insn
0xf90007f4 [ CTX SP 8 [+] STR ] test-insn
0x58000053 [ VM 2 insns LDR ] test-insn
0x14000003 [ 3 insns B ] test-insn
0xaa0003e1 [ arg2 arg1 MOV ] test-insn
0xd27ced4a [ ds-0 ds-0 -16 EOR ] test-insn
