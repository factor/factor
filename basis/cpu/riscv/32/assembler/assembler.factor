! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.codegen.relocation compiler.constants
cpu.riscv.32.assembler.registers endian kernel locals make math
math.bitwise math.order sequences ;
IN: cpu.riscv.32.assembler

ERROR: invalid-riscv-immediate value width ;
ERROR: invalid-riscv-register reg ;
: insns ( n -- bytes ) 4 * ; inline
: emit-insn ( n -- ) 4 >le % ;
: emit-half ( n -- ) 2 >le % ;
:: signed-immediate ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-riscv-immediate ] if ;
:: unsigned-immediate ( value width -- bits )
    value width bits value = [ value ]
    [ value width invalid-riscv-immediate ] if ;
: R ( reg -- n ) dup int-register? [ n>> 5 unsigned-immediate ] [ invalid-riscv-register ] if ;
: F ( reg -- n ) dup fp-register? [ n>> 5 unsigned-immediate ] [ invalid-riscv-register ] if ;
:: r-insn ( rd rs1 rs2 f3 f7 opcode -- )
    rd R 7 shift rs1 R 15 shift bitor rs2 R 20 shift bitor
    f3 12 shift bitor f7 25 shift bitor opcode bitor emit-insn ;
:: i-insn ( rd rs1 imm f3 opcode -- )
    rd R 7 shift rs1 R 15 shift bitor imm 12 signed-immediate 20 shift bitor
    f3 12 shift bitor opcode bitor emit-insn ;
:: s-bits ( imm -- bits )
    imm 12 signed-immediate :> n
    n 5 bits 7 shift n -5 shift 25 shift bitor ;
:: s-insn ( rs2 rs1 imm f3 opcode -- )
    rs1 R 15 shift rs2 R 20 shift bitor imm s-bits bitor
    f3 12 shift bitor opcode bitor emit-insn ;
:: b-bits ( imm -- bits )
    imm 13 signed-immediate :> n
    imm 1 bitand 0 = [ ] [ imm 13 invalid-riscv-immediate ] if
    n -12 shift 31 shift n -5 shift 6 bits 25 shift bitor
    n -1 shift 4 bits 8 shift bitor n -11 shift 1 bits 7 shift bitor ;
:: b-insn ( rs1 rs2 imm f3 -- )
    rs1 R 15 shift rs2 R 20 shift bitor imm b-bits bitor
    f3 12 shift bitor 0x63 bitor emit-insn ;
:: u-insn ( rd imm opcode -- )
    rd R 7 shift imm 20 unsigned-immediate 12 shift bitor opcode bitor emit-insn ;
:: j-bits ( imm -- bits )
    imm 21 signed-immediate :> n
    imm 1 bitand 0 = [ ] [ imm 21 invalid-riscv-immediate ] if
    n -20 shift 31 shift n -1 shift 10 bits 21 shift bitor
    n -11 shift 1 bits 20 shift bitor n -12 shift 8 bits 12 shift bitor ;
