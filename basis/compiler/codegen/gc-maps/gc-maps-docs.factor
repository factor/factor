USING: bit-arrays byte-arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.stack-frame help.markup help.syntax kernel math sequences ;
IN: compiler.codegen.gc-maps

HELP: emit-gc-info-bitmaps
{ $values
  { "gc-maps" sequence }
  { "counts" "counts of the three different types of gc checks" }
}
{ $description "Emits the scrub location data in the 'gc-maps' to the make sequence being created. The result is a concatenation of all datastack scrub locations, retainstack scrub locations and gc root locations converted into a byte-array. Given that byte-array and knowledge of the number of scrub locations, the original gc-map can be reconstructed."  } ;

HELP: emit-scrub
{ $values
  { "seqs" "a sequence of sequences of 0/1" }
  { "n" "length of the longest sequence" }
}
{ $description "Emits a space-efficient " { $link bit-array } " to the make sequence being created. The outputted array will be of length n times the number of sequences given. Each group of n elements in the array contains true values if the stack location should be scrubbed, and false if it shouldn't." }
{ $examples
  { $example
    "USING: bit-arrays byte-arrays compiler.codegen.gc-maps make prettyprint ;"
    "[ { B{ 0 } B{ 0 } B{ 1 1 1 0 } } emit-scrub ] ?{ } make . ."
    "?{ t f f f t f f f f f f t }\n4"
  }
} ;

{ emit-gc-info-bitmaps emit-scrub } related-words

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
{ $description "GC maps are emitted so that the end is aligned to a 16-byte boundary." } ;

HELP: gc-maps
{ $var-description "Variable that holds a sequence of " { $link gc-map } " tuples. Gc maps are added to the sequence by " { $link gc-map-here } "." } ;

HELP: gc-map-needed?
{ $values { "gc-map/f" { $maybe gc-map } } { "?" boolean } }
{ $description "If all slots in the gc-map are empty, then it doesn't need to be emitted." } ;

HELP: gc-root-offsets
{ $values { "gc-map" gc-map } { "offsets" sequence } }
{ $description "Gets the offets of all roots in a gc-map. The " { $link stack-frame } " variable must have been setup first." } ;

HELP: serialize-gc-maps
{ $values { "byte-array" byte-array } }
{ $description "Serializes the gc-maps that have been registered in the " { $link gc-maps } " variable into a byte-array." } ;

HELP: gc-map-here
{ $values { "gc-map" gc-map } }
{ $description "Registers the gc map in the " { $link gc-maps } " dynamic variable at the current compiled offset." } ;

ARTICLE: "compiler.codegen.gc-maps" "GC maps"
"The " { $vocab-link "compiler.codegen.gc-maps" } " handles generating code for keeping track of garbage collection maps. Every code block either ends with:"
{ $list "uint 0" }
"or"
{ $list
  {
      "bitmap, byte aligned, five subsequences:"
      { $list
        "scrubbed data stack locations"
        "scrubbed retain stack locations"
        "GC root spill slots"
      }
  }
  "uint[] base pointers"
  "uint[] return addresses"
  "uint largest scrubbed data stack location"
  "uint largest scrubbed retain stack location"
  "uint largest GC root spill slot"
  "uint largest derived root spill slot"
  "int number of return addresses"
}
"The " { $link gc-map } " tuples of the " { $link cfg } " are serialized to the above format and placed directly after the generated code."
$nl
"Main entry point:"
{ $subsections emit-gc-maps } ;

ABOUT: "compiler.codegen.gc-maps"
