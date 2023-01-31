! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes kernel math
math.bitwise ;
IN: cpu.arm.assembler.64

: encode-bitmask ( imm64 -- Nimmrimms ) 64 (encode-bitmask) ;

: ADC ( Rm Rn Rd -- ) ADC64-encode ;
: ADCS ( Rm Rn Rd -- ) ADCS64-encode ;

: ADDi ( uimm24 Rn Rd -- ) [ split-imm ] 2dip ADDi64-encode ;
: ADDr ( Rm Rn Rd -- ) [ 3 0 ] 2dip ADDer64-encode ;

: ANDi ( imm64 Rn Rd -- ) [ encode-bitmask ] 2dip ANDi64-encode ;
: ANDr ( Rm Rn Rd -- ) [ [ 0 ] dip 0 ] 2dip ANDsr64-encode ;

: ASRi ( uimm6 Rn Rd -- ) [ 6 ?ubits ] 2dip ASRi64-encode ;
: ASRr ( Rm Rn Rd -- ) ASRr64-encode ;

: BIC ( Rm Rn Rd -- ) [ [ 0 ] dip 0 ] 2dip BIC64-encode ;

: CBNZ ( simm21 Rt -- ) [ 2 ?>> 19 ?sbits ] dip CBNZ64-encode ;

: CMPi ( imm24 Rd -- ) [ split-imm ] dip CMPi64-encode ;
: CMPr ( Rm Rn -- ) [ 3 0 ] dip CMPer64-encode ;

! cond is EQ NE CS HS CC LO MI PL VS VC HI LS GE LT GT LE AL NV
: CSEL ( Rm Rn Rd cond -- ) -rot CSEL64-encode ;
: CSET ( Rd cond -- ) swap CSET64-encode ;
: CSETM ( Rd cond -- ) swap CSETM64-encode ;

: EORi ( imm64 Rn Rd -- ) [ encode-bitmask ] 2dip EORi64-encode ;
: EORr ( Rm Rn Rd -- ) [ [ 0 ] dip 0 ] 2dip EORsr64-encode ;

: FPCR ( -- op0 op1 CRn CRm op2 ) 3 3 4 4 0 ;
: FPSR ( -- op0 op1 CRn CRm op2 ) 3 3 4 4 1 ;

: LDPpost ( simm10 Rn Rt2 Rt -- ) [ 3 ?>> 7 ?sbits ] 3dip swapd LDPpost64-encode ;
: LDPpre ( simm10 Rn Rt2 Rt -- ) [ 3 ?>> 7 ?sbits ] 3dip swapd LDPpre64-encode ;
: LDPsoff ( simm10 Rn Rt2 Rt -- ) [ 3 ?>> 7 ?sbits ] 3dip swapd LDPsoff64-encode ;

: LDRl ( simm21 Rt -- ) [ 2 ?>> 19 ?sbits ] dip LDRl64-encode ;
: LDRpost ( simm9 Rn Rt -- ) [ 9 ?sbits ] 2dip LDRpost64-encode ;
: LDRpre ( simm9 Rn Rt -- ) [ 9 ?sbits ] 2dip LDRpre64-encode ;
: LDRr ( Rm Rn Rt -- ) [ 3 0 ] 2dip LDRr64-encode ;
: LDRuoff ( uimm15 Rn Rt -- ) [ 3 ?>> 12 ?ubits ] 2dip LDRuoff64-encode ;

: LDRBr ( Rm Rn Rt -- ) [ 0 ] 2dip LDRBsr-encode ;
: LDRBuoff ( uimm12 Rn Rt -- ) [ 12 ?ubits ] 2dip LDRBuoff-encode ;

: LDRHuoff ( uimm13 Rn Rt -- ) [ 1 ?>> 12 ?ubits ] 2dip LDRHuoff-encode ;

: LDUR ( simm9 Rn Rt -- ) [ 9 ?sbits ] 2dip LDUR64-encode ;

: LSLi ( uimm6 Rn Rd -- ) [ 6 ?ubits ] 2dip LSLi64-encode ;
: LSLr ( Rm Rn Rd -- ) LSLr64-encode ;

: LSRi ( uimm6 Rn Rd -- ) [ 6 ?ubits ] 2dip LSRi64-encode ;

: MOVr ( Rn Rd -- ) MOVr64-encode ;
: MOVsp ( Rn Rd -- ) [ 0 ] 2dip MOVsp64-encode ;
: MOVwi ( imm16 Rt -- ) [ [ 0 ] dip 16 bits ] dip MOVwi64-encode ;

: MRS ( op0 op1 CRn CRm op2 Rt -- ) MRS-encode ;

: MSRr ( op0 op1 CRn CRm op2 Rt -- ) MSRr-encode ;

: MSUB ( Ra Rm Rn Rd -- ) [ swap ] 2dip MSUB64-encode ;

: MUL ( Rm Rn Rd -- ) MUL64-encode ;

: MVN ( Rm Rd -- ) [ [ 0 ] dip 0 ] dip MVN64-encode ;

: NEG ( Rm Rd -- ) [ [ 0 ] dip 0 ] dip NEG64-encode ;

: NZCV ( -- op0 op1 CRn CRm op2 ) 3 3 4 2 0 ;

: ORRr ( Rm Rn Rd -- ) [ [ 0 ] dip 0 ] 2dip ORRsr64-encode ;

: SDIV ( Rm Rn Rd -- ) SDIV64-encode ;

: STADD ( Rs Rn -- ) STADD64-encode ;

: STPpost ( simm10 Rn Rt2 Rt -- ) [ 3 ?>> 7 ?sbits ] 3dip swapd STPpost64-encode ;
: STPpre ( simm10 Rn Rt2 Rt -- ) [ 3 ?>> 7 ?sbits ] 3dip swapd STPpre64-encode ;
: STPsoff ( simm10 Rn Rt2 Rt -- ) [ 3 ?>> 7 ?sbits ] 3dip swapd STPsoff64-encode ;

: STRpre ( simm9 Rn Rt -- ) [ 9 ?sbits ] 2dip STRpre64-encode ;
: STRpost ( simm9 Rn Rt -- ) [ 9 ?sbits ] 2dip STRpost64-encode ;
: STRr ( Rm Rn Rt -- ) [ 3 0 ] 2dip STRr64-encode ;
: STRuoff ( uimm15 Rn Rt -- ) [ 3 ?>> 12 ?ubits ] 2dip STRuoff64-encode ;

: SUBi ( uimm24 Rn Rd -- ) [ split-imm ] 2dip SUBi64-encode ;
: SUBr ( Rm Rn Rd -- ) [ 3 0 ] 2dip SUBer64-encode ;

: TSTi ( imm64 Rn -- ) [ encode-bitmask ] dip TSTi64-encode ;
