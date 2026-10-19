! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.build-stack-frame compiler.cfg.stack-frame compiler.cfg.instructions compiler.cfg.utilities compiler.cfg.comparisons sequences byte-arrays cpu.architecture cpu.sparc kernel layouts make namespaces
system tools.test ;
IN: cpu.sparc.tests

: emit32 ( quot -- bytes )
    4 \ cell [ sparc.32 \ cpu [ B{ } make ] with-variable ] with-variable ; inline
: emit64 ( quot -- bytes )
    8 \ cell [ sparc.64 \ cpu [ B{ } make ] with-variable ] with-variable ; inline

{ B{ 0xa0 0x04 0x40 0x12 } } [ [ 16 17 18 %add ] emit32 ] unit-test
{ B{ 0xa0 0x14 0x60 0x00 } } [ [ 16 17 int-rep %copy ] emit32 ] unit-test
{ B{ 0xa0 0x3c 0x60 0x00 } } [ [ 16 17 %not ] emit32 ] unit-test
{ B{ 0xa1 0x2c 0x70 0x3f } } [ [ 16 17 63 %shl-imm ] emit64 ] unit-test
{ B{ 0xa1 0x2c 0x50 0x12 } } [ [ 16 17 18 %shl ] emit64 ] unit-test
{ B{ 0x9d 0xe3 0xbf 0xa0 } } [ [ 96 %prologue ] emit32 ] unit-test
{ B{ 0x9d 0xe3 0xbf 0x50 } } [ [ 176 %prologue ] emit64 ] unit-test
{ B{ 0x81 0xe8 0x00 0x00 } } [ [ 96 %epilogue ] emit32 ] unit-test
{ B{ 0x81 0xc3 0xe0 0x08 0x01 0x00 0x00 0x00 } }
[ [ %return ] emit32 ] unit-test

! Every floating comparison must select its SPARC FCC branch encoding.
{ { 4 13 6 11 9 2 15 12 5 14 3 1 10 7 } }
[ { cc< cc<= cc> cc>= cc= cc<> cc<>= cc/< cc/<= cc/> cc/>= cc/= cc/<> cc/<>= }
  [ float-condition ] map ] unit-test

! Nonempty leaf words still need their own local/input register window.
{ 96 } [
    4 \ cell [ sparc.32 \ cpu [
        { T{ ##load-integer f 0 100 } } insns>cfg dup build-stack-frame stack-frame>> total-size>>
    ] with-variable ] with-variable
] unit-test
{ 176 } [
    8 \ cell [ sparc.64 \ cpu [
        { T{ ##load-integer f 0 100 } } insns>cfg dup build-stack-frame stack-frame>> total-size>>
    ] with-variable ] with-variable
] unit-test
