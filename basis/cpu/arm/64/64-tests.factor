! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.data arrays byte-arrays compiler.cfg
compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.registers
compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.test
cpu.architecture cpu.arm.64 cpu.arm.64.assembler.registers kernel
kernel.private locals make math math.vectors math.vectors.simd namespaces
sequences system tools.test vectors ;
IN: cpu.arm.64.tests

! Extra shuffle indices are ignored after filling the destination vector.
{ int-4{ 5 6 7 8 } } [
    int-4{ 1 2 3 4 } int-4{ 5 6 7 8 }
    [ { int-4 int-4 } declare
      { 4 5 6 7 0 1 2 3 } vshuffle2-elements ] compile-call
] unit-test

{ double-2{ 4.0 1.0 } } [
    double-2{ 1.0 2.0 } double-2{ 3.0 4.0 }
    [ { double-2 double-2 } declare
      { 7 4 0 1 } vshuffle2-elements ] compile-call
] unit-test

! Public entry points must retain vector operations after specialization.
{ t } [ [ { int-4 int-4 } declare vmul-wide ] [ ##mul-wide-vector? ] contains-insn? ] unit-test
{ t } [ [ { int-4 int-4 } declare vabsdiff ] [ ##binary-vector-function? ] contains-insn? ] unit-test
{ t } [ [ { float-4 float-4 float-4 } declare vfma ] [ ##fma-vector? ] contains-insn? ] unit-test
{ t } [ [ { uint-4 int-4 } declare vshift ] [ ##binary-vector-function? ] contains-insn? ] unit-test

{ uint-4{ 0xa8800000 0xa8800000 0xa8800000 0xa8800000 } } [
    float-4{ 1.0000001192092896 1.0000001192092896 1.0000001192092896 1.0000001192092896 }
    float-4{ 0.9999998807907104 0.9999998807907104 0.9999998807907104 0.9999998807907104 }
    float-4{ -1 -1 -1 -1 }
    [ { float-4 float-4 float-4 } declare vfma uint-4-cast ] compile-call
] unit-test

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

:: write-barrier-imm-code ( slot -- code )
    init-relocation
    [ X0 slot 0 X1 X2 %write-barrier-imm ] B{ } make ;

:: inc-code ( n -- code )
    init-relocation [ n <ds-loc> %inc ] B{ } make ;

:: mul-imm-code ( n -- code )
    init-relocation [ X0 X1 n %mul-imm ] B{ } make ;

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

! Callback loads first recover the native stack saved by CALLBACK-STUB.
{ 12 20 } [
    0x10000 stack-param-store-code length
    0x10000 stack-param-load-code length
] unit-test

! Keep using scaled immediate operands whenever they fit.
{ 8 12 } [
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

! Large tuple slot offsets need the same address materialization.
{ 32 36 } [
    512 write-barrier-imm-code length
    513 write-barrier-imm-code length
] unit-test

! Generated stack effects can exceed the immediate adjustment range.
{ 4 8 8 } [
    512 inc-code length
    513 inc-code length
    -513 inc-code length
] unit-test

! Representation lowering emits negative multiply immediates for tagged negation.
{ 8 8 } [
    100 mul-imm-code length
    -16 mul-imm-code length
] unit-test

cpu arm.64? [
    ! EXT only has a four-bit byte offset. Handle the identity and zero cases
    ! without emitting the out-of-range offsets 16 or greater.
    {
        char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        char-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
        char-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
        char-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
        char-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
    } [
        char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { char-16 } declare 0 hlshift ] compile-call
        char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { char-16 } declare 16 hlshift ] compile-call
        char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { char-16 } declare 17 hlshift ] compile-call
        char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { char-16 } declare 16 hrshift ] compile-call
        char-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { char-16 } declare 17 hrshift ] compile-call
    ] unit-test

    ! Lane shifts use the element width as their immediate boundary.
    {
        uchar-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        uchar-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
        uchar-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
        uchar-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        uchar-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
        char-16{ -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 }
    } [
        uchar-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { uchar-16 } declare 0 vlshift ] compile-call
        uchar-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { uchar-16 } declare 8 vlshift ] compile-call
        uchar-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { uchar-16 } declare 9 vlshift ] compile-call
        uchar-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { uchar-16 } declare 0 vrshift ] compile-call
        uchar-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
        [ { uchar-16 } declare 9 vrshift ] compile-call
        char-16{ -1 1 -2 2 -3 3 -4 4 -5 5 -6 6 -7 7 -8 8 }
        [ { char-16 } declare 9 vrshift ] compile-call
    ] unit-test

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

! SIMD coverage regressions: dynamic inputs keep these checks on the native path.
{ uchar-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } } [
    uchar-16{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 } 0x100000000
    [ { uchar-16 fixnum } declare vlshift ] compile-call
] unit-test

