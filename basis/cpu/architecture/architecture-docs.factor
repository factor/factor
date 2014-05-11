USING: assocs classes compiler.cfg.instructions cpu.x86.assembler
cpu.x86.assembler.operands help.markup help.syntax layouts literals math
multiline system words ;
IN: cpu.architecture

<<
STRING: ex-%box-alien
USING: compiler.codegen compiler.codegen.relocation cpu.architecture make ;
init-fixup init-relocation [ RAX RBX RCX %box-alien ] B{ } make disassemble
000000e9fcc720a0: 48b80100000000000000  mov rax, 0x1
000000e9fcc720aa: 4885db                test rbx, rbx
000000e9fcc720ad: 0f8400000000          jz dword 0xe9fcc720b3
000000e9fcc720b3: 498d4d10              lea rcx, [r13+0x10]
000000e9fcc720b7: 488b01                mov rax, [rcx]
000000e9fcc720ba: 48c70018000000        mov qword [rax], 0x18
000000e9fcc720c1: 4883c806              or rax, 0x6
000000e9fcc720c5: 48830130              add qword [rcx], 0x30
000000e9fcc720c9: 48c7400201000000      mov qword [rax+0x2], 0x1
000000e9fcc720d1: 48c7400a01000000      mov qword [rax+0xa], 0x1
000000e9fcc720d9: 48895812              mov [rax+0x12], rbx
000000e9fcc720dd: 4889581a              mov [rax+0x1a], rbx
;

STRING: ex-%allot
USING: cpu.architecture make ;
[ RAX 40 tuple RCX %allot ] B{ } make disassemble
0000000002270cc0: 498d4d10        lea rcx, [r13+0x10]
0000000002270cc4: 488b01          mov rax, [rcx]
0000000002270cc7: 48c7001c000000  mov qword [rax], 0x1c
0000000002270cce: 4883c807        or rax, 0x7
0000000002270cd2: 48830130        add qword [rcx], 0x30
;
>>

HELP: signed-rep
{ $values { "rep" representation } { "rep'" representation } }
{ $description "Maps any representation to its signed counterpart, if it has one." } ;

HELP: immediate-arithmetic?
{ $values { "n" number } { "?" boolean } }
{ $description
  "Can this value be an immediate operand for " { $link %add-imm } ", "
  { $link %sub-imm } ", or " { $link %mul-imm } "?"
} ;

HELP: machine-registers
{ $values { "assoc" assoc } }
{ $description "Mapping from register class to machine registers." } ;

HELP: vm-stack-space
{ $values { "n" number } }
{ $description "Parameter space to reserve in anything making VM calls." } ;

HELP: complex-addressing?
{ $values { "?" boolean } }
{ $description "Specifies if " { $link %slot } ", " { $link %set-slot } " and " { $link %write-barrier } " accept the 'scale' and 'tag' parameters, and if %load-memory and %store-memory work." } ;

HELP: param-regs
{ $values { "abi" "a calling convention symbol" } { "regs" assoc } }
{ $description "Retrieves the order in which machine registers are used for parameters for the given calling convention." } ;

HELP: %load-immediate
{ $values { "reg" "a register symbol" } { "val" "a value" } }
{ $description "Emits code for loading an immediate value into a register. On " { $link x86 } ", if val is 0, then an " { $link XOR } " instruction is emitted instead of " { $link MOV } "." } ;

HELP: %call
{ $values { "word" word } }
{ $description "Emits code for calling a word in Factor." } ;

HELP: %box-alien
{ $values { "dst" "destination register" } { "src" "source register" } { "temp" "temporary register" } }
{ $description "Emits machine code for boxing an alien value. Internally, this word will allocate five " { $link cells } " which wraps the alien." }
{ $examples { $unchecked-example $[ ex-%box-alien ] } }
{ $see-also ##box-alien %allot } ;

HELP: %allot
{ $values
  { "dst" "destination register symbol" }
  { "size" "number of bytes to allocate" }
  { "class" "one of the built-in classes listed in " { $link type-numbers } }
  { "temp" "temporary register symbol" }
}
{ $description "Emits machine code for allocating memory." }
{ $examples
  "In this example 40 bytes is allocated and a tagged pointer to the memory is put in " { $link RAX } ":"
  { $unchecked-example $[ ex-%allot ] }
} ;

HELP: fused-unboxing?
{ $values { "?" boolean } }
{ $description "Whether this architecture support " { $link %load-float } ", " { $link %load-double } ", and " { $link %load-vector } "." } ;

HELP: return-regs
{ $values { "regs" assoc } }
{ $description "What registers that will be used for function return values of which class." } ;
