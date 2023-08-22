! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators kernel make math math.bitwise
namespaces sequences words words.symbol parser ;
IN: cpu.arm.32.assembler

! Registers
<<

SYMBOL: registers

V{ } registers set-global

SYNTAX: REGISTER:
    scan-new-word
    [ define-symbol ]
    [ registers get length "register" set-word-prop ]
    [ registers get push ]
    tri ;

>>

REGISTER: R0
REGISTER: R1
REGISTER: R2
REGISTER: R3
REGISTER: R4
REGISTER: R5
REGISTER: R6
REGISTER: R7
REGISTER: R8
REGISTER: R9
REGISTER: R10
REGISTER: R11
REGISTER: R12
REGISTER: R13
REGISTER: R14
REGISTER: R15

ALIAS: SL R10 ALIAS: FP R11 ALIAS: IP R12
ALIAS: SP R13 ALIAS: LR R14 ALIAS: PC R15

<PRIVATE

GENERIC: register ( register -- n )
M: word register "register" word-prop ;
M: f register drop 0 ;

PREDICATE: register-class < word register >boolean ;

PRIVATE>

! Condition codes
SYMBOL: cond-code

: >CC ( n -- )
    cond-code set ;

: CC> ( -- n )
    ! Default value is 0b1110 AL (= always)
    cond-code [ f ] change 0b1110 or ;

: EQ ( -- ) 0b0000 >CC ;
: NE ( -- ) 0b0001 >CC ;
: CS ( -- ) 0b0010 >CC ;
: CC ( -- ) 0b0011 >CC ;
: LO ( -- ) 0b0100 >CC ;
: PL ( -- ) 0b0101 >CC ;
: VS ( -- ) 0b0110 >CC ;
: VC ( -- ) 0b0111 >CC ;
: HI ( -- ) 0b1000 >CC ;
: LS ( -- ) 0b1001 >CC ;
: GE ( -- ) 0b1010 >CC ;
: LT ( -- ) 0b1011 >CC ;
: GT ( -- ) 0b1100 >CC ;
: LE ( -- ) 0b1101 >CC ;
: AL ( -- ) 0b1110 >CC ;
: NV ( -- ) 0b1111 >CC ;

<PRIVATE

: (insn) ( n -- ) CC> 28 shift bitor , ;

: insn ( bitspec -- ) bitfield (insn) ; inline

! Branching instructions
GENERIC#: (B) 1 ( target l -- )

M: integer (B) { 24 { 1 25 } { 0 26 } { 1 27 } 0 } insn ;

PRIVATE>

: B ( target -- ) 0 (B) ;
: BL ( target -- ) 1 (B) ;

! Data processing instructions
<PRIVATE

SYMBOL: updates-cond-code

PRIVATE>

: S ( -- ) updates-cond-code on ;

: S> ( -- ? ) updates-cond-code [ f ] change ;

<PRIVATE

: sinsn ( bitspec -- )
    bitfield S> [ 20 2^ bitor ] when (insn) ; inline

GENERIC#: shift-imm/reg 2 ( shift-imm/Rs Rm shift -- n )

M: integer shift-imm/reg ( shift-imm Rm shift -- n )
    { { 0 4 } 5 { register 0 } 7 } bitfield ;

M: register-class shift-imm/reg ( Rs Rm shift -- n )
    {
        { 1 4 }
        { 0 7 }
        5
        { register 8 }
        { register 0 }
    } bitfield ;

PRIVATE>

TUPLE: IMM immed rotate ;
C: <IMM> IMM

TUPLE: shifter Rm by shift ;
C: <shifter> shifter

<PRIVATE

GENERIC: shifter-op ( shifter-op -- n )

M: IMM shifter-op
    [ immed>> ] [ rotate>> ] bi { { 1 25 } 8 0 } bitfield ;

M: shifter shifter-op
    [ by>> ] [ Rm>> ] [ shift>> ] tri shift-imm/reg ;

PRIVATE>

: <LSL> ( Rm shift-imm/Rs -- shifter-op ) 0b00 <shifter> ;
: <LSR> ( Rm shift-imm/Rs -- shifter-op ) 0b01 <shifter> ;
: <ASR> ( Rm shift-imm/Rs -- shifter-op ) 0b10 <shifter> ;
: <ROR> ( Rm shift-imm/Rs -- shifter-op ) 0b11 <shifter> ;
: <RRX> ( Rm -- shifter-op ) 0 <ROR> ;

M: register-class shifter-op 0 <LSL> shifter-op ;
M: integer shifter-op 0 <IMM> shifter-op ;

<PRIVATE

: addr1 ( Rd Rn shifter-op opcode -- )
    {
        21 ! opcode
        { shifter-op 0 }
        { register 16 } ! Rn
        { register 12 } ! Rd
    } sinsn ;

PRIVATE>

: AND ( Rd Rn shifter-op -- ) 0b0000 addr1 ;
: EOR ( Rd Rn shifter-op -- ) 0b0001 addr1 ;
: SUB ( Rd Rn shifter-op -- ) 0b0010 addr1 ;
: RSB ( Rd Rn shifter-op -- ) 0b0011 addr1 ;
: ADD ( Rd Rn shifter-op -- ) 0b0100 addr1 ;
: ADC ( Rd Rn shifter-op -- ) 0b0101 addr1 ;
: SBC ( Rd Rn shifter-op -- ) 0b0110 addr1 ;
: RSC ( Rd Rn shifter-op -- ) 0b0111 addr1 ;
: ORR ( Rd Rn shifter-op -- ) 0b1100 addr1 ;
: BIC ( Rd Rn shifter-op -- ) 0b1110 addr1 ;

: MOV ( Rd shifter-op -- ) [ f ] dip 0b1101 addr1 ;
: MVN ( Rd shifter-op -- ) [ f ] dip 0b1111 addr1 ;

