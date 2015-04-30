USING: compiler.codegen.relocation help.markup help.syntax math ;
IN: compiler.constants

HELP: rt-cards-offset
{ $description "Relocation offset type for the cards table." }
{ $see-also rel-cards-offset } ;

HELP: rt-decks-offset
{ $description "Relocation offset type for the decks table." }
{ $see-also rel-decks-offset } ;

HELP: string-offset
{ $values { "n" integer } }
{ $description "hm" } ;


ARTICLE: "compiler.constants" "VM memory layout constants"
"Common constants."
$nl
"Constants that must match vm/memory.hpp:"
{ $subsections card-bits card-mark deck-bits }
"Constants that must match vm/layouts.hpp:"
{ $subsections
  alien-offset
  array-start-offset
  byte-array-offset
  callstack-length-offset
  callstack-top-offset
  context-callstack-bottom-offset
  context-callstack-save-offset
  context-callstack-seg-offset
  context-datastack-offset
  context-callstack-top-offset
  context-retainstack-offset
  float-offset
  profile-count-offset
  quot-entry-point-offset
  segment-end-offset
  segment-size-offset
  segment-start-offset
  slot-offset
  string-aux-offset
  string-offset
  tuple-class-offset
  underlying-alien-offset
  vm-context-offset
  vm-fault-flag-offset
  vm-signal-handler-addr-offset
  vm-spare-context-offset
  word-entry-point-offset
} ;

ABOUT: "compiler.constants"