:: JAL ( rd imm -- ) rd R 7 shift imm j-bits bitor 0x6f bitor emit-insn ;
: LUI ( rd imm -- ) 0x37 u-insn ;
: AUIPC ( rd imm -- ) 0x17 u-insn ;
: JALR ( rd rs1 imm -- ) 0 0x67 i-insn ;
: ADD ( rd rs1 rs2 -- ) 0 0 51 r-insn ;
: SUB ( rd rs1 rs2 -- ) 0 32 51 r-insn ;
: SLL ( rd rs1 rs2 -- ) 1 0 51 r-insn ;
: SLT ( rd rs1 rs2 -- ) 2 0 51 r-insn ;
: SLTU ( rd rs1 rs2 -- ) 3 0 51 r-insn ;
: XOR ( rd rs1 rs2 -- ) 4 0 51 r-insn ;
: SRL ( rd rs1 rs2 -- ) 5 0 51 r-insn ;
: SRA ( rd rs1 rs2 -- ) 5 32 51 r-insn ;
: OR ( rd rs1 rs2 -- ) 6 0 51 r-insn ;
: AND ( rd rs1 rs2 -- ) 7 0 51 r-insn ;
: MUL ( rd rs1 rs2 -- ) 0 1 0x33 r-insn ;
: MULH ( rd rs1 rs2 -- ) 1 1 0x33 r-insn ;
: MULHSU ( rd rs1 rs2 -- ) 2 1 0x33 r-insn ;
: MULHU ( rd rs1 rs2 -- ) 3 1 0x33 r-insn ;
: DIV ( rd rs1 rs2 -- ) 4 1 0x33 r-insn ;
: DIVU ( rd rs1 rs2 -- ) 5 1 0x33 r-insn ;
: REM ( rd rs1 rs2 -- ) 6 1 0x33 r-insn ;
: REMU ( rd rs1 rs2 -- ) 7 1 0x33 r-insn ;
: ADDI ( rd rs1 imm -- ) 0 19 i-insn ;
: SLTI ( rd rs1 imm -- ) 2 19 i-insn ;
: SLTIU ( rd rs1 imm -- ) 3 19 i-insn ;
: XORI ( rd rs1 imm -- ) 4 19 i-insn ;
: ORI ( rd rs1 imm -- ) 6 19 i-insn ;
: ANDI ( rd rs1 imm -- ) 7 19 i-insn ;
: LB ( rd rs1 imm -- ) 0 3 i-insn ;
: LH ( rd rs1 imm -- ) 1 3 i-insn ;
: LW ( rd rs1 imm -- ) 2 3 i-insn ;
: LBU ( rd rs1 imm -- ) 4 3 i-insn ;
: LHU ( rd rs1 imm -- ) 5 3 i-insn ;
: SB ( rs2 rs1 imm -- ) 0 0x23 s-insn ;
: SH ( rs2 rs1 imm -- ) 1 0x23 s-insn ;
: SW ( rs2 rs1 imm -- ) 2 0x23 s-insn ;
: BEQ ( rs1 rs2 imm -- ) 0 b-insn ;
: BNE ( rs1 rs2 imm -- ) 1 b-insn ;
: BLT ( rs1 rs2 imm -- ) 4 b-insn ;
: BGE ( rs1 rs2 imm -- ) 5 b-insn ;
: BLTU ( rs1 rs2 imm -- ) 6 b-insn ;
: BGEU ( rs1 rs2 imm -- ) 7 b-insn ;
:: shift-insn ( rd rs1 shamt width f3 top opcode -- )
    rd R 7 shift rs1 R 15 shift bitor
    shamt width unsigned-immediate top bitor 20 shift bitor
    f3 12 shift bitor opcode bitor emit-insn ;
: SLLI ( rd rs1 shamt -- ) 5 1 0 19 shift-insn ;
: SRLI ( rd rs1 shamt -- ) 5 5 0 19 shift-insn ;
: SRAI ( rd rs1 shamt -- ) 5 5 1024 19 shift-insn ;

: NOP ( -- ) ZERO ZERO 0 ADDI ;
: RET ( -- ) ZERO RA 0 JALR ;
: JR ( rs -- ) [ ZERO ] dip 0 JALR ;
: J ( imm -- ) [ ZERO ] dip JAL ;
: MV ( rd rs -- ) 0 ADDI ;
: NOT ( rd rs -- ) -1 XORI ;
: NEG ( rd rs -- ) [ ZERO ] dip SUB ;
: SEQZ ( rd rs -- ) 1 SLTIU ;
: SNEZ ( rd rs -- ) [ ZERO ] dip SLTU ;
: SLTZ ( rd rs -- ) ZERO SLT ;
: SGTZ ( rd rs -- ) [ ZERO ] dip SLT ;
: BEQZ ( rs imm -- ) [ ZERO ] dip BEQ ;
: BNEZ ( rs imm -- ) [ ZERO ] dip BNE ;
: BLEZ ( rs imm -- ) [ ZERO ] 2dip BGE ;
: BGEZ ( rs imm -- ) [ ZERO ] dip BGE ;
: BLTZ ( rs imm -- ) [ ZERO ] dip BLT ;
: BGTZ ( rs imm -- ) [ ZERO ] 2dip BLT ;
: ECALL ( -- ) 0x73 emit-insn ;
: EBREAK ( -- ) 0x100073 emit-insn ;
: FENCE.I ( -- ) 0x100f emit-insn ;
: FENCE ( pred succ -- ) [ 4 unsigned-immediate 24 shift ] [ 4 unsigned-immediate 20 shift ] bi* bitor 0xf bitor emit-insn ;
:: csr-insn ( rd csr rs f3 -- )
    rd R 7 shift csr 12 unsigned-immediate 20 shift bitor
    rs 5 unsigned-immediate 15 shift bitor f3 12 shift bitor 0x73 bitor emit-insn ;
