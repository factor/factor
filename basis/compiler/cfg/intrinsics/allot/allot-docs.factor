USING: byte-arrays compiler.tree help.markup help.syntax ;
IN: compiler.cfg.intrinsics.allot

HELP: emit-<byte-array>
{ $values { "node" node } }
{ $description "Emits optimized cfg instructions for allocating a " { $link byte-array } "." } ;

HELP: emit-<tuple-boa>
{ $values { "node" node } }
{ $description "Emits optimized cfg instructions for building and allocating tuples." } ;

ARTICLE: "compiler.cfg.intrinsics.allot" "Generating instructions for inline memory allocation"
"Generating instructions for inline memory allocation"
$nl
"Emitters:"
{ $subsections emit-<byte-array> emit-<tuple-boa> } ;

ABOUT: "compiler.cfg.intrinsics.allot"
