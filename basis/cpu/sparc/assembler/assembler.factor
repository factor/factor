! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: endian kernel locals make math math.bitwise ;
IN: cpu.sparc.assembler

! Registers use architectural numbers: g0..g7=0..7, o0..o7=8..15,
! l0..l7=16..23, i0..i7=24..31. Destination comes first.
! Instructions are big-endian for both V8 and V9; delay slots are explicit.
ERROR: invalid-sparc-operand value width ;
:: unsigned-field ( value width -- bits )
    value width bits value = [ value ]
    [ value width invalid-sparc-operand ] if ;
:: signed-field ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-sparc-operand ] if ;
: R ( reg -- bits ) 5 unsigned-field ;
! V9 doubles cover f0..f62. Bit 5 maps to the low instruction field bit.
:: D ( reg -- bits )
    reg 6 unsigned-field drop
    reg 1 bitand 0 = [ ] [ reg 6 invalid-sparc-operand ] if
    reg 5 bits reg -5 shift bitor ;
: emit-insn ( n -- ) 4 >be % ;
:: format3 ( rd rs1 operand immediate? op3 op -- )
    op 30 shift rd R 25 shift bitor op3 19 shift bitor
    rs1 R 14 shift bitor
    operand immediate? [ 13 signed-field 0x2000 bitor ] [ R ] if
    bitor emit-insn ;
:: alu-reg ( rd rs1 rs2 op3 -- ) rd rs1 rs2 f op3 2 format3 ;
:: alu-imm ( rd rs1 imm op3 -- ) rd rs1 imm t op3 2 format3 ;
:: mem-reg ( rd rs1 rs2 op3 -- ) rd rs1 rs2 f op3 3 format3 ;
:: mem-imm ( rd rs1 imm op3 -- ) rd rs1 imm t op3 3 format3 ;
:: SETHI ( rd imm -- )
    rd R 25 shift imm 22 unsigned-field bitor 0x01000000 bitor emit-insn ;
:: displacement ( bytes width -- bits )
    bytes 3 bitand 0 = [ bytes -2 shift width signed-field ]
    [ bytes width invalid-sparc-operand ] if ;
:: CALL ( bytes -- ) bytes 30 displacement 0x40000000 bitor emit-insn ;
:: Bicc ( cc bytes annul? -- )
    cc 4 unsigned-field 25 shift bytes 22 displacement bitor
    annul? [ 0x20000000 bitor ] when 0x00800000 bitor emit-insn ;
:: FBfcc ( cc bytes annul? -- )
    cc 4 unsigned-field 25 shift bytes 22 displacement bitor
    annul? [ 0x20000000 bitor ] when 0x01800000 bitor emit-insn ;
