! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.accessors alien.data byte-arrays compiler.cfg.instructions
compiler.codegen.gc-maps compiler.codegen.relocation compiler.test
cpu.architecture cpu.arm.64.assembler.registers kernel kernel.private
locals make math namespaces sequences system tools.test vectors ;
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

:: return-address-follows? ( code return-address call-insn -- ? )
    code call-insn subseq-index 4 + return-address = ;

: alien-global-code ( -- code )
    init-relocation
    [ X0 "compiler-test-global" "compiler-test-library" %alien-global ]
    B{ } make ;

! A GC map for a C call is keyed by the address execution resumes at,
! immediately after BLR. The branch and inline dlsym literal pool come later.
{ t t } [
    0 alien-call-code+return-address
    B{ 0x20 0x03 0x3f 0xd6 } return-address-follows? ! BLR X25

    16 alien-call-code+return-address
    B{ 0x40 0x03 0x3f 0xd6 } return-address-follows? ! BLR X26
] unit-test

! The LDR and branch are followed by an eight-byte dlsym literal.
{ 16 2 } [
    alien-global-code length
    parameter-table get length
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
