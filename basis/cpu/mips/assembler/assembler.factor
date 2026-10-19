! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! MIPS32/MIPS64 classic ISA; branch displacements are bytes from PC + 4.
! Raw control transfers emit one instruction; callers supply the delay slot.
USING: accessors cpu.mips.assembler.registers endian kernel locals
make math math.bitwise namespaces ;
IN: cpu.mips.assembler
SYMBOL: mips-big-endian?
ERROR: invalid-mips-immediate value width ;
ERROR: invalid-mips-register reg ;
:: unsigned-immediate ( value width -- bits )
    value width bits value = [ value ] [ value width invalid-mips-immediate ] if ;
:: signed-immediate ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-mips-immediate ] if ;
: R ( reg -- n ) dup int-register? [ n>> 5 unsigned-immediate ] [ invalid-mips-register ] if ;
: F ( reg -- n ) dup fp-register? [ n>> 5 unsigned-immediate ] [ invalid-mips-register ] if ;
: emit-insn ( insn -- ) mips-big-endian? get [ 4 >be ] [ 4 >le ] if % ;
:: r-insn ( rd rs rt shamt function -- )
    rs R 21 shift rt R 16 shift bitor rd R 11 shift bitor
    shamt 5 unsigned-immediate 6 shift bitor function bitor emit-insn ;
:: i-insn ( rt rs imm opcode -- )
    rs R 21 shift rt R 16 shift bitor imm 16 signed-immediate bitor
    opcode 26 shift bitor emit-insn ;
:: u-insn ( rt rs imm opcode -- )
    rs R 21 shift rt R 16 shift bitor imm 16 unsigned-immediate bitor
    opcode 26 shift bitor emit-insn ;
:: branch-insn ( rs rt displacement opcode -- )
    displacement 3 bitand zero? [ ] [ displacement 18 invalid-mips-immediate ] if
    rt rs displacement -2 shift opcode i-insn ;
:: j-insn ( address opcode -- )
    address 3 bitand zero? [ ] [ address 28 invalid-mips-immediate ] if
    address -2 shift 26 unsigned-immediate opcode 26 shift bitor emit-insn ;
: ADDU ( rd rs rt -- ) 0 33 r-insn ;
: SUBU ( rd rs rt -- ) 0 35 r-insn ;
: AND ( rd rs rt -- ) 0 36 r-insn ;
: OR ( rd rs rt -- ) 0 37 r-insn ;
: XOR ( rd rs rt -- ) 0 38 r-insn ;
: NOR ( rd rs rt -- ) 0 39 r-insn ;
: SLT ( rd rs rt -- ) 0 42 r-insn ;
: SLTU ( rd rs rt -- ) 0 43 r-insn ;
: DADDU ( rd rs rt -- ) 0 45 r-insn ;
: DSUBU ( rd rs rt -- ) 0 47 r-insn ;
: ADDIU ( rt rs imm -- ) 9 i-insn ;
: SLTI ( rt rs imm -- ) 10 i-insn ;
: SLTIU ( rt rs imm -- ) 11 i-insn ;
: DADDIU ( rt rs imm -- ) 25 i-insn ;
: LB ( rt rs imm -- ) 32 i-insn ;
: LH ( rt rs imm -- ) 33 i-insn ;
: LW ( rt rs imm -- ) 35 i-insn ;
: LWL ( rt rs imm -- ) 34 i-insn ;
: LWR ( rt rs imm -- ) 38 i-insn ;
: SWL ( rt rs imm -- ) 42 i-insn ;
: SWR ( rt rs imm -- ) 46 i-insn ;
: LDL ( rt rs imm -- ) 26 i-insn ;
: LDR ( rt rs imm -- ) 27 i-insn ;
: SDL ( rt rs imm -- ) 44 i-insn ;
: SDR ( rt rs imm -- ) 45 i-insn ;
: LBU ( rt rs imm -- ) 36 i-insn ;
: LHU ( rt rs imm -- ) 37 i-insn ;
: LWU ( rt rs imm -- ) 39 i-insn ;
: SB ( rt rs imm -- ) 40 i-insn ;
: SH ( rt rs imm -- ) 41 i-insn ;
: SW ( rt rs imm -- ) 43 i-insn ;
: LD ( rt rs imm -- ) 55 i-insn ;
: SD ( rt rs imm -- ) 63 i-insn ;
: ANDI ( rt rs imm -- ) 12 u-insn ;
: ORI ( rt rs imm -- ) 13 u-insn ;
: XORI ( rt rs imm -- ) 14 u-insn ;
: LUI ( rt imm -- ) [ ZERO ] dip 15 u-insn ;
: SLL ( rd rt shamt -- ) [ ZERO ] 2dip 0 r-insn ;
: SRL ( rd rt shamt -- ) [ ZERO ] 2dip 2 r-insn ;
: SRA ( rd rt shamt -- ) [ ZERO ] 2dip 3 r-insn ;
: DSLL ( rd rt shamt -- ) [ ZERO ] 2dip 56 r-insn ;
: DSRL ( rd rt shamt -- ) [ ZERO ] 2dip 58 r-insn ;
: DSRA ( rd rt shamt -- ) [ ZERO ] 2dip 59 r-insn ;
: DSLL32 ( rd rt shamt -- ) [ ZERO ] 2dip 60 r-insn ;
: DSRL32 ( rd rt shamt -- ) [ ZERO ] 2dip 62 r-insn ;
: DSRA32 ( rd rt shamt -- ) [ ZERO ] 2dip 63 r-insn ;
 : BEQ ( rs rt displacement -- ) 4 branch-insn ;