: ADD ( rd rs1 rs2 -- ) 0 alu-reg ;
: ADDI ( rd rs1 imm -- ) 0 alu-imm ;
: AND ( rd rs1 rs2 -- ) 1 alu-reg ;
: ANDI ( rd rs1 imm -- ) 1 alu-imm ;
: OR ( rd rs1 rs2 -- ) 2 alu-reg ;
: ORI ( rd rs1 imm -- ) 2 alu-imm ;
: XOR ( rd rs1 rs2 -- ) 3 alu-reg ;
: XORI ( rd rs1 imm -- ) 3 alu-imm ;
: SUB ( rd rs1 rs2 -- ) 4 alu-reg ;
: SUBI ( rd rs1 imm -- ) 4 alu-imm ;
: ANDN ( rd rs1 rs2 -- ) 5 alu-reg ;
: ANDNI ( rd rs1 imm -- ) 5 alu-imm ;
: ORN ( rd rs1 rs2 -- ) 6 alu-reg ;
: ORNI ( rd rs1 imm -- ) 6 alu-imm ;
: XNOR ( rd rs1 rs2 -- ) 7 alu-reg ;
: XNORI ( rd rs1 imm -- ) 7 alu-imm ;
: ADDX ( rd rs1 rs2 -- ) 8 alu-reg ;
: ADDXI ( rd rs1 imm -- ) 8 alu-imm ;
: UMUL ( rd rs1 rs2 -- ) 10 alu-reg ;
: UMULI ( rd rs1 imm -- ) 10 alu-imm ;
: SMUL ( rd rs1 rs2 -- ) 11 alu-reg ;
: SMULI ( rd rs1 imm -- ) 11 alu-imm ;
: SUBX ( rd rs1 rs2 -- ) 12 alu-reg ;
: SUBXI ( rd rs1 imm -- ) 12 alu-imm ;
: UDIV ( rd rs1 rs2 -- ) 14 alu-reg ;
: UDIVI ( rd rs1 imm -- ) 14 alu-imm ;
: SDIV ( rd rs1 rs2 -- ) 15 alu-reg ;
: SDIVI ( rd rs1 imm -- ) 15 alu-imm ;
: ADDcc ( rd rs1 rs2 -- ) 16 alu-reg ;
: ADDccI ( rd rs1 imm -- ) 16 alu-imm ;
: ANDcc ( rd rs1 rs2 -- ) 17 alu-reg ;
: ANDccI ( rd rs1 imm -- ) 17 alu-imm ;
: ORcc ( rd rs1 rs2 -- ) 18 alu-reg ;
: ORccI ( rd rs1 imm -- ) 18 alu-imm ;
: XORcc ( rd rs1 rs2 -- ) 19 alu-reg ;
: XORccI ( rd rs1 imm -- ) 19 alu-imm ;
: SUBcc ( rd rs1 rs2 -- ) 20 alu-reg ;
: SUBccI ( rd rs1 imm -- ) 20 alu-imm ;
: ADDXcc ( rd rs1 rs2 -- ) 24 alu-reg ;
: ADDXccI ( rd rs1 imm -- ) 24 alu-imm ;
: UMULcc ( rd rs1 rs2 -- ) 26 alu-reg ;
: UMULccI ( rd rs1 imm -- ) 26 alu-imm ;
: SMULcc ( rd rs1 rs2 -- ) 27 alu-reg ;
: SMULccI ( rd rs1 imm -- ) 27 alu-imm ;
: SUBXcc ( rd rs1 rs2 -- ) 28 alu-reg ;
: SUBXccI ( rd rs1 imm -- ) 28 alu-imm ;
: UDIVcc ( rd rs1 rs2 -- ) 30 alu-reg ;
: UDIVccI ( rd rs1 imm -- ) 30 alu-imm ;
: SDIVcc ( rd rs1 rs2 -- ) 31 alu-reg ;
: SDIVccI ( rd rs1 imm -- ) 31 alu-imm ;
: JMPL ( rd rs1 rs2 -- ) 56 alu-reg ;
: JMPLI ( rd rs1 imm -- ) 56 alu-imm ;
: SAVE ( rd rs1 rs2 -- ) 60 alu-reg ;
: SAVEI ( rd rs1 imm -- ) 60 alu-imm ;
: RESTORE ( rd rs1 rs2 -- ) 61 alu-reg ;
: RESTOREI ( rd rs1 imm -- ) 61 alu-imm ;
: MULX ( rd rs1 rs2 -- ) 9 alu-reg ;
: MULXI ( rd rs1 imm -- ) 9 alu-imm ;
: UDIVX ( rd rs1 rs2 -- ) 13 alu-reg ;
: UDIVXI ( rd rs1 imm -- ) 13 alu-imm ;
: SDIVX ( rd rs1 rs2 -- ) 45 alu-reg ;
: SDIVXI ( rd rs1 imm -- ) 45 alu-imm ;
: LD ( rd rs1 imm -- ) 0 mem-imm ;
: LDR ( rd rs1 rs2 -- ) 0 mem-reg ;
: LDUB ( rd rs1 imm -- ) 1 mem-imm ;
: LDUBR ( rd rs1 rs2 -- ) 1 mem-reg ;
: LDUH ( rd rs1 imm -- ) 2 mem-imm ;
: LDUHR ( rd rs1 rs2 -- ) 2 mem-reg ;
: LDD ( rd rs1 imm -- ) 3 mem-imm ;
: LDDR ( rd rs1 rs2 -- ) 3 mem-reg ;
: ST ( rd rs1 imm -- ) 4 mem-imm ;
: STR ( rd rs1 rs2 -- ) 4 mem-reg ;
: STB ( rd rs1 imm -- ) 5 mem-imm ;
: STBR ( rd rs1 rs2 -- ) 5 mem-reg ;
: STH ( rd rs1 imm -- ) 6 mem-imm ;
: STHR ( rd rs1 rs2 -- ) 6 mem-reg ;
: STD ( rd rs1 imm -- ) 7 mem-imm ;
: STDR ( rd rs1 rs2 -- ) 7 mem-reg ;
: LDSB ( rd rs1 imm -- ) 9 mem-imm ;
: LDSBR ( rd rs1 rs2 -- ) 9 mem-reg ;
: LDSH ( rd rs1 imm -- ) 10 mem-imm ;
: LDSHR ( rd rs1 rs2 -- ) 10 mem-reg ;
: LDX ( rd rs1 imm -- ) 11 mem-imm ;
: LDXR ( rd rs1 rs2 -- ) 11 mem-reg ;
: STX ( rd rs1 imm -- ) 14 mem-imm ;
: STXR ( rd rs1 rs2 -- ) 14 mem-reg ;
: LDF ( rd rs1 imm -- ) 32 mem-imm ;
: LDFR ( rd rs1 rs2 -- ) 32 mem-reg ;
: LDDF ( rd rs1 imm -- ) [ D ] 2dip 35 mem-imm ;
: LDDFR ( rd rs1 rs2 -- ) [ D ] 2dip 35 mem-reg ;
: STF ( rd rs1 imm -- ) 36 mem-imm ;
: STFR ( rd rs1 rs2 -- ) 36 mem-reg ;
! FSR rd=0 is the V8 32-bit form; rd=1 is the V9 64-bit form.
: LDFSR ( rs1 imm -- ) 0 -rot 33 mem-imm ;
: STFSR ( rs1 imm -- ) 0 -rot 37 mem-imm ;
: LDXFSR ( rs1 imm -- ) 1 -rot 33 mem-imm ;
: STXFSR ( rs1 imm -- ) 1 -rot 37 mem-imm ;
: STDF ( rd rs1 imm -- ) [ D ] 2dip 39 mem-imm ;
: STDFR ( rd rs1 rs2 -- ) [ D ] 2dip 39 mem-reg ;
:: shift-reg ( rd rs1 rs2 op3 -- ) rd rs1 rs2 op3 alu-reg ;
:: shift-imm ( rd rs1 amount extended? op3 -- )
    2 30 shift rd R 25 shift bitor op3 19 shift bitor
    rs1 R 14 shift bitor 0x2000 bitor
    amount extended? [ 6 ] [ 5 ] if unsigned-field bitor
    extended? [ 0x1000 bitor ] when emit-insn ;
