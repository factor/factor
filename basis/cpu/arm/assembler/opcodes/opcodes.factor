! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.error classes.parser effects
effects.parser endian kernel lexer make math math.bitwise
math.parser multiline parser sequences vocabs.parser words
words.symbol ;
IN: cpu.arm.assembler.opcodes

! https://developer.arm.com/documentation/ddi0487/latest/
! https://static.docs.arm.com/ddi0487/fb/DDI0487F_b_armv8_arm.pdf ! initial work
! https://static.docs.arm.com/ddi0487/fb/DDI0487G_a_armv8_arm.pdf ! 3/13/21

<<
SYNTAX: REGISTERS:
    ";"
    [
        create-word-in
        [ define-symbol ]
        [ dup name>> 1 tail string>number "ordinal" set-word-prop ] bi
    ] each-token ;
>>

<<
GENERIC: register ( obj -- n )
M: word register "ordinal" word-prop ;
M: integer register ;
: error-word ( word -- new-class )
    name>> "-range" append create-class-in dup save-location
    tuple
    { "value" }
    [ define-error-class ] keepdd ;

: make-checker-word ( word n -- )
    [ drop dup error-word ]
    [ nip swap '[ dup _ on-bits > [ _ execute( value -- * ) ] when ] ]
    [ 2drop ( n -- n ) ] 2tri
    define-declared ;

SYNTAX: FIELD:
    scan-new-word scan-object
    [ "width" set-word-prop ] 2keep
    make-checker-word ;

: make-register-checker-word ( word n -- )
    [ drop dup error-word '[ _ execute( value -- * ) ] ]
    [ nip swap '[ register dup _ on-bits > _ when ] ]
    [ 2drop ( n -- n ) ] 2tri
    define-declared ;

SYNTAX: REGISTER-FIELD:
    scan-new-word scan-object
    [ "width" set-word-prop ] 2keep
    make-register-checker-word ;
>>

<<
FIELD: op1 1
FIELD: op2 2
FIELD: op3 3
FIELD: op4 4
FIELD: op5 5
FIELD: op6 6
FIELD: op7 7
FIELD: op8 8
FIELD: op9 9
FIELD: op10 10

FIELD: opc1 1
FIELD: opc2 2
FIELD: opc3 3
FIELD: opc4 4

FIELD: option1 1
FIELD: option2 2
FIELD: option3 3
FIELD: option4 4
FIELD: option5 5

FIELD: a1 1
FIELD: b1 1
FIELD: c1 1
FIELD: d1 1
FIELD: e1 1
FIELD: f1 1
FIELD: g1 1
FIELD: h1 1

FIELD: A 1
FIELD: D 1
FIELD: L 1
FIELD: M 1
FIELD: N 1
FIELD: Q 1
FIELD: S 1
FIELD: U 1
FIELD: Z 1

FIELD: sf 1

FIELD: size1 1
FIELD: size2 2

FIELD: shift2 2

FIELD: b40 5

FIELD: immr 6
FIELD: imms 6
FIELD: immrimms 12
FIELD: Nimmrimms 13
FIELD: imm3 3
FIELD: imm4 4
FIELD: imm5 5
FIELD: imm6 6
FIELD: imm7 7
FIELD: imm9 9
FIELD: imm12 12
FIELD: imm13 13
FIELD: imm14 14
FIELD: imm16 16
FIELD: imm19 19
FIELD: imm26 26

FIELD: simm7 7
FIELD: uimm4 4
FIELD: uimm6 6

FIELD: immlo2 2
FIELD: immhi19 19

FIELD: cond4 4
FIELD: CRm 4
FIELD: CRn 4
FIELD: nzcv 4
FIELD: hw2 2
FIELD: mask4 4

REGISTER-FIELD: Ra 5
REGISTER-FIELD: Rm 5
REGISTER-FIELD: Rn 5
REGISTER-FIELD: Rd 5
REGISTER-FIELD: Rs 5
REGISTER-FIELD: Rt 5
REGISTER-FIELD: Rt2 5
REGISTER-FIELD: Xd 5
REGISTER-FIELD: Xm 5
REGISTER-FIELD: Xn 5
REGISTER-FIELD: Xt 5
REGISTER-FIELD: Xt2 5

! General purpose registers, 64bit
REGISTERS: X0 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12
X13 X14 X15 X16 X17 X18 X19 X20 X21 X22 X23 X24 X25
X26 X27 X28 X29 X30 ;

! Lower registers, shared with X0..X30, 32bit
REGISTERS: W0 W1 W2 W3 W4 W5 W6 W7 W8 W9 W10 W11 W12
W13 W14 W15 W16 W17 W18 W19 W20 W21 W22 W23 W24 W25
W26 W27 W28 W29 W30 ;

! https://static.docs.arm.com/ddi0487/fb/DDI0487F_b_armv8_arm.pdf pgA1-42
! Neon registers (SIMD Scalar) Q/D/S/H/B 128/64/32/16/8 bits
REGISTERS: V0 V1 V2 V3 V4 V5 V6 V7 V8 V9 V10 V11 V12
V13 V14 V15 V16 V17 V18 V19 V20 V21 V22 V23 V24 V25
V26 V27 V28 V29 V30 V31 ;

REGISTERS: B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 B10 B11 B12
B13 B14 B15 B16 B17 B18 B19 B20 B21 B22 B23 B24 B25
B26 B27 B28 B29 B30 B31 ;

REGISTERS: H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 H10 H11 H12
H13 H14 H15 H16 H17 H18 H19 H20 H21 H22 H23 H24 H25
H26 H27 H28 H29 H30 H31 ;

REGISTERS: S0 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12
S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S25
S26 S27 S28 S29 S30 S31 ;

REGISTERS: D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12
D13 D14 D15 D16 D17 D18 D19 D20 D21 D22 D23 D24 D25
D26 D27 D28 D29 D30 D31 ;

REGISTERS: Q0 Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12
Q13 Q14 Q15 Q16 Q17 Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25
Q26 Q27 Q28 Q29 Q30 Q31 ;

CONSTANT: SP 31
CONSTANT: WSP 31
CONSTANT: WZR 31
CONSTANT: XZR 31

! Zero/discard register 31, ZR WZR XZR - reads 0 always, writes to it succeed
! Stack Pointer register 31 WSP SP
! SINGLETONS: WZR XZR ; ! alias for register 31
! SINGLETONS: WSP SP ; ! alias for register 31 which does not exist
! Rn - register

! PSTATE EL0: NZCV, DAIF, 

! EL - exception level. application 0, OS (priv) 1, hypervisor 2, low-level 3

! Stack Pointer EL0 is 64bit, rest are 32bit
SINGLETONS: SP_EL0 SP_EL1 SP_EL2 SP_EL3 ;

! Exception link registers, 64bit
SINGLETONS: ELR_EL1 ELR_EL2 ELR_EL3 ;

! Saved program status registers, exception level, 64bit
SINGLETONS: SPSR_EL1 SPSR_EL2 SPSR_EL3 ;

! Program counter, 64bit
! SINGLETONS: PC ; ! not accessible (?)

! Flags: N negative, Z zero, C carry, V overflow, SS software step, IL illegal execution
! D debug, A SError system error, I IRQ normal interrupt, F FIQ fast interrupt

! Distinct L1 I-cache (instruction) and D-cache (data), unified L2 cache
! 4kb page size alignment, unaligned accepted

! PCS Procedure Call Standard X0-X7 parameters/results registers
! X9-X15 caller-saved temp regs (use)
! X19-X29 callee-saved (preserved)
! X8 indirect result register, syscalls register
! X16 X17 are IP0 and IP1, intra-procedure temp regs (avoid)
! X18 platform-register (avoid)
! X29 FP frame pointer register (avoid)
! X30 LR link register (avoid)

![[
(bits(N), bit) LSL_C(bits(N) x, integer shift)
    assert shift > 0;
    shift = if shift > N then N else shift;
    extended_x = x : Zeros(shift);
    result = extended_x<N-1:0>;
    carry_out = extended_x<N>;
    return (result, carry_out);
]]

! Instructions

! https://community.element14.com/products/devtools/technicallibrary/m/files/10863
! pg 16
! cond code set in previous arm assembly instruction
: EQ ( -- n ) 0b0000 ; inline ! Z set: equal
: NE ( -- n ) 0b0001 ; inline ! Z clear: not equal
: CS ( -- n ) 0b0010 ; inline ! C set: unsigned higher or same
: HS ( -- n ) 0b0010 ; inline !
: CC ( -- n ) 0b0011 ; inline ! C clear: unsigned lower
: LO ( -- n ) 0b0011 ; inline !
: MI ( -- n ) 0b0100 ; inline ! N set: negative
: PL ( -- n ) 0b0101 ; inline ! N clear: positive or zero
: VS ( -- n ) 0b0110 ; inline ! V set: overflow
: VC ( -- n ) 0b0111 ; inline ! V clear: no overflow
: HI ( -- n ) 0b1000 ; inline ! C set and Z clear: unsigned higher
: LS ( -- n ) 0b1001 ; inline ! C clear or Z set: unsigned lower or same
: GE ( -- n ) 0b1010 ; inline ! N equals V: greater or equal
: LT ( -- n ) 0b1011 ; inline ! N not equal to V: less than
: GT ( -- n ) 0b1100 ; inline ! Z clear AND (N equals V): greater than
: LE ( -- n ) 0b1101 ; inline ! Z set OR (N not equal to V): less than or equal
: AL ( -- n ) 0b1110 ; inline ! always
: NV ( -- n ) 0b1111 ; inline ! always

ERROR: no-field-word vocab name ;

TUPLE: integer-literal value width ;
C: <integer-literal> integer-literal

! handle 1xx0 where x = dontcare
: make-integer-literal ( string -- integer-literal )
    [ "0b" prepend { { CHAR: x CHAR: 0 } } substitute string>number ]
    [ length ] bi <integer-literal> ;

: ?lookup-word ( name vocab -- word )
    2dup lookup-word
    [ 2nip ]
    [ over [ "01x" member? ] all? [ drop make-integer-literal ] [ no-field-word ] if ] if* ;

GENERIC: width ( obj -- n )
M: word width "width" word-prop ;
M: integer-literal width width>> ;

GENERIC: value ( obj -- n )
M: integer-literal value value>> ;
M: object value ;

: arm-bitfield ( seq -- assoc )
    [ current-vocab name>> ?lookup-word ] map
    [ dup width ] map>alist
    dup values [ f = ] any? [ throw ] when ;

ERROR: bad-instruction values ;
>>

<<
SYNTAX: ARM-INSTRUCTION:
    scan-new-word
    scan-effect
    [
      in>> arm-bitfield
      [ keys [ value ] map ]
      [ values 32 [ - ] accumulate* ] bi zip
      dup last second 0 = [ bad-instruction ] unless
      '[ _ bitfield* 4 >le % ]
    ] [ in>> [ string>number ] reject { } <effect> ] bi define-declared ;
>>

! ADC: Add with Carry.
! ADCS: Add with Carry, setting flags.
ARM-INSTRUCTION: ADC32-encode ( 0 0 0 11010000 Rm 000000 Rn Rd -- )
ARM-INSTRUCTION: ADCS32-encode ( 0 0 1 11010000 Rm 000000 Rn Rd -- )
ARM-INSTRUCTION: ADC64-encode ( 1 0 0 11010000 Rm 000000 Rn Rd -- )
ARM-INSTRUCTION: ADCS64-encode ( 1 0 1 11010000 Rm 000000 Rn Rd -- )

! ADD (extended register): Add (extended register).
ARM-INSTRUCTION: ADDer32-encode ( 0 0 0 01011 00 1 Rm option3 imm3 Rn Rd -- )
ARM-INSTRUCTION: ADDer64-encode ( 1 0 0 01011 00 1 Rm option3 imm3 Rn Rd -- )

! ADD (immediate): Add (immediate).
ARM-INSTRUCTION: ADDi32-encode ( 0 0 0 10001 shift2 imm12 Rn Rd -- )
ARM-INSTRUCTION: ADDi64-encode ( 1 0 0 10001 shift2 imm12 Rn Rd -- )

! ADD (shifted register): Add (shifted register).
ARM-INSTRUCTION: ADDsr32-encode ( 0 0 0 01011 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: ADDsr64-encode ( 1 0 0 01011 shift2 0 Rm imm6 Rn Rd -- )

! ADDG: Add with Tag.
ARM-INSTRUCTION: ADDG-encode ( 1 0 0 100011 0 uimm6 00 uimm4 Xn Xd -- )

! ADDS (extended register): Add (extended register), setting flags.
ARM-INSTRUCTION: ADDSer32-encode ( 0 0 1 01011 00 1 Rm option3 imm3 Rn Rd -- )
ARM-INSTRUCTION: ADDSer64-encode ( 1 0 1 01011 00 1 Rm option3 imm3 Rn Rd -- )

! ADDS (immediate): Add (immediate), setting flags.
ARM-INSTRUCTION: ADDSi32-encode ( 0 0 1 10001 shift2 imm12 Rn Rd -- )
ARM-INSTRUCTION: ADDSi64-encode ( 1 0 1 10001 shift2 imm12 Rn Rd -- )

! ADDS (shifted register): Add (shifted register), setting flags.
ARM-INSTRUCTION: ADDSsr32-encode ( 0 0 1 01011 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: ADDSsr64-encode ( 1 0 1 01011 shift2 0 Rm imm6 Rn Rd -- )

! ADR: Form PC-relative address.
! ADRP: Form PC-relative address to 4KB page.
ARM-INSTRUCTION: ADR-encode  ( 0 immlo2 10000 immhi19 Rd -- )
ARM-INSTRUCTION: ADRP-encode ( 1 immlo2 10000 immhi19 Rd -- )

! AND (immediate): Bitwise AND (immediate).
ARM-INSTRUCTION: ANDi32-encode ( 0 00 100100 0 immrimms Rn Rd -- )
ARM-INSTRUCTION: ANDi64-encode ( 1 00 100100 Nimmrimms Rn Rd -- )

! AND (shifted register): Bitwise AND (shifted register).
ARM-INSTRUCTION: ANDsr32-encode ( 0 00 01010 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: ANDsr64-encode ( 1 00 01010 shift2 0 Rm imm6 Rn Rd -- )

! ANDS (immediate): Bitwise AND (immediate), setting flags.
ARM-INSTRUCTION: ANDSi32-encode ( 0 11 100100 0 immrimms Rn Rd -- )
ARM-INSTRUCTION: ANDSi64-encode ( 1 11 100100 Nimmrimms Rn Rd -- )

! ANDS (shifted register): Bitwise AND (shifted register), setting flags.
ARM-INSTRUCTION: ANDSsr32-encode ( 0 11 01010 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: ANDSsr64-encode ( 1 11 01010 shift2 0 Rm imm6 Rn Rd -- )

! ASR (immediate): Arithmetic Shift Right (immediate): an alias of SBFM.
ARM-INSTRUCTION: ASRi32-encode ( 0 00 100110 0 immr 011111 Rn Rd -- )
ARM-INSTRUCTION: ASRi64-encode ( 1 00 100110 1 immr 111111 Rn Rd -- )

! ASR (register): Arithmetic Shift Right (register): an alias of ASRV.
ARM-INSTRUCTION: ASRr32-encode ( 0 0 0 11010110 Rm 0010 10 Rn Rd -- )
ARM-INSTRUCTION: ASRr64-encode ( 1 0 0 11010110 Rm 0010 10 Rn Rd -- )

! ASRV: Arithmetic Shift Right Variable.
ARM-INSTRUCTION: ASRV32-encode ( 0 0 0 11010110 Rm 0010 10 Rn Rd -- )
ARM-INSTRUCTION: ASRV64-encode ( 1 0 0 11010110 Rm 0010 10 Rn Rd -- )

! AT: Address Translate: an alias of SYS.
ARM-INSTRUCTION: AT-encode ( 1101010100 0 01 op3 0111 1000 op3 Rt -- )

! AUTDA, AUTDZA: Authenticate Data address, using key A.
! AUTDB, AUTDZB: Authenticate Data address, using key B.
ARM-INSTRUCTION: AUTDA-encode  ( 1 1 0 11010110 00001 0 0 0 110 Rn Rd -- )
ARM-INSTRUCTION: AUTDZA-encode ( 1 1 0 11010110 00001 0 0 1 110 11111 Rd -- )
ARM-INSTRUCTION: AUTDB-encode  ( 1 1 0 11010110 00001 0 0 0 111 Rn Rd -- )
ARM-INSTRUCTION: AUTDZB-encode ( 1 1 0 11010110 00001 0 0 1 111 11111 Rd -- )

! AUTIA, AUTIA1716, AUTIASP, AUTIAZ, AUTIZA: Authenticate Instruction address, using key A.
! ARMv8.3
ARM-INSTRUCTION: AUTIA-encode  ( 1 1 0 11010110 00001 0 0 0 100 Rn Rd -- )
ARM-INSTRUCTION: AUTIZA-encode ( 1 1 0 11010110 00001 0 0 1 100 11111 Rd -- )
! ARMv8.3
ARM-INSTRUCTION: AUTIA1716-encode ( 1101010100 0 00 011 0010 0001 100 11111 -- )
ARM-INSTRUCTION: AUTIASP-encode   ( 1101010100 0 00 011 0010 0011 101 11111 -- )
ARM-INSTRUCTION: AUTIAAZ-encode   ( 1101010100 0 00 011 0010 0011 100 11111 -- )

! AUTIB, AUTIB1716, AUTIBSP, AUTIBZ, AUTIZB: Authenticate Instruction address, using key B.
! ARMv8.3
ARM-INSTRUCTION: AUTIB-encode  ( 1 1 0 11010110 00001 0 0 0 101 Rn Rd -- )
ARM-INSTRUCTION: AUTIZB-encode ( 1 1 0 11010110 00001 0 0 1 101 11111 Rd -- )
! ARMv8.3
ARM-INSTRUCTION: AUTIB1716-encode ( 1101010100 0 00 011 0010 0001 110 11111 -- )
ARM-INSTRUCTION: AUTIBSP-encode   ( 1101010100 0 00 011 0010 0011 111 11111 -- )
ARM-INSTRUCTION: AUTIBZ-encode    ( 1101010100 0 00 011 0010 0011 110 11111 -- )

! AXFlag: Convert floating-point condition flags from ARM to external format.
ARM-INSTRUCTION: AXFlag-encode ( 1101010100 0 00 000 0100 0000 010 11111 -- )

! B: Branch.
ARM-INSTRUCTION: B-encode ( 0 00101 imm26 -- )

! B.cond: Branch conditionally.
ARM-INSTRUCTION: B.cond-encode ( 0101010 0 imm19 0 cond4 -- )

! BFC: Bitfield Clear: an alias of BFM.
ARM-INSTRUCTION: BFC32-encode ( 0 01 100110 0 immrimms 11111 Rd -- )
ARM-INSTRUCTION: BFC64-encode ( 1 01 100110 Nimmrimms 11111 Rd -- )

! BFI: Bitfield Insert: an alias of BFM.
ARM-INSTRUCTION: BFI32-encode ( 0 01 100110 0 immrimms Rn Rd -- )
ARM-INSTRUCTION: BFI64-encode ( 1 01 100110 Nimmrimms Rn Rd -- )

! BFM: Bitfield Move.
ARM-INSTRUCTION: BFM32-encode ( 0 01 100110 0 immrimms Rn Rd -- )
ARM-INSTRUCTION: BFM64-encode ( 1 01 100110 Nimmrimms Rn Rd -- )

! BFXIL: Bitfield extract and insert at low end: an alias of BFM.
ARM-INSTRUCTION: BFXIL32-encode ( 0 01 100110 0 immrimms Rn Rd -- )
ARM-INSTRUCTION: BFXIL64-encode ( 1 01 100110 Nimmrimms Rn Rd -- )

! BIC (shifted register): Bitwise Bit Clear (shifted register).
ARM-INSTRUCTION: BIC32-encode ( 0 00 01010 shift2 1 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: BIC64-encode ( 1 00 01010 shift2 1 Rm imm6 Rn Rd -- )
! BICS (shifted register): Bitwise Bit Clear (shifted register), setting flags.
ARM-INSTRUCTION: BICS32-encode ( 0 11 01010 shift2 1 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: BICS64-encode ( 1 11 01010 shift2 1 Rm imm6 Rn Rd -- )
! BL: Branch with Link.
ARM-INSTRUCTION: BL-encode ( 1 00101 imm26 -- )
! BLR: Branch with Link to Register.
ARM-INSTRUCTION: BLR-encode ( 1101011 0 0 01 11111 0000 0 0 Rn 00000 -- )

! BLRAA, BLRAAZ, BLRAB, BLRABZ: Branch with Link to Register, with pointer authentication.
ARM-INSTRUCTION: BLRAA-encode  ( 1101011 0 0 01 11111 0000 1 0 Rn Rm -- )
ARM-INSTRUCTION: BLRAAZ-encode ( 1101011 1 0 01 11111 0000 1 0 Rn 11111 -- )
ARM-INSTRUCTION: BLRAB-encode  ( 1101011 0 0 01 11111 0000 1 1 Rn Rm -- )
ARM-INSTRUCTION: BLRABZ-encode ( 1101011 1 0 01 11111 0000 1 1 Rn 11111 -- )

! BR: Branch to Register.
ARM-INSTRUCTION: BR-encode ( 1101011 0 0 00 11111 0000 0 0 Rn 00000 -- )

! BRAA, BRAAZ, BRAB, BRABZ: Branch to Register, with pointer authentication.
ARM-INSTRUCTION: BRAA-encode  ( 1101011 0 0 00 11111 0000 1 0 Rn 11111 -- )
ARM-INSTRUCTION: BRAAZ-encode ( 1101011 1 0 00 11111 0000 1 0 Rn Rm -- )
ARM-INSTRUCTION: BRAB-encode  ( 1101011 0 0 00 11111 0000 1 1 Rn 11111 -- )
ARM-INSTRUCTION: BRABZ-encode ( 1101011 1 0 00 11111 0000 1 1 Rn Rm -- )

! BRK: Breakpoint instruction.
ARM-INSTRUCTION: BRK-encode ( 11010100 001 imm16 000 00 -- )
! BTI: Branch Target Identification.
ARM-INSTRUCTION: BTI-encode ( 1101010100 0 00 011 0010 0100 000 11111 -- )

! CAS, CASA, CASAL, CASL: Compare and Swap word or doubleword in memory.
ARM-INSTRUCTION: CAS32-encode   ( 10 001000 1 0 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASA32-encode  ( 10 001000 1 1 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASAL32-encode ( 10 001000 1 1 1 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: CASL32-encode  ( 10 001000 1 0 1 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: CAS64-encode   ( 11 001000 1 0 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASA64-encode  ( 11 001000 1 1 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASAL64-encode ( 11 001000 1 1 1 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: CASL64-encode  ( 11 001000 1 0 1 Rs 1 11111 Rn Rt -- )

! CASB, CASAB, CASALB, CASLB: Compare and Swap byte in memory.
ARM-INSTRUCTION: CASAB-encode  ( 00 001000 1 1 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASALB-encode ( 00 001000 1 1 1 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: CASB-encode   ( 00 001000 1 0 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASLB-encode  ( 00 001000 1 0 1 Rs 1 11111 Rn Rt -- )

! CASH, CASAH, CASALH, CASLH: Compare and Swap halfword in memory.
ARM-INSTRUCTION: CASAH-encode  ( 01 001000 1 1 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASALH-encode ( 01 001000 1 1 1 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: CASH-encode   ( 01 001000 1 0 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASLH-encode  ( 01 001000 1 0 1 Rs 1 11111 Rn Rt -- )

! CASP, CASPA, CASPAL, CASPL: Compare and Swap Pair of words or doublewords in memory.
ARM-INSTRUCTION: CASP32-encode   ( 0 0 001000 0 0 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASPA32-encode  ( 0 0 001000 0 1 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASPAL32-encode ( 0 0 001000 0 1 1 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: CASPL32-encode  ( 0 0 001000 0 0 1 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: CASP64-encode   ( 0 1 001000 0 0 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASPA64-encode  ( 0 1 001000 0 1 1 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: CASPAL64-encode ( 0 1 001000 0 1 1 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: CASPL64-encode  ( 0 1 001000 0 0 1 Rs 1 11111 Rn Rt -- )

! CBNZ: Compare and Branch on Nonzero.
ARM-INSTRUCTION: CBNZ32-encode ( 0 011010 1 imm19 Rt -- )
ARM-INSTRUCTION: CBNZ64-encode ( 1 011010 1 imm19 Rt -- )

! CBZ: Compare and Branch on Zero.
ARM-INSTRUCTION: CBZ32-encode ( 0 011010 0 imm19 Rt -- )
ARM-INSTRUCTION: CBZ64-encode ( 1 011010 0 imm19 Rt -- )

! CCMN (immediate): Conditional Compare Negative (immediate).
ARM-INSTRUCTION: CCMNi32-encode ( 0 0 1 11010010 imm5 cond4 1 0 Rn 0 nzcv -- )
ARM-INSTRUCTION: CCMNi64-encode ( 1 0 1 11010010 imm5 cond4 1 0 Rn 0 nzcv -- )
! CCMN (register): Conditional Compare Negative (register).
ARM-INSTRUCTION: CCMNr32-encode ( 0 0 1 11010010 Rm cond4 0 0 Rn 0 nzcv -- )
ARM-INSTRUCTION: CCMNr64-encode ( 1 0 1 11010010 Rm cond4 0 0 Rn 0 nzcv -- )
! CCMP (immediate): Conditional Compare (immediate).
ARM-INSTRUCTION: CCMPi32-encode ( 0 1 1 11010010 imm5 cond4 1 0 Rn 0 nzcv -- )
ARM-INSTRUCTION: CCMPi64-encode ( 1 1 1 11010010 imm5 cond4 1 0 Rn 0 nzcv -- )
! CCMP (register): Conditional Compare (register).
ARM-INSTRUCTION: CCMPr32-encode ( 0 1 1 11010010 Rm cond4 0 0 Rn 0 nzcv -- )
ARM-INSTRUCTION: CCMPr64-encode ( 1 1 1 11010010 Rm cond4 0 0 Rn 0 nzcv -- )

! CFINV: Invert Carry Flag.
ARM-INSTRUCTION: CFINV-encode ( 1101010100 0 0 0 000 0100 0000 000 11111 -- )
! CFP: Control Flow Prediction Restriction by Context: an alias of SYS.
ARM-INSTRUCTION: CFP-encode ( 1101010100 0 01 011 0111 0011 100 Rt -- )
! CINC: Conditional Increment: an alias of CSINC.
ARM-INSTRUCTION: CINC32-encode ( 0 0 0 11010100 Rm cond4 0 1 Rn Rd -- )
ARM-INSTRUCTION: CINC64-encode ( 1 0 0 11010100 Rm cond4 0 1 Rn Rd -- )
! CINV: Conditional Invert: an alias of CSINV.
ARM-INSTRUCTION: CINV32-encode ( 0 0 0 11010100 Rm cond4 0 0 Rn Rd -- )
ARM-INSTRUCTION: CINV64-encode ( 1 0 0 11010100 Rm cond4 0 0 Rn Rd -- )
! CLREX: Clear Exclusive.
ARM-INSTRUCTION: CLREX-encode ( 1101010100 0 00 011 0011 CRm 010 11111 -- )
! CLS: Count Leading Sign bits.
ARM-INSTRUCTION: CLS32-encode ( 0 1 0 11010110 00000 00010 1 Rn Rd -- )
ARM-INSTRUCTION: CLS64-encode ( 1 1 0 11010110 00000 00010 1 Rn Rd -- )
! CLZ: Count Leading Zeros.
ARM-INSTRUCTION: CLZ32-encode ( 0 1 0 11010110 00000 00010 0 Rn Rd -- )
ARM-INSTRUCTION: CLZ64-encode ( 1 1 0 11010110 00000 00010 0 Rn Rd -- )

! CMN (extended register): Compare Negative (extended register): an alias of ADDS (extended register).
ARM-INSTRUCTION: CMNer32-encode ( 0 0 1 01011 00 1 Rm option3 imm3 Rn Rd -- )
ARM-INSTRUCTION: CMNer64-encode ( 1 0 1 01011 00 1 Rm option3 imm3 Rn Rd -- )
! CMN (immediate): Compare Negative (immediate): an alias of ADDS (immediate).
ARM-INSTRUCTION: CMNi32-encode ( 0 0 1 10001 shift2 imm12 Rn 11111 -- )
ARM-INSTRUCTION: CMNi64-encode ( 1 0 1 10001 shift2 imm12 Rn 11111 -- )
! CMN (shifted register): Compare Negative (shifted register): an alias of ADDS (shifted register).
ARM-INSTRUCTION: CMNsr32-encode ( 0 0 1 01011 shift2 0 Rm imm6 Rn 11111 -- )
ARM-INSTRUCTION: CMNsr64-encode ( 1 0 1 01011 shift2 0 Rm imm6 Rn 11111 -- )

! CMP (extended register): Compare (extended register): an alias of SUBS (extended register).
ARM-INSTRUCTION: CMPer32-encode ( 0 1 1 01011 00 1 Rm option3 imm3 Rn 11111 -- )
ARM-INSTRUCTION: CMPer64-encode ( 1 1 1 01011 00 1 Rm option3 imm3 Rn 11111 -- )
! CMP (immediate): Compare (immediate): an alias of SUBS (immediate).
ARM-INSTRUCTION: CMPi32-encode ( 0 1 1 10001 shift2 imm12 Rn 11111 -- )
ARM-INSTRUCTION: CMPi64-encode ( 1 1 1 10001 shift2 imm12 Rn 11111 -- )
! CMP (shifted register): Compare (shifted register): an alias of SUBS (shifted register).
ARM-INSTRUCTION: CMPsr32-encode ( 0 1 1 01011 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: CMPsr64-encode ( 1 1 1 01011 shift2 0 Rm imm6 Rn Rd -- )

! CMPP: Compare with Tag: an alias of SUBPS.
ARM-INSTRUCTION: CMPP-encode ( 1 0 1 11010110 Xm 0 0 0 0 0 0 Xn Xd -- )
! CNEG: Conditional Negate: an alias of CSNEG.
ARM-INSTRUCTION: CNEG32-encode ( 0 1 0 11010100 Rm cond4 0 1 Rn Rd -- )
ARM-INSTRUCTION: CNEG64-encode ( 1 1 0 11010100 Rm cond4 0 1 Rn Rd -- )
! CPP: Cache Prefetch Prediction Restriction by Context: an alias of SYS.
ARM-INSTRUCTION: CPP-encode ( 1101010100 0 01 011 0111 0011 111 Rt -- )

! CRC32B, CRC32H, CRC32W, CRC32X: CRC32 checksum.
ARM-INSTRUCTION: CRC32B32-encode ( 0 0 0 11010110 Rm 010 0 00 Rn Rd -- )
ARM-INSTRUCTION: CRC32B64-encode ( 1 0 0 11010110 Rm 010 0 00 Rn Rd -- )
ARM-INSTRUCTION: CRC32H32-encode ( 0 0 0 11010110 Rm 010 0 01 Rn Rd -- )
ARM-INSTRUCTION: CRC32H64-encode ( 1 0 0 11010110 Rm 010 0 01 Rn Rd -- )
ARM-INSTRUCTION: CRC32W32-encode ( 0 0 0 11010110 Rm 010 0 10 Rn Rd -- )
ARM-INSTRUCTION: CRC32W64-encode ( 1 0 0 11010110 Rm 010 0 10 Rn Rd -- )
ARM-INSTRUCTION: CRC32X32-encode ( 0 0 0 11010110 Rm 010 0 11 Rn Rd -- )
ARM-INSTRUCTION: CRC32X64-encode ( 1 0 0 11010110 Rm 010 0 11 Rn Rd -- )

! CRC32CB, CRC32CH, CRC32CW, CRC32CX: CRC32C checksum.
ARM-INSTRUCTION: CRC32CB32-encode ( 0 0 0 11010110 Rm 010 1 00 Rn Rd -- )
ARM-INSTRUCTION: CRC32CB64-encode ( 1 0 0 11010110 Rm 010 1 00 Rn Rd -- )
ARM-INSTRUCTION: CRC32CH32-encode ( 0 0 0 11010110 Rm 010 1 01 Rn Rd -- )
ARM-INSTRUCTION: CRC32CH64-encode ( 1 0 0 11010110 Rm 010 1 01 Rn Rd -- )
ARM-INSTRUCTION: CRC32CW32-encode ( 0 0 0 11010110 Rm 010 1 10 Rn Rd -- )
ARM-INSTRUCTION: CRC32CW64-encode ( 1 0 0 11010110 Rm 010 1 10 Rn Rd -- )
ARM-INSTRUCTION: CRC32CX32-encode ( 0 0 0 11010110 Rm 010 1 11 Rn Rd -- )
ARM-INSTRUCTION: CRC32CX64-encode ( 1 0 0 11010110 Rm 010 1 11 Rn Rd -- )

! CSDB: Consumption of Speculative Data Barrier.
ARM-INSTRUCTION: CSDB-encode ( 1101010100 0 00 011 0010 0010 100 11111 -- )
! CSEL: Conditional Select.
ARM-INSTRUCTION: CSEL32-encode ( 0 0 0 11010100 Rm cond4 0 0 Rn Rd -- )
ARM-INSTRUCTION: CSEL64-encode ( 1 0 0 11010100 Rm cond4 0 0 Rn Rd -- )
! CSET: Conditional Set: an alias of CSINC.
ARM-INSTRUCTION: CSET32-encode ( 0 0 0 11010100 11111 cond4 0 1 11111 Rd -- )
ARM-INSTRUCTION: CSET64-encode ( 1 0 0 11010100 11111 cond4 0 1 11111 Rd -- )
! CSETM: Conditional Set Mask: an alias of CSINV.
ARM-INSTRUCTION: CSETM32-encode ( 0 0 0 11010100 11111 cond4 0 0 11111 Rd -- )
ARM-INSTRUCTION: CSETM64-encode ( 1 0 0 11010100 11111 cond4 0 0 11111 Rd -- )

! CSINC: Conditional Select Increment.
ARM-INSTRUCTION: CSINC32-encode ( 0 0 0 11010100 Rm cond4 0 1 Rn Rd -- )
ARM-INSTRUCTION: CSINC64-encode ( 1 0 0 11010100 Rm cond4 0 1 Rn Rd -- )

! CSINV: Conditional Select Invert.
ARM-INSTRUCTION: CSINV32-encode ( 0 0 0 11010100 Rm cond4 0 0 Rn Rd -- )
ARM-INSTRUCTION: CSINV64-encode ( 1 0 0 11010100 Rm cond4 0 0 Rn Rd -- )

! CSNEG: Conditional Select Negation.
ARM-INSTRUCTION: CSNEG32-encode ( 0 1 0 11010100 Rm cond4 0 1 Rn Rd -- )
ARM-INSTRUCTION: CSNEG64-encode ( 1 1 0 11010100 Rm cond4 0 1 Rn Rd -- )

! DC: Data Cache operation: an alias of SYS.
ARM-INSTRUCTION: DC-encode ( 1101010100 0 01 op3 0111 CRm op3 Rt -- )
! DCPS1: Debug Change PE State to EL1..
ARM-INSTRUCTION: DCPS1-encode ( 11010100 101 imm16 000 01 -- )
! DCPS2: Debug Change PE State to EL2..
ARM-INSTRUCTION: DCPS2-encode ( 11010100 101 imm16 000 10 -- )
! DCPS3: Debug Change PE State to EL3.
ARM-INSTRUCTION: DCPS3-encode ( 11010100 101 imm16 000 11 -- )

! DMB: Data Memory Barrier.
ARM-INSTRUCTION: DMB-encode ( 1101010100 0 00 011 0011 CRm 1 01 11111 -- )
! DRPS: Debug restore process state.
ARM-INSTRUCTION: DPRS-encode ( 1101011 0101 11111 000000 11111 00000 -- )
! DSB: Data Synchronization Barrier.
ARM-INSTRUCTION: DSB-encode ( 1101010100 0 00 011 0011 CRm 1 00 11111 -- )
! DVP: Data Value Prediction Restriction by Context: an alias of SYS.
ARM-INSTRUCTION: DVP-encode ( 1101010100 0 01 011 0111 0011 101 Rt -- )

! EON (shifted register): Bitwise Exclusive OR NOT (shifted register).
ARM-INSTRUCTION: EONsr32-encode ( 0 10 01010 shift2 1 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: EONsr64-encode ( 1 10 01010 shift2 1 Rm imm6 Rn Rd -- )

! EOR (immediate): Bitwise Exclusive OR (immediate).
ARM-INSTRUCTION: EORi32-encode ( 0 10 100100 0 immrimms Rn Rd -- )
ARM-INSTRUCTION: EORi64-encode ( 1 10 100100 Nimmrimms Rn Rd -- )

! EOR (shifted register): Bitwise Exclusive OR (shifted register).
ARM-INSTRUCTION: EORsr32-encode ( 0 10 01010 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: EORsr64-encode ( 1 10 01010 shift2 0 Rm imm6 Rn Rd -- )

! ERET: Exception Return.
ARM-INSTRUCTION: ERET-encode ( 1101011 0 100 11111 0000 0 0 11111 00000 -- )

! ERETAA, ERETAB: Exception Return, with pointer authentication.
! ARMv8.3
ARM-INSTRUCTION: ERETAA-encode ( 1101011 0 100 11111 0000 1 0 11111 00000 -- )
ARM-INSTRUCTION: ERETAB-encode ( 1101011 0 100 11111 0000 1 1 11111 11111 -- )

! ESB: Error Synchronization Barrier.
! ARMv8.2
ARM-INSTRUCTION: ESB-encode ( 1101010100 0 00 011 0010 0010 000 11111 -- )
! EXTR: Extract register.
ARM-INSTRUCTION: EXTR32-encode ( 0 00 100111 0 0 Rm imms Rn Rd -- )
ARM-INSTRUCTION: EXTR64-encode ( 1 00 100111 1 0 Rm imms Rn Rd -- )

! GMI: Tag Mask Insert.
ARM-INSTRUCTION: GMI-encode ( 1 0 0 11010110 Xm 0 0 0 1 0 1 Xn Xd -- )
! HINT: Hint instruction.
ARM-INSTRUCTION: HINT-encode ( 1101010100 0 00 011 0010 CRm op3 11111 -- )
! HLT: Halt instruction.
ARM-INSTRUCTION: HLT-encode ( 11010100 010 imm16 000 00 -- )

! HVC: Hypervisor Call.
ARM-INSTRUCTION: HVC-encode ( 11010100 000 imm16 000 10 -- )
! IC: Instruction Cache operation: an alias of SYS.
ARM-INSTRUCTION: IC-encode ( 1101010100 0 01 op3 0111 CRm op3 Rt -- )
! IRG: Insert Random Tag.
ARM-INSTRUCTION: IRG-encode ( 1 0 0 11010110 Xm 0 0 0 1 0 0 Xn Xd -- )
! ISB: Instruction Synchronization Barrier.
ARM-INSTRUCTION: ISB-encode ( 1101010100 0 00 011 0011 CRm 1 10 11111 -- )

! LDADD, LDADDA, LDADDAL, LDADDL: Atomic add on word or doubleword in memory.
ARM-INSTRUCTION: LDADD32-encode   ( 10 111 0 00 0 0 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDA32-encode  ( 10 111 0 00 1 0 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDAL32-encode ( 10 111 0 00 1 1 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDL32-encode  ( 10 111 0 00 0 1 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADD64-encode   ( 11 111 0 00 0 0 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDA64-encode  ( 11 111 0 00 1 0 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDAL64-encode ( 11 111 0 00 1 1 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDL64-encode  ( 11 111 0 00 0 1 1 Rs 0 000 00 Rn Rt -- )

! LDADDB, LDADDAB, LDADDALB, LDADDLB: Atomic add on byte in memory.
ARM-INSTRUCTION: LDADDAB-encode  ( 00 111 0 00 1 0 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDALB-encode ( 00 111 0 00 1 1 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDB-encode   ( 00 111 0 00 0 0 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDLB-encode  ( 00 111 0 00 0 1 1 Rs 0 000 00 Rn Rt -- )

! LDADDH, LDADDAH, LDADDALH, LDADDLH: Atomic add on halfword in memory.
ARM-INSTRUCTION: LDADDAH-encode  ( 01 111 0 00 1 0 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDALH-encode ( 01 111 0 00 1 1 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDH-encode   ( 01 111 0 00 0 0 1 Rs 0 000 00 Rn Rt -- )
ARM-INSTRUCTION: LDADDLH-encode  ( 01 111 0 00 0 1 1 Rs 0 000 00 Rn Rt -- )

! LDAPR: Load-Acquire RCpc Register.
! ARMv8.3
ARM-INSTRUCTION: LDAPR32-encode ( 10 111 0 00 1 0 1 11111 1 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDAPR64-encode ( 11 111 0 00 1 0 1 11111 1 100 00 Rn Rt -- )
! LDAPRB: Load-Acquire RCpc Register Byte.
ARM-INSTRUCTION: LDAPRB-encode ( 00 111 0 00 1 0 1 11111 1 100 00 Rn Rt -- )
! LDAPRH: Load-Acquire RCpc Register Halfword.
ARM-INSTRUCTION: LDAPRH-encode ( 01 111 0 00 1 0 1 11111 1 100 00 Rn Rt -- )

! LDAPUR: Load-Acquire RCpc Register (unscaled).
ARM-INSTRUCTION: LDAPUR32-encode ( 10 011001 01 0 imm9 00 Rn Rt -- )
ARM-INSTRUCTION: LDAPUR64-encode ( 11 011001 01 0 imm9 00 Rn Rt -- )
! LDAPURB: Load-Acquire RCpc Register Byte (unscaled).
ARM-INSTRUCTION: LDAPURB-encode ( 00 011001 01 0 imm9 00 Rn Rt -- )
! LDAPURH: Load-Acquire RCpc Register Halfword (unscaled).
ARM-INSTRUCTION: LDAPURH-encode ( 01 011001 01 0 imm9 00 Rn Rt -- )
! LDAPURSB: Load-Acquire RCpc Register Signed Byte (unscaled).
ARM-INSTRUCTION: LDAPURSB32-encode ( 00 011001 11 0 imm9 00 Rn Rt -- )
ARM-INSTRUCTION: LDAPURSB64-encode ( 00 011001 10 0 imm9 00 Rn Rt -- )
! LDAPURSH: Load-Acquire RCpc Register Signed Halfword (unscaled).
ARM-INSTRUCTION: LDAPURSH32-encode ( 01 011001 11 0 imm9 00 Rn Rt -- )
ARM-INSTRUCTION: LDAPURSH64-encode ( 01 011001 10 0 imm9 00 Rn Rt -- )
! LDAPURSW: Load-Acquire RCpc Register Signed Word (unscaled).
ARM-INSTRUCTION: LDAPURSW-encode ( 10 011001 10 0 imm9 00 Rn Rt -- )
! LDAR: Load-Acquire Register.
ARM-INSTRUCTION: LDAR32-encode ( 10 001000 1 1 0 11111 1 11111 Rn Rt -- )
ARM-INSTRUCTION: LDAR64-encode ( 11 001000 1 1 0 11111 1 11111 Rn Rt -- )
! LDARB: Load-Acquire Register Byte.
ARM-INSTRUCTION: LDARB-encode ( 00 001000 1 1 0 11111 1 11111 Rn Rt -- )
! LDARH: Load-Acquire Register Halfword.
ARM-INSTRUCTION: LDARH-encode ( 01 001000 1 1 0 11111 1 11111 Rn Rt -- )
! LDAXP: Load-Acquire Exclusive Pair of Registers.
ARM-INSTRUCTION: LDAXP32-encode ( 1 0 001000 0 1 1 11111 1 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDAXP64-encode ( 1 1 001000 0 1 1 11111 1 Rt2 Rn Rt -- )
! LDAXR: Load-Acquire Exclusive Register.
ARM-INSTRUCTION: LDAXR32-encode ( 10 001000 0 1 0 11111 1 11111 Rn Rt -- )
ARM-INSTRUCTION: LDAXR64-encode ( 11 001000 0 1 0 11111 1 11111 Rn Rt -- )
! LDAXRB: Load-Acquire Exclusive Register Byte.
ARM-INSTRUCTION: LDAXRB-encode ( 00 001000 0 1 0 11111 1 11111 Rn Rt -- )
! LDAXRH: Load-Acquire Exclusive Register Halfword.
ARM-INSTRUCTION: LDAXRH-encode ( 01 001000 0 1 0 11111 1 11111 Rn Rt -- )

! LDCLR, LDCLRA, LDCLRAL, LDCLRL: Atomic bit clear on word or doubleword in memory.
ARM-INSTRUCTION: LDCLR32-encode   ( 10 111 0 00 0 0 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRA32-encode  ( 10 111 0 00 1 0 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRAL32-encode ( 10 111 0 00 1 1 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRL32-encode  ( 10 111 0 00 0 1 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLR64-encode   ( 11 111 0 00 0 0 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRA64-encode  ( 11 111 0 00 1 0 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRAL64-encode ( 11 111 0 00 1 1 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRL64-encode  ( 11 111 0 00 0 1 1 Rs 0 001 00 Rn Rt -- )

! LDCLRB, LDCLRAB, LDCLRALB, LDCLRLB: Atomic bit clear on byte in memory.
ARM-INSTRUCTION: LDCLRAB-encode  ( 00 111 0 00 1 0 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRALB-encode ( 00 111 0 00 1 1 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRB-encode   ( 00 111 0 00 0 0 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRLB-encode  ( 00 111 0 00 0 1 1 Rs 0 001 00 Rn Rt -- )

! LDCLRH, LDCLRAH, LDCLRALH, LDCLRLH: Atomic bit clear on halfword in memory.
ARM-INSTRUCTION: LDCLRAH-encode  ( 01 111 0 00 1 0 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRALH-encode ( 01 111 0 00 1 1 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRA-encode   ( 01 111 0 00 0 0 1 Rs 0 001 00 Rn Rt -- )
ARM-INSTRUCTION: LDCLRLH-encode  ( 01 111 0 00 0 1 1 Rs 0 001 00 Rn Rt -- )

! LDEOR, LDEORA, LDEORAL, LDEORL: Atomic exclusive OR on word or doubleword in memory.
ARM-INSTRUCTION: LDEOR32-encode   ( 10 111 0 00 0 0 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORA32-encode  ( 10 111 0 00 1 0 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORAL32-encode ( 10 111 0 00 1 1 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORL32-encode  ( 10 111 0 00 0 1 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEOR64-encode   ( 11 111 0 00 0 0 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORA64-encode  ( 11 111 0 00 1 0 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORAL64-encode ( 11 111 0 00 1 1 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORL64-encode  ( 11 111 0 00 0 1 1 Rs 0 010 00 Rn Rt -- )

! LDEORB, LDEORAB, LDEORALB, LDEORLB: Atomic exclusive OR on byte in memory.
ARM-INSTRUCTION: LDEORAB-encode  ( 00 111 0 00 1 0 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORALB-encode ( 00 111 0 00 1 1 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORB-encode   ( 00 111 0 00 0 0 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORLB-encode  ( 00 111 0 00 0 1 1 Rs 0 010 00 Rn Rt -- )

! LDEORH, LDEORAH, LDEORALH, LDEORLH: Atomic exclusive OR on halfword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDEORAH-encode  ( 01 111 0 00 1 0 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORALH-encode ( 01 111 0 00 1 1 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORH-encode   ( 01 111 0 00 0 0 1 Rs 0 010 00 Rn Rt -- )
ARM-INSTRUCTION: LDEORLH-encode  ( 01 111 0 00 0 1 1 Rs 0 010 00 Rn Rt -- )

! LDG: Load Allocation Tag.
! ARMv8.5
ARM-INSTRUCTION: LDG-encode ( 11011001 0 1 1 imm9 0 0 Xn Xt -- )
! LDGV: Load Allocation Tag.
! ARMv8.5
ARM-INSTRUCTION: LDGV-encode ( 11011001 1 1 1 0 0 0 0 0 0 0 0 0 0 0 Xn Xt -- )

! LDLAR: Load LOAcquire Register.
! ARMv8.1
ARM-INSTRUCTION: LDLAR32-encode ( 10 001000 1 1 0 11111 0 11111 Rn Rt -- )
ARM-INSTRUCTION: LDLAR64-encode ( 11 001000 1 1 0 11111 0 11111 Rn Rt -- )
! LDLARB: Load LOAcquire Register Byte.
ARM-INSTRUCTION: LDLARB-encode ( 00 001000 1 1 0 11111 0 11111 Rn Rt -- )
! LDLARH: Load LOAcquire Register Halfword.
ARM-INSTRUCTION: LDLARH-encode ( 01 001000 1 1 0 11111 0 11111 Rn Rt -- )

! LDNP: Load Pair of Registers, with non-temporal hint.
ARM-INSTRUCTION: LDNP32-encode ( 00 101 0 000 1 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDNP64-encode ( 10 101 0 000 1 imm7 Rt2 Rn Rt -- )

! LDP: Load Pair of Registers.
ARM-INSTRUCTION: LDPpost32-encode ( 00 101 0 001 1 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDPpost64-encode ( 10 101 0 001 1 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDPpre32-encode  ( 00 101 0 011 1 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDPpre64-encode  ( 10 101 0 011 1 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDPsoff32-encode ( 00 101 0 010 1 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDPsoff64-encode ( 10 101 0 010 1 imm7 Rt2 Rn Rt -- )

! LDPSW: Load Pair of Registers Signed Word.
ARM-INSTRUCTION: LDPSWpost-encode ( 01 101 0 001 1 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDPSWpre-encode  ( 01 101 0 011 1 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDPSWsoff-encode ( 01 101 0 010 1 imm7 Rt2 Rn Rt -- )

! LDR (immediate): Load Register (immediate).
ARM-INSTRUCTION: LDRpost32-encode ( 10 111 0 00 01 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRpost64-encode ( 11 111 0 00 01 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRpre32-encode  ( 10 111 0 00 01 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRpre64-encode  ( 11 111 0 00 01 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRuoff32-encode ( 10 111 0 01 01 imm12 Rn Rt -- )
ARM-INSTRUCTION: LDRuoff64-encode ( 11 111 0 01 01 imm12 Rn Rt -- )

! LDR (literal): Load Register (literal).
ARM-INSTRUCTION: LDRl32-encode ( 00 011 0 00 imm19 Rt -- )
ARM-INSTRUCTION: LDRl64-encode ( 01 011 0 00 imm19 Rt -- )

! LDR (register): Load Register (register).
ARM-INSTRUCTION: LDRr32-encode ( 10 111 0 00 01 1 Rm option3 S 1 0 Rn Rt -- )
ARM-INSTRUCTION: LDRr64-encode ( 11 111 0 00 01 1 Rm option3 S 1 0 Rn Rt -- )

! LDRAA, LDRAB: Load Register, with pointer authentication.
! ARMv8.3
ARM-INSTRUCTION: LDRAAoff-encode ( 11 111 0 00 0 S 1 imm9 0 1 Rn Rt  -- )
ARM-INSTRUCTION: LDRAApre-encode ( 11 111 0 00 0 S 1 imm9 1 1 Rn Rt  -- )
ARM-INSTRUCTION: LDRABoff-encode ( 11 111 0 00 1 S 1 imm9 0 1 Rn Rt  -- )
ARM-INSTRUCTION: LDRABpre-encode ( 11 111 0 00 1 S 1 imm9 1 1 Rn Rt  -- )

! LDRB (immediate): Load Register Byte (immediate).
ARM-INSTRUCTION: LDRBpost-encode ( 00 111 0 00 01 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRBpre-encode ( 00 111 0 00 01 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRBuoff-encode ( 00 111 0 01 01 imm12 Rn Rt -- )

! LDRB (register): Load Register Byte (register).
! option: 010: UXTW, 110 SXTW, 111 SXTX, S shift 0/1
ARM-INSTRUCTION: LDRBer-encode ( 00 111 0 00 01 1 Rm option3 S 10 Rn Rt -- )
ARM-INSTRUCTION: LDRBsr-encode ( 00 111 0 00 01 1 Rm 011 S 10 Rn Rt -- )

! LDRH (immediate): Load Register Halfword (immediate).
ARM-INSTRUCTION: LDRHpost-encode ( 01 111 0 00 01 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRHpre-encode ( 01 111 0 00 01 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRHuoff-encode ( 01 111 0 01 01 imm12 Rn Rt -- )

! LDRH (register): Load Register Halfword (register).
ARM-INSTRUCTION: LDRHr-encode ( 01 111 0 00 01 1 Rm option3 S 10 Rn Rt  -- )

! LDRSB (immediate): Load Register Signed Byte (immediate).
ARM-INSTRUCTION: LDRSBpost32-encode ( 00 111 0 00 11 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRSBpost64-encode ( 00 111 0 00 10 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRSBpre32-encode  ( 00 111 0 00 11 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRSBpre64-encode  ( 00 111 0 00 10 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRSBuoff32-encode ( 00 111 0 01 11 imm12 Rn Rt -- )
ARM-INSTRUCTION: LDRSBuoff64-encode ( 00 111 0 01 10 imm12 Rn Rt -- )

! LDRSB (register): Load Register Signed Byte (register).
ARM-INSTRUCTION: LDRSBer32-encode   ( 00 111 0 00 11 1 Rm option3 S 10 Rn Rt -- )
ARM-INSTRUCTION: LDRSBsr32-encode ( 00 111 0 00 11 1 Rm 011 S 10 Rn Rt -- )
ARM-INSTRUCTION: LDRSBer64-encode   ( 00 111 0 00 10 1 Rm option3 S 10 Rn Rt -- )
ARM-INSTRUCTION: LDRSBsr64-encode ( 00 111 0 00 10 1 Rm 011 S 10 Rn Rt -- )

! LDRSH (immediate): Load Register Signed Halfword (immediate).
ARM-INSTRUCTION: LDRSHpost32-encode ( 01 111 0 00 11 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRSHpost64-encode ( 01 111 0 00 10 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRSHpre32-encode  ( 01 111 0 00 11 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRSHpre64-encode  ( 01 111 0 00 10 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRSHuoff32-encode ( 01 111 0 01 11 imm12 Rn Rt -- )
ARM-INSTRUCTION: LDRSHuoff64-encode ( 01 111 0 01 10 imm12 Rn Rt -- )

! LDRSH (register): Load Register Signed Halfword (register).
ARM-INSTRUCTION: LDRSHr32-encode ( 01 111 0 00 11 1 Rm option3 S 10 Rn Rt -- )
ARM-INSTRUCTION: LDRSHr64-encode ( 01 111 0 00 10 1 Rm option3 S 10 Rn Rt -- )

! LDRSW (immediate): Load Register Signed Word (immediate).
ARM-INSTRUCTION: LDRSWpost32-encode ( 10 111 0 00 10 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: LDRSWpre32-encode  ( 10 111 0 00 10 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: LDRSWuoff64-encode ( 10 111 0 01 10 imm12 Rn Rt -- )

! LDRSW (literal): Load Register Signed Word (literal).
ARM-INSTRUCTION: LDRSWl-encode ( 10 011 0 00 imm19 Rt -- )

! LDRSW (register): Load Register Signed Word (register).
ARM-INSTRUCTION: LDRSWr-encode ( 10 111 0 00 10 1 Rm option3 S 10 Rn Rt -- )

! LDSET, LDSETA, LDSETAL, LDSETL: Atomic bit set on word or doubleword in memory.
ARM-INSTRUCTION: LDSET32-encode   ( 10 111 0 00 0 0 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETA32-encode  ( 10 111 0 00 1 0 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETAL32-encode ( 10 111 0 00 1 1 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETL32-encode  ( 10 111 0 00 0 1 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSET64-encode   ( 11 111 0 00 0 0 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETA64-encode  ( 11 111 0 00 1 0 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETAL64-encode ( 11 111 0 00 1 1 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETL64-encode  ( 11 111 0 00 0 1 1 Rs 0 011 00 Rn Rt -- )

! LDSETB, LDSETAB, LDSETALB, LDSETLB: Atomic bit set on byte in memory.
ARM-INSTRUCTION: LDSETAB-encode  ( 00 111 0 00 1 0 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETALB-encode ( 00 111 0 00 1 1 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETB-encode   ( 00 111 0 00 0 0 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETLB-encode  ( 00 111 0 00 0 1 1 Rs 0 011 00 Rn Rt -- )

! LDSETH, LDSETAH, LDSETALH, LDSETLH: Atomic bit set on halfword in memory.
ARM-INSTRUCTION: LDSETAH-encode  ( 01 111 0 00 1 0 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETALH-encode ( 01 111 0 00 1 1 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETH-encode   ( 01 111 0 00 0 0 1 Rs 0 011 00 Rn Rt -- )
ARM-INSTRUCTION: LDSETLH-encode  ( 01 111 0 00 0 1 1 Rs 0 011 00 Rn Rt -- )

! LDSMAX, LDSMAXA, LDSMAXAL, LDSMAXL: Atomic signed maximum on word or doubleword in memory.
ARM-INSTRUCTION: LDSMAX32-encode   ( 10 111 0 00 0 0 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXA32-encode  ( 10 111 0 00 1 0 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXAL32-encode ( 10 111 0 00 1 1 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXL32-encode  ( 10 111 0 00 0 1 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAX64-encode   ( 11 111 0 00 0 0 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXA64-encode  ( 11 111 0 00 1 0 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXAL64-encode ( 11 111 0 00 1 1 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXL64-encode  ( 11 111 0 00 0 1 1 Rs 0 100 00 Rn Rt -- )

! LDSMAXB, LDSMAXAB, LDSMAXALB, LDSMAXLB: Atomic signed maximum on byte in memory.
ARM-INSTRUCTION: LDSMAXAB-encode  ( 00 111 0 00 1 0 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXALB-encode ( 00 111 0 00 1 1 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXB-encode   ( 00 111 0 00 0 0 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXLB-encode  ( 00 111 0 00 0 1 1 Rs 0 100 00 Rn Rt -- )

! LDSMAXH, LDSMAXAH, LDSMAXALH, LDSMAXLH: Atomic signed maximum on halfword in memory.
ARM-INSTRUCTION: LDSMAXAH-encode  ( 00 111 0 00 1 0 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXALH-encode ( 00 111 0 00 1 1 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXH-encode   ( 00 111 0 00 0 0 1 Rs 0 100 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMAXLH-encode  ( 00 111 0 00 0 1 1 Rs 0 100 00 Rn Rt -- )

! LDSMIN, LDSMINA, LDSMINAL, LDSMINL: Atomic signed minimum on word or doubleword in memory.
ARM-INSTRUCTION: LDSMIN32-encode   ( 10 111 0 00 0 0 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINA32-encode  ( 10 111 0 00 1 0 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINAL32-encode ( 10 111 0 00 1 1 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINL32-encode  ( 10 111 0 00 0 1 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMIN64-encode   ( 11 111 0 00 0 0 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINA64-encode  ( 11 111 0 00 1 0 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINAL64-encode ( 11 111 0 00 1 1 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINL64-encode  ( 11 111 0 00 0 1 1 Rs 0 101 00 Rn Rt -- )

! LDSMINB, LDSMINAB, LDSMINALB, LDSMINLB: Atomic signed minimum on byte in memory.
! ARMv8.1
ARM-INSTRUCTION: LDSMINAB-encode  ( 00 111 0 00 1 0 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINALB-encode ( 00 111 0 00 1 1 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINB-encode   ( 00 111 0 00 0 0 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINLB-encode  ( 00 111 0 00 0 1 1 Rs 0 101 00 Rn Rt -- )

! LDSMINH, LDSMINAH, LDSMINALH, LDSMINLH: Atomic signed minimum on halfword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDSMINAH-encode  ( 01 111 0 00 1 0 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINALH-encode ( 01 111 0 00 1 1 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINH-encode   ( 01 111 0 00 0 0 1 Rs 0 101 00 Rn Rt -- )
ARM-INSTRUCTION: LDSMINLH-encode  ( 01 111 0 00 0 1 1 Rs 0 101 00 Rn Rt -- )

! LDTR: Load Register (unprivileged).
ARM-INSTRUCTION: LDTR32-encode ( 10 111 0 00 01 0 imm9 10 Rn Rt -- )
ARM-INSTRUCTION: LDTR64-encode ( 11 111 0 00 01 0 imm9 10 Rn Rt -- )

! LDTRB: Load Register Byte (unprivileged).
ARM-INSTRUCTION: LDTRB-encode ( 00 111 0 00 01 0 imm9 10 Rn Rt -- )

! LDTRH: Load Register Halfword (unprivileged).
ARM-INSTRUCTION: LDTRH-encode ( 01 111 0 00 01 0 imm9 10 Rn Rt -- )

! LDTRSB: Load Register Signed Byte (unprivileged).
ARM-INSTRUCTION: LDTRSB32-encode ( 00 111 0 00 11 0 imm9 10 Rn Rt -- )
ARM-INSTRUCTION: LDTRSB64-encode ( 00 111 0 00 10 0 imm9 10 Rn Rt -- )

! LDTRSH: Load Register Signed Halfword (unprivileged).
ARM-INSTRUCTION: LDTRSH32-encode ( 01 111 0 00 11 0 imm9 10 Rn Rt -- )
ARM-INSTRUCTION: LDTRSH64-encode ( 01 111 0 00 10 0 imm9 10 Rn Rt -- )

! LDTRSW: Load Register Signed Word (unprivileged).
ARM-INSTRUCTION: LDTRSW-encode ( 10 111 0 00 10 0 imm9 10 Rn Rt -- )

! LDUMAX, LDUMAXA, LDUMAXAL, LDUMAXL: Atomic unsigned maximum on word or doubleword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMAX32-encode   ( 10 111 0 00 0 0 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXA32-encode  ( 10 111 0 00 1 0 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXAL32-encode ( 10 111 0 00 1 1 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXL32-encode  ( 10 111 0 00 0 1 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAX64-encode   ( 11 111 0 00 0 0 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXA64-encode  ( 11 111 0 00 1 0 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXAL64-encode ( 11 111 0 00 1 1 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXL64-encode  ( 11 111 0 00 0 1 1 Rs 0 110 00 Rn Rt -- )

! LDUMAXB, LDUMAXAB, LDUMAXALB, LDUMAXLB: Atomic unsigned maximum on byte in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMAXAB-encode  ( 00 111 0 00 1 0 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXALB-encode ( 00 111 0 00 1 1 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXB-encode   ( 00 111 0 00 0 0 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXLB-encode  ( 00 111 0 00 0 1 1 Rs 0 110 00 Rn Rt -- )

! LDUMAXH, LDUMAXAH, LDUMAXALH, LDUMAXLH: Atomic unsigned maximum on halfword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMAXAH-encode  ( 01 111 0 00 1 0 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXALH-encode ( 01 111 0 00 1 1 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXH-encode   ( 01 111 0 00 0 0 1 Rs 0 110 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMAXLH-encode  ( 01 111 0 00 0 1 1 Rs 0 110 00 Rn Rt -- )

! LDUMIN, LDUMINA, LDUMINAL, LDUMINL: Atomic unsigned minimum on word or doubleword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMIN32-encode   ( 10 111 0 00 0 0 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINA32-encode  ( 10 111 0 00 1 0 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINAL32-encode ( 10 111 0 00 1 1 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINL32-encode  ( 10 111 0 00 0 1 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMIN64-encode   ( 11 111 0 00 0 0 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINA64-encode  ( 11 111 0 00 1 0 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINAL64-encode ( 11 111 0 00 1 1 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINL64-encode  ( 11 111 0 00 0 1 1 Rs 0 111 00 Rn Rt -- )

! LDUMINB, LDUMINAB, LDUMINALB, LDUMINLB: Atomic unsigned minimum on byte in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMINAB-encode  ( 00 111 0 00 1 0 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINALB-encode ( 00 111 0 00 1 1 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINB-encode   ( 00 111 0 00 0 0 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINLB-encode  ( 00 111 0 00 0 1 1 Rs 0 111 00 Rn Rt -- )

! LDUMINH, LDUMINAH, LDUMINALH, LDUMINLH: Atomic unsigned minimum on halfword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMINAH-encode  ( 01 111 0 00 1 0 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINALH-encode ( 01 111 0 00 1 1 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINH-encode   ( 01 111 0 00 0 0 1 Rs 0 111 00 Rn Rt -- )
ARM-INSTRUCTION: LDUMINLH-encode  ( 01 111 0 00 0 1 1 Rs 0 111 00 Rn Rt -- )

! LDUR: Load Register (unscaled).
ARM-INSTRUCTION: LDUR32-encode ( 10 111 0 00 01 0 imm9 00 Rn Rt -- )
ARM-INSTRUCTION: LDUR64-encode ( 11 111 0 00 01 0 imm9 00 Rn Rt -- )

! LDURB: Load Register Byte (unscaled).
ARM-INSTRUCTION: LDURB-encode ( 00 111 0 00 01 0 imm9 00 Rn Rt -- )

! LDURH: Load Register Halfword (unscaled).
ARM-INSTRUCTION: LDURH-encode ( 01 111 0 00 01 0 imm9 00 Rn Rt -- )

! LDURSB: Load Register Signed Byte (unscaled).
ARM-INSTRUCTION: LDURSB32-encode ( 00 111 0 00 10 0 imm9 00 Rn Rt -- )
ARM-INSTRUCTION: LDURSB64-encode ( 00 111 0 00 11 0 imm9 00 Rn Rt -- )

! LDURSH: Load Register Signed Halfword (unscaled).
ARM-INSTRUCTION: LDURSH32-encode ( 01 111 0 00 10 0 imm9 00 Rn Rt -- )
ARM-INSTRUCTION: LDURSH64-encode ( 01 111 0 00 11 0 imm9 00 Rn Rt -- )

! LDURSW: Load Register Signed Word (unscaled).
ARM-INSTRUCTION: LDURSW-encode ( 10 111 0 00 10 0 imm9 00 Rn Rt -- )

! LDXP: Load Exclusive Pair of Registers.
ARM-INSTRUCTION: LDXP32-encode ( 1 0 001000 0 1 1 11111 0 Rt2 Rn Rt -- )
ARM-INSTRUCTION: LDXP64-encode ( 1 1 001000 0 1 1 11111 0 Rt2 Rn Rt -- )

! LDXR: Load Exclusive Register.
ARM-INSTRUCTION: LDXR32-encode ( 10 001000 0 1 0 11111 0 11111 Rn Rt -- )
ARM-INSTRUCTION: LDXR64-encode ( 11 001000 0 1 0 11111 0 11111 Rn Rt -- )

! LDXRB: Load Exclusive Register Byte.
ARM-INSTRUCTION: LDXRB-encode ( 00 001000 0 1 0 11111 0 11111 Rn Rt -- )

! LDXRH: Load Exclusive Register Halfword.
ARM-INSTRUCTION: LDXRH-encode ( 01 001000 0 1 0 11111 0 11111 Rn Rt -- )

! LSL (immediate): Logical Shift Left (immediate): an alias of UBFM.
ARM-INSTRUCTION: LSLi32-encode ( 0 10 100110 0 immrimms Rn Rd -- )
ARM-INSTRUCTION: LSLi64-encode ( 1 10 100110 1 immrimms Rn Rd -- )

! LSL (register): Logical Shift Left (register): an alias of LSLV.
ARM-INSTRUCTION: LSLr32-encode ( 0 0 0 11010110 Rm 0010 00 Rn Rd -- )
ARM-INSTRUCTION: LSLr64-encode ( 1 0 0 11010110 Rm 0010 00 Rn Rd -- )

! LSLV: Logical Shift Left Variable.
ARM-INSTRUCTION: LSLV32-encode ( 0 0 0 11010110 Rm 0010 00 Rn Rd -- )
ARM-INSTRUCTION: LSLV64-encode ( 1 0 0 11010110 Rm 0010 00 Rn Rd -- )

! LSR (immediate): Logical Shift Right (immediate): an alias of UBFM.
ARM-INSTRUCTION: LSRi32-encode ( 0 10 100110 0 immr 011111 Rn Rd -- )
ARM-INSTRUCTION: LSRi64-encode ( 1 10 100110 1 immr 111111 Rn Rd -- )

! LSR (register): Logical Shift Right (register): an alias of LSRV.
ARM-INSTRUCTION: LSRr32-encode ( 0 0 0 11010110 Rm 0010 01 Rn Rd -- )
ARM-INSTRUCTION: LSRr64-encode ( 1 0 0 11010110 Rm 0010 01 Rn Rd -- )

! LSRV: Logical Shift Right Variable.
ARM-INSTRUCTION: LSRV32-encode ( 0 0 0 11010110 Rm 0010 01 Rn Rd -- )
ARM-INSTRUCTION: LSRV64-encode ( 1 0 0 11010110 Rm 0010 01 Rn Rd -- )

! MADD: Multiply-Add.
ARM-INSTRUCTION: MADD32-encode ( 0 00 11011 000 Rm 0 Ra Rn Rd -- )
ARM-INSTRUCTION: MADD64-encode ( 1 00 11011 000 Rm 0 Ra Rn Rd -- )

! MNEG: Multiply-Negate: an alias of MSUB.
ARM-INSTRUCTION: MNEG32-encode ( 0 00 11011 000 Rm 1 11111 Rn Rd -- )
ARM-INSTRUCTION: MNEG64-encode ( 1 00 11011 000 Rm 1 11111 Rn Rd -- )

! MOV (bitmask immediate): Move (bitmask immediate): an alias of ORR (immediate).
ARM-INSTRUCTION: MOVbi32-encode ( 0 01 100100 0 immr imms 11111 Rn -- )
ARM-INSTRUCTION: MOVbi64-encode ( 1 01 100100 Nimmrimms 11111 Rn -- )

! MOV (inverted wide immediate): Move (inverted wide immediate): an alias of MOVN.
ARM-INSTRUCTION: MOViwi32-encode ( 0 00 100101 hw2 imm16 Rd -- )
ARM-INSTRUCTION: MOViwi64-encode ( 1 00 100101 hw2 imm16 Rd -- )

! MOV (register): Move (register): an alias of ORR (shifted register).
ARM-INSTRUCTION: MOVr32-encode ( 0 01 01010 00 0 Rm 000000 11111 Rd -- )
ARM-INSTRUCTION: MOVr64-encode ( 1 01 01010 00 0 Rm 000000 11111 Rd -- )

! MOV (to/from SP): Move between register and stack pointer: an alias of ADD (immediate).
ARM-INSTRUCTION: MOVsp32-encode ( 0 0 0 10001 shift2 000000000000 Rn Rd -- )
ARM-INSTRUCTION: MOVsp64-encode ( 1 0 0 10001 shift2 000000000000 Rn Rd -- )

! MOV (wide immediate): Move (wide immediate): an alias of MOVZ.
ARM-INSTRUCTION: MOVwi32-encode ( 0 10 100101 hw2 imm16 Rd -- )
ARM-INSTRUCTION: MOVwi64-encode ( 1 10 100101 hw2 imm16 Rd -- )

! MOVK: Move wide with keep.
ARM-INSTRUCTION: MOVK32-encode ( 0 11 100101 hw2 imm16 Rd -- )
ARM-INSTRUCTION: MOVK64-encode ( 1 11 100101 hw2 imm16 Rd -- )

! MOVN: Move wide with NOT.
ARM-INSTRUCTION: MOVN32-encode ( 0 00 100101 hw2 imm16 Rd -- )
ARM-INSTRUCTION: MOVN64-encode ( 1 00 100101 hw2 imm16 Rd -- )

! MOVZ: Move wide with zero.
ARM-INSTRUCTION: MOVZ32-encode ( 0 10 100101 hw2 imm16 Rd -- )
ARM-INSTRUCTION: MOVZ64-encode ( 1 10 100101 hw2 imm16 Rd -- )

! MRS: Move System Register.
! System register name, encoded in the "o0:op1:CRn:CRm:op2"
ARM-INSTRUCTION: MRS-encode ( 1101010100 1 op2 op3 CRn CRm op3 Rt -- )

! MSR (immediate): Move immediate value to Special Register.
ARM-INSTRUCTION: MSRi-encode ( 1101010100 0 00 op3 0100 CRm op3 11111 -- )

! MSR (register): Move general-purpose register to System Register.
ARM-INSTRUCTION: MSRr-encode ( 1101010100 0 op2 op3 CRn CRm op3 Rt -- )

! MSUB: Multiply-Subtract.
ARM-INSTRUCTION: MSUB32-encode ( 0 00 11011 000 Rm 1 Ra Rn Rd -- )
ARM-INSTRUCTION: MSUB64-encode ( 1 00 11011 000 Rm 1 Ra Rn Rd -- )

! MUL: Multiply: an alias of MADD.
ARM-INSTRUCTION: MUL32-encode ( 0 00 11011 000 Rm 0 11111 Rn Rd -- )
ARM-INSTRUCTION: MUL64-encode ( 1 00 11011 000 Rm 0 11111 Rn Rd -- )

! MVN: Bitwise NOT: an alias of ORN (shifted register).
ARM-INSTRUCTION: MVN32-encode ( 0 0 1 01010 shift2 1 Rm imm6 11111 Rd -- )
ARM-INSTRUCTION: MVN64-encode ( 1 0 1 01010 shift2 1 Rm imm6 11111 Rd -- )

! NEG (shifted register): Negate (shifted register): an alias of SUB (shifted register).
ARM-INSTRUCTION: NEG32-encode ( 0 1 0 01011 shift2 0 Rm imm6 11111 Rd -- )
ARM-INSTRUCTION: NEG64-encode ( 1 1 0 01011 shift2 0 Rm imm6 11111 Rd -- )

! NEGS: Negate, setting flags: an alias of SUBS (shifted register).
ARM-INSTRUCTION: NEGS32-encode ( 0 1 1 01011 shift2 0 Rm imm6 11111 Rd -- )
ARM-INSTRUCTION: NEGS64-encode ( 1 1 1 01011 shift2 0 Rm imm6 11111 Rd -- )

! NGC: Negate with Carry: an alias of SBC.
ARM-INSTRUCTION: NGC32-encode ( 0 1 0 11010000 Rm 000000 11111 Rd -- )
ARM-INSTRUCTION: NGC64-encode ( 1 1 0 11010000 Rm 000000 11111 Rd -- )

! NGCS: Negate with Carry, setting flags: an alias of SBCS.
ARM-INSTRUCTION: NGCS32-encode ( 0 1 1 11010000 Rm 000000 11111 Rd -- )
ARM-INSTRUCTION: NGCS64-encode ( 1 1 1 11010000 Rm 000000 11111 Rd -- )

! NOP: No Operation.
ARM-INSTRUCTION: NOP ( 1101010100 0 00 011 0010 0000 000 11111 -- )

! ORN (shifted register): Bitwise OR NOT (shifted register).
ARM-INSTRUCTION: ORNsr32-encode ( 0 01 01010 shift2 1 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: ORNsr64-encode ( 1 01 01010 shift2 1 Rm imm6 Rn Rd -- )

! ORR (immediate): Bitwise OR (immediate).
ARM-INSTRUCTION: ORRi32-encode ( 0 01 100100 0 immrimms Rn Rd -- )
ARM-INSTRUCTION: ORRi64-encode ( 1 01 100100 Nimmrimms Rn Rd -- )

! ORR (shifted register): Bitwise OR (shifted register).
ARM-INSTRUCTION: ORRsr32-encode ( 0 01 01010 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: ORRsr64-encode ( 1 01 01010 shift2 0 Rm imm6 Rn Rd -- )

! PACDA, PACDZA: Pointer Authentication Code for Data address, using key A.
! ARMv8.3
ARM-INSTRUCTION: PACDA-encode  ( 1 1 0 11010110 00001 0 0 0 010 Rn Rd -- )
ARM-INSTRUCTION: PACDZA-encode ( 1 1 0 11010110 00001 0 0 1 010 11111 Rd -- )

! PACDB, PACDZB: Pointer Authentication Code for Data address, using key B.
! ARMv8.3
ARM-INSTRUCTION: PACDB-encode  ( 1 1 0 11010110 00001 0 0 0 011 Rn Rd -- )
ARM-INSTRUCTION: PACDZB-encode ( 1 1 0 11010110 00001 0 0 1 011 11111 Rd -- )

! PACGA: Pointer Authentication Code, using Generic key.
! ARMv8.3
ARM-INSTRUCTION: PACGA-encode ( 1 0 0 11010110 Rm 001100 Rn Rd -- )

! PACIA, PACIA1716, PACIASP, PACIAZ, PACIZA: Pointer Authentication Code for Instruction address, using key A.
! ARMv8.3
ARM-INSTRUCTION: PACIA-encode  ( 1 1 0 11010110 00001 0 0 0 000 Rn Rd -- )
ARM-INSTRUCTION: PACIZA-encode ( 1 1 0 11010110 00001 0 0 1 000 Rn Rd -- )
! ARMv8.3
ARM-INSTRUCTION: PACIA1716-encode ( 1101010100 0 00 011 0010 0001 000 11111 -- )
ARM-INSTRUCTION: PACIASP-encode   ( 1101010100 0 00 011 0010 0011 001 11111 -- )
ARM-INSTRUCTION: PACIAZ-encode    ( 1101010100 0 00 011 0010 0011 000 11111 -- )

! PACIB, PACIB1716, PACIBSP, PACIBZ, PACIZB: Pointer Authentication Code for Instruction address, using key B.
! ARMv8.3
ARM-INSTRUCTION: PACIB-encode  ( 1 1 0 11010110 00001 0 0 0 001 Rn Rd -- )
ARM-INSTRUCTION: PACIZB-encode ( 1 1 0 11010110 00001 0 0 1 001 Rn Rd -- )
! ARMv8.3
ARM-INSTRUCTION: PACIB1716-encode ( 1101010100 0 00 011 0010 0001 010 11111 -- )
ARM-INSTRUCTION: PACIBSP-encode   ( 1101010100 0 00 011 0010 0011 011 11111 -- )
ARM-INSTRUCTION: PACIBZ-encode    ( 1101010100 0 00 011 0010 0011 010 11111 -- )

! PRFM (immediate): Prefetch Memory (immediate).
ARM-INSTRUCTION: PRFMi-encode ( 11 111 0 01 10 imm12 Rn Rt -- )

! PRFM (literal): Prefetch Memory (literal).
ARM-INSTRUCTION: PRFMl-encode ( 11 011 0 00 imm19 Rt -- )

! PRFM (register): Prefetch Memory (register).
ARM-INSTRUCTION: PRFMr-encode ( 11 111 0 00 10 1 Rm option3 S 10 Rn Rt -- )

! PRFM (unscaled offset): Prefetch Memory (unscaled offset).
ARM-INSTRUCTION: PRFMunscoff-encode ( 11 111 0 00 10 0 imm9 00 Rn Rt -- )

! PSB CSYNC: Profiling Synchronization Barrier.
! ARMv8.2
ARM-INSTRUCTION: PSB-CSYNC-encode ( 1101010100 0 00 011 0010 0010 001 11111 -- )

! PSSBB: Physical Speculative Store Bypass Barrier.
ARM-INSTRUCTION: PSSBB-encode ( 1101010100 0 00 011 0011 0100 1 00 11111 -- )

! RBIT: Reverse Bits.
ARM-INSTRUCTION: RBIT32-encode ( 0 1 0 11010110 00000 0000 00 Rn Rd -- )
ARM-INSTRUCTION: RBIT64-encode ( 1 1 0 11010110 00000 0000 00 Rn Rd -- )

! RET: Return from subroutine.
ARM-INSTRUCTION: RET-encode ( 1101011 0 0 10 11111 0000 0 0 Rn 00000 -- )

! RETAA, RETAB: Return from subroutine, with pointer authentication.
! ARMv8.3
ARM-INSTRUCTION: RETAA-encode ( 1101011 0 0 10 11111 0000 1 0 11111 11111 -- )
ARM-INSTRUCTION: RETAB-encode ( 1101011 0 0 10 11111 0000 1 1 11111 11111 -- )

! REV: Reverse Bytes.
ARM-INSTRUCTION: REVb32-encode ( 0 1 0 11010110 00000 0000 10 Rn Rd -- )
ARM-INSTRUCTION: REVb64-encode ( 1 1 0 11010110 00000 0000 11 Rn Rd -- )

! REV16: Reverse bytes in 16-bit halfwords.
ARM-INSTRUCTION: REV16_32 ( 0 1 0 11010110 00000 0000 01 Rn Rd -- )
ARM-INSTRUCTION: REV16_64 ( 1 1 0 11010110 00000 0000 01 Rn Rd -- )

! REV32: Reverse bytes in 32-bit words.
ARM-INSTRUCTION: REV32-encode ( 1 1 0 11010110 00000 0000 10 Rn Rd -- )

! REV64: Reverse Bytes: an alias of REV.
ARM-INSTRUCTION: REV64-encode ( 0 Q 0 01110 size2 10000 0000 0 10 Rn Rd -- )

! RMIF: Rotate, Mask Insert Flags.
! ARMv8.4
ARM-INSTRUCTION: RMIF-encode ( 1 0 1 11010000 imm6 00001 Rn 0 mask4 -- )

! ROR (immediate): Rotate right (immediate): an alias of EXTR.
ARM-INSTRUCTION: RORi32-encode ( 0 00 100111 0 0 Rm 0 imm5 Rn Rd -- )
ARM-INSTRUCTION: RORi64-encode ( 1 00 100111 1 0 Rm imms Rn Rd -- )

! ROR (register): Rotate Right (register): an alias of RORV.
ARM-INSTRUCTION: RORr32-encode ( 0 0 0 11010110 Rm 0010 11 Rn Rd -- )
ARM-INSTRUCTION: RORr64-encode ( 1 0 0 11010110 Rm 0010 11 Rn Rd -- )

! RORV: Rotate Right Variable.
ARM-INSTRUCTION: RORV32-encode ( 0 0 0 11010110 Rm 0010 11 Rn Rd -- )
ARM-INSTRUCTION: RORV64-encode ( 1 0 0 11010110 Rm 0010 11 Rn Rd -- )

! SB: Speculation Barrier.
ARM-INSTRUCTION: SB-encode ( 1101010100 0 00 011 0011 0000 1 11 11111 -- )

! SBC: Subtract with Carry.
ARM-INSTRUCTION: SBC32-encode ( 0 1 0 11010000 Rm 000000 Rn Rd -- )
ARM-INSTRUCTION: SBC64-encode ( 1 1 0 11010000 Rm 000000 Rn Rd -- )

! SBCS: Subtract with Carry, setting flags.
ARM-INSTRUCTION: SBCS32-encode ( 0 1 1 11010000 Rm 000000 Rn Rd -- )
ARM-INSTRUCTION: SBCS64-encode ( 1 1 1 11010000 Rm 000000 Rn Rd -- )

! SBFIZ: Signed Bitfield Insert in Zero: an alias of SBFM.
ARM-INSTRUCTION: SBFIZ32-encode ( 0 00 100110 0 immr imms Rn Rd -- )
ARM-INSTRUCTION: SBFIZ64-encode ( 1 00 100110 1 immr imms Rn Rd -- )

! SBFM: Signed Bitfield Move.
ARM-INSTRUCTION: SBFM32-encode ( 0 00 100110 0 immr imms Rn Rd -- )
ARM-INSTRUCTION: SBFM64-encode ( 1 00 100110 1 immr imms Rn Rd -- )

! SBFX: Signed Bitfield Extract: an alias of SBFM.
ARM-INSTRUCTION: SBFX32-encode ( 0 00 100110 0 immr imms Rn Rd -- )
ARM-INSTRUCTION: SBFX64-encode ( 1 00 100110 1 immr imms Rn Rd -- )

! SDIV: Signed Divide.
ARM-INSTRUCTION: SDIV32-encode ( 0 0 0 11010110 Rm 00001 1 Rn Rd -- )
ARM-INSTRUCTION: SDIV64-encode ( 1 0 0 11010110 Rm 00001 1 Rn Rd -- )

! SETF8, SETF16: Evaluation of 8 or 16 bit flag values.
! ARMv8.4
ARM-INSTRUCTION: SETF8-encode  ( 0 0 1 11010000 000000 0 0010 Rn 0 1101 -- )
ARM-INSTRUCTION: SETF16-encode ( 0 0 1 11010000 000000 1 0010 Rn 0 1101 -- )

! SEV: Send Event.
ARM-INSTRUCTION: SEV-encode  ( 1101010100 0 00 011 0010 0000 100 11111 -- )

! SEVL: Send Event Local.
ARM-INSTRUCTION: SEVL-encode ( 1101010100 0 00 011 0010 0000 101 11111 -- )

! SMADDL: Signed Multiply-Add Long.
ARM-INSTRUCTION: SMADDL-encode ( 1 00 11011 0 01 Rm 0 Ra Rn Rd -- )

! SMC: Secure Monitor Call.
ARM-INSTRUCTION: SMC-encode ( 11010100 000 imm16 000 11 -- )

! SMNEGL: Signed Multiply-Negate Long: an alias of SMSUBL.
ARM-INSTRUCTION: SMNEGL-encode ( 1 00 11011 0 01 Rm 1 11111 Rn Rd -- )

! SMSUBL: Signed Multiply-Subtract Long.
ARM-INSTRUCTION: SMSUBL-encode ( 1 00 11011 0 01 Rm 1 Ra Rn Rd -- )

! SMULH: Signed Multiply High.
ARM-INSTRUCTION: SMULH-encode ( 1 00 11011 0 10 Rm 0 11111 Rn Rd -- )

! SMULL: Signed Multiply Long: an alias of SMADDL.
ARM-INSTRUCTION: SMULL-encode ( 1 00 11011 0 01 Rm 0 11111 Rn Rd -- )

! SSBB: Speculative Store Bypass Barrier.
ARM-INSTRUCTION: SSBB-encode ( 1101010100 0 00 011 0011 0000 1 00 11111 -- )

! ST2G: Store Allocation Tags.
! ARMv8.5
ARM-INSTRUCTION: ST2Gpost-encode ( 11011001 1 0 1 imm9 0 1 Xn 11111 -- )
ARM-INSTRUCTION: ST2Gpre-encode  ( 11011001 1 0 1 imm9 1 1 Xn 11111 -- )
ARM-INSTRUCTION: ST2Gsoff-encode ( 11011001 1 0 1 imm9 1 0 Xn 11111 -- )

! STADD, STADDL: Atomic add on word or doubleword in memory, without return: an alias of LDADD, LDADDA, LDADDAL, LDADDL.
ARM-INSTRUCTION: STADD32-encode  ( 10 111 0 00 0 0 1 Rs 0 000 00 Rn 11111 -- )
ARM-INSTRUCTION: STADDL32-encode ( 10 111 0 00 0 1 1 Rs 0 000 00 Rn 11111 -- )
ARM-INSTRUCTION: STADD64-encode  ( 11 111 0 00 0 0 1 Rs 0 000 00 Rn 11111 -- )
ARM-INSTRUCTION: STADDL64-encode ( 11 111 0 00 0 1 1 Rs 0 000 00 Rn 11111 -- )

! STADDB, STADDLB: Atomic add on byte in memory, without return: an alias of LDADDB, LDADDAB, LDADDALB, LDADDLB.
! ARMv8.1
ARM-INSTRUCTION: STADDB-encode  ( 00 111 0 00 0 0 1 Rs 0 000 00 Rn 11111 -- )
ARM-INSTRUCTION: STADDLB-encode ( 00 111 0 00 0 1 1 Rs 0 000 00 Rn 11111 -- )

! STADDH, STADDLH: Atomic add on halfword in memory, without return: an alias of LDADDH, LDADDAH, LDADDALH, LDADDLH.
ARM-INSTRUCTION: STADDH-encode  ( 01 111 0 00 0 0 1 Rs 0 000 00 Rn 11111 -- )
ARM-INSTRUCTION: STADDLH-encode ( 01 111 0 00 0 1 1 Rs 0 000 00 Rn 11111 -- )

! STCLR, STCLRL: Atomic bit clear on word or doubleword in memory, without return: an alias of LDCLR, LDCLRA, LDCLRAL, LDCLRL.
! ARMv8.1
ARM-INSTRUCTION: STCLR32-encode  ( 10 111 0 00 0 0 1 Rs 0 001 00 Rn 11111 -- )
ARM-INSTRUCTION: STCLR64-encode  ( 10 111 0 00 0 1 1 Rs 0 001 00 Rn 11111 -- )
ARM-INSTRUCTION: STCLRL32-encode ( 11 111 0 00 0 0 1 Rs 0 001 00 Rn 11111 -- )
ARM-INSTRUCTION: STCLRL64-encode ( 11 111 0 00 0 1 1 Rs 0 001 00 Rn 11111 -- )

! STCLRB, STCLRLB: Atomic bit clear on byte in memory, without return: an alias of LDCLRB, LDCLRAB, LDCLRALB, LDCLRLB.
! ARMv8.1
ARM-INSTRUCTION: STCLRB-encode   ( 00 111 0 00 0 0 1 Rs 0 001 00 Rn 11111 -- )
ARM-INSTRUCTION: STCLRLB-encode  ( 00 111 0 00 0 1 1 Rs 0 001 00 Rn 11111 -- )

! STCLRH, STCLRLH: Atomic bit clear on halfword in memory, without return: an alias of LDCLRH, LDCLRAH, LDCLRALH, LDCLRLH.
! ARMv8.1
ARM-INSTRUCTION: STCLRH-encode  ( 01 111 0 00 0 0 1 Rs 0 001 00 Rn 11111 -- )
ARM-INSTRUCTION: STCLRLH-encode ( 01 111 0 00 0 1 1 Rs 0 001 00 Rn 11111 -- )

! STEOR, STEORL: Atomic exclusive OR on word or doubleword in memory, without return: an alias of LDEOR, LDEORA, LDEORAL, LDEORL.
! ARMv8.1
ARM-INSTRUCTION: STEOR32-encode  ( 10 111 0 00 0 0 1 Rs 0 010 00 Rn 11111 -- )
ARM-INSTRUCTION: STEORL32-encode ( 10 111 0 00 0 1 1 Rs 0 010 00 Rn 11111 -- )
ARM-INSTRUCTION: STEOR64-encode  ( 11 111 0 00 0 0 1 Rs 0 010 00 Rn 11111 -- )
ARM-INSTRUCTION: STEORL64-encode ( 11 111 0 00 0 1 1 Rs 0 010 00 Rn 11111 -- )

! STEORB, STEORLB: Atomic exclusive OR on byte in memory, without return: an alias of LDEORB, LDEORAB, LDEORALB, LDEORLB.
! ARMv8.1
ARM-INSTRUCTION: STEORB-encode  ( 00 111 0 00 0 0 1 Rs 0 010 00 Rn 11111 -- )
ARM-INSTRUCTION: STEORLB-encode ( 00 111 0 00 0 1 1 Rs 0 010 00 Rn 11111 -- )

! STEORH, STEORLH: Atomic exclusive OR on halfword in memory, without return: an alias of LDEORH, LDEORAH, LDEORALH, LDEORLH.
! ARMv8.1
ARM-INSTRUCTION: STEORH-encode  ( 01 111 0 00 0 0 1 Rs 0 010 00 Rn 11111 -- )
ARM-INSTRUCTION: STEORLH-encode ( 01 111 0 00 0 1 1 Rs 0 010 00 Rn 11111 -- )

! STG: Store Allocation Tag.
! ARMv8.5
ARM-INSTRUCTION: STGpost-encode ( 11011001 0 0 1 imm9 0 1 Xn 11111 -- )
ARM-INSTRUCTION: STGpre-encode  ( 11011001 0 0 1 imm9 1 1 Xn 11111 -- )
ARM-INSTRUCTION: STGsoff-encode ( 11011001 0 0 1 imm9 1 0 Xn 11111 -- )

! STGP: Store Allocation Tag and Pair of registers.
! ARMv8.5
ARM-INSTRUCTION: STGPpost-encode ( 0 1 101 0 001 0 simm7 Xt2 Xn Xt -- )
ARM-INSTRUCTION: STGPpre-encode  ( 0 1 101 0 011 0 simm7 Xt2 Xn Xt -- )
ARM-INSTRUCTION: STGPsoff-encode ( 0 1 101 0 010 0 simm7 Xt2 Xn Xt -- )

! STGV: Store Tag Vector.
! ARMv8.5
ARM-INSTRUCTION: STGV-encode ( 11011001 1 0 1 0 0 0 0 0 0 0 0 0 0 0 Xn Xt -- )

! STLLR: Store LORelease Register.
! ARMv8.1
ARM-INSTRUCTION: STLLR32-encode ( 10 001000 1 0 0 11111 0 11111 Rn Rt -- )
ARM-INSTRUCTION: STLLR64-encode ( 11 001000 1 0 0 11111 0 11111 Rn Rt -- )

! STLLRB: Store LORelease Register Byte.
! ARMv8.1
ARM-INSTRUCTION: STLLRB-encode ( 00 001000 1 0 0 11111 0 11111 Rn Rt -- )

! STLLRH: Store LORelease Register Halfword.
ARM-INSTRUCTION: STLLRH-encode ( 01 001000 1 0 0 11111 0 11111 Rn Rt -- )

! STLR: Store-Release Register.
ARM-INSTRUCTION: STLR32-encode ( 10 001000 1 0 0 11111 1 11111 Rn Rt -- )
ARM-INSTRUCTION: STLR64-encode ( 11 001000 1 0 0 11111 1 11111 Rn Rt -- )

! STLRB: Store-Release Register Byte.
ARM-INSTRUCTION: STLRB-encode ( 00 001000 1 0 0 11111 1 11111 Rn Rt -- )

! STLRH: Store-Release Register Halfword.
ARM-INSTRUCTION: STLRH-encode ( 01 001000 1 0 0 11111 1 11111 Rn Rt -- )

! STLUR: Store-Release Register (unscaled).
ARM-INSTRUCTION: STLUR32-encode ( 10 011001 00 0 imm9 00 Rn Rt -- )
ARM-INSTRUCTION: STLUR64-encode ( 11 011001 00 0 imm9 00 Rn Rt -- )

! STLURB: Store-Release Register Byte (unscaled).
ARM-INSTRUCTION: STLURB-encode ( 00 011001 00 0 imm9 00 Rn Rt -- )

! STLURH: Store-Release Register Halfword (unscaled).
ARM-INSTRUCTION: STLURH-encode ( 01 011001 00 0 imm9 00 Rn Rt -- )

! STLXP: Store-Release Exclusive Pair of registers.
ARM-INSTRUCTION: STLXP32-encode ( 1 0 001000 0 0 1 Rs 1 Rt2 Rn Rt -- )
ARM-INSTRUCTION: STLXP64-encode ( 1 1 001000 0 0 1 Rs 1 Rt2 Rn Rt -- )

! STLXR: Store-Release Exclusive Register.
ARM-INSTRUCTION: STLXR32-encode ( 10 001000 0 0 0 Rs 1 11111 Rn Rt -- )
ARM-INSTRUCTION: STLXR64-encode ( 11 001000 0 0 0 Rs 1 11111 Rn Rt -- )

! STLXRB: Store-Release Exclusive Register Byte.
ARM-INSTRUCTION: STLXRB-encode ( 00 001000 0 0 0 Rs 1 11111 Rn Rt -- )

! STLXRH: Store-Release Exclusive Register Halfword.
ARM-INSTRUCTION: STLXRH-encode ( 01 001000 0 0 0 Rs 1 11111 Rn Rt -- )

! STNP: Store Pair of Registers, with non-temporal hint.
ARM-INSTRUCTION: STNP32-encode ( 00 101 0 000 0 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: STNP64-encode ( 10 101 0 000 0 imm7 Rt2 Rn Rt -- )

! STP: Store Pair of Registers.
ARM-INSTRUCTION: STPpost32-encode ( 00 101 0 001 0 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: STPpost64-encode ( 10 101 0 001 0 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: STPpre32-encode  ( 00 101 0 011 0 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: STPpre64-encode  ( 10 101 0 011 0 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: STPsoff32-encode ( 00 101 0 010 0 imm7 Rt2 Rn Rt -- )
ARM-INSTRUCTION: STPsoff64-encode ( 10 101 0 010 0 imm7 Rt2 Rn Rt -- )

! STR (immediate): Store Register (immediate).
ARM-INSTRUCTION: STRpost32-encode ( 10 111 0 00 00 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: STRpost64-encode ( 11 111 0 00 00 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: STRpre32-encode  ( 10 111 0 00 00 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: STRpre64-encode  ( 11 111 0 00 00 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: STRuoff32-encode ( 10 111 0 01 00 imm12 Rn Rt -- )
ARM-INSTRUCTION: STRuoff64-encode ( 11 111 0 01 00 imm12 Rn Rt -- )

! STR (register): Store Register (register).
ARM-INSTRUCTION: STRr32-encode ( 10 111 0 00 00 1 Rm option3 S 10 Rn Rt -- )
ARM-INSTRUCTION: STRr64-encode ( 11 111 0 00 00 1 Rm option3 S 10 Rn Rt -- )

! STRB (immediate): Store Register Byte (immediate).
ARM-INSTRUCTION: STRBpost-encode ( 00 111 0 00 00 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: STRBpre-encode  ( 00 111 0 00 00 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: STRBuoff-encode ( 00 111 0 01 00 imm12 Rn Rt -- )

! STRB (register): Store Register Byte (register).
ARM-INSTRUCTION: STRBer-encode   ( 00 111 0 00 00 1 Rm option3 S 10 Rn Rt -- )
ARM-INSTRUCTION: STRBsr-encode ( 00 111 0 00 00 1 Rm 011 S 10 Rn Rt -- )

! STRH (immediate): Store Register Halfword (immediate).
ARM-INSTRUCTION: STRHpost-encode ( 01 111 0 00 00 0 imm9 01 Rn Rt -- )
ARM-INSTRUCTION: STRHpre-encode  ( 01 111 0 00 00 0 imm9 11 Rn Rt -- )
ARM-INSTRUCTION: STRHuoff-encode ( 01 111 0 01 00 imm12 Rn Rt -- )

! STRH (register): Store Register Halfword (register).
ARM-INSTRUCTION: STRHr-encode ( 01 111 0 00 00 1 Rm option3 S 10 Rn Rt -- )

! STSET, STSETL: Atomic bit set on word or doubleword in memory, without return: an alias of LDSET, LDSETA, LDSETAL, LDSETL.
! ARMv8.1
ARM-INSTRUCTION: STSET32-encode  ( 10 111 0 00 0 0 1 Rs 0 011 00 Rn 11111 -- )
ARM-INSTRUCTION: STSETL32-encode ( 10 111 0 00 0 1 1 Rs 0 011 00 Rn 11111 -- )
ARM-INSTRUCTION: STSET64-encode  ( 11 111 0 00 0 0 1 Rs 0 011 00 Rn 11111 -- )
ARM-INSTRUCTION: STSETL64-encode ( 11 111 0 00 0 1 1 Rs 0 011 00 Rn 11111 -- )

! STSETB, STSETLB: Atomic bit set on byte in memory, without return: an alias of LDSETB, LDSETAB, LDSETALB, LDSETLB.
! ARMv8.1
ARM-INSTRUCTION: STSETB-encode  ( 00 111 0 00 0 0 1 Rs 0 011 00 Rn 11111 -- )
ARM-INSTRUCTION: STSETLB-encode ( 00 111 0 00 0 1 1 Rs 0 011 00 Rn 11111 -- )

! STSETH, STSETLH: Atomic bit set on halfword in memory, without return: an alias of LDSETH, LDSETAH, LDSETALH, LDSETLH.
! ARMv8.1
ARM-INSTRUCTION: STSETH-encode  ( 01 111 0 00 0 0 1 Rs 0 011 00 Rn 11111 -- )
ARM-INSTRUCTION: STSETLH-encode ( 01 111 0 00 0 1 1 Rs 0 011 00 Rn 11111 -- )

! STSMAX, STSMAXL: Atomic signed maximum on word or doubleword in memory, without return: an alias of LDSMAX, LDSMAXA, LDSMAXAL, LDSMAXL.
! ARMv8.1
ARM-INSTRUCTION: STSMAX32-encode  ( 10 111 0 00 0 0 1 Rs 0 100 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMAXL32-encode ( 10 111 0 00 0 1 1 Rs 0 100 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMAX64-encode  ( 11 111 0 00 0 0 1 Rs 0 100 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMAXL64-encode ( 11 111 0 00 0 1 1 Rs 0 100 00 Rn 11111 -- )

! STSMAXB, STSMAXLB: Atomic signed maximum on byte in memory, without return: an alias of LDSMAXB, LDSMAXAB, LDSMAXALB, LDSMAXLB.
! ARMv8.1
ARM-INSTRUCTION: STSMAXB-encode  ( 00 111 0 00 0 0 1 Rs 0 100 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMAXLB-encode ( 00 111 0 00 0 1 1 Rs 0 100 00 Rn 11111 -- )

! STSMAXH, STSMAXLH: Atomic signed maximum on halfword in memory, without return: an alias of LDSMAXH, LDSMAXAH, LDSMAXALH, LDSMAXLH
! ARMv8.1
ARM-INSTRUCTION: STSMAXH-encode  ( 01 111 0 00 0 0 1 Rs 0 100 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMAXLH-encode ( 01 111 0 00 0 1 1 Rs 0 100 00 Rn 11111 -- )

! STSMIN, STSMINL: Atomic signed minimum on word or doubleword in memory, without return: an alias of LDSMIN, LDSMINA, LDSMINAL, LDSMINL.
! ARMv8.1
ARM-INSTRUCTION: STSMIN32-encode  ( 10 111 0 00 0 0 1 Rs 0 101 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMINL32-encode ( 10 111 0 00 0 0 1 Rs 0 101 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMIN64-encode  ( 11 111 0 00 0 1 1 Rs 0 101 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMINL64-encode ( 11 111 0 00 0 1 1 Rs 0 101 00 Rn 11111 -- )

! STSMINB, STSMINLB: Atomic signed minimum on byte in memory, without return: an alias of LDSMINB, LDSMINAB, LDSMINALB, LDSMINLB.
ARM-INSTRUCTION: STSMINB-encode  ( 00 111 0 00 0 0 1 Rs 0 101 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMINLB-encode ( 00 111 0 00 0 1 1 Rs 0 101 00 Rn 11111 -- )

! STSMINH, STSMINLH: Atomic signed minimum on halfword in memory, without return: an alias of LDSMINH, LDSMINAH, LDSMINALH, LDSMINLH.
ARM-INSTRUCTION: STSMINH-encode  ( 01 111 0 00 0 0 1 Rs 0 101 00 Rn 11111 -- )
ARM-INSTRUCTION: STSMINLH-encode ( 01 111 0 00 0 1 1 Rs 0 101 00 Rn 11111 -- )

! STTR: Store Register (unprivileged).
ARM-INSTRUCTION: STTR32-encode ( 10 111 0 00 00 0 imm9 10 Rn Rt -- )
ARM-INSTRUCTION: STTR64-encode ( 11 111 0 00 00 0 imm9 10 Rn Rt -- )

! STTRB: Store Register Byte (unprivileged).
ARM-INSTRUCTION: STTRB-encode ( 00 111 0 00 00 0 imm9 10 Rn Rt -- )

! STTRH: Store Register Halfword (unprivileged).
ARM-INSTRUCTION: STTRH-encode ( 01 111 0 00 00 0 imm9 10 Rn Rt -- )

! STUMAX, STUMAXL: Atomic unsigned maximum on word or doubleword in memory, without return: an alias of LDUMAX, LDUMAXA, LDUMAXAL, LDUMAXL.
! ARMv8.1
ARM-INSTRUCTION: STUMAX32-encode  ( 10 111 0 00 0 0 1 Rs 0 110 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMAXL32-encode ( 10 111 0 00 0 1 1 Rs 0 110 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMAX64-encode  ( 11 111 0 00 0 0 1 Rs 0 110 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMAXL64-encode ( 11 111 0 00 0 1 1 Rs 0 110 00 Rn 11111 -- )

! STUMAXB, STUMAXLB: Atomic unsigned maximum on byte in memory, without return: an alias of LDUMAXB, LDUMAXAB, LDUMAXALB, LDUMAXLB.
ARM-INSTRUCTION: STUMAXB-encode  ( 00 111 0 00 0 0 1 Rs 0 110 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMAXLB-encode ( 00 111 0 00 0 1 1 Rs 0 110 00 Rn 11111 -- )

! STUMAXH, STUMAXLH: Atomic unsigned maximum on halfword in memory, without return: an alias of LDUMAXH, LDUMAXAH, LDUMAXALH, LDUMAXLH.
ARM-INSTRUCTION: STUMAXH-encode  ( 01 111 0 00 0 0 1 Rs 0 110 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMAXLH-encode ( 01 111 0 00 0 1 1 Rs 0 110 00 Rn 11111 -- )

! STUMIN, STUMINL: Atomic unsigned minimum on word or doubleword in memory, without return: an alias of LDUMIN, LDUMINA, LDUMINAL, LDUMINL.
! ARMv8.1
ARM-INSTRUCTION: STUMIN32-encode   ( 10 111 0 00 0 0 1 Rs 0 111 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMINL32-encode  ( 10 111 0 00 0 1 1 Rs 0 111 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMIN64-encode   ( 11 111 0 00 0 0 1 Rs 0 111 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMINL64-encode  ( 11 111 0 00 0 1 1 Rs 0 111 00 Rn 11111 -- )

! STUMINB, STUMINLB: Atomic unsigned minimum on byte in memory, without return: an alias of LDUMINB, LDUMINAB, LDUMINALB, LDUMINLB.
! ARMv8.1
ARM-INSTRUCTION: STUMINB-encode  ( 00 111 0 00 0 0 1 Rs 0 111 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMINLB-encode ( 00 111 0 00 0 1 1 Rs 0 111 00 Rn 11111 -- )

! STUMINH, STUMINLH: Atomic unsigned minimum on halfword in memory, without return: an alias of LDUMINH, LDUMINAH, LDUMINALH, LDUMINLH.
ARM-INSTRUCTION: STUMINH-encode  ( 01 111 0 00 0 0 1 Rs 0 111 00 Rn 11111 -- )
ARM-INSTRUCTION: STUMINLH-encode ( 01 111 0 00 0 1 1 Rs 0 111 00 Rn 11111 -- )

! STUR: Store Register (unscaled).
ARM-INSTRUCTION: STUR32-encode ( 10 111 0 00 00 0 imm9 00 Rn Rt -- )
ARM-INSTRUCTION: STUR64-encode ( 11 111 0 00 00 0 imm9 00 Rn Rt -- )

! STURB: Store Register Byte (unscaled).
ARM-INSTRUCTION: STURB-encode ( 00 111 0 00 00 0 imm9 00 Rn Rt -- )

! STURH: Store Register Halfword (unscaled).
ARM-INSTRUCTION: STURH-encode ( 01 111 0 00 00 0 imm9 00 Rn Rt -- )

! STXP: Store Exclusive Pair of registers.
ARM-INSTRUCTION: STXP32-encode ( 1 0 001000 0 0 1 Rs 0 Rt2 Rn Rt -- )
ARM-INSTRUCTION: STXP64-encode ( 1 1 001000 0 0 1 Rs 0 Rt2 Rn Rt -- )

! STXR: Store Exclusive Register.
ARM-INSTRUCTION: STXR32-encode ( 10 001000 0 0 0 Rs 0 11111 Rn Rt -- )
ARM-INSTRUCTION: STXR64-encode ( 11 001000 0 0 0 Rs 0 11111 Rn Rt -- )

! STXRB: Store Exclusive Register Byte.
ARM-INSTRUCTION: STXRB-encode ( 00 001000 0 0 0 Rs 0 11111 Rn Rt -- )

! STXRH: Store Exclusive Register Halfword.
ARM-INSTRUCTION: STXRH-encode ( 01 001000 0 0 0 Rs 0 11111 Rn Rt -- )

! STZ2G: Store Allocation Tags, Zeroing.
! ARMv8.5
ARM-INSTRUCTION: STZ2Gpost-encode ( 11011001 1 1 1 imm9 0 1 Xn 11111 -- )
ARM-INSTRUCTION: STZ2Gpre-encode  ( 11011001 1 1 1 imm9 1 1 Xn 11111 -- )
ARM-INSTRUCTION: STZ2Gsoff-encode ( 11011001 1 1 1 imm9 1 0 Xn 11111 -- )

! STZG: Store Allocation Tag, Zeroing.
! ARMv8.5
ARM-INSTRUCTION: STZGpost-encode ( 11011001 0 1 1 imm9 0 1 Xn 11111 -- )
ARM-INSTRUCTION: STZGpre-encode  ( 11011001 0 1 1 imm9 1 1 Xn 11111 -- )
ARM-INSTRUCTION: STZGsoff-encode ( 11011001 0 1 1 imm9 1 0 Xn 11111 -- )

! SUB (extended register): Subtract (extended register).
ARM-INSTRUCTION: SUBer32-encode ( 0 1 0 01011 00 1 Rm option3 imm3 Rn Rd -- )
ARM-INSTRUCTION: SUBer64-encode ( 1 1 0 01011 00 1 Rm option3 imm3 Rn Rd -- )

! SUB (immediate): Subtract (immediate).
ARM-INSTRUCTION: SUBi32-encode ( 0 1 0 10001 shift2 imm12 Rn Rd -- )
ARM-INSTRUCTION: SUBi64-encode ( 1 1 0 10001 shift2 imm12 Rn Rd -- )

! SUB (shifted register): Subtract (shifted register).
ARM-INSTRUCTION: SUBsr32-encode ( 0 1 0 01011 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: SUBsr64-encode ( 1 1 0 01011 shift2 0 Rm imm6 Rn Rd -- )

! SUBG: Subtract with Tag.
! ARMv8.5
ARM-INSTRUCTION: SUBG-encode ( 1 1 0 100011 0 uimm6 00 uimm4 Xn Xd -- )

! SUBP: Subtract Pointer.
! ARMv8.5
ARM-INSTRUCTION: SUBP-encode ( 1 0 0 11010110 Xm 0 0 0 0 0 0 Xn Xd -- )

! SUBPS: Subtract Pointer, setting Flags.
! ARMv8.5
ARM-INSTRUCTION: SUBPS-encode ( 1 0 1 11010110 Xm 0 0 0 0 0 0 Xn Xd -- )

! SUBS (extended register): Subtract (extended register), setting flags.
ARM-INSTRUCTION: SUBSer32-encode ( 0 1 1 01011 00 1 Rm option3 imm3 Rn Rd -- )
ARM-INSTRUCTION: SUBSer64-encode ( 1 1 1 01011 00 1 Rm option3 imm3 Rn Rd -- )

! SUBS (immediate): Subtract (immediate), setting flags.
ARM-INSTRUCTION: SUBSimm32-encode ( 0 1 1 10001 shift2 imm12 Rn Rd -- )
ARM-INSTRUCTION: SUBSimm64-encode ( 1 1 1 10001 shift2 imm12 Rn Rd -- )

! SUBS (shifted register): Subtract (shifted register), setting flags.
ARM-INSTRUCTION: SUBSsr32-encode ( 0 1 1 01011 shift2 0 Rm imm6 Rn Rd -- )
ARM-INSTRUCTION: SUBSsr64-encode ( 1 1 1 01011 shift2 0 Rm imm6 Rn Rd -- )

! SVC: Supervisor Call.
ARM-INSTRUCTION: SVC-encode ( 11010100 000 imm16 000 01 -- )

! SWP, SWPA, SWPAL, SWPL: Swap word or doubleword in memory
! ARMv8.1
ARM-INSTRUCTION: SWP32-encode   ( 10 111 0 00 0 0 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPA32-encode  ( 10 111 0 00 1 0 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPAL32-encode ( 10 111 0 00 1 1 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPL32-encode  ( 10 111 0 00 0 1 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWP64-encode   ( 11 111 0 00 0 0 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPA64-encode  ( 11 111 0 00 1 0 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPAL64-encode ( 11 111 0 00 1 1 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPL64-encode  ( 11 111 0 00 0 1 1 Rs 1 000 00 Rn Rt -- )

! SWPB, SWPAB, SWPALB, SWPLB: Swap byte in memory.
! ARMv8.1
ARM-INSTRUCTION: SWPAB-encode  ( 00 111 0 00 1 0 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPALB-encode ( 00 111 0 00 1 1 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPB-encode   ( 00 111 0 00 0 0 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPLB-encode  ( 00 111 0 00 0 1 1 Rs 1 000 00 Rn Rt -- )

! SWPH, SWPAH, SWPALH, SWPLH: Swap halfword in memory.
ARM-INSTRUCTION: SWPAH-encode  ( 01 111 0 00 1 0 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPALH-encode ( 01 111 0 00 1 1 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPH-encode   ( 01 111 0 00 0 0 1 Rs 1 000 00 Rn Rt -- )
ARM-INSTRUCTION: SWPLH-encode  ( 01 111 0 00 0 1 1 Rs 1 000 00 Rn Rt -- )

! SXTB: Signed Extend Byte: an alias of SBFM.
ARM-INSTRUCTION: SXTB32-encode ( 0 00 100110 0 000000 000111 Rn Rd -- )
ARM-INSTRUCTION: SXTB64-encode ( 1 00 100110 1 000000 000111 Rn Rd -- )

! SXTH: Sign Extend Halfword: an alias of SBFM.
ARM-INSTRUCTION: SXTH32-encode ( 0 00 100110 0 000000 001111 Rn Rd -- )
ARM-INSTRUCTION: SXTH64-encode ( 1 00 100110 1 000000 001111 Rn Rd -- )

! SXTW: Sign Extend Word: an alias of SBFM.
ARM-INSTRUCTION: SXTW-encode ( 1 00 100110 1 000000 011111 Rn Rd -- )

! SYS: System instruction.
ARM-INSTRUCTION: SYS-encode  ( 1101010100 0 01 op3 CRn CRm op3 Rt -- )

! SYSL: System instruction with result.
ARM-INSTRUCTION: SYSL-encode ( 1101010100 1 01 op3 CRn CRm op3 Rt -- )

! TBNZ: Test bit and Branch if Nonzero.
ARM-INSTRUCTION: TBNZW-encode ( 0 011011 1 b40 imm14 Rt -- )
ARM-INSTRUCTION: TBNZX-encode ( 1 011011 1 b40 imm14 Rt -- )

! TBZ: Test bit and Branch if Zero.
ARM-INSTRUCTION: TBHZW-encode ( 0 011011 0 b40 imm14 Rt -- )
ARM-INSTRUCTION: TBHZX-encode ( 1 011011 0 b40 imm14 Rt -- )

! TLBI: TLB Invalidate operation: an alias of SYS.
ARM-INSTRUCTION: TLBI-encode ( 1101010100 0 01 op3 1000 CRm op3 Rt -- )

! TSB CSYNC: Trace Synchronization Barrier.
! ARMv8.4
ARM-INSTRUCTION: TSB-CSYNC-encode ( 1101010100 0 00 011 0010 0010 010 11111 -- )

! TST (immediate): Test bits (immediate): an alias of ANDS (immediate).
ARM-INSTRUCTION: TSTi32-encode ( 0 11 100100 0 immrimms Rn 11111 -- )
ARM-INSTRUCTION: TSTi64-encode ( 1 11 100100 Nimmrimms Rn 11111 -- )

! TST (shifted register): Test (shifted register): an alias of ANDS (shifted register).
ARM-INSTRUCTION: TSTsr32-encode ( 0 11 01010 shift2 0 Rm imm6 Rn 11111 -- )
ARM-INSTRUCTION: TSTsr64-encode ( 1 11 01010 shift2 0 Rm imm6 Rn 11111 -- )

! UBFIZ: Unsigned Bitfield Insert in Zero: an alias of UBFM.
ARM-INSTRUCTION: UBFIZ32-encode ( 0 10 100110 0 immr imms Rn Rd -- )
ARM-INSTRUCTION: UBFIZ64-encode ( 1 10 100110 1 immr imms Rn Rd -- )

! UBFM: Unsigned Bitfield Move.
ARM-INSTRUCTION: UBFM32-encode ( 0 10 100110 0 immr imms Rn Rd -- )
ARM-INSTRUCTION: UBFM64-encode ( 1 10 100110 1 immr imms Rn Rd -- )

! UBFX: Unsigned Bitfield Extract: an alias of UBFM.
ARM-INSTRUCTION: UBFX32-encode ( 0 10 100110 0 immr imms Rn Rd -- )
ARM-INSTRUCTION: UBFX64-encode ( 1 10 100110 1 immr imms Rn Rd -- )

! UDF: Permanently Undefined.
ARM-INSTRUCTION: UDF-encode ( 0000000000000000 imm16 -- )

! UDIV: Unsigned Divide.
ARM-INSTRUCTION: UDIV32-encode ( 0 0 0 11010110 Rm 00001 0 Rn Rd -- )
ARM-INSTRUCTION: UDIV64-encode ( 1 0 0 11010110 Rm 00001 0 Rn Rd -- )

! UMADDL: Unsigned Multiply-Add Long.
ARM-INSTRUCTION: UMADDL-encode ( 1 00 11011 1 01 Rm 0 Ra Rn Rd -- )

! UMNEGL: Unsigned Multiply-Negate Long: an alias of UMSUBL.
ARM-INSTRUCTION: UMNEGL-encode ( 1 00 11011 1 01 Rm 1 11111 Rn Rd -- )

! UMSUBL: Unsigned Multiply-Subtract Long.
ARM-INSTRUCTION: UMSUBL-encode ( 1 00 11011 1 01 Rm 1 Ra Rn Rd -- )

! UMULH: Unsigned Multiply High.
ARM-INSTRUCTION: UMULH-encode ( 1 00 11011 1 10 Rm 0 11111 Rn Rd -- )

! UMULL: Unsigned Multiply Long: an alias of UMADDL.
ARM-INSTRUCTION: UMULL-encode ( 1 00 11011 1 01 Rm 0 11111 Rn Rd -- )

! UXTB: Unsigned Extend Byte: an alias of UBFM.
ARM-INSTRUCTION: UXTB-encode ( 0 10 100110 0 000000 000111 Rn Rd -- )

! UXTH: Unsigned Extend Halfword: an alias of UBFM.
ARM-INSTRUCTION: UXTH-encode ( 0 10 100110 0 000000 000111 Rn Rd -- )

! WFE: Wait For Event.
ARM-INSTRUCTION: WFE-encode ( 1101010100 0 00 011 0010 0000 010 11111 -- )

! WFI: Wait For Interrupt.
ARM-INSTRUCTION: WFI-encode ( 1101010100 0 00 011 0010 0000 011 11111 -- )

! XAFlag: Convert floating-point condition flags from external format to ARM format.
ARM-INSTRUCTION: XAFlag-encode ( 1101010100 0 00 000 0100 0000 001 11111 -- )

! XPACD, XPACI, XPACLRI: Strip Pointer Authentication Code.
! ARMv8.3
ARM-INSTRUCTION: XPACD-encode ( 1 1 0 11010110 00001 0 1 000 1 11111 Rd -- )
ARM-INSTRUCTION: XPACI-encode ( 1 1 0 11010110 00001 0 1 000 0 11111 Rd -- )
ARM-INSTRUCTION: XPACLRI-encode ( 1101010100 0 00 011 0010 0000 111 11111 -- )

! YIELD: YIELD.
ARM-INSTRUCTION: YIELD-encode ( 1101010100 0 00 011 0010 0000 001 11111 -- )
