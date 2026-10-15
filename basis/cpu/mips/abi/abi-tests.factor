! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.complex arrays assocs classes.struct
compiler.cfg.builder.alien compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params cpu.architecture cpu.mips cpu.mips.abi
cpu.mips.assembler.registers kernel literals namespaces sequences system
 tools.test vectors ;
IN: cpu.mips.abi.tests

STRUCT: two-floats { a float } { b float } ;
STRUCT: float-double { a float } { b double } ;
STRUCT: double-int { a double } { b int } ;
STRUCT: two-doubles { a double } { b double } ;

{ { int-rep double-rep } } [
    mipsel.64 \ cpu [ float-double lookup-c-type flatten-struct-type keys ] with-variable
] unit-test
{ { double-rep int-rep } } [
    mipsel.64 \ cpu [ double-int lookup-c-type flatten-struct-type keys ] with-variable
] unit-test
{ { int-rep } } [
    mipsel.64 \ cpu [ two-floats lookup-c-type flatten-struct-type keys ] with-variable
] unit-test
{ { float-rep float-rep } } [
    mipsel.64 \ cpu [ two-floats lookup-c-type flatten-struct-type-return keys ] with-variable
] unit-test
{ { float-rep double-rep } } [
    mipsel.64 \ cpu [ float-double lookup-c-type flatten-struct-type-return keys ] with-variable
] unit-test
{ { int-rep int-rep } } [
    mipsel.64 \ cpu [ double-int lookup-c-type flatten-struct-type-return keys ] with-variable
] unit-test
{ { int-rep int-rep } } [
    mipsel.32 \ cpu [ two-floats lookup-c-type flatten-struct-type keys ] with-variable
] unit-test
{ { int-rep int-rep int-rep int-rep } } [
    mipsel.32 \ cpu [ float-double lookup-c-type flatten-struct-type keys ] with-variable
] unit-test
{ { 0 8 } } [
    mipsel.64 \ cpu [
        { float-rep double-rep } float-double lookup-c-type struct-components drop
    ] with-variable
] unit-test
{ { int-rep int-rep } } [
    mipsel.64 \ cpu [ t varargs-parameter? [
        two-doubles lookup-c-type flatten-struct-type keys
    ] with-variable ] with-variable
] unit-test
{ t f f f } [
    0 int-reg-reps [ 0 float-reg-reps [
        double lookup-c-type o32-fp-argument?
        t varargs-named-count [ double lookup-c-type o32-fp-argument? ] with-variable
        1 int-reg-reps [ double lookup-c-type o32-fp-argument? ] with-variable
        2 float-reg-reps [ double lookup-c-type o32-fp-argument? ] with-variable
    ] with-variable ] with-variable
] unit-test

! Real allocator uses positional slots across mixed register banks in N64.
{ ${ A0 F13 A2 F15 } 0 } [
    mipsel.64 \ cpu [ [
        f param-regs init-regs
        V{ } clone reg-values set V{ } clone stack-values set
        0 stack-params set 0 stack-group-remaining set
        0 int-reg-reps set 0 float-reg-reps set
        { int double int double } [ lookup-c-type flatten-scalar-parameter first ] map
        [ dup prepare-parameter-group 0 swap first3 8 next-parameter ] each
        reg-values get [ third ] map >array stack-params get
    ] with-scope ] with-variable
] unit-test

! An O32 eight-byte argument skips a1 and starts at a2, and its home
! area position advances from four to eight bytes before either half.
{ ${ A2 A3 } 8 } [
    mipsel.32 \ cpu [ [
        ${ A3 A2 A1 } >vector int-regs set ${ F14 F12 } >vector float-regs set
        4 stack-params set
        { int-rep f f 4 0 8 } prepare-abi-parameter-group
        int-regs get reverse >array stack-params get
    ] with-scope ] with-variable
] unit-test

