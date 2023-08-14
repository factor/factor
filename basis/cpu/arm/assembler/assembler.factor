! Copyright (C) 2020 Doug Coleman.
! Copyright (C) 2023 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators cpu.arm.assembler.opcodes
generalizations grouping kernel math math.bitwise math.parser
sequences shuffle ;
IN: cpu.arm.assembler

! pre-index mode: computed addres is the base-register + offset
! ldr X1, [X2, #4]!
! post-index mode: computed address is the base-register
! ldr X1, [X2], #4
! in both modes, the base-register is updated

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

! Floating-point variants

SYMBOLS: H S D ;

: >ftype ( symbol -- n ) { { H 3 } { S 0 } { D 1 } } at ; inline


: ADDV ( Rn Rd size Q -- ) -roll -rot ADDV-encode ;

: ADR ( simm21 Rd -- ) [ [ 2 bits ] [ -2 shift 19 ?sbits ] bi ] dip ADR-encode ;

: ADRP ( simm21 Rd -- ) [ 4096 / [ 2 bits ] [ -2 shift 19 ?sbits ] bi ] dip ADRP-encode ;

! B but that is breakpoint
: Br ( simm28 -- ) 2 ?>> 26 ?sbits B-encode ;
: B.cond ( simm21 cond -- ) [ 2 ?>> 19 ?sbits ] dip B.cond-encode ;
: BL ( simm28 -- ) 2 ?>> 26 ?sbits BL-encode ;
: BR ( Rn -- ) BR-encode ;
: BLR ( Rn -- ) BLR-encode ;

: BRK ( uimm16 -- ) 16 ?ubits BRK-encode ;

: CNT ( Vn Vd size Q -- ) -roll -rot CNT-encode ;

: DUPgen ( Rn Rd size Q -- ) -roll 2^ -rot DUPgen-encode ;

: FADDs ( Rm Rn Rd var -- ) >ftype -roll FADDs-encode ;
: FCVT ( Rn Rd svar dvar -- ) [ >ftype ] bi@ 2swap FCVT-encode ;
: FDIVs ( Rm Rn Rd var -- ) >ftype -roll FDIVs-encode ;
: FMAXs ( Rm Rn Rd var -- ) >ftype -roll FMAXs-encode ;
: FMINs ( Rm Rn Rd var -- ) >ftype -roll FMINs-encode ;
: FMULs ( Rm Rn Rd var -- ) >ftype -roll FMULs-encode ;
: FSQRTs ( Rn Rd var -- ) >ftype -rot FSQRTs-encode ;
: FSUBs ( Rm Rn Rd var -- ) >ftype -roll FSUBs-encode ;

: FMOVgen ( Rn Rd sf ftype rmode opcode -- ) 4 2 mnswap FMOVgen-encode ;

: FPCR ( -- op0 op1 CRn CRm op2 ) 3 3 4 4 0 ;
: FPSR ( -- op0 op1 CRn CRm op2 ) 3 3 4 4 1 ;

: HLT ( uimm16 -- ) 16 ?ubits HLT-encode ;

: LDRBr ( Rm Rn Rt -- ) [ 0 ] 2dip LDRBsr-encode ;
: LDRBuoff ( uimm12 Rn Rt -- ) [ 12 ?ubits ] 2dip LDRBuoff-encode ;
: LDRHuoff ( uimm13 Rn Rt -- ) [ 1 ?>> 12 ?ubits ] 2dip LDRHuoff-encode ;

: MRS ( op0 op1 CRn CRm op2 Rt -- ) MRS-encode ;
: MSRr ( op0 op1 CRn CRm op2 Rt -- ) MSRr-encode ;

: NZCV ( -- op0 op1 CRn CRm op2 ) 3 3 4 2 0 ;

: RET ( Rn/f -- ) X30 or RET-encode ;

: SVC ( uimm16 -- ) 16 ?ubits SVC-encode ;
