! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generator generator.fixup kernel sequences words
namespaces math math.bitfields ;
IN: cpu.arm.assembler

: define-registers ( seq -- )
    dup length [ "register" set-word-prop ] 2each ;

SYMBOL: R0
SYMBOL: R1
SYMBOL: R2
SYMBOL: R3
SYMBOL: R4
SYMBOL: R5
SYMBOL: R6
SYMBOL: R7
SYMBOL: R8
SYMBOL: R9
SYMBOL: R10
SYMBOL: R11
SYMBOL: R12
SYMBOL: R13
SYMBOL: R14
SYMBOL: R15

{ R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 R13 R14 R15 }
define-registers

PREDICATE: register < word register >boolean ;

GENERIC: register ( register -- n )
M: word register "register" word-prop ;
M: f register drop 0 ;

: SL R10 ; inline : FP R11 ; inline : IP R12 ; inline
: SP R13 ; inline : LR R14 ; inline : PC R15 ; inline

! Condition codes
SYMBOL: cond-code

: >CC ( n -- )
    cond-code set ;

: CC> ( -- n )
    #! Default value is BIN: 1110 AL (= always)
    cond-code [ f ] change BIN: 1110 or ;

: EQ BIN: 0000 >CC ;
: NE BIN: 0001 >CC ;
: CS BIN: 0010 >CC ;
: CC BIN: 0011 >CC ;
: LO BIN: 0100 >CC ;
: PL BIN: 0101 >CC ;
: VS BIN: 0110 >CC ;
: VC BIN: 0111 >CC ;
: HI BIN: 1000 >CC ;
: LS BIN: 1001 >CC ;
: GE BIN: 1010 >CC ;
: LT BIN: 1011 >CC ;
: GT BIN: 1100 >CC ;
: LE BIN: 1101 >CC ;
: AL BIN: 1110 >CC ;
: NV BIN: 1111 >CC ;

: (insn) ( n -- ) CC> 28 shift bitor , ;

: insn ( bitspec -- ) bitfield (insn) ; inline

! Branching instructions
GENERIC# (B) 1 ( signed-imm-24 l -- )

M: integer (B) { 24 { 1 25 } { 0 26 } { 1 27 } 0 } insn ;
M: word (B) 0 swap (B) rc-relative-arm-3 rel-word ;
M: label (B) 0 swap (B) rc-relative-arm-3 label-fixup ;

: B 0 (B) ; : BL 1 (B) ;

! Data processing instructions
SYMBOL: updates-cond-code

: S ( -- ) updates-cond-code on ;

: S> ( -- ? ) updates-cond-code [ f ] change ;

: sinsn ( bitspec -- )
    bitfield S> [ 20 2^ bitor ] when (insn) ; inline

GENERIC# shift-imm/reg 2 ( shift-imm/Rs Rm shift -- n )

M: integer shift-imm/reg ( shift-imm Rm shift -- n )
    { { 0 4 } 5 { register 0 } 7 } bitfield ;

M: register shift-imm/reg ( Rs Rm shift -- n )
    {
        { 1 4 }
        { 0 7 }
        5
        { register 8 }
        { register 0 }
    } bitfield ;

GENERIC: shifter-op ( shifter-op -- n )

TUPLE: IMM immed rotate ;
C: <IMM> IMM

M: IMM shifter-op
    dup IMM-immed swap IMM-rotate
    { { 1 25 } 8 0 } bitfield ;

TUPLE: shifter Rm by shift ;
C: <shifter> shifter

M: shifter shifter-op
    dup shifter-by over shifter-Rm rot shifter-shift
    shift-imm/reg ;

: <LSL> ( Rm shift-imm/Rs -- shifter-op ) BIN: 00 <shifter> ;
: <LSR> ( Rm shift-imm/Rs -- shifter-op ) BIN: 01 <shifter> ;
: <ASR> ( Rm shift-imm/Rs -- shifter-op ) BIN: 10 <shifter> ;
: <ROR> ( Rm shift-imm/Rs -- shifter-op ) BIN: 11 <shifter> ;
: <RRX> ( Rm -- shifter-op ) 0 <ROR> ;

M: register shifter-op 0 <LSL> shifter-op ;

M: integer shifter-op 0 <IMM> shifter-op ;

: addr1 ( Rd Rn shifter-op opcode -- )
    {
        21 ! opcode
        { shifter-op 0 }
        { register 16 } ! Rn
        { register 12 } ! Rd
    } sinsn ;

