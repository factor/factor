USING: byte-arrays cpu.alpha.64.assembler
cpu.alpha.64.assembler.registers make tools.test ;
IN: cpu.alpha.64.assembler.tests

! GNU as -mev6: addt/suid $f1,$f2,$f3; cvtqt/suid $f1,$f2;
! sqrtt/suid $f1,$f2. The /i bit is required for inexact status.
{ B{ 0x03 0xfc 0x22 0x58 } } [ [ F3 F1 F2 ADDT ] B{ } make ] unit-test
{ B{ 0xc2 0xff 0xe1 0x5b } } [ [ F2 F1 CVTQT ] B{ } make ] unit-test
{ B{ 0x62 0xfd 0xe1 0x53 } } [ [ F2 F1 SQRTT ] B{ } make ] unit-test
{ B{ 0x00 0x04 0x00 0x60 } } [ [ EXCB ] B{ } make ] unit-test
