! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Classic SH3/SH4. Branch callers supply a byte displacement from the
! instruction address. Delay slots are emitted explicitly by the caller.
USING: endian kernel layouts locals make math math.bitwise namespaces ;
IN: cpu.sh.assembler
SYMBOL: sh-big-endian?
SYMBOL: sh-soft-abi?
ERROR: invalid-sh-register register ;
ERROR: invalid-sh-immediate value width ;
ERROR: invalid-sh-displacement value ;
:: register-number ( reg -- n )
    reg 0 >= reg 16 < and [ reg ] [ reg invalid-sh-register ] if ;
:: signed-immediate ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-sh-immediate ] if ;
:: unsigned-immediate ( value width -- bits )
    value 0 >= value width bits value = and [ value ]
    [ value width invalid-sh-immediate ] if ;
: emit-word ( n -- ) 2 sh-big-endian? get [ >be ] [ >le ] if % ;
: emit-long ( n -- ) 4 sh-big-endian? get [ >be ] [ >le ] if % ;
:: rr ( src dst opcode -- )
    dst register-number 8 shift src register-number 4 shift bitor opcode bitor emit-word ;
:: rn ( dst opcode -- ) dst register-number 8 shift opcode bitor emit-word ;
:: ri ( value dst opcode -- )
    dst register-number 8 shift value 8 signed-immediate bitor opcode bitor emit-word ;
: NOP ( -- ) 0x0009 emit-word ;
: RTS ( -- ) 0x000b emit-word ;
: MOV ( src dst -- ) 0x6003 rr ;
: MOVI ( value dst -- ) 0xe000 ri ;
: MOV.L ( src dst -- ) 0x6002 rr ;
: MOV.B ( src dst -- ) 0x6000 rr ;
: MOV.W ( src dst -- ) 0x6001 rr ;
: STORE.L ( src dst -- ) 0x2002 rr ;
: STORE.B ( src dst -- ) 0x2000 rr ;
: STORE.W ( src dst -- ) 0x2001 rr ;
: PUSH.L ( src dst -- ) 0x2006 rr ;
: POP.L ( src dst -- ) 0x6006 rr ;
: ADD ( src dst -- ) 0x300c rr ;
: ADDI ( value dst -- ) 0x7000 ri ;
: SUB ( src dst -- ) 0x3008 rr ;
: ADDC ( src dst -- ) 0x300e rr ;
: SUBC ( src dst -- ) 0x300a rr ;
: ADDV ( src dst -- ) 0x300f rr ;
: SUBV ( src dst -- ) 0x300b rr ;
: AND ( src dst -- ) 0x2009 rr ;
: OR ( src dst -- ) 0x200b rr ;
: XOR ( src dst -- ) 0x200a rr ;
: NOT ( src dst -- ) 0x6007 rr ;
: NEG ( src dst -- ) 0x600b rr ;
: NEGC ( src dst -- ) 0x600a rr ;
: TST ( src dst -- ) 0x2008 rr ;
: CMP/EQ ( src dst -- ) 0x3000 rr ;
: CMP/GT ( src dst -- ) 0x3007 rr ;
: CMP/GE ( src dst -- ) 0x3003 rr ;
: CMP/HI ( src dst -- ) 0x3006 rr ;
: CMP/HS ( src dst -- ) 0x3002 rr ;
: SHAD ( src dst -- ) 0x400c rr ;
: SHLD ( src dst -- ) 0x400d rr ;
: MUL.L ( src dst -- ) 0x0007 rr ;
: DMULS.L ( src dst -- ) 0x300d rr ;
: DMULU.L ( src dst -- ) 0x3005 rr ;
: EXTU.B ( src dst -- ) 0x600c rr ;
: EXTU.W ( src dst -- ) 0x600d rr ;
: EXTS.B ( src dst -- ) 0x600e rr ;
: EXTS.W ( src dst -- ) 0x600f rr ;
: SWAP.W ( src dst -- ) 0x6009 rr ;
: MOVT ( dst -- ) 0x0029 rn ;
: JMP ( dst -- ) 0x402b rn ;
: JSR ( dst -- ) 0x400b rn ;
: TAS.B ( dst -- ) 0x401b rn ;
: SHLL ( dst -- ) 0x4000 rn ;
: SHLR ( dst -- ) 0x4001 rn ;
: SHAR ( dst -- ) 0x4021 rn ;
: DT ( dst -- ) 0x4010 rn ;
: STS-PR ( dst -- ) 0x002a rn ;
: LDS-PR ( src -- ) 0x402a rn ;
: LDS-MACL ( src -- ) 0x401a rn ;
: LDS-MACH ( src -- ) 0x400a rn ;
: STS-MACL ( dst -- ) 0x001a rn ;
: STS-MACH ( dst -- ) 0x000a rn ;
: STS-FPSCR ( dst -- ) 0x006a rn ;
: LDS-FPSCR ( src -- ) 0x406a rn ;
: STS-FPUL ( dst -- ) 0x005a rn ;
: LDS-FPUL ( src -- ) 0x405a rn ;
: STS.L-PR ( dst -- ) 0x4022 rn ;
: LDS.L-PR ( src -- ) 0x4026 rn ;
:: branch-bits ( displacement width -- bits )
    displacement 1 bitand zero? [ displacement 4 - 2 /i width signed-immediate ]
    [ displacement invalid-sh-displacement ] if ;
