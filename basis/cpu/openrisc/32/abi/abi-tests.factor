! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.complex arrays classes.struct combinators
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
cpu.architecture cpu.openrisc.32.abi cpu.openrisc.32.assembler.registers
kernel literals math namespaces sequences system tools.test vectors ;
IN: cpu.openrisc.32.abi.tests

STRUCT: or1k-pair { high uint } { low uint } ;
STRUCT: or1k-triple { first uint } { second uint } { third uint } ;

{ 11 12 11 12 } [
    M\ openrisc.32 return-regs execute
    [ first second first2 [ n>> ] bi@ ]
    [ second second first [ lo>> ] [ hi>> ] bi ] bi
] unit-test

{ 3 4 5 6 7 8 3 4 4 5 5 6 6 7 7 8 8 8 } [
    f M\ openrisc.32 param-regs execute
    [ first second [ n>> ] each ]
    [ second second [ [ lo>> ] [ hi>> ] bi ] each ] bi
] unit-test

! Singles consume one GPR; doubles consume two consecutive GPRs without
! alignment. Both classes share the same r3-r8 cursor.
{ 3 4 4 5 5 6 } [
    [
        openrisc.32 \ cpu set
        f M\ openrisc.32 param-regs execute init-regs
        { float-rep } M\ openrisc.32 prepare-abi-parameter-group execute
        f float-rep next-reg-param
        { float-rep } M\ openrisc.32 prepare-abi-parameter-group execute
        f float-rep next-reg-param
        { double-rep } M\ openrisc.32 prepare-abi-parameter-group execute
        f double-rep next-reg-param
        [ [ lo>> ] [ hi>> ] bi ] tri@
    ] with-scope
] unit-test

{ f f f f } [
    M\ openrisc.32 long-long-on-stack? execute
    M\ openrisc.32 long-long-odd-register? execute
    M\ openrisc.32 float-right-align-on-stack? execute
    M\ openrisc.32 struct-return-on-stack? execute
] unit-test

{ t f t f } [
    complex-float M\ openrisc.32 value-struct? execute
    complex-double M\ openrisc.32 value-struct? execute
    complex-float M\ openrisc.32 return-struct-in-registers? execute
    complex-double M\ openrisc.32 return-struct-in-registers? execute
] unit-test

{ { int-rep int-rep } } [
    complex-float lookup-c-type
    M\ openrisc.32 flatten-struct-type-return execute [ first ] map
] unit-test

{ { 2 f } } [
    complex-float lookup-c-type
    M\ openrisc.32 flatten-struct-type execute
    [ dup length 4 > [ 4 swap nth ] [ drop f ] if ] map
] unit-test

! GCC passes ordinary aggregate arguments and results indirectly, including a
! two-word value that could otherwise fit in r11:r12.
{ f f f f } [
    or1k-pair lookup-c-type M\ openrisc.32 value-struct? execute
    or1k-triple lookup-c-type M\ openrisc.32 value-struct? execute
    or1k-pair lookup-c-type M\ openrisc.32 return-struct-in-registers? execute
    or1k-triple lookup-c-type M\ openrisc.32 return-struct-in-registers? execute
] unit-test

! Strict argument naming exhausts both register banks at the first unnamed
! parameter. This keeps every variadic tail value on the native stack.
{ 4 2 } [
    [
        ${ R6 R7 R8 } >vector int-regs set
        ${ F1 F2 } >vector float-regs set
        1 int-reg-reps set 0 float-reg-reps set
        t varargs-parameter? set
        { int-rep f t } M\ openrisc.32 prepare-abi-parameter-group execute
        int-reg-reps get float-reg-reps get
    ] with-scope
] unit-test

{ 1 0 } [
    [
        ${ R6 R7 R8 } >vector int-regs set
        ${ F1 F2 } >vector float-regs set
        1 int-reg-reps set 0 float-reg-reps set
        f varargs-parameter? set
        { int-rep f f } M\ openrisc.32 prepare-abi-parameter-group execute
        int-reg-reps get float-reg-reps get
    ] with-scope
] unit-test

! These checks need the target VM's four-byte cell size.
cpu openrisc.32? [
    { { int-rep int-rep } } [
        [
            0 int-reg-reps set 0 float-reg-reps set
            or1k-pair lookup-c-type flatten-struct-type [ first ] map
        ] with-scope
    ] unit-test

    { { double-rep } } [
        [
            0 int-reg-reps set 0 float-reg-reps set
            double lookup-c-type flatten-scalar-parameter [ first ] map
        ] with-scope
    ] unit-test
] when