: SLL ( rd rs1 rs2 -- ) 37 shift-reg ;
: SRL ( rd rs1 rs2 -- ) 38 shift-reg ;
: SRA ( rd rs1 rs2 -- ) 39 shift-reg ;
: SLLI ( rd rs1 amount -- ) f 37 shift-imm ;
: SRLI ( rd rs1 amount -- ) f 38 shift-imm ;
: SRAI ( rd rs1 amount -- ) f 39 shift-imm ;
: SLLXI ( rd rs1 amount -- ) t 37 shift-imm ;
: SRLXI ( rd rs1 amount -- ) t 38 shift-imm ;
: SRAXI ( rd rs1 amount -- ) t 39 shift-imm ;
:: fpop ( rd rs1 rs2 opf -- )
    0x81a00000 rd R 25 shift bitor rs1 R 14 shift bitor
    opf 9 unsigned-field 5 shift bitor rs2 R bitor emit-insn ;
:: double-op ( rd rs1 rs2 opf -- ) rd D rs1 D rs2 D opf fpop ;
: FADDS ( rd rs1 rs2 -- ) 0x41 fpop ;
: FSUBS ( rd rs1 rs2 -- ) 0x45 fpop ;
: FMULS ( rd rs1 rs2 -- ) 0x49 fpop ;
: FDIVS ( rd rs1 rs2 -- ) 0x4d fpop ;
: FADDD ( rd rs1 rs2 -- ) 0x42 double-op ;
: FSUBD ( rd rs1 rs2 -- ) 0x46 double-op ;
: FMULD ( rd rs1 rs2 -- ) 0x4a double-op ;
: FDIVD ( rd rs1 rs2 -- ) 0x4e double-op ;
: NOP ( -- ) 0 0 SETHI ;
: RET ( -- ) 0 31 8 JMPLI ;
: RETL ( -- ) 0 15 8 JMPLI ;
: RESTORE0 ( -- ) 0 0 0 RESTORE ;

