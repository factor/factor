! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays classes.struct
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
cpu.architecture cpu.riscv.32.abi kernel namespaces sequences system tools.test ;
FROM: alien.c-types => float ;
IN: cpu.riscv.32.abi.tests

STRUCT: int-fp { integer int } { number double } ;
STRUCT: wide-int-fp { integer longlong } { number double } ;
STRUCT: fp-pair { first double } { second double } ;
STRUCT: gp-pair { first uint } { second uint } ;
UNION-STRUCT: fp-union { number double } { integer ulonglong } ;

{ { 0 8 } } [ int-fp lookup-c-type fp-struct-members [ first ] map ] unit-test
{ { 0 8 } } [ int-fp fp-struct-members [ first ] map ] unit-test
{ f } [ wide-int-fp lookup-c-type fp-struct-members ] unit-test
{ { double-rep double-rep } } [ fp-pair lookup-c-type fp-struct-members [ third ] map ] unit-test
{ f } [ fp-union lookup-c-type fp-struct-members ] unit-test

! The scalar convention is independent of the native VM's cell width.
{ t } [
    [
        8 float-reg-reps set f varargs-parameter? set
        double lookup-c-type scalar-integer-convention?
    ] with-scope
] unit-test
{ t } [
    [
        0 float-reg-reps set t varargs-parameter? set
        double lookup-c-type scalar-integer-convention?
    ] with-scope
] unit-test
{ f } [
    [
        7 float-reg-reps set f varargs-parameter? set
        double lookup-c-type scalar-integer-convention?
    ] with-scope
] unit-test

! Flattening dispatches through the native CPU and uses its cell width.
! Keep the ILP32D two-word checks on an actual RV32 VM.
cpu riscv.32? [
    { { int-rep int-rep } } [
        [
            0 int-reg-reps set 0 float-reg-reps set
            gp-pair lookup-c-type flatten-struct-type [ first ] map
        ] with-scope
    ] unit-test

    { { 4 4 } } [
        [
            0 int-reg-reps set 0 float-reg-reps set
            gp-pair lookup-c-type flatten-struct-type [ fourth ] map
        ] with-scope
    ] unit-test

    { { int-rep int-rep } } [
        [
            0 int-reg-reps set 8 float-reg-reps set
            double lookup-c-type flatten-scalar-parameter [ first ] map
        ] with-scope
    ] unit-test

    { { int-rep int-rep } } [
        [
            0 int-reg-reps set 0 float-reg-reps set
            t varargs-parameter? set
            double lookup-c-type flatten-scalar-parameter [ first ] map
        ] with-scope
    ] unit-test
] when

! Stack integers do not consume the independent FP argument bank.
{ t } [
    [
        16 int-reg-reps set 0 float-reg-reps set
        fp-pair lookup-c-type parameter-fp-members >boolean
    ] with-scope
] unit-test
