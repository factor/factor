! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.codegen.relocation compiler.constants
cpu.alpha.64.assembler.registers endian kernel locals make math math.bitwise ;
IN: cpu.alpha.64.assembler
ERROR: invalid-alpha-immediate value width ;
ERROR: invalid-alpha-register reg ;
: emit-insn ( n -- ) 4 >le % ;
:: signed-immediate ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-alpha-immediate ] if ;
:: unsigned-immediate ( value width -- bits )
    value width bits value = [ value ]
    [ value width invalid-alpha-immediate ] if ;
: R ( reg -- n ) dup int-register? [ n>> 5 unsigned-immediate ] [ invalid-alpha-register ] if ;
: F ( reg -- n ) dup fp-register? [ n>> 5 unsigned-immediate ] [ invalid-alpha-register ] if ;
:: memory-insn ( rd base displacement opcode -- )
    rd R 21 shift base R 16 shift bitor
    displacement 16 signed-immediate bitor opcode 26 shift bitor emit-insn ;
:: operate-insn ( dst src1 src2 function opcode -- )
    src1 R 21 shift src2 R 16 shift bitor dst R bitor
    function 5 shift bitor opcode 26 shift bitor emit-insn ;
:: literal-insn ( dst src value function opcode -- )
    src R 21 shift value 8 unsigned-immediate 13 shift bitor
    dst R bitor function 5 shift bitor 0x1000 bitor opcode 26 shift bitor emit-insn ;
:: branch-insn ( reg displacement opcode -- )
    displacement 3 bitand 0 = [ ] [ displacement 23 invalid-alpha-immediate ] if
    displacement -2 shift 21 signed-immediate
    reg R 21 shift bitor opcode 26 shift bitor emit-insn ;
:: jump-insn ( link target function -- )
    link R 21 shift target R 16 shift bitor
    function 14 shift bitor 0x68000000 bitor emit-insn ;
