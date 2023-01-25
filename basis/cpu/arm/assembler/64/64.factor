! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes kernel math
math.bitwise ;
IN: cpu.arm.assembler.64

: ADC ( Rm Rn Rd -- ) ADC64-encode ;
: ADCS ( Rm Rn Rd -- ) ADCS64-encode ;

: ADDi ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    ADDi64-encode ;

: ASRi ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip ASRi64-encode ;

: CBNZ ( imm19 Rt -- ) [ 19 ?bits ] dip CBNZ64-encode ;

: CMPi ( imm12 Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] dip
    CMPi64-encode ;

! cond4 is EQ NE CS HS CC LO MI PL VS VC HI LS GE LT GT LE AL NV
: CSEL ( Rm Rn Rd cond4 -- ) -rot CSEL64-encode ;
: CSET ( Rd cond4 -- ) swap CSET64-encode ;
: CSETM ( Rd cond4 -- ) swap CSETM64-encode ;

: LDR-pre ( imm9 Rn Rt -- ) LDRpre64-encode ;
: LDR-post ( imm9 Rn Rt -- ) LDRpost64-encode ;
: LDR-uoff ( imm12 Rn Rt -- ) [ 8 / ] 2dip LDRuoff64-encode ;

: LDP-pre ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd LDPpre64-encode ;

: LDP-post ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd LDPpost64-encode ;

: LDP-signed-offset ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd LDPsoff64-encode ;

: LSLi ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip LSLi64-encode ;
: LSRi ( imm6 Rn Rd -- ) [ 6 ?bits ] 2dip LSRi64-encode ;


: MOVwi ( imm Rt -- ) [ 0 ] 2dip MOVwi64-encode ;
: MOVr ( Rn Rd -- ) MOVr64-encode ;



! stp     x29, x30, [sp,#-16]!
! -16 SP X30 X29 STP-pre
: STP-pre ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPpre64-encode ;

: STP-post ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPpost64-encode ;

: STP-signed-offset ( offset register-offset register-mid register -- )
    [ 8 / 7 bits ] 3dip swapd STPsoff64-encode ;

: STRr ( Rm Rn Rt -- )
    [ 0 0 ] 2dip STRr64-encode ;

: STRuoff ( imm12 Rn Rt -- )
    [ -3 shift ] 2dip STRuoff64-encode ;

: SUBi ( imm12 Rn Rd -- )
    [ 12 prepare-split-imm 1 0 ? swap ] 2dip
    SUBi64-encode ;

