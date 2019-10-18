IN: cpu.arm.assembler.tests
USING: cpu.arm.assembler math tools.test namespaces make
sequences kernel quotations ;
FROM: cpu.arm.assembler => B ;

: test-opcode ( expect quot -- ) [ { } make first ] curry unit-test ;

[ HEX: ea000000 ] [ 0 B ] test-opcode
[ HEX: eb000000 ] [ 0 BL ] test-opcode
! [ HEX: e12fff30 ] [ R0 BLX ] test-opcode

[ HEX: e24cc004 ] [ IP IP 4 SUB ] test-opcode
[ HEX: e24cb004 ] [ FP IP 4 SUB ] test-opcode
[ HEX: e087e3ac ] [ LR R7 IP 7 <LSR> ADD ] test-opcode
[ HEX: e08c0109 ] [ R0 IP R9 2 <LSL> ADD ] test-opcode
[ HEX: 02850004 ] [ R0 R5 4 EQ ADD ] test-opcode
[ HEX: 00000000 ] [ R0 R0 R0 EQ AND ] test-opcode

[ HEX: e1a0c00c ] [ IP IP MOV ] test-opcode
[ HEX: e1a0c00d ] [ IP SP MOV ] test-opcode
[ HEX: e3a03003 ] [ R3 3 MOV ] test-opcode
[ HEX: e1a00003 ] [ R0 R3 MOV ] test-opcode
[ HEX: e1e01c80 ] [ R1 R0 25 <LSL> MVN ] test-opcode
[ HEX: e1e00ca1 ] [ R0 R1 25 <LSR> MVN ] test-opcode
[ HEX: 11a021ac ] [ R2 IP 3 <LSR> NE MOV ] test-opcode

[ HEX: e3530007 ] [ R3 7 CMP ] test-opcode

[ HEX: e008049a ] [ R8 SL R4 MUL ] test-opcode

[ HEX: e5151004 ] [ R1 R5 4 <-> LDR ] test-opcode
[ HEX: e41c2004 ] [ R2 IP 4 <-!> LDR ] test-opcode
[ HEX: e50e2004 ] [ R2 LR 4 <-> STR ] test-opcode

[ HEX: e7910002 ] [ R0 R1 R2 <+> LDR ] test-opcode
[ HEX: e7910102 ] [ R0 R1 R2 2 <LSL> <+> LDR ] test-opcode

[ HEX: e1d310bc ] [ R1 R3 12 <+> LDRH ] test-opcode
[ HEX: e1d310fc ] [ R1 R3 12 <+> LDRSH ] test-opcode
[ HEX: e1d310dc ] [ R1 R3 12 <+> LDRSB ] test-opcode
[ HEX: e1c310bc ] [ R1 R3 12 <+> STRH ] test-opcode
[ HEX: e19310b4 ] [ R1 R3 R4 <+> LDRH ] test-opcode
[ HEX: e1f310fc ] [ R1 R3 12 <!+> LDRSH ] test-opcode
[ HEX: e1b310d4 ] [ R1 R3 R4 <!+> LDRSB ] test-opcode
[ HEX: e0c317bb ] [ R1 R3 123 <+!> STRH ] test-opcode
[ HEX: e08310b4 ] [ R1 R3 R4 <+!> STRH ] test-opcode
