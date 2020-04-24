! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.error classes.parser effects
effects.parser fry generalizations kernel lexer math
math.bitwise math.parser multiline parser sequences
sequences.extras splitting vocabs.parser words words.symbol ;
IN: cpu.arm64.assembler

! https://static.docs.arm.com/ddi0487/fb/DDI0487F_b_armv8_arm.pdf

<<
SYNTAX: REGISTERS:
    ";"
    [
        create-word-in
        [ define-symbol ]
        [ dup name>> 1 tail string>number "ordinal" set-word-prop ] bi
    ] each-token ;
>>

GENERIC: register ( obj -- n )
M: word register "ordinal" word-prop ;
M: integer register ;
<<
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
FIELD: cmode4 4
FIELD: CRm4 4
FIELD: CRn4 4
FIELD: CRm 4
FIELD: CRn 4
FIELD: nzcv4 4
FIELD: nzcv 4
FIELD: o0 1
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

! https://www.element14.com/community/servlet/JiveServlet/previewBody/41836-102-1-229511/ARM.Reference_Manual.pdf
! pg 16
! cond code set in prev arm assembler
: >CC ( x -- x ) ; 
: EQ ( -- n ) 0000 >CC ;
: NE ( -- n ) 0001 >CC ;
: CS ( -- n ) 0010 >CC ;
: HS ( -- n ) 0010 >CC ;
: CC ( -- n ) 0011 >CC ;
: LO ( -- n ) 0011 >CC ;
: MI ( -- n ) 0100 >CC ;
: PL ( -- n ) 0101 >CC ;
: VS ( -- n ) 0110 >CC ;
: VC ( -- n ) 0111 >CC ;
: HI ( -- n ) 1000 >CC ;
: LS ( -- n ) 1001 >CC ;
: GE ( -- n ) 1010 >CC ;
: LT ( -- n ) 1011 >CC ;
: GT ( -- n ) 1100 >CC ;
: LE ( -- n ) 1101 >CC ;
: AL ( -- n ) 1110 >CC ;
: NV ( -- n ) 1111 >CC ;

: imm13>parts-64 ( imm13 -- imms immr N )
    [ -4 shift 4 bits ] [ 4 bits ] [ -8 shift ] tri ;

: imm12>parts-32 ( imm12 -- imms immr N-is-0 )
    [ -4 shift 4 bits ] [ 4 bits ] [ drop 0 ] tri ;


<<
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
    [ width ] map-zip
    dup values [ f = ] any? [ throw ] when ;

ERROR: bad-instruction values ;
SYNTAX: ARM-INSTRUCTION:
    scan-new-word
    scan-effect
    [
      in>> arm-bitfield
      [ keys [ value ] map ]
      [ values 32 [ - ] accumulate* ] bi zip
      dup last second 0 = [ bad-instruction ] unless
      '[ _ bitfield* ]
    ] [ in>> [ string>number ] reject { "instruction" } <effect> ] bi define-declared ;
>>

! ADC: Add with Carry.
! ADCS: Add with Carry, setting flags.
ARM-INSTRUCTION: ADC32 ( 0 0 0 11010000 Rm 000000 Rn Rd -- instruction )
ARM-INSTRUCTION: ADCS32 ( 0 0 1 11010000 Rm 000000 Rn Rd -- instruction )
ARM-INSTRUCTION: ADC64 ( 1 0 0 11010000 Rm 000000 Rn Rd -- instruction )
ARM-INSTRUCTION: ADCS64 ( 1 0 1 11010000 Rm 000000 Rn Rd -- instruction )

! ADD (extended register): Add (extended register).
ARM-INSTRUCTION: ADDer32 ( 0 0 0 01011 00 0 Rm option3 imm3 Rn Rd -- instruction )
ARM-INSTRUCTION: ADDer64 ( 1 0 0 01011 00 0 Rm option3 imm3 Rn Rd -- instruction )

! ADD (immediate): Add (immediate).
ARM-INSTRUCTION: ADDi32 ( 0 0 0 10001 shift2 imm12 Rn Rd -- instruction )
ARM-INSTRUCTION: ADDi64 ( 1 0 0 10001 shift2 imm12 Rn Rd -- instruction )

