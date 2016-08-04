USING: alien compiler.cfg.builder.alien.params cpu.architecture
cpu.x86.assembler.operands kernel literals system tools.test ;
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
