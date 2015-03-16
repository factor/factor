USING: byte-vectors compiler.codegen.labels compiler.constants cpu.architecture
help.markup help.syntax make strings ;
IN: compiler.codegen.relocation

HELP: relocation-table
{ $description "A " { $link byte-vector } " holding the relocations for the current compilation. Each sequence of four bytes in the vector represents one relocation." }
{ $see-also init-relocation } ;

HELP: add-relocation
{ $values
  { "class" "a relocation class such as " { $link rc-relative } }
  { "type" "a relocation type such as " { $link rt-safepoint } }
}
{ $description "Adds one relocation to the relocation table." } ;

HELP: add-literal
{ $values { "obj" "a symbol" } }
{ $description "Adds a symbol to the " { $link literal-table } "." } ;

HELP: init-relocation
{ $description "Initializes the dynamic variables related to code relocation." } ;

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

ARTICLE: "compiler.codegen.relocation" "Relocatable VM objects"
"The " { $vocab-link "compiler.codegen.relocation" } " deals with assigning memory addresses to VM objects, such as the card table. Those objects have different addresses during each execution which is why they are \"relocatable\". The vocab is shared by the optimizing and non-optimizing compiler." ;

ABOUT: "compiler.codegen.relocation"
