USING: kernel parser ;
<< "resource:basis/compiler/constants/constants.factor" run-file >>
<< "resource:basis/cpu/alpha/64/assembler/assembler.factor" run-file >>
USING: byte-arrays cpu.alpha.64.assembler cpu.alpha.64.assembler.registers
io.encodings.binary io.files make ;
[
    R3 R1 R2 ADDQ R3 R1 R2 SUBQ R3 R1 31 ANDI R3 R1 R2 BIS
    R1 R2 -8 LDQ R1 R2 16 STQ F1 R2 0 LDT F1 R2 8 STT
    F3 F1 F2 ADDT F3 F1 F2 SUBT F3 F1 F2 MULT F3 F1 F2 DIVT
    F2 F1 CVTTQ F2 F1 CVTQT F2 F1 CVTST F2 F1 CVTTS
    F3 F1 F2 CMPTLT F3 F1 F2 CPYS F1 MF-FPCR F1 MT-FPCR
    F2 F1 SQRTT
] B{ } make "alpha-assembler.bin" binary set-file-contents