: LDA ( rd base displacement -- ) 8 memory-insn ;
: LDAH ( rd base displacement -- ) 9 memory-insn ;
: LDQ_U ( rd base displacement -- ) 11 memory-insn ;
: LDL ( rd base displacement -- ) 40 memory-insn ;
: LDQ ( rd base displacement -- ) 41 memory-insn ;
: STL ( rd base displacement -- ) 44 memory-insn ;
: STQ ( rd base displacement -- ) 45 memory-insn ;
: LDQ_L ( rd base displacement -- ) 43 memory-insn ;
: STQ_C ( rd base displacement -- ) 47 memory-insn ;
: LDBU ( rd base displacement -- ) 10 memory-insn ;
: LDWU ( rd base displacement -- ) 12 memory-insn ;
: STB ( rd base displacement -- ) 14 memory-insn ;
: STW ( rd base displacement -- ) 13 memory-insn ;
: ADDQ ( dst src1 src2 -- ) 32 16 operate-insn ;
: ADDQI ( dst src value -- ) 32 16 literal-insn ;
: SUBQ ( dst src1 src2 -- ) 41 16 operate-insn ;
: SUBQI ( dst src value -- ) 41 16 literal-insn ;
: S4ADDQ ( dst src1 src2 -- ) 34 16 operate-insn ;
: S4ADDQI ( dst src value -- ) 34 16 literal-insn ;
: S8ADDQ ( dst src1 src2 -- ) 50 16 operate-insn ;
: S8ADDQI ( dst src value -- ) 50 16 literal-insn ;
: CMPULT ( dst src1 src2 -- ) 29 16 operate-insn ;
: CMPULTI ( dst src value -- ) 29 16 literal-insn ;
: CMPEQ ( dst src1 src2 -- ) 45 16 operate-insn ;
: CMPEQI ( dst src value -- ) 45 16 literal-insn ;
: CMPULE ( dst src1 src2 -- ) 61 16 operate-insn ;
: CMPULEI ( dst src value -- ) 61 16 literal-insn ;
: CMPLT ( dst src1 src2 -- ) 77 16 operate-insn ;
: CMPLTI ( dst src value -- ) 77 16 literal-insn ;
: CMPLE ( dst src1 src2 -- ) 109 16 operate-insn ;
: CMPLEI ( dst src value -- ) 109 16 literal-insn ;
: AND ( dst src1 src2 -- ) 0 17 operate-insn ;
: ANDI ( dst src value -- ) 0 17 literal-insn ;
: BIC ( dst src1 src2 -- ) 8 17 operate-insn ;
: BICI ( dst src value -- ) 8 17 literal-insn ;
: BIS ( dst src1 src2 -- ) 32 17 operate-insn ;
: BISI ( dst src value -- ) 32 17 literal-insn ;
: ORNOT ( dst src1 src2 -- ) 40 17 operate-insn ;
: ORNOTI ( dst src value -- ) 40 17 literal-insn ;
: XOR ( dst src1 src2 -- ) 64 17 operate-insn ;
: XORI ( dst src value -- ) 64 17 literal-insn ;
: EQV ( dst src1 src2 -- ) 72 17 operate-insn ;
: EQVI ( dst src value -- ) 72 17 literal-insn ;
: CMOVEQ ( dst src1 src2 -- ) 36 17 operate-insn ;
: CMOVEQI ( dst src value -- ) 36 17 literal-insn ;
: CMOVNE ( dst src1 src2 -- ) 38 17 operate-insn ;
: CMOVNEI ( dst src value -- ) 38 17 literal-insn ;
: CMOVLT ( dst src1 src2 -- ) 68 17 operate-insn ;
: CMOVLTI ( dst src value -- ) 68 17 literal-insn ;
: CMOVGE ( dst src1 src2 -- ) 70 17 operate-insn ;
: CMOVGEI ( dst src value -- ) 70 17 literal-insn ;
: CMOVLE ( dst src1 src2 -- ) 100 17 operate-insn ;
: CMOVLEI ( dst src value -- ) 100 17 literal-insn ;
: CMOVGT ( dst src1 src2 -- ) 102 17 operate-insn ;
: CMOVGTI ( dst src value -- ) 102 17 literal-insn ;
: SLL ( dst src1 src2 -- ) 57 18 operate-insn ;
: SLLI ( dst src value -- ) 57 18 literal-insn ;
: SRL ( dst src1 src2 -- ) 52 18 operate-insn ;
: SRLI ( dst src value -- ) 52 18 literal-insn ;
: SRA ( dst src1 src2 -- ) 60 18 operate-insn ;
: SRAI ( dst src value -- ) 60 18 literal-insn ;
: ZAP ( dst src1 src2 -- ) 48 18 operate-insn ;
: ZAPI ( dst src value -- ) 48 18 literal-insn ;
: ZAPNOT ( dst src1 src2 -- ) 49 18 operate-insn ;
: ZAPNOTI ( dst src value -- ) 49 18 literal-insn ;
: MULQ ( dst src1 src2 -- ) 32 19 operate-insn ;
: MULQI ( dst src value -- ) 32 19 literal-insn ;
: UMULH ( dst src1 src2 -- ) 48 19 operate-insn ;
: UMULHI ( dst src value -- ) 48 19 literal-insn ;
: EXTQL ( dst src1 src2 -- ) 54 18 operate-insn ;
: EXTQLI ( dst src value -- ) 54 18 literal-insn ;
: EXTQH ( dst src1 src2 -- ) 122 18 operate-insn ;
: EXTQHI ( dst src value -- ) 122 18 literal-insn ;
: BR ( reg displacement -- ) 48 branch-insn ;
: BSR ( reg displacement -- ) 52 branch-insn ;
: BEQ ( reg displacement -- ) 57 branch-insn ;
: BLT ( reg displacement -- ) 58 branch-insn ;
: BLE ( reg displacement -- ) 59 branch-insn ;
: BNE ( reg displacement -- ) 61 branch-insn ;
: BGE ( reg displacement -- ) 62 branch-insn ;
: BGT ( reg displacement -- ) 63 branch-insn ;
: BLBC ( reg displacement -- ) 56 branch-insn ;
: BLBS ( reg displacement -- ) 60 branch-insn ;
 : JMP ( target -- ) ZERO swap 0 jump-insn ;
