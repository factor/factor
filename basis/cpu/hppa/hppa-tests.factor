! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays compiler.cfg.instructions cpu.architecture cpu.hppa
cpu.hppa.assembler.registers kernel layouts make namespaces sequences system tools.test vectors compiler.codegen.labels compiler.codegen.relocation ;
IN: cpu.hppa.tests
USING: alien.accessors arrays compiler.cfg.intrinsics words ;
! A refreshed saved image may retain the old unsafe accessor properties.
{ { f f f f } } [
    enable-alien-4-intrinsics
    hppa.32 \ cpu [ enable-cpu-features ] with-variable
    { alien-signed-4 alien-unsigned-4 set-alien-signed-4 set-alien-unsigned-4 }
    [ "intrinsic" word-prop ] map
    enable-cpu-features
] unit-test
: code32 ( quot -- bytes )
    hppa.32 \ cpu [ 4 \ cell [
        init-relocation V{ } clone label-table set
        B{ } make label-table get compute-labels drop
    ] with-variable ] with-variable ; inline
{ B{ 0x08 0xa4 0x06 0x06 } } [ [ R6 R4 R5 %add ] code32 ] unit-test
{ B{ 0x08 0xa4 0x04 0x06 } } [ [ R6 R4 R5 %sub ] code32 ] unit-test
{ B{ 0x34 0x86 0x3f 0xad } } [ [ R6 R4 -42 %add-imm ] code32 ] unit-test
{ B{ 0xd0 0x86 0x1b 0x45 } } [ [ R6 R4 5 %shr-imm ] code32 ] unit-test
{ B{ 0xd0 0x86 0x1f 0x45 } } [ [ R6 R4 5 %sar-imm ] code32 ] unit-test
{ B{ 0x48 0xa6 0x00 0x0c } } [ [ R6 R5 2 2 %slot-imm ] code32 ] unit-test
{ B{ 0x68 0xa6 0x00 0x0c } } [ [ R6 R5 2 2 %set-slot-imm ] code32 ] unit-test
{ 24 } [ [ 20000 %prologue ] code32 length ] unit-test
{ B{ 0x4a 0x42 0x00 0x08 0x4a 0x52 0x00 0x00 } } [ [ 32 %epilogue ] code32 ] unit-test
! NaN adapters surround the native finite arithmetic instruction.
{ B{ 0x30 0x86 0x0e 0x06 } } [
    480 484 [ F6 F4 F5 %add-float ] code32 subseq
] unit-test
USING: compiler.cfg.comparisons ;
{ B{ 0x80 0xa4 0x40 0x18 0x08 0x00 0x02 0x40
      0x34 0x06 0x00 0x00 0xe8 0x00 0x00 0x08
      0x08 0x00 0x02 0x40 0x34 0x06 0x00 0x02 } } [
    [ R6 R4 R5 cc< compare-bit ] code32
] unit-test
{ B{ 0x08 0x04 0x02 0x46 } } [ [ R6 R4 int-rep %copy ] code32 ] unit-test
{ B{ 0x34 0x14 0x00 0x3e 0x08 0xb4 0x04 0x14
      0x01 0x74 0x18 0x40 0xd4 0xc4 0x00 0x00 } } [
    [ R6 R4 R5 %shl ] code32
] unit-test
{ 12 } [ [ F8 R26 %integer>float ] code32 length ] unit-test
{ 252 } [ [ R28 F8 %float>integer ] code32 length ] unit-test
{ 28 } [ [ R28 R26 R25 %mul ] code32 length ] unit-test
{ B{ 0x30 0x86 0x0c 0x17 0x30 0x00 0x24 0x20
      0xe8 0x00 0x00 0x08 0x34 0x1c 0x00 0x02 0x34 0x1c 0x00 0x00 } } [
    [ R28 F5 F7 cc< float-bit ] code32 480 tail
] unit-test
! Quiet ordered predicates retain NaN-false results without the signaling bit.
{ B{ 0x30 0x86 0x0c 0x16 0x30 0x00 0x24 0x20
      0xe8 0x00 0x00 0x08 0x34 0x1c 0x00 0x02 0x34 0x1c 0x00 0x00 } } [
    [ R28 F5 F7 cc< t float-bit-mode ] code32 480 tail
] unit-test
{ 32 } [ [ R28 R26 R25 add-overflow ] code32 length ] unit-test
{ 24 } [ [ R28 R26 R25 sub-overflow ] code32 length ] unit-test
{ 28 } [ [ F8 1.25 %load-double ] code32 length ] unit-test
[ [ R28 R26 0 8 f integer-load ] code32 ] [ unsupported-hppa-memory-width? ] must-fail-with
USING: arrays ;
! Argument sources r25/r26 deliberately form a physical-register swap.
{ 32 } [
    [ f R25 int-rep R26 3array R26 int-rep R25 3array 2array
      { } { } { } 0 16 [ ] %alien-assembly ] code32 length
] unit-test
{ -40 -48 -36 -52 } [
    F5 double-rep argument-home F7 double-rep argument-home
    R26 int-rep argument-home R22 int-rep argument-home
] unit-test
USING: compiler.codegen.relocation ;
{ 32 } [
    [ init-relocation R28 int-rep R26 3array 1array { } %callback-inputs ] code32 length
] unit-test
{ B{ 0x08 0x06 0x02 0x57 } } [
    [ R23 int-rep R28 load-callback-input ] code32
] unit-test
{ 40 } [
    [ init-relocation R23 int-rep R28 3array 1array %callback-outputs ] code32 length
] unit-test
{ 4 } [ [ R28 R26 %unbox-alien ] code32 length ] unit-test
{ 156 } [
    [ init-relocation V{ } clone label-table set R28 R26 %unbox-any-c-ptr ] code32 length
] unit-test
{ t { } -16 } [
    hppa.32 \ cpu [
        init-relocation V{ } clone label-table set
        [ <label> dup %jump-label resolve-label ] B{ } make drop
        rc-native-0 rc-absolute? label-table get compute-labels literal-table get first
    ] with-variable
] unit-test
