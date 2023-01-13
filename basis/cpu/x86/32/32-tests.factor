IN: cpu.x86.32.tests
USING: alien alien.c-types tools.test cpu.x86.assembler
cpu.x86.assembler.operands ;

: assembly-test-1 ( -- x ) int { } cdecl [ EAX 3 MOV ] alien-assembly ;

{ 3 } [ assembly-test-1 ] unit-test
