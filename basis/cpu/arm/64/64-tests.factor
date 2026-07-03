! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.instructions compiler.codegen.gc-maps
compiler.codegen.relocation cpu.architecture kernel locals make
math namespaces sequences tools.test vectors ;
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

! A GC map for a C call is keyed by the address execution resumes at,
! immediately after BLR. The branch and inline dlsym literal pool come later.
{ t t } [
    0 alien-call-code+return-address
    B{ 0x20 0x03 0x3f 0xd6 } return-address-follows? ! BLR X25

    16 alien-call-code+return-address
    B{ 0x40 0x03 0x3f 0xd6 } return-address-follows? ! BLR X26
] unit-test
