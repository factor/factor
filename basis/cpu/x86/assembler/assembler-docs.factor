USING: compiler.codegen.labels cpu.x86.assembler help.markup help.syntax ;
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
