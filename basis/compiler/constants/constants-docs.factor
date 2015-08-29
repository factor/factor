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

HELP: vm-context-offset
{ $values { "n" integer } }
{ $description "Offset in bytes from the start of the vm struct to the context (ctx) field." } ;

ARTICLE: "compiler.constants" "VM memory layout constants"
"Common constants. All the values are given in relation to the bootstrap image being built."
$nl
"Constants that must match vm/memory.hpp:"
{ $subsections card-bits card-mark deck-bits }
"Constants that must match vm/layouts.hpp:"
{ $subsections
  profile-count-offset
  slot-offset
}
"Offsets to fields in the context struct:"
{ $subsections
  context-callstack-bottom-offset
  context-callstack-save-offset
  context-callstack-seg-offset
  context-datastack-offset
  context-callstack-top-offset
  context-retainstack-offset
}
"Offsets to field in the segment struct:"
{ $subsections
  segment-end-offset
  segment-size-offset
  segment-start-offset
}
"Offsets to fields in the vm struct:"
{ $subsections
  vm-context-offset
  vm-fault-flag-offset
  vm-signal-handler-addr-offset
  vm-spare-context-offset
}
"Offsets to fields in data objects:"
{ $subsections
  alien-offset
  array-start-offset
  byte-array-offset
  callstack-length-offset
  callstack-top-offset
  float-offset
  quot-entry-point-offset
  string-aux-offset
  string-offset
  tuple-class-offset
  underlying-alien-offset
  word-entry-point-offset
} ;

ABOUT: "compiler.constants"