: AND BIN: 0000 addr1 ;
: EOR BIN: 0001 addr1 ;
: SUB BIN: 0010 addr1 ;
: RSB BIN: 0011 addr1 ;
: ADD BIN: 0100 addr1 ;
: ADC BIN: 0101 addr1 ;
: SBC BIN: 0110 addr1 ;
: RSC BIN: 0111 addr1 ;
: ORR BIN: 1100 addr1 ;
: BIC BIN: 1110 addr1 ;

: MOV f swap BIN: 1101 addr1 ;
: MVN f swap BIN: 1111 addr1 ;

! These always update the condition code flags
: (CMP) >r f -rot r> S addr1 ;

: TST BIN: 1000 (CMP) ;
: TEQ BIN: 1001 (CMP) ;
: CMP BIN: 1010 (CMP) ;
: CMN BIN: 1011 (CMP) ;

! Multiply instructions
: (MLA)  ( Rd Rm Rs Rn a -- )
    {
        21
        { register 12 }
        { register 8 }
        { register 0 }
        { register 16 }
        { 1 7 }
        { 1 4 }
    } sinsn ;

: MUL ( Rd Rm Rs -- ) f 0 (MLA) ;
: MLA ( Rd Rm Rs Rn -- ) 1 (MLA) ;

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

: SMLAL 1 1 (S/UMLAL) ; : SMULL 1 0 (S/UMLAL) ;
: UMLAL 0 1 (S/UMLAL) ; : UMULL 0 0 (S/UMLAL) ;

! Miscellaneous arithmetic instructions
: CLZ ( Rd Rm -- )
    {
        { 1 24 }
        { 1 22 }
        { 1 21 }
        { BIN: 111 16 }
        { BIN: 1111 8 }
        { 1 4 }
        { register 0 }
        { register 12 }
    } sinsn ;

! Status register acess instructions

! Load and store instructions
GENERIC: addressing-mode-2 ( addressing-mode -- n )

TUPLE: addressing p u w ;
: <addressing> ( delegate p u w -- addressing )
    {
        set-delegate
        set-addressing-p
        set-addressing-u
        set-addressing-w
    } addressing construct ;

M: addressing addressing-mode-2
    {
        addressing-p addressing-u addressing-w delegate
    } get-slots addressing-mode-2
    { 0 21 23 24 } bitfield ;

M: integer addressing-mode-2 ;

M: object addressing-mode-2 shifter-op { { 1 25 } 0 } bitfield ;

! Offset
: <+> 1 1 0 <addressing> ;
: <-> 1 0 0 <addressing> ;

! Pre-indexed
: <!+> 1 1 1 <addressing> ;
: <!-> 1 0 1 <addressing> ;

! Post-indexed
: <+!> 0 1 0 <addressing> ;
: <-!> 0 0 0 <addressing> ;

: addr2 ( Rd Rn addressing-mode b l -- )
    {
        { 1 26 }
        20
        22
        { addressing-mode-2 0 }
        { register 16 }
        { register 12 }
    } insn ;

: LDR 0 1 addr2 ;
: LDRB 1 1 addr2 ;
: STR 0 0 addr2 ;
: STRB 1 0 addr2 ;

! We might have to simulate these instructions since older ARM
! chips don't have them.
SYMBOL: have-BX?
SYMBOL: have-BLX?

GENERIC# (BX) 1 ( Rm l -- )

M: register (BX) ( Rm l -- )
    {
        { 1 24 }
        { 1 21 }
        { BIN: 1111 16 }
        { BIN: 1111 12 }
        { BIN: 1111 8 }
        5
        { 1 4 }
        { register 0 }
    } insn ;

M: word (BX) 0 swap (BX) rc-relative-arm-3 rel-word ;

M: label (BX) 0 swap (BX) rc-relative-arm-3 label-fixup ;

: BX have-BX? get [ 0 (BX) ] [ PC swap MOV ] if ;

: BLX have-BLX? get [ 1 (BX) ] [ LR PC MOV BX ] if ;

! More load and store instructions
GENERIC: addressing-mode-3 ( addressing-mode -- n )

: b>n/n ( b -- n n ) dup -4 shift swap HEX: f bitand ;

M: addressing addressing-mode-3
    [ addressing-p ] keep
    [ addressing-u ] keep
    [ addressing-w ] keep
    delegate addressing-mode-3
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

: LDRH 1 1 0 addr3 ;
: LDRSB 0 1 1 addr3 ;
: LDRSH 1 1 1 addr3 ;
: STRH 1 0 0 addr3 ;

! Load and store multiple instructions

! Semaphore instructions

! Exception-generating instructions
