! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays compiler.cfg.instructions cpu.architecture cpu.m88k
cpu.m88k.assembler.registers kernel make namespaces sequences system tools.test ;
IN: cpu.m88k.tests
: code32 ( quot -- bytes ) m88k.32 \ cpu [ B{ } make ] with-variable ; inline
{ B{ 0xf4 0xc4 0x60 5 } } [ [ R6 R4 R5 %add ] code32 ] unit-test
{ B{ 0xf4 0xc4 0x64 5 } } [ [ R6 R4 R5 %sub ] code32 ] unit-test
{ B{ 0x64 0xc4 0 42 } } [ [ R6 R4 -42 %add-imm ] code32 ] unit-test
{ B{ 0x60 0xc4 0 42 } } [ [ R6 R4 -42 %sub-imm ] code32 ] unit-test
{ B{ 0x5c 0xc0 0xff 0xff 0x58 0xc6 0xff 0xff } }
[ [ R6 -1 %load-immediate ] code32 ] unit-test
{ B{ 0x14 0xc5 0 6 } } [ [ R6 R5 2 2 %slot-imm ] code32 ] unit-test
{ B{ 0x24 0xc5 0 6 } } [ [ R6 R5 2 2 %set-slot-imm ] code32 ] unit-test
{ B{ 0xf6 0x80 0x58 0x1f 0x67 0xff 0 32
      0x26 0x9f 0 0 0x24 0x3f 0 4 } }
[ [ 32 %prologue ] code32 ] unit-test
{ B{ 0x14 0x3f 0 4 0x17 0xff 0 0 } }
[ [ 32 %epilogue ] code32 ] unit-test
{ B{ 0xf4 0xc0 0x58 4 } } [ [ R6 R4 int-rep %copy ] code32 ] unit-test
{ B{ 0xf5 0x80 0x58 0x0a 0xf5 0xa0 0x58 0x0b } }
[ [ R12 R10 double-rep %copy ] code32 ] unit-test
{ B{ 0x85 0x8a 0x2a 0xac } }
[ [ R12 R10 R12 %add-float ] code32 ] unit-test
{ t } [ m88k.32 \ cpu [ -65535 immediate-arithmetic? ] with-variable ] unit-test
{ f } [ m88k.32 \ cpu [ -65536 immediate-arithmetic? ] with-variable ] unit-test
USING: compiler.cfg.comparisons ;
{ B{ 0xf4 0xc4 0x6c 5 } } [ [ R6 R4 R5 %mul ] code32 ] unit-test
{ B{ 0xf0 0xc4 0x90 5 } } [ [ R6 R4 5 %sar-imm ] code32 ] unit-test
{ B{ 0xf6 0x84 0x7c 5 0xd8 0xd4 0 4
      0x5c 0xc0 0 0 0x58 0xc6 0 0 0xc0 0 0 3
      0x5c 0xc0 0 0 0x58 0xc6 0 1 } }
[ [ R6 R4 R5 cc< compare-bit ] code32 ] unit-test
USING: alien.c-types ;
{ 44 } [ [ R2 R2 1 int-rep uint %load-memory-imm ] code32 length ] unit-test
{ 28 } [ [ R2 R2 1 int-rep short %load-memory-imm ] code32 length ] unit-test
{ 36 } [ [ R3 R2 1 int-rep uint %store-memory-imm ] code32 length ] unit-test
USING: accessors compiler.cfg compiler.cfg.stack-frame compiler.codegen.gc-maps ;
{ 12 12 0 } [
    T{ cfg { stack-frame T{ stack-frame { spill-area-base 32 } } } } cfg [
        m88k.32 \ cpu [
            T{ gc-map { gc-roots { T{ spill-slot { n 0 } } } } }
            dup gc-roots>> first gc-root-offset swap
            dup safepoint-gc-map gc-roots>> first gc-root-offset swap
            gc-roots>> first n>>
        ] with-variable
    ] with-variable
] unit-test
{ 36 } [ [ R2 R2 R3 add-overflow ] code32 length ] unit-test
USING: assocs ;
{ 12 13 12 0 4 } [
    T{ cfg { stack-frame T{ stack-frame { spill-area-base 32 } } } } cfg [
        m88k.32 \ cpu [
            T{ gc-map
                { gc-roots { T{ spill-slot { n 0 } } } }
                { derived-roots { { T{ spill-slot { n 4 } } T{ spill-slot { n 0 } } } } }
            } [ safepoint-gc-map
                [ gc-roots>> first gc-root-offset ]
                [ derived-roots>> first first gc-root-offset ]
                [ derived-roots>> first second gc-root-offset ] tri
            ] [ [ gc-roots>> first n>> ]
                [ derived-roots>> first first n>> ] bi ] bi
        ] with-variable
    ] with-variable
] unit-test
{ f } [ m88k.32 \ cpu [ f safepoint-gc-map ] with-variable ] unit-test
USING: layouts ;
{ B{ 0x14 0x50 0 16 0x60 0x42 0 128 } }
[ 4 \ cell [ [ R2 %callback-stack ] code32 ] with-variable ] unit-test
{ 24 } [ [ R2 R2 R3 sub-overflow ] code32 length ] unit-test
{ 136 } [ [ R2 R2 R3 mul-overflow ] code32 length ] unit-test
[ [ R2 R3 0 int-rep longlong %load-memory-imm ] code32 ]
[ unsupported-m88k-memory-width? ] must-fail-with
USING: compiler.codegen.labels compiler.codegen.relocation vectors ;
{ B{ 0x3f 0xf4 0 0 0 0 0 0 } } [
    init-relocation V{ } clone label-table set V{ } clone binary-literal-table set
    [ R10 1.25 %load-double ] code32 drop
    binary-literal-table get first first
] unit-test
{ B{ 0x3f 0xa0 0 0 } } [
    init-relocation V{ } clone label-table set V{ } clone binary-literal-table set
    [ R10 1.25 %load-float ] code32 drop
    binary-literal-table get first first
] unit-test
