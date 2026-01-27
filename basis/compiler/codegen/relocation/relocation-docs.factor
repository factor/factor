USING: alien byte-vectors compiler.constants cpu.architecture
help.markup help.syntax make strings vectors ;
IN: compiler.codegen.relocation

HELP: add-dlsym-parameters
{ $values { "symbol" string } { "dll" dll } }
{ $description "Adds a pair of parameters for a reference to an external C function to the " { $link parameter-table } ". 'symbol' is the name of the function and 'dll' is the shared library which contains it." } ;

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

HELP: parameter-table
{ $var-description "The parameter table is a " { $link vector } " which contains all the parameters for the word being generated." }
{ $see-also add-dlsym-parameters init-relocation } ;

HELP: relocation-table
{ $description "A " { $link byte-vector } " holding the relocations for the current compilation. Each sequence of four bytes in the vector represents one relocation." }
{ $see-also init-relocation } ;

HELP: rel-decks-offset
{ $values { "class" "a relocation class" } }
{ $description "Adds a decks offset relocation. It is used for marking cards when emitting write barriers." } ;

HELP: rel-literal
{ $values { "literal" "a literal" } { "class" "a relocation class" } }
{ $description "Adds a reference to a literal value to the current code offset." } ;

HELP: rel-safepoint
{ $values { "class" "a relocation class" } }
{ $description "Adds a safe point to the " { $link relocation-table } " for the current code offset. This word is used by the " { $link %safepoint } " generator." } ;

ARTICLE: "compiler.codegen.relocation" "Relocatable VM objects"
"The " { $vocab-link "compiler.codegen.relocation" } " deals with assigning memory addresses to VM objects, such as the card table. Those objects have different addresses during each execution which is why they are \"relocatable\". The vocab is shared by the optimizing and non-optimizing compiler."
$nl
"Adding relocations:"
{ $subsections add-relocation rel-decks-offset rel-safepoint }
"Adding parameters:"
{ $subsections add-dlsym-parameters }
"Tables used during code generation:"
{ $subsections literal-table parameter-table relocation-table } ;

ABOUT: "compiler.codegen.relocation"
