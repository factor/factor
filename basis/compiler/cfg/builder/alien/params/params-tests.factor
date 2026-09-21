USING: alien arrays compiler.cfg.builder.alien.params cpu.architecture
cpu.x86.assembler.operands kernel layouts literals locals math namespaces
sequences system tools.test vectors ;
IN: compiler.cfg.builder.alien.params.tests

! next-reg-param
cpu x86.64? [
    os windows? { RCX XMM1 XMM2 R9 } { RDI XMM0 XMM1 RSI } ? [
        cdecl param-regs init-regs
        f int-rep next-reg-param
        f double-rep next-reg-param
        f float-rep next-reg-param
        f int-rep next-reg-param
    ] unit-test
] when

! reg-class-full?
{
    f t V{ } f
} [
    V{ 1 2 3 } clone f reg-class-full?
    V{ 1 } clone [ t reg-class-full? ] keep
    V{ 1 2 } t reg-class-full?
] unit-test

! Exercise AAPCS64 stack layout even on a host using Apple's compact ABI.
! Leave one FP register: the whole HFA must spill, along with the scalar
! following it. Each float member occupies four bytes, not eight.
:: spilled-float-group ( count initial compact? -- offsets size )
    [
        initial stack-params set
        compact? compact-stack-params? set
        0 stack-group-remaining set
        V{ 0 } clone float-regs set
        V{ } clone stack-values set
        count [| i |
            float-rep f f 4 4array i zero? count 0 ? suffix
            prepare-parameter-group
            i float-rep f f 4 next-parameter
        ] each-integer
        count float-rep f f 4 next-parameter
        stack-values get [ third ] map >array
        stack-params get
    ] with-scope ;

cell 8 = [
    { { 0 4 8 } 16 } [ 2 0 f spilled-float-group ] unit-test
    { { 8 12 16 24 } 32 } [ 3 8 f spilled-float-group ] unit-test
    { { 4 8 12 } 16 } [ 2 4 t spilled-float-group ] unit-test
] when