: BNE ( rs rt displacement -- ) 5 branch-insn ;
: J ( address -- ) 2 j-insn ;
: JAL ( address -- ) 3 j-insn ;
: JR ( rs -- ) ZERO swap ZERO 0 8 r-insn ;
: JALR ( rd rs -- ) ZERO 0 9 r-insn ;
: NOP ( -- ) 0 emit-insn ;
: RET ( -- ) RA JR NOP ;
: CALL ( rs -- ) RA swap JALR NOP ;
: JUMP ( rs -- ) JR NOP ;
:: cop1-insn ( fd fs ft fmt function -- )
    17 26 shift fmt 21 shift bitor ft F 16 shift bitor
    fs F 11 shift bitor fd F 6 shift bitor function bitor emit-insn ;
: ADD.S ( fd fs ft -- ) 16 0 cop1-insn ;
: SUB.S ( fd fs ft -- ) 16 1 cop1-insn ;
: MUL.S ( fd fs ft -- ) 16 2 cop1-insn ;
: DIV.S ( fd fs ft -- ) 16 3 cop1-insn ;
: ADD.D ( fd fs ft -- ) 17 0 cop1-insn ;
: SUB.D ( fd fs ft -- ) 17 1 cop1-insn ;
: MUL.D ( fd fs ft -- ) 17 2 cop1-insn ;
: DIV.D ( fd fs ft -- ) 17 3 cop1-insn ;

! HI/LO arithmetic must be scheduled by the backend for the target ISA.
:: hilo-insn ( rs rt function -- ) ZERO rs rt 0 function r-insn ;
: MULT ( rs rt -- ) 24 hilo-insn ;
: MULTU ( rs rt -- ) 25 hilo-insn ;
: DIV ( rs rt -- ) 26 hilo-insn ;
: DIVU ( rs rt -- ) 27 hilo-insn ;
: DMULT ( rs rt -- ) 28 hilo-insn ;
: DMULTU ( rs rt -- ) 29 hilo-insn ;
: DDIV ( rs rt -- ) 30 hilo-insn ;
: DDIVU ( rs rt -- ) 31 hilo-insn ;
: MFHI ( rd -- ) ZERO ZERO 0 16 r-insn ;
: MFLO ( rd -- ) ZERO ZERO 0 18 r-insn ;
: MTHI ( rs -- ) ZERO swap ZERO 0 17 r-insn ;
: MTLO ( rs -- ) ZERO swap ZERO 0 19 r-insn ;
: SLLV ( rd rt rs -- ) swap 0 4 r-insn ;
: SRLV ( rd rt rs -- ) swap 0 6 r-insn ;
: SRAV ( rd rt rs -- ) swap 0 7 r-insn ;
: DSLLV ( rd rt rs -- ) swap 0 20 r-insn ;
: DSRLV ( rd rt rs -- ) swap 0 22 r-insn ;
: DSRAV ( rd rt rs -- ) swap 0 23 r-insn ;
: MOV ( rd rs -- ) ZERO OR ;
: NOT ( rd rs -- ) ZERO NOR ;
: NEG ( rd rs -- ) [ ZERO ] dip SUBU ;
: DNEG ( rd rs -- ) [ ZERO ] dip DSUBU ;
: BLEZ ( rs displacement -- ) [ ZERO ] dip 6 branch-insn ;
: BGTZ ( rs displacement -- ) [ ZERO ] dip 7 branch-insn ;
: BLTZ ( rs displacement -- ) [ R0 ] dip 1 branch-insn ;
: BGEZ ( rs displacement -- ) [ R1 ] dip 1 branch-insn ;
:: fp-memory ( ft base offset opcode -- )
    opcode 26 shift base R 21 shift bitor ft F 16 shift bitor
    offset 16 signed-immediate bitor emit-insn ;
: LWC1 ( ft base offset -- ) 49 fp-memory ;
: LDC1 ( ft base offset -- ) 53 fp-memory ;
: SWC1 ( ft base offset -- ) 57 fp-memory ;
: SDC1 ( ft base offset -- ) 61 fp-memory ;
:: cop1-transfer ( rt fs kind -- )
    17 26 shift kind 21 shift bitor rt R 16 shift bitor
    fs F 11 shift bitor emit-insn ;