! These always update the condition code flags
<PRIVATE

: (CMP) ( Rn shifter-op opcode -- ) [ f ] 3dip S addr1 ;

PRIVATE>

: TST ( Rn shifter-op -- ) 0b1000 (CMP) ;
: TEQ ( Rn shifter-op -- ) 0b1001 (CMP) ;
: CMP ( Rn shifter-op -- ) 0b1010 (CMP) ;
: CMN ( Rn shifter-op -- ) 0b1011 (CMP) ;

! Multiply instructions
<PRIVATE

: (MLA) ( Rd Rm Rs Rn a -- )
    {
        21
        { register 12 }
        { register 8 }
        { register 0 }
        { register 16 }
        { 1 7 }
        { 1 4 }
    } sinsn ;

: (S/UMLAL)  ( RdLo RdHi Rm Rs s a -- )
    {
        { 1 23 }
        22
        21
        { register 8 }
        { register 0 }
        { register 16 }
        { register 12 }
        { 1 7 }
        { 1 4 }
    } sinsn ;

PRIVATE>

: MUL ( Rd Rm Rs -- ) f 0 (MLA) ;
: MLA ( Rd Rm Rs Rn -- ) 1 (MLA) ;

: SMLAL ( RdLo RdHi Rm Rs -- ) 1 1 (S/UMLAL) ;
: SMULL ( RdLo RdHi Rm Rs -- ) 1 0 (S/UMLAL) ;
: UMLAL ( RdLo RdHi Rm Rs -- ) 0 1 (S/UMLAL) ;
: UMULL ( RdLo RdHi Rm Rs -- ) 0 0 (S/UMLAL) ;

! Miscellaneous arithmetic instructions
: CLZ ( Rd Rm -- )
    {
        { 1 24 }
        { 1 22 }
        { 1 21 }
        { 0b111 16 }
        { 0b1111 8 }
        { 1 4 }
        { register 0 }
        { register 12 }
    } sinsn ;

! Status register acess instructions

! Load and store instructions
<PRIVATE

GENERIC: addressing-mode-2 ( addressing-mode -- n )

TUPLE: addressing base p u w ;
C: <addressing> addressing

M: addressing addressing-mode-2
    { [ p>> ] [ u>> ] [ w>> ] [ base>> addressing-mode-2 ] } cleave
    { 0 21 23 24 } bitfield ;

M: integer addressing-mode-2 ;

M: object addressing-mode-2 shifter-op { { 1 25 } 0 } bitfield ;

: addr2 ( Rd Rn addressing-mode b l -- )
    {
        { 1 26 }
        20
        22
        { addressing-mode-2 0 }
        { register 16 }
        { register 12 }
    } insn ;

PRIVATE>

! Offset
: <+> ( base -- addressing ) 1 1 0 <addressing> ;
: <-> ( base -- addressing ) 1 0 0 <addressing> ;

! Pre-indexed
: <!+> ( base -- addressing ) 1 1 1 <addressing> ;
: <!-> ( base -- addressing ) 1 0 1 <addressing> ;

! Post-indexed
: <+!> ( base -- addressing ) 0 1 0 <addressing> ;
: <-!> ( base -- addressing ) 0 0 0 <addressing> ;

: LDR  ( Rd Rn addressing-mode -- ) 0 1 addr2 ;
: LDRB ( Rd Rn addressing-mode -- ) 1 1 addr2 ;
: STR  ( Rd Rn addressing-mode -- ) 0 0 addr2 ;
: STRB ( Rd Rn addressing-mode -- ) 1 0 addr2 ;

! We might have to simulate these instructions since older ARM
! chips don't have them.
SYMBOL: have-BX?
SYMBOL: have-BLX?

<PRIVATE

GENERIC#: (BX) 1 ( Rm l -- )

M: register-class (BX) ( Rm l -- )
    {
        { 1 24 }
        { 1 21 }
        { 0b1111 16 }
        { 0b1111 12 }
        { 0b1111 8 }
        5
        { 1 4 }
        { register 0 }
    } insn ;

PRIVATE>

: BX ( Rm -- ) have-BX? get [ 0 (BX) ] [ [ PC ] dip MOV ] if ;

: BLX ( Rm -- ) have-BLX? get [ 1 (BX) ] [ LR PC MOV BX ] if ;

! More load and store instructions
<PRIVATE

GENERIC: addressing-mode-3 ( addressing-mode -- n )

: b>n/n ( b -- n n ) [ -4 shift ] [ 0xf bitand ] bi ;

M: addressing addressing-mode-3
    { [ p>> ] [ u>> ] [ w>> ] [ base>> addressing-mode-3 ] } cleave
    { 0 21 23 24 } bitfield ;

M: integer addressing-mode-3
    b>n/n {
        ! { 1 24 }
        { 1 22 }
        { 1 7 }
        { 1 4 }
        0
        8
    } bitfield ;

M: object addressing-mode-3
    shifter-op {
        ! { 1 24 }
        { 1 7 }
        { 1 4 }
        0
    } bitfield ;

: addr3 ( Rn Rd addressing-mode h l s -- )
    {
        6
        20
        5
        { addressing-mode-3 0 }
        { register 16 }
        { register 12 }
    } insn ;

PRIVATE>

: LDRH  ( Rn Rd addressing-mode -- ) 1 1 0 addr3 ;
: LDRSB ( Rn Rd addressing-mode -- ) 0 1 1 addr3 ;
: LDRSH ( Rn Rd addressing-mode -- ) 1 1 1 addr3 ;
: STRH  ( Rn Rd addressing-mode -- ) 1 0 0 addr3 ;

! Load and store multiple instructions

! Semaphore instructions

! Exception-generating instructions
