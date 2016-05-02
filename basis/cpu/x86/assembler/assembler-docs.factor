USING: compiler.codegen.labels cpu.x86.assembler.private help.markup
help.syntax ;
IN: cpu.x86.assembler

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
{ $values { "dst" "destination" "src" "source" } }
{ $description "Moves a value from one place to another." } ;

HELP: (MOV-I)
{ $values { "dst" "destination" "src" "immediate value" } }
{ $description "MOV where the src is immediate." } ;

ARTICLE: "cpu.x86.assembler" "X86 assembler" "This vocab implements an assembler for x86 architectures." ;

ABOUT: "cpu.x86.assembler"
