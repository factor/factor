! GNU binutils 2.45 oracle, LoongArch64 LP64D.
USING: cpu.loongarch.64.assembler cpu.loongarch.64.assembler.registers
endian grouping kernel make sequences tools.test ;
IN: cpu.loongarch.64.assembler.tests
{ { 0x001098a4 0x02ffc0a4 0x28ffe2f0 0x29c022f0 0x0041fe30
    0x1c00000c 0x4c000181 0x64001200 0x00830010 0x01010820
    0x0c220820 0x0114dc04 0x011aa816 0x0114bac4 } } [
    [ A0 A1 A2 ADD A0 A1 -16 ADDI ds-0 DS -8 LD ds-0 DS 8 SD
      ds-0 ds-1 63 SLLI temp 0 AUIPC RA temp 0 JALR
      ds-0 ZERO 16 BGE ds-0 ds-0 -16 ANDI F0 F1 F2 FADD.D
      A0 F1 F2 FEQ.D A0 F0 1 FCVT.L.D ] B{ } make
    4 <groups> [ le> ] map
] unit-test

! Ordered less/less-equal comparisons signal for quiet NaNs.
{ { 0x0c218820 0x0114dc04 0x0c238820 0x0114dc04 } } [
    [ A0 F1 F2 FLT.D A0 F1 F2 FLE.D ] B{ } make
    4 <groups> [ le> ] map
] unit-test

{ { 0x00150000 } } [
    [ NOP ] B{ } make 4 <groups> [ le> ] map
] unit-test
