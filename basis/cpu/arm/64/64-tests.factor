! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.data arrays byte-arrays compiler.cfg
compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.registers
compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.test
cpu.architecture cpu.arm.64 cpu.arm.64.assembler.registers kernel
kernel.private locals make math math.floats.env math.vectors math.vectors.conversion
math.vectors.simd math.vectors.simd.intrinsics namespaces sequences system tools.test vectors ;
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

! The low-level signed-pack intrinsic preserves the source representation's
! signedness, including the unsigned representations advertised by ARM64.
{ uchar-16{ 0 1 254 255 255 255 255 255 255 255 255 255 255 254 1 0 } } [
    ushort-8{ 0 1 254 255 256 32767 32768 65535 }
    ushort-8{ 65535 32768 32767 256 255 254 1 0 }
    [ { ushort-8 ushort-8 } declare [ underlying>> ] bi@
      ushort-8-rep (simd-vpack-signed) uchar-16 boa ] compile-call
] unit-test
{ ushort-8{ 65535 65535 65535 65535 0 1 65534 65535 } } [
    uint-4{ 2147483648 4294967295 65536 65535 }
    uint-4{ 0 1 65534 65535 }
    [ { uint-4 uint-4 } declare [ underlying>> ] bi@
      uint-4-rep (simd-vpack-signed) ushort-8 boa ] compile-call
] unit-test
{ uint-4{ 4294967295 4294967295 4294967294 4294967295 } } [
    ulonglong-2{ 9223372036854775808 18446744073709551615 }
    ulonglong-2{ 4294967294 4294967296 }
    [ { ulonglong-2 ulonglong-2 } declare [ underlying>> ] bi@
      ulonglong-2-rep (simd-vpack-signed) uint-4 boa ] compile-call
] unit-test
{ t } [
    [ { uint-4 uint-4 } declare [ underlying>> ] bi@
      uint-4-rep (simd-vpack-signed) ushort-8 boa ]
    [ ##signed-pack-vector? ] contains-insn?
] unit-test

! Public entry points must retain vector operations after specialization.
{ t } [ [ { int-4 int-4 } declare vmul-wide ] [ ##mul-wide-vector? ] contains-insn? ] unit-test
{ t } [ [ { int-4 int-4 } declare vabsdiff ] [ ##binary-vector-function? ] contains-insn? ] unit-test
{ t } [ [ { float-4 float-4 float-4 } declare vfma ] [ ##fma-vector? ] contains-insn? ] unit-test
{ t } [ [ { uint-4 int-4 } declare vshift ] [ ##binary-vector-function? ] contains-insn? ] unit-test

! Both halves must widen single-precision lanes, preserving the sign of zero
! and single subnormals. FCVTL's wrong precision bit instead reads half lanes.
{ t } [
    [ { float-4 } declare float-4 double-2 vconvert ]
    [ ##unpack-vector-head? ] contains-insn?
] unit-test
{ t } [
    [ { float-4 } declare float-4 double-2 vconvert ]
    [ ##unpack-vector-tail? ] contains-insn?
] unit-test
{ ulonglong-2{ 0x8000000000000000 0x36a0000000000000 }
  ulonglong-2{ 0x3ff0000020000000 0x7ff0000000000000 } } [
    uint-4{ 0x80000000 0x00000001 0x3f800001 0x7f800000 } float-4-cast
    [ { float-4 } declare float-4 double-2 vconvert
      [ ulonglong-2-cast ] bi@ ] compile-call
] unit-test

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
    [ X0 int-rep n 8 %store-stack-param ] B{ } make ;

:: stack-param-load-code ( n -- code )
    init-relocation
    [ X0 int-rep n 8 %load-stack-param ] B{ } make ;

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

! Signed conversions must agree with typed-array storage outside the signed
! lane range. A bare FCVTZS saturates rather than preserving the low bits.
{ int-4{ -2147483648 512 2147483392 -512 } } [
    float-4{ 2147483648 4294967808 -2147483904 -4294967808 }
    [ { float-4 } declare float-4 int-4 vconvert ] compile-call
] unit-test
{ int-4{ 2147483520 -2147483648 -1 1 } } [
    float-4{ 2147483520 -2147483648 -1.75 1.75 }
    [ { float-4 } declare float-4 int-4 vconvert ] compile-call
] unit-test
{ longlong-2{ -9223372036854775808 4096 } } [
    double-2{ 9223372036854775808 18446744073709555712 }
    [ { double-2 } declare double-2 longlong-2 vconvert ] compile-call
] unit-test
{ longlong-2{ 9223372036854773760 -4096 } } [
    double-2{ -9223372036854777856 -18446744073709555712 }
    [ { double-2 } declare double-2 longlong-2 vconvert ] compile-call
] unit-test

! Cover the c-type-based addressing path used by the memory backend too.
{ B{ 0x20 0x79 0xe2 0x3c } } [
    [ V0 X1 X2 4 0 float-4-rep f %load-memory ] B{ } make
    4 tail-slice >byte-array
] unit-test
{ B{ 0x20 0x79 0xa2 0x3c } } [
    [ V0 X1 X2 4 0 float-4-rep f %store-memory ] B{ } make
    4 tail-slice >byte-array
] unit-test

! These entry points previously fell back to scalar lane operations.
{ t } [ [ { longlong-2 longlong-2 } declare vmin ] [ ##min-vector? ] contains-insn? ] unit-test
{ t } [ [ { ulonglong-2 ulonglong-2 } declare vmax ] [ ##max-vector? ] contains-insn? ] unit-test
{ t } [ [ { float-4 } declare float-4 int-4 vconvert ] [ ##float>integer-vector? ] contains-insn? ] unit-test

! Signed ordering and unsigned ordering differ across the top lane bit.
{ longlong-2{ -9223372036854775808 -1 } longlong-2{ 9223372036854775807 0 } } [
    longlong-2{ -9223372036854775808 0 } longlong-2{ 9223372036854775807 -1 }
    [ { longlong-2 longlong-2 } declare [ vmin ] [ vmax ] 2bi ] compile-call
] unit-test
{ ulonglong-2{ 0 9223372036854775807 } ulonglong-2{ 18446744073709551615 9223372036854775808 } } [
    ulonglong-2{ 18446744073709551615 9223372036854775807 }
    ulonglong-2{ 0 9223372036854775808 }
    [ { ulonglong-2 ulonglong-2 } declare [ vmin ] [ vmax ] 2bi ] compile-call
] unit-test
{ int-4{ 0 0 0 0 } } [
    uint-4{ 0x7f800000 0xff800000 0x7fc00001 0xffc00001 } float-4-cast
    [ { float-4 } declare float-4 int-4 vconvert ] compile-call
] unit-test
{ int-4{ 0 0 0 0 } } [
    uint-4{ 0x00000001 0x807fffff 0x7f7fffff 0xff7fffff } float-4-cast
    [ { float-4 } declare float-4 int-4 vconvert ] compile-call
] unit-test

! Exercise every sign/exponent with several fraction patterns, including the
! boundaries at which shifts would wrap if only their low byte were considered.
: scalar-float>integer ( bytes rep -- bytes' ) (simd-v>integer) ;
: compiled-float>integer ( vector -- vector' )
    { float-4 } declare float-4 int-4 vconvert ;
{ t } [
    512 <iota> [ 23 shift uint-4{ 0 1 0x3fffff 0x7fffff } [ bitor ] with map >uint-4
        float-4-cast
        [ underlying>> float-4-rep scalar-float>integer ]
        [ compiled-float>integer underlying>> ] bi =
    ] all?
] unit-test
{ t } [
    4096 <iota> [
        1664525 * 1013904223 + 0xffffffff bitand
        uint-4{ 0 0x1fffff 0x55555555 0xffffffff } [ bitxor ] with map >uint-4 float-4-cast
        [ underlying>> float-4-rep scalar-float>integer ]
        [ compiled-float>integer underlying>> ] bi =
    ] all?
] unit-test

! Keep the portable binary64 conversion's exceptional behavior covered too.
{ longlong-2{ 0 0 } } [
    double-2{ 1/0. -1/0. }
    [ { double-2 } declare double-2 longlong-2 vconvert ] compile-call
] unit-test
{ longlong-2{ 0 0 } } [
    ulonglong-2{ 0x7ff8000000000001 0xfff0000000000001 } double-2-cast
    [ { double-2 } declare double-2 longlong-2 vconvert ] compile-call
] unit-test

! Constant (2^n + 1) multiplication selects a shifted ADD without a scratch.
{ B{ 32 4 1 139 } } [ [ X0 X1 3 %mul-imm ] B{ } make ] unit-test
{ B{ 0 12 0 139 } } [ [ X0 X0 9 %mul-imm ] B{ } make ] unit-test
USE: math.private
{ 21 } [ 7 [ { fixnum } declare 3 fixnum*fast ] compile-call ] unit-test
{ -63 } [ -7 [ { fixnum } declare 9 fixnum*fast ] compile-call ] unit-test
! MNEG supports destination/source aliasing.
{ B{ 32 252 2 155 } } [ [ X0 X1 X2 %mneg ] B{ } make ] unit-test
{ B{ 0 252 1 155 } } [ [ X0 X0 X1 %mneg ] B{ } make ] unit-test
{ B{ 32 252 0 155 } } [ [ X0 X1 X0 %mneg ] B{ } make ] unit-test
! The architecture default remains a portable MUL then NEG lowering.
{ 8 } [ [ X0 X1 X2 M\ object %mneg execute ] B{ } make length ] unit-test

USE: alien
QUALIFIED-WITH: alien.c-types c
QUALIFIED-WITH: cpu.arm.64.assembler a

: acquire-uint ( ptr -- n )
    c:uint { c:void* } cdecl [ W0 X0 a:LDAR ] alien-assembly ;
: release-uint ( n ptr -- )
    c:void { c:uint c:void* } cdecl [ W0 X1 a:STLR ] alien-assembly ;

{ 3735928559 } [ 0 c:uint <ref> [ 3735928559 swap release-uint ] keep acquire-uint ] unit-test

: increment-exclusive ( ptr -- n )
    c:uint { c:void* } cdecl [
        <label> [ resolve-label ] keep
        W1 X0 a:LDAXR
        W1 W1 1 a:ADD
        W2 W1 X0 a:STLXR
        W2 swap a:CBNZ
        W0 W1 a:MOV
    ] alien-assembly ;

{ 42 42 } [ 41 c:uint <ref> [ increment-exclusive ] keep acquire-uint ] unit-test

: scalar-fused-add ( a b c -- x )
    c:double { c:double c:double c:double } cdecl
    [ D0 D0 D1 D2 a:FMADDs ] alien-assembly ;
: scalar-fused-subtract ( a b c -- x )
    c:double { c:double c:double c:double } cdecl
    [ D0 D0 D1 D2 a:FMSUBs ] alien-assembly ;
: scalar-negated-fused-add ( a b c -- x )
    c:double { c:double c:double c:double } cdecl
    [ D0 D0 D1 D2 a:FNMADDs ] alien-assembly ;
: scalar-negated-fused-subtract ( a b c -- x )
    c:double { c:double c:double c:double } cdecl
    [ D0 D0 D1 D2 a:FNMSUBs ] alien-assembly ;

{ 10.0 } [ 2.0 3.0 4.0 scalar-fused-add ] unit-test
{ -2.0 } [ 2.0 3.0 4.0 scalar-fused-subtract ] unit-test
{ -10.0 } [ 2.0 3.0 4.0 scalar-negated-fused-add ] unit-test
{ 2.0 } [ 2.0 3.0 4.0 scalar-negated-fused-subtract ] unit-test
! A cancellation whose low product bits would disappear with two roundings.
{ -4.930380657631324e-32 } [
    1.0000000000000002 0.9999999999999998 -1.0 scalar-fused-add
] unit-test

! The integer-bit conversion intentionally does not raise floating-point
! exceptions. Numeric results match the portable path, whose incidental flags
! (and enabled traps) can differ. Inspect flags around an already compiled call.
{ { } } [
    uint-4{ 0x7f800001 0xff800001 0x3fc00000 0xbfc00000 } float-4-cast
    [ compiled-float>integer drop ] collect-fp-exceptions
] unit-test
{ { +fp-zero-divide+ } } [
    uint-4{ 0x7f800001 0xff800001 0x3fc00000 0xbfc00000 } float-4-cast
    [
        { +fp-zero-divide+ } set-fp-exception-flags
        compiled-float>integer drop fp-exception-flags
    ] without-fp-traps
] unit-test