: CSRRW ( rd csr rs -- ) R 1 csr-insn ;
: CSRRS ( rd csr rs -- ) R 2 csr-insn ;
: CSRRC ( rd csr rs -- ) R 3 csr-insn ;
: CSRRWI ( rd csr imm -- ) 5 csr-insn ;
: CSRRSI ( rd csr imm -- ) 6 csr-insn ;
: CSRRCI ( rd csr imm -- ) 7 csr-insn ;
: CSRR ( rd csr -- ) ZERO CSRRS ;
: CSRW ( csr rs -- ) [ ZERO ] 2dip CSRRW ;
: RDCYCLE ( rd -- ) 0xc00 CSRR ;
: RDTIME ( rd -- ) 0xc01 CSRR ;
: RDINSTRET ( rd -- ) 0xc02 CSRR ;
: RDCYCLEH ( rd -- ) 0xc80 CSRR ;
: RDTIMEH ( rd -- ) 0xc81 CSRR ;
: RDINSTRETH ( rd -- ) 0xc82 CSRR ;

! Fixed-size loads let the collector relocate any 32-bit literal.
:: LI32 ( rd value -- )
    value 32 >signed :> v
    v 12 >signed :> low
    rd v low - -12 shift 20 bits LUI rd rd low ADDI ;
:: LI ( rd value -- )
    value 32 >signed :> v
    v 12 >signed v = [ rd ZERO v ADDI ] [ rd v LI32 ] if ;
: load-address ( rd -- class ) 0 LI32 rc-absolute-riscv-li ;
: call-relative ( -- class ) temp 0 AUIPC RA temp 0 JALR rc-relative-riscv ;
: jump-relative ( -- class ) temp 0 AUIPC ZERO temp 0 JALR rc-relative-riscv ;

:: fp-load ( rd rs1 imm f3 -- )
    rd F 7 shift rs1 R 15 shift bitor imm 12 signed-immediate 20 shift bitor
    f3 12 shift bitor 7 bitor emit-insn ;
:: fp-store ( rs2 rs1 imm f3 -- )
    rs2 F 20 shift rs1 R 15 shift bitor imm s-bits bitor
    f3 12 shift bitor 0x27 bitor emit-insn ;
: FLW ( rd rs1 imm -- ) 2 fp-load ;
: FLD ( rd rs1 imm -- ) 3 fp-load ;
: FSW ( rs2 rs1 imm -- ) 2 fp-store ;
: FSD ( rs2 rs1 imm -- ) 3 fp-store ;
:: fp-insn ( rd rs1 rs2 rm funct7 -- )
    rd F 7 shift rs1 F 15 shift bitor rs2 F 20 shift bitor
    rm 3 unsigned-immediate 12 shift bitor funct7 25 shift bitor 0x53 bitor emit-insn ;
: FADD.S ( rd rs1 rs2 -- ) 7 0 fp-insn ;
: FSUB.S ( rd rs1 rs2 -- ) 7 4 fp-insn ;
: FMUL.S ( rd rs1 rs2 -- ) 7 8 fp-insn ;
: FDIV.S ( rd rs1 rs2 -- ) 7 12 fp-insn ;
: FSGNJ.S ( rd rs1 rs2 -- ) 0 16 fp-insn ;
: FSGNJN.S ( rd rs1 rs2 -- ) 1 16 fp-insn ;
: FSGNJX.S ( rd rs1 rs2 -- ) 2 16 fp-insn ;
: FMIN.S ( rd rs1 rs2 -- ) 0 20 fp-insn ;
: FMAX.S ( rd rs1 rs2 -- ) 1 20 fp-insn ;
: FSQRT.S ( rd rs -- ) F0 7 44 fp-insn ;
: FMV.S ( rd rs -- ) dup FSGNJ.S ;
: FNEG.S ( rd rs -- ) dup FSGNJN.S ;
: FABS.S ( rd rs -- ) dup FSGNJX.S ;
: FADD.D ( rd rs1 rs2 -- ) 7 1 fp-insn ;
: FSUB.D ( rd rs1 rs2 -- ) 7 5 fp-insn ;
: FMUL.D ( rd rs1 rs2 -- ) 7 9 fp-insn ;
: FDIV.D ( rd rs1 rs2 -- ) 7 13 fp-insn ;
: FSGNJ.D ( rd rs1 rs2 -- ) 0 17 fp-insn ;
: FSGNJN.D ( rd rs1 rs2 -- ) 1 17 fp-insn ;
: FSGNJX.D ( rd rs1 rs2 -- ) 2 17 fp-insn ;
: FMIN.D ( rd rs1 rs2 -- ) 0 21 fp-insn ;
: FMAX.D ( rd rs1 rs2 -- ) 1 21 fp-insn ;
: FSQRT.D ( rd rs -- ) F0 7 45 fp-insn ;
: FMV.D ( rd rs -- ) dup FSGNJ.D ;
: FNEG.D ( rd rs -- ) dup FSGNJN.D ;
: FABS.D ( rd rs -- ) dup FSGNJX.D ;
:: fp-compare ( rd rs1 rs2 rm fmt -- )
    rd R 7 shift rs1 F 15 shift bitor rs2 F 20 shift bitor
    rm 12 shift bitor fmt 0x50 + 25 shift bitor 0x53 bitor emit-insn ;
