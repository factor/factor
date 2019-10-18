USING: compiler.codegen.labels cpu.x86.assembler.private help.markup
help.syntax kernel math sequences ;
IN: cpu.x86.assembler

HELP: (MOV-I)
{ $values { "dst" "destination" } { "src" "immediate value" } }
{ $description "MOV where 'src' is immediate. If dst is a 64-bit register and the 'src' value fits in 32 bits, then zero extension is taken advantage of by downgrading 'dst' to a 32-bit register. That way, the instruction gets a shorter encoding." } ;

HELP: 1-operand
{ $values { "operand" "operand" } { "reg,rex.w,opcode" sequence } }
{ $description "Used for encoding some instructions with one operand." } ;

HELP: DEC
{ $values { "dst" "register" } }
{ $description "Emits a DEC instruction." } ;

HELP: INC
{ $values { "dst" "register" } }
{ $description "Emits an INC instruction." } ;

HELP: JE
{ $values { "dst" "destination address or " { $link label } } }
{ $description "Emits a conditional jump instruction to the given address relative to the current code offset." }
{ $examples
  { $unchecked-example
    "USING: cpu.x86.assembler make ;"
    "[ 0x0 JE ] B{ } make disassemble"
    "000000e9fcc71fe0: 0f8400000000  jz dword 0xe9fcc71fe6"
  }
} ;

HELP: MOV
{ $values { "dst" "destination" } { "src" "source" } }
{ $description "Moves a value from one place to another." } ;

HELP: MOVSX
{ $values { "dst" "destination" } { "src" "source" } }
{ $description "Moves a value with sign extension." } ;

HELP: PEXTRB
{ $values { "dest" "destination" } { "src" "source" } { "imm" "immediate" } }
{ $description "Packed extract byte. This instruction copies the byte selected by 'imm' into the first eight bits of the selected register." } ;

HELP: immediate-1/4
{ $values { "dst" "dst" } { "imm" "imm" } { "reg,rex.w,opcode" sequence } }
{ $description "If imm is a byte, compile the opcode and the byte. Otherwise, set the 8-bit operand flag in the opcode, and compile the cell. The 'reg' is not really a register, but a value for the 'reg' field of the mod-r/m byte." } ;

HELP: zero-extendable?
{ $values { "imm" integer } { "?" boolean } }
{ $description "All positive 32-bit numbers are zero extendable except for 0 which is the value used for relocations." } ;

ARTICLE: "cpu.x86.assembler" "CPU x86 assembler"
"This vocab implements an assembler for x86 architectures."
$nl
"General instructions:"
{ $subsections DEC INC JE MOV MOVSX }
"SSE instructions:"
{ $subsections PEXTRB } ;

ABOUT: "cpu.x86.assembler"
