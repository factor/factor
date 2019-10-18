USING: cpu.x86.assembler cpu.x86.assembler.operands
cpu.x86.assembler.operands.private make tools.test ;
IN: cpu.x86.assembler.operands.tests

[ RCX RSP 2 0 <indirect> ] [ bad-index? ] must-fail-with

{ B{ 72 137 12 153 } } [
    [ RCX RBX 2 0 <indirect> RCX MOV ] B{ } make
] unit-test

! No specific encoding for RBP and R13
{ B{ 73 137 76 157 0 } } [
    [ R13 RBX 2 f <indirect> RCX MOV ] B{ } make
] unit-test
