! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.data arrays byte-arrays compiler.cfg
compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.registers
compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.test
cpu.architecture cpu.arm.64 cpu.arm.64.assembler.registers kernel
kernel.private locals make math namespaces sequences system tools.test
vectors ;
IN: cpu.arm.64.tests

:: alien-call-code+return-address ( stack-size -- code return-address )
    init-relocation
    V{ } clone return-addresses set
    V{ } clone gc-maps set
    [
        f { } { } { } { } 0 stack-size { } "dll"
        T{ gc-map { gc-roots V{ 0 } } }
        %alien-invoke
    ] B{ } make
    return-addresses get first ;

:: alien-indirect-code+return-address ( stack-size -- code return-address )
    init-relocation
    V{ } clone return-addresses set
    V{ } clone gc-maps set
    [
        X0 f { } { } { } { } 0 stack-size
        T{ gc-map { gc-roots V{ 0 } } }
        %alien-indirect
    ] B{ } make
    return-addresses get first ;

:: return-address-follows? ( code return-address call-insn -- ? )
    code call-insn subseq-index 4 + return-address = ;

: alien-global-code ( -- code )
    init-relocation
    [ X0 "compiler-test-global" "compiler-test-library" %alien-global ]
    B{ } make ;

: large-spill-reload-code ( -- code )
    f f <basic-block> <cfg>
    [ stack-frame>> 0x10000 >>spill-area-base drop ] keep cfg set
    init-relocation
    [ X0 int-rep 0 <spill-slot> %reload ] B{ } make ;

: large-spill-store-code ( -- code )
    f f <basic-block> <cfg>
    [ stack-frame>> 0x10000 >>spill-area-base drop ] keep cfg set
    init-relocation
    [ X0 int-rep 0 <spill-slot> %spill ] B{ } make ;

: scaled-spill-reload-code ( -- code )
    f f <basic-block> <cfg>
    [ stack-frame>> 0x100 >>spill-area-base drop ] keep cfg set
    init-relocation
    [ X0 int-rep 0 <spill-slot> %reload ] B{ } make ;

: large-spill-from-temp-code ( -- code )
    f f <basic-block> <cfg>
    [ stack-frame>> 0x10000 >>spill-area-base drop ] keep cfg set
    init-relocation
    [ 0 <spill-slot> temp int-rep %copy ] B{ } make ;

:: stack-param-store-code ( n -- code )
    init-relocation
    [ X0 int-rep n %store-stack-param ] B{ } make ;

:: stack-param-load-code ( n -- code )
    init-relocation
    [ X0 int-rep n %load-stack-param ] B{ } make ;

:: local-allot-code ( offset -- code )
    f f <basic-block> <cfg>
    [ stack-frame>> 0 >>allot-area-base drop ] keep cfg set
    init-relocation
    [ X0 16 8 offset %local-allot ] B{ } make ;

:: prologue-code ( size -- code )
    init-relocation [ size %prologue ] B{ } make ;

:: epilogue-code ( size -- code )
    init-relocation [ size %epilogue ] B{ } make ;

:: allot-code ( size -- code )
    init-relocation [ X0 size array X1 %allot ] B{ } make ;

:: nursery-check-code ( size -- code )
    init-relocation [
        V{ } clone label-table set
        <label> :> done
        done size cc<= X0 X1 %check-nursery-branch
        done resolve-label
    ] B{ } make ;

! A GC map for a C call is keyed by the address execution resumes at,
! immediately after BLR. The branch and inline dlsym literal pool come later.
{ t t t t } [
    0 alien-call-code+return-address
    B{ 0x20 0x03 0x3f 0xd6 } return-address-follows? ! BLR X25

    16 alien-call-code+return-address
    B{ 0x40 0x03 0x3f 0xd6 } return-address-follows? ! BLR X26

    0x1020 alien-call-code+return-address
    B{ 0x40 0x03 0x3f 0xd6 } return-address-follows? ! BLR X26

    0x1020 alien-indirect-code+return-address
    B{ 0x40 0x03 0x3f 0xd6 } return-address-follows? ! BLR X26
] unit-test

! The LDR and branch are followed by an eight-byte dlsym literal.
{ 16 2 } [
    alien-global-code length
    parameter-table get length
] unit-test

! Large spill areas need a materialized register offset before access.
{ 8 8 } [
    large-spill-reload-code length
    large-spill-store-code length
] unit-test

! Preserve scaled immediate spills, and use temp2 if temp holds the value.
{ 4 B{ 0x2f 0x00 0xa0 0xd2 } } [
    scaled-spill-reload-code length
    large-spill-from-temp-code 4 head
] unit-test

! Integer FFI values occupy temp, so their large addresses use temp2.
{ 12 16 } [
    0x10000 stack-param-store-code length
    0x10000 stack-param-load-code length
] unit-test

! Keep using scaled immediate operands whenever they fit.
{ 8 8 } [
    0x100 stack-param-store-code length
    0x100 stack-param-load-code length
] unit-test

! Stack-local offsets are aligned, but not necessarily ADD immediates.
{ 4 8 } [
    0x1000 local-allot-code length
    0x1008 local-allot-code length
] unit-test

! Frame sizes are 16-byte aligned, which does not imply ADD encodability.
{ 12 16 8 12 } [
    0x1010 prologue-code length
    0x1020 prologue-code length
    0x1010 epilogue-code length
    0x1020 epilogue-code length
] unit-test

! Allot and its nursery check use the same potentially large size.
{ 24 28 20 24 } [
    0x1000 allot-code length
    0x1008 allot-code length
    0x1000 nursery-check-code length
    0x1010 nursery-check-code length
] unit-test

cpu arm.64? [
    ! Shifted add/sub immediates accepted by the optimizer can exceed a
    ! single MOVZ halfword when fused into an alien memory operation.
    { 0 } [
        0x100001 <byte-array>
        [ { byte-array } declare 0x100000 alien-unsigned-1 ] compile-call
    ] unit-test

    { 123 } [
        0x100001 <byte-array>
        dup 123 swap 0x100000 [
            { fixnum byte-array fixnum } declare
            set-alien-unsigned-1
        ] compile-call
        0x100000 alien-unsigned-1
    ] unit-test
] when
