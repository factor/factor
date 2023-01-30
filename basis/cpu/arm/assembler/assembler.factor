! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators cpu.arm.assembler.opcodes grouping kernel
math math.bitwise math.parser sequences ;
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

: split-imm ( imm -- shift imm' ) 12 (split-imm) 1 0 ? swap ;

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

: ADR ( imm21 Rd -- ) [ [ 2 bits ] [ -2 shift 19 ?sbits ] bi ] dip ADR-encode ;

: ADRP ( imm21 Rd -- ) [ 4096 / [ 2 bits ] [ -2 shift 19 ?sbits ] bi ] dip ADRP-encode ;

: RET ( register/f -- ) X30 or RET-encode ;

: SVC ( imm16 -- ) 16 ?ubits SVC-encode ;

: BRK ( imm16 -- ) 16 ?ubits BRK-encode ;
: HLT ( imm16 -- ) 16 ?ubits HLT-encode ;

! B but that is breakpoint
: Br ( imm28 -- ) 4 / 26 ?sbits B-encode ;
: B.cond ( imm21 cond4 -- ) [ 4 / 19 ?sbits ] dip B.cond-encode ;
: BL ( imm28 -- ) 4 / 26 ?sbits BL-encode ;
: BR ( Rn -- ) BR-encode ;
: BLR ( Rn -- ) BLR-encode ;
