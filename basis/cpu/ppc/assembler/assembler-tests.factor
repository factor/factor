IN: cpu.ppc.assembler.tests
USING: cpu.ppc.assembler tools.test arrays kernel namespaces
make vocabs sequences ;

: test-assembler ( expected quot -- )
    [ 1array ] [ [ B{ } make ] curry ] bi* unit-test ;

B{ HEX: 38 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 ADDI ] test-assembler
B{ HEX: 3c HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 ADDIS ] test-assembler
B{ HEX: 30 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 ADDIC ] test-assembler
B{ HEX: 34 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 ADDIC. ] test-assembler
B{ HEX: 38 HEX: 40 HEX: 00 HEX: 01 } [ 1 2 LI ] test-assembler
B{ HEX: 3c HEX: 40 HEX: 00 HEX: 01 } [ 1 2 LIS ] test-assembler
B{ HEX: 38 HEX: 22 HEX: ff HEX: fd } [ 1 2 3 SUBI ] test-assembler
B{ HEX: 1c HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 MULI ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 1a HEX: 14 } [ 1 2 3 ADD ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 1a HEX: 15 } [ 1 2 3 ADD. ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 1e HEX: 14 } [ 1 2 3 ADDO ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 1e HEX: 15 } [ 1 2 3 ADDO. ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 18 HEX: 14 } [ 1 2 3 ADDC ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 18 HEX: 15 } [ 1 2 3 ADDC. ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 1e HEX: 14 } [ 1 2 3 ADDO ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 1c HEX: 15 } [ 1 2 3 ADDCO. ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 19 HEX: 14 } [ 1 2 3 ADDE ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: 38 } [ 1 2 3 AND ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: 39 } [ 1 2 3 AND. ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 1b HEX: d6 } [ 1 2 3 DIVW ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 1b HEX: 96 } [ 1 2 3 DIVWU ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1a HEX: 38 } [ 1 2 3 EQV ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1b HEX: b8 } [ 1 2 3 NAND ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: f8 } [ 1 2 3 NOR ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 10 HEX: f8 } [ 1 2 NOT ] test-assembler
B{ HEX: 60 HEX: 41 HEX: 00 HEX: 03 } [ 1 2 3 ORI ] test-assembler
B{ HEX: 64 HEX: 41 HEX: 00 HEX: 03 } [ 1 2 3 ORIS ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1b HEX: 78 } [ 1 2 3 OR ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 13 HEX: 78 } [ 1 2 MR ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 18 HEX: 96 } [ 1 2 3 MULHW ] test-assembler
B{ HEX: 1c HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 MULLI ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 18 HEX: 16 } [ 1 2 3 MULHWU ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 19 HEX: d6 } [ 1 2 3 MULLW ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: 30 } [ 1 2 3 SLW ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1e HEX: 30 } [ 1 2 3 SRAW ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1c HEX: 30 } [ 1 2 3 SRW ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1e HEX: 70 } [ 1 2 3 SRAWI ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 18 HEX: 50 } [ 1 2 3 SUBF ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 18 HEX: 10 } [ 1 2 3 SUBFC ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 19 HEX: 10 } [ 1 2 3 SUBFE ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 07 HEX: 74 } [ 1 2 EXTSB ] test-assembler
B{ HEX: 68 HEX: 41 HEX: 00 HEX: 03 } [ 1 2 3 XORI ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1a HEX: 78 } [ 1 2 3 XOR ] test-assembler
B{ HEX: 7c HEX: 22 HEX: 00 HEX: d0 } [ 1 2 NEG ] test-assembler
B{ HEX: 2c HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 CMPI ] test-assembler
B{ HEX: 28 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 CMPLI ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: 00 } [ 1 2 3 CMP ] test-assembler
B{ HEX: 54 HEX: 22 HEX: 19 HEX: 0a } [ 1 2 3 4 5 RLWINM ] test-assembler
B{ HEX: 54 HEX: 22 HEX: 18 HEX: 38 } [ 1 2 3 SLWI ] test-assembler
B{ HEX: 54 HEX: 22 HEX: e8 HEX: fe } [ 1 2 3 SRWI ] test-assembler
B{ HEX: 88 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LBZ ] test-assembler
B{ HEX: 8c HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LBZU ] test-assembler
B{ HEX: a8 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LHA ] test-assembler
B{ HEX: ac HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LHAU ] test-assembler
B{ HEX: a0 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LHZ ] test-assembler
B{ HEX: a4 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LHZU ] test-assembler
B{ HEX: 80 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LWZ ] test-assembler
B{ HEX: 84 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LWZU ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: ae } [ 1 2 3 LBZX ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: ee } [ 1 2 3 LBZUX ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1a HEX: ae } [ 1 2 3 LHAX ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1a HEX: ee } [ 1 2 3 LHAUX ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1a HEX: 2e } [ 1 2 3 LHZX ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 1a HEX: 6e } [ 1 2 3 LHZUX ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: 2e } [ 1 2 3 LWZX ] test-assembler
B{ HEX: 7c HEX: 41 HEX: 18 HEX: 6e } [ 1 2 3 LWZUX ] test-assembler
B{ HEX: 48 HEX: 00 HEX: 00 HEX: 01 } [ 1 B ] test-assembler
B{ HEX: 48 HEX: 00 HEX: 00 HEX: 01 } [ 1 BL ] test-assembler
B{ HEX: 41 HEX: 80 HEX: 00 HEX: 04 } [ 1 BLT ] test-assembler
B{ HEX: 41 HEX: 81 HEX: 00 HEX: 04 } [ 1 BGT ] test-assembler
B{ HEX: 40 HEX: 81 HEX: 00 HEX: 04 } [ 1 BLE ] test-assembler
B{ HEX: 40 HEX: 80 HEX: 00 HEX: 04 } [ 1 BGE ] test-assembler
B{ HEX: 41 HEX: 80 HEX: 00 HEX: 04 } [ 1 BLT ] test-assembler
B{ HEX: 40 HEX: 82 HEX: 00 HEX: 04 } [ 1 BNE ] test-assembler
B{ HEX: 41 HEX: 82 HEX: 00 HEX: 04 } [ 1 BEQ ] test-assembler
B{ HEX: 41 HEX: 83 HEX: 00 HEX: 04 } [ 1 BO ] test-assembler
B{ HEX: 40 HEX: 83 HEX: 00 HEX: 04 } [ 1 BNO ] test-assembler
B{ HEX: 4c HEX: 20 HEX: 00 HEX: 20 } [ 1 BCLR ] test-assembler
B{ HEX: 4e HEX: 80 HEX: 00 HEX: 20 } [ BLR ] test-assembler
B{ HEX: 4e HEX: 80 HEX: 00 HEX: 21 } [ BLRL ] test-assembler
B{ HEX: 4c HEX: 20 HEX: 04 HEX: 20 } [ 1 BCCTR ] test-assembler
B{ HEX: 4e HEX: 80 HEX: 04 HEX: 20 } [ BCTR ] test-assembler
B{ HEX: 7c HEX: 61 HEX: 02 HEX: a6 } [ 3 MFXER ] test-assembler
B{ HEX: 7c HEX: 68 HEX: 02 HEX: a6 } [ 3 MFLR ] test-assembler
B{ HEX: 7c HEX: 69 HEX: 02 HEX: a6 } [ 3 MFCTR ] test-assembler
B{ HEX: 7c HEX: 61 HEX: 03 HEX: a6 } [ 3 MTXER ] test-assembler
B{ HEX: 7c HEX: 68 HEX: 03 HEX: a6 } [ 3 MTLR ] test-assembler
B{ HEX: 7c HEX: 69 HEX: 03 HEX: a6 } [ 3 MTCTR ] test-assembler
B{ HEX: 7c HEX: 61 HEX: 02 HEX: a6 } [ 3 MFXER ] test-assembler
B{ HEX: 7c HEX: 68 HEX: 02 HEX: a6 } [ 3 MFLR ] test-assembler
B{ HEX: c0 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LFS ] test-assembler
B{ HEX: c4 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LFSU ] test-assembler
B{ HEX: c8 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LFD ] test-assembler
B{ HEX: cc HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 LFDU ] test-assembler
B{ HEX: d0 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 STFS ] test-assembler
B{ HEX: d4 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 STFSU ] test-assembler
B{ HEX: d8 HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 STFD ] test-assembler
B{ HEX: dc HEX: 22 HEX: 00 HEX: 03 } [ 1 2 3 STFDU ] test-assembler
B{ HEX: fc HEX: 20 HEX: 10 HEX: 48 } [ 1 2 FMR ] test-assembler
B{ HEX: fc HEX: 20 HEX: 10 HEX: 1e } [ 1 2 FCTIWZ ] test-assembler
B{ HEX: fc HEX: 22 HEX: 18 HEX: 2a } [ 1 2 3 FADD ] test-assembler
B{ HEX: fc HEX: 22 HEX: 18 HEX: 2b } [ 1 2 3 FADD. ] test-assembler
B{ HEX: fc HEX: 22 HEX: 18 HEX: 28 } [ 1 2 3 FSUB ] test-assembler
B{ HEX: fc HEX: 22 HEX: 00 HEX: f2 } [ 1 2 3 FMUL ] test-assembler
B{ HEX: fc HEX: 22 HEX: 18 HEX: 24 } [ 1 2 3 FDIV ] test-assembler
B{ HEX: fc HEX: 20 HEX: 10 HEX: 2c } [ 1 2 FSQRT ] test-assembler
B{ HEX: fc HEX: 41 HEX: 18 HEX: 00 } [ 1 2 3 FCMPU ] test-assembler
B{ HEX: fc HEX: 41 HEX: 18 HEX: 40 } [ 1 2 3 FCMPO ] test-assembler
B{ HEX: 3c HEX: 60 HEX: 12 HEX: 34 HEX: 60 HEX: 63 HEX: 56 HEX: 78 } [ HEX: 12345678 3 LOAD ] test-assembler
