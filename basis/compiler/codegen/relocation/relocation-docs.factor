USING: byte-vectors compiler.codegen.labels compiler.constants cpu.architecture
help.markup help.syntax make strings ;
IN: compiler.codegen.relocation

HELP: relocation-table
{ $description "A " { $link byte-vector } " holding the relocations for the current compilation. Each sequence of four bytes in the vector represents one relocation." } ;

HELP: add-relocation
{ $values
  { "class" "a relocation class such as " { $link rc-relative } }
  { "type" "a relocation type such as " { $link rt-safepoint } }
}
{ $description "Adds one relocation to the relocation table." } ;

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
    "USING: compiler.codegen.relocation cpu.x86.assembler"
    "cpu.x86.assembler.operands kernel layouts make prettyprint ;"
    "[ init-relocation RAX 0 MOV compiled-offset ] B{ } make"
    "cell-bits 64 = ["
    "    [ 10 = ] [ B{ 72 184 0 0 0 0 0 0 0 0 } = ] bi*"
    "] ["
    "    [ 6 = ] [ B{ 72 184 0 0 0 0 } = ] bi*"
    "] if . ."
    "t\nt"
  }
} ;

HELP: resolve-label
{ $values { "label/name" { $link label } " or " { $link string } } }
{ $description "Assigns the current " { $link compiled-offset } " to the given label." } ;
