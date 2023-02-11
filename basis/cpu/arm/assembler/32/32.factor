! Copyright (C) 2023 Doug Coleman.
! Copyright (C) 2023 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes kernel math ;
IN: cpu.arm.assembler.32

: ADC ( Rm Rn Rd -- ) ADC32-encode ;
: ADCS ( Rm Rn Rd -- ) ADCS32-encode ;

: ADDi ( uimm24 Rn Rd -- ) [ split-imm ] 2dip ADDi32-encode ;

: ASRi ( uimm6 Rn Rd -- ) [ 6 ?ubits ] 2dip ASRi32-encode ;

: CMPi ( uimm24 Rd -- ) [ split-imm ] dip CMPi32-encode ;

: LSLi ( uimm6 Rn Rd -- ) [ 6 ?ubits ] 2dip LSLi32-encode ;
: LSRi ( uimm6 Rn Rd -- ) [ 6 ?ubits ] 2dip LSRi32-encode ;

: STRuoff ( uimm14 Rn Rt -- ) [ 2 ?>> 12 ?ubits ] 2dip STRuoff32-encode ;

: SUBi ( uimm24 Rn Rd -- ) [ split-imm ] 2dip SUBi32-encode ;
