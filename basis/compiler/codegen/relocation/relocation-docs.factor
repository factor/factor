USING: compiler.codegen.labels cpu.architecture help.markup help.syntax make
strings ;
IN: compiler.codegen.relocation

HELP: add-literal
{ $values { "obj" "a symbol" } }
{ $description "Adds a symbol to the " { $link literal-table } "." } ;

HELP: rel-safepoint
{ $values { "class" "a relocation class" } }
{ $description "Adds a safe point to the " { $link relocation-table } " for the current code offset. This word is used by the " { $link %safepoint } " generator." } ;

HELP: compiled-offset
{ $values { "n" "offset of the code being constructed in the current " { $link make } " sequence." } }
{ $description "The current compiled code offset. Used for (among other things) calculating jump labels." }
{ $examples
  { $example
    "USING: compiler.codegen.relocation cpu.x86.assembler cpu.x86.assembler.operands make prettyprint ;"
    "[ init-relocation RAX 0 MOV compiled-offset ] B{ } make . ."
    "B{ 72 184 0 0 0 0 0 0 0 0 }\n10"
  }
} ;

HELP: resolve-label
{ $values { "label/name" { $link label } " or " { $link string } } }
{ $description "Assigns the current " { $link compiled-offset } " to the given label." } ;
