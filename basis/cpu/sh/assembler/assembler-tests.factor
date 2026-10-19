USING: byte-arrays endian cpu.sh.assembler kernel layouts make namespaces tools.test ;
IN: cpu.sh.assembler.tests
: little-code ( quot -- bytes ) [ B{ } make ] curry f sh-big-endian? rot with-variable ; inline
: big-code ( quot -- bytes ) [ B{ } make ] curry t sh-big-endian? rot with-variable ; inline
{ B{ 0x2a 0xe0 0x0b 0x00 0x09 0x00 } } [ [ 42 0 MOVI RTS NOP ] little-code ] unit-test
{ B{ 0xe0 0x2a 0x00 0x0b 0x00 0x09 } } [ [ 42 0 MOVI RTS NOP ] big-code ] unit-test
{ B{ 0x13 0x62 0x1c 0x32 0x02 0xa0 0x09 0x00 } }
[ [ 1 2 MOV 1 2 ADD 8 BRA NOP ] little-code ] unit-test
{ B{ 0x12 0x62 0x22 0x21 0x26 0x4f 0x22 0x4f } }
[ [ 1 2 MOV.L 2 1 STORE.L 15 LDS.L-PR 15 STS.L-PR ] little-code ] unit-test
{ B{ 0x12 0xf2 0x4d 0xf2 0x6a 0x40 } }
[ [ 1 2 FMUL 2 FNEG 0 LDS-FPSCR ] little-code ] unit-test
{ B{ 0x02 0xd0 0x13 0x52 0x23 0x11 } }
[ [ 8 0 LOAD-PC.L 1 12 2 LOAD-DISP.L 2 1 12 STORE-DISP.L ] little-code ] unit-test
[ [ 128 0 MOVI ] little-code ] [ invalid-sh-immediate? ] must-fail-with
[ [ 0 16 MOV ] little-code ] [ invalid-sh-register? ] must-fail-with
[ [ 7 BRA ] little-code ] [ invalid-sh-displacement? ] must-fail-with
[ [ 4099 BRA ] little-code ] [ invalid-sh-displacement? ] must-fail-with
[ [ 4100 BRA ] little-code ] [ invalid-sh-immediate? ] must-fail-with
[ [ -4 0 LOAD-PC.L ] little-code ] [ invalid-sh-immediate? ] must-fail-with
