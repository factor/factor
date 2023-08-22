! Copyright (C) 2020 Doug Coleman.
! Copyright (C) 2023 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators cpu.arm.64.assembler.opcodes
generalizations grouping kernel lexer math math.bitwise
math.parser parser sequences sequences.generalizations shuffle
words words.symbol ;
IN: cpu.arm.64.assembler

<PRIVATE

<<
: name>ord ( str -- n )
    dup 2 tail* { "ZR" "SP" } member?
    [ drop 31 ] [ 1 tail string>number ] if ;

SYNTAX: REGISTERS:
    ";" [
        create-word-in
        [ define-symbol ]
        [ dup name>> name>ord "ordinal" set-word-prop ] bi
    ] each-token ;
>>

PRIVATE>

! General purpose registers, 64bit
REGISTERS: X0 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12
X13 X14 X15 X16 X17 X18 X19 X20 X21 X22 X23 X24 X25
X26 X27 X28 X29 X30 XZR SP ;

! Lower registers, shared with X0..X30, 32bit
REGISTERS: W0 W1 W2 W3 W4 W5 W6 W7 W8 W9 W10 W11 W12
W13 W14 W15 W16 W17 W18 W19 W20 W21 W22 W23 W24 W25
W26 W27 W28 W29 W30 WZR WSP ;

! https://static.docs.arm.com/ddi0487/fb/DDI0487F_b_armv8_arm.pdf pgA1-42
! Neon registers (SIMD Scalar) Q/D/S/H/B 128/64/32/16/8 bits
REGISTERS: V0 V1 V2 V3 V4 V5 V6 V7 V8 V9 V10 V11 V12
V13 V14 V15 V16 V17 V18 V19 V20 V21 V22 V23 V24 V25
V26 V27 V28 V29 V30 V31 ;

REGISTERS: Q0 Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12
Q13 Q14 Q15 Q16 Q17 Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25
Q26 Q27 Q28 Q29 Q30 Q31 ;

REGISTERS: D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12
D13 D14 D15 D16 D17 D18 D19 D20 D21 D22 D23 D24 D25
D26 D27 D28 D29 D30 D31 ;

REGISTERS: S0 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12
S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S25
S26 S27 S28 S29 S30 S31 ;

REGISTERS: H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 H10 H11 H12
H13 H14 H15 H16 H17 H18 H19 H20 H21 H22 H23 H24 H25
H26 H27 H28 H29 H30 H31 ;

REGISTERS: B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 B10 B11 B12
B13 B14 B15 B16 B17 B18 B19 B20 B21 B22 B23 B24 B25
B26 B27 B28 B29 B30 B31 ;

! Condition codes
: EQ ( -- cond ) 0b0000 ; inline ! Z set: equal
: NE ( -- cond ) 0b0001 ; inline ! Z clear: not equal
: CS ( -- cond ) 0b0010 ; inline ! C set: unsigned higher or same
: HS ( -- cond ) 0b0010 ; inline !
: CC ( -- cond ) 0b0011 ; inline ! C clear: unsigned lower
: LO ( -- cond ) 0b0011 ; inline !
: MI ( -- cond ) 0b0100 ; inline ! N set: negative
: PL ( -- cond ) 0b0101 ; inline ! N clear: positive or zero
: VS ( -- cond ) 0b0110 ; inline ! V set: overflow
: VC ( -- cond ) 0b0111 ; inline ! V clear: no overflow
: HI ( -- cond ) 0b1000 ; inline ! C set and Z clear: unsigned higher
: LS ( -- cond ) 0b1001 ; inline ! C clear or Z set: unsigned lower or same
: GE ( -- cond ) 0b1010 ; inline ! N equals V: greater or equal
: LT ( -- cond ) 0b1011 ; inline ! N not equal to V: less than
: GT ( -- cond ) 0b1100 ; inline ! Z clear AND (N equals V): greater than
: LE ( -- cond ) 0b1101 ; inline ! Z set OR (N not equal to V): less than or equal
: AL ( -- cond ) 0b1110 ; inline ! always
: NV ( -- cond ) 0b1111 ; inline ! always

! SIMD Arrangement specifiers
: 8B ( -- size Q ) 0 0 ; inline
: 16B ( -- size Q ) 0 1 ; inline
: 4H ( -- size Q ) 1 0 ; inline
: 8H ( -- size Q ) 1 1 ; inline
: 2S ( -- size Q ) 2 0 ; inline
: 4S ( -- size Q ) 2 1 ; inline
: 2D ( -- size Q ) 3 1 ; inline

