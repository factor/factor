USING: cpu.ppc.assembler tools.test arrays kernel namespaces
make vocabs sequences byte-arrays.hex ;
FROM: cpu.ppc.assembler => B ;
IN: cpu.ppc.assembler.tests

: test-assembler ( expected quot -- )
    [ 1array ] [ [ B{ } make ] curry ] bi* unit-test ;

HEX{ 38 22 00 03 } [ 1 2 3 ADDI ] test-assembler
HEX{ 3c 22 00 03 } [ 1 2 3 ADDIS ] test-assembler
HEX{ 30 22 00 03 } [ 1 2 3 ADDIC ] test-assembler
HEX{ 34 22 00 03 } [ 1 2 3 ADDIC. ] test-assembler
HEX{ 38 40 00 01 } [ 1 2 LI ] test-assembler
HEX{ 3c 40 00 01 } [ 1 2 LIS ] test-assembler
HEX{ 38 22 ff fd } [ 1 2 3 SUBI ] test-assembler
HEX{ 1c 22 00 03 } [ 1 2 3 MULI ] test-assembler
HEX{ 7c 22 1a 14 } [ 1 2 3 ADD ] test-assembler
HEX{ 7c 22 1a 15 } [ 1 2 3 ADD. ] test-assembler
HEX{ 7c 22 1e 14 } [ 1 2 3 ADDO ] test-assembler
HEX{ 7c 22 1e 15 } [ 1 2 3 ADDO. ] test-assembler
HEX{ 7c 22 18 14 } [ 1 2 3 ADDC ] test-assembler
HEX{ 7c 22 18 15 } [ 1 2 3 ADDC. ] test-assembler
HEX{ 7c 22 1e 14 } [ 1 2 3 ADDO ] test-assembler
HEX{ 7c 22 1c 15 } [ 1 2 3 ADDCO. ] test-assembler
HEX{ 7c 22 19 14 } [ 1 2 3 ADDE ] test-assembler
HEX{ 7c 41 18 38 } [ 1 2 3 AND ] test-assembler
HEX{ 7c 41 18 39 } [ 1 2 3 AND. ] test-assembler
HEX{ 7c 22 1b d6 } [ 1 2 3 DIVW ] test-assembler
HEX{ 7c 22 1b 96 } [ 1 2 3 DIVWU ] test-assembler
HEX{ 7c 41 1a 38 } [ 1 2 3 EQV ] test-assembler
HEX{ 7c 41 1b b8 } [ 1 2 3 NAND ] test-assembler
HEX{ 7c 41 18 f8 } [ 1 2 3 NOR ] test-assembler
HEX{ 7c 41 10 f8 } [ 1 2 NOT ] test-assembler
HEX{ 60 41 00 03 } [ 1 2 3 ORI ] test-assembler
HEX{ 64 41 00 03 } [ 1 2 3 ORIS ] test-assembler
HEX{ 7c 41 1b 78 } [ 1 2 3 OR ] test-assembler
HEX{ 7c 41 13 78 } [ 1 2 MR ] test-assembler
HEX{ 7c 22 18 96 } [ 1 2 3 MULHW ] test-assembler
HEX{ 1c 22 00 03 } [ 1 2 3 MULLI ] test-assembler
HEX{ 7c 22 18 16 } [ 1 2 3 MULHWU ] test-assembler
HEX{ 7c 22 19 d6 } [ 1 2 3 MULLW ] test-assembler
HEX{ 7c 41 18 30 } [ 1 2 3 SLW ] test-assembler
HEX{ 7c 41 1e 30 } [ 1 2 3 SRAW ] test-assembler
HEX{ 7c 41 1c 30 } [ 1 2 3 SRW ] test-assembler
HEX{ 7c 41 1e 70 } [ 1 2 3 SRAWI ] test-assembler
HEX{ 7c 22 18 50 } [ 1 2 3 SUBF ] test-assembler
HEX{ 7c 22 18 10 } [ 1 2 3 SUBFC ] test-assembler
HEX{ 7c 22 19 10 } [ 1 2 3 SUBFE ] test-assembler
HEX{ 7c 41 07 74 } [ 1 2 EXTSB ] test-assembler
HEX{ 68 41 00 03 } [ 1 2 3 XORI ] test-assembler
HEX{ 7c 41 1a 78 } [ 1 2 3 XOR ] test-assembler
HEX{ 7c 22 00 d0 } [ 1 2 NEG ] test-assembler
HEX{ 2c 22 00 03 } [ 1 2 3 CMPI ] test-assembler
HEX{ 28 22 00 03 } [ 1 2 3 CMPLI ] test-assembler
HEX{ 7c 41 18 00 } [ 1 2 3 CMP ] test-assembler
HEX{ 54 22 19 0a } [ 1 2 3 4 5 RLWINM ] test-assembler
HEX{ 54 22 18 38 } [ 1 2 3 SLWI ] test-assembler
HEX{ 54 22 e8 fe } [ 1 2 3 SRWI ] test-assembler
HEX{ 88 22 00 03 } [ 1 2 3 LBZ ] test-assembler
HEX{ 8c 22 00 03 } [ 1 2 3 LBZU ] test-assembler
HEX{ a8 22 00 03 } [ 1 2 3 LHA ] test-assembler
HEX{ ac 22 00 03 } [ 1 2 3 LHAU ] test-assembler
HEX{ a0 22 00 03 } [ 1 2 3 LHZ ] test-assembler
HEX{ a4 22 00 03 } [ 1 2 3 LHZU ] test-assembler
HEX{ 80 22 00 03 } [ 1 2 3 LWZ ] test-assembler
HEX{ 84 22 00 03 } [ 1 2 3 LWZU ] test-assembler
HEX{ 7c 41 18 ae } [ 1 2 3 LBZX ] test-assembler
HEX{ 7c 41 18 ee } [ 1 2 3 LBZUX ] test-assembler
HEX{ 7c 41 1a ae } [ 1 2 3 LHAX ] test-assembler
HEX{ 7c 41 1a ee } [ 1 2 3 LHAUX ] test-assembler
HEX{ 7c 41 1a 2e } [ 1 2 3 LHZX ] test-assembler
HEX{ 7c 41 1a 6e } [ 1 2 3 LHZUX ] test-assembler
HEX{ 7c 41 18 2e } [ 1 2 3 LWZX ] test-assembler
HEX{ 7c 41 18 6e } [ 1 2 3 LWZUX ] test-assembler
HEX{ 7c 41 1c 2e } [ 1 2 3 LFSX ] test-assembler
HEX{ 7c 41 1c 6e } [ 1 2 3 LFSUX ] test-assembler
HEX{ 7c 41 1c ae } [ 1 2 3 LFDX ] test-assembler
HEX{ 7c 41 1c ee } [ 1 2 3 LFDUX ] test-assembler
HEX{ 7c 41 1d 2e } [ 1 2 3 STFSX ] test-assembler
HEX{ 7c 41 1d 6e } [ 1 2 3 STFSUX ] test-assembler
HEX{ 7c 41 1d ae } [ 1 2 3 STFDX ] test-assembler
HEX{ 7c 41 1d ee } [ 1 2 3 STFDUX ] test-assembler
HEX{ 48 00 00 01 } [ 1 B ] test-assembler
HEX{ 48 00 00 01 } [ 1 BL ] test-assembler
HEX{ 41 80 00 04 } [ 1 BLT ] test-assembler
HEX{ 41 81 00 04 } [ 1 BGT ] test-assembler
HEX{ 40 81 00 04 } [ 1 BLE ] test-assembler
HEX{ 40 80 00 04 } [ 1 BGE ] test-assembler
HEX{ 41 80 00 04 } [ 1 BLT ] test-assembler
HEX{ 40 82 00 04 } [ 1 BNE ] test-assembler
HEX{ 41 82 00 04 } [ 1 BEQ ] test-assembler
HEX{ 41 83 00 04 } [ 1 BO ] test-assembler
HEX{ 40 83 00 04 } [ 1 BNO ] test-assembler
HEX{ 4c 20 00 20 } [ 1 BCLR ] test-assembler
HEX{ 4e 80 00 20 } [ BLR ] test-assembler
HEX{ 4e 80 00 21 } [ BLRL ] test-assembler
HEX{ 4c 20 04 20 } [ 1 BCCTR ] test-assembler
HEX{ 4e 80 04 20 } [ BCTR ] test-assembler
HEX{ 7c 61 02 a6 } [ 3 MFXER ] test-assembler
HEX{ 7c 68 02 a6 } [ 3 MFLR ] test-assembler
HEX{ 7c 69 02 a6 } [ 3 MFCTR ] test-assembler
HEX{ 7c 61 03 a6 } [ 3 MTXER ] test-assembler
HEX{ 7c 68 03 a6 } [ 3 MTLR ] test-assembler
HEX{ 7c 69 03 a6 } [ 3 MTCTR ] test-assembler
HEX{ 7c 61 02 a6 } [ 3 MFXER ] test-assembler
HEX{ 7c 68 02 a6 } [ 3 MFLR ] test-assembler
HEX{ c0 22 00 03 } [ 1 2 3 LFS ] test-assembler
HEX{ c4 22 00 03 } [ 1 2 3 LFSU ] test-assembler
HEX{ c8 22 00 03 } [ 1 2 3 LFD ] test-assembler
HEX{ cc 22 00 03 } [ 1 2 3 LFDU ] test-assembler
HEX{ d0 22 00 03 } [ 1 2 3 STFS ] test-assembler
HEX{ d4 22 00 03 } [ 1 2 3 STFSU ] test-assembler
HEX{ d8 22 00 03 } [ 1 2 3 STFD ] test-assembler
HEX{ dc 22 00 03 } [ 1 2 3 STFDU ] test-assembler
HEX{ fc 20 10 90 } [ 1 2 FMR ] test-assembler
HEX{ fc 40 08 90 } [ 2 1 FMR ] test-assembler
HEX{ fc 20 10 91 } [ 1 2 FMR. ] test-assembler
HEX{ fc 40 08 91 } [ 2 1 FMR. ] test-assembler
HEX{ fc 20 10 1e } [ 1 2 FCTIWZ ] test-assembler
HEX{ fc 22 18 2a } [ 1 2 3 FADD ] test-assembler
HEX{ fc 22 18 2b } [ 1 2 3 FADD. ] test-assembler
HEX{ fc 22 18 28 } [ 1 2 3 FSUB ] test-assembler
HEX{ fc 22 00 f2 } [ 1 2 3 FMUL ] test-assembler
HEX{ fc 22 18 24 } [ 1 2 3 FDIV ] test-assembler
HEX{ fc 20 10 2c } [ 1 2 FSQRT ] test-assembler
HEX{ fc 41 18 00 } [ 1 2 3 FCMPU ] test-assembler
HEX{ fc 41 18 40 } [ 1 2 3 FCMPO ] test-assembler
HEX{ 3c 60 12 34 60 63 56 78 } [ HEX: 12345678 3 LOAD ] test-assembler
