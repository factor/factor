! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.stack-frame compiler.codegen.labels compiler.codegen.relocation
compiler.constants arrays hashtables cpu.architecture cpu.mips cpu.mips.assembler
cpu.mips.assembler.registers kernel make namespaces sequences system tools.test vectors ;
IN: cpu.mips.tests

: code32 ( quot -- bytes ) mipsel.32 \ cpu [ f mips-big-endian? [ B{ } make ] with-variable ] with-variable ; inline
: code64 ( quot -- bytes ) mipsel.64 \ cpu [ f mips-big-endian? [ B{ } make ] with-variable ] with-variable ; inline

! GNU as: addiu/daddiu v0,zero,32767 and -32768. Relocation
! templates continue using the fixed LI32/LI64 sequences.
{ B{ 255 127 2 36 } } [ [ V0 32767 %load-immediate ] code32 ] unit-test
{ B{ 0 128 2 36 } } [ [ V0 -32768 %load-immediate ] code32 ] unit-test
{ B{ 255 127 2 100 } } [ [ V0 32767 %load-immediate ] code64 ] unit-test
{ B{ 0 128 2 100 } } [ [ V0 -32768 %load-immediate ] code64 ] unit-test

{ B{ 33 16 133 0 } } [ [ V0 A0 A1 %add ] code32 ] unit-test
{ B{ 45 16 133 0 } } [ [ V0 A0 A1 %add ] code64 ] unit-test
{ B{ 24 0 133 0 18 16 0 0 } } [ [ V0 A0 A1 %mul ] code32 ] unit-test
{ B{ 28 0 133 0 18 16 0 0 } } [ [ V0 A0 A1 %mul ] code64 ] unit-test
{ B{ 60 16 4 0 } } [ [ V0 A0 32 %shl-imm ] code64 ] unit-test
{ B{ 191 23 4 0 } } [ [ V0 A0 62 %sar-imm ] code64 ] unit-test
{ B{ 37 192 128 0 2 0 25 139 255 255 25 155 37 16 32 3 } } [ [ V0 A0 -1 int-rep f %load-memory-imm ] code32 ] unit-test
{ B{ 37 192 128 0 6 0 25 107 255 255 25 111 37 16 32 3 } } [ [ V0 A0 -1 int-rep f %load-memory-imm ] code64 ] unit-test
{ B{ 0 16 132 68 161 16 128 70 } } [ [ F2 A0 %integer>float ] code32 ] unit-test
{ B{ 0 16 164 68 161 16 160 70 } } [ [ F2 A0 %integer>float ] code64 ] unit-test
{ B{ 0 16 36 70 } } [ [ F0 F2 F4 %add-float ] code64 ] unit-test
{ 16 } [ [ init-relocation V{ } clone label-table set <label> %jump-label ] code32 length ] unit-test
{ 36 } [ [ init-relocation V{ } clone label-table set <label> %jump-label ] code64 length ] unit-test
! Store outgoing stack arguments before assigning N64 a4/a5. Scratch t0/t1
! alias those native parameter registers and must not overwrite their values.
! GNU MIPS64EL oracle: move a5,a7; move t8,sp; move t9,a5;
! sdl t9,7(t8); sdr t9,0(t8); move a4,t0.
{ B{ 37 72 96 1 37 192 160 3 37 200 32 1 7 0 25 179 0 0 25 183 37 64 128 1 } } [
    [
        f R12 int-rep R8 3array 1array R11 int-rep 0 8 4array 1array
        { } { } 0 32 [ ] %alien-assembly
    ] code64
] unit-test

! Both Factor callee headers and the primary native gate put caller SP
! 16 bytes above their linked FP. Root zero must address caller SP.
: first-root-offset ( -- n )
    f f <basic-block> <cfg>
    T{ stack-frame { spill-area-base 0 } } >>stack-frame cfg [
        0 <spill-slot> gc-root-offset
    ] with-variable ;
{ 4 } [ mipsel.32 \ cpu [ first-root-offset ] with-variable ] unit-test
{ 2 } [ mipsel.64 \ cpu [ first-root-offset ] with-variable ] unit-test
! An 80-byte outgoing argument area links its alternate FP at SP+48.
! Relative to primary FP=SP-16, move roots down by 64 bytes.
: alternate-root-offset ( -- n )
    <gc-map> 64 <spill-slot> 1array >>gc-roots H{ } clone >>derived-roots
    80 stack-call-gc-map gc-roots>> first n>> ;
{ 0 } [ mipsel.32 \ cpu [ alternate-root-offset ] with-variable ] unit-test
{ 0 } [ mipsel.64 \ cpu [ alternate-root-offset ] with-variable ] unit-test
