! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes kernel math ;
IN: cpu.arm.assembler.32

: ADC ( Rm Rn Rd -- ) ADC32-encode ;
: ADCS ( Rm Rn Rd -- ) ADCS32-encode ;

: ADDi ( imm12 Rn Rd -- ) [ split-imm ] 2dip ADDi32-encode ;

: ASRi ( imm6 Rn Rd -- ) [ 6 ?ubits ] 2dip ASRi32-encode ;

: CMPi ( imm12 Rd -- ) [ split-imm ] dip CMPi32-encode ;

: LSLi ( imm6 Rn Rd -- ) [ 6 ?ubits ] 2dip LSLi32-encode ;
: LSRi ( imm6 Rn Rd -- ) [ 6 ?ubits ] 2dip LSRi32-encode ;

: STRuoff ( imm14 Rn Rt -- ) [ 4 / 12 ?ubits ] 2dip STRuoff32-encode ;

: SUBi ( imm12 Rn Rd -- ) [ split-imm ] 2dip SUBi32-encode ;