:: fp-to-int ( rd rs fmt kind rm -- )
    rd R 7 shift rs F 15 shift bitor kind 20 shift bitor
    rm 3 unsigned-immediate 12 shift bitor fmt 0x60 + 25 shift bitor 0x53 bitor emit-insn ;
:: int-to-fp ( rd rs fmt kind rm -- )
    rd F 7 shift rs R 15 shift bitor kind 20 shift bitor
    rm 3 unsigned-immediate 12 shift bitor fmt 0x68 + 25 shift bitor 0x53 bitor emit-insn ;
: FEQ.S ( rd rs1 rs2 -- ) 2 0 fp-compare ;
: FLT.S ( rd rs1 rs2 -- ) 1 0 fp-compare ;
: FLE.S ( rd rs1 rs2 -- ) 0 0 fp-compare ;
: FCVT.W.S ( rd rs rm -- ) [ 0 0 ] dip fp-to-int ;
: FCVT.S.W ( rd rs rm -- ) [ 0 0 ] dip int-to-fp ;
: FCVT.WU.S ( rd rs rm -- ) [ 0 1 ] dip fp-to-int ;
: FCVT.S.WU ( rd rs rm -- ) [ 0 1 ] dip int-to-fp ;
:: FCLASS.S ( rd rs -- )
    rd R 7 shift rs F 15 shift bitor 1 12 shift bitor 112 25 shift bitor 0x53 bitor emit-insn ;
: FEQ.D ( rd rs1 rs2 -- ) 2 1 fp-compare ;
: FLT.D ( rd rs1 rs2 -- ) 1 1 fp-compare ;
: FLE.D ( rd rs1 rs2 -- ) 0 1 fp-compare ;
: FCVT.W.D ( rd rs rm -- ) [ 1 0 ] dip fp-to-int ;
: FCVT.D.W ( rd rs rm -- ) [ 1 0 ] dip int-to-fp ;
: FCVT.WU.D ( rd rs rm -- ) [ 1 1 ] dip fp-to-int ;
: FCVT.D.WU ( rd rs rm -- ) [ 1 1 ] dip int-to-fp ;
:: FCLASS.D ( rd rs -- )
    rd R 7 shift rs F 15 shift bitor 1 12 shift bitor 113 25 shift bitor 0x53 bitor emit-insn ;
:: FMV.X.W ( rd rs -- ) rd R 7 shift rs F 15 shift bitor 0x70 25 shift bitor 0x53 bitor emit-insn ;
:: FMV.W.X ( rd rs -- ) rd F 7 shift rs R 15 shift bitor 0x78 25 shift bitor 0x53 bitor emit-insn ;
: FCVT.S.D ( rd rs -- ) F1 7 0x20 fp-insn ;
: FCVT.D.S ( rd rs -- ) F0 0 0x21 fp-insn ;
:: fp-fma ( rd rs1 rs2 rs3 fmt opcode -- )
    rd F 7 shift rs1 F 15 shift bitor rs2 F 20 shift bitor rs3 F 27 shift bitor
    fmt 25 shift bitor 7 12 shift bitor opcode bitor emit-insn ;
: FMADD.S ( rd rs1 rs2 rs3 -- ) 0 67 fp-fma ;
: FMSUB.S ( rd rs1 rs2 rs3 -- ) 0 71 fp-fma ;
: FNMSUB.S ( rd rs1 rs2 rs3 -- ) 0 75 fp-fma ;
: FNMADD.S ( rd rs1 rs2 rs3 -- ) 0 79 fp-fma ;
: FMADD.D ( rd rs1 rs2 rs3 -- ) 1 67 fp-fma ;
: FMSUB.D ( rd rs1 rs2 rs3 -- ) 1 71 fp-fma ;
: FNMSUB.D ( rd rs1 rs2 rs3 -- ) 1 75 fp-fma ;
: FNMADD.D ( rd rs1 rs2 rs3 -- ) 1 79 fp-fma ;
:: atomic-insn ( rd rs1 rs2 aq rl width funct5 -- )
    rd R 7 shift rs1 R 15 shift bitor rs2 R 20 shift bitor
    aq 1 unsigned-immediate 26 shift bitor rl 1 unsigned-immediate 25 shift bitor
    width 12 shift bitor funct5 27 shift bitor 0x2f bitor emit-insn ;
