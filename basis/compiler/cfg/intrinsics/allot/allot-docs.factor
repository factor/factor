USING: byte-arrays classes.tuple.private compiler.cfg compiler.tree
help.markup help.syntax ;
IN: compiler.cfg.intrinsics.allot

HELP: emit-<byte-array>
{ $values
  { "block" "current " { $link basic-block } }
  { "#call" node }
  { "block'" basic-block }
}
{ $description "Emits optimized cfg instructions for allocating a " { $link byte-array } "." } ;

HELP: emit-<tuple-boa>
{ $values
  { "block" "current " { $link basic-block } }
  { "#call" #call }
  { "block'" basic-block }
}
{ $description "Emits intrinsic cfg instructions for building and allocating tuples. The intrinsic condition is that the tuple layout given to " { $link <tuple-boa> } " must be a literal." }
{ $see-also <tuple-boa> } ;

ARTICLE: "compiler.cfg.intrinsics.allot" "Generating instructions for inline memory allocation"
"Generating instructions for inline memory allocation"
$nl
"Emitters:"
{ $subsections
  emit-(byte-array)
  emit-<array>
  emit-<byte-array>
  emit-<tuple-boa>
} ;

ABOUT: "compiler.cfg.intrinsics.allot"
