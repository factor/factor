! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cpu.arm64.assembler.opcodes kernel math
math.bitwise namespaces sequences ;
IN: cpu.arm64.assembler

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

: ADDi64 ( imm12 Rn Rd -- ) [ 0 ] 3dip ADDi64-encode >out ;

: ADRP ( imm Rd -- ) [ ip 12 on-bits unmask - -12 shift [ 2 bits ] [ -2 shift ] bi ] dip ADRP-encode >out ;

: BL ( offset -- ) ip - 4 / BL-encode >out ;
: BR ( register -- ) BR-encode >out ;

: LDR-pre ( imm9 Rn Rt -- ) [ 8 / 9 bits ] 2dip LDRpre64-encode >out ;
: LDR-post ( imm9 Rn Rt -- ) [ 8 / 9 bits ] 2dip LDRpost64-encode >out ;
: LDR-uoff ( imm12 Rn Rt -- ) [ 8 / 12 bits ] 2dip LDRuoff64-encode >out ;

: LSLi64 ( imm6 Rd Rt -- ) LSLi64-encode >out ;
: LSRi64 ( imm6 Rd Rt -- ) LSRi64-encode >out ;

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

: with-output-variable ( value variable quot -- value )
    over [ get ] curry compose with-variable ; inline

: with-new-arm64-offset ( offset quot -- arm64-assembler )
    [ <arm64-assembler> \ arm64-assembler ] dip with-output-variable ; inline

: with-new-arm64 ( quot -- arm64-assembler )
    [ 0 <arm64-assembler> \ arm64-assembler ] dip with-output-variable ; inline

: offset-test-arm64 ( offset quot -- instuctions )
    with-new-arm64-offset out>> ; inline

: offset-test-arm64-instruction ( offset quot -- instuction )
    offset-test-arm64 first ; inline

: test-arm64 ( quot -- instructions )
    0 swap offset-test-arm64 ; inline

: test-arm64-instruction ( quot -- instructions )
    0 swap offset-test-arm64-instruction ; inline