! Independent GNU N64 caller/callee assembly uses swc1/lwc1 at
! offsets 0, 8, 16 for named floats beyond the eight register slots.
{ { 0 8 16 } 24 } [
    mips.64 \ cpu [ [
        f compact-stack-params? set 0 stack-params set
        { float-rep float-rep float-rep } [ 4 alloc-stack-param ] map
        stack-params get
    ] with-scope ] with-variable
] unit-test
{ { 0 8 16 } 24 } [
    mipsel.64 \ cpu [ [
        f compact-stack-params? set 0 stack-params set
        { float-rep float-rep float-rep } [ 4 alloc-stack-param ] map
        stack-params get
    ] with-scope ] with-variable
] unit-test

! C strings use a self-referential pair descriptor, not array dimensions.
{ { } } [ c-string lookup-c-type double-offsets ] unit-test
{ f } [ c-string lookup-c-type abi-members ] unit-test
{ { } } [ { c-string 2 } double-offsets ] unit-test
{ { 0 8 } } [ { double 2 } double-offsets ] unit-test

! GNU N64 complex float consumes two positional slots only when both fit.
{ { float-rep float-rep } } [
    mipsel.64 \ cpu [ [
        3 int-reg-reps set 3 float-reg-reps set
        complex-float lookup-c-type flatten-struct-type keys
    ] with-scope ] with-variable
] unit-test
{ { int-rep } } [
    mips.64 \ cpu [ [
        0 int-reg-reps set 7 float-reg-reps set
        complex-float lookup-c-type flatten-struct-type keys
    ] with-scope ] with-variable
] unit-test
{ { int-rep } } [
    mipsel.64 \ cpu [ [
        0 int-reg-reps set 0 float-reg-reps set
        t varargs-parameter? set
        complex-float lookup-c-type flatten-struct-type keys
    ] with-scope ] with-variable
] unit-test
{ t f { float-rep float-rep } { double-rep double-rep } } [
    mipsel.32 \ cpu [ [
        complex-float lookup-c-type return-struct-in-registers?
        two-floats lookup-c-type return-struct-in-registers?
        complex-float lookup-c-type flatten-struct-type-return keys
        complex-double lookup-c-type flatten-struct-type-return keys
    ] with-scope ] with-variable
] unit-test

! NetBSD's default N64 userland uses GP payloads even with hardware FP
! available. Native GCC captures distinguish GP low-word floats from
! stack floats at the slot base, and FP-member returns use V0/A0.
{ t f f } [
    netbsd \ os [
        mips.64 \ cpu [ mips-soft-float-abi? ] with-variable
        mips.32 \ cpu [ mips-soft-float-abi? ] with-variable
    ] with-variable
    linux \ os [ mips.64 \ cpu [ mips-soft-float-abi? ] with-variable ] with-variable
] unit-test
{ ${ V0 A0 } { } } [
    netbsd \ os [ mips.64 \ cpu [
        return-regs float-regs of f param-regs float-regs of
    ] with-variable ] with-variable
] unit-test
{ { int-rep int-rep } { double-rep double-rep } } [
    netbsd \ os [ mips.64 \ cpu [
        two-doubles lookup-c-type flatten-struct-type keys
        two-doubles lookup-c-type flatten-struct-type-return keys
    ] with-variable ] with-variable
] unit-test
{ { int-rep f f 4 0 4 float-rep } } [
    netbsd \ os [ mips.64 \ cpu [
        float lookup-c-type flatten-scalar-parameter first
    ] with-variable ] with-variable
] unit-test
{ { 0 int-rep 0 4 float-rep } 8 } [
    netbsd \ os [ mips.64 \ cpu [ [
        V{ } clone int-regs set V{ } clone stack-values set
        0 stack-params set 0 stack-group-remaining set
        { int-rep f f 4 0 4 float-rep } prepare-parameter-group
        0 int-rep f f 4 next-parameter
        stack-values get first stack-params get
    ] with-scope ] with-variable ] with-variable
] unit-test
