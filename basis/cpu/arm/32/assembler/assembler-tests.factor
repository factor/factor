IN: cpu.arm32.assembler.tests
USING: cpu.arm.32.assembler math tools.test namespaces make
sequences kernel quotations ;
FROM: cpu.arm.32.assembler => B ;

: test-opcode ( expect quot -- ) [ { } make first ] curry unit-test ;

{ 0xea000000 } [ 0 B ] test-opcode
{ 0xeb000000 } [ 0 BL ] test-opcode
! { 0xe12fff30 } [ R0 BLX ] test-opcode

{ 0xe24cc004 } [ IP IP 4 SUB ] test-opcode
{ 0xe24cb004 } [ FP IP 4 SUB ] test-opcode
{ 0xe087e3ac } [ LR R7 IP 7 <LSR> ADD ] test-opcode
{ 0xe08c0109 } [ R0 IP R9 2 <LSL> ADD ] test-opcode
{ 0x02850004 } [ R0 R5 4 EQ ADD ] test-opcode
{ 0x00000000 } [ R0 R0 R0 EQ AND ] test-opcode

{ 0xe1a0c00c } [ IP IP MOV ] test-opcode
{ 0xe1a0c00d } [ IP SP MOV ] test-opcode
{ 0xe3a03003 } [ R3 3 MOV ] test-opcode
{ 0xe1a00003 } [ R0 R3 MOV ] test-opcode
{ 0xe1e01c80 } [ R1 R0 25 <LSL> MVN ] test-opcode
{ 0xe1e00ca1 } [ R0 R1 25 <LSR> MVN ] test-opcode
{ 0x11a021ac } [ R2 IP 3 <LSR> NE MOV ] test-opcode

{ 0xe3530007 } [ R3 7 CMP ] test-opcode

{ 0xe008049a } [ R8 SL R4 MUL ] test-opcode

{ 0xe5151004 } [ R1 R5 4 <-> LDR ] test-opcode
{ 0xe41c2004 } [ R2 IP 4 <-!> LDR ] test-opcode
{ 0xe50e2004 } [ R2 LR 4 <-> STR ] test-opcode

{ 0xe7910002 } [ R0 R1 R2 <+> LDR ] test-opcode
{ 0xe7910102 } [ R0 R1 R2 2 <LSL> <+> LDR ] test-opcode

{ 0xe1d310bc } [ R1 R3 12 <+> LDRH ] test-opcode
{ 0xe1d310fc } [ R1 R3 12 <+> LDRSH ] test-opcode
{ 0xe1d310dc } [ R1 R3 12 <+> LDRSB ] test-opcode
{ 0xe1c310bc } [ R1 R3 12 <+> STRH ] test-opcode
{ 0xe19310b4 } [ R1 R3 R4 <+> LDRH ] test-opcode
{ 0xe1f310fc } [ R1 R3 12 <!+> LDRSH ] test-opcode
{ 0xe1b310d4 } [ R1 R3 R4 <!+> LDRSB ] test-opcode
{ 0xe0c317bb } [ R1 R3 123 <+!> STRH ] test-opcode
{ 0xe08310b4 } [ R1 R3 R4 <+!> STRH ] test-opcode