! FMOVgen variants
: HW ( -- sf ftype rmode opcode ) 0 3 0 6 ; inline
: HX ( -- sf ftype rmode opcode ) 1 3 0 6 ; inline
: WH ( -- sf ftype rmode opcode ) 0 3 0 7 ; inline
: WS ( -- sf ftype rmode opcode ) 0 0 0 7 ; inline
: SW ( -- sf ftype rmode opcode ) 0 0 0 6 ; inline
: XH ( -- sf ftype rmode opcode ) 1 3 0 7 ; inline
: XD ( -- sf ftype rmode opcode ) 1 1 0 7 ; inline
: XD[1] ( -- sf ftype rmode opcode ) 1 2 0 7 ; inline
: DX ( -- sf ftype rmode opcode ) 1 1 0 6 ; inline
: D[1]X ( -- sf ftype rmode opcode ) 1 2 0 6 ; inline

! Floating-point variants
: H ( -- ftype ) 3 ; inline
: S ( -- ftype ) 0 ; inline
: D ( -- ftype ) 1 ; inline

! Special-purpose registers
: FPCR ( -- op0 op1 CRn CRm op2 ) 3 3 4 4 0 ;
: FPSR ( -- op0 op1 CRn CRm op2 ) 3 3 4 4 1 ;
: NZCV ( -- op0 op1 CRn CRm op2 ) 3 3 4 2 0 ;

<PRIVATE

ERROR: arm64-encoding-imm original n-bits-requested truncated ;
: ?ubits ( x n -- x )
    2dup bits dup reach =
    [ 2drop ] [ arm64-encoding-imm ] if ; inline

: ?sbits ( x n -- x )
    2dup >signed dup reach =
    [ drop bits ] [ arm64-encoding-imm ] if ; inline

ERROR: scaling-error original n-bits-shifted rest ;
: ?>> ( x n -- x )
    2dup bits [ neg shift ] [ scaling-error ] if-zero ;

! Some instructions allow an immediate literal of n bits
! or n bits shifted. This means there are invalid immediate
! values, e.g. imm12 of 1, 4096, but not 4097
ERROR: imm-out-of-range imm n ;
: imm-lower? ( imm n -- ? ) on-bits unmask 0 > not ;

: imm-upper? ( imm n -- ? )
    [ on-bits ] [ shift ] bi unmask 0 > not ;

: (split-imm) ( imm n -- imm upper? )
    {
        { [ 2dup imm-lower? ] [ drop f ] }
        { [ 2dup imm-upper? ] [ drop t ] }
        [ imm-out-of-range ]
    } cond ;

: split-imm ( imm -- shift imm ) 12 (split-imm) 1 0 ? swap ;

: ADR-split ( simm21 -- immlo immhi )
    [ 2 bits ] [ -2 shift 19 ?sbits ] bi ;

! Logical immediates

ERROR: illegal-bitmask-immediate n ;
: ?bitmask ( imm imm-size -- imm )
    dupd on-bits 0 [ = ] bi-curry@ bi or
    [ dup illegal-bitmask-immediate ] when ;

: element-size ( imm imm-size -- imm element-size )
    [ 2dup 2/ [ neg shift ] 2keep '[ _ on-bits bitand ] same? ]
    [ 2/ ] while ;

: bit-transitions ( imm element-size -- seq )
    [ >bin ] dip CHAR: 0 pad-head 2 circular-clump ;

ERROR: illegal-bitmask-element n ;
: ?element ( imm element-size -- element )
    [ bits ] keep dupd bit-transitions
    [ first2 = not ] count 2 =
    [ dup illegal-bitmask-element ] unless ;

: >Nimms ( element element-size -- N imms )
    [ bit-count 1 - ] [ log2 1 + ] bi*
    7 [ on-bits ] bi@ bitxor bitor
    6 toggle-bit [ -6 shift ] [ 6 bits ] bi ;

: >immr ( element element-size -- immr )
    [ bit-transitions "10" swap index 1 + ] keep mod ;

: (encode-bitmask) ( imm imm-size -- (N)immrimms )
    [ bits ] [ ?bitmask ] [ element-size ] tri
    [ ?element ] keep [ >Nimms ] [ >immr ] 2bi
    { 12 0 6 } bitfield* ;

ERROR: register-mismatch registers ;
MACRO: bw ( n -- quot ) ! ( ... -- bw ... )
    dup '[
        [
            _ narray [
                name>> dup "SP" = [ drop "X" ] when first
            ] map
            dup all-equal? [ register-mismatch ] unless
            first CHAR: X = 1 0 ?
        ] _ nkeep
    ] ;

: 1bw ( Rt -- bw Rt ) 1 bw ;
: 2bw ( Rn Rd -- bw Rn Rd ) 2 bw ;
: 3bw ( Rm Rn Rd -- bw Rm Rn Rd ) 3 bw ;
: 4bw ( Ra Rm Rn Rd -- bw Ra Rm Rn Rd ) 4 bw ;

: (load/store-pair) ( simm10 Rn Rt2 Rt -- bw imm7 Rt2 Rn Rt )
    2bw [ -rot [ 3 ?>> 7 ?sbits ] dip ] 2dip swapd ;