! Fixed-size templates permit image relocation and inline-cache patching.
! SET64 requires a scratch register distinct from the destination.
:: SET32 ( rd value -- )
    value 32 unsigned-field :> n
    rd n -10 shift SETHI rd rd n 10 bits ORI ;
:: SET64 ( rd scratch value -- )
    rd R scratch R = scratch 0 = or
    [ scratch 5 invalid-sparc-operand ] when
    value 64 unsigned-field :> n
    scratch n -42 shift SETHI
    scratch scratch n -32 shift 10 bits ORI
    scratch scratch 32 SLLXI
    rd n -10 shift 22 bits SETHI
    rd rd n 10 bits ORI
    rd rd scratch OR ;
! V9 predicted branches: cc is 0 for ICC, 2 for XCC.
:: BPcc ( condition bytes cc predict-taken? annul? -- )
    cc 0 = cc 2 = or [ ] [ cc 2 invalid-sparc-operand ] if
    condition 4 unsigned-field 25 shift cc 20 shift bitor
    bytes 19 displacement bitor 0x00400000 bitor
    predict-taken? [ 0x00080000 bitor ] when
    annul? [ 0x20000000 bitor ] when emit-insn ;
:: FBPfcc ( condition bytes fcc predict-taken? annul? -- )
    condition 4 unsigned-field 25 shift
    fcc 2 unsigned-field 20 shift bitor
    bytes 19 displacement bitor 0x01400000 bitor
    predict-taken? [ 0x00080000 bitor ] when
    annul? [ 0x20000000 bitor ] when emit-insn ;

! Unary conversions retain the distinct single/double register encodings.
:: unary-fpop ( rd rs opf -- ) rd 0 rs opf fpop ;
: FMOVS ( rd rs -- ) 1 unary-fpop ;
: FNEGS ( rd rs -- ) 5 unary-fpop ;
: FABSS ( rd rs -- ) 9 unary-fpop ;
: FSQRTS ( rd rs -- ) 0x29 unary-fpop ;
: FMOVD ( rd rs -- ) [ D ] bi@ 2 unary-fpop ;
: FNEGD ( rd rs -- ) [ D ] bi@ 6 unary-fpop ;
: FABSD ( rd rs -- ) [ D ] bi@ 10 unary-fpop ;
: FSQRTD ( rd rs -- ) [ D ] bi@ 0x2a unary-fpop ;
: FITOD ( rd rs -- ) [ D ] dip 0xc8 unary-fpop ;
: FDTOI ( rd rs -- ) D 0xd2 unary-fpop ;
: FSTOD ( rd rs -- ) [ D ] dip 0xc9 unary-fpop ;
: FDTOS ( rd rs -- ) D 0xc6 unary-fpop ;
: FXTOD ( rd rs -- ) [ D ] bi@ 0x88 unary-fpop ;
: FDTOX ( rd rs -- ) [ D ] bi@ 0x82 unary-fpop ;
:: fcompare ( fcc rs1 rs2 opf -- )
    0x81a80000 fcc 2 unsigned-field 25 shift bitor
    rs1 R 14 shift bitor opf 5 shift bitor rs2 R bitor emit-insn ;
: FCMPS ( fcc rs1 rs2 -- ) 0x51 fcompare ;
: FCMPD ( fcc rs1 rs2 -- ) [ D ] bi@ 0x52 fcompare ;
: FCMPED ( fcc rs1 rs2 -- ) [ D ] bi@ 0x56 fcompare ;

! Extended register shifts set x independently of the register operand.
:: shift-x-reg ( rd rs1 rs2 op3 -- )
    0x80001000 rd R 25 shift bitor rs1 R 14 shift bitor
    op3 19 shift bitor rs2 R bitor emit-insn ;
: SLLX ( rd rs1 rs2 -- ) 37 shift-x-reg ;
: SRLX ( rd rs1 rs2 -- ) 38 shift-x-reg ;
: SRAX ( rd rs1 rs2 -- ) 39 shift-x-reg ;
! Flush register windows before exposing the native stack to GC or the VM.
: FLUSHW ( -- ) 0x81580000 emit-insn ;
: FLUSH-WINDOWS-V8 ( -- ) 0x91d02003 emit-insn ;
: RDY ( rd -- ) 0 0 40 alu-reg ;