: MFC1 ( rt fs -- ) 0 cop1-transfer ;
: DMFC1 ( rt fs -- ) 1 cop1-transfer ;
: CFC1 ( rt fs -- ) 2 cop1-transfer ;
: MTC1 ( rt fs -- ) 4 cop1-transfer ;
: DMTC1 ( rt fs -- ) 5 cop1-transfer ;
: CTC1 ( rt fs -- ) 6 cop1-transfer ;
: SQRT.S ( fd fs -- ) F0 16 4 cop1-insn ;
: ABS.S ( fd fs -- ) F0 16 5 cop1-insn ;
: MOV.S ( fd fs -- ) F0 16 6 cop1-insn ;
: NEG.S ( fd fs -- ) F0 16 7 cop1-insn ;
: TRUNC.L.S ( fd fs -- ) F0 16 9 cop1-insn ;
: TRUNC.W.S ( fd fs -- ) F0 16 13 cop1-insn ;
: SQRT.D ( fd fs -- ) F0 17 4 cop1-insn ;
: ABS.D ( fd fs -- ) F0 17 5 cop1-insn ;
: MOV.D ( fd fs -- ) F0 17 6 cop1-insn ;
: NEG.D ( fd fs -- ) F0 17 7 cop1-insn ;
: TRUNC.L.D ( fd fs -- ) F0 17 9 cop1-insn ;
: TRUNC.W.D ( fd fs -- ) F0 17 13 cop1-insn ;
: CVT.D.S ( fd fs -- ) F0 16 33 cop1-insn ;
: CVT.S.D ( fd fs -- ) F0 17 32 cop1-insn ;
: CVT.D.W ( fd fs -- ) F0 20 33 cop1-insn ;
: CVT.D.L ( fd fs -- ) F0 21 33 cop1-insn ;

! Fixed-size literal templates retain stable relocation and call-site offsets.
! LI32 builds an exact 32-bit pattern (sign-extended on a MIPS64 CPU).
:: LI32 ( rd value -- )
    rd value -16 shift 16 bits LUI
    rd rd value 16 bits ORI ;
! LI64 builds all bits without a signed LUI intermediate.
:: LI64 ( rd value -- )
    rd ZERO value -48 shift 16 bits ORI
    rd rd 16 DSLL rd rd value -32 shift 16 bits ORI
    rd rd 16 DSLL rd rd value -16 shift 16 bits ORI
    rd rd 16 DSLL rd rd value 16 bits ORI ;
: CALL32 ( address -- ) T9 swap LI32 T9 CALL ;
: JUMP32 ( address -- ) T9 swap LI32 T9 JUMP ;
: CALL64 ( address -- ) T9 swap LI64 T9 CALL ;
: JUMP64 ( address -- ) T9 swap LI64 T9 JUMP ;

! Default COP1 condition code 0. Floating comparisons may raise IEEE exceptions.
:: fp-compare ( fs ft fmt function -- )
    17 26 shift fmt 21 shift bitor ft F 16 shift bitor
    fs F 11 shift bitor function bitor emit-insn ;
: C.EQ.S ( fs ft -- ) 16 50 fp-compare ;
: C.EQ.D ( fs ft -- ) 17 50 fp-compare ;
: C.LT.S ( fs ft -- ) 16 60 fp-compare ;
: C.LT.D ( fs ft -- ) 17 60 fp-compare ;
: C.LE.S ( fs ft -- ) 16 62 fp-compare ;
: C.LE.D ( fs ft -- ) 17 62 fp-compare ;
: C.UN.S ( fs ft -- ) 16 49 fp-compare ;
: C.UN.D ( fs ft -- ) 17 49 fp-compare ;
:: fp-branch ( displacement true? -- )
    displacement 3 bitand zero? [ ] [ displacement 18 invalid-mips-immediate ] if
    17 26 shift 8 21 shift bitor true? 16 shift bitor
    displacement -2 shift 16 signed-immediate bitor emit-insn ;
: BC1F ( displacement -- ) 0 fp-branch ;
: BC1T ( displacement -- ) 1 fp-branch ;
: LL ( rt rs imm -- ) 48 i-insn ;
: LLD ( rt rs imm -- ) 52 i-insn ;
: SC ( rt rs imm -- ) 56 i-insn ;
: SCD ( rt rs imm -- ) 60 i-insn ;
: MOVZ ( rd rs rt -- ) 0 10 r-insn ;
: MOVN ( rd rs rt -- ) 0 11 r-insn ;
: SYNC ( -- ) 15 emit-insn ;
: BREAK ( -- ) 13 emit-insn ;
: SYSCALL ( -- ) 12 emit-insn ;