:: branch ( displacement width opcode -- )
    displacement width branch-bits opcode bitor emit-word ;
: BRA ( displacement -- ) 12 0xa000 branch ;
: BSR ( displacement -- ) 12 0xb000 branch ;
: BT ( displacement -- ) 8 0x8900 branch ;
: BF ( displacement -- ) 8 0x8b00 branch ;
: BT/S ( displacement -- ) 8 0x8d00 branch ;
: BF/S ( displacement -- ) 8 0x8f00 branch ;
:: LOAD-PC.L ( displacement dst -- )
    displacement 2 bits zero? [ ] [ displacement invalid-sh-displacement ] if
    displacement 4 /i 8 unsigned-immediate dst register-number 8 shift bitor
    0xd000 bitor emit-word ;
:: LOAD-DISP.L ( src displacement dst -- )
    displacement 2 bits zero? [ ] [ displacement invalid-sh-displacement ] if
    displacement 4 /i 4 unsigned-immediate :> disp
    dst register-number 8 shift src register-number 4 shift bitor disp bitor 0x5000 bitor emit-word ;
:: STORE-DISP.L ( src dst displacement -- )
    displacement 2 bits zero? [ ] [ displacement invalid-sh-displacement ] if
    displacement 4 /i 4 unsigned-immediate :> disp
    dst register-number 8 shift src register-number 4 shift bitor disp bitor 0x1000 bitor emit-word ;
! SH4 FPU encodings. FPSCR.PR/SZ/FR and even DR register validation
! belong to the emitter selecting single vs double precision operations.
: FMOV ( src dst -- ) 0xf00c rr ;
: FMOV.LOAD ( src dst -- ) 0xf008 rr ;
: FMOV.STORE ( src dst -- ) 0xf00a rr ;
: FADD ( src dst -- ) 0xf000 rr ;
: FSUB ( src dst -- ) 0xf001 rr ;
: FMUL ( src dst -- ) 0xf002 rr ;
: FDIV ( src dst -- ) 0xf003 rr ;
: FCMP/EQ ( src dst -- ) 0xf004 rr ;
: FCMP/GT ( src dst -- ) 0xf005 rr ;
: FNEG ( dst -- ) 0xf04d rn ;
: FSQRT ( dst -- ) 0xf06d rn ;
: FLOAT ( dst -- ) 0xf02d rn ;
: FTRC ( src -- ) 0xf03d rn ;
: FSTS ( dst -- ) 0xf00d rn ;
: FLDS ( src -- ) 0xf01d rn ;
: FCNVSD ( dst -- ) 0xf0ad rn ;
: FCNVDS ( src -- ) 0xf0bd rn ;
: FSCHG ( -- ) 0xf3fd emit-word ;
: FRCHG ( -- ) 0xfbfd emit-word ;
