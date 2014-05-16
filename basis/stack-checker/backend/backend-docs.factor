USING: compiler.tree effects help.markup help.syntax quotations sequences
stack-checker.visitor ;
IN: stack-checker.backend

HELP: infer-quot-here
{ $values { "quot" quotation } }
{ $description "Performs inferencing on the given quotation. This word should only be called in a " { $link with-infer } " context." } ;

HELP: introduce-values
{ $values { "values" sequence } }
{ $description "Emits an " { $link #introduce } " node to the current " { $link stack-visitor } " which pushes the given values onto the data stack." } ;

HELP: with-infer
{ $values { "quot" quotation } { "effect" effect } { "visitor" "a visitor, if any" } }
{ $description "Initializes the inference engine and then runs the given quotation which is supposed to perform the inferencing." } ;
