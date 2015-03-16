USING: bootstrap.image.private effects help.markup help.syntax strings ;
IN: bootstrap.primitives

HELP: make-sub-primitive
{ $values { "word" string } { "vocab" string } { "effect" effect } }
{ $description "Defines a sub primitive word." }
{ $see-also define-sub-primitive } ;
