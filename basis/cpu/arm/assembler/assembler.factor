! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators cpu.arm.assembler.opcodes
kernel make math math.bitwise namespaces sequences ;
IN: cpu.arm.assembler

! pre-index mode: computed addres is the base-register + offset
! ldr X1, [X2, #4]!
! post-index mode: computed address is the base-register
! ldr X1, [X2], #4
! in both modes, the base-register is updated

ERROR: arm64-encoding-imm original n-bits-requested truncated ;
: ?bits ( x n -- x ) 2dup bits dup reach = [ 2drop ] [ arm64-encoding-imm ] if ; inline

! : ip ( -- address ) arm64-assembler get ip>> ;

! Some instructions allow an immediate literal of n bits
! or n bits shifted. This means there are invalid immediate
! values, e.g. imm12 of 1, 4096, but not 4097
ERROR: imm-out-of-range imm n ;
: imm-lower? ( imm n -- ? )
    on-bits unmask 0 > not ;

 : imm-upper? ( imm n -- ? )
    [ on-bits ] [ shift ] bi unmask 0 > not ;

: prepare-split-imm ( imm n -- imm upper? )
    {
        { [ 2dup imm-lower? ] [ drop f ] }
        { [ 2dup imm-upper? ] [ drop t ] }
        [ imm-out-of-range ]
    } cond ;

: ADR ( imm21 Rd -- )
    [ [ 2 bits ] [ -2 shift 19 ?bits ] bi ] dip ADR-encode ;

: ADRP ( imm21 Rd -- )
    [ [ 2 bits ] [ -2 shift 19 ?bits ] bi ] dip ADRP-encode ;

: RET ( register/f -- ) X30 or RET-encode ;

: SVC ( imm16 -- ) 16 ?bits SVC-encode ;

: BRK ( imm16 -- ) 16 ?bits BRK-encode ;
: HLT ( imm16 -- ) 16 ?bits HLT-encode ;

! B but that is breakpoint
: Br ( imm26 -- ) 26 ?bits B-encode ;
: B.cond ( imm19 cond4 -- ) [ 19 ?bits ] dip B.cond-encode ;
! : BL ( offset -- ) ip - 4 / BL-encode ;
: BL ( offset -- ) BL-encode ;
: BR ( Rn -- ) BR-encode ;
: BLR ( Rn -- ) BLR-encode ;