: AMOSWAP.W ( rd rs1 rs2 aq rl -- ) 2 1 atomic-insn ;
: AMOADD.W ( rd rs1 rs2 aq rl -- ) 2 0 atomic-insn ;
: AMOXOR.W ( rd rs1 rs2 aq rl -- ) 2 4 atomic-insn ;
: AMOAND.W ( rd rs1 rs2 aq rl -- ) 2 12 atomic-insn ;
: AMOOR.W ( rd rs1 rs2 aq rl -- ) 2 8 atomic-insn ;
: AMOMIN.W ( rd rs1 rs2 aq rl -- ) 2 16 atomic-insn ;
: AMOMAX.W ( rd rs1 rs2 aq rl -- ) 2 20 atomic-insn ;
: AMOMINU.W ( rd rs1 rs2 aq rl -- ) 2 24 atomic-insn ;
: AMOMAXU.W ( rd rs1 rs2 aq rl -- ) 2 28 atomic-insn ;
: SC.W ( rd rs1 rs2 aq rl -- ) 2 3 atomic-insn ;
: LR.W ( rd rs1 aq rl -- ) [ ZERO ] 2dip 2 2 atomic-insn ;

! RV32C. Fields are { source-bit width instruction-bit } triples.
:: scatter ( value fields -- bits )
    fields [ first3 :> ( source width target )
        value source neg shift width bits target shift
    ] map 0 [ bitor ] reduce ;