{ char-16{ -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 } } [
    char-16{ -1 1 -2 2 -3 3 -4 4 -5 5 -6 6 -7 7 -8 8 } 256
    [ { char-16 fixnum } declare vrshift ] compile-call
] unit-test

{ int-4{ 127 -128 5 6 } } [
    int-4{ 5 6 127 -128 }
    [ { int-4 } declare { 2 3 0 1 } vshuffle-elements ] compile-call
] unit-test

{ double-2{ 4.0 1.0 } } [
    double-2{ 1.0 2.0 } double-2{ 3.0 4.0 }
    [ { double-2 double-2 } declare { 3 0 } vshuffle2-elements ] compile-call
] unit-test

{ short-8{ 32767 -32768 6 -6 32767 -32768 6 -6 } } [
    short-8{ 32767 -32768 2 -2 32767 -32768 2 -2 }
    short-8{ 2 2 3 3 2 2 3 3 }
    [ { short-8 short-8 } declare vs* ] compile-call
] unit-test

{ 4080 } [
    uchar-16{ 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 }
    uchar-16{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
    [ { uchar-16 uchar-16 } declare vsad ] compile-call
] unit-test

{ longlong-2{ 0 -6 } } [
    longlong-2{ 0x100000000 -2 } longlong-2{ 0x100000000 3 }
    [ { longlong-2 longlong-2 } declare v* ] compile-call
] unit-test

{ ulonglong-2{ 0xffffffffffffffff 0x8000000000000000 } } [
    ulonglong-2{ 0xffffffffffffffff 0xffffffffffffffff }
    ulonglong-2{ 0xffffffffffffffff 1 }
    [ { ulonglong-2 ulonglong-2 } declare vavg ] compile-call
] unit-test

{ int-4{ 2147483647 2147483647 2147483647 2147483647 } } [
    short-8{ -32768 -32768 -32768 -32768 -32768 -32768 -32768 -32768 }
    dup [ { short-8 short-8 } declare v*hs+ ] compile-call
] unit-test

{ int-4{ 32 0 1 1 } } [
    int-4{ -1 0 1 -2147483648 } [ { int-4 } declare vbit-count ] compile-call
] unit-test
{ int-4{ 0 32 31 0 } } [
    int-4{ -1 0 1 -2147483648 } [ { int-4 } declare vclz ] compile-call
] unit-test
{ int-4{ 0 32 0 31 } } [
    int-4{ -1 0 1 -2147483648 } [ { int-4 } declare vctz ] compile-call
] unit-test
{ int-4{ -1 0 -2147483648 1 } } [
    int-4{ -1 0 1 -2147483648 } [ { int-4 } declare vbit-reverse ] compile-call
] unit-test
{ longlong-2{ 64 63 } } [
    longlong-2{ 0 1 } [ { longlong-2 } declare vclz ] compile-call
] unit-test
{ uint-4{ 2 1 0 0 } } [
    uint-4{ 1 2 3 4 } int-4{ 1 -1 256 -256 }
    [ { uint-4 int-4 } declare vshift ] compile-call
] unit-test
{ longlong-2{ -1 0 } } [
    longlong-2{ -1 1 } longlong-2{ -256 256 }
    [ { longlong-2 longlong-2 } declare vshift ] compile-call
] unit-test
{ uint-4{ 4294967295 4294967295 0 3 } } [
    int-4{ -2147483648 2147483647 1 -2 } int-4{ 2147483647 -2147483648 1 1 }
    [ { int-4 int-4 } declare vabsdiff ] compile-call
] unit-test
{ longlong-2{ 4294967296 -6 } longlong-2{ 20 -42 } } [
    int-4{ 65536 -2 4 -6 } int-4{ 65536 3 5 7 }
    [ { int-4 int-4 } declare vmul-wide ] compile-call
] unit-test
{ float-4{ -2.0 -1.0 1.0 2.0 } float-4{ -2.0 -0.0 0.0 2.0 } } [
    float-4{ -1.5 -0.5 0.5 1.5 }
    [ { float-4 } declare dup vround swap vround-to-even ] compile-call
] unit-test
{ float-4{ -3.0 -1.0 0.0 2.0 } } [
    float-4{ -2.5 -0.5 0.5 2.5 } [ { float-4 } declare vfloor ] compile-call
] unit-test
{ float-4{ 5.0 10.0 17.0 26.0 } } [
    float-4{ 1 2 3 4 } float-4{ 2 3 4 5 } float-4{ 3 4 5 6 }
    [ { float-4 float-4 float-4 } declare vfma ] compile-call
] unit-test
