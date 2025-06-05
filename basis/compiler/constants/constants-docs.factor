USING: compiler.codegen.relocation help.markup help.syntax math vm ;
IN: compiler.constants

HELP: context-callstack-save-offset
{ $values { "n" integer } }
{ $description "Offset in bytes in the " { $link context } " struct to where the c callstack is saved." } ;

HELP: rc-absolute
{ $description "Absolute address in a four-byte location." } ;

HELP: rc-absolute-cell
{ $description "Indicates that the relocation is a cell-sized absolute address to an object in the VM." } ;


HELP: rt-cards-offset
{ $description "Relocation offset type for the cards table." }
{ $see-also rel-cards-offset } ;

HELP: rt-decks-offset
{ $description "Relocation offset type for the decks table." }
{ $see-also rel-decks-offset } ;

HELP: rt-literal
{ $description "Relocation type for a literal. The literal can be either an immediate such as a fixnum or " { $link f } " or an object reference." }
{ $see-also rel-literal } ;

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
  string-offset
  tuple-class-offset
  word-entry-point-offset
}
"Relocation classes:"
{ $subsections
    rc-absolute-cell
    rc-absolute
    rc-absolute-2
    rc-absolute-1
    rc-relative
    rc-relative-arm-b
    rc-relative-arm-b.cond/ldr
    rc-absolute-arm-ldur
    rc-absolute-arm-cmp
}
"Relocation types:"
{ $subsections
    rt-dlsym
    rt-entry-point
    rt-entry-point-pic
    rt-entry-point-pic-tail
    rt-here
    rt-this
    rt-literal
    rt-untagged
    rt-megamorphic-cache-hits
    rt-vm
    rt-cards-offset
    rt-decks-offset
    rt-dlsym-toc
    rt-inline-cache-miss
    rt-safepoint
} ;

ABOUT: "compiler.constants"