: R' ( reg -- n ) R dup 8 15 between? [ 8 - ] [ invalid-riscv-register ] if ;
: F' ( reg -- n ) F dup 8 15 between? [ 8 - ] [ invalid-riscv-register ] if ;
: nonzero-register ( reg -- n ) R dup zero? [ invalid-riscv-register ] when ;
: nonzero-immediate ( n -- n ) dup zero? [ 0 invalid-riscv-immediate ] when ;
:: aligned-immediate ( n width alignment -- n' )
    n width unsigned-immediate n alignment 1 - bitand zero?
    [ ] [ n width invalid-riscv-immediate ] if ;
:: ci-insn ( rd imm opcode -- )
    rd R 7 shift imm 6 signed-immediate { { 5 1 12 } { 0 5 2 } } scatter bitor
    opcode bitor emit-half ;
: C.NOP ( -- ) 1 emit-half ;
: C.ADDI ( rd imm -- ) 1 ci-insn ;
: C.LI ( rd imm -- ) 0x4001 ci-insn ;
:: C.LUI ( rd imm -- )
    rd nonzero-register 2 = [ rd invalid-riscv-register ] when
    rd imm 20 >signed nonzero-immediate 0x6001 ci-insn ;
:: C.ADDI16SP ( imm -- )
    imm 10 signed-immediate nonzero-immediate :> n
    imm 15 bitand zero? [ ] [ imm 10 invalid-riscv-immediate ] if
    n { { 9 1 12 } { 4 1 6 } { 6 1 5 } { 7 2 3 } { 5 1 2 } } scatter
    0x6101 bitor emit-half ;
:: C.ADDI4SPN ( rd imm -- )
    rd R' 2 shift imm 10 4 aligned-immediate nonzero-immediate
    { { 4 2 11 } { 6 4 7 } { 2 1 6 } { 3 1 5 } } scatter bitor emit-half ;
:: cl-insn ( r base offset fp? size opcode -- )
    r fp? [ F' ] [ R' ] if 2 shift base R' 7 shift bitor
    offset size 4 = 7 8 ? size aligned-immediate
    size 4 = { { 3 3 10 } { 2 1 6 } { 6 1 5 } }
    { { 3 3 10 } { 6 2 5 } } ? scatter bitor opcode bitor emit-half ;
: C.LW ( rd base offset -- ) f 4 0x4000 cl-insn ;
: C.SW ( rs base offset -- ) f 4 0xc000 cl-insn ;
: C.FLW ( rd base offset -- ) t 4 0x6000 cl-insn ;
: C.FSW ( rs base offset -- ) t 4 0xe000 cl-insn ;
: C.FLD ( rd base offset -- ) t 8 0x2000 cl-insn ;
: C.FSD ( rs base offset -- ) t 8 0xa000 cl-insn ;
:: cb-shift ( rd shamt opcode -- )
    rd R' 7 shift shamt 5 unsigned-immediate
    { { 5 1 12 } { 0 5 2 } } scatter bitor opcode bitor emit-half ;
: C.SRLI ( rd shamt -- ) 0x8001 cb-shift ;
: C.SRAI ( rd shamt -- ) 0x8401 cb-shift ;
:: C.ANDI ( rd imm -- )
    rd R' 7 shift imm 6 signed-immediate
    { { 5 1 12 } { 0 5 2 } } scatter bitor 0x8801 bitor emit-half ;
:: ca-insn ( rd rs opcode -- ) rd R' 7 shift rs R' 2 shift bitor opcode bitor emit-half ;
: C.SUB ( rd rs -- ) 0x8c01 ca-insn ;
: C.XOR ( rd rs -- ) 0x8c21 ca-insn ;
: C.OR ( rd rs -- ) 0x8c41 ca-insn ;
: C.AND ( rd rs -- ) 0x8c61 ca-insn ;
:: cj-insn ( imm opcode -- )
    imm 12 signed-immediate :> n
    imm 1 bitand zero? [ ] [ imm 12 invalid-riscv-immediate ] if
    n { { 11 1 12 } { 4 1 11 } { 8 2 9 } { 10 1 8 }
        { 6 1 7 } { 7 1 6 } { 1 3 3 } { 5 1 2 } } scatter opcode bitor emit-half ;
: C.J ( imm -- ) 0xa001 cj-insn ;
: C.JAL ( imm -- ) 0x2001 cj-insn ;
:: cb-branch ( rs imm opcode -- )
    imm 9 signed-immediate :> n
    imm 1 bitand zero? [ ] [ imm 9 invalid-riscv-immediate ] if
    rs R' 7 shift n { { 8 1 12 } { 3 2 10 } { 6 2 5 } { 1 2 3 } { 5 1 2 } }
    scatter bitor opcode bitor emit-half ;
: C.BEQZ ( rs imm -- ) 0xc001 cb-branch ;
: C.BNEZ ( rs imm -- ) 0xe001 cb-branch ;
:: C.SLLI ( rd shamt -- )
    rd R 7 shift shamt 5 unsigned-immediate
    { { 5 1 12 } { 0 5 2 } } scatter bitor 2 bitor emit-half ;
:: c-stack-load ( rd offset fp? size opcode -- )
    rd fp? [ F ] [ nonzero-register ] if 7 shift
    offset size 4 = 8 9 ? size aligned-immediate
    size 4 = { { 5 1 12 } { 2 3 4 } { 6 2 2 } }
    { { 5 1 12 } { 3 2 5 } { 6 3 2 } } ? scatter bitor opcode bitor emit-half ;
: C.LWSP ( rd offset -- ) f 4 0x4002 c-stack-load ;
: C.FLWSP ( rd offset -- ) t 4 0x6002 c-stack-load ;
: C.FLDSP ( rd offset -- ) t 8 0x2002 c-stack-load ;
:: c-stack-store ( rs offset fp? size opcode -- )
    rs fp? [ F ] [ R ] if 2 shift
    offset size 4 = 8 9 ? size aligned-immediate
    size 4 = { { 2 4 9 } { 6 2 7 } } { { 3 3 10 } { 6 3 7 } } ?
    scatter bitor opcode bitor emit-half ;
: C.SWSP ( rs offset -- ) f 4 0xc002 c-stack-store ;
: C.FSWSP ( rs offset -- ) t 4 0xe002 c-stack-store ;
: C.FSDSP ( rs offset -- ) t 8 0xa002 c-stack-store ;
: C.JR ( rs -- ) nonzero-register 7 shift 0x8002 bitor emit-half ;
: C.JALR ( rs -- ) nonzero-register 7 shift 0x9002 bitor emit-half ;
:: cr-insn ( rd rs opcode -- )
    rd R 7 shift rs nonzero-register 2 shift bitor opcode bitor emit-half ;
: C.MV ( rd rs -- ) 0x8002 cr-insn ;
: C.ADD ( rd rs -- ) 0x9002 cr-insn ;
: C.EBREAK ( -- ) 0x9002 emit-half ;
