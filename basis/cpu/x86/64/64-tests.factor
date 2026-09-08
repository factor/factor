USING: alien alien.c-types assocs compiler.cfg.registers
cpu.architecture cpu.x86.64 cpu.x86.assembler cpu.x86.assembler.operands make
sequences tools.test ;
IN: cpu.x86.64.tests

: assembly-test-1 ( -- x ) int { } cdecl [ RAX 3 MOV ] alien-assembly ;

{ 3 } [ assembly-test-1 ] unit-test

: assembly-test-2 ( a b -- x )
    int { int int } cdecl [
        param-reg-0 param-reg-1 ADD
        int-regs return-regs at first param-reg-0 MOV
    ] alien-assembly ;

{ 23 } [ 17 6 assembly-test-2 ] unit-test

{ B{ 73 131 198 24 } } [
    [ T{ ds-loc { n 3 } } %inc ] B{ } make
] unit-test

! High-half extraction must initialize a distinct destination. UNPCKHPD
! reads its first operand as well as its second; coalescing can hide this.
{ B{ 0x0f 0x28 0xc1 0x66 0x0f 0x15 0xc1 } } [
    [ XMM0 XMM1 float-4-rep %tail>head-vector ] B{ } make
] unit-test

{ B{ 0x0f 0x28 0xc1 0x66 0x0f 0x15 0xc1 } } [
    [ XMM0 XMM1 double-2-rep %tail>head-vector ] B{ } make
] unit-test

{ B{ 0x66 0x0f 0x15 0xc0 } } [
    [ XMM0 XMM0 float-4-rep %tail>head-vector ] B{ } make
] unit-test