: JSR ( target -- ) RA swap 1 jump-insn ;
: RET ( -- ) ZERO RA 2 jump-insn ;
: MV ( dst src -- ) dup BIS ;
: NEG ( dst src -- ) ZERO swap SUBQ ;
: NOT ( dst src -- ) ZERO swap ORNOT ;
: NOP ( -- ) ZERO ZERO MV ;
: MB ( -- ) 0x60004000 emit-insn ;
: IMB ( -- ) 0x00000086 emit-insn ;
! Split a literal into aligned 32-bit loads, preserving all 64 address bits.
:: literal-load ( dst address scratch -- )
    scratch address 4 LDL dst address 0 LDL
    dst dst 15 ZAPNOTI scratch scratch 32 SLLI dst dst scratch BIS ;
:: LI ( dst value -- )
    value 16 >signed value = [ dst ZERO value LDA ] [
        dst 8 BR value 8 >le % dst dst dst R 3 = temp2 temp3 ? literal-load
    ] if ;
:: load-address ( dst -- class )
    dst 8 BR 0 8 >le %
    dst dst temp3 literal-load rc-native-1 ;
: call-address ( -- class ) PV load-address ;
: jump-address ( -- class ) PV load-address ;
:: float-memory-insn ( rd base displacement opcode -- )
    rd F 21 shift base R 16 shift bitor
    displacement 16 signed-immediate bitor opcode 26 shift bitor emit-insn ;
: LDS ( dst base offset -- ) 0x22 float-memory-insn ;
: LDT ( dst base offset -- ) 0x23 float-memory-insn ;
: STS ( src base offset -- ) 0x26 float-memory-insn ;
: STT ( src base offset -- ) 0x27 float-memory-insn ;
:: float-insn ( dst src1 src2 function opcode -- )
    src1 F 21 shift src2 F 16 shift bitor dst F bitor
    function 5 shift bitor opcode 26 shift bitor emit-insn ;
! IEEE completion includes inexact (/suid), with dynamic rounding.
: ADDT ( dst src1 src2 -- ) 0x7e0 0x16 float-insn ;
: SUBT ( dst src1 src2 -- ) 0x7e1 0x16 float-insn ;
: MULT ( dst src1 src2 -- ) 0x7e2 0x16 float-insn ;
: DIVT ( dst src1 src2 -- ) 0x7e3 0x16 float-insn ;
: CMPTUN ( dst src1 src2 -- ) 0x5a4 0x16 float-insn ;
: CMPTEQ ( dst src1 src2 -- ) 0x5a5 0x16 float-insn ;
: CMPTLT ( dst src1 src2 -- ) 0x5a6 0x16 float-insn ;
: CMPTLE ( dst src1 src2 -- ) 0x5a7 0x16 float-insn ;
: CPYS ( dst src1 src2 -- ) 0x020 0x17 float-insn ;
: CPYSN ( dst src1 src2 -- ) 0x021 0x17 float-insn ;
: CVTTQ ( dst src -- ) F31 swap 0x52f 0x16 float-insn ;
: CVTQT ( dst src -- ) F31 swap 0x7fe 0x16 float-insn ;
: CVTST ( dst src -- ) F31 swap 0x6ac 0x16 float-insn ;
: CVTTS ( dst src -- ) F31 swap 0x7ec 0x16 float-insn ;
: SQRTT ( dst src -- ) F31 swap 0x7eb 0x14 float-insn ;
: EXCB ( -- ) 0x60000400 emit-insn ;
: MF-FPCR ( dst -- ) dup dup 0x025 0x17 float-insn ;
: MT-FPCR ( src -- ) dup dup 0x024 0x17 float-insn ;