PRIVATE>

: encode-bitmask ( imm64 -- Nimmrimms ) 64 (encode-bitmask) ;


: ADC ( Rm Rn Rd -- ) 3bw ADC-encode ;
: ADCS ( Rm Rn Rd -- ) 3bw ADCS-encode ;

: ADDi ( uimm12 Rn Rd -- ) 2bw [ swap split-imm ] 2dip ADDi-encode ;
: ADDr ( Rm Rn Rd -- ) 3bw [ 3 0 ] 2dip ADDer-encode ;

: ADDV ( Vn Rd size Q -- ) -roll -rot ADDV-encode ;

: ADR ( simm21 Xd -- ) [ ADR-split ] dip ADR-encode ;
: ADRP ( simm33 Xd -- ) [ 12 ?>> ADR-split ] dip ADRP-encode ;

: ANDi ( imm64 Rn Rd -- ) 2bw [ swap encode-bitmask ] 2dip ANDi-encode ;
: ANDr ( Rm Rn Rd -- ) 3bw [ 0 0 -rot ] 2dip ANDsr-encode ;

: ASRi ( uimm6 Rn Rd -- ) 2bw [ swap 6 ?ubits ] 2dip ASRi-encode ;
: ASRr ( Rm Rn Rd -- ) 3bw ASRr-encode ;

! B but that is breakpoint
: Br ( simm28 -- ) 2 ?>> 26 ?sbits B-encode ;
: BR ( Rn -- ) BR-encode ;

: B.cond ( simm21 cond -- ) [ 2 ?>> 19 ?sbits ] dip B.cond-encode ;

: BL ( simm28 -- ) 2 ?>> 26 ?sbits BL-encode ;
: BLR ( Rn -- ) BLR-encode ;

: BIC ( Rm Rn Rd -- ) 3bw [ 0 0 -rot ] 2dip BIC-encode ;

: BRK ( uimm16 -- ) 16 ?ubits BRK-encode ;

: CBNZ ( simm21 Rt -- ) 1bw [ swap 2 ?>> 19 ?sbits ] dip CBNZ-encode ;

: CLZ ( Rn Rd -- ) 2bw CLZ-encode ;

: CMPi ( imm12 Rn -- ) 1bw [ swap split-imm ] dip CMPi-encode ;
: CMPr ( Rm Rn -- ) 2bw [ 3 0 ] dip CMPer-encode ;

: CNT ( Vn Vd size Q -- ) -roll -rot CNT-encode ;

! cond is EQ NE CS HS CC LO MI PL VS VC HI LS GE LT GT LE AL NV
: CSEL ( Rm Rn Rd cond -- ) [ 3bw ] dip -rot CSEL-encode ;
: CSET ( Rd cond -- ) [ 1bw ] dip swap CSET-encode ;
: CSETM ( Rd cond -- ) [ 1bw ] dip swap CSETM-encode ;

: DUPgen ( Rn Rd size Q -- ) -roll 2^ -rot DUPgen-encode ;

: EORi ( imm64 Rn Rd -- ) 2bw [ swap encode-bitmask ] 2dip EORi-encode ;
: EORr ( Rm Rn Rd -- ) 3bw [ 0 0 -rot ] 2dip EORsr-encode ;

: FADDs ( Rm Rn Rd var -- ) -roll FADDs-encode ;

: FCVT ( Rn Rd svar dvar -- ) 2swap FCVT-encode ;
: FCVTZSsi ( Rn Rd var -- ) [ 2bw ] dip -rot FCVTZSsi-encode ;

: FDIVs ( Rm Rn Rd var -- ) -roll FDIVs-encode ;

: FMAXs ( Rm Rn Rd var -- ) -roll FMAXs-encode ;
: FMINs ( Rm Rn Rd var -- ) -roll FMINs-encode ;

: FMOVgen ( Rn Rd sf ftype rmode opcode -- ) 4 2 mnswap FMOVgen-encode ;

: FMULs ( Rm Rn Rd var -- ) -roll FMULs-encode ;

: FSQRTs ( Rn Rd var -- ) -rot FSQRTs-encode ;

: FSUBs ( Rm Rn Rd var -- ) -roll FSUBs-encode ;

: HLT ( uimm16 -- ) 16 ?ubits HLT-encode ;

: LDPpost ( simm10 Rn Rt2 Rt -- ) (load/store-pair) LDPpost-encode ;
: LDPpre  ( simm10 Rn Rt2 Rt -- ) (load/store-pair) LDPpre-encode ;
: LDPsoff ( simm10 Rn Rt2 Rt -- ) (load/store-pair) LDPsoff-encode ;