! ADD (shifted register): Add (shifted register).
ARM-INSTRUCTION: ADDsr32 ( 0 0 0 01011 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: ADDsr64 ( 1 0 0 01011 shift2 0 Rm imm6 Rn Rd -- instruction )

ARM-INSTRUCTION: ADDs ( 01 0 11110 size2 1 Rm 10000 1 Rn Rd -- instruction )

! ADDG: Add with Tag.
ARM-INSTRUCTION: ADDG ( 1 0 0 100011 0 uimm6 00 uimm4 Xn Xd -- instruction )

! ADDS (extended register): Add (extended register), setting flags.
ARM-INSTRUCTION: ADDSer32 ( 0 0 1 01011 00 1 Rm option3 imm3 Rn Rd -- instruction )
ARM-INSTRUCTION: ADDSer64 ( 1 0 1 01011 00 1 Rm option3 imm3 Rn Rd -- instruction )

! ADDS (immediate): Add (immediate), setting flags.
ARM-INSTRUCTION: ADDSi32 ( 0 0 1 10001 shift2 imm12 Rn Rd -- instruction )
ARM-INSTRUCTION: ADDSi64 ( 1 0 1 10001 shift2 imm12 Rn Rd -- instruction )

! ADDS (shifted register): Add (shifted register), setting flags.
ARM-INSTRUCTION: ADDSsr32 ( 0 0 1 01011 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: ADDSsr64 ( 1 0 1 01011 shift2 0 Rm imm6 Rn Rd -- instruction )

! ADR: Form PC-relative address.
! ADRP: Form PC-relative address to 4KB page.
ARM-INSTRUCTION: ADR  ( 0 immlo2 10000 immhi19 Rd -- instruction )
ARM-INSTRUCTION: ADRP ( 1 immlo2 10000 immhi19 Rd -- instruction )


! AND (immediate): Bitwise AND (immediate).
ARM-INSTRUCTION: ANDi32 ( 0 00 100100 0 immrimms Rn Rd -- instruction )
ARM-INSTRUCTION: ANDi64 ( 1 00 100100 Nimmrimms Rn Rd -- instruction )

! AND (shifted register): Bitwise AND (shifted register).
ARM-INSTRUCTION: ANDsr32 ( 0 00 01010 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: ANDsr64 ( 1 00 01010 shift2 0 Rm imm6 Rn Rd -- instruction )

! ANDS (immediate): Bitwise AND (immediate), setting flags.
ARM-INSTRUCTION: ANDSi32 ( 0 11 100100 0 immrimms Rn Rd -- instruction )
ARM-INSTRUCTION: ANDSi64 ( 1 11 100100 Nimmrimms Rn Rd -- instruction )

! ANDS (shifted register): Bitwise AND (shifted register), setting flags.
ARM-INSTRUCTION: ANDSsr32 ( 0 11 01010 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: ANDSsr64 ( 1 11 01010 shift2 0 Rm imm6 Rn Rd -- instruction )

! ASR (immediate): Arithmetic Shift Right (immediate): an alias of SBFM.
ARM-INSTRUCTION: ASRi32 ( 0 00 100110 0 immr 011111 Rn Rd -- instruction )
ARM-INSTRUCTION: ASRi64 ( 1 00 100110 1 immr 111111 Rn Rd -- instruction )

! ASR (register): Arithmetic Shift Right (register): an alias of ASRV.
ARM-INSTRUCTION: ASRr32 ( 0 0 0 11010110 Rm 0010 10 Rn Rd -- instruction )
ARM-INSTRUCTION: ASRr64 ( 1 0 0 11010110 Rm 0010 10 Rn Rd -- instruction )

! ASRV: Arithmetic Shift Right Variable.
ARM-INSTRUCTION: ASRV32 ( 0 0 0 11010110 Rm 0010 10 Rn Rd -- instruction )
ARM-INSTRUCTION: ASRV64 ( 1 0 0 11010110 Rm 0010 10 Rn Rd -- instruction )

! AT: Address Translate: an alias of SYS.
ARM-INSTRUCTION: AT ( 1101010100 0 01 op3 0111 1000 op3 Rt -- instruction )

! AUTDA, AUTDZA: Authenticate Data address, using key A.
! AUTDB, AUTDZB: Authenticate Data address, using key B.
ARM-INSTRUCTION: AUTDA  ( 1 1 0 11010110 00001 0 0 0 110 Rn Rd -- instruction )
ARM-INSTRUCTION: AUTDZA ( 1 1 0 11010110 00001 0 0 1 110 11111 Rd -- instruction )
ARM-INSTRUCTION: AUTDB  ( 1 1 0 11010110 00001 0 0 0 111 Rn Rd -- instruction )
ARM-INSTRUCTION: AUTDZB ( 1 1 0 11010110 00001 0 0 1 111 11111 Rd -- instruction )

! AUTIA, AUTIA1716, AUTIASP, AUTIAZ, AUTIZA: Authenticate Instruction address, using key A.
! ARMv8.3
ARM-INSTRUCTION: AUTIA  ( 1 1 0 11010110 00001 0 0 0 100 Rn Rd -- instruction )
ARM-INSTRUCTION: AUTIZA ( 1 1 0 11010110 00001 0 0 1 100 11111 Rd -- instruction )
! ARMv8.3
ARM-INSTRUCTION: AUTIA1716 ( 1101010100 0 00 011 0010 0001 100 11111 -- instruction )
ARM-INSTRUCTION: AUTIASP   ( 1101010100 0 00 011 0010 0011 101 11111 -- instruction )
ARM-INSTRUCTION: AUTIAAZ   ( 1101010100 0 00 011 0010 0011 100 11111 -- instruction )

! AUTIB, AUTIB1716, AUTIBSP, AUTIBZ, AUTIZB: Authenticate Instruction address, using key B.
! ARMv8.3
ARM-INSTRUCTION: AUTIB  ( 1 1 0 11010110 00001 0 0 0 101 Rn Rd -- instruction )
ARM-INSTRUCTION: AUTIZB ( 1 1 0 11010110 00001 0 0 1 101 11111 Rd -- instruction )
! ARMv8.3
ARM-INSTRUCTION: AUTIB1716 ( 1101010100 0 00 011 0010 0001 110 11111 -- instruction )
ARM-INSTRUCTION: AUTIBSP   ( 1101010100 0 00 011 0010 0011 111 11111 -- instruction )
ARM-INSTRUCTION: AUTIBZ    ( 1101010100 0 00 011 0010 0011 110 11111 -- instruction )

! AXFlag: Convert floating-point condition flags from ARM to external format.
ARM-INSTRUCTION: AXFlag ( 1101010100 0 00 000 0100 0000 010 11111 -- instruction )

! B: Branch.
ARM-INSTRUCTION: B ( 0 00101 imm26 -- instruction )

! B.cond: Branch conditionally.
ARM-INSTRUCTION: B.cond ( 0101010 0 imm19 0 cond4 -- instruction )

! BFC: Bitfield Clear: an alias of BFM.
ARM-INSTRUCTION: BFC32 ( 0 01 100110 0 immrimms 11111 Rd -- instruction )
ARM-INSTRUCTION: BFC64 ( 1 01 100110 Nimmrimms 11111 Rd -- instruction )

! BFI: Bitfield Insert: an alias of BFM.
ARM-INSTRUCTION: BFI32 ( 0 01 100110 0 immrimms Rn Rd -- instruction )
ARM-INSTRUCTION: BFI64 ( 1 01 100110 Nimmrimms Rn Rd -- instruction )

! BFM: Bitfield Move.
ARM-INSTRUCTION: BFM32 ( 0 01 100110 0 immrimms Rn Rd -- instruction )
ARM-INSTRUCTION: BFM64 ( 1 01 100110 Nimmrimms Rn Rd -- instruction )

! BFXIL: Bitfield extract and insert at low end: an alias of BFM.
ARM-INSTRUCTION: BFXIL32 ( 0 01 100110 0 immrimms Rn Rd -- instruction )
ARM-INSTRUCTION: BFXIL64 ( 1 01 100110 Nimmrimms Rn Rd -- instruction )

! BIC (shifted register): Bitwise Bit Clear (shifted register).
ARM-INSTRUCTION: BIC ( 0 Q 1 0111100000 a1 b1 c1 cmode4 0 1 d1 e1 f1 g1 h1 Rd -- instruction )
! BIC (shifted register): Bitwise Bit Clear (shifted register).
ARM-INSTRUCTION: BICsr32 ( 0 00 01010 shift2 1 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: BICsr64 ( 1 00 01010 shift2 1 Rm imm6 Rn Rd -- instruction )
! BICS (shifted register): Bitwise Bit Clear (shifted register), setting flags.
ARM-INSTRUCTION: BICSsr32 ( 0 11 01010 shift2 1 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: BICSsr64 ( 1 11 01010 shift2 1 Rm imm6 Rn Rd -- instruction )
! BL: Branch with Link.
ARM-INSTRUCTION: BL ( 1 00101 imm26 -- instruction )
! BLR: Branch with Link to Register.
ARM-INSTRUCTION: BLR ( 1101011 0 0 01 11111 0000 0 0 Rn 00000 -- instruction )

! BLRAA, BLRAAZ, BLRAB, BLRABZ: Branch with Link to Register, with pointer authentication.
ARM-INSTRUCTION: BLRAA  ( 1101011 0 0 01 11111 0000 1 0 Rn Rm -- instruction )
ARM-INSTRUCTION: BLRAAZ ( 1101011 1 0 01 11111 0000 1 0 Rn 11111 -- instruction )
ARM-INSTRUCTION: BLRAB  ( 1101011 0 0 01 11111 0000 1 1 Rn Rm -- instruction )
ARM-INSTRUCTION: BLRABZ ( 1101011 1 0 01 11111 0000 1 1 Rn 11111 -- instruction )

! BR: Branch to Register.
ARM-INSTRUCTION: BR ( 1101011 0 0 00 11111 0000 0 0 Rn 00000 -- instruction )

! BRAA, BRAAZ, BRAB, BRABZ: Branch to Register, with pointer authentication.
ARM-INSTRUCTION: BRAA  ( 1101011 0 0 00 11111 0000 1 0 Rn 11111 -- instruction )
ARM-INSTRUCTION: BRAAZ ( 1101011 1 0 00 11111 0000 1 0 Rn Rm -- instruction )
ARM-INSTRUCTION: BRAB  ( 1101011 0 0 00 11111 0000 1 1 Rn 11111 -- instruction )
ARM-INSTRUCTION: BRABZ ( 1101011 1 0 00 11111 0000 1 1 Rn Rm -- instruction )

! BRK: Breakpoint instruction.
ARM-INSTRUCTION: BRK ( 11010100 001 imm16 000 00 -- instruction )
! BTI: Branch Target Identification.
ARM-INSTRUCTION: BTI ( 1101010100 0 00 011 0010 0100 000 11111 -- instruction )

! CAS, CASA, CASAL, CASL: Compare and Swap word or doubleword in memory.
ARM-INSTRUCTION: CAS32   ( 10 001000 1 0 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASA32  ( 10 001000 1 1 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASAL32 ( 10 001000 1 1 1 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASL32  ( 10 001000 1 0 1 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CAS64   ( 11 001000 1 0 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASA64  ( 11 001000 1 1 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASAL64 ( 11 001000 1 1 1 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASL64  ( 11 001000 1 0 1 Rs 1 11111 Rn Rt -- instruction )

! CASB, CASAB, CASALB, CASLB: Compare and Swap byte in memory.
ARM-INSTRUCTION: CASAB  ( 00 001000 1 1 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASALB ( 00 001000 1 1 1 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASB   ( 00 001000 1 0 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASLB  ( 00 001000 1 0 1 Rs 1 11111 Rn Rt -- instruction )

! CASH, CASAH, CASALH, CASLH: Compare and Swap halfword in memory.
ARM-INSTRUCTION: CASAH  ( 01 001000 1 1 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASALH ( 01 001000 1 1 1 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASH   ( 01 001000 1 0 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASLH  ( 01 001000 1 0 1 Rs 1 11111 Rn Rt -- instruction )

! CASP, CASPA, CASPAL, CASPL: Compare and Swap Pair of words or doublewords in memory.
ARM-INSTRUCTION: CASP32   ( 0 0 001000 0 0 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASPA32  ( 0 0 001000 0 1 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASPAL32 ( 0 0 001000 0 1 1 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASPL32  ( 0 0 001000 0 0 1 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASP64   ( 0 1 001000 0 0 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASPA64  ( 0 1 001000 0 1 1 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASPAL64 ( 0 1 001000 0 1 1 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: CASPL64  ( 0 1 001000 0 0 1 Rs 1 11111 Rn Rt -- instruction )

! CBNZ: Compare and Branch on Nonzero.
ARM-INSTRUCTION: CBNZ32 ( 0 011010 1 imm19 Rt -- instruction )
ARM-INSTRUCTION: CBNZ64 ( 1 011010 1 imm19 Rt -- instruction )

! CBZ: Compare and Branch on Zero.
ARM-INSTRUCTION: CBZ32 ( 0 011010 0 imm19 Rt -- instruction )
ARM-INSTRUCTION: CBZ64 ( 1 011010 0 imm19 Rt -- instruction )


! CCMN (immediate): Conditional Compare Negative (immediate).
ARM-INSTRUCTION: CCMNi32 ( 0 0 1 11010010 imm5 cond4 1 0 Rn 0 nzcv4 -- instruction )
ARM-INSTRUCTION: CCMNi64 ( 1 0 1 11010010 imm5 cond4 1 0 Rn 0 nzcv4 -- instruction )
! CCMN (register): Conditional Compare Negative (register).
ARM-INSTRUCTION: CCMNr32 ( 0 0 1 11010010 Rm cond4 0 0 Rn 0 nzcv4 -- instruction )
ARM-INSTRUCTION: CCMNr64 ( 1 0 1 11010010 Rm cond4 0 0 Rn 0 nzcv4 -- instruction )
! CCMP (immediate): Conditional Compare (immediate).
ARM-INSTRUCTION: CCMPi32 ( 0 1 1 11010010 imm5 cond4 1 0 Rn 0 nzcv4 -- instruction )
ARM-INSTRUCTION: CCMPi64 ( 1 1 1 11010010 imm5 cond4 1 0 Rn 0 nzcv4 -- instruction )
! CCMP (register): Conditional Compare (register).
ARM-INSTRUCTION: CCMPr32 ( 0 1 1 11010010 Rm cond4 0 0 Rn 0 nzcv4 -- instruction )
ARM-INSTRUCTION: CCMPr64 ( 1 1 1 11010010 Rm cond4 0 0 Rn 0 nzcv4 -- instruction )

! CFINV: Invert Carry Flag.
ARM-INSTRUCTION: CFINV ( 1101010100 0 0 0 000 0100 0000 000 11111 -- instruction )
! CFP: Control Flow Prediction Restriction by Context: an alias of SYS.
ARM-INSTRUCTION: CFP ( 1101010100 0 01 011 0111 0011 100 Rt -- instruction )
! CINC: Conditional Increment: an alias of CSINC.
ARM-INSTRUCTION: CINC32 ( 0 0 0 11010100 Rm cond4 0 1 Rn Rd -- instruction )
ARM-INSTRUCTION: CINC64 ( 1 0 0 11010100 Rm cond4 0 1 Rn Rd -- instruction )
! CINV: Conditional Invert: an alias of CSINV.
ARM-INSTRUCTION: CINV32 ( 0 0 0 11010100 Rm cond4 0 0 Rn Rd -- instruction )
ARM-INSTRUCTION: CINV64 ( 1 0 0 11010100 Rm cond4 0 0 Rn Rd -- instruction )
! CLREX: Clear Exclusive.
ARM-INSTRUCTION: CLREX ( 1101010100 0 00 011 0011 CRm 010 11111 -- instruction )
! CLS: Count Leading Sign bits.
ARM-INSTRUCTION: CLS32 ( 0 1 0 11010110 00000 00010 1 Rn Rd -- instruction )
ARM-INSTRUCTION: CLS64 ( 1 1 0 11010110 00000 00010 1 Rn Rd -- instruction )
! CLZ: Count Leading Zeros.
ARM-INSTRUCTION: CLZ32 ( 0 1 0 11010110 00000 00010 0 Rn Rd -- instruction )
ARM-INSTRUCTION: CLZ64 ( 1 1 0 11010110 00000 00010 0 Rn Rd -- instruction )

! CMN (extended register): Compare Negative (extended register): an alias of ADDS (extended register).
ARM-INSTRUCTION: CMNer32 ( 0 0 1 01011 00 1 Rm option3 imm3 Rn Rd -- instruction )
ARM-INSTRUCTION: CMNer64 ( 1 0 1 01011 00 1 Rm option3 imm3 Rn Rd -- instruction )
! CMN (immediate): Compare Negative (immediate): an alias of ADDS (immediate).
ARM-INSTRUCTION: CMNi32 ( 0 0 1 10001 shift2 imm12 Rn 11111 -- instruction )
ARM-INSTRUCTION: CMNi64 ( 1 0 1 10001 shift2 imm12 Rn 11111 -- instruction )
! CMN (shifted register): Compare Negative (shifted register): an alias of ADDS (shifted register).
ARM-INSTRUCTION: CMN-sr32 ( 0 0 1 01011 shift2 0 Rm imm6 Rn 11111 -- instruction )
ARM-INSTRUCTION: CMN-sr64 ( 1 0 1 01011 shift2 0 Rm imm6 Rn 11111 -- instruction )

! CMP (extended register): Compare (extended register): an alias of SUBS (extended register).
ARM-INSTRUCTION: CMPer32 ( 0 1 1 01011 00 1 Rm option3 imm3 Rn 11111 -- instruction )
ARM-INSTRUCTION: CMPer64 ( 1 1 1 01011 00 1 Rm option3 imm3 Rn 11111 -- instruction )
! CMP (immediate): Compare (immediate): an alias of SUBS (immediate).
ARM-INSTRUCTION: CMPi32 ( 0 1 1 10001 shift2 imm12 Rn 11111 -- instruction )
ARM-INSTRUCTION: CMPi64 ( 1 1 1 10001 shift2 imm12 Rn 11111 -- instruction )
! CMP (shifted register): Compare (shifted register): an alias of SUBS (shifted register).
ARM-INSTRUCTION: CMPsr32 ( 0 1 1 01011 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: CMPsr64 ( 1 1 1 01011 shift2 0 Rm imm6 Rn Rd -- instruction )

! CMPP: Compare with Tag: an alias of SUBPS.
ARM-INSTRUCTION: CMPP ( 1 0 1 11010110 Xm 0 0 0 0 0 0 Xn Xd -- instruction )
! CNEG: Conditional Negate: an alias of CSNEG.
ARM-INSTRUCTION: CNEG32 ( 0 1 0 11010100 Rm cond4 0 1 Rn Rd -- instruction )
ARM-INSTRUCTION: CNEG64 ( 1 1 0 11010100 Rm cond4 0 1 Rn Rd -- instruction )
! CPP: Cache Prefetch Prediction Restriction by Context: an alias of SYS.
ARM-INSTRUCTION: CPP ( 1101010100 0 01 011 0111 0011 111 Rt -- instruction )

! CRC32B, CRC32H, CRC32W, CRC32X: CRC32 checksum.
ARM-INSTRUCTION: CRC32B32 ( 0 0 0 11010110 Rm 010 0 00 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32B64 ( 1 0 0 11010110 Rm 010 0 00 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32H32 ( 0 0 0 11010110 Rm 010 0 01 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32H64 ( 1 0 0 11010110 Rm 010 0 01 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32W32 ( 0 0 0 11010110 Rm 010 0 10 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32W64 ( 1 0 0 11010110 Rm 010 0 10 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32X32 ( 0 0 0 11010110 Rm 010 0 11 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32X64 ( 1 0 0 11010110 Rm 010 0 11 Rn Rd -- instruction )

! CRC32CB, CRC32CH, CRC32CW, CRC32CX: CRC32C checksum.
ARM-INSTRUCTION: CRC32CB32 ( 0 0 0 11010110 Rm 010 1 00 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32CB64 ( 1 0 0 11010110 Rm 010 1 00 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32CH32 ( 0 0 0 11010110 Rm 010 1 01 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32CH64 ( 1 0 0 11010110 Rm 010 1 01 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32CW32 ( 0 0 0 11010110 Rm 010 1 10 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32CW64 ( 1 0 0 11010110 Rm 010 1 10 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32CX32 ( 0 0 0 11010110 Rm 010 1 11 Rn Rd -- instruction )
ARM-INSTRUCTION: CRC32CX64 ( 1 0 0 11010110 Rm 010 1 11 Rn Rd -- instruction )

! CSDB: Consumption of Speculative Data Barrier.
ARM-INSTRUCTION: CSDB ( 1101010100 0 00 011 0010 0010 100 11111 -- instruction )
! CSEL: Conditional Select.
ARM-INSTRUCTION: CSEL32 ( 0 0 0 11010100 Rm cond4 0 0 Rn Rd -- instruction )
ARM-INSTRUCTION: CSEL64 ( 1 0 0 11010100 Rm cond4 0 0 Rn Rd -- instruction )
! CSET: Conditional Set: an alias of CSINC.
ARM-INSTRUCTION: CSET32 ( 0 0 0 11010100 11111 cond4 0 1 11111 Rd -- instruction )
ARM-INSTRUCTION: CSET64 ( 1 0 0 11010100 11111 cond4 0 1 11111 Rd -- instruction )
! CSETM: Conditional Set Mask: an alias of CSINV.
ARM-INSTRUCTION: CSETM32 ( 0 0 0 11010100 11111 cond4 0 0 11111 Rd -- instruction )
ARM-INSTRUCTION: CSETM64 ( 1 0 0 11010100 11111 cond4 0 0 11111 Rd -- instruction )

! CSINC: Conditional Select Increment.
ARM-INSTRUCTION: CSINC32 ( 0 0 0 11010100 Rm cond4 0 1 Rn Rd -- instruction )
ARM-INSTRUCTION: CSINC64 ( 1 0 0 11010100 Rm cond4 0 1 Rn Rd -- instruction )

! CSINV: Conditional Select Invert.
ARM-INSTRUCTION: CSINV32 ( 0 0 0 11010100 Rm cond4 0 0 Rn Rd -- instruction )
ARM-INSTRUCTION: CSINV64 ( 1 0 0 11010100 Rm cond4 0 0 Rn Rd -- instruction )

! CSNEG: Conditional Select Negation.
ARM-INSTRUCTION: CSNEG32 ( 0 1 0 11010100 Rm cond4 0 1 Rn Rd -- instruction )
ARM-INSTRUCTION: CSNEG64 ( 1 1 0 11010100 Rm cond4 0 1 Rn Rd -- instruction )

! DC: Data Cache operation: an alias of SYS.
ARM-INSTRUCTION: DC ( 1101010100 0 01 op3 0111 CRm op3 Rt -- instruction )
! DCPS1: Debug Change PE State to EL1..
ARM-INSTRUCTION: DCPS1 ( 11010100 101 imm16 000 01 -- instruction )
! DCPS2: Debug Change PE State to EL2..
ARM-INSTRUCTION: DCPS2 ( 11010100 101 imm16 000 10 -- instruction )
! DCPS3: Debug Change PE State to EL3.
ARM-INSTRUCTION: DCPS3 ( 11010100 101 imm16 000 11 -- instruction )

! DMB: Data Memory Barrier.
ARM-INSTRUCTION: DMB ( 1101010100 0 00 011 0011 CRm 1 01 11111 -- instruction )
! DRPS: Debug restore process state.
ARM-INSTRUCTION: DPRS ( 1101011 0101 11111 000000 11111 00000 -- instruction )
! DSB: Data Synchronization Barrier.
ARM-INSTRUCTION: DSB ( 1101010100 0 00 011 0011 CRm 1 00 11111 -- instruction )
! DVP: Data Value Prediction Restriction by Context: an alias of SYS.
ARM-INSTRUCTION: DVP ( 1101010100 0 01 011 0111 0011 101 Rt -- instruction )

! EON (shifted register): Bitwise Exclusive OR NOT (shifted register).
ARM-INSTRUCTION: EONsr32 ( 0 10 01010 shift2 1 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: EONsr64 ( 1 10 01010 shift2 1 Rm imm6 Rn Rd -- instruction )

! EOR (immediate): Bitwise Exclusive OR (immediate).
ARM-INSTRUCTION: EORi32 ( 0 10 100100 0 immrimms Rn Rd -- instruction )
ARM-INSTRUCTION: EORi64 ( 1 10 100100 Nimmrimms Rn Rd -- instruction )

! EOR (shifted register): Bitwise Exclusive OR (shifted register).
ARM-INSTRUCTION: EORsr32 ( 0 10 01010 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: EORsr64 ( 1 10 01010 shift2 0 Rm imm6 Rn Rd -- instruction )

! ERET: Exception Return.
ARM-INSTRUCTION: ERET ( 1101011 0 100 11111 0000 0 0 11111 00000 -- instruction )

! ERETAA, ERETAB: Exception Return, with pointer authentication.
! ARMv8.3
ARM-INSTRUCTION: ERETAA ( 1101011 0 100 11111 0000 1 0 11111 00000 -- instruction )
ARM-INSTRUCTION: ERETAB ( 1101011 0 100 11111 0000 1 1 11111 11111 -- instruction )

! ESB: Error Synchronization Barrier.
! ARMv8.2
ARM-INSTRUCTION: ESB ( 1101010100 0 00 011 0010 0010 000 11111 -- instruction )
! EXTR: Extract register.
ARM-INSTRUCTION: EXTR32 ( 0 00 100111 0 0 Rm imms Rn Rd -- instruction )
ARM-INSTRUCTION: EXTR64 ( 1 00 100111 1 0 Rm imms Rn Rd -- instruction )

! GMI: Tag Mask Insert.
ARM-INSTRUCTION: GMI ( 1 0 0 11010110 Xm 0 0 0 1 0 1 Xn Xd -- instruction )
! HINT: Hint instruction.
ARM-INSTRUCTION: HINT ( 1101010100 0 00 011 0010 CRm op3 11111 -- instruction )
! HLT: Halt instruction.
ARM-INSTRUCTION: HLT ( 11010100 010 imm16 000 00 -- instruction )

! HVC: Hypervisor Call.
ARM-INSTRUCTION: HVC ( 11010100 000 imm16 000 10 -- instruction )
! IC: Instruction Cache operation: an alias of SYS.
ARM-INSTRUCTION: IC ( 1101010100 0 01 op3 0111 CRm op3 Rt -- instruction )
! IRG: Insert Random Tag.
ARM-INSTRUCTION: IRG ( 1 0 0 11010110 Xm 0 0 0 1 0 0 Xn Xd -- instruction )
! ISB: Instruction Synchronization Barrier.
ARM-INSTRUCTION: ISB ( 1101010100 0 00 011 0011 CRm 1 10 11111 -- instruction )

! LDADD, LDADDA, LDADDAL, LDADDL: Atomic add on word or doubleword in memory.
ARM-INSTRUCTION: LDADD32   ( 10 111 0 00 0 0 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDA32  ( 10 111 0 00 1 0 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDAL32 ( 10 111 0 00 1 1 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDL32  ( 10 111 0 00 0 1 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADD64   ( 11 111 0 00 0 0 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDA64  ( 11 111 0 00 1 0 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDAL64 ( 11 111 0 00 1 1 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDL64  ( 11 111 0 00 0 1 1 Rs 0 000 00 Rn Rt -- instruction )

! LDADDB, LDADDAB, LDADDALB, LDADDLB: Atomic add on byte in memory.
ARM-INSTRUCTION: LDADDAB  ( 00 111 0 00 1 0 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDALB ( 00 111 0 00 1 1 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDB   ( 00 111 0 00 0 0 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDLB  ( 00 111 0 00 0 1 1 Rs 0 000 00 Rn Rt -- instruction )

! LDADDH, LDADDAH, LDADDALH, LDADDLH: Atomic add on halfword in memory.
ARM-INSTRUCTION: LDADDAH  ( 01 111 0 00 1 0 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDALH ( 01 111 0 00 1 1 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDH   ( 01 111 0 00 0 0 1 Rs 0 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDADDLH  ( 01 111 0 00 0 1 1 Rs 0 000 00 Rn Rt -- instruction )

! LDAPR: Load-Acquire RCpc Register.
! ARMv8.3
ARM-INSTRUCTION: LDAPR32 ( 10 111 0 00 1 0 1 11111 1 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDAPR64 ( 11 111 0 00 1 0 1 11111 1 100 00 Rn Rt -- instruction )
! LDAPRB: Load-Acquire RCpc Register Byte.
ARM-INSTRUCTION: LDAPRB ( 00 111 0 00 1 0 1 11111 1 100 00 Rn Rt -- instruction )
! LDAPRH: Load-Acquire RCpc Register Halfword.
ARM-INSTRUCTION: LDAPRH ( 01 111 0 00 1 0 1 11111 1 100 00 Rn Rt -- instruction )

! LDAPUR: Load-Acquire RCpc Register (unscaled).
ARM-INSTRUCTION: LDAPUR32 ( 10 011001 01 0 imm9 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDAPUR64 ( 11 011001 01 0 imm9 00 Rn Rt -- instruction )
! LDAPURB: Load-Acquire RCpc Register Byte (unscaled).
ARM-INSTRUCTION: LDAPURB ( 00 011001 01 0 imm9 00 Rn Rt -- instruction )
! LDAPURH: Load-Acquire RCpc Register Halfword (unscaled).
ARM-INSTRUCTION: LDAPURH ( 01 011001 01 0 imm9 00 Rn Rt -- instruction )
! LDAPURSB: Load-Acquire RCpc Register Signed Byte (unscaled).
ARM-INSTRUCTION: LDAPURSB32 ( 00 011001 11 0 imm9 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDAPURSB64 ( 00 011001 10 0 imm9 00 Rn Rt -- instruction )
! LDAPURSH: Load-Acquire RCpc Register Signed Halfword (unscaled).
ARM-INSTRUCTION: LDAPURSH32 ( 01 011001 11 0 imm9 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDAPURSH64 ( 01 011001 10 0 imm9 00 Rn Rt -- instruction )
! LDAPURSW: Load-Acquire RCpc Register Signed Word (unscaled).
ARM-INSTRUCTION: LDAPURSW ( 10 011001 10 0 imm9 00 Rn Rt -- instruction )
! LDAR: Load-Acquire Register.
ARM-INSTRUCTION: LDAR32 ( 10 001000 1 1 0 11111 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: LDAR64 ( 11 001000 1 1 0 11111 1 11111 Rn Rt -- instruction )
! LDARB: Load-Acquire Register Byte.
ARM-INSTRUCTION: LDARB ( 00 001000 1 1 0 11111 1 11111 Rn Rt -- instruction )
! LDARH: Load-Acquire Register Halfword.
ARM-INSTRUCTION: LDARH ( 01 001000 1 1 0 11111 1 11111 Rn Rt -- instruction )
! LDAXP: Load-Acquire Exclusive Pair of Registers.
ARM-INSTRUCTION: LDAXP32 ( 1 0 001000 0 1 1 11111 1 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDAXP64 ( 1 1 001000 0 1 1 11111 1 Rt2 Rn Rt -- instruction )
! LDAXR: Load-Acquire Exclusive Register.
ARM-INSTRUCTION: LDAXR32 ( 10 001000 0 1 0 11111 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: LDAXR64 ( 11 001000 0 1 0 11111 1 11111 Rn Rt -- instruction )
! LDAXRB: Load-Acquire Exclusive Register Byte.
ARM-INSTRUCTION: LDAXRB ( 00 001000 0 1 0 11111 1 11111 Rn Rt -- instruction )
! LDAXRH: Load-Acquire Exclusive Register Halfword.
ARM-INSTRUCTION: LDAXRH ( 01 001000 0 1 0 11111 1 11111 Rn Rt -- instruction )

! LDCLR, LDCLRA, LDCLRAL, LDCLRL: Atomic bit clear on word or doubleword in memory.
ARM-INSTRUCTION: LDCLR32   ( 10 111 0 00 0 0 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRA32  ( 10 111 0 00 1 0 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRAL32 ( 10 111 0 00 1 1 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRL32  ( 10 111 0 00 0 1 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLR64   ( 11 111 0 00 0 0 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRA64  ( 11 111 0 00 1 0 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRAL64 ( 11 111 0 00 1 1 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRL64  ( 11 111 0 00 0 1 1 Rs 0 001 00 Rn Rt -- instruction )

! LDCLRB, LDCLRAB, LDCLRALB, LDCLRLB: Atomic bit clear on byte in memory.
ARM-INSTRUCTION: LDCLRAB  ( 00 111 0 00 1 0 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRALB ( 00 111 0 00 1 1 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRB   ( 00 111 0 00 0 0 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRLB  ( 00 111 0 00 0 1 1 Rs 0 001 00 Rn Rt -- instruction )

! LDCLRH, LDCLRAH, LDCLRALH, LDCLRLH: Atomic bit clear on halfword in memory.
ARM-INSTRUCTION: LDCLRAH  ( 01 111 0 00 1 0 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRALH ( 01 111 0 00 1 1 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRA   ( 01 111 0 00 0 0 1 Rs 0 001 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDCLRLH  ( 01 111 0 00 0 1 1 Rs 0 001 00 Rn Rt -- instruction )

! LDEOR, LDEORA, LDEORAL, LDEORL: Atomic exclusive OR on word or doubleword in memory.
ARM-INSTRUCTION: LDEOR32   ( 10 111 0 00 0 0 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORA32  ( 10 111 0 00 1 0 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORAL32 ( 10 111 0 00 1 1 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORL32  ( 10 111 0 00 0 1 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEOR64   ( 11 111 0 00 0 0 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORA64  ( 11 111 0 00 1 0 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORAL64 ( 11 111 0 00 1 1 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORL64  ( 11 111 0 00 0 1 1 Rs 0 010 00 Rn Rt -- instruction )

! LDEORB, LDEORAB, LDEORALB, LDEORLB: Atomic exclusive OR on byte in memory.
ARM-INSTRUCTION: LDEORAB  ( 00 111 0 00 1 0 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORALB ( 00 111 0 00 1 1 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORB   ( 00 111 0 00 0 0 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORLB  ( 00 111 0 00 0 1 1 Rs 0 010 00 Rn Rt -- instruction )

! LDEORH, LDEORAH, LDEORALH, LDEORLH: Atomic exclusive OR on halfword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDEORAH  ( 01 111 0 00 1 0 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORALH ( 01 111 0 00 1 1 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORH   ( 01 111 0 00 0 0 1 Rs 0 010 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDEORLH  ( 01 111 0 00 0 1 1 Rs 0 010 00 Rn Rt -- instruction )

! LDG: Load Allocation Tag.
! ARMv8.5
ARM-INSTRUCTION: LDG ( 11011001 0 1 1 imm9 0 0 Xn Xt -- instruction )
! LDGV: Load Allocation Tag.
! ARMv8.5
ARM-INSTRUCTION: LDGV ( 11011001 1 1 1 0 0 0 0 0 0 0 0 0 0 0 Xn Xt -- instruction )

! LDLAR: Load LOAcquire Register.
! ARMv8.1
ARM-INSTRUCTION: LDLAR32 ( 10 001000 1 1 0 11111 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: LDLAR64 ( 11 001000 1 1 0 11111 0 11111 Rn Rt -- instruction )
! LDLARB: Load LOAcquire Register Byte.
ARM-INSTRUCTION: LDLARB ( 00 001000 1 1 0 11111 0 11111 Rn Rt -- instruction )
! LDLARH: Load LOAcquire Register Halfword.
ARM-INSTRUCTION: LDLARH ( 01 001000 1 1 0 11111 0 11111 Rn Rt -- instruction )

! LDNP: Load Pair of Registers, with non-temporal hint.
ARM-INSTRUCTION: LDNP32 ( 00 101 0 000 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDNP64 ( 10 101 0 000 1 imm7 Rt2 Rn Rt -- instruction )

! LDP: Load Pair of Registers.
ARM-INSTRUCTION: LDPpost32 ( 00 101 0 001 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPpost64 ( 10 101 0 001 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPpre32  ( 00 101 0 011 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPpre64  ( 10 101 0 011 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPsoff32 ( 00 101 0 010 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPsoff64 ( 10 101 0 010 1 imm7 Rt2 Rn Rt -- instruction )

! LDPSW: Load Pair of Registers Signed Word.
ARM-INSTRUCTION: LDPSWpost32 ( 01 101 0 001 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPSWpost64 ( 01 101 0 001 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPSWpre32  ( 01 101 0 011 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPSWpre64  ( 01 101 0 011 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPSWsoff32 ( 01 101 0 010 1 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDPSWsoff64 ( 01 101 0 010 1 imm7 Rt2 Rn Rt -- instruction )

! LDR (immediate): Load Register (immediate).
ARM-INSTRUCTION: LDRipost32 ( 10 111 0 00 01 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRipost64 ( 11 111 0 00 01 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRipre32  ( 10 111 0 00 01 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRipre64  ( 11 111 0 00 01 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRiuoff32 ( 10 111 0 01 01 imm12 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRiuoff64 ( 11 111 0 01 01 imm12 Rn Rt -- instruction )

! LDR (literal): Load Register (literal).
ARM-INSTRUCTION: LDRl32 ( 00 011 0 00 imm19 Rt -- instruction )
ARM-INSTRUCTION: LDRl64 ( 00 011 0 00 imm19 Rt -- instruction )

! LDR (register): Load Register (register).
ARM-INSTRUCTION: LDRr32 ( 10 111 0 00 01 1 Rm option3 S 1 0 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRr64 ( 11 111 0 00 01 1 Rm option3 S 1 0 Rn Rt -- instruction )

! LDRAA, LDRAB: Load Register, with pointer authentication.
! ARMv8.3
ARM-INSTRUCTION: LDRAAoff ( 11 111 0 00 0 S 1 imm9 0 1 Rn Rt  -- instruction )
ARM-INSTRUCTION: LDRAApre ( 11 111 0 00 0 S 1 imm9 1 1 Rn Rt  -- instruction )
ARM-INSTRUCTION: LDRABoff ( 11 111 0 00 1 S 1 imm9 0 1 Rn Rt  -- instruction )
ARM-INSTRUCTION: LDRABpre ( 11 111 0 00 1 S 1 imm9 1 1 Rn Rt  -- instruction )

! LDRB (immediate): Load Register Byte (immediate).
ARM-INSTRUCTION: LDRBimmpost ( 00 111 0 00 01 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRBimmpre ( 00 111 0 00 01 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRBimmuoff ( 00 111 0 01 01 imm12 Rn Rt -- instruction )

! LDRB (register): Load Register Byte (register).
! option: 010: UXTW, 110 SXTW, 111 SXTX, S shift 0/1
ARM-INSTRUCTION: LDRBrext ( 00 111 0 00 01 1 Rm option3 S 10 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRBrshift ( 00 111 0 00 01 1 Rm 011 S 10 Rn Rt -- instruction )

! LDRH (immediate): Load Register Halfword (immediate).
ARM-INSTRUCTION: LDRHimmpost ( 01 111 0 00 01 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRHimmpre ( 01 111 0 00 01 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRHimmuoff ( 01 111 0 01 01 imm12 Rn Rt -- instruction )

! LDRH (register): Load Register Halfword (register).
ARM-INSTRUCTION: LDRHr ( 01 111 0 00 01 1 Rm option3 S 10 Rn Rt  -- instruction )

! LDRSB (immediate): Load Register Signed Byte (immediate).
ARM-INSTRUCTION: LDRSBimmpost32 ( 00 111 0 00 11 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSBimmpost64 ( 00 111 0 00 10 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSBimmpre32  ( 00 111 0 00 11 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSBimmpre64  ( 00 111 0 00 10 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSBimmuoff32 ( 00 111 0 01 11 imm12 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSBimmuoff64 ( 00 111 0 01 10 imm12 Rn Rt -- instruction )

! LDRSB (register): Load Register Signed Byte (register).
ARM-INSTRUCTION: LDRSBextreg32   ( 00 111 0 00 11 1 Rm option3 S 10 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSBshiftreg32 ( 00 111 0 00 11 1 Rm 011 S 10 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSBextreg64   ( 00 111 0 00 10 1 Rm option3 S 10 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSBshiftreg64 ( 00 111 0 00 10 1 Rm 011 S 10 Rn Rt -- instruction )

! LDRSH (immediate): Load Register Signed Halfword (immediate).
ARM-INSTRUCTION: LDRSHimmpost32 ( 01 111 0 00 11 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSHimmpost64 ( 01 111 0 00 10 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSHimmpre32  ( 01 111 0 00 11 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSHimmpre64  ( 01 111 0 00 10 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSHimmuoff32 ( 01 111 0 01 11 imm12 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSHimmuoff64 ( 01 111 0 01 10 imm12 Rn Rt -- instruction )

! LDRSH (register): Load Register Signed Halfword (register).
ARM-INSTRUCTION: LDRSH32 ( 01 111 0 00 11 1 Rm option3 S 10 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSH64 ( 01 111 0 00 10 1 Rm option3 S 10 Rn Rt -- instruction )

! LDRSW (immediate): Load Register Signed Word (immediate).
ARM-INSTRUCTION: LDRSWimmpost32 ( 10 111 0 00 10 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSWimmpre32  ( 10 111 0 00 10 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: LDRSWimmuoff64 ( 10 111 0 01 10 imm12 Rn Rt -- instruction )

! LDRSW (literal): Load Register Signed Word (literal).
ARM-INSTRUCTION: LDRSWl ( 10 011 0 00 imm19 Rt -- instruction )

! LDRSW (register): Load Register Signed Word (register).
ARM-INSTRUCTION: LDRSWr ( 10 111 0 00 10 1 Rm option3 S 10 Rn Rt -- instruction )

! LDSET, LDSETA, LDSETAL, LDSETL: Atomic bit set on word or doubleword in memory.
ARM-INSTRUCTION: LDSET32   ( 10 111 0 00 0 0 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETA32  ( 10 111 0 00 1 0 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETAL32 ( 10 111 0 00 1 1 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETL32  ( 10 111 0 00 0 1 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSET64   ( 11 111 0 00 0 0 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETA64  ( 11 111 0 00 1 0 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETAL64 ( 11 111 0 00 1 1 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETL64  ( 11 111 0 00 0 1 1 Rs 0 011 00 Rn Rt -- instruction )

! LDSETB, LDSETAB, LDSETALB, LDSETLB: Atomic bit set on byte in memory.
ARM-INSTRUCTION: LDSETAB  ( 00 111 0 00 1 0 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETALB ( 00 111 0 00 1 1 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETB   ( 00 111 0 00 0 0 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETLB  ( 00 111 0 00 0 1 1 Rs 0 011 00 Rn Rt -- instruction )

! LDSETH, LDSETAH, LDSETALH, LDSETLH: Atomic bit set on halfword in memory.
ARM-INSTRUCTION: LDSETAH  ( 01 111 0 00 1 0 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETALH ( 01 111 0 00 1 1 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETH   ( 01 111 0 00 0 0 1 Rs 0 011 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSETLH  ( 01 111 0 00 0 1 1 Rs 0 011 00 Rn Rt -- instruction )

! LDSMAX, LDSMAXA, LDSMAXAL, LDSMAXL: Atomic signed maximum on word or doubleword in memory.
ARM-INSTRUCTION: LDSMAX32   ( 10 111 0 00 0 0 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXA32  ( 10 111 0 00 1 0 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXAL32 ( 10 111 0 00 1 1 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXL32  ( 10 111 0 00 0 1 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAX64   ( 11 111 0 00 0 0 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXA64  ( 11 111 0 00 1 0 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXAL64 ( 11 111 0 00 1 1 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXL64  ( 11 111 0 00 0 1 1 Rs 0 100 00 Rn Rt -- instruction )

! LDSMAXB, LDSMAXAB, LDSMAXALB, LDSMAXLB: Atomic signed maximum on byte in memory.
ARM-INSTRUCTION: LDSMAXAB  ( 00 111 0 00 1 0 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXALB ( 00 111 0 00 1 1 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXB   ( 00 111 0 00 0 0 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXLB  ( 00 111 0 00 0 1 1 Rs 0 100 00 Rn Rt -- instruction )

! LDSMAXH, LDSMAXAH, LDSMAXALH, LDSMAXLH: Atomic signed maximum on halfword in memory.
ARM-INSTRUCTION: LDSMAXAH  ( 00 111 0 00 1 0 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXALH ( 00 111 0 00 1 1 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXH   ( 00 111 0 00 0 0 1 Rs 0 100 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMAXLH  ( 00 111 0 00 0 1 1 Rs 0 100 00 Rn Rt -- instruction )

! LDSMIN, LDSMINA, LDSMINAL, LDSMINL: Atomic signed minimum on word or doubleword in memory.
ARM-INSTRUCTION: LDSMIN32   ( 10 111 0 00 0 0 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINA32  ( 10 111 0 00 1 0 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINAL32 ( 10 111 0 00 1 1 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINL32  ( 10 111 0 00 0 1 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMIN64   ( 11 111 0 00 0 0 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINA64  ( 11 111 0 00 1 0 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINAL64 ( 11 111 0 00 1 1 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINL64  ( 11 111 0 00 0 1 1 Rs 0 101 00 Rn Rt -- instruction )

! LDSMINB, LDSMINAB, LDSMINALB, LDSMINLB: Atomic signed minimum on byte in memory.
! ARMv8.1
ARM-INSTRUCTION: LDSMINAB  ( 00 111 0 00 1 0 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINALB ( 00 111 0 00 1 1 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINB   ( 00 111 0 00 0 0 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINLB  ( 00 111 0 00 0 1 1 Rs 0 101 00 Rn Rt -- instruction )

! LDSMINH, LDSMINAH, LDSMINALH, LDSMINLH: Atomic signed minimum on halfword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDSMINAH  ( 01 111 0 00 1 0 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINALH ( 01 111 0 00 1 1 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINH   ( 01 111 0 00 0 0 1 Rs 0 101 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDSMINLH  ( 01 111 0 00 0 1 1 Rs 0 101 00 Rn Rt -- instruction )

! LDTR: Load Register (unprivileged).
ARM-INSTRUCTION: LDTR32 ( 10 111 0 00 01 0 imm9 10 Rn Rt -- instruction )
ARM-INSTRUCTION: LDTR64 ( 11 111 0 00 01 0 imm9 10 Rn Rt -- instruction )

! LDTRB: Load Register Byte (unprivileged).
ARM-INSTRUCTION: LDTRB ( 00 111 0 00 01 0 imm9 10 Rn Rt -- instruction )

! LDTRH: Load Register Halfword (unprivileged).
ARM-INSTRUCTION: LDTRH ( 01 111 0 00 01 0 imm9 10 Rn Rt -- instruction )

! LDTRSB: Load Register Signed Byte (unprivileged).
ARM-INSTRUCTION: LDTRSB32 ( 00 111 0 00 11 0 imm9 10 Rn Rt -- instruction )
ARM-INSTRUCTION: LDTRSB64 ( 00 111 0 00 10 0 imm9 10 Rn Rt -- instruction )

! LDTRSH: Load Register Signed Halfword (unprivileged).
ARM-INSTRUCTION: LDTRSH32 ( 01 111 0 00 11 0 imm9 10 Rn Rt -- instruction )
ARM-INSTRUCTION: LDTRSH64 ( 01 111 0 00 10 0 imm9 10 Rn Rt -- instruction )

! LDTRSW: Load Register Signed Word (unprivileged).
ARM-INSTRUCTION: LDTRSW ( 10 111 0 00 10 0 imm9 10 Rn Rt -- instruction )

! LDUMAX, LDUMAXA, LDUMAXAL, LDUMAXL: Atomic unsigned maximum on word or doubleword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMAX32   ( 10 111 0 00 0 0 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXA32  ( 10 111 0 00 1 0 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXAL32 ( 10 111 0 00 1 1 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXL32  ( 10 111 0 00 0 1 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAX64   ( 11 111 0 00 0 0 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXA64  ( 11 111 0 00 1 0 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXAL64 ( 11 111 0 00 1 1 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXL64  ( 11 111 0 00 0 1 1 Rs 0 110 00 Rn Rt -- instruction )

! LDUMAXB, LDUMAXAB, LDUMAXALB, LDUMAXLB: Atomic unsigned maximum on byte in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMAXAB  ( 00 111 0 00 1 0 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXALB ( 00 111 0 00 1 1 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXB   ( 00 111 0 00 0 0 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXLB  ( 00 111 0 00 0 1 1 Rs 0 110 00 Rn Rt -- instruction )

! LDUMAXH, LDUMAXAH, LDUMAXALH, LDUMAXLH: Atomic unsigned maximum on halfword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMAXAH  ( 01 111 0 00 1 0 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXALH ( 01 111 0 00 1 1 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXH   ( 01 111 0 00 0 0 1 Rs 0 110 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMAXLH  ( 01 111 0 00 0 1 1 Rs 0 110 00 Rn Rt -- instruction )

! LDUMIN, LDUMINA, LDUMINAL, LDUMINL: Atomic unsigned minimum on word or doubleword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMIN32   ( 10 111 0 00 0 0 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINA32  ( 10 111 0 00 1 0 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINAL32 ( 10 111 0 00 1 1 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINL32  ( 10 111 0 00 0 1 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMIN64   ( 11 111 0 00 0 0 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINA64  ( 11 111 0 00 1 0 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINAL64 ( 11 111 0 00 1 1 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINL64  ( 11 111 0 00 0 1 1 Rs 0 111 00 Rn Rt -- instruction )

! LDUMINB, LDUMINAB, LDUMINALB, LDUMINLB: Atomic unsigned minimum on byte in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMINAB  ( 00 111 0 00 1 0 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINALB ( 00 111 0 00 1 1 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINB   ( 00 111 0 00 0 0 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINLB  ( 00 111 0 00 0 1 1 Rs 0 111 00 Rn Rt -- instruction )

! LDUMINH, LDUMINAH, LDUMINALH, LDUMINLH: Atomic unsigned minimum on halfword in memory.
! ARMv8.1
ARM-INSTRUCTION: LDUMINAH  ( 01 111 0 00 1 0 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINALH ( 01 111 0 00 1 1 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINH   ( 01 111 0 00 0 0 1 Rs 0 111 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUMINLH  ( 01 111 0 00 0 1 1 Rs 0 111 00 Rn Rt -- instruction )

! LDUR: Load Register (unscaled).
ARM-INSTRUCTION: LDUR32 ( 10 111 0 00 01 0 imm9 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDUR64 ( 11 111 0 00 01 0 imm9 00 Rn Rt -- instruction )

! LDURB: Load Register Byte (unscaled).
ARM-INSTRUCTION: LDURB ( 00 111 0 00 01 0 imm9 00 Rn Rt -- instruction )

! LDURH: Load Register Halfword (unscaled).
ARM-INSTRUCTION: LDURH ( 01 111 0 00 01 0 imm9 00 Rn Rt -- instruction )

! LDURSB: Load Register Signed Byte (unscaled).
ARM-INSTRUCTION: LDURSB32 ( 00 111 0 00 10 0 imm9 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDURSB64 ( 00 111 0 00 11 0 imm9 00 Rn Rt -- instruction )

! LDURSH: Load Register Signed Halfword (unscaled).
ARM-INSTRUCTION: LDURSH32 ( 01 111 0 00 10 0 imm9 00 Rn Rt -- instruction )
ARM-INSTRUCTION: LDURSH64 ( 01 111 0 00 11 0 imm9 00 Rn Rt -- instruction )

! LDURSW: Load Register Signed Word (unscaled).
ARM-INSTRUCTION: LDURSW ( 10 111 0 00 10 0 imm9 00 Rn Rt -- instruction )

! LDXP: Load Exclusive Pair of Registers.
ARM-INSTRUCTION: LDXP32 ( 1 0 001000 0 1 1 11111 0 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: LDXP64 ( 1 1 001000 0 1 1 11111 0 Rt2 Rn Rt -- instruction )

! LDXR: Load Exclusive Register.
ARM-INSTRUCTION: LDXR32 ( 10 001000 0 1 0 11111 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: LDXR64 ( 11 001000 0 1 0 11111 0 11111 Rn Rt -- instruction )

! LDXRB: Load Exclusive Register Byte.
ARM-INSTRUCTION: LDXRB ( 00 001000 0 1 0 11111 0 11111 Rn Rt -- instruction )

! LDXRH: Load Exclusive Register Halfword.
ARM-INSTRUCTION: LDXRH ( 01 001000 0 1 0 11111 0 11111 Rn Rt -- instruction )

! LSL (immediate): Logical Shift Left (immediate): an alias of UBFM.
ARM-INSTRUCTION: LSLi32 ( 0 10 100110 0 immrimms Rn Rd -- instruction )
ARM-INSTRUCTION: LSLi64 ( 1 10 100110 1 immrimms Rn Rd -- instruction )

! LSL (register): Logical Shift Left (register): an alias of LSLV.
ARM-INSTRUCTION: LSLr32 ( 0 0 0 11010110 Rm 0010 00 Rn Rd -- instruction )
ARM-INSTRUCTION: LSLr64 ( 1 0 0 11010110 Rm 0010 00 Rn Rd -- instruction )

! LSLV: Logical Shift Left Variable.
ARM-INSTRUCTION: LSLV32 ( 0 0 0 11010110 Rm 0010 00 Rn Rd -- instruction )
ARM-INSTRUCTION: LSLV64 ( 1 0 0 11010110 Rm 0010 00 Rn Rd -- instruction )

! LSR (immediate): Logical Shift Right (immediate): an alias of UBFM.
ARM-INSTRUCTION: LSRi32 ( 0 10 100110 0 immr 011111 Rn Rd -- instruction )
ARM-INSTRUCTION: LSRi64 ( 1 10 100110 1 immr 111111 Rn Rd -- instruction )

! LSR (register): Logical Shift Right (register): an alias of LSRV.
ARM-INSTRUCTION: LSRr32 ( 0 0 0 11010110 Rm 0010 01 Rn Rd -- instruction )
ARM-INSTRUCTION: LSRr64 ( 1 0 0 11010110 Rm 0010 01 Rn Rd -- instruction )

! LSRV: Logical Shift Right Variable.
ARM-INSTRUCTION: LSRV32 ( 0 0 0 11010110 Rm 0010 01 Rn Rd -- instruction )
ARM-INSTRUCTION: LSRV64 ( 1 0 0 11010110 Rm 0010 01 Rn Rd -- instruction )

! MADD: Multiply-Add.
ARM-INSTRUCTION: MADD32 ( 0 00 11011 000 Rm 0 Ra Rn Rd -- instruction )
ARM-INSTRUCTION: MADD64 ( 1 00 11011 000 Rm 0 Ra Rn Rd -- instruction )

! MNEG: Multiply-Negate: an alias of MSUB.
ARM-INSTRUCTION: MNEG32 ( 0 00 11011 000 Rm 1 11111 Rn Rd -- instruction )
ARM-INSTRUCTION: MNEG64 ( 1 00 11011 000 Rm 1 11111 Rn Rd -- instruction )

! MOV (bitmask immediate): Move (bitmask immediate): an alias of ORR (immediate).
ARM-INSTRUCTION: MOVbi32 ( 0 01 100100 0 immr imms 11111 Rn -- instruction )
ARM-INSTRUCTION: MOVbi64 ( 1 01 100100 Nimmrimms 11111 Rn -- instruction )

! MOV (inverted wide immediate): Move (inverted wide immediate): an alias of MOVN.
ARM-INSTRUCTION: MOViwi32 ( 0 00 100101 hw2 imm16 Rd -- instruction )
ARM-INSTRUCTION: MOViwi64 ( 1 00 100101 hw2 imm16 Rd -- instruction )

! MOV (register): Move (register): an alias of ORR (shifted register).
ARM-INSTRUCTION: MOVr32 ( 0 01 01010 00 0 Rm 000000 11111 Rd -- instruction )
ARM-INSTRUCTION: MOVr64 ( 1 01 01010 00 0 Rm 000000 11111 Rd -- instruction )

! MOV (to/from SP): Move between register and stack pointer: an alias of ADD (immediate).
ARM-INSTRUCTION: MOVsp32 ( 0 0 0 10001 shift2 000000000000 Rn Rd -- instruction )
ARM-INSTRUCTION: MOVsp64 ( 1 0 0 10001 shift2 000000000000 Rn Rd -- instruction )

! MOV (wide immediate): Move (wide immediate): an alias of MOVZ.
ARM-INSTRUCTION: MOVwi32 ( 0 10 100101 hw2 imm16 Rd -- instruction )
ARM-INSTRUCTION: MOVwi64 ( 1 10 100101 hw2 imm16 Rd -- instruction )

! MOVK: Move wide with keep.
ARM-INSTRUCTION: MOVK32 ( 0 11 100101 hw2 imm16 Rd -- instruction )
ARM-INSTRUCTION: MOVK64 ( 1 11 100101 hw2 imm16 Rd -- instruction )

! MOVN: Move wide with NOT.
ARM-INSTRUCTION: MOVN32 ( 0 00 100101 hw2 imm16 Rd -- instruction )
ARM-INSTRUCTION: MOVN64 ( 1 00 100101 hw2 imm16 Rd -- instruction )

! MOVZ: Move wide with zero.
ARM-INSTRUCTION: MOVZ32 ( 0 10 100101 hw2 imm16 Rd -- instruction )
ARM-INSTRUCTION: MOVZ64 ( 1 10 100101 hw2 imm16 Rd -- instruction )

! MRS: Move System Register.
! System register name, encoded in the "o0:op1:CRn:CRm:op2"
ARM-INSTRUCTION: MRS ( 1101010100 1 1 o0 op3 CRn CRm op3 Rt -- instruction )

! MSR (immediate): Move immediate value to Special Register.
ARM-INSTRUCTION: MRSi ( 1101010100 0 00 op3 0100 CRm op3 11111 -- instruction )

! MSR (register): Move general-purpose register to System Register.
ARM-INSTRUCTION: MRSr ( 1101010100 0 1 o0 op3 CRn CRm op3 Rt -- instruction )

! MSUB: Multiply-Subtract.
ARM-INSTRUCTION: MSUB32 ( 0 00 11011 000 Rm 1 Ra Rn Rd -- instruction )
ARM-INSTRUCTION: MSUB64 ( 1 00 11011 000 Rm 1 Ra Rn Rd -- instruction )

! MUL: Multiply: an alias of MADD.
ARM-INSTRUCTION: MUL32 ( 0 00 11011 000 Rm 0 11111 Rn Rd -- instruction )
ARM-INSTRUCTION: MUL64 ( 1 00 11011 000 Rm 0 11111 Rn Rd -- instruction )

! MVN: Bitwise NOT: an alias of ORN (shifted register).
ARM-INSTRUCTION: MVN32 ( 0 0 1 01010 shift2 1 Rm imm6 11111 Rd -- instruction )
ARM-INSTRUCTION: MVN64 ( 1 0 1 01010 shift2 1 Rm imm6 11111 Rd -- instruction )

! NEG (shifted register): Negate (shifted register): an alias of SUB (shifted register).
ARM-INSTRUCTION: NEGsr32 ( 0 1 0 01011 shift2 0 Rm imm6 11111 Rd -- instruction )
ARM-INSTRUCTION: NEGsr64 ( 1 1 0 01011 shift2 0 Rm imm6 11111 Rd -- instruction )

! NEGS: Negate, setting flags: an alias of SUBS (shifted register).
ARM-INSTRUCTION: NEGS32 ( 0 1 1 01011 shift2 0 Rm imm6 11111 Rd -- instruction )
ARM-INSTRUCTION: NEGS64 ( 1 1 1 01011 shift2 0 Rm imm6 11111 Rd -- instruction )

! NGC: Negate with Carry: an alias of SBC.
ARM-INSTRUCTION: NGC32 ( 0 1 0 11010000 Rm 000000 11111 Rd -- instruction )
ARM-INSTRUCTION: NGC64 ( 1 1 0 11010000 Rm 000000 11111 Rd -- instruction )

! NGCS: Negate with Carry, setting flags: an alias of SBCS.
ARM-INSTRUCTION: NGCS32 ( 0 1 1 11010000 Rm 000000 11111 Rd -- instruction )
ARM-INSTRUCTION: NGCS64 ( 1 1 1 11010000 Rm 000000 11111 Rd -- instruction )

! NOP: No Operation.
ARM-INSTRUCTION: NOP ( 1101010100 0 00 011 0010 0000 000 11111 -- instruction )

! ORN (shifted register): Bitwise OR NOT (shifted register).
ARM-INSTRUCTION: ORNsr32 ( 0 01 01010 shift2 1 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: ORNsr64 ( 1 01 01010 shift2 1 Rm imm6 Rn Rd -- instruction )

! ORR (immediate): Bitwise OR (immediate).
ARM-INSTRUCTION: ORR32 ( 0 01 100100 0 immrimms Rn Rd -- instruction )
ARM-INSTRUCTION: ORR64 ( 1 01 100100 Nimmrimms Rn Rd -- instruction )

! ORR (shifted register): Bitwise OR (shifted register).
ARM-INSTRUCTION: ORRsr32 ( 0 01 01010 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: ORRsr64 ( 1 01 01010 shift2 0 Rm imm6 Rn Rd -- instruction )

! PACDA, PACDZA: Pointer Authentication Code for Data address, using key A.
! ARMv8.3
ARM-INSTRUCTION: PACDA  ( 1 1 0 11010110 00001 0 0 0 010 Rn Rd -- instruction )
ARM-INSTRUCTION: PACDZA ( 1 1 0 11010110 00001 0 0 1 010 11111 Rd -- instruction )

! PACDB, PACDZB: Pointer Authentication Code for Data address, using key B.
! ARMv8.3
ARM-INSTRUCTION: PACDB  ( 1 1 0 11010110 00001 0 0 0 011 Rn Rd -- instruction )
ARM-INSTRUCTION: PACDZB ( 1 1 0 11010110 00001 0 0 1 011 11111 Rd -- instruction )

! PACGA: Pointer Authentication Code, using Generic key.
! ARMv8.3
ARM-INSTRUCTION: PACGA ( 1 0 0 11010110 Rm 001100 Rn Rd -- instruction )

! PACIA, PACIA1716, PACIASP, PACIAZ, PACIZA: Pointer Authentication Code for Instruction address, using key A.
! ARMv8.3
ARM-INSTRUCTION: PACIA  ( 1 1 0 11010110 00001 0 0 0 000 Rn Rd -- instruction )
ARM-INSTRUCTION: PACIZA ( 1 1 0 11010110 00001 0 0 1 000 Rn Rd -- instruction )
! ARMv8.3
ARM-INSTRUCTION: PACIA1716 ( 1101010100 0 00 011 0010 0001 000 11111 -- instruction )
ARM-INSTRUCTION: PACIASP   ( 1101010100 0 00 011 0010 0011 001 11111 -- instruction )
ARM-INSTRUCTION: PACIAZ    ( 1101010100 0 00 011 0010 0011 000 11111 -- instruction )


! PACIB, PACIB1716, PACIBSP, PACIBZ, PACIZB: Pointer Authentication Code for Instruction address, using key B.
! ARMv8.3
ARM-INSTRUCTION: PACIB  ( 1 1 0 11010110 00001 0 0 0 001 Rn Rd -- instruction )
ARM-INSTRUCTION: PACIZB ( 1 1 0 11010110 00001 0 0 1 001 Rn Rd -- instruction )
! ARMv8.3
ARM-INSTRUCTION: PACIB1716 ( 1101010100 0 00 011 0010 0001 010 11111 -- instruction )
ARM-INSTRUCTION: PACIBSP   ( 1101010100 0 00 011 0010 0011 011 11111 -- instruction )
ARM-INSTRUCTION: PACIBZ    ( 1101010100 0 00 011 0010 0011 010 11111 -- instruction )

! PRFM (immediate): Prefetch Memory (immediate).
ARM-INSTRUCTION: PRFMi ( 11 111 0 01 10 imm12 Rn Rt -- instruction )

! PRFM (literal): Prefetch Memory (literal).
ARM-INSTRUCTION: PRFMl ( 11 011 0 00 imm19 Rt -- instruction )

! PRFM (register): Prefetch Memory (register).
ARM-INSTRUCTION: PRFMr ( 11 111 0 00 10 1 Rm option3 S 10 Rn Rt -- instruction )

! PRFM (unscaled offset): Prefetch Memory (unscaled offset).
ARM-INSTRUCTION: PRFMunscoff ( 11 111 0 00 10 0 imm9 00 Rn Rt -- instruction )

! PSB CSYNC: Profiling Synchronization Barrier.
! ARMv8.2
ARM-INSTRUCTION: PSB-CSYNC ( 1101010100 0 00 011 0010 0010 001 11111 -- instruction )

! PSSBB: Physical Speculative Store Bypass Barrier.
ARM-INSTRUCTION: PSSBB ( 1101010100 0 00 011 0011 0100 1 00 11111 -- instruction )

! RBIT: Reverse Bits.
ARM-INSTRUCTION: RBIT32 ( 0 1 0 11010110 00000 0000 00 Rn Rd -- instruction )
ARM-INSTRUCTION: RBIT64 ( 1 1 0 11010110 00000 0000 00 Rn Rd -- instruction )

! RET: Return from subroutine.
ARM-INSTRUCTION: RET ( 1101011 0 0 10 11111 0000 0 0 Rn 00000 -- instruction )

! RETAA, RETAB: Return from subroutine, with pointer authentication.
! ARMv8.3
ARM-INSTRUCTION: RETAA ( 1101011 0 0 10 11111 0000 1 0 11111 11111 -- instruction )
ARM-INSTRUCTION: RETAB ( 1101011 0 0 10 11111 0000 1 1 11111 11111 -- instruction )

! REV: Reverse Bytes.
ARM-INSTRUCTION: REVb32 ( 0 1 0 11010110 00000 0000 10 Rn Rd -- instruction )
ARM-INSTRUCTION: REVb64 ( 1 1 0 11010110 00000 0000 11 Rn Rd -- instruction )

! REV16: Reverse bytes in 16-bit halfwords.
ARM-INSTRUCTION: REV16_32 ( 0 1 0 11010110 00000 0000 01 Rn Rd -- instruction )
ARM-INSTRUCTION: REV16_64 ( 1 1 0 11010110 00000 0000 01 Rn Rd -- instruction )

! REV32: Reverse bytes in 32-bit words.
ARM-INSTRUCTION: REV32 ( 1 1 0 11010110 00000 0000 10 Rn Rd -- instruction )

! REV64: Reverse Bytes: an alias of REV.
ARM-INSTRUCTION: REV64 ( 0 Q 0 01110 size2 10000 0000 0 10 Rn Rd -- instruction )

! RMIF: Rotate, Mask Insert Flags.
! ARMv8.4
ARM-INSTRUCTION: RMIF ( 1 0 1 11010000 imm6 00001 Rn 0 mask4 -- instruction )

! ROR (immediate): Rotate right (immediate): an alias of EXTR.
ARM-INSTRUCTION: RORi32 ( 0 00 100111 0 0 Rm 0 imm5 Rn Rd -- instruction )
ARM-INSTRUCTION: RORi64 ( 1 00 100111 1 0 Rm imms Rn Rd -- instruction )

! ROR (register): Rotate Right (register): an alias of RORV.
ARM-INSTRUCTION: RORr32 ( 0 0 0 11010110 Rm 0010 11 Rn Rd -- instruction )
ARM-INSTRUCTION: RORr64 ( 1 0 0 11010110 Rm 0010 11 Rn Rd -- instruction )

! RORV: Rotate Right Variable.
ARM-INSTRUCTION: RORV32 ( 0 0 0 11010110 Rm 0010 11 Rn Rd -- instruction )
ARM-INSTRUCTION: RORV64 ( 1 0 0 11010110 Rm 0010 11 Rn Rd -- instruction )

! SB: Speculation Barrier.
ARM-INSTRUCTION: SB ( 1101010100 0 00 011 0011 0000 1 11 11111 -- instruction )

! SBC: Subtract with Carry.
ARM-INSTRUCTION: SBC32 ( 0 1 0 11010000 Rm 000000 Rn Rd -- instruction )
ARM-INSTRUCTION: SBC64 ( 1 1 0 11010000 Rm 000000 Rn Rd -- instruction )

! SBCS: Subtract with Carry, setting flags.
ARM-INSTRUCTION: SBCS32 ( 0 1 1 11010000 Rm 000000 Rn Rd -- instruction )
ARM-INSTRUCTION: SBCS64 ( 1 1 1 11010000 Rm 000000 Rn Rd -- instruction )

! SBFIZ: Signed Bitfield Insert in Zero: an alias of SBFM.
ARM-INSTRUCTION: SBFIZ32 ( 0 00 100110 0 immr imms Rn Rd -- instruction )
ARM-INSTRUCTION: SBFIZ64 ( 1 00 100110 1 immr imms Rn Rd -- instruction )

! SBFM: Signed Bitfield Move.
ARM-INSTRUCTION: SBFM32 ( 0 00 100110 0 immr imms Rn Rd -- instruction )
ARM-INSTRUCTION: SBFM64 ( 1 00 100110 1 immr imms Rn Rd -- instruction )

! SBFX: Signed Bitfield Extract: an alias of SBFM.
ARM-INSTRUCTION: SBFX32 ( 0 00 100110 0 immr imms Rn Rd -- instruction )
ARM-INSTRUCTION: SBFX64 ( 1 00 100110 1 immr imms Rn Rd -- instruction )

! SDIV: Signed Divide.
ARM-INSTRUCTION: SDIV32 ( 0 0 0 11010110 Rm 00001 1 Rn Rd -- instruction )
ARM-INSTRUCTION: SDIV64 ( 1 0 0 11010110 Rm 00001 1 Rn Rd -- instruction )

! SETF8, SETF16: Evaluation of 8 or 16 bit flag values.
! ARMv8.4
ARM-INSTRUCTION: SETF8  ( 0 0 1 11010000 000000 0 0010 Rn 0 1101 -- instruction )
ARM-INSTRUCTION: SETF16 ( 0 0 1 11010000 000000 1 0010 Rn 0 1101 -- instruction )

! SEV: Send Event.
ARM-INSTRUCTION: SEV  ( 1101010100 0 00 011 0010 0000 100 11111 -- instruction )

! SEVL: Send Event Local.
ARM-INSTRUCTION: SEVL ( 1101010100 0 00 011 0010 0000 101 11111 -- instruction )

! SMADDL: Signed Multiply-Add Long.
ARM-INSTRUCTION: SMADDL ( 1 00 11011 0 01 Rm 0 Ra Rn Rd -- instruction )

! SMC: Secure Monitor Call.
ARM-INSTRUCTION: SMC ( 11010100 000 imm16 000 11 -- instruction )

! SMNEGL: Signed Multiply-Negate Long: an alias of SMSUBL.
ARM-INSTRUCTION: SMNEGL ( 1 00 11011 0 01 Rm 1 11111 Rn Rd -- instruction )

! SMSUBL: Signed Multiply-Subtract Long.
ARM-INSTRUCTION: SMSUBL ( 1 00 11011 0 01 Rm 1 Ra Rn Rd -- instruction )

! SMULH: Signed Multiply High.
ARM-INSTRUCTION: SMULH ( 1 00 11011 0 10 Rm 0 11111 Rn Rd -- instruction )

! SMULL: Signed Multiply Long: an alias of SMADDL.
ARM-INSTRUCTION: SMULL ( 1 00 11011 0 01 Rm 0 11111 Rn Rd -- instruction )

! SSBB: Speculative Store Bypass Barrier.
ARM-INSTRUCTION: SSBB ( 1101010100 0 00 011 0011 0000 1 00 11111 -- instruction )

! ST2G: Store Allocation Tags.
! ARMv8.5
ARM-INSTRUCTION: ST2Gpost ( 11011001 1 0 1 imm9 0 1 Xn 11111 -- instruction )
ARM-INSTRUCTION: ST2Gpre  ( 11011001 1 0 1 imm9 1 1 Xn 11111 -- instruction )
ARM-INSTRUCTION: ST2Gsoff ( 11011001 1 0 1 imm9 1 0 Xn 11111 -- instruction )

! STADD, STADDL: Atomic add on word or doubleword in memory, without return: an alias of LDADD, LDADDA, LDADDAL, LDADDL.
ARM-INSTRUCTION: STADD32  ( 10 111 0 00 0 0 1 Rs 0 000 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STADDL32 ( 10 111 0 00 0 1 1 Rs 0 000 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STADD64  ( 11 111 0 00 0 0 1 Rs 0 000 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STADDL64 ( 11 111 0 00 0 1 1 Rs 0 000 00 Rn 11111 -- instruction )

! STADDB, STADDLB: Atomic add on byte in memory, without return: an alias of LDADDB, LDADDAB, LDADDALB, LDADDLB.
! ARMv8.1
ARM-INSTRUCTION: STADDB  ( 00 111 0 00 0 0 1 Rs 0 000 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STADDLB ( 00 111 0 00 0 1 1 Rs 0 000 00 Rn 11111 -- instruction )

! STADDH, STADDLH: Atomic add on halfword in memory, without return: an alias of LDADDH, LDADDAH, LDADDALH, LDADDLH.
ARM-INSTRUCTION: STADDH  ( 01 111 0 00 0 0 1 Rs 0 000 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STADDLH ( 01 111 0 00 0 1 1 Rs 0 000 00 Rn 11111 -- instruction )

! STCLR, STCLRL: Atomic bit clear on word or doubleword in memory, without return: an alias of LDCLR, LDCLRA, LDCLRAL, LDCLRL.
! ARMv8.1
ARM-INSTRUCTION: STCLR32  ( 10 111 0 00 0 0 1 Rs 0 001 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STCLR64  ( 10 111 0 00 0 1 1 Rs 0 001 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STCLRL32 ( 11 111 0 00 0 0 1 Rs 0 001 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STCLRL64 ( 11 111 0 00 0 1 1 Rs 0 001 00 Rn 11111 -- instruction )

! STCLRB, STCLRLB: Atomic bit clear on byte in memory, without return: an alias of LDCLRB, LDCLRAB, LDCLRALB, LDCLRLB.
! ARMv8.1
ARM-INSTRUCTION: STCLRB   ( 00 111 0 00 0 0 1 Rs 0 001 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STCLRLB  ( 00 111 0 00 0 1 1 Rs 0 001 00 Rn 11111 -- instruction )

! STCLRH, STCLRLH: Atomic bit clear on halfword in memory, without return: an alias of LDCLRH, LDCLRAH, LDCLRALH, LDCLRLH.
! ARMv8.1
ARM-INSTRUCTION: STCLRH  ( 01 111 0 00 0 0 1 Rs 0 001 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STCLRLH ( 01 111 0 00 0 1 1 Rs 0 001 00 Rn 11111 -- instruction )

! STEOR, STEORL: Atomic exclusive OR on word or doubleword in memory, without return: an alias of LDEOR, LDEORA, LDEORAL, LDEORL.
! ARMv8.1
ARM-INSTRUCTION: STEOR32  ( 10 111 0 00 0 0 1 Rs 0 010 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STEORL32 ( 10 111 0 00 0 1 1 Rs 0 010 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STEOR64  ( 11 111 0 00 0 0 1 Rs 0 010 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STEORL64 ( 11 111 0 00 0 1 1 Rs 0 010 00 Rn 11111 -- instruction )

! STEORB, STEORLB: Atomic exclusive OR on byte in memory, without return: an alias of LDEORB, LDEORAB, LDEORALB, LDEORLB.
! ARMv8.1
ARM-INSTRUCTION: STEORB  ( 00 111 0 00 0 0 1 Rs 0 010 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STEORLB ( 00 111 0 00 0 1 1 Rs 0 010 00 Rn 11111 -- instruction )

! STEORH, STEORLH: Atomic exclusive OR on halfword in memory, without return: an alias of LDEORH, LDEORAH, LDEORALH, LDEORLH.
! ARMv8.1
ARM-INSTRUCTION: STEORH  ( 01 111 0 00 0 0 1 Rs 0 010 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STEORLH ( 01 111 0 00 0 1 1 Rs 0 010 00 Rn 11111 -- instruction )

! STG: Store Allocation Tag.
! ARMv8.5
ARM-INSTRUCTION: STGpost ( 11011001 0 0 1 imm9 0 1 Xn 11111 -- instruction )
ARM-INSTRUCTION: STGpre  ( 11011001 0 0 1 imm9 1 1 Xn 11111 -- instruction )
ARM-INSTRUCTION: STGsoff ( 11011001 0 0 1 imm9 1 0 Xn 11111 -- instruction )

! STGP: Store Allocation Tag and Pair of registers.
! ARMv8.5
ARM-INSTRUCTION: STGPpost ( 0 1 101 0 001 0 simm7 Xt2 Xn Xt -- instruction )
ARM-INSTRUCTION: STGPpre  ( 0 1 101 0 011 0 simm7 Xt2 Xn Xt -- instruction )
ARM-INSTRUCTION: STGPsoff ( 0 1 101 0 010 0 simm7 Xt2 Xn Xt -- instruction )

! STGV: Store Tag Vector.
! ARMv8.5
ARM-INSTRUCTION: STGV ( 11011001 1 0 1 0 0 0 0 0 0 0 0 0 0 0 Xn Xt -- instruction )

! STLLR: Store LORelease Register.
! ARMv8.1
ARM-INSTRUCTION: STLLR32 ( 10 001000 1 0 0 11111 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: STLLR64 ( 11 001000 1 0 0 11111 0 11111 Rn Rt -- instruction )

! STLLRB: Store LORelease Register Byte.
! ARMv8.1
ARM-INSTRUCTION: STLLRB ( 00 001000 1 0 0 11111 0 11111 Rn Rt -- instruction )

! STLLRH: Store LORelease Register Halfword.
ARM-INSTRUCTION: STLLRH ( 01 001000 1 0 0 11111 0 11111 Rn Rt -- instruction )

! STLR: Store-Release Register.
ARM-INSTRUCTION: STLR32 ( 10 001000 1 0 0 11111 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: STLR64 ( 11 001000 1 0 0 11111 1 11111 Rn Rt -- instruction )

! STLRB: Store-Release Register Byte.
ARM-INSTRUCTION: STLRB ( 00 001000 1 0 0 11111 1 11111 Rn Rt -- instruction )

! STLRH: Store-Release Register Halfword.
ARM-INSTRUCTION: STLRH ( 01 001000 1 0 0 11111 1 11111 Rn Rt -- instruction )

! STLUR: Store-Release Register (unscaled).
ARM-INSTRUCTION: STLUR32 ( 10 011001 00 0 imm9 00 Rn Rt -- instruction )
ARM-INSTRUCTION: STLUR64 ( 11 011001 00 0 imm9 00 Rn Rt -- instruction )

! STLURB: Store-Release Register Byte (unscaled).
ARM-INSTRUCTION: STLURB ( 00 011001 00 0 imm9 00 Rn Rt -- instruction )

! STLURH: Store-Release Register Halfword (unscaled).
ARM-INSTRUCTION: STLURH ( 01 011001 00 0 imm9 00 Rn Rt -- instruction )

! STLXP: Store-Release Exclusive Pair of registers.
ARM-INSTRUCTION: STLXP32 ( 1 0 001000 0 0 1 Rs 1 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: STLXP64 ( 1 1 001000 0 0 1 Rs 1 Rt2 Rn Rt -- instruction )

! STLXR: Store-Release Exclusive Register.
ARM-INSTRUCTION: STLXR32 ( 10 001000 0 0 0 Rs 1 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: STLXR64 ( 11 001000 0 0 0 Rs 1 11111 Rn Rt -- instruction )

! STLXRB: Store-Release Exclusive Register Byte.
ARM-INSTRUCTION: STLXRB ( 00 001000 0 0 0 Rs 1 11111 Rn Rt -- instruction )

! STLXRH: Store-Release Exclusive Register Halfword.
ARM-INSTRUCTION: STLXRH ( 01 001000 0 0 0 Rs 1 11111 Rn Rt -- instruction )

! STNP: Store Pair of Registers, with non-temporal hint.
ARM-INSTRUCTION: STNP32 ( 00 101 0 000 0 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: STNP64 ( 10 101 0 000 0 imm7 Rt2 Rn Rt -- instruction )

! STP: Store Pair of Registers.
ARM-INSTRUCTION: STPpost32 ( 00 101 0 001 0 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: STPpost64 ( 10 101 0 001 0 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: STPpre32  ( 00 101 0 011 0 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: STPpre64  ( 10 101 0 011 0 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: STPsoff32 ( 00 101 0 010 0 imm7 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: STPsoff64 ( 10 101 0 010 0 imm7 Rt2 Rn Rt -- instruction )

! STR (immediate): Store Register (immediate).
ARM-INSTRUCTION: STRpost32 ( 00 111 0 00 00 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: STRpost64 ( 11 111 0 00 00 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: STRpre32  ( 00 111 0 00 00 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: STRpre64  ( 11 111 0 00 00 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: STRuoff32 ( 00 111 0 01 00 imm12 Rn Rt -- instruction )
ARM-INSTRUCTION: STRuoff64 ( 11 111 0 01 00 imm12 Rn Rt -- instruction )

! STR (register): Store Register (register).
ARM-INSTRUCTION: STRr32 ( 10 111 0 00 00 1 Rm option3 S 10 Rn Rt -- instruction )
ARM-INSTRUCTION: STRr64 ( 11 111 0 00 00 1 Rm option3 S 10 Rn Rt -- instruction )

! STRB (immediate): Store Register Byte (immediate).
ARM-INSTRUCTION: STRpost ( 00 111 0 00 00 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: STRpre  ( 00 111 0 00 00 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: STRuoff ( 00 111 0 01 00 imm12 Rn Rt -- instruction )

! STRB (register): Store Register Byte (register).
ARM-INSTRUCTION: STRBext   ( 00 111 0 00 00 1 Rm option3 S 10 Rn Rt -- instruction )
ARM-INSTRUCTION: STRBshift ( 00 111 0 00 00 1 Rm 011 S 10 Rn Rt -- instruction )

! STRH (immediate): Store Register Halfword (immediate).
ARM-INSTRUCTION: STRHpost ( 01 111 0 00 00 0 imm9 01 Rn Rt -- instruction )
ARM-INSTRUCTION: STRHpre  ( 01 111 0 00 00 0 imm9 11 Rn Rt -- instruction )
ARM-INSTRUCTION: STRHuoff ( 01 111 0 01 00 imm12 Rn Rt -- instruction )

! STRH (register): Store Register Halfword (register).
ARM-INSTRUCTION: STRH ( 01 111 0 00 00 1 Rm option3 S 10 Rn Rt -- instruction )

! STSET, STSETL: Atomic bit set on word or doubleword in memory, without return: an alias of LDSET, LDSETA, LDSETAL, LDSETL.
! ARMv8.1
ARM-INSTRUCTION: STSET32  ( 10 111 0 00 0 0 1 Rs 0 011 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSETL32 ( 10 111 0 00 0 1 1 Rs 0 011 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSET64  ( 11 111 0 00 0 0 1 Rs 0 011 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSETL64 ( 11 111 0 00 0 1 1 Rs 0 011 00 Rn 11111 -- instruction )

! STSETB, STSETLB: Atomic bit set on byte in memory, without return: an alias of LDSETB, LDSETAB, LDSETALB, LDSETLB.
! ARMv8.1
ARM-INSTRUCTION: STSETB  ( 00 111 0 00 0 0 1 Rs 0 011 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSETLB ( 00 111 0 00 0 1 1 Rs 0 011 00 Rn 11111 -- instruction )

! STSETH, STSETLH: Atomic bit set on halfword in memory, without return: an alias of LDSETH, LDSETAH, LDSETALH, LDSETLH.
! ARMv8.1
ARM-INSTRUCTION: STSETH  ( 01 111 0 00 0 0 1 Rs 0 011 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSETLH ( 01 111 0 00 0 1 1 Rs 0 011 00 Rn 11111 -- instruction )

! STSMAX, STSMAXL: Atomic signed maximum on word or doubleword in memory, without return: an alias of LDSMAX, LDSMAXA, LDSMAXAL, LDSMAXL.
! ARMv8.1
ARM-INSTRUCTION: STSMAX32  ( 10 111 0 00 0 0 1 Rs 0 100 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMAXL32 ( 10 111 0 00 0 1 1 Rs 0 100 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMAX64  ( 11 111 0 00 0 0 1 Rs 0 100 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMAXL64 ( 11 111 0 00 0 1 1 Rs 0 100 00 Rn 11111 -- instruction )

! STSMAXB, STSMAXLB: Atomic signed maximum on byte in memory, without return: an alias of LDSMAXB, LDSMAXAB, LDSMAXALB, LDSMAXLB.
! ARMv8.1
ARM-INSTRUCTION: STSMAXB  ( 00 111 0 00 0 0 1 Rs 0 100 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMAXLB ( 00 111 0 00 0 1 1 Rs 0 100 00 Rn 11111 -- instruction )

! STSMAXH, STSMAXLH: Atomic signed maximum on halfword in memory, without return: an alias of LDSMAXH, LDSMAXAH, LDSMAXALH, LDSMAXLH
! ARMv8.1
ARM-INSTRUCTION: STSMAXH  ( 01 111 0 00 0 0 1 Rs 0 100 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMAXLH ( 01 111 0 00 0 1 1 Rs 0 100 00 Rn 11111 -- instruction )

! STSMIN, STSMINL: Atomic signed minimum on word or doubleword in memory, without return: an alias of LDSMIN, LDSMINA, LDSMINAL, LDSMINL.
! ARMv8.1
ARM-INSTRUCTION: STSMIN32  ( 10 111 0 00 0 0 1 Rs 0 101 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMINL32 ( 10 111 0 00 0 0 1 Rs 0 101 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMIN64  ( 11 111 0 00 0 1 1 Rs 0 101 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMINL64 ( 11 111 0 00 0 1 1 Rs 0 101 00 Rn 11111 -- instruction )

! STSMINB, STSMINLB: Atomic signed minimum on byte in memory, without return: an alias of LDSMINB, LDSMINAB, LDSMINALB, LDSMINLB.
ARM-INSTRUCTION: STSMINB  ( 00 111 0 00 0 0 1 Rs 0 101 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMINLB ( 00 111 0 00 0 1 1 Rs 0 101 00 Rn 11111 -- instruction )

! STSMINH, STSMINLH: Atomic signed minimum on halfword in memory, without return: an alias of LDSMINH, LDSMINAH, LDSMINALH, LDSMINLH.
ARM-INSTRUCTION: STSMINH  ( 01 111 0 00 0 0 1 Rs 0 101 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STSMINLH ( 01 111 0 00 0 1 1 Rs 0 101 00 Rn 11111 -- instruction )

! STTR: Store Register (unprivileged).
ARM-INSTRUCTION: STTR32 ( 10 111 0 00 00 0 imm9 10 Rn Rt -- instruction )
ARM-INSTRUCTION: STTR64 ( 11 111 0 00 00 0 imm9 10 Rn Rt -- instruction )

! STTRB: Store Register Byte (unprivileged).
ARM-INSTRUCTION: STTRB ( 00 111 0 00 00 0 imm9 10 Rn Rt -- instruction )

! STTRH: Store Register Halfword (unprivileged).
ARM-INSTRUCTION: STTRH ( 01 111 0 00 00 0 imm9 10 Rn Rt -- instruction )

! STUMAX, STUMAXL: Atomic unsigned maximum on word or doubleword in memory, without return: an alias of LDUMAX, LDUMAXA, LDUMAXAL, LDUMAXL.
! ARMv8.1
ARM-INSTRUCTION: STUMAX32  ( 10 111 0 00 0 0 1 Rs 0 110 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMAXL32 ( 10 111 0 00 0 1 1 Rs 0 110 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMAX64  ( 11 111 0 00 0 0 1 Rs 0 110 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMAXL64 ( 11 111 0 00 0 1 1 Rs 0 110 00 Rn 11111 -- instruction )

! STUMAXB, STUMAXLB: Atomic unsigned maximum on byte in memory, without return: an alias of LDUMAXB, LDUMAXAB, LDUMAXALB, LDUMAXLB.
ARM-INSTRUCTION: STUMAXB  ( 00 111 0 00 0 0 1 Rs 0 110 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMAXLB ( 00 111 0 00 0 1 1 Rs 0 110 00 Rn 11111 -- instruction )

! STUMAXH, STUMAXLH: Atomic unsigned maximum on halfword in memory, without return: an alias of LDUMAXH, LDUMAXAH, LDUMAXALH, LDUMAXLH.
ARM-INSTRUCTION: STUMAXH  ( 01 111 0 00 0 0 1 Rs 0 110 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMAXLH ( 01 111 0 00 0 1 1 Rs 0 110 00 Rn 11111 -- instruction )

! STUMIN, STUMINL: Atomic unsigned minimum on word or doubleword in memory, without return: an alias of LDUMIN, LDUMINA, LDUMINAL, LDUMINL.
! ARMv8.1
ARM-INSTRUCTION: STUMIN32   ( 10 111 0 00 0 0 1 Rs 0 111 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMINL32  ( 10 111 0 00 0 1 1 Rs 0 111 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMIN64   ( 11 111 0 00 0 0 1 Rs 0 111 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMINL64  ( 11 111 0 00 0 1 1 Rs 0 111 00 Rn 11111 -- instruction )

! STUMINB, STUMINLB: Atomic unsigned minimum on byte in memory, without return: an alias of LDUMINB, LDUMINAB, LDUMINALB, LDUMINLB.
! ARMv8.1
ARM-INSTRUCTION: STUMINB  ( 00 111 0 00 0 0 1 Rs 0 111 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMINLB ( 00 111 0 00 0 1 1 Rs 0 111 00 Rn 11111 -- instruction )

! STUMINH, STUMINLH: Atomic unsigned minimum on halfword in memory, without return: an alias of LDUMINH, LDUMINAH, LDUMINALH, LDUMINLH.
ARM-INSTRUCTION: STUMINH  ( 01 111 0 00 0 0 1 Rs 0 111 00 Rn 11111 -- instruction )
ARM-INSTRUCTION: STUMINLH ( 01 111 0 00 0 1 1 Rs 0 111 00 Rn 11111 -- instruction )

! STUR: Store Register (unscaled).
ARM-INSTRUCTION: STUR32 ( 10 111 0 00 00 0 imm9 00 Rn Rt -- instruction )
ARM-INSTRUCTION: STUR64 ( 11 111 0 00 00 0 imm9 00 Rn Rt -- instruction )

! STURB: Store Register Byte (unscaled).
ARM-INSTRUCTION: STURB ( 00 111 0 00 00 0 imm9 00 Rn Rt -- instruction )

! STURH: Store Register Halfword (unscaled).
ARM-INSTRUCTION: STURH ( 01 111 0 00 00 0 imm9 00 Rn Rt -- instruction )

! STXP: Store Exclusive Pair of registers.
ARM-INSTRUCTION: STXP32 ( 1 0 001000 0 0 1 Rs 0 Rt2 Rn Rt -- instruction )
ARM-INSTRUCTION: STXP64 ( 1 1 001000 0 0 1 Rs 0 Rt2 Rn Rt -- instruction )

! STXR: Store Exclusive Register.
ARM-INSTRUCTION: STXR32 ( 10 001000 0 0 0 Rs 0 11111 Rn Rt -- instruction )
ARM-INSTRUCTION: STXR64 ( 11 001000 0 0 0 Rs 0 11111 Rn Rt -- instruction )

! STXRB: Store Exclusive Register Byte.
ARM-INSTRUCTION: STXRB ( 00 001000 0 0 0 Rs 0 11111 Rn Rt -- instruction )

! STXRH: Store Exclusive Register Halfword.
ARM-INSTRUCTION: STXRH ( 01 001000 0 0 0 Rs 0 11111 Rn Rt -- instruction )

! STZ2G: Store Allocation Tags, Zeroing.
! ARMv8.5
ARM-INSTRUCTION: STZ2Gpost ( 11011001 1 1 1 imm9 0 1 Xn 11111 -- instruction )
ARM-INSTRUCTION: STZ2Gpre  ( 11011001 1 1 1 imm9 1 1 Xn 11111 -- instruction )
ARM-INSTRUCTION: STZ2Gsoff ( 11011001 1 1 1 imm9 1 0 Xn 11111 -- instruction )

! STZG: Store Allocation Tag, Zeroing.
! ARMv8.5
ARM-INSTRUCTION: STZGpost ( 11011001 0 1 1 imm9 0 1 Xn 11111 -- instruction )
ARM-INSTRUCTION: STZGpre  ( 11011001 0 1 1 imm9 1 1 Xn 11111 -- instruction )
ARM-INSTRUCTION: STZGsoff ( 11011001 0 1 1 imm9 1 0 Xn 11111 -- instruction )

! SUB (extended register): Subtract (extended register).
ARM-INSTRUCTION: SUBer32 ( 0 1 0 01011 00 1 Rm option3 imm3 Rn Rd -- instruction )
ARM-INSTRUCTION: SUBer64 ( 1 1 0 01011 00 1 Rm option3 imm3 Rn Rd -- instruction )

! SUB (immediate): Subtract (immediate).
ARM-INSTRUCTION: SUBimm32 ( 0 1 0 10001 shift2 imm12 Rn Rd -- instruction )
ARM-INSTRUCTION: SUBimm64 ( 1 1 0 10001 shift2 imm12 Rn Rd -- instruction )

! SUB (shifted register): Subtract (shifted register).
ARM-INSTRUCTION: SUBsr32 ( 0 1 0 01011 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: SUBsr64 ( 1 1 0 01011 shift2 0 Rm imm6 Rn Rd -- instruction )

! SUBG: Subtract with Tag.
! ARMv8.5
ARM-INSTRUCTION: SUBG ( 1 1 0 100011 0 uimm6 00 uimm4 Xn Xd -- instruction )

! SUBP: Subtract Pointer.
! ARMv8.5
ARM-INSTRUCTION: SUBP ( 1 0 0 11010110 Xm 0 0 0 0 0 0 Xn Xd -- instruction )

! SUBPS: Subtract Pointer, setting Flags.
! ARMv8.5
ARM-INSTRUCTION: SUBPS ( 1 0 1 11010110 Xm 0 0 0 0 0 0 Xn Xd -- instruction )

! SUBS (extended register): Subtract (extended register), setting flags.
ARM-INSTRUCTION: SUBSer32 ( 0 1 1 01011 00 1 Rm option3 imm3 Rn Rd -- instruction )
ARM-INSTRUCTION: SUBSer64 ( 1 1 1 01011 00 1 Rm option3 imm3 Rn Rd -- instruction )

! SUBS (immediate): Subtract (immediate), setting flags.
ARM-INSTRUCTION: SUBSimm32 ( 0 1 1 10001 shift2 imm12 Rn Rd -- instruction )
ARM-INSTRUCTION: SUBSimm64 ( 1 1 1 10001 shift2 imm12 Rn Rd -- instruction )

! SUBS (shifted register): Subtract (shifted register), setting flags.
ARM-INSTRUCTION: SUBSsr32 ( 0 1 1 01011 shift2 0 Rm imm6 Rn Rd -- instruction )
ARM-INSTRUCTION: SUBSsr64 ( 1 1 1 01011 shift2 0 Rm imm6 Rn Rd -- instruction )

! SVC: Supervisor Call.
ARM-INSTRUCTION: SVC ( 11010100 000 imm16 000 01 -- instruction )

! SWP, SWPA, SWPAL, SWPL: Swap word or doubleword in memory
! ARMv8.1
ARM-INSTRUCTION: SWP32   ( 10 111 0 00 0 0 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPA32  ( 10 111 0 00 1 0 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPAL32 ( 10 111 0 00 1 1 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPL32  ( 10 111 0 00 0 1 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWP64   ( 11 111 0 00 0 0 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPA64  ( 11 111 0 00 1 0 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPAL64 ( 11 111 0 00 1 1 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPL64  ( 11 111 0 00 0 1 1 Rs 1 000 00 Rn Rt -- instruction )

! SWPB, SWPAB, SWPALB, SWPLB: Swap byte in memory.
! ARMv8.1
ARM-INSTRUCTION: SWPAB  ( 00 111 0 00 1 0 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPALB ( 00 111 0 00 1 1 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPB   ( 00 111 0 00 0 0 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPLB  ( 00 111 0 00 0 1 1 Rs 1 000 00 Rn Rt -- instruction )

! SWPH, SWPAH, SWPALH, SWPLH: Swap halfword in memory.
ARM-INSTRUCTION: SWPAH  ( 01 111 0 00 1 0 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPALH ( 01 111 0 00 1 1 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPH   ( 01 111 0 00 0 0 1 Rs 1 000 00 Rn Rt -- instruction )
ARM-INSTRUCTION: SWPLH  ( 01 111 0 00 0 1 1 Rs 1 000 00 Rn Rt -- instruction )

! SXTB: Signed Extend Byte: an alias of SBFM.
ARM-INSTRUCTION: SXTB32 ( 0 00 100110 0 000000 000111 Rn Rd -- instruction )
ARM-INSTRUCTION: SXTB64 ( 1 00 100110 1 000000 000111 Rn Rd -- instruction )

! SXTH: Sign Extend Halfword: an alias of SBFM.
ARM-INSTRUCTION: SXTH32 ( 0 00 100110 0 000000 001111 Rn Rd -- instruction )
ARM-INSTRUCTION: SXTH64 ( 1 00 100110 1 000000 001111 Rn Rd -- instruction )

! SXTW: Sign Extend Word: an alias of SBFM.
ARM-INSTRUCTION: SXTW ( 1 00 100110 1 000000 011111 Rn Rd -- instruction )

! SYS: System instruction.
ARM-INSTRUCTION: SYS  ( 1101010100 0 01 op3 CRn CRm op3 Rt -- instruction )

! SYSL: System instruction with result.
ARM-INSTRUCTION: SYSL ( 1101010100 1 01 op3 CRn CRm op3 Rt -- instruction )

! TBNZ: Test bit and Branch if Nonzero.
ARM-INSTRUCTION: TBNZW ( 0 011011 1 b40 imm14 Rt -- instruction )
ARM-INSTRUCTION: TBNZX ( 1 011011 1 b40 imm14 Rt -- instruction )

! TBZ: Test bit and Branch if Zero.
ARM-INSTRUCTION: TBHZW ( 0 011011 0 b40 imm14 Rt -- instruction )
ARM-INSTRUCTION: TBHZX ( 1 011011 0 b40 imm14 Rt -- instruction )

! TLBI: TLB Invalidate operation: an alias of SYS.
ARM-INSTRUCTION: TLBI ( 1101010100 0 01 op3 1000 CRm op3 Rt -- instruction )

! TSB CSYNC: Trace Synchronization Barrier.
! ARMv8.4
ARM-INSTRUCTION: TSB-CSYNC ( 1101010100 0 00 011 0010 0010 010 11111 -- instruction )

! TST (immediate): Test bits (immediate): an alias of ANDS (immediate).
ARM-INSTRUCTION: TSTi32 ( 0 11 100100 0 immrimms Rn 11111 -- instruction )
ARM-INSTRUCTION: TSTi64 ( 1 11 100100 Nimmrimms Rn 11111 -- instruction )

! TST (shifted register): Test (shifted register): an alias of ANDS (shifted register).
ARM-INSTRUCTION: TSTsr32 ( 0 11 01010 shift2 0 Rm imm6 Rn 11111 -- instruction )
ARM-INSTRUCTION: TSTsr64 ( 1 11 01010 shift2 0 Rm imm6 Rn 11111 -- instruction )

! UBFIZ: Unsigned Bitfield Insert in Zero: an alias of UBFM.
ARM-INSTRUCTION: UBFIZ32 ( 0 10 100110 0 immr imms Rn Rd -- instruction )
ARM-INSTRUCTION: UBFIZ64 ( 1 10 100110 1 immr imms Rn Rd -- instruction )

! UBFM: Unsigned Bitfield Move.
ARM-INSTRUCTION: UBFM32 ( 0 10 100110 0 immr imms Rn Rd -- instruction )
ARM-INSTRUCTION: UBFM64 ( 1 10 100110 1 immr imms Rn Rd -- instruction )

! UBFX: Unsigned Bitfield Extract: an alias of UBFM.
ARM-INSTRUCTION: UBFX32 ( 0 10 100110 0 immr imms Rn Rd -- instruction )
ARM-INSTRUCTION: UBFX64 ( 1 10 100110 1 immr imms Rn Rd -- instruction )

! UDF: Permanently Undefined.
ARM-INSTRUCTION: UDF ( 0000000000000000 imm16 -- instruction )

! UDIV: Unsigned Divide.
ARM-INSTRUCTION: UDIV32 ( 0 0 0 11010110 Rm 00001 0 Rn Rd -- instruction )
ARM-INSTRUCTION: UDIV64 ( 1 0 0 11010110 Rm 00001 0 Rn Rd -- instruction )

! UMADDL: Unsigned Multiply-Add Long.
ARM-INSTRUCTION: UMADDL ( 1 00 11011 1 01 Rm 0 Ra Rn Rd -- instruction )

! UMNEGL: Unsigned Multiply-Negate Long: an alias of UMSUBL.
ARM-INSTRUCTION: UMNEGL ( 1 00 11011 1 01 Rm 1 11111 Rn Rd -- instruction )

! UMSUBL: Unsigned Multiply-Subtract Long.
ARM-INSTRUCTION: UMSUBL ( 1 00 11011 1 01 Rm 1 Ra Rn Rd -- instruction )

! UMULH: Unsigned Multiply High.
ARM-INSTRUCTION: UMULH ( 1 00 11011 1 10 Rm 0 11111 Rn Rd -- instruction )

! UMULL: Unsigned Multiply Long: an alias of UMADDL.
ARM-INSTRUCTION: UMULL ( 1 00 11011 1 01 Rm 0 11111 Rn Rd -- instruction )

! UXTB: Unsigned Extend Byte: an alias of UBFM.
ARM-INSTRUCTION: UXTB ( 0 10 100110 0 000000 000111 Rn Rd -- instruction )

! UXTH: Unsigned Extend Halfword: an alias of UBFM.
ARM-INSTRUCTION: UXTH ( 0 10 100110 0 000000 000111 Rn Rd -- instruction )

! WFE: Wait For Event.
ARM-INSTRUCTION: WFE ( 1101010100 0 00 011 0010 0000 010 11111 -- instruction )

! WFI: Wait For Interrupt.
ARM-INSTRUCTION: WFI ( 1101010100 0 00 011 0010 0000 011 11111 -- instruction )

! XAFlag: Convert floating-point condition flags from external format to ARM format.
ARM-INSTRUCTION: XAFlag ( 1101010100 0 00 000 0100 0000 001 11111 -- instruction )

! XPACD, XPACI, XPACLRI: Strip Pointer Authentication Code.
! ARMv8.3
ARM-INSTRUCTION: XPACD ( 1 1 0 11010110 00001 0 1 000 1 11111 Rd -- instruction )
ARM-INSTRUCTION: XPACI ( 1 1 0 11010110 00001 0 1 000 0 11111 Rd -- instruction )
ARM-INSTRUCTION: XPACLRI ( 1101010100 0 00 011 0010 0000 111 11111 -- instruction )

! YIELD: YIELD.
ARM-INSTRUCTION: YIELD ( 1101010100 0 00 011 0010 0000 001 11111 -- instruction )


