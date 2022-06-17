! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.extras
cpu.arm.assembler.opcodes io.binary kernel math
math.bitwise namespaces sequences ;
IN: cpu.arm.assembler

! pre-index mode: computed addres is the base-register + offset
! ldr X1, [X2, #4]!
! post-index mode: computed address is the base-register
! ldr X1, [X2], #4
! in both modes, the base-register is updated

TUPLE: arm64-assembler ip labels out ;
: <arm64-assembler> ( ip -- arm-assembler )
    arm64-assembler new
        swap >>ip
        H{ } clone >>labels
        V{ } clone >>out ;

: ip ( -- address ) arm64-assembler get ip>> ;
: >out ( instruction -- ) arm64-assembler get out>> push ;

: ADR ( imm21 Rd -- )
    [ [ 2 bits ] [ 19 bits ] bi ] dip ADR-encode >out ;

: ADRP ( imm21 Rd -- )
    [ [ 2 bits ] [ 19 bits ] bi ] dip ADRP-encode >out ;

: BL ( offset -- ) ip - 4 / BL-encode >out ;
: BR ( register -- ) BR-encode >out ;

: LDR-pre ( imm9 Rn Rt -- ) LDRpre64-encode >out ;
: LDR-post ( imm9 Rn Rt -- ) LDRpost64-encode >out ;
: LDR-uoff ( imm12 Rn Rt -- ) [ 8 / ] 2dip LDRuoff64-encode >out ;

: MOVwi64 ( imm Rt -- ) [ 0 ] 2dip MOVwi64-encode >out ;
: MOVr64 ( Rn Rd -- ) MOVr64-encode >out ;

: RET ( register/f -- ) X30 or RET-encode >out ;

! stp     x29, x30, [sp,#-16]!
! -16 SP X30 X29 STP-pre
: STP-pre ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPpre64-encode >out ;

: STP-post ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPpost64-encode >out ;

: STP-signed-offset ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPsoff64-encode >out ;

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

: ADDi32 ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    ADDi32-encode >out ;

: ADDi64 ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    ADDi64-encode >out ;

: SUBi32 ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    SUBi32-encode >out ;

: SUBi64 ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    SUBi64-encode >out ;

: CMPi32 ( imm12 Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] dip
    CMPi32-encode >out ;

: CMPi64 ( imm12 Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] dip
    CMPi64-encode >out ;

: STRuoff32 ( imm12 Rn Rt -- )
    [ -2 shift ] 2dip STRuoff32-encode >out ;

: STRuoff64 ( imm12 Rn Rt -- )
    [ -3 shift ] 2dip STRuoff64-encode >out ;

: STRr64 ( Rm Rn Rt -- )
    [ 0 0 ] 2dip STRr64-encode >out ;

: ASRi32 ( imm6 Rn Rd -- ) ASRi32-encode >out ;
: ASRi64 ( imm6 Rn Rd -- ) ASRi64-encode >out ;
: LSLi32 ( imm6 Rn Rd -- ) LSLi32-encode >out ;
: LSLi64 ( imm6 Rn Rd -- ) LSLi64-encode >out ;
: LSRi32 ( imm6 Rn Rd -- ) LSRi32-encode >out ;
: LSRi64 ( imm6 Rn Rd -- ) LSRi64-encode >out ;

: SVC ( imm16 -- ) SVC-encode >out ;

: with-new-arm64-offset ( offset quot -- arm64-assembler )
    [ <arm64-assembler> \ arm64-assembler ] dip
    '[ @ \ arm64-assembler get ] with-variable ; inline

: with-new-arm64 ( quot -- arm64-assembler )
    [ 0 <arm64-assembler> \ arm64-assembler ] dip
    '[ @ \ arm64-assembler get ] with-variable ; inline

: assemble-arm ( quot -- bytes )
    with-new-arm64 out>> [ 4 >le ] map concat ; inline

: offset-test-arm64 ( offset quot -- instuctions )
    with-new-arm64-offset out>> ; inline

: offset-test-arm64-instruction ( offset quot -- instuction )
    offset-test-arm64 first ; inline

: test-arm64 ( quot -- instructions )
    0 swap offset-test-arm64 ; inline

: test-arm64-instruction ( quot -- instructions )
    0 swap offset-test-arm64-instruction ; inline
