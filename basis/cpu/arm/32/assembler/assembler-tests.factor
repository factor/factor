IN: cpu.arm32.assembler.tests
USING: cpu.arm.32.assembler math tools.test namespaces make
sequences kernel quotations literals ;
FROM: cpu.arm.32.assembler => B ;

: test-opcode ( expect quot -- ) [ f emit-bytecode? [ { } make first ] with-variable ] curry unit-test ;

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

{ 0xe30a0bcd } [ R0 0xabcd MOVW ] test-opcode
{ 0xe34f4fff } [ R4 0xffff MOVT ] test-opcode
{ 0xe12fff3c } [ [ have-BLX? on IP BLX ] with-scope ] test-opcode
{ B{ 205 11 10 227 } } [
    [ emit-bytecode? on [ R0 0xabcd MOVW ] B{ } make ] with-scope
] unit-test

{ B{ 4 192 159 229 60 255 47 225 0 0 0 234 0 0 0 0 } } [
    [ emit-bytecode? on have-BLX? on
      [ f call-address 2drop ] B{ } make ] with-scope
] unit-test
{ B{ 0 0 159 229 0 0 0 234 0 0 0 0 } } [
    [ emit-bytecode? on
      [ f R0 load-address 2drop ] B{ } make ] with-scope
] unit-test

{ 0xe92d4010 } [ ${ R4 LR } PUSH ] test-opcode
{ 0xe8bd8010 } [ ${ R4 PC } POP ] test-opcode
{ 0xed2d0b20 } [ VPUSH-D0-D15 ] test-opcode
{ 0xecbd0b20 } [ VPOP-D0-D15 ] test-opcode
{ 0xeef10a10 } [ R0 VMRS ] test-opcode
{ 0xeee10a10 } [ R0 VMSR ] test-opcode

{ 0xeafffff8 } [ -8 B ] test-opcode

{ 0xe16f2f13 } [ R2 R3 CLZ ] test-opcode

{ 0xe1a03211 } [ R3 R1 R2 <LSL> MOV ] test-opcode
{ 0xe0c32190 } [ R2 R3 R0 R1 SMULL ] test-opcode

{ 0xe5101003 } [ R1 R0 -3 <+> LDR ] test-opcode

{ 0x31a00001 } [ LO R0 R1 MOV ] test-opcode
{ 0x41a00001 } [ MI R0 R1 MOV ] test-opcode

{ 0xe10fc000 } [ R12 MRS-APSR ] test-opcode
{ 0xe12cf00c } [ R12 MSR-APSR ] test-opcode

{ 0xe2401002 } [ R1 R0 -2 ADD ] test-opcode
{ 0xe2801002 } [ R1 R0 -2 SUB ] test-opcode
