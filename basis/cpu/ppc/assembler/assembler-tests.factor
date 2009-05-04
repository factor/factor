IN: cpu.ppc.assembler.tests
USING: cpu.ppc.assembler tools.test arrays kernel namespaces
make vocabs sequences ;

: test-assembler ( expected quot -- )
    [ 1array ] [ [ { } make ] curry ] bi* unit-test ;

{ HEX: 38220003 } [ 1 2 3 ADDI ] test-assembler
{ HEX: 3c220003 } [ 1 2 3 ADDIS ] test-assembler
{ HEX: 30220003 } [ 1 2 3 ADDIC ] test-assembler
{ HEX: 34220003 } [ 1 2 3 ADDIC. ] test-assembler
{ HEX: 38400001 } [ 1 2 LI ] test-assembler
{ HEX: 3c400001 } [ 1 2 LIS ] test-assembler
{ HEX: 3822fffd } [ 1 2 3 SUBI ] test-assembler
{ HEX: 1c220003 } [ 1 2 3 MULI ] test-assembler
{ HEX: 7c221a14 } [ 1 2 3 ADD ] test-assembler
{ HEX: 7c221a15 } [ 1 2 3 ADD. ] test-assembler
{ HEX: 7c221e14 } [ 1 2 3 ADDO ] test-assembler
{ HEX: 7c221e15 } [ 1 2 3 ADDO. ] test-assembler
{ HEX: 7c221814 } [ 1 2 3 ADDC ] test-assembler
{ HEX: 7c221815 } [ 1 2 3 ADDC. ] test-assembler
{ HEX: 7c221e14 } [ 1 2 3 ADDO ] test-assembler
{ HEX: 7c221c15 } [ 1 2 3 ADDCO. ] test-assembler
{ HEX: 7c221914 } [ 1 2 3 ADDE ] test-assembler
{ HEX: 7c411838 } [ 1 2 3 AND ] test-assembler
{ HEX: 7c411839 } [ 1 2 3 AND. ] test-assembler
{ HEX: 7c221bd6 } [ 1 2 3 DIVW ] test-assembler
{ HEX: 7c221b96 } [ 1 2 3 DIVWU ] test-assembler
{ HEX: 7c411a38 } [ 1 2 3 EQV ] test-assembler
{ HEX: 7c411bb8 } [ 1 2 3 NAND ] test-assembler
{ HEX: 7c4118f8 } [ 1 2 3 NOR ] test-assembler
{ HEX: 7c4110f8 } [ 1 2 NOT ] test-assembler
{ HEX: 60410003 } [ 1 2 3 ORI ] test-assembler
{ HEX: 64410003 } [ 1 2 3 ORIS ] test-assembler
{ HEX: 7c411b78 } [ 1 2 3 OR ] test-assembler
{ HEX: 7c411378 } [ 1 2 MR ] test-assembler
{ HEX: 7c221896 } [ 1 2 3 MULHW ] test-assembler
{ HEX: 1c220003 } [ 1 2 3 MULLI ] test-assembler
{ HEX: 7c221816 } [ 1 2 3 MULHWU ] test-assembler
{ HEX: 7c2219d6 } [ 1 2 3 MULLW ] test-assembler
{ HEX: 7c411830 } [ 1 2 3 SLW ] test-assembler
{ HEX: 7c411e30 } [ 1 2 3 SRAW ] test-assembler
{ HEX: 7c411c30 } [ 1 2 3 SRW ] test-assembler
{ HEX: 7c411e70 } [ 1 2 3 SRAWI ] test-assembler
{ HEX: 7c221850 } [ 1 2 3 SUBF ] test-assembler
{ HEX: 7c221810 } [ 1 2 3 SUBFC ] test-assembler
{ HEX: 7c221910 } [ 1 2 3 SUBFE ] test-assembler
{ HEX: 7c410774 } [ 1 2 EXTSB ] test-assembler
{ HEX: 68410003 } [ 1 2 3 XORI ] test-assembler
{ HEX: 7c411a78 } [ 1 2 3 XOR ] test-assembler
{ HEX: 7c2200d0 } [ 1 2 NEG ] test-assembler
{ HEX: 2c220003 } [ 1 2 3 CMPI ] test-assembler
{ HEX: 28220003 } [ 1 2 3 CMPLI ] test-assembler
{ HEX: 7c411800 } [ 1 2 3 CMP ] test-assembler
{ HEX: 5422190a } [ 1 2 3 4 5 RLWINM ] test-assembler
{ HEX: 54221838 } [ 1 2 3 SLWI ] test-assembler
{ HEX: 5422e8fe } [ 1 2 3 SRWI ] test-assembler
{ HEX: 88220003 } [ 1 2 3 LBZ ] test-assembler
{ HEX: 8c220003 } [ 1 2 3 LBZU ] test-assembler
{ HEX: a8220003 } [ 1 2 3 LHA ] test-assembler
{ HEX: ac220003 } [ 1 2 3 LHAU ] test-assembler
{ HEX: a0220003 } [ 1 2 3 LHZ ] test-assembler
{ HEX: a4220003 } [ 1 2 3 LHZU ] test-assembler
{ HEX: 80220003 } [ 1 2 3 LWZ ] test-assembler
{ HEX: 84220003 } [ 1 2 3 LWZU ] test-assembler
{ HEX: 7c4118ae } [ 1 2 3 LBZX ] test-assembler
{ HEX: 7c4118ee } [ 1 2 3 LBZUX ] test-assembler
{ HEX: 7c411aae } [ 1 2 3 LHAX ] test-assembler
{ HEX: 7c411aee } [ 1 2 3 LHAUX ] test-assembler
{ HEX: 7c411a2e } [ 1 2 3 LHZX ] test-assembler
{ HEX: 7c411a6e } [ 1 2 3 LHZUX ] test-assembler
{ HEX: 7c41182e } [ 1 2 3 LWZX ] test-assembler
{ HEX: 7c41186e } [ 1 2 3 LWZUX ] test-assembler
{ HEX: 48000001 } [ 1 B ] test-assembler
{ HEX: 48000001 } [ 1 BL ] test-assembler
{ HEX: 41800004 } [ 1 BLT ] test-assembler
{ HEX: 41810004 } [ 1 BGT ] test-assembler
{ HEX: 40810004 } [ 1 BLE ] test-assembler
{ HEX: 40800004 } [ 1 BGE ] test-assembler
{ HEX: 41800004 } [ 1 BLT ] test-assembler
{ HEX: 40820004 } [ 1 BNE ] test-assembler
{ HEX: 41820004 } [ 1 BEQ ] test-assembler
{ HEX: 41830004 } [ 1 BO ] test-assembler
{ HEX: 40830004 } [ 1 BNO ] test-assembler
{ HEX: 4c200020 } [ 1 BCLR ] test-assembler
{ HEX: 4e800020 } [ BLR ] test-assembler
{ HEX: 4e800021 } [ BLRL ] test-assembler
{ HEX: 4c200420 } [ 1 BCCTR ] test-assembler
{ HEX: 4e800420 } [ BCTR ] test-assembler
{ HEX: 7c6102a6 } [ 3 MFXER ] test-assembler
{ HEX: 7c6802a6 } [ 3 MFLR ] test-assembler
{ HEX: 7c6902a6 } [ 3 MFCTR ] test-assembler
{ HEX: 7c6103a6 } [ 3 MTXER ] test-assembler
{ HEX: 7c6803a6 } [ 3 MTLR ] test-assembler
{ HEX: 7c6903a6 } [ 3 MTCTR ] test-assembler
{ HEX: 7c6102a6 } [ 3 MFXER ] test-assembler
{ HEX: 7c6802a6 } [ 3 MFLR ] test-assembler
{ HEX: c0220003 } [ 1 2 3 LFS ] test-assembler
{ HEX: c4220003 } [ 1 2 3 LFSU ] test-assembler
{ HEX: c8220003 } [ 1 2 3 LFD ] test-assembler
{ HEX: cc220003 } [ 1 2 3 LFDU ] test-assembler
{ HEX: d0220003 } [ 1 2 3 STFS ] test-assembler
{ HEX: d4220003 } [ 1 2 3 STFSU ] test-assembler
{ HEX: d8220003 } [ 1 2 3 STFD ] test-assembler
{ HEX: dc220003 } [ 1 2 3 STFDU ] test-assembler
{ HEX: fc201048 } [ 1 2 FMR ] test-assembler
{ HEX: fc20101e } [ 1 2 FCTIWZ ] test-assembler
{ HEX: fc22182a } [ 1 2 3 FADD ] test-assembler
{ HEX: fc22182b } [ 1 2 3 FADD. ] test-assembler
{ HEX: fc221828 } [ 1 2 3 FSUB ] test-assembler
{ HEX: fc2200f2 } [ 1 2 3 FMUL ] test-assembler
{ HEX: fc221824 } [ 1 2 3 FDIV ] test-assembler
{ HEX: fc20102c } [ 1 2 FSQRT ] test-assembler
{ HEX: fc411800 } [ 1 2 3 FCMPU ] test-assembler
{ HEX: fc411840 } [ 1 2 3 FCMPO ] test-assembler
{ HEX: 3c601234 HEX: 60635678 } [ HEX: 12345678 3 LOAD ] test-assembler