: LDRl ( simm21 Rt -- ) 1bw [ swap 2 ?>> 19 ?sbits ] dip LDRl-encode ;
: LDRpost ( simm9 Rn Rt -- ) 2bw [ swap 9 ?sbits ] 2dip LDRpost-encode ;
: LDRpre ( simm9 Rn Rt -- ) 2bw [ swap 9 ?sbits ] 2dip LDRpre-encode ;
: LDRr ( Rm Rn Rt -- ) 3bw [ 3 0 ] 2dip LDRr-encode ;

: LDRuoff ( uimm14/15 Rn Rt -- ) 1bw -rotd [ over 2 + ?>> 12 ?ubits ] 2dip LDRuoff-encode ;

: LDRBr ( Rm Rn Rt -- ) [ 0 ] 2dip LDRBsr-encode ;
: LDRBuoff ( uimm12 Rn Rt -- ) [ 12 ?ubits ] 2dip LDRBuoff-encode ;
: LDRHuoff ( uimm13 Rn Rt -- ) [ 1 ?>> 12 ?ubits ] 2dip LDRHuoff-encode ;

: LDUR ( simm9 Rn Rt -- ) 2bw [ swap 9 ?sbits ] 2dip LDUR-encode ;

: LSLi ( uimm6 Rn Rd -- ) 2bw [ tuck [ dup ] 2dip 6 ?ubits ] 2dip LSLi-encode ;
: LSLr ( Rm Rn Rd -- ) 3bw LSLr-encode ;

: LSRi ( uimm6 Rn Rd -- ) 2bw [ tuck [ dup ] 2dip 6 ?ubits ] 2dip LSRi-encode ;
: LSRr ( Rm Rn Rd -- ) 3bw LSRr-encode ;

: MOVr ( Rn Rd -- ) 2bw MOVr-encode ;
: MOVsp ( Rn Rd -- ) 2bw [ 0 ] 2dip MOVsp-encode ;
: MOVwi ( imm16 Rd -- ) 1bw [ 0 rot 16 bits ] dip MOVwi-encode ;
: MOVZ ( lsl imm16 Rd -- ) 1bw -rotd [ 16 bits ] dip MOVZ-encode ;
: MOVK ( lsl imm16 Rd -- ) 1bw -rotd [ 16 bits ] dip MOVK-encode ;

: MRS ( op0 op1 CRn CRm op2 Rt -- ) MRS-encode ;
: MSRr ( op0 op1 CRn CRm op2 Rt -- ) MSRr-encode ;

: MSUB ( Ra Rm Rn Rd -- ) 4bw [ swap ] 2dip MSUB-encode ;

: MUL ( Rm Rn Rd -- ) 3bw MUL-encode ;

: MVN ( Rm Rd -- ) 2bw [ 0 0 -rot ] dip MVN-encode ;

: NEG ( Rm Rd -- ) 2bw [ 0 0 -rot ] dip NEG-encode ;

: NOP ( -- ) NOP-encode ;

: ORRi ( imm64 Rn Rd -- ) 2bw [ swap encode-bitmask ] 2dip ORRi-encode ;
: ORRr ( Rm Rn Rd -- ) 3bw [ 0 0 -rot ] 2dip ORRsr-encode ;

: RET ( Rn/f -- ) X30 or RET-encode ;

: SCVTFsi ( Rn Rd var -- ) [ 2bw ] dip -rot SCVTFsi-encode ;

: SDIV ( Rm Rn Rd -- ) 3bw SDIV-encode ;

: STADD ( Rs Rn -- ) 2bw STADD-encode ;

: STPpost ( simm10 Rn Rt2 Rt -- ) (load/store-pair) STPpost-encode ;
: STPpre ( simm10 Rn Rt2 Rt -- ) (load/store-pair) STPpre-encode ;
: STPsoff ( simm10 Rn Rt2 Rt -- ) (load/store-pair) STPsoff-encode ;

: STRpost ( simm9 Rn Rt -- ) 2bw [ swap 9 ?sbits ] 2dip STRpost-encode ;
: STRpre ( simm9 Rn Rt -- ) 2bw [ swap 9 ?sbits ] 2dip STRpre-encode ;
: STRr ( Rm Rn Rt -- ) 3bw [ 3 0 ] 2dip STRr-encode ;
: STRuoff ( uimm14/15 Rn Rt -- ) 1bw -rotd [ over 2 + ?>> 12 ?ubits ] 2dip STRuoff-encode ;

: SUBi ( uimm12 Rn Rd -- ) 2bw [ swap split-imm ] 2dip SUBi-encode ;
: SUBr ( Rm Rn Rd -- ) 3bw [ 3 0 ] 2dip SUBer-encode ;

: SVC ( uimm16 -- ) 16 ?ubits SVC-encode ;

: TSTi ( imm64 Rn -- ) 1bw [ swap encode-bitmask ] dip TSTi-encode ;
