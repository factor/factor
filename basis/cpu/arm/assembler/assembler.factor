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

: ADR ( imm21 Rd -- )
    [ [ 2 bits ] [ -2 shift 19 ?bits ] bi ] dip ADR-encode ;

: ADRP ( imm21 Rd -- )
    [ [ 2 bits ] [ -2 shift 19 ?bits ] bi ] dip ADRP-encode ;

: LDR-pre ( imm9 Rn Rt -- ) LDRpre64-encode ;
: LDR-post ( imm9 Rn Rt -- ) LDRpost64-encode ;
: LDR-uoff ( imm12 Rn Rt -- ) [ 8 / ] 2dip LDRuoff64-encode ;

: MOVwi64 ( imm Rt -- ) [ 0 ] 2dip MOVwi64-encode ;
: MOVr64 ( Rn Rd -- ) MOVr64-encode ;

: RET ( register/f -- ) X30 or RET-encode ;

! stp     x29, x30, [sp,#-16]!
! -16 SP X30 X29 STP-pre
: STP-pre ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPpre64-encode ;

: STP-post ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPpost64-encode ;

: STP-signed-offset ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPsoff64-encode ;


: LDP-pre ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd LDPpre64-encode ;

: LDP-post ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd LDPpost64-encode ;

: LDP-signed-offset ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd LDPsoff64-encode ;

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
    ADDi32-encode ;

: ADDi64 ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    ADDi64-encode ;

: SUBi32 ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    SUBi32-encode ;

: SUBi64 ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    SUBi64-encode ;

: CMPi32 ( imm12 Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] dip
    CMPi32-encode ;

: CMPi64 ( imm12 Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] dip
    CMPi64-encode ;

: STRuoff32 ( imm12 Rn Rt -- )
    [ -2 shift ] 2dip STRuoff32-encode ;

: STRuoff64 ( imm12 Rn Rt -- )
    [ -3 shift ] 2dip STRuoff64-encode ;

: STRr64 ( Rm Rn Rt -- )
    [ 0 0 ] 2dip STRr64-encode ;

: ASRi32 ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip ASRi32-encode ;
: ASRi64 ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip ASRi64-encode ;
: LSLi32 ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip LSLi32-encode ;
: LSLi64 ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip LSLi64-encode ;
: LSRi32 ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip LSRi32-encode ;
: LSRi64 ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip LSRi64-encode ;

: SVC ( imm16 -- ) 16 ?bits SVC-encode ;

: ADC32 ( Rm Rn Rd -- ) ADC32-encode ;
: ADCS32 ( Rm Rn Rd -- ) ADCS32-encode ;
: ADC64 ( Rm Rn Rd -- ) ADC64-encode ;
: ADCS64 ( Rm Rn Rd -- ) ADCS64-encode ;

: BRK ( imm16 -- ) 16 ?bits BRK-encode ;
: HLT ( imm16 -- ) 16 ?bits HLT-encode ;

: CBNZ ( imm19 Rt -- ) [ 19 ?bits ] dip CBNZ64-encode ;
! cond4 is EQ NE CS HS CC LO MI PL VS VC HI LS GE LT GT LE AL NV
: CSEL ( Rm Rn Rd cond4 -- ) -rot CSEL64-encode ;
: CSET ( Rd cond4 -- ) swap CSET64-encode ;
: CSETM ( Rd cond4 -- ) swap CSETM64-encode ;

! B but that is breakpoint
: Br ( imm26 -- ) 26 ?bits B-encode ;
: B.cond ( imm19 cond4 -- ) [ 19 ?bits ] dip B.cond-encode ;
! : BL ( offset -- ) ip - 4 / BL-encode ;
: BL ( offset -- ) BL-encode ;
: BR ( Rn -- ) BR-encode ;
: BLR ( Rn -- ) BLR-encode ;
