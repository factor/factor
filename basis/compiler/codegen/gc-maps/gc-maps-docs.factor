USING: bit-arrays byte-arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.stack-frame help.markup help.syntax kernel math sequences ;
IN: compiler.codegen.gc-maps

HELP: emit-gc-info-bitmap
{ $values
  { "gc-maps" sequence }
  { "spill-count" "maximum number of spill slots" }
}
{ $description "Emits a bitmap of live locations of spill slots in the 'gc-maps' to the current make sequence." } ;

HELP: emit-gc-roots
{ $values
  { "seqs" "a sequence of sequences" }
  { "n" "maximum number of spill slots" }
} { $description "Emits the sequences of spill slots as a sequence of " { $link t } " and " { $link f } " values to the current make sequence." } ;

HELP: emit-uint
{ $values { "n" integer } }
{ $description "Emits an unsigned 32 bit integer to the make sequence being created. The word takes care of ensuring that the byte order is correct for the current machine." }
{ $examples
  { $example
    "USING: compiler.codegen.gc-maps make prettyprint ;"
    "[ 0xffff emit-uint ] B{ } make ."
    "B{ 255 255 0 0 }"
  }
} ;

HELP: emit-gc-maps
{ $description "One of the last stages in code generation are emitting the GC maps which are placed directly after the generated executable code. They are emitted so that the end is aligned to a 16-byte boundary." } ;

HELP: gc-maps
{ $var-description "Variable that holds a sequence of " { $link gc-map } " tuples. Gc maps are added to the sequence by " { $link gc-map-here } "." } ;

HELP: gc-map-needed?
{ $values { "gc-map/f" { $maybe gc-map } } { "?" boolean } }
{ $description "If all slots in the gc-map are empty, then it doesn't need to be emitted." } ;

HELP: gc-root-offsets
{ $values { "gc-map" gc-map } { "offsets" sequence } }
{ $description "Gets the offsets of all roots in a gc-map. The " { $link cfg } " variable must have been set and the stack-frame slot been initialized." } ;

HELP: serialize-gc-maps
{ $values { "byte-array" byte-array } }
{ $description "Serializes the gc-maps that have been registered in the " { $link gc-maps } " variable into a byte-array." } ;

HELP: gc-map-here
{ $values { "gc-map" gc-map } }
{ $description "Registers the gc map in the " { $link gc-maps } " dynamic variable at the current compiled offset." } ;

ARTICLE: "compiler.codegen.gc-maps" "GC maps"
"The " { $vocab-link "compiler.codegen.gc-maps" } " vocab serializes a compiled words gc maps into a space-efficient format which is appended to the end of the code block."
$nl
"Every code block generated either ends with:"
{ $list "uint 0" }
"or"
{ $list
  {
      "a bitmap representing the indices of the spill slots that contain roots in each gc map"
  }
  "uint[] base pointers"
  "uint[] return addresses"
  "uint largest GC root spill slot"
  "uint largest derived root spill slot"
  "int number of return addresses/gc maps"
}
"For example, if there are three gc maps and each contain four roots, then bit 0-3 in the bitmap would indicate liveness of the first gc maps roots, 4-7 of the second and 8-11 of the third."
$nl
"Main entry point:"
{ $subsections emit-gc-maps } ;

ABOUT: "compiler.codegen.gc-maps"
