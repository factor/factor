USING: arrays cpu.architecture cpu.arm.64 cpu.arm.64.assembler cpu.arm.64.assembler.registers endian kernel make tools.test namespaces sequences prettyprint system vocabs.loader locals math ;
IN: arm64-gap-isa.encodings
f restartable-tests? set-global
<< "cpu.arm.64.assembler" reload "cpu.arm.64" reload >>
SYMBOL: mismatches
0 mismatches set
:: check-insn ( expected quot -- ) [ quot call( -- ) ] { } make be> expected = [ quot . mismatches [ 1 + ] change ] unless ;
! ldar W0, [X1]
0x20fcdf88 [ W0 X1 LDAR ] check-insn
! stlr W0, [X1]
0x20fc9f88 [ W0 X1 STLR ] check-insn
! ldxr W0, [X1]
0x207c5f88 [ W0 X1 LDXR ] check-insn
! ldaxr W0, [X1]
0x20fc5f88 [ W0 X1 LDAXR ] check-insn
! stxr W2, W0, [X1]
0x207c0288 [ W2 W0 X1 STXR ] check-insn
! stlxr W2, W0, [X1]
0x20fc0288 [ W2 W0 X1 STLXR ] check-insn
! ldarb W0, [X1]
0x20fcdf08 [ W0 X1 LDARB ] check-insn
! stlrb W0, [X1]
0x20fc9f08 [ W0 X1 STLRB ] check-insn
! ldxrb W0, [X1]
0x207c5f08 [ W0 X1 LDXRB ] check-insn
! ldaxrb W0, [X1]
0x20fc5f08 [ W0 X1 LDAXRB ] check-insn
! stxrb W2, W0, [X1]
0x207c0208 [ W2 W0 X1 STXRB ] check-insn
! stlxrb W2, W0, [X1]
0x20fc0208 [ W2 W0 X1 STLXRB ] check-insn
! ldarh W0, [X1]
0x20fcdf48 [ W0 X1 LDARH ] check-insn
! stlrh W0, [X1]
0x20fc9f48 [ W0 X1 STLRH ] check-insn
! ldxrh W0, [X1]
0x207c5f48 [ W0 X1 LDXRH ] check-insn
! ldaxrh W0, [X1]
0x20fc5f48 [ W0 X1 LDAXRH ] check-insn
! stxrh W2, W0, [X1]
0x207c0248 [ W2 W0 X1 STXRH ] check-insn
! stlxrh W2, W0, [X1]
0x20fc0248 [ W2 W0 X1 STLXRH ] check-insn
! ldar W30, [X17]
0x3efedf88 [ W30 X17 LDAR ] check-insn
! stlr W30, [X17]
0x3efe9f88 [ W30 X17 STLR ] check-insn
! ldxr W30, [X17]
0x3e7e5f88 [ W30 X17 LDXR ] check-insn
! ldaxr W30, [X17]
0x3efe5f88 [ W30 X17 LDAXR ] check-insn
! stxr W29, W30, [X17]
0x3e7e1d88 [ W29 W30 X17 STXR ] check-insn
! stlxr W29, W30, [X17]
0x3efe1d88 [ W29 W30 X17 STLXR ] check-insn
! ldarb W30, [X17]
0x3efedf08 [ W30 X17 LDARB ] check-insn
! stlrb W30, [X17]
0x3efe9f08 [ W30 X17 STLRB ] check-insn
! ldxrb W30, [X17]
0x3e7e5f08 [ W30 X17 LDXRB ] check-insn
! ldaxrb W30, [X17]
0x3efe5f08 [ W30 X17 LDAXRB ] check-insn
! stxrb W29, W30, [X17]
0x3e7e1d08 [ W29 W30 X17 STXRB ] check-insn
! stlxrb W29, W30, [X17]
0x3efe1d08 [ W29 W30 X17 STLXRB ] check-insn
! ldarh W30, [X17]
0x3efedf48 [ W30 X17 LDARH ] check-insn
! stlrh W30, [X17]
0x3efe9f48 [ W30 X17 STLRH ] check-insn
! ldxrh W30, [X17]
0x3e7e5f48 [ W30 X17 LDXRH ] check-insn
! ldaxrh W30, [X17]
0x3efe5f48 [ W30 X17 LDAXRH ] check-insn
! stxrh W29, W30, [X17]
0x3e7e1d48 [ W29 W30 X17 STXRH ] check-insn
! stlxrh W29, W30, [X17]
0x3efe1d48 [ W29 W30 X17 STLXRH ] check-insn
! ldar WZR, [SP]
0xffffdf88 [ WZR SP LDAR ] check-insn
! stlr WZR, [SP]
0xffff9f88 [ WZR SP STLR ] check-insn
! ldxr WZR, [SP]
0xff7f5f88 [ WZR SP LDXR ] check-insn
! ldaxr WZR, [SP]
0xffff5f88 [ WZR SP LDAXR ] check-insn
! stxr W29, WZR, [SP]
0xff7f1d88 [ W29 WZR SP STXR ] check-insn
! stlxr W29, WZR, [SP]
0xffff1d88 [ W29 WZR SP STLXR ] check-insn
! ldarb WZR, [SP]
0xffffdf08 [ WZR SP LDARB ] check-insn
! stlrb WZR, [SP]
0xffff9f08 [ WZR SP STLRB ] check-insn
! ldxrb WZR, [SP]
0xff7f5f08 [ WZR SP LDXRB ] check-insn
! ldaxrb WZR, [SP]
0xffff5f08 [ WZR SP LDAXRB ] check-insn
! stxrb W29, WZR, [SP]
0xff7f1d08 [ W29 WZR SP STXRB ] check-insn
! stlxrb W29, WZR, [SP]
0xffff1d08 [ W29 WZR SP STLXRB ] check-insn
! ldarh WZR, [SP]
0xffffdf48 [ WZR SP LDARH ] check-insn
! stlrh WZR, [SP]
0xffff9f48 [ WZR SP STLRH ] check-insn
! ldxrh WZR, [SP]
0xff7f5f48 [ WZR SP LDXRH ] check-insn
! ldaxrh WZR, [SP]
0xffff5f48 [ WZR SP LDAXRH ] check-insn
! stxrh W29, WZR, [SP]
0xff7f1d48 [ W29 WZR SP STXRH ] check-insn
! stlxrh W29, WZR, [SP]
0xffff1d48 [ W29 WZR SP STLXRH ] check-insn
! ldar X0, [X1]
0x20fcdfc8 [ X0 X1 LDAR ] check-insn
! stlr X0, [X1]
0x20fc9fc8 [ X0 X1 STLR ] check-insn
! ldxr X0, [X1]
0x207c5fc8 [ X0 X1 LDXR ] check-insn
! ldaxr X0, [X1]
0x20fc5fc8 [ X0 X1 LDAXR ] check-insn
! stxr W2, X0, [X1]
0x207c02c8 [ W2 X0 X1 STXR ] check-insn
! stlxr W2, X0, [X1]
0x20fc02c8 [ W2 X0 X1 STLXR ] check-insn
! ldar X30, [X17]
0x3efedfc8 [ X30 X17 LDAR ] check-insn
! stlr X30, [X17]
0x3efe9fc8 [ X30 X17 STLR ] check-insn
! ldxr X30, [X17]
0x3e7e5fc8 [ X30 X17 LDXR ] check-insn
! ldaxr X30, [X17]
0x3efe5fc8 [ X30 X17 LDAXR ] check-insn
! stxr W29, X30, [X17]
0x3e7e1dc8 [ W29 X30 X17 STXR ] check-insn
! stlxr W29, X30, [X17]
0x3efe1dc8 [ W29 X30 X17 STLXR ] check-insn
! ldar XZR, [SP]
0xffffdfc8 [ XZR SP LDAR ] check-insn
! stlr XZR, [SP]
0xffff9fc8 [ XZR SP STLR ] check-insn
! ldxr XZR, [SP]
0xff7f5fc8 [ XZR SP LDXR ] check-insn
! ldaxr XZR, [SP]
0xffff5fc8 [ XZR SP LDAXR ] check-insn
! stxr W29, XZR, [SP]
0xff7f1dc8 [ W29 XZR SP STXR ] check-insn
! stlxr W29, XZR, [SP]
0xffff1dc8 [ W29 XZR SP STLXR ] check-insn
! stxr wzr, x0, [sp]
0xe07f1fc8 [ WZR X0 SP STXR ] check-insn
! stlxr wzr, x0, [sp]
0xe0ff1fc8 [ WZR X0 SP STLXR ] check-insn
! dmb #0
0xbf3003d5 [ 0 DMB ] check-insn
! dmb #1
0xbf3103d5 [ 1 DMB ] check-insn
! dmb #2
0xbf3203d5 [ 2 DMB ] check-insn
! dmb #3
0xbf3303d5 [ 3 DMB ] check-insn
! dmb #4
0xbf3403d5 [ 4 DMB ] check-insn
! dmb #5
0xbf3503d5 [ 5 DMB ] check-insn
! dmb #6
0xbf3603d5 [ 6 DMB ] check-insn
! dmb #7
0xbf3703d5 [ 7 DMB ] check-insn
! dmb #8
0xbf3803d5 [ 8 DMB ] check-insn
! dmb #9
0xbf3903d5 [ 9 DMB ] check-insn
! dmb #10
0xbf3a03d5 [ 10 DMB ] check-insn
! dmb #11
0xbf3b03d5 [ 11 DMB ] check-insn
! dmb #12
0xbf3c03d5 [ 12 DMB ] check-insn
! dmb #13
0xbf3d03d5 [ 13 DMB ] check-insn
! dmb #14
0xbf3e03d5 [ 14 DMB ] check-insn
! dmb #15
0xbf3f03d5 [ 15 DMB ] check-insn
! dsb #0
0x9f3003d5 [ 0 DSB ] check-insn
! dsb #1
0x9f3103d5 [ 1 DSB ] check-insn
! dsb #2
0x9f3203d5 [ 2 DSB ] check-insn
! dsb #3
0x9f3303d5 [ 3 DSB ] check-insn
! dsb #4
0x9f3403d5 [ 4 DSB ] check-insn
! dsb #5
0x9f3503d5 [ 5 DSB ] check-insn
! dsb #6
0x9f3603d5 [ 6 DSB ] check-insn
! dsb #7
0x9f3703d5 [ 7 DSB ] check-insn
! dsb #8
0x9f3803d5 [ 8 DSB ] check-insn
! dsb #9
0x9f3903d5 [ 9 DSB ] check-insn
! dsb #10
0x9f3a03d5 [ 10 DSB ] check-insn
! dsb #11
0x9f3b03d5 [ 11 DSB ] check-insn
! dsb #12
0x9f3c03d5 [ 12 DSB ] check-insn
! dsb #13
0x9f3d03d5 [ 13 DSB ] check-insn
! dsb #14
0x9f3e03d5 [ 14 DSB ] check-insn
! dsb #15
0x9f3f03d5 [ 15 DSB ] check-insn
! isb
0xdf3f03d5 [ ISB ] check-insn
! clrex
0x5f3f03d5 [ CLREX ] check-insn
! fmadd S0, S1, S2, S3
0x200c021f [ S0 S1 S2 S3 FMADDs ] check-insn
! fmsub S0, S1, S2, S3
0x208c021f [ S0 S1 S2 S3 FMSUBs ] check-insn
! fnmadd S0, S1, S2, S3
0x200c221f [ S0 S1 S2 S3 FNMADDs ] check-insn
! fnmsub S0, S1, S2, S3
0x208c221f [ S0 S1 S2 S3 FNMSUBs ] check-insn
! fmadd S31, S31, S31, S31
0xff7f1f1f [ S31 S31 S31 S31 FMADDs ] check-insn
! fmsub S31, S31, S31, S31
0xffff1f1f [ S31 S31 S31 S31 FMSUBs ] check-insn
! fnmadd S31, S31, S31, S31
0xff7f3f1f [ S31 S31 S31 S31 FNMADDs ] check-insn
! fnmsub S31, S31, S31, S31
0xffff3f1f [ S31 S31 S31 S31 FNMSUBs ] check-insn
! fmadd S30, S17, S29, S11
0x3e2e1d1f [ S30 S17 S29 S11 FMADDs ] check-insn
! fmsub S30, S17, S29, S11
0x3eae1d1f [ S30 S17 S29 S11 FMSUBs ] check-insn
! fnmadd S30, S17, S29, S11
0x3e2e3d1f [ S30 S17 S29 S11 FNMADDs ] check-insn
! fnmsub S30, S17, S29, S11
0x3eae3d1f [ S30 S17 S29 S11 FNMSUBs ] check-insn
! fmadd D0, D1, D2, D3
0x200c421f [ D0 D1 D2 D3 FMADDs ] check-insn
! fmsub D0, D1, D2, D3
0x208c421f [ D0 D1 D2 D3 FMSUBs ] check-insn
! fnmadd D0, D1, D2, D3
0x200c621f [ D0 D1 D2 D3 FNMADDs ] check-insn
! fnmsub D0, D1, D2, D3
0x208c621f [ D0 D1 D2 D3 FNMSUBs ] check-insn
! fmadd D31, D31, D31, D31
0xff7f5f1f [ D31 D31 D31 D31 FMADDs ] check-insn
! fmsub D31, D31, D31, D31
0xffff5f1f [ D31 D31 D31 D31 FMSUBs ] check-insn
! fnmadd D31, D31, D31, D31
0xff7f7f1f [ D31 D31 D31 D31 FNMADDs ] check-insn
! fnmsub D31, D31, D31, D31
0xffff7f1f [ D31 D31 D31 D31 FNMSUBs ] check-insn
! fmadd D30, D17, D29, D11
0x3e2e5d1f [ D30 D17 D29 D11 FMADDs ] check-insn
! fmsub D30, D17, D29, D11
0x3eae5d1f [ D30 D17 D29 D11 FMSUBs ] check-insn
! fnmadd D30, D17, D29, D11
0x3e2e7d1f [ D30 D17 D29 D11 FNMADDs ] check-insn
! fnmsub D30, D17, D29, D11
0x3eae7d1f [ D30 D17 D29 D11 FNMSUBs ] check-insn
! add x0, x1, x1, lsl #1
0x2004018b [ X0 X1 3 %mul-imm ] check-insn
! add x0, x1, x1, lsl #2
0x2008018b [ X0 X1 5 %mul-imm ] check-insn
! add x0, x1, x1, lsl #3
0x200c018b [ X0 X1 9 %mul-imm ] check-insn
! add x0, x1, x1, lsl #4
0x2010018b [ X0 X1 17 %mul-imm ] check-insn
! add x0, x1, x1, lsl #5
0x2014018b [ X0 X1 33 %mul-imm ] check-insn
! add x0, x1, x1, lsl #6
0x2018018b [ X0 X1 65 %mul-imm ] check-insn
! add x0, x1, x1, lsl #7
0x201c018b [ X0 X1 129 %mul-imm ] check-insn
! add x0, x1, x1, lsl #8
0x2020018b [ X0 X1 257 %mul-imm ] check-insn
! add x0, x1, x1, lsl #9
0x2024018b [ X0 X1 513 %mul-imm ] check-insn
! add x0, x1, x1, lsl #10
0x2028018b [ X0 X1 1025 %mul-imm ] check-insn
! add x0, x1, x1, lsl #11
0x202c018b [ X0 X1 2049 %mul-imm ] check-insn
! add x0, x0, x0, lsl #1
0x0004008b [ X0 X0 3 %mul-imm ] check-insn
! add x0, x0, x0, lsl #2
0x0008008b [ X0 X0 5 %mul-imm ] check-insn
! add x0, x0, x0, lsl #3
0x000c008b [ X0 X0 9 %mul-imm ] check-insn
! add x0, x0, x0, lsl #4
0x0010008b [ X0 X0 17 %mul-imm ] check-insn
! add x0, x0, x0, lsl #5
0x0014008b [ X0 X0 33 %mul-imm ] check-insn
! add x0, x0, x0, lsl #6
0x0018008b [ X0 X0 65 %mul-imm ] check-insn
! add x0, x0, x0, lsl #7
0x001c008b [ X0 X0 129 %mul-imm ] check-insn
! add x0, x0, x0, lsl #8
0x0020008b [ X0 X0 257 %mul-imm ] check-insn
! add x0, x0, x0, lsl #9
0x0024008b [ X0 X0 513 %mul-imm ] check-insn
! add x0, x0, x0, lsl #10
0x0028008b [ X0 X0 1025 %mul-imm ] check-insn
! add x0, x0, x0, lsl #11
0x002c008b [ X0 X0 2049 %mul-imm ] check-insn
! add x30, x17, x17, lsl #1
0x3e06118b [ X30 X17 3 %mul-imm ] check-insn
! add x30, x17, x17, lsl #2
0x3e0a118b [ X30 X17 5 %mul-imm ] check-insn
! add x30, x17, x17, lsl #3
0x3e0e118b [ X30 X17 9 %mul-imm ] check-insn
! add x30, x17, x17, lsl #4
0x3e12118b [ X30 X17 17 %mul-imm ] check-insn
! add x30, x17, x17, lsl #5
0x3e16118b [ X30 X17 33 %mul-imm ] check-insn
! add x30, x17, x17, lsl #6
0x3e1a118b [ X30 X17 65 %mul-imm ] check-insn
! add x30, x17, x17, lsl #7
0x3e1e118b [ X30 X17 129 %mul-imm ] check-insn
! add x30, x17, x17, lsl #8
0x3e22118b [ X30 X17 257 %mul-imm ] check-insn
! add x30, x17, x17, lsl #9
0x3e26118b [ X30 X17 513 %mul-imm ] check-insn
! add x30, x17, x17, lsl #10
0x3e2a118b [ X30 X17 1025 %mul-imm ] check-insn
! add x30, x17, x17, lsl #11
0x3e2e118b [ X30 X17 2049 %mul-imm ] check-insn
! mneg x0, x1, x2
0x20fc029b [ X0 X1 X2 %mneg ] check-insn
! mneg x0, x0, x1
0x00fc019b [ X0 X0 X1 %mneg ] check-insn
! mneg x0, x1, x0
0x20fc009b [ X0 X1 X0 %mneg ] check-insn
mismatches get .
mismatches get zero? 0 1 ? exit
