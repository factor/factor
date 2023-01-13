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
