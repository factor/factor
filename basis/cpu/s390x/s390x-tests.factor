! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.test compiler.cfg.instructions sequences compiler.codegen.gc-maps compiler.codegen.relocation byte-arrays cpu.architecture cpu.s390x cpu.s390x.assembler.registers
compiler.cfg.builder.alien kernel make namespaces system tools.test ;
IN: cpu.s390x.tests
! Directly invoke target methods so these oracle tests run on a host CPU.
{ B{ 0xb9 0xe8 0x30 0x22 } } [
    [ R2 R2 R3 M\ s390x %add execute ] B{ } make
] unit-test
{ B{ 0xb9 0xe9 0x30 0x22 } } [
    [ R2 R2 R3 M\ s390x %sub execute ] B{ } make
] unit-test
! Destination overlapping the second operand must not lose the operand.
{ B{ 0xb9 0x04 0 0x02 0xb9 0x04 0 0x23 0xb9 0x0c 0 0x20 } } [
    [ R2 R3 R2 M\ s390x %mul execute ] B{ } make
] unit-test
{ B{ 0xeb 0x23 0 0x3f 0 0x0a } } [
    [ R2 R3 63 M\ s390x %sar-imm execute ] B{ } make
] unit-test
{ B{ 0xb9 0x04 0 0x23 } } [
    [ R2 R3 int-rep M\ s390x %copy execute ] B{ } make
] unit-test
{ B{ 0x28 0x02 } } [
    [ F0 F2 double-rep M\ s390x %copy execute ] B{ } make
] unit-test

! Nonzero outgoing argument areas reserve both Linux's 160-byte register
! save area and the walkable 16-byte header used by trampoline2.
{ 0 } [ 0 s390x insert-trampoline-area ] unit-test
{ 192 } [ 8 s390x insert-trampoline-area ] unit-test
{ 208 } [ 32 s390x insert-trampoline-area ] unit-test

{ 32 } [ 8 riscv.64 insert-trampoline-area ] unit-test
{ 8 } [ 8 x86.64 insert-trampoline-area ] unit-test

! Native calls resume at BASR's successor and preserve the live stack registers.
{ V{ 14 } 14 } [
    [
        init-relocation
        V{ } clone return-addresses set
        V{ } clone gc-maps set
        "box_signed_cell" f T{ gc-map { gc-roots { 0 } } }
        M\ s390x %c-invoke execute
        return-addresses get compiled-offset
    ] B{ } make drop
] unit-test
{ V{ 20 } 20 8 } [
    [
        init-relocation
        V{ } clone return-addresses set
        V{ } clone gc-maps set
        192 "box_signed_cell" f
        T{ gc-map { gc-roots { T{ spill-slot { n 200 } } } } }
        c-invoke-stack
        return-addresses get compiled-offset
        gc-maps get first gc-roots>> first n>>
    ] B{ } make drop
] unit-test

! Snapshot pointers agree with the 512-byte variadic callback frame.
{ { 368 56 160 } { -24 -16 } } [
    [ 1 16 3 2 emit-s390x-va-cursor-inputs ] V{ } make
    [ [ ##add-imm? ] filter [ src2>> ] map >array ]
    [ [ ##load-integer? ] filter [ val>> ] map >array ] bi
] cfg-unit-test